-- ============================================================================
-- BloodNorms | 0020_retention_and_suppression.sql
-- Compliance Engine: Suppression Registry & Ephemeral Data Retention Purge
--
-- Complies with: India Digital Personal Data Protection Act (DPDP Act) 2023
-- 1. suppression_list: Cryptographically hashed phone numbers for DND & opt-outs
-- 2. purge_expired_ephemeral_data(): Scheduled automated cleanup for closed requests
-- 3. check_phone_suppressed(): Fast match suppression lookup
-- ============================================================================

set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Table: suppression_list (Cryptographic DND & Opt-Out Registry)
-- Stores SHA-256 hashes of phone numbers rather than plaintext numbers
-- ---------------------------------------------------------------------------
create table if not exists public.suppression_list (
  id uuid primary key default gen_random_uuid(),
  phone_hash text not null unique,
  channel text not null default 'all', -- 'whatsapp', 'sms', 'voice', 'all'
  reason text not null default 'user_opt_out', -- 'user_opt_out', 'dnd', 'compliance'
  meta jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_suppression_phone_hash
  on public.suppression_list (phone_hash);

alter table public.suppression_list enable row level security;

-- Authenticated systems and webhook receivers can query and insert
create policy "suppression_service_read" on public.suppression_list
  for select using (auth.role() = 'authenticated' or auth.role() = 'service_role');

create policy "suppression_service_insert" on public.suppression_list
  for insert with check (true);

-- ---------------------------------------------------------------------------
-- 2. Stored Function: check_phone_suppressed
-- Returns true if a phone hash is registered in the suppression registry
-- ---------------------------------------------------------------------------
create or replace function public.check_phone_suppressed(
  p_phone_hash text,
  p_channel text default 'all'
)
returns boolean as $$
declare
  v_exists boolean;
begin
  select exists(
    select 1 from public.suppression_list
    where phone_hash = p_phone_hash
      and (channel = 'all' or channel = p_channel)
  ) into v_exists;

  return v_exists;
end;
$$ language plpgsql security definer;

-- ---------------------------------------------------------------------------
-- 3. Stored Procedure: purge_expired_ephemeral_data
-- Purges fulfilled and expired patient requests older than 90 days per DPDP
-- Preserves immutable audit_logs and usage_events for regulatory retention
-- ---------------------------------------------------------------------------
create or replace function public.purge_expired_ephemeral_data()
returns table(purged_requests integer, purged_notifications integer) as $$
declare
  v_req_count integer := 0;
  v_notif_count integer := 0;
begin
  -- 1. Purge closed emergency requests older than 90 days
  delete from public.requests
  where status in ('fulfilled', 'expired', 'cancelled')
    and (closed_at < now() - interval '90 days' or created_at < now() - interval '90 days');
  get diagnostics v_req_count = row_count;

  -- 2. Purge delivered in-app notifications older than 60 days
  delete from public.notifications
  where created_at < now() - interval '60 days';
  get diagnostics v_notif_count = row_count;

  -- 3. Log purge event into immutable audit trail
  insert into public.audit_logs (actor_id, action, target_type, target_id, payload)
  values (
    '00000000-0000-0000-0000-000000000000',
    'cron_purge_expired_data',
    'system',
    'ephemeral_cleanup',
    jsonb_build_object(
      'purged_requests', v_req_count,
      'purged_notifications', v_notif_count,
      'executed_at', now()
    )
  );

  return query select v_req_count, v_notif_count;
end;
$$ language plpgsql security definer;
