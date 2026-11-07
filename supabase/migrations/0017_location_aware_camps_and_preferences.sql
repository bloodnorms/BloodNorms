-- ============================================================================
-- BloodNorms | 0017_location_aware_camps_and_preferences.sql
-- Multi-Location Aware Donors & Geo-Fenced Blood Camp Broadcasting Engine
-- Ensures camp broadcast outreach strictly targets donors in the local camp radius
-- and suppresses out-of-region donors (e.g. Kakinada, Visakhapatnam, Vijayawada)
-- 1. Donors table location & away status columns
-- 2. Bank camps location, city, and target radius columns
-- 3. Enhanced preview_broadcast_audience with suppression breakdown & area telemetry
-- 4. Enhanced dispatch_geo_broadcast with targeted in-app notification dispatch
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================

set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Donors: Add location, away status, and travel preference columns
-- ---------------------------------------------------------------------------
alter table public.donors
  add column if not exists city text not null default 'Rajahmundry',
  add column if not exists area text not null default 'Danavaipeta',
  add column if not exists pincode text default '533101',
  add column if not exists travel_radius_km double precision not null default 15.0,
  add column if not exists lat double precision not null default 17.0005,
  add column if not exists lng double precision not null default 81.7820,
  add column if not exists is_away boolean not null default false,
  add column if not exists away_reason text default null,
  add column if not exists away_until timestamptz default null;

create index if not exists donors_city_idx on public.donors (city);
create index if not exists donors_is_away_idx on public.donors (is_away);

-- ---------------------------------------------------------------------------
-- 2. Bank Camps: Add city, district, pincode, target radius & coordinator
-- ---------------------------------------------------------------------------
alter table public.bank_camps
  add column if not exists city text not null default 'Rajahmundry',
  add column if not exists district text not null default 'East Godavari',
  add column if not exists pincode text default '533101',
  add column if not exists target_radius_km double precision not null default 10.0,
  add column if not exists directions_url text default null,
  add column if not exists coordinator_name text default null,
  add column if not exists coordinator_phone text default null;

create index if not exists bank_camps_city_idx on public.bank_camps (city);

