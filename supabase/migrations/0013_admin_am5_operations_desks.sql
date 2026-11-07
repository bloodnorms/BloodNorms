-- ============================================================================
-- BloodNorms | 0013_admin_am5_operations_desks.sql
-- Milestone AM5: Operations Desks (CMD-1..8, LIV-1..9, NHD-1..5, REQ-1..5, DNT-1..4)
-- 1. requester_profiles with abuse scoring and blocklist registry
-- 2. prescription_reviews with 7-day auto-delete schedule
-- 3. needs_human_cases with claim, triage, volunteer script outcomes
-- 4. on_call_shifts with shift notes & handover
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Requester Profiles & Abuse Prevention
-- ---------------------------------------------------------------------------
create table if not exists public.requester_profiles (
  id                  uuid primary key default gen_random_uuid(),
  phone               text not null unique,
  full_name           text,
  total_requests      int not null default 1,
  cancelled_requests  int not null default 0,
  abuse_score         int not null default 0,
  is_blocked          boolean not null default false,
  blocked_reason      text,
  blocked_at          timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists requester_profiles_phone_idx on public.requester_profiles (phone);

alter table public.requester_profiles enable row level security;
drop policy if exists requester_profiles_policy on public.requester_profiles;
create policy requester_profiles_policy on public.requester_profiles for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.requester_profiles to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 2. Prescription Reviews Desk (7-day privacy retention)
-- ---------------------------------------------------------------------------
create table if not exists public.prescription_reviews (
  id                uuid primary key default gen_random_uuid(),
  request_id        text references public.requests(id) on delete cascade,
  prescription_url  text not null,
  status            text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  reviewed_by       uuid references auth.users(id) on delete set null,
  notes             text,
  reviewed_at       timestamptz,
  auto_delete_at    timestamptz not null default (now() + interval '7 days'),
  created_at        timestamptz not null default now()
);

create index if not exists prescription_reviews_status_idx on public.prescription_reviews (status, created_at desc);

alter table public.prescription_reviews enable row level security;
drop policy if exists prescription_reviews_policy on public.prescription_reviews;
create policy prescription_reviews_policy on public.prescription_reviews for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.prescription_reviews to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 3. Needs-Human Extended Cases Queue
-- ---------------------------------------------------------------------------
create table if not exists public.needs_human_cases (
  id            uuid primary key default gen_random_uuid(),
  case_type     text not null check (case_type in ('exhausted_rings', 'no_whatsapp', 'wrong_number', 'failed_code', 'complaint', 'other')),
  request_id    text references public.requests(id) on delete set null,
  phone         text,
  claimed_by    uuid references auth.users(id) on delete set null,
  status        text not null default 'open' check (status in ('open', 'claimed', 'snoozed', 'resolved')),
  snoozed_until timestamptz,
  notes         text,
  outcome       text,
  created_at    timestamptz not null default now(),
  resolved_at   timestamptz
);

create index if not exists needs_human_cases_status_idx on public.needs_human_cases (status, created_at desc);

alter table public.needs_human_cases enable row level security;
drop policy if exists needs_human_cases_policy on public.needs_human_cases;
create policy needs_human_cases_policy on public.needs_human_cases for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.needs_human_cases to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 4. On-Call Responder Shifts
-- ---------------------------------------------------------------------------
create table if not exists public.on_call_shifts (
  id                uuid primary key default gen_random_uuid(),
  responder_name    text not null,
  responder_phone   text not null,
  shift_start       timestamptz not null,
  shift_end         timestamptz not null,
  handover_notes    text,
  is_active         boolean not null default true,
  created_at        timestamptz not null default now()
);

alter table public.on_call_shifts enable row level security;
drop policy if exists on_call_shifts_policy on public.on_call_shifts;
create policy on_call_shifts_policy on public.on_call_shifts for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.on_call_shifts to authenticated, anon;

-- Pre-seed default on-call shift
insert into public.on_call_shifts (responder_name, responder_phone, shift_start, shift_end, handover_notes)
values (
  'Arkio On-Call Lead',
  '+919876543210',
  now(),
  now() + interval '24 hours',
  'Primary helpline monitored on Twilio IVR and WhatsApp.'
) on conflict do nothing;

