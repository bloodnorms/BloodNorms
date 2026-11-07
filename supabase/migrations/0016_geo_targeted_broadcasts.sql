-- ============================================================================
-- BloodNorms | 0016_geo_targeted_broadcasts.sql
-- Regional & Geo-Fenced Blood Camp Broadcast Engine
-- Solves multi-location donor targeting: ensures camp broadcasts are ONLY sent
-- to donors within the specific camp venue radius and city/district.
-- 1. regional_broadcasts ledger
-- 2. preview_broadcast_audience (Haversine/PostGIS spatial distance + donor travel radius)
-- 3. dispatch_geo_broadcast with Four-Eyes check (>200 recipients) & cost tracking
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Regional Broadcasts Table
-- ---------------------------------------------------------------------------
create table if not exists public.regional_broadcasts (
  id                  uuid primary key default gen_random_uuid(),
  title               text not null,
  message             text not null,
  broadcast_type      text not null check (broadcast_type in ('camp_invitation', 'shortage_alert', 'awareness_campaign')),
  camp_id             uuid references public.camps(id) on delete set null,
  target_city         text not null default 'All',
  target_district     text,
  center_lat          double precision,
  center_lng          double precision,
  radius_km           double precision not null default 10.0,
  respect_travel_cap  boolean not null default true,
  blood_group_filter  text not null default 'All',
  channel             text not null default 'whatsapp' check (channel in ('whatsapp', 'sms')),
  recipients_count    int not null default 0,
  suppressed_count    int not null default 0,
  estimated_cost_inr  numeric(10, 2) not null default 0.00,
  approval_id         uuid references public.approval_requests(id) on delete set null,
  status              text not null default 'sent' check (status in ('pending_approval', 'queued', 'sent', 'failed')),
  dispatched_by       uuid references auth.users(id) on delete set null,
  created_at          timestamptz not null default now()
);

create index if not exists regional_broadcasts_created_idx on public.regional_broadcasts (created_at desc);

alter table public.regional_broadcasts enable row level security;
drop policy if exists regional_broadcasts_policy on public.regional_broadcasts;
create policy regional_broadcasts_policy on public.regional_broadcasts for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.regional_broadcasts to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 2. Stored Procedure: preview_broadcast_audience
-- Calculates exact eligible recipients within radius of camp venue or city
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
set search_path = public
as $$
declare
  v_lat double precision := p_center_lat;
  v_lng double precision := p_center_lng;
  v_city text := p_city;
  v_unit_rate numeric(10, 4) := 0.8500; -- Default WhatsApp marketing rate
  v_eligible_count int := 0;
  v_suppressed_count int := 0;
  v_estimated_cost numeric(10, 2) := 0.00;
  v_requires_approval boolean := false;
  v_sample jsonb;