-- ---------------------------------------------------------------------------
-- 3. Stored Procedure: preview_broadcast_audience (Enhanced with suppression breakdown)
-- ---------------------------------------------------------------------------
create or replace function public.preview_broadcast_audience(
  p_camp_id uuid default null,
  p_city text default 'All',
  p_center_lat double precision default null,
  p_center_lng double precision default null,
  p_radius_km double precision default 10.0,
  p_respect_travel_cap boolean default true,
  p_blood_group text default 'All',
  p_channel text default 'whatsapp'
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_lat double precision := p_center_lat;
  v_lng double precision := p_center_lng;
  v_city text := coalesce(p_city, 'All');
  v_venue text := 'Designated Center';
  v_camp_title text := 'Blood Donation Drive';
  v_unit_rate numeric;
  v_eligible_count int := 0;
  v_suppressed_count int := 0;
  v_sample jsonb := '[]'::jsonb;
  v_suppressed_sample jsonb := '[]'::jsonb;
  v_area_breakdown jsonb := '{}'::jsonb;
  v_suppression_reasons jsonb := '{}'::jsonb;
  v_estimated_cost numeric;
begin
  -- Resolve coordinates and venue if camp_id provided
  if p_camp_id is not null then
    select
      coalesce(v_lat, st_y(geo::geometry), 17.0005),
      coalesce(v_lng, st_x(geo::geometry), 81.7820),
      coalesce(nullif(v_city, 'All'), city, 'Rajahmundry'),
      coalesce(venue, 'Camp Venue'),
      coalesce(title, 'Blood Donation Drive')
    into v_lat, v_lng, v_city, v_venue, v_camp_title
    from public.bank_camps
    where id = p_camp_id;
  end if;

  -- Default to Rajahmundry coordinates if still null
  v_lat := coalesce(v_lat, 17.0005);
  v_lng := coalesce(v_lng, 81.7820);

  -- Determine unit rate from rate card (Meta WhatsApp vs SMS)
  if p_channel = 'sms' then
    v_unit_rate := 0.2800;
  else
    v_unit_rate := 0.8500;
  end if;

  -- Calculate candidate donors with precise Haversine distance and suppression reasons
  with evaluated_donors as (
    select
      d.id,
      coalesce(d.full_name, d.first_name, 'Donor') as full_name,
      d.phone,
      d.blood_group::text as blood_group,
      coalesce(d.city, 'Rajahmundry') as city,
      coalesce(d.area, 'Danavaipeta') as area,
      coalesce(d.travel_radius_km, 15.0) as donor_max_radius,
      d.is_away,
      -- Haversine distance in KM
      (
        6371 * acos(
          least(1.0, greatest(-1.0,
            cos(radians(v_lat)) * cos(radians(coalesce(d.lat, v_lat))) *
            cos(radians(coalesce(d.lng, v_lng)) - radians(v_lng)) +
            sin(radians(v_lat)) * sin(radians(coalesce(d.lat, v_lat)))
          ))
        )
      ) as distance_km
    from public.donors d
    where d.state = 'active'
  ),
  classified_donors as (
    select
      ed.*,
      case
        when ed.is_away then 'Donor is marked Out of Station / Away'
        when p_blood_group <> 'All' and ed.blood_group <> p_blood_group then 'Blood group mismatch (' || ed.blood_group || ')'
        when v_city <> 'All' and ed.city not ilike '%' || v_city || '%' then 'Different city (' || ed.city || ')'
        when ed.distance_km > p_radius_km then 'Outside target radius (' || round(ed.distance_km::numeric, 1) || ' km > ' || p_radius_km || ' km)'
        when p_respect_travel_cap and ed.distance_km > ed.donor_max_radius then 'Exceeds donor travel limit (' || ed.donor_max_radius || ' km < ' || round(ed.distance_km::numeric, 1) || ' km)'
        else 'ELIGIBLE'
      end as eligibility_status
    from evaluated_donors ed
  )
  select
    count(*) filter (where eligibility_status = 'ELIGIBLE'),
    count(*) filter (where eligibility_status <> 'ELIGIBLE'),
    coalesce(jsonb_agg(jsonb_build_object(
      'id', id,
      'name', full_name,
      'blood_group', blood_group,
      'city', city,
      'area', area,
      'distance_km', round(distance_km::numeric, 1),
      'travel_radius_km', donor_max_radius
    )) filter (where eligibility_status = 'ELIGIBLE'), '[]'::jsonb),
    coalesce(jsonb_agg(jsonb_build_object(
      'id', id,
      'name', full_name,
      'blood_group', blood_group,
      'city', city,
      'distance_km', round(distance_km::numeric, 1),
      'reason', eligibility_status
    )) filter (where eligibility_status <> 'ELIGIBLE'), '[]'::jsonb)
  into v_eligible_count, v_suppressed_count, v_sample, v_suppressed_sample
  from classified_donors;

  v_estimated_cost := round((v_eligible_count * v_unit_rate)::numeric, 2);

  return jsonb_build_object(
    'camp_id', p_camp_id,
    'venue_name', v_venue,
    'camp_title', v_camp_title,
    'target_city', v_city,
    'center_lat', v_lat,
    'center_lng', v_lng,
    'radius_km', p_radius_km,
    'respect_travel_cap', p_respect_travel_cap,
    'blood_group', p_blood_group,
    'channel', p_channel,
    'unit_rate_inr', v_unit_rate,
    'eligible_count', v_eligible_count,
    'suppressed_count', v_suppressed_count,
    'estimated_cost_inr', v_estimated_cost,
    'requires_approval', (v_eligible_count > 200),
    'sample_donors', v_sample,
    'suppressed_donors', (select jsonb_agg(x) from (select jsonb_array_elements(v_suppressed_sample) as x limit 20) s)
  );
end $$;

-- ---------------------------------------------------------------------------
-- 4. Stored Procedure: dispatch_geo_broadcast (With In-App Notifications)
-- ---------------------------------------------------------------------------
create or replace function public.dispatch_geo_broadcast(
  p_title text,
  p_message text,
  p_broadcast_type text,
  p_camp_id uuid default null,
  p_city text default 'All',
  p_center_lat double precision default null,
  p_center_lng double precision default null,
  p_radius_km double precision default 10.0,
  p_respect_travel_cap boolean default true,
  p_blood_group text default 'All',
  p_channel text default 'whatsapp',
  p_approval_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_preview jsonb;
  v_eligible_count int;
  v_suppressed_count int;
  v_cost numeric;
  v_broadcast_id uuid;
  v_requires_approval boolean;
  v_rec record;
begin
  -- 1. Get live audience calculation
  v_preview := public.preview_broadcast_audience(
    p_camp_id,
    p_city,
    p_center_lat,
    p_center_lng,
    p_radius_km,
    p_respect_travel_cap,
    p_blood_group,
    p_channel
  );

  v_eligible_count := (v_preview->>'eligible_count')::int;
  v_suppressed_count := (v_preview->>'suppressed_count')::int;
  v_cost := (v_preview->>'estimated_cost_inr')::numeric;
  v_requires_approval := (v_preview->>'requires_approval')::boolean;

  -- 2. Four-Eyes check if > 200 recipients
  if v_requires_approval and p_approval_id is null then
    return jsonb_build_object(
      'ok', false,
      'requires_approval', true,
      'eligible_count', v_eligible_count,
      'error', 'Broadcast reaches ' || v_eligible_count || ' donors (>200). Four-Eyes Maker-Checker approval required.'
    );
  end if;

  -- 3. Insert broadcast record
  insert into public.regional_broadcasts (
    camp_id,
    venue_name,
    target_city,
    center_lat,
    center_lng,
    radius_km,
    respect_travel_cap,
    recipients_count,
    suppressed_count,
    estimated_cost_inr,
    approval_id,
    channel,
    status
  ) values (
    p_camp_id,
    coalesce(v_preview->>'venue_name', 'Designated Center'),
    coalesce(v_preview->>'target_city', 'All'),
    (v_preview->>'center_lat')::double precision,
    (v_preview->>'center_lng')::double precision,
    p_radius_km,
    p_respect_travel_cap,
    v_eligible_count,
    v_suppressed_count,
    v_cost,
    p_approval_id,
    p_channel,
    'dispatched'
  )
  returning id into v_broadcast_id;

  -- 4. Queue targeted in-app notifications for each in-radius eligible donor
  if exists (select 1 from information_schema.tables where table_name = 'in_app_notifications') then
    for v_rec in select * from jsonb_to_recordset(v_preview->'sample_donors') as x(id text, name text, distance_km numeric, city text, area text)
    loop
      insert into public.in_app_notifications (
        recipient_id,
        recipient_role,
        title,
        body,
        category,
        payload
      ) values (
        v_rec.id::uuid,
        'donor',
        p_title,
        p_message || E'\n📍 Distance: ' || v_rec.distance_km || ' km from your location (' || coalesce(v_rec.area, 'Area') || ')',
        'camp_invite',
        jsonb_build_object(
          'broadcast_id', v_broadcast_id,
          'camp_id', p_camp_id,
          'distance_km', v_rec.distance_km,
          'city', v_rec.city,
          'area', v_rec.area
        )
      ) on conflict do nothing;
    end loop;
  end if;

  -- 5. Record cost event in ledger
  if exists (select 1 from information_schema.tables where table_name = 'cost_events') then
    insert into public.cost_events (
      request_id,
      service,
      units,
      unit_type,
      cost_inr,
      metadata
    ) values (
      null,
      case when p_channel = 'sms' then 'sms_failover' else 'whatsapp_meta' end,
      v_eligible_count,
      'messages',
      v_cost,
      jsonb_build_object(
        'broadcast_id', v_broadcast_id,
        'camp_id', p_camp_id,
        'city', p_city,
        'radius_km', p_radius_km,
        'suppressed_out_of_region', v_suppressed_count
      )
    );
  end if;

  -- 6. Record immutable audit log
  if exists (select 1 from information_schema.tables where table_name = 'audit_logs') then
    insert into public.audit_logs (actor_id, action, target_type, target_id, details)
    values (
      auth.uid(),
      'broadcast.geo_targeted',
      'regional_broadcast',
      v_broadcast_id,
      jsonb_build_object(
        'recipients', v_eligible_count,
        'suppressed', v_suppressed_count,
        'city', p_city,
        'radius_km', p_radius_km
      )
    );
  end if;

  return jsonb_build_object(
    'ok', true,
    'broadcast_id', v_broadcast_id,
    'recipients', v_eligible_count,
    'suppressed', v_suppressed_count,
    'estimated_cost_inr', v_cost,
    'channel', p_channel,
    'status', 'dispatched'
  );
end $$;

grant execute on function public.preview_broadcast_audience(uuid, text, double precision, double precision, double precision, boolean, text, text) to authenticated, anon;
grant execute on function public.dispatch_geo_broadcast(text, text, text, uuid, text, double precision, double precision, double precision, boolean, text, text, uuid) to authenticated, anon;
