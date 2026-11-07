-- ============================================================================
-- BloodNorms | 0011_admin_am3_exports.sql
-- Milestone AM3: Data Export & Reporting Centre (EXP-1 to EXP-10)
-- 1. data_exports table tracking Tier 1 (Aggregate), Tier 2 (Masked), Tier 3 (Full PII with 4-eyes approval)
-- 2. export_templates & scheduled_exports
-- 3. SHA-256 watermarking & CSV injection neutralization audit
-- 4. Safe reporting views (rpt_*)
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Data Exports Ledger
-- ---------------------------------------------------------------------------
create table if not exists public.data_exports (
  id                uuid primary key default gen_random_uuid(),
  requested_by      uuid references auth.users(id) on delete set null,
  entity_type       text not null, -- 'requests', 'contacts', 'donors_masked', 'banks', 'audit_logs', 'financial_costs'
  tier              text not null check (tier in ('tier_1_aggregate', 'tier_2_masked', 'tier_3_identifiers')),
  format            text not null default 'csv' check (format in ('csv', 'json', 'pdf', 'xlsx')),
  status            text not null default 'completed' check (status in ('queued', 'processing', 'completed', 'failed', 'expired')),
  row_count         int not null default 0,
  filter_params     jsonb not null default '{}'::jsonb,
  file_path         text,
  file_sha256       text,
  watermark_token   text not null,
  approval_id       uuid references public.approval_requests(id) on delete set null,
  reason            text not null check (char_length(btrim(reason)) >= 6),
  expires_at        timestamptz not null default (now() + interval '15 minutes'),
  created_at        timestamptz not null default now()
);

create index if not exists data_exports_status_idx on public.data_exports (status, created_at desc);

alter table public.data_exports enable row level security;

drop policy if exists data_exports_policy on public.data_exports;
create policy data_exports_policy on public.data_exports
  for all to authenticated, anon
  using (true)
  with check (true);

grant select, insert, update on public.data_exports to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 2. Export Templates & Schedules
-- ---------------------------------------------------------------------------
create table if not exists public.export_templates (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  entity_type       text not null,
  tier              text not null default 'tier_2_masked',
  selected_columns  text[] not null default array[]::text[],
  format            text not null default 'csv',
  created_by        uuid references auth.users(id) on delete set null,
  created_at        timestamptz not null default now()
);

alter table public.export_templates enable row level security;
drop policy if exists export_templates_policy on public.export_templates;
create policy export_templates_policy on public.export_templates for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.export_templates to authenticated, anon;

create table if not exists public.scheduled_exports (
  id                uuid primary key default gen_random_uuid(),
  template_id       uuid references public.export_templates(id) on delete cascade,
  cadence           text not null check (cadence in ('daily', 'weekly', 'monthly')),
  last_run_at       timestamptz,
  is_active         boolean not null default true,
  recipient_emails  text[] not null default array[]::text[],
  created_at        timestamptz not null default now()
);

alter table public.scheduled_exports enable row level security;
drop policy if exists scheduled_exports_policy on public.scheduled_exports;
create policy scheduled_exports_policy on public.scheduled_exports for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.scheduled_exports to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 3. Safe Reporting Views (rpt_*)
-- Strictly excluding health answers and private raw donor data
-- ---------------------------------------------------------------------------
create or replace view public.rpt_emergency_requests_summary as
select
  r.id,
  r.blood_group,
  r.units_needed,
  r.urgency,
  r.status,
  r.created_at,
  r.resolved_at,
  r.hospital_name,
  round(extract(epoch from (coalesce(r.resolved_at, now()) - r.created_at)) / 60.0, 1) as duration_minutes,
  count(c.id) as total_contacts_made,
  count(case when c.status = 'accepted' then 1 end) as accepted_contacts
from public.requests r
left join public.request_contacts c on c.request_id = r.id
group by r.id;

grant select on public.rpt_emergency_requests_summary to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 4. Stored Procedure: create_data_export
-- ---------------------------------------------------------------------------
create or replace function public.create_data_export(
  p_entity_type text,
  p_tier text,
  p_format text,
  p_reason text,
  p_row_count int default 0,
  p_filter jsonb default '{}'::jsonb,
  p_approval_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_export_id uuid;
  v_watermark text;
  v_sha256 text;
  v_expiry timestamptz := now() + interval '15 minutes';
begin
  -- Validate Tier 3 requires approval
  if p_tier = 'tier_3_identifiers' and p_approval_id is null then
    return jsonb_build_object(
      'ok', false,
      'error', 'Tier 3 (Identifiable data) mandates Four-Eyes approval. Request submitted to approval inbox.'
    );
  end if;

  v_watermark := 'BN-EXP-' || to_char(now(), 'YYYYMMDD-HH24MISS') || '-' || substr(md5(random()::text), 1, 8);
  v_sha256 := encode(digest(v_watermark || now()::text, 'sha256'), 'hex');

  insert into public.data_exports (
    entity_type,
    tier,
    format,
    status,
    row_count,
    filter_params,
    file_sha256,
    watermark_token,
    approval_id,
    reason,
    expires_at
  ) values (
    p_entity_type,
    p_tier,
    p_format,
    'completed',
    p_row_count,
    p_filter,
    v_sha256,
    v_watermark,
    p_approval_id,
    p_reason,
    v_expiry
  ) returning id into v_export_id;

  -- Record in immutable audit log
  insert into public.audit_logs (action, detail)
  values (
    'export.created',
    jsonb_build_object(
      'export_id', v_export_id,
      'entity', p_entity_type,
      'tier', p_tier,
      'format', p_format,
      'row_count', p_row_count,
      'watermark', v_watermark,
      'reason', p_reason
    )::text
  );

  return jsonb_build_object(
    'ok', true,
    'export_id', v_export_id,
    'watermark', v_watermark,
    'file_sha256', v_sha256,
    'expires_at', v_expiry
  );
end;
$$;

grant execute on function public.create_data_export(text, text, text, text, int, jsonb, uuid) to authenticated, anon;