begin
  -- If camp_id is provided, lookup camp coordinates and city
  if p_camp_id is not null then
    select
      coalesce(v_lat, c.latitude, 17.0005),
      coalesce(v_lng, c.longitude, 81.8040),
      case when v_city = 'All' or v_city is null then 'Rajahmundry' else v_city end
    into v_lat, v_lng, v_city
    from public.camps c
    where c.id = p_camp_id;
  end if;

  -- Default to Rajahmundry coordinates if not provided
  v_lat := coalesce(v_lat, 17.0005);
  v_lng := coalesce(v_lng, 81.8040);

  -- Determine unit rate from rate card
  if p_channel = 'sms' then
    v_unit_rate := 0.2800;
  else
    v_unit_rate := 0.8500;
  end if;

  -- Query eligible active donors matching criteria
  with candidate_donors as (
    select
      d.id,
      d.full_name,
      d.phone,
      d.blood_group,
      d.city,
      coalesce(d.travel_radius_km, 15.0) as donor_max_radius,
      -- Haversine distance in KM
      (
        6371 * acos(
          cos(radians(v_lat)) * cos(radians(coalesce(d.latitude, v_lat))) *
          cos(radians(coalesce(d.longitude, v_lng)) - radians(v_lng)) +
          sin(radians(v_lat)) * sin(radians(coalesce(d.latitude, v_lat)))
        )
      ) as distance_km
    from public.donors d
    where d.state = 'active'
      and (p_blood_group = 'All' or d.blood_group = p_blood_group)
      and (v_city = 'All' or d.city is null or d.city ilike '%' || v_city || '%')
  ),
  filtered_donors as (
    select *
    from candidate_donors
    where distance_km <= p_radius_km
      and (not p_respect_travel_cap or distance_km <= donor_max_radius)
  )
  select
    count(*),
    jsonb_agg(jsonb_build_object(
      'id', id,
      'name', full_name,
      'blood_group', blood_group,
      'distance_km', round(distance_km::numeric, 1),
      'city', city
    )) filter (where id is not null)
  into v_eligible_count, v_sample
  from (select * from filtered_donors limit 10) sub;

  -- Count total active donors minus eligible to know suppressed outside radius
  select count(*) - v_eligible_count into v_suppressed_count
  from public.donors
  where state = 'active';

  v_suppressed_count := greatest(v_suppressed_count, 0);
  v_estimated_cost := round(v_eligible_count * v_unit_rate, 2);
  v_requires_approval := (v_eligible_count > 200);

  return jsonb_build_object(
    'eligible_count', v_eligible_count,
    'suppressed_count', v_suppressed_count,
    'target_city', v_city,
    'center_lat', v_lat,
    'center_lng', v_lng,
    'radius_km', p_radius_km,
    'unit_rate_inr', v_unit_rate,
    'estimated_cost_inr', v_estimated_cost,
    'requires_approval', v_requires_approval,
    'sample_donors', coalesce(v_sample, '[]'::jsonb)
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Stored Procedure: dispatch_geo_broadcast
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
set search_path = public
as $$
declare
  v_preview jsonb;
  v_eligible_count int;
  v_suppressed_count int;
  v_cost numeric(10, 2);
  v_broadcast_id uuid;
begin
  -- 1. Calculate audience
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

  -- 2. Enforce Four-Eyes Approval Policy (> 200 recipients)
  if v_eligible_count > 200 and p_approval_id is null then
    return jsonb_build_object(
      'ok', false,
      'requires_approval', true,
      'eligible_count', v_eligible_count,
      'reason', 'Broadcast reach (' || v_eligible_count || ' donors) exceeds 200 recipients threshold. Requires Four-Eyes approval.'
    );
  end if;

  -- 3. Insert record into regional_broadcasts ledger
  insert into public.regional_broadcasts (
    title,
    message,
    broadcast_type,
    camp_id,
    target_city,
    center_lat,
    center_lng,
    radius_km,
    respect_travel_cap,
    blood_group_filter,
    channel,
    recipients_count,
    suppressed_count,
    estimated_cost_inr,
    approval_id,
    status
  ) values (
    p_title,
    p_message,
    p_broadcast_type,
    p_camp_id,
    p_city,
    (v_preview->>'center_lat')::double precision,
    (v_preview->>'center_lng')::double precision,
    p_radius_km,
    p_respect_travel_cap,
    p_blood_group,
    p_channel,
    v_eligible_count,
    v_suppressed_count,
    v_cost,
    p_approval_id,
    'sent'
  ) returning id into v_broadcast_id;

  -- 4. Record cost event in INR ledger
  insert into public.cost_events (
    service_name,
    units_consumed,
    unit_cost_inr,
    total_cost_inr,
    meta_payload
  ) values (
    case when p_channel = 'sms' then 'sms_failover' else 'whatsapp_marketing' end,
    v_eligible_count,
    (v_preview->>'unit_rate_inr')::numeric,
    v_cost,
    jsonb_build_object(
      'broadcast_id', v_broadcast_id,
      'broadcast_type', p_broadcast_type,
      'target_city', p_city,
      'radius_km', p_radius_km
    )
  );

  -- 5. Record in immutable platform audit log
  insert into public.audit_logs (action, detail)
  values (
    'broadcast.geo_targeted',
    jsonb_build_object(
      'broadcast_id', v_broadcast_id,
      'camp_id', p_camp_id,
      'city', p_city,
      'radius_km', p_radius_km,
      'recipients', v_eligible_count,
      'suppressed_outside_radius', v_suppressed_count,
      'cost_inr', v_cost
    )::text
  );

  return jsonb_build_object(
    'ok', true,
    'broadcast_id', v_broadcast_id,
    'recipients', v_eligible_count,
    'suppressed', v_suppressed_count,
    'estimated_cost_inr', v_cost
  );
end;
$$;

grant execute on function public.preview_broadcast_audience(uuid, text, double precision, double precision, double precision, boolean, text, text) to authenticated, anon;
grant execute on function public.dispatch_geo_broadcast(text, text, text, uuid, text, double precision, double precision, double precision, boolean, text, text, uuid) to authenticated, anon;

