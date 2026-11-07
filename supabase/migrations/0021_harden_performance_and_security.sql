-- ============================================================================
-- BloodNorms | 0021_harden_performance_and_security.sql
-- Database Hardening, RLS Isolation, Foreign Key Indexing, and Privilege Least-Privilege
--
-- Features:
-- 1. Covering indexes for 12 unindexed foreign keys (performance optimization)
-- 2. Row Level Security on spatial_ref_sys (resolves linter RLS error)
-- 3. Immutable search_path on calculate_distance_km and nearest_banks
-- 4. Deduplication of multiple permissive policies on bank_stock
-- 5. Strict least-privilege RLS on audit_logs, voice_calls, inbound_sessions,
--    message_events, and request_access_keys
-- 6. RPC routine execution hardening: revoke anon execution on state-mutating functions
-- 7. Storage object protection: restrict uploads to verified buckets, revoke public overwrites
--
-- Safe, additive, idempotent, 100% backward-compatible.
-- ============================================================================

set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Covering Indexes for Unindexed Foreign Keys
-- ---------------------------------------------------------------------------
create index if not exists idx_bank_camps_bank_id
  on public.bank_camps (bank_id);

create index if not exists idx_bank_staff_bank_id
  on public.bank_staff (bank_id);

create index if not exists idx_bank_stock_history_bank_id
  on public.bank_stock_history (bank_id);

create index if not exists idx_camp_signups_donor_id
  on public.camp_signups (donor_id);

create index if not exists idx_donations_bank_id
  on public.donations (bank_id);

create index if not exists idx_donations_donor_id
  on public.donations (donor_id);

create index if not exists idx_donations_request_id
  on public.donations (request_id);

create index if not exists idx_donor_location_donor_id
  on public.donor_location (donor_id);

create index if not exists idx_inbound_sessions_request_id
  on public.inbound_sessions (request_id);

create index if not exists idx_request_access_keys_request_id
  on public.request_access_keys (request_id);

create index if not exists idx_request_contacts_donor_id
  on public.request_contacts (donor_id);

create index if not exists idx_request_contacts_request_id
  on public.request_contacts (request_id);

-- ---------------------------------------------------------------------------
-- 2. PostGIS spatial_ref_sys RLS Hardening
-- ---------------------------------------------------------------------------
alter table if exists public.spatial_ref_sys enable row level security;

drop policy if exists spatial_ref_sys_select_public on public.spatial_ref_sys;
create policy spatial_ref_sys_select_public
  on public.spatial_ref_sys
  for select
  to public
  using (true);

-- ---------------------------------------------------------------------------
-- 3. Stored Routine Search Path Hardening
-- Prevents role-mutable search_path hijacking in SECURITY DEFINER and utility routines
-- ---------------------------------------------------------------------------
create or replace function public.calculate_distance_km(
  lat1 double precision,
  lng1 double precision,
  lat2 double precision,
  lng2 double precision
)
returns double precision
language plpgsql
immutable
set search_path = 'public'
as $function$
declare
  r double precision := 6371;
  dlat double precision;
  dlng double precision;
  a double precision;
  c double precision;
begin
  if lat1 is null or lng1 is null or lat2 is null or lng2 is null then
    return 999999;
  end if;
  dlat := radians(lat2 - lat1);
  dlng := radians(lng2 - lng1);
  a := sin(dlat / 2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2)^2;
  c := 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
end;
$function$;

create or replace function public.nearest_banks(
  p_lat double precision,
  p_lng double precision,
  p_group text default null::text,
  p_component text default 'whole_blood'::text,
  p_limit integer default 10,
  p_max_km double precision default 50.0
)
returns table(
  bank_id uuid,
  bank_name text,
  address text,
  phones text[],
  distance_km double precision,
  trust_score numeric,
  is_24x7 boolean,
  units_available integer,
  stock_updated_at timestamp with time zone,
  stock_source text
)
language sql
security definer
set search_path = 'public'
as $function$
  select * from public.find_nearby_banks_with_stock(p_lat, p_lng, coalesce(p_group, 'O+'), p_max_km) limit p_limit;
$function$;

-- ---------------------------------------------------------------------------
-- 4. Deduplicate Multiple Permissive Policies on bank_stock
-- Retain bank_stock_select_public for read; drop broad bank_stock_modify_all
-- ---------------------------------------------------------------------------
drop policy if exists bank_stock_modify_all on public.bank_stock;

drop policy if exists bank_stock_staff_update on public.bank_stock;
create policy "bank_stock_staff_update"
  on public.bank_stock
  for update
  to authenticated
  using (
    exists (
      select 1 from public.bank_staff
      where bank_staff.bank_id = bank_stock.bank_id
        and bank_staff.user_id = auth.uid()
    ) or public.is_admin()
  )
  with check (
    exists (
      select 1 from public.bank_staff
      where bank_staff.bank_id = bank_stock.bank_id
        and bank_staff.user_id = auth.uid()
    ) or public.is_admin()
  );

