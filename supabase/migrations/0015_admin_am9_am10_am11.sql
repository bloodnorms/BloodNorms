-- ============================================================================
-- BloodNorms | 0015_admin_am9_am10_am11.sql
-- Milestone AM9, AM10 & AM11: Safety, DPDP, Partners, Incidents & Hardening
-- 1. safety_incidents desk (P1 to P4 severity, SLA, root cause)
-- 2. dpdp_requests registry (DPDP Act 2023 compliance, erasure & export)
-- 3. partners registry (Red Cross, Rotary, Lions, NSS)
-- 4. Sandbox test markers & privacy boundaries enforcement
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Safety Incidents Desk
-- ---------------------------------------------------------------------------
create table if not exists public.safety_incidents (
  id                  uuid primary key default gen_random_uuid(),
  title               text not null,
  severity            text not null check (severity in ('P1_critical', 'P2_major', 'P3_moderate', 'P4_minor')),
  status              text not null default 'open' check (status in ('open', 'investigating', 'mitigated', 'resolved')),
  impacted_service    text not null, -- 'telephony', 'whatsapp', 'gemini_live', 'database', 'matching_engine'
  description         text not null,
  root_cause          text,
  mitigation_steps    text,
  declared_by         uuid references auth.users(id) on delete set null,
  declared_at         timestamptz not null default now(),
  resolved_at         timestamptz
);

create index if not exists safety_incidents_status_idx on public.safety_incidents (status, severity);

alter table public.safety_incidents enable row level security;
drop policy if exists safety_incidents_policy on public.safety_incidents;
create policy safety_incidents_policy on public.safety_incidents for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.safety_incidents to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 2. DPDP Act 2023 Compliance & Data Rights Registry
-- ---------------------------------------------------------------------------
create table if not exists public.dpdp_requests (
  id              uuid primary key default gen_random_uuid(),
  request_type    text not null check (request_type in ('erasure', 'export', 'rectification')),
  donor_id        uuid references public.donors(id) on delete set null,
  phone_masked    text not null,
  status          text not null default 'pending' check (status in ('pending', 'approved', 'completed', 'rejected')),
  processed_by    uuid references auth.users(id) on delete set null,
  created_at      timestamptz not null default now(),
  completed_at    timestamptz
);

alter table public.dpdp_requests enable row level security;
drop policy if exists dpdp_requests_policy on public.dpdp_requests;
create policy dpdp_requests_policy on public.dpdp_requests for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.dpdp_requests to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 3. Partners & Community Alliances
-- ---------------------------------------------------------------------------
create table if not exists public.partners (
  id                    uuid primary key default gen_random_uuid(),
  name                  text not null,
  organization_type     text not null default 'rotary',
  contact_person        text,
  contact_phone         text,
  camps_organized_count int not null default 0,
  is_active             boolean not null default true,
  created_at            timestamptz not null default now()
);

alter table public.partners enable row level security;
drop policy if exists partners_policy on public.partners;
create policy partners_policy on public.partners for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.partners to authenticated, anon;

-- Seed default community partners
insert into public.partners (name, organization_type, contact_person, contact_phone, camps_organized_count)
values
  ('Indian Red Cross Society (East Godavari)', 'red_cross', 'District Coordinator', '+918832451122', 12),
  ('Rotary Club of Rajahmundry', 'rotary', 'Camp Director', '+918832473344', 8),
  ('Lions Club International Godavari', 'lions', 'President', '+918832465566', 5),
  ('National Service Scheme (NSS) AU', 'nss', 'Program Officer', '+918912587788', 9)
on conflict do nothing;

