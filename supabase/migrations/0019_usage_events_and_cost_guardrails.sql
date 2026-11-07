-- ============================================================================
-- BloodNorms | 0019_usage_events_and_cost_guardrails.sql
-- Financial Telemetry Ledger & Immutable Consumption Tracking
--
-- Features:
-- 1. usage_events table: Granular tracking of telephony, speech AI, and WhatsApp costs in INR
-- 2. Immutability trigger: Rejects UPDATE and DELETE to prevent financial tampering
-- 3. App settings seed for cost guardrails (Feature flags default to false / OFF)
-- ============================================================================

set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Table: usage_events (Immutable consumption log)
-- ---------------------------------------------------------------------------
create table if not exists public.usage_events (
  id uuid primary key default gen_random_uuid(),
  service text not null, -- 'twilio_voice', 'gemini_live', 'meta_whatsapp'
  units numeric(12, 4) not null, -- count of messages, seconds, or minutes
  unit_type text not null, -- 'messages', 'seconds', 'minutes'
  unit_rate_inr numeric(10, 4) not null,
  estimated_cost_inr numeric(10, 4) not null,
  request_id text default null,
  call_sid text default null,
  tenant_id text default 'default',
  meta jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Indexing for temporal, service, and correlation queries
create index if not exists idx_usage_events_created_desc
  on public.usage_events (created_at desc);

create index if not exists idx_usage_events_service_created
  on public.usage_events (service, created_at desc);

create index if not exists idx_usage_events_request_id
  on public.usage_events (request_id);

-- Enable Row Level Security
alter table public.usage_events enable row level security;

-- Only authenticated administrators or service_role can query usage ledgers
create policy "usage_events_admin_read" on public.usage_events
  for select using (auth.role() = 'authenticated' or auth.role() = 'service_role');

create policy "usage_events_service_insert" on public.usage_events
  for insert with check (true);

-- ---------------------------------------------------------------------------
-- 2. Immutability Trigger: Reject any UPDATE or DELETE on usage_events
-- ---------------------------------------------------------------------------
create or replace function public.check_usage_events_immutable()
returns trigger as $$
begin
  raise exception 'Financial ledger entries in usage_events are strictly immutable and cannot be updated or deleted';
end;
$$ language plpgsql;

drop trigger if exists trg_usage_events_immutable on public.usage_events;
create trigger trg_usage_events_immutable
  before update or delete on public.usage_events
  for each row execute function public.check_usage_events_immutable();

-- ---------------------------------------------------------------------------
-- 3. Progressive Safety Configuration Seed (Guardrails Default strictly OFF)
-- ---------------------------------------------------------------------------
insert into public.app_settings (key, value)
values (
  'cost_guardrails',
  jsonb_build_object(
    'enabled', false,
    'daily_spend_cap_inr', 50000.0,
    'max_call_duration_seconds', 600,
    'kill_switch_active', false,
    'updated_at', now()
  )
)
on conflict (key) do nothing;
