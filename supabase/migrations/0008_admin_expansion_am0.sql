-- ============================================================================
-- BloodNorms | 0008_admin_expansion_am0.sql
-- Milestone AM0 & AM1 Database Scaffolding:
-- 1. Built-in Roles (10 roles) & Module.Action Permissions Matrix
-- 2. User-Role Assignments with Expiration & Break-Glass Protocol
-- 3. Progressive Feature Flags Infrastructure (Default OFF in production)
-- 4. Audit Log Immutability Hardening (Revoke UPDATE & DELETE via trigger)
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Roles & Permissions Architecture
-- ---------------------------------------------------------------------------
create table if not exists public.admin_roles (
  id          text primary key,
  label       text not null,
  description text,
  is_builtin  boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Seed the 10 built-in roles
insert into public.admin_roles (id, label, description, is_builtin) values
  ('super_admin', 'Super Admin', 'Full system access, promote admins, release kill switch, approve caps', true),
  ('admin', 'Admin', 'Day-to-day operations, settings, content, campaigns, exports within permissions', true),
  ('support', 'Support', 'Read-limited: look up, resend messages, opt-out/in, handle cases', true),
  ('oncall', 'On-Call Responder', 'Live requests, Needs-human queue, kill switch and maintenance (enable only)', true),
  ('bank_manager', 'Bank Manager', 'Banks, stock, partners, bank staff invites', true),
  ('content_editor', 'Content Editor', 'Copy deck, help pages, translations (cannot publish alone)', true),
  ('clinical_reviewer', 'Clinical Reviewer', 'Approve health questions and eligibility constants', true),
  ('legal_officer', 'Legal Officer', 'Consent texts, policies, data-rights queue, incident records', true),
  ('analyst', 'Analyst', 'Aggregate dashboards and Tier 1 exports only', true),
  ('finance', 'Finance', 'Cost, caps (view), invoices, renewals, rate card', true)
on conflict (id) do update set
  label = excluded.label,
  description = excluded.description;

create table if not exists public.admin_permissions (
  code        text primary key,
  module      text not null,
  action      text not null,
  description text,
  created_at  timestamptz not null default now()
);

-- Core action permissions
insert into public.admin_permissions (code, module, action, description) values
  ('requests.view', 'requests', 'view', 'View active and past blood requests'),
  ('requests.edit', 'requests', 'edit', 'Modify in-flight request attributes'),
  ('requests.close', 'requests', 'close', 'Close requests with outcome reason'),
  ('donors.view', 'donors', 'view', 'View donor directory (masked)'),
  ('donors.edit', 'donors', 'edit', 'Edit donor profile and availability'),
  ('donors.reveal_pii', 'donors', 'reveal_pii', 'Reveal unmasked donor phone numbers (audited)'),
  ('donors.delete', 'donors', 'delete', 'Anonymize or delete donor records'),
  ('banks.view', 'banks', 'view', 'View blood banks and stock levels'),
  ('banks.edit', 'banks', 'edit', 'Update blood bank stock and staff'),
  ('camps.view', 'camps', 'view', 'View blood donation camps'),
  ('camps.edit', 'camps', 'edit', 'Create, edit, and check-in camp drives'),
  ('broadcasts.create', 'broadcasts', 'create', 'Compose and submit regional broadcasts'),
  ('broadcasts.approve', 'broadcasts', 'approve', 'Approve broadcasts >200 recipients'),
  ('maintenance.edit', 'maintenance', 'edit', 'Enable, schedule, or disable maintenance mode'),
  ('kill_switch.engage', 'kill_switch', 'engage', 'Halt outbound messaging and requests'),
  ('kill_switch.release', 'kill_switch', 'release', 'Release global or scoped kill switch'),
  ('ai_voice.edit', 'ai_voice', 'edit', 'Configure AI prompts and voice models'),
  ('ai_voice.publish', 'ai_voice', 'publish', 'Publish verified AI prompt versions'),
  ('exports.export_aggregate', 'exports', 'export_aggregate', 'Export Tier 1 anonymous statistics'),
  ('exports.export_masked', 'exports', 'export_masked', 'Export Tier 2 masked operational data'),
  ('exports.export_full', 'exports', 'export_full', 'Export Tier 3 full identifiers (step-up required)'),
  ('audit.view', 'audit', 'view', 'View system audit trails and data access logs')
on conflict (code) do nothing;

create table if not exists public.admin_role_permissions (
  role_id         text not null references public.admin_roles(id) on delete cascade,
  permission_code text not null references public.admin_permissions(code) on delete cascade,
  primary key (role_id, permission_code)
);

-- Map permissions to built-in roles
insert into public.admin_role_permissions (role_id, permission_code)
select 'super_admin', code from public.admin_permissions
on conflict do nothing;

insert into public.admin_role_permissions (role_id, permission_code) values
  ('admin', 'requests.view'), ('admin', 'requests.edit'), ('admin', 'requests.close'),
  ('admin', 'donors.view'), ('admin', 'donors.edit'),
  ('admin', 'banks.view'), ('admin', 'banks.edit'),
  ('admin', 'camps.view'), ('admin', 'camps.edit'),
  ('admin', 'broadcasts.create'), ('admin', 'broadcasts.approve'),
  ('admin', 'maintenance.edit'), ('admin', 'kill_switch.engage'),
  ('admin', 'ai_voice.edit'),
  ('admin', 'exports.export_aggregate'), ('admin', 'exports.export_masked'),
  ('admin', 'audit.view'),
  ('support', 'requests.view'), ('support', 'donors.view'), ('support', 'banks.view'), ('support', 'camps.view'),
  ('oncall', 'requests.view'), ('oncall', 'requests.edit'), ('oncall', 'kill_switch.engage'), ('oncall', 'maintenance.edit'),
  ('bank_manager', 'banks.view'), ('banks_manager', 'banks.edit'), ('bank_manager', 'camps.view'), ('bank_manager', 'camps.edit'),
  ('analyst', 'requests.view'), ('analyst', 'donors.view'), ('analyst', 'banks.view'), ('analyst', 'exports.export_aggregate'),
  ('finance', 'exports.export_aggregate')
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 2. User Roles & Break-Glass Elevation
-- ---------------------------------------------------------------------------
create table if not exists public.admin_user_roles (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  role_id     text not null references public.admin_roles(id) on delete cascade,
  granted_by  uuid references auth.users(id) on delete set null,
  expires_at  timestamptz,
  created_at  timestamptz not null default now(),
  constraint admin_user_roles_user_role_unique unique (user_id, role_id)
);

create table if not exists public.admin_break_glass_grants (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  reason      text not null check (char_length(btrim(reason)) >= 10),
  granted_at  timestamptz not null default now(),
  expires_at  timestamptz not null default (now() + interval '2 hours'),
  review_note text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz
);

-- Backwards compatibility: map existing admin_users into admin_user_roles
insert into public.admin_user_roles (user_id, role_id)
select user_id, role from public.admin_users
where role in (select id from public.admin_roles)
on conflict do nothing;

-- Function: Check if user has specific permission code
create or replace function public.has_permission(p_permission text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
      from public.admin_user_roles ur
      join public.admin_role_permissions rp on rp.role_id = ur.role_id
     where ur.user_id = auth.uid()
       and (ur.expires_at is null or ur.expires_at > now())
       and (rp.permission_code = p_permission or ur.role_id = 'super_admin')
    union
    select 1
      from public.admin_break_glass_grants bg
     where bg.user_id = auth.uid()
       and bg.expires_at > now()
  );
$$;

-- ---------------------------------------------------------------------------
-- 3. Feature Flags Engine (Default OFF in Production)
-- ---------------------------------------------------------------------------
create table if not exists public.feature_flags (
  key         text primary key,
  name        text not null,
  description text,
  enabled     boolean not null default false,
  category    text not null default 'admin',
  owner       text not null default 'Siva',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Seed initial expansion flags (all default OFF)
insert into public.feature_flags (key, name, description, enabled, category) values
  ('flag_advanced_rbac', 'Advanced RBAC & 4-Eyes Approvals', 'Granular 10-role permission matrix & step-up verification', false, 'security'),
  ('flag_scoped_maintenance', 'Scoped Maintenance Controls', '8 independent surface switches with localized 503 pages', false, 'operations'),
  ('flag_data_export_engine', 'Multi-Tier Data Export Engine', 'Tier 1/2/3 export builder with signed links and watermarking', false, 'data'),
  ('flag_cost_computation', 'Itemized INR Cost Computation', 'Per-request, per-channel, and per-campaign cost tracking', false, 'finance'),
  ('flag_ai_voice_studio', 'AI Voice Studio Evaluation', 'Prompt versioning, safety linter, and 60-dialogue test runner', false, 'ai'),
  ('flag_data_quality_centre', 'Data Quality Anomaly Centre', 'Detects duplicate donors, unmapped PINs, and stock glitches', false, 'data'),
  ('flag_global_search_palette', 'Global Command Palette (Ctrl+K)', 'Universal cross-entity search and keyboard shortcuts', false, 'productivity')
on conflict (key) do nothing;

-- ---------------------------------------------------------------------------
-- 4. Audit Log Immutability Hardening
-- ---------------------------------------------------------------------------
-- Hard privacy rule: No one, including super_admin or service_role, may UPDATE or DELETE audit records.
create or replace function public.enforce_audit_log_immutability()
returns trigger language plpgsql as $$
begin
  raise exception 'audit_logs entries are strictly immutable and cannot be updated or deleted'
    using errcode = '42501';
end $$;

drop trigger if exists trg_audit_logs_immutable on public.audit_logs;
create trigger trg_audit_logs_immutable
  before update or delete on public.audit_logs
  for each row execute function public.enforce_audit_log_immutability();

