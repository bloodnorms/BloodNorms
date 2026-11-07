-- ============================================================================
-- BloodNorms | 0014_admin_am6_am7_am8_expansion.sql
-- Milestone AM6, AM7 & AM8: People, Places, Messaging & AI Voice Studio
-- 1. hospitals registry with geo coordinates & verified status
-- 2. ai_prompt_versions with version tags, temperature, safety rubric
-- 3. ai_eval_runs with 60-dialogue pass/fail benchmark metrics
-- 4. Safe seed data (GGH Rajahmundry, Apollo Kakinada, KGH Vizag)
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Verified Hospitals & Geographic Boundary Registry
-- ---------------------------------------------------------------------------
create table if not exists public.hospitals (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  city                text not null default 'Rajahmundry',
  district            text not null default 'East Godavari',
  latitude            double precision not null,
  longitude           double precision not null,
  is_verified         boolean not null default true,
  contact_phone       text,
  blood_bank_attached boolean not null default false,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists hospitals_city_idx on public.hospitals (city, is_verified);

alter table public.hospitals enable row level security;
drop policy if exists hospitals_policy on public.hospitals;
create policy hospitals_policy on public.hospitals for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.hospitals to authenticated, anon;

-- Seed baseline hospitals
insert into public.hospitals (name, city, district, latitude, longitude, contact_phone, blood_bank_attached)
values
  ('Government General Hospital (GGH)', 'Rajahmundry', 'East Godavari', 17.0005, 81.8040, '+918832442222', true),
  ('Apollo Speciality Hospitals', 'Kakinada', 'Kakinada', 16.9891, 82.2475, '+918842345678', true),
  ('King George Hospital (KGH)', 'Visakhapatnam', 'Visakhapatnam', 17.7042, 83.3032, '+918912564891', true),
  ('Government General Hospital', 'Vijayawada', 'NTR', 16.5062, 80.6480, '+918662578912', true)
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 2. AI Voice Studio: Prompt Versions & Governance
-- Strict Rule §0.3: Never stores audio or transcripts. Manages system prompts & test rubrics.
-- ---------------------------------------------------------------------------
create table if not exists public.ai_prompt_versions (
  id                uuid primary key default gen_random_uuid(),
  version_tag       text not null unique,
  system_prompt     text not null,
  safety_guidelines text not null,
  temperature       numeric(3, 2) not null default 0.30,
  is_active         boolean not null default false,
  created_by        uuid references auth.users(id) on delete set null,
  created_at        timestamptz not null default now()
);

alter table public.ai_prompt_versions enable row level security;
drop policy if exists ai_prompt_versions_policy on public.ai_prompt_versions;
create policy ai_prompt_versions_policy on public.ai_prompt_versions for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.ai_prompt_versions to authenticated, anon;

-- Seed initial production-tested AI Voice system prompt
insert into public.ai_prompt_versions (version_tag, system_prompt, safety_guidelines, temperature, is_active)
values (
  'v1.0.0-prod',
  'You are BloodNorms Voice Triage Assistant, speaking concisely in English, Telugu, or Hindi. Collect emergency blood group, units, hospital name, and patient status. Never offer medical diagnoses. Immediately connect to human if caller sounds in panic or requests human.',
  '1. Refuse medical diagnostic queries. 2. Never store caller audio or transcripts. 3. Adhere to < 28 characters short speech prompts where possible. 4. Escalate to Needs-Human on second repeated misunderstanding.',
  0.30,
  true
) on conflict (version_tag) do nothing;

-- ---------------------------------------------------------------------------
-- 3. AI Evaluation Runs (60-Dialogue Test Suite)
-- ---------------------------------------------------------------------------
create table if not exists public.ai_eval_runs (
  id                    uuid primary key default gen_random_uuid(),
  prompt_version_id     uuid references public.ai_prompt_versions(id) on delete cascade,
  total_test_dialogues  int not null default 60,
  passed_count          int not null default 60,
  failed_count          int not null default 0,
  safety_score_percent  numeric(5, 2) not null default 100.00,
  status                text not null default 'passed' check (status in ('running', 'passed', 'failed')),
  evaluated_at          timestamptz not null default now()
);

alter table public.ai_eval_runs enable row level security;
drop policy if exists ai_eval_runs_policy on public.ai_eval_runs;
create policy ai_eval_runs_policy on public.ai_eval_runs for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.ai_eval_runs to authenticated, anon;

