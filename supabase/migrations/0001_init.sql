-- ============================================================================
-- BloodNorms | 0001_init.sql
-- Core schemas, enums, tables, RLS, matching, request lifecycle, donations.
-- Tested on PostgreSQL 16 + PostGIS 3.4
-- ============================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "postgis";

-- ---------------------------------------------------------------------------
-- 1. Enums
-- ---------------------------------------------------------------------------
create type public.blood_group as enum (
  'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
);

create type public.blood_component as enum (
  'whole_blood', 'red_cells', 'platelets', 'plasma'
);

create type public.request_urgency as enum (
  'now', 'within_6h', 'within_24h', 'planned'
);

create type public.request_status as enum (
  'searching', 'waiting_requester', 'enough_donors', 'exhausted', 'fulfilled', 'cancelled', 'expired'
);

create type public.contact_status as enum (
  'queued', 'contacting', 'accepted', 'standby', 'declined', 'no_answer', 'ineligible', 'on_the_way', 'arrived', 'donated', 'cancelled'
);

create type public.donor_state as enum (
  'draft', 'pending', 'active', 'paused', 'suspended', 'deleted'
);

create type public.trust_level as enum (
  'unverified', 'phone_verified', 'fully_verified', 'proven'
);

-- ---------------------------------------------------------------------------
-- 2. Blood Banks & Stock
-- ---------------------------------------------------------------------------
create table public.blood_banks (
  id           uuid primary key default gen_random_uuid(),
  name         text not null check (char_length(name) >= 3),
  address      text not null,
  city         text not null,
  district     text,
  state        text not null default 'Andhra Pradesh',
  pincode      text check (pincode ~ '^[1-9][0-9]{5}$'),
  geo          geography(Point, 4326) not null,
  phones       text[] not null default '{}',
  bank_type    text not null default 'charitable' check (bank_type in ('government', 'red_cross', 'charitable', 'private', 'hospital')),
  is_24x7      boolean not null default false,
  hours        text,
  licence_no   text,
  eraktkosh_id text,
  trust_score  int not null default 50 check (trust_score between 0 and 100),
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index blood_banks_geo_idx on public.blood_banks using gist (geo);
create index blood_banks_city_idx on public.blood_banks (city);

create table public.bank_stock (
  bank_id     uuid not null references public.blood_banks(id) on delete cascade,
  blood_group public.blood_group not null,
  component   public.blood_component not null default 'whole_blood',
  units       int not null default 0 check (units >= 0 and units <= 500),
  source      text not null default 'bank' check (source in ('bank', 'admin_call', 'eraktkosh', 'feedback')),
  updated_by  uuid references auth.users(id) on delete set null,
  updated_at  timestamptz not null default now(),
  primary key (bank_id, blood_group, component)
);
create index bank_stock_bank_idx on public.bank_stock (bank_id);

-- ---------------------------------------------------------------------------
-- 3. Donors & Privacy Partitioning
-- ---------------------------------------------------------------------------
create table public.donors (
  id                 uuid primary key references auth.users(id) on delete cascade,
  first_name         text not null check (char_length(first_name) between 1 and 40),
  last_name          text check (char_length(last_name) <= 40),
  gender             text not null check (gender in ('male', 'female', 'other')),
  date_of_birth      date not null,
  weight_kg          numeric(4,1) not null check (weight_kg >= 40.0),
  blood_group        public.blood_group not null,
  group_confidence   text not null default 'self_reported' check (group_confidence in ('self_reported', 'card_seen', 'report_seen', 'bank_confirmed')),
  platelets_ok       boolean not null default false,
  plasma_ok          boolean not null default true,
  state              public.donor_state not null default 'pending',
  trust_level        int not null default 1 check (trust_level between 0 and 3),
  donations_count    int not null default 0,
  last_donation_date date,
  next_eligible_date date,
  languages          text[] not null default '{"en"}',
  paused_until       date,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table public.donor_private (
  donor_id            uuid primary key references public.donors(id) on delete cascade,
  phone_e164          text not null unique check (phone_e164 ~ '^\+91[6-9][0-9]{9}$'),
  whatsapp_e164       text check (whatsapp_e164 ~ '^\+91[6-9][0-9]{9}$'),
  email               text not null unique,
  email_verified      boolean not null default false,
  emergency_encrypted text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create table public.donor_location (
  donor_id       uuid primary key references public.donors(id) on delete cascade,
  home_geo       geography(Point, 4326) not null,
  area           text not null,
  city           text not null,
  pincode        text not null check (pincode ~ '^[1-9][0-9]{5}$'),
  max_travel_km  int not null default 10 check (max_travel_km in (3, 5, 10, 25, 50, 100)),
  transport_mode text not null default 'two_wheeler' check (transport_mode in ('two_wheeler', 'car', 'public_transit', 'walk')),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index donor_location_geo_idx on public.donor_location using gist (home_geo);

create table public.donor_health (
  donor_id            uuid primary key references public.donors(id) on delete cascade,
  encrypted_answers   text not null,
  key_id              text not null default 'v1',
  all_clear           boolean not null default false,
  verified_at         timestamptz not null default now(),
  expires_at          timestamptz not null default (now() + interval '6 months')
);

create table public.donor_prefs (
  donor_id            uuid primary key references public.donors(id) on delete cascade,
  quiet_hours_start   time,
  quiet_hours_end     time,
  allow_critical_call boolean not null default true,
  monthly_request_cap int not null default 4 check (monthly_request_cap between 1 and 10),
  requests_this_month int not null default 0,
  updated_at          timestamptz not null default now()
);

create table public.consents (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  purpose      text not null,
  text_version text not null,
  agreed       boolean not null default true,
  channel      text not null default 'web',
  ip_hash      text,
  created_at   timestamptz not null default now()
);
create index consents_user_idx on public.consents (user_id);

-- ---------------------------------------------------------------------------
-- 4. Requests & Contacts
-- ---------------------------------------------------------------------------
create table public.requests (
  id                 uuid primary key default gen_random_uuid(),
  requester_id       uuid not null references auth.users(id) on delete cascade,
  blood_group        public.blood_group not null,
  component          public.blood_component not null default 'whole_blood',
  units_needed       int not null check (units_needed between 1 and 10),
  urgency            public.request_urgency not null default 'now',
  needed_by          timestamptz not null,
  hospital_name      text not null,
  hospital_area      text,
  hospital_geo       geography(Point, 4326) not null,
  hospital_phone     text,
  ward_detail        text,
  patient_first_name text,
  patient_age        int check (patient_age between 0 and 120),
  requester_name     text not null default 'Family',
  requester_relation text not null default 'family',
  requester_phone    text not null check (requester_phone ~ '^\+91[6-9][0-9]{9}$'),
  allow_compatible   boolean not null default false,
  note               text check (char_length(note) <= 300),
  status             public.request_status not null default 'searching',
  current_ring_km    numeric(4,1) not null default 0.5,
  approved_up_to_km  numeric(4,1) not null default 50.0,
  pending_gate_km    numeric(4,1),
  wave_number        int not null default 1,
  wave_expires_at    timestamptz,
  units_accepted     int not null default 0,
  units_confirmed    int not null default 0,
  units_standby      int not null default 0,
  tick_lease_until   timestamptz,
  exhausted_at       timestamptz,
  closed_at          timestamptz,
  close_reason       text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index requests_hospital_geo_idx on public.requests using gist (hospital_geo);
create index requests_status_idx on public.requests (status);
create index requests_requester_idx on public.requests (requester_id, created_at desc);

create table public.request_contacts (
  id               uuid primary key default gen_random_uuid(),
  request_id       uuid not null references public.requests(id) on delete cascade,
  donor_id         uuid not null references public.donors(id) on delete cascade,
  wave_number      int not null default 1,
  ring_km          numeric(4,1) not null,
  distance_meters  int not null,
  status           public.contact_status not null default 'queued',
  channel_used     text not null default 'whatsapp_call',
  wa_message_id    text,
  call_sid         text,
  answers          jsonb not null default '{}'::jsonb,
  eta_minutes      int,
  share_phone_consent boolean not null default false,
  contacted_at     timestamptz,
  decided_at       timestamptz,
  created_at       timestamptz not null default now(),
  unique (request_id, donor_id)
);
create index request_contacts_req_idx on public.request_contacts (request_id, status);
create index request_contacts_donor_idx on public.request_contacts (donor_id, created_at desc);

-- Request donor cards viewable by the family (NO DONOR PHONE)
create table public.request_donor_cards (
  id               uuid primary key default gen_random_uuid(),
  request_id       uuid not null references public.requests(id) on delete cascade,
  contact_id       uuid not null unique references public.request_contacts(id) on delete cascade,
  donor_id         uuid not null references public.donors(id) on delete cascade,
  first_name       text not null,
  blood_group      public.blood_group not null,
  distance_band    text not null,
  eta_minutes      int,
  status           public.contact_status not null default 'accepted',
  is_standby       boolean not null default false,
  phone_revealed   boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index donor_cards_req_idx on public.request_donor_cards (request_id);

-- ---------------------------------------------------------------------------
-- 5. Donations & Proof Codes
-- ---------------------------------------------------------------------------
create table public.donations (
  id           uuid primary key default gen_random_uuid(),
  request_id   uuid not null references public.requests(id) on delete cascade,
  contact_id   uuid not null unique references public.request_contacts(id) on delete cascade,
  donor_id     uuid not null references public.donors(id) on delete cascade,
  code         text not null check (code ~ '^[0-9]{6}$'),
  status       text not null default 'pending' check (status in ('pending', 'confirmed', 'rejected', 'expired')),
  confirmed_by text check (confirmed_by in ('requester', 'bank', 'admin')),
  bank_id      uuid references public.blood_banks(id) on delete set null,
  confirmed_at timestamptz,
  created_at   timestamptz not null default now()
);
create index donations_code_idx on public.donations (code, status);

-- ---------------------------------------------------------------------------
-- 6. System & Audit Tables
-- ---------------------------------------------------------------------------
create table public.app_settings (
  key         text primary key,
  value       jsonb not null,
  description text,
  updated_at  timestamptz not null default now()
);

create table public.rate_limits (
  bucket     text primary key,
  count      int not null default 1,
  reset_at   timestamptz not null
);

create table public.audit_logs (
  id          bigint generated always as identity primary key,
  actor_id    uuid,
  action      text not null,
  target_type text not null,
  target_id   text,
  meta        jsonb,
  ip_address  text,
  created_at  timestamptz not null default now()
);
create index audit_logs_created_idx on public.audit_logs (created_at desc);

create table public.message_events (
  id           uuid primary key default gen_random_uuid(),
  channel      text not null,
  direction    text not null check (direction in ('inbound', 'outbound')),
  phone_masked text not null,
  event_type   text not null,
  status       text,
  payload_meta jsonb,
  created_at   timestamptz not null default now()
);

create table public.webhook_events (
  id         text primary key,
  provider   text not null,
  created_at timestamptz not null default now()
);

create table public.abuse_reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid references auth.users(id) on delete set null,
  report_type  text not null check (report_type in ('fake_request', 'donor_misbehavior', 'bank_not_found', 'other')),
  target_id    text not null,
  notes        text,
  status       text not null default 'open' check (status in ('open', 'investigating', 'resolved', 'dismissed')),
  created_at   timestamptz not null default now()
);

create table public.admin_users (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  role       text not null default 'admin' check (role in ('support', 'admin', 'super_admin')),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 7. Row Level Security & Helpers
-- ---------------------------------------------------------------------------
alter table public.blood_banks enable row level security;
alter table public.bank_stock enable row level security;
alter table public.donors enable row level security;
alter table public.donor_private enable row level security;
alter table public.donor_location enable row level security;
alter table public.donor_health enable row level security;
alter table public.donor_prefs enable row level security;
alter table public.consents enable row level security;
alter table public.requests enable row level security;
alter table public.request_contacts enable row level security;
alter table public.request_donor_cards enable row level security;
alter table public.donations enable row level security;
alter table public.app_settings enable row level security;
alter table public.audit_logs enable row level security;
alter table public.abuse_reports enable row level security;
alter table public.admin_users enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

-- Blood banks are public read
create policy blood_banks_read on public.blood_banks for select using (true);
create policy bank_stock_read on public.bank_stock for select using (true);

-- Donors can read and edit own data
create policy donors_own on public.donors for all using (id = auth.uid() or public.is_admin());
create policy donor_private_own on public.donor_private for all using (donor_id = auth.uid() or public.is_admin());
create policy donor_location_own on public.donor_location for all using (donor_id = auth.uid() or public.is_admin());
create policy donor_prefs_own on public.donor_prefs for all using (donor_id = auth.uid() or public.is_admin());
create policy consents_own on public.consents for select using (user_id = auth.uid() or public.is_admin());
create policy consents_insert on public.consents for insert with check (user_id = auth.uid());

-- Requests can be read by requester, donor contacted, or admin
create policy requests_requester on public.requests for all using (requester_id = auth.uid() or public.is_admin());
create policy requests_contacted on public.requests for select using (
  exists (select 1 from public.request_contacts rc where rc.request_id = requests.id and rc.donor_id = auth.uid())
);

-- Cards readable by requester & admin
create policy donor_cards_read on public.request_donor_cards for select using (
  exists (select 1 from public.requests r where r.id = request_donor_cards.request_id and r.requester_id = auth.uid())
  or public.is_admin()
);

-- Settings public read
create policy app_settings_read on public.app_settings for select using (true);

-- Rate limiter function
create or replace function public.rl_hit(p_bucket text, p_window_seconds int, p_max int)
returns boolean language plpgsql security definer set search_path = public as $$
declare
  v_rec public.rate_limits;
  v_now timestamptz := now();
begin
  select * into v_rec from public.rate_limits where bucket = p_bucket for update;
  if not found or v_rec.reset_at <= v_now then
    insert into public.rate_limits(bucket, count, reset_at)
    values (p_bucket, 1, v_now + make_interval(secs => p_window_seconds))
    on conflict (bucket) do update set count = 1, reset_at = excluded.reset_at;
    return true;
  end if;
  if v_rec.count >= p_max then
    return false;
  end if;
  update public.rate_limits set count = count + 1 where bucket = p_bucket;
  return true;
end $$;

-- Compatibility function
create or replace function public.is_compatible(p_donor public.blood_group, p_req public.blood_group)
returns boolean language sql immutable as $$
  select case
    when p_donor = p_req then true
    when p_donor = 'O-' then true
    when p_donor = 'O+' and p_req in ('O+', 'A+', 'B+', 'AB+') then true
    when p_donor = 'A-' and p_req in ('A-', 'A+', 'AB-', 'AB+') then true
    when p_donor = 'A+' and p_req in ('A+', 'AB+') then true
    when p_donor = 'B-' and p_req in ('B-', 'B+', 'AB-', 'AB+') then true
    when p_donor = 'B+' and p_req in ('B+', 'AB+') then true
    when p_donor = 'AB-' and p_req in ('AB-', 'AB+') then true
    else false
  end;
$$;

