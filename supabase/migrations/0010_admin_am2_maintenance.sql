-- ============================================================================
-- BloodNorms | 0010_admin_am2_maintenance.sql
-- Milestone AM2: Maintenance Mode & Scoped Switches (MNT-1 to MNT-10)
-- 1. maintenance_windows table with 8 independent scopes
-- 2. In-flight policies (continue_active, freeze, emergency_bypass)
-- 3. Bypass allowlist (phones, admin IDs, IP addresses)
-- 4. Trilingual notifications (en, te, hi)
-- 5. Helper security-definer procedures with audit logging
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Maintenance Windows Table
-- ---------------------------------------------------------------------------
create table if not exists public.maintenance_windows (
  id                uuid primary key default gen_random_uuid(),
  title             text not null,
  scopes            text[] not null default array['web', 'donor', 'bank', 'public', 'whatsapp', 'phone', 'api']::text[],
  status            text not null default 'scheduled' check (status in ('scheduled', 'active', 'completed', 'cancelled')),
  inflight_policy   text not null default 'continue_active' check (inflight_policy in ('continue_active', 'freeze', 'emergency_bypass')),
  message_en        text not null default 'Scheduled maintenance in progress. Emergency blood helpline remains active.',
  message_te        text not null default 'నిర్వహణ పనులు జరుగుతున్నాయి. అత్యవసర రక్త సహాయం అందుబాటులో ఉంది.',
  message_hi        text not null default 'रखरखाव कार्य प्रगति पर है। आपातकालीन रक्त हेल्पलाइन सक्रिय है।',
  scheduled_start   timestamptz not null,
  scheduled_end     timestamptz not null,
  actual_start      timestamptz,
  actual_end        timestamptz,
  created_by        uuid references auth.users(id) on delete set null,
  reason            text not null check (char_length(btrim(reason)) >= 6),
  bypass_allowlist  jsonb not null default '{"phones": [], "admin_ids": [], "ips": []}'::jsonb,
  syndicate_status  boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists maintenance_windows_status_idx on public.maintenance_windows (status, scheduled_start);

alter table public.maintenance_windows enable row level security;

drop policy if exists maintenance_windows_select on public.maintenance_windows;
create policy maintenance_windows_select on public.maintenance_windows
  for select to authenticated, anon
  using (true);

drop policy if exists maintenance_windows_insert on public.maintenance_windows;
create policy maintenance_windows_insert on public.maintenance_windows
  for insert to authenticated, anon
  with check (true);

drop policy if exists maintenance_windows_update on public.maintenance_windows;
create policy maintenance_windows_update on public.maintenance_windows
  for update to authenticated, anon
  using (true)
  with check (true);

grant select, insert, update on public.maintenance_windows to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 2. Seed Default App Settings for Maintenance Mode
-- ---------------------------------------------------------------------------
insert into public.app_settings (key, value)
values
  ('maintenance_mode_active', '{"active": false}'::jsonb),
  ('maintenance_active_scopes', '["web","donor","bank","public","whatsapp","phone","api"]'::jsonb),
  ('maintenance_inflight_policy', '"continue_active"'::jsonb),
  ('maintenance_current_window_id', 'null'::jsonb)
on conflict (key) do nothing;

-- ---------------------------------------------------------------------------
-- 3. Stored Procedure: check_maintenance_status
-- Evaluates whether a given scope is under maintenance and whether user is bypassed.
-- ---------------------------------------------------------------------------
create or replace function public.check_maintenance_status(
  p_scope text,
  p_identifier text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_active boolean := false;
  v_scopes jsonb;
  v_policy text := 'continue_active';
  v_window record;
  v_bypassed boolean := false;
  v_msg_en text := 'Scheduled maintenance in progress.';
  v_msg_te text := 'నిర్వహణ పనులు జరుగుతున్నాయి.';
  v_msg_hi text := 'रखरखाव कार्य प्रगति पर है।';
begin
  -- Check active window first
  select * into v_window
    from public.maintenance_windows
   where status = 'active'
     and now() between coalesce(actual_start, scheduled_start) and scheduled_end
   order by created_at desc
   limit 1;

  if found then
    if p_scope = any(v_window.scopes) then
      v_active := true;
      v_policy := v_window.inflight_policy;
      v_msg_en := v_window.message_en;
      v_msg_te := v_window.message_te;
      v_msg_hi := v_window.message_hi;

      -- Check bypass allowlist
      if p_identifier is not null then
        if (v_window.bypass_allowlist->'phones')::text ilike '%' || p_identifier || '%'
           or (v_window.bypass_allowlist->'admin_ids')::text ilike '%' || p_identifier || '%'
           or (v_window.bypass_allowlist->'ips')::text ilike '%' || p_identifier || '%' then
          v_bypassed := true;
        end if;
      end if;
    end if;
  else
    -- Fallback to app_settings
    select (value->>'active')::boolean into v_active
      from public.app_settings
     where key = 'maintenance_mode_active';

    v_active := coalesce(v_active, false);

    if v_active then
      select value into v_scopes from public.app_settings where key = 'maintenance_active_scopes';
      if v_scopes is not null and not (v_scopes::text ilike '%' || p_scope || '%') then
        v_active := false;
      end if;
    end if;
  end if;

  return jsonb_build_object(
    'active', v_active and (not v_bypassed),
    'is_maintenance', v_active,
    'bypassed', v_bypassed,
    'scope', p_scope,
    'policy', v_policy,
    'messages', jsonb_build_object(
      'en', v_msg_en,
      'te', v_msg_te,
      'hi', v_msg_hi
    )
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Stored Procedure: set_maintenance_mode
-- ---------------------------------------------------------------------------
create or replace function public.set_maintenance_mode(
  p_active boolean,
  p_scopes text[],
  p_policy text default 'continue_active',
  p_reason text default 'Scheduled operational maintenance',
  p_duration_minutes int default 60,
  p_bypass_allowlist jsonb default '{"phones": [], "admin_ids": [], "ips": []}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_window_id uuid;
  v_start timestamptz := now();
  v_end timestamptz := now() + (p_duration_minutes || ' minutes')::interval;
begin
  if p_active then
    -- Complete any previous active windows
    update public.maintenance_windows
       set status = 'completed', actual_end = now()
     where status = 'active';

    -- Create new active window
    insert into public.maintenance_windows (
      title,
      scopes,
      status,
      inflight_policy,
      scheduled_start,
      scheduled_end,
      actual_start,
      reason,
      bypass_allowlist
    ) values (
      'Emergency / Scheduled Maintenance (' || to_char(now(), 'YYYY-MM-DD HH24:MI') || ')',
      p_scopes,
      'active',
      p_policy,
      v_start,
      v_end,
      v_start,
      p_reason,
      p_bypass_allowlist
    ) returning id into v_window_id;

    -- Update app_settings
    update public.app_settings set value = jsonb_build_object('active', true) where key = 'maintenance_mode_active';
    update public.app_settings set value = to_jsonb(p_scopes) where key = 'maintenance_active_scopes';
    update public.app_settings set value = to_jsonb(p_policy) where key = 'maintenance_inflight_policy';
    update public.app_settings set value = to_jsonb(v_window_id::text) where key = 'maintenance_current_window_id';
  else
    -- Turn off
    update public.maintenance_windows
       set status = 'completed', actual_end = now()
     where status = 'active';

    update public.app_settings set value = jsonb_build_object('active', false) where key = 'maintenance_mode_active';
    update public.app_settings set value = 'null'::jsonb where key = 'maintenance_current_window_id';
  end if;

  -- Append to immutable audit logs
  insert into public.audit_logs (action, detail)
  values (
    case when p_active then 'maintenance.enable' else 'maintenance.disable' end,
    jsonb_build_object(
      'active', p_active,
      'scopes', p_scopes,
      'policy', p_policy,
      'reason', p_reason,
      'duration_minutes', p_duration_minutes
    )::text
  );

  return jsonb_build_object('ok', true, 'active', p_active, 'window_id', v_window_id);
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Stored Procedure: extend_maintenance_window
-- ---------------------------------------------------------------------------
create or replace function public.extend_maintenance_window(
  p_window_id uuid,
  p_additional_minutes int,
  p_reason text default 'Extension required for system checks'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new_end timestamptz;
begin
  update public.maintenance_windows
     set scheduled_end = scheduled_end + (p_additional_minutes || ' minutes')::interval,
         updated_at = now()
   where id = p_window_id
     and status = 'active'
  returning scheduled_end into v_new_end;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'Window not found or not active');
  end if;

  insert into public.audit_logs (action, detail)
  values (
    'maintenance.extend',
    jsonb_build_object(
      'window_id', p_window_id,
      'additional_minutes', p_additional_minutes,
      'new_end', v_new_end,
      'reason', p_reason
    )::text
  );

  return jsonb_build_object('ok', true, 'new_end', v_new_end);
end;
$$;

grant execute on function public.check_maintenance_status(text, text) to authenticated, anon;
grant execute on function public.set_maintenance_mode(boolean, text[], text, text, int, jsonb) to authenticated, anon;
grant execute on function public.extend_maintenance_window(uuid, int, text) to authenticated, anon;

