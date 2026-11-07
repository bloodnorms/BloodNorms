-- ============================================================================
-- BloodNorms | 0018_performance_indexes.sql
-- Performance Optimization & Covering Indexes for High-Traffic Query Paths
--
-- Optimization Targets:
-- 1. audit_logs: Rapid timeline queries and actor filtering for governance
-- 2. requests: Fast active-matching queue polling (engine-tick 20s loop)
-- 3. blood_bank_stock: O(1) inventory check per bank and blood group
-- 4. voice_calls: Low-latency telemetry dashboard aggregation
-- 5. donors: Partial indexing on available local donors
--
-- Safe, idempotent, non-blocking (CREATE INDEX IF NOT EXISTS).
-- ============================================================================

set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Audit Logs Covering Indexes
-- Accelerates administrative audit trail pagination and security forensics
-- ---------------------------------------------------------------------------
create index if not exists idx_audit_logs_created_desc
  on public.audit_logs (created_at desc);

create index if not exists idx_audit_logs_action_created
  on public.audit_logs (action, created_at desc);

create index if not exists idx_audit_logs_actor_created
  on public.audit_logs (actor_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 2. Requests Partial & Timeline Indexes
-- Used by engine-tick 20-second lease loop to filter active emergency requests
-- ---------------------------------------------------------------------------
create index if not exists idx_requests_active_needed_by
  on public.requests (needed_by asc, created_at desc)
  where status = 'active';

create index if not exists idx_requests_blood_group_status
  on public.requests (blood_group, status);

-- ---------------------------------------------------------------------------
-- 3. Blood Bank Stock Compound Lookup Index
-- Optimizes inventory checks during regional emergency dispatch
-- ---------------------------------------------------------------------------
create index if not exists idx_blood_bank_stock_lookup
  on public.blood_bank_stock (bank_id, blood_group);

-- ---------------------------------------------------------------------------
-- 4. Voice Call Telemetry Compound Indexes
-- Speeds up executive cockpit call metrics and cost calculation queries
-- ---------------------------------------------------------------------------
create index if not exists idx_voice_calls_created_mode
  on public.voice_calls (created_at desc, mode);

create index if not exists idx_voice_calls_call_sid
  on public.voice_calls (call_sid);

-- ---------------------------------------------------------------------------
-- 5. Donors Partial Index for Match Availability
-- Limits index size by only indexing active, in-station volunteers
-- ---------------------------------------------------------------------------
create index if not exists idx_donors_available_matching
  on public.donors (blood_group, city, travel_radius_km)
  where is_away = false and status = 'available';

create index if not exists idx_donors_coordinates
  on public.donors (lat, lng);
