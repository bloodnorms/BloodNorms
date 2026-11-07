-- ============================================================================
-- BloodNorms | 0004_inbound.sql
-- Direct-contact inbound channels: WhatsApp assistant, voice calls,
-- capability links, pincodes, nearest banks, channel-verified requesters.
-- Tested on PostgreSQL 16 + PostGIS 3.4
-- ============================================================================

set search_path = public, extensions;

-- 1. Alter requests table to track origin and session
alter table public.requests
  add column if not exists origin text not null default 'web' check (origin in ('web', 'whatsapp', 'voice')),
  add column if not exists origin_session_id text;

-- 2. Inbound Sessions (WhatsApp & Phone Assistants)
create table if not exists public.inbound_sessions (
  id             uuid primary key default gen_random_uuid(),
  channel        text not null check (channel in ('whatsapp', 'voice_keypad', 'voice_ai')),
  phone_e164     text not null check (phone_e164 ~ '^\+91[6-9][0-9]{9}$'),
  language       text not null default 'en' check (language in ('en', 'te', 'hi')),
  state          text not null default 'start',
  slots          jsonb not null default '{}'::jsonb,
  identity_state text not null default 'unverified' check (identity_state in ('unverified', 'pending_confirm', 'verified')),
  request_id     uuid references public.requests(id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  expires_at     timestamptz not null default (now() + interval '45 minutes')
);
create index if not exists inbound_sessions_phone_idx on public.inbound_sessions (phone_e164, updated_at desc);
create index if not exists inbound_sessions_expires_idx on public.inbound_sessions (expires_at);

-- 3. Live Request Capability Access Keys (Hash only stored)
create table if not exists public.request_access_keys (
  key_hash   text primary key, -- sha256 hex
  request_id uuid not null references public.requests(id) on delete cascade,
  expires_at timestamptz not null default (now() + interval '72 hours'),
  created_at timestamptz not null default now()
);
create index if not exists request_access_keys_req_idx on public.request_access_keys (request_id);

-- 4. Pincodes Table (All-India Directory)
create table if not exists public.pincodes (
  pincode     text primary key check (pincode ~ '^[1-9][0-9]{5}$'),
  office_name text not null,
  district    text not null,
  state       text not null,
  geo         geography(Point, 4326) not null,
  lat         double precision not null,
  lng         double precision not null
);
create index if not exists pincodes_geo_idx on public.pincodes using gist (geo);

-- 5. Voice Calls Log (Duration, outcome, cost estimate - NO AUDIO, NO TRANSCRIPTS)
create table if not exists public.voice_calls (
  id                 uuid primary key default gen_random_uuid(),
  call_sid           text not null unique,
  phone_masked       text not null,
  direction          text not null check (direction in ('inbound', 'outbound')),
  mode               text not null default 'ivr' check (mode in ('ivr', 'ai')),
  language           text not null default 'en' check (language in ('en', 'te', 'hi')),
  duration_seconds   int not null default 0,
  outcome            text not null default 'completed',
  tool_calls_count   int not null default 0,
  estimated_cost_inr numeric(6, 2) not null default 0.00,
  meta               jsonb,
  created_at         timestamptz not null default now()
);
create index if not exists voice_calls_sid_idx on public.voice_calls (call_sid);
create index if not exists voice_calls_created_idx on public.voice_calls (created_at desc);

-- 6. Inbound Settings default seeds
insert into public.app_settings (key, value, description)
values
  ('inbound_whatsapp_enabled', '{"enabled": false}'::jsonb, 'WhatsApp requester intake assistant switch'),
  ('inbound_voice_enabled', '{"enabled": false}'::jsonb, 'Inbound phone calls intake switch'),
  ('voice_mode', '{"mode": "ivr"}'::jsonb, 'ivr (keypad) or ai (Gemini Live speech-to-speech)'),
  ('ai_voice_daily_minutes_cap', '{"value": 60}'::jsonb, 'Max daily minutes for AI voice before falling back to keypad'),
  ('ai_voice_max_call_seconds', '{"value": 360}'::jsonb, 'Hard timeout for a single AI voice call in seconds')
on conflict (key) do nothing;

-- 7. Nearest Banks Function (One source of truth for Web, WhatsApp, and Voice)
create or replace function public.nearest_banks(
  p_lat double precision,
  p_lng double precision,
  p_group text default null,
  p_component text default 'whole_blood',
  p_limit int default 10,
  p_max_km double precision default 100.0
)
returns table (
  id uuid,
  name text,
  address text,
  city text,
  district text,
  phones text[],
  is_24x7 boolean,
  distance_km double precision,
  stock_units int,
  stock_source text,
  stock_updated_at timestamptz,
  stock_freshness text,
  trust_score int,
  trust_label text
)
language sql stable security definer set search_path = public, extensions as $$
  select
    b.id,
    b.name,
    b.address,
    b.city,
    b.district,
    b.phones,
    b.is_24x7,
    round((st_distance(b.geo, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography) / 1000.0)::numeric, 1)::double precision as distance_km,
    coalesce(s.units, 0) as stock_units,
    s.source as stock_source,
    s.updated_at as stock_updated_at,
    case
      when s.updated_at is null then 'unknown'
      when s.updated_at >= now() - interval '2 hours' then 'fresh'
      when s.updated_at >= now() - interval '12 hours' then 'moderate'
      else 'stale'
    end as stock_freshness,
    b.trust_score,
    case
      when b.trust_score >= 80 then 'Reliable'
      when b.trust_score >= 40 then 'OK'
      else 'Often wrong'
    end as trust_label
  from public.blood_banks b
  left join public.bank_stock s
    on s.bank_id = b.id
   and (p_group is null or s.blood_group = p_group::public.blood_group)
   and s.component = p_component::public.blood_component
  where b.active = true
    and st_dwithin(b.geo, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, p_max_km * 1000.0)
  order by st_distance(b.geo, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography) asc
  limit p_limit;
$$;

-- 8. Pincode lookup helper
create or replace function public.pincode_lookup(p_code text)
returns table (office_name text, district text, state text, lat double precision, lng double precision)
language sql stable security definer set search_path = public as $$
  select office_name, district, state, lat, lng from public.pincodes where pincode = p_code limit 1;
$$;

-- 9. Mint & Resolve capability access keys
create or replace function public.mint_request_access_key(p_request_id uuid, p_hash text, p_ttl_hours int default 72)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.request_access_keys(key_hash, request_id, expires_at)
  values (p_hash, p_request_id, now() + make_interval(hours => p_ttl_hours))
  on conflict (key_hash) do update set expires_at = excluded.expires_at;
end $$;

create or replace function public.resolve_request_access_key(p_hash text)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  v_req_id uuid;
begin
  select request_id into v_req_id
    from public.request_access_keys
   where key_hash = p_hash and expires_at > now();
  return v_req_id;
end $$;

-- 10. AI Voice daily usage helper (India time / Asia/Kolkata)
create or replace function public.ai_voice_seconds_today()
returns int language sql stable security definer set search_path = public as $$
  select coalesce(sum(duration_seconds), 0)::int
    from public.voice_calls
   where mode = 'ai'
     and created_at >= (timezone('Asia/Kolkata', now())::date)::timestamptz;
$$;

-- 11. Create request for user (Server-side service-role function for WhatsApp and Voice)
create or replace function public.create_request_for_user(
  p_user_id uuid,
  p_origin text,
  p_origin_session_id text,
  p_blood_group public.blood_group,
  p_component public.blood_component,
  p_units int,
  p_urgency public.request_urgency,
  p_hospital_name text,
  p_hospital_area text,
  p_lat double precision,
  p_lng double precision,
  p_requester_name text,
  p_requester_phone text,
  p_requester_relation text default 'family',
  p_patient_first_name text default null,
  p_patient_age int default null,
  p_hospital_phone text default null,
  p_ward_detail text default null,
  p_allow_compatible boolean default false,
  p_note text default null
) returns uuid
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_id uuid;
  v_needed_by timestamptz;
  v_kill_switch boolean;
begin
  -- Check kill switch
  select coalesce((value->>'enabled')::boolean, false) into v_kill_switch
    from public.app_settings where key = 'kill_switch';
  if v_kill_switch then raise exception 'service_paused' using errcode = '54000'; end if;

  -- India bounds check
  if p_lat not between 6.0 and 38.0 or p_lng not between 68.0 and 98.0 then
    raise exception 'outside_india' using errcode = '22023';
  end if;

  -- Requester limits: max 3 requests / day
  if not public.rl_hit('req_create:' || p_requester_phone, 86400, 3) then
    raise exception 'rate_limited' using errcode = '54000';
  end if;

  -- One active request per phone
  if exists (
    select 1 from public.requests
     where requester_phone = p_requester_phone
       and status in ('searching', 'waiting_requester', 'enough_donors')
  ) then
    raise exception 'active_request_exists' using errcode = '23505';
  end if;

  -- Calculate needed_by
  v_needed_by := case p_urgency
    when 'now' then now() + interval '2 hours'
    when 'within_6h' then now() + interval '6 hours'
    when 'within_24h' then now() + interval '24 hours'
    else now() + interval '48 hours'
  end;

  insert into public.requests (
    requester_id, origin, origin_session_id, blood_group, component, units_needed,
    urgency, needed_by, hospital_name, hospital_area,
    hospital_geo, hospital_phone, ward_detail, patient_first_name, patient_age,
    requester_name, requester_relation, requester_phone, allow_compatible, note,
    status, current_ring_km, approved_up_to_km, wave_number
  ) values (
    p_user_id, p_origin, p_origin_session_id, p_blood_group, p_component, p_units,
    p_urgency, v_needed_by, p_hospital_name, p_hospital_area,
    st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, p_hospital_phone, p_ward_detail,
    p_patient_first_name, p_patient_age, p_requester_name, p_requester_relation,
    p_requester_phone, p_allow_compatible, p_note, 'searching', 0.5, 50.0, 1
  ) returning id into v_id;

  insert into public.audit_logs(actor_id, action, target_type, target_id, meta)
  values (p_user_id, 'create_request', 'request', v_id::text, jsonb_build_object('origin', p_origin, 'group', p_blood_group, 'units', p_units));

  return v_id;
end $$;

-- 12. Reveal donor phone for user (audited, rate-limited to 30/h)
create or replace function public.reveal_donor_phone_for_user(p_request_id uuid, p_contact_id uuid)
returns text language plpgsql security definer set search_path = public as $$
declare
  v_c public.request_contacts;
  v_phone text;
begin
  select * into v_c from public.request_contacts where id = p_contact_id and request_id = p_request_id;
  if not found or v_c.status not in ('accepted', 'standby', 'on_the_way', 'arrived') then
    raise exception 'not_found_or_forbidden' using errcode = '42501';
  end if;

  if not v_c.share_phone_consent then
    return null;
  end if;

  -- Rate limit reveals: 30 / hour
  if not public.rl_hit('reveal_phone:' || p_request_id::text, 3600, 30) then
    raise exception 'rate_limited' using errcode = '54000';
  end if;

  select phone_e164 into v_phone from public.donor_private where donor_id = v_c.donor_id;

  update public.request_donor_cards set phone_revealed = true where contact_id = p_contact_id;

  insert into public.audit_logs(actor_id, action, target_type, target_id)
  values (auth.uid(), 'reveal_donor_phone', 'contact', p_contact_id::text);

  return v_phone;
end $$;