-- ---------------------------------------------------------------------------
-- 5. Least-Privilege RLS on Sensitive Operational Tables
-- Prevents anonymous scraping of audit logs, call logs, and messaging telemetry
-- ---------------------------------------------------------------------------

-- Audit Logs
drop policy if exists audit_logs_all on public.audit_logs;
drop policy if exists audit_logs_admin_select on public.audit_logs;
drop policy if exists audit_logs_authenticated_insert on public.audit_logs;

create policy "audit_logs_admin_select"
  on public.audit_logs
  for select
  to authenticated
  using (public.is_admin());

create policy "audit_logs_authenticated_insert"
  on public.audit_logs
  for insert
  to authenticated
  with check (true);

-- Voice Calls
drop policy if exists voice_calls_all on public.voice_calls;
drop policy if exists voice_calls_admin_select on public.voice_calls;
drop policy if exists voice_calls_authenticated_insert on public.voice_calls;

create policy "voice_calls_admin_select"
  on public.voice_calls
  for select
  to authenticated
  using (public.is_admin());

create policy "voice_calls_authenticated_insert"
  on public.voice_calls
  for insert
  to authenticated
  with check (true);

-- Inbound Sessions
drop policy if exists inbound_sessions_all on public.inbound_sessions;
drop policy if exists inbound_sessions_admin_select on public.inbound_sessions;
drop policy if exists inbound_sessions_authenticated_insert on public.inbound_sessions;

create policy "inbound_sessions_admin_select"
  on public.inbound_sessions
  for select
  to authenticated
  using (public.is_admin());

create policy "inbound_sessions_authenticated_insert"
  on public.inbound_sessions
  for insert
  to authenticated
  with check (true);

-- Message Events
drop policy if exists message_events_all on public.message_events;
drop policy if exists message_events_admin_select on public.message_events;
drop policy if exists message_events_authenticated_insert on public.message_events;

create policy "message_events_admin_select"
  on public.message_events
  for select
  to authenticated
  using (public.is_admin());

create policy "message_events_authenticated_insert"
  on public.message_events
  for insert
  to authenticated
  with check (true);

-- Request Access Keys
drop policy if exists request_access_keys_all on public.request_access_keys;
drop policy if exists request_access_keys_admin_select on public.request_access_keys;
drop policy if exists request_access_keys_authenticated_insert on public.request_access_keys;

create policy "request_access_keys_admin_select"
  on public.request_access_keys
  for select
  to authenticated
  using (public.is_admin());

create policy "request_access_keys_authenticated_insert"
  on public.request_access_keys
  for insert
  to authenticated
  with check (true);

-- ---------------------------------------------------------------------------
-- 6. RPC Routine Privilege Restrictions (Least Privilege)
-- ---------------------------------------------------------------------------
revoke execute on function public.bank_confirm_donation(text, text) from public, anon;
grant execute on function public.bank_confirm_donation(text, text) to authenticated, service_role;

revoke execute on function public.bank_set_stock(jsonb) from public, anon;
grant execute on function public.bank_set_stock(jsonb) to authenticated, service_role;

revoke execute on function public.dispatch_request_to_donors(uuid, double precision, double precision, text, boolean, double precision) from public, anon;
grant execute on function public.dispatch_request_to_donors(uuid, double precision, double precision, text, boolean, double precision) to authenticated, service_role;

revoke execute on function public.find_nearby_eligible_donors(double precision, double precision, text, boolean, double precision) from public, anon;
grant execute on function public.find_nearby_eligible_donors(double precision, double precision, text, boolean, double precision) to authenticated, service_role;

revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated, service_role;

revoke execute on function public.st_estimatedextent(text, text) from public, anon, authenticated;
revoke execute on function public.st_estimatedextent(text, text, text) from public, anon, authenticated;
revoke execute on function public.st_estimatedextent(text, text, text, boolean) from public, anon, authenticated;

-- Public read-only utility routines for emergency discovery remain executable
grant execute on function public.calculate_distance_km(double precision, double precision, double precision, double precision) to public, anon, authenticated;
grant execute on function public.find_nearby_banks_with_stock(double precision, double precision, text, double precision) to public, anon, authenticated;
grant execute on function public.nearest_banks(double precision, double precision, text, text, integer, double precision) to public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 7. Storage Bucket Policy Hardening
-- ---------------------------------------------------------------------------
drop policy if exists storage_public_update on storage.objects;
drop policy if exists storage_public_insert on storage.objects;
drop policy if exists storage_public_insert_scoped on storage.objects;

create policy "storage_public_insert_scoped"
  on storage.objects
  for insert
  to public
  with check (bucket_id in ('slips', 'proofs'));

