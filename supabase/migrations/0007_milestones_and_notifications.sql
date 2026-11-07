-- ============================================================================
-- BloodNorms | 0007_milestones_and_notifications.sql
-- Additive Stage 3, 4, 5 Migration:
-- 1. Donor Milestone Badges & Appreciation Certificates
-- 2. Camp Attendance Check-in & Collection Counters
-- 3. Centralized Notification Center (In-App real-time announcements & alerts)
-- Backward-compatible, non-destructive additive DDL.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Donor Milestone Badges
-- ---------------------------------------------------------------------------
create table if not exists public.donor_badges (
  id              uuid primary key default gen_random_uuid(),
  donor_id        uuid not null references public.donors(id) on delete cascade,
  badge_code      text not null,
  badge_name      text not null,
  description     text,
  unlocked_at     timestamptz not null default now(),
  certificate_url text,
  created_at      timestamptz not null default now(),
  constraint donor_badges_donor_code_unique unique (donor_id, badge_code)
);

create index if not exists donor_badges_donor_idx on public.donor_badges (donor_id, unlocked_at desc);

alter table public.donor_badges enable row level security;

drop policy if exists donor_badges_select on public.donor_badges;
create policy donor_badges_select on public.donor_badges
  for select to authenticated, anon
  using (donor_id = auth.uid() or public.is_admin() or auth.uid() is null);

drop policy if exists donor_badges_admin_write on public.donor_badges;
create policy donor_badges_admin_write on public.donor_badges
  for all to authenticated
  using (public.is_admin() or donor_id = auth.uid())
  with check (public.is_admin() or donor_id = auth.uid());

grant select, insert, update on public.donor_badges to authenticated, anon;

-- Add badge_level to donors if not exists
alter table public.donors add column if not exists badge_level text default 'bronze';

-- ---------------------------------------------------------------------------
-- 2. Camp Attendance & Collection Counters
-- ---------------------------------------------------------------------------
alter table public.bank_camps
  add column if not exists attendees_checked_in integer not null default 0,
  add column if not exists units_collected integer not null default 0;

alter table public.camp_signups
  add column if not exists checked_in boolean not null default false,
  add column if not exists checked_in_at timestamptz;

-- Function: Bank staff or admin checks in an attendee at a camp
create or replace function public.bank_check_in_camp_attendee(
  p_camp_id uuid,
  p_donor_id uuid default null,
  p_phone text default null,
  p_units_donated int default 1
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_target_donor_id uuid := p_donor_id;
  v_donor_name text;
  v_blood_group public.blood_group;
  v_new_donations int;
begin
  -- Resolve donor by phone if not passed
  if v_target_donor_id is null and p_phone is not null then
    select donor_id into v_target_donor_id
      from public.donor_private
     where phone_e164 = p_phone or right(phone_e164, 10) = right(p_phone, 10)
     limit 1;
  end if;

  if v_target_donor_id is null then
    return jsonb_build_object('ok', false, 'reason', 'donor_not_found');
  end if;

  -- Ensure signup record exists and mark checked in
  insert into public.camp_signups (camp_id, donor_id, checked_in, checked_in_at)
  values (p_camp_id, v_target_donor_id, true, now())
  on conflict (camp_id, donor_id) do update
    set checked_in = true, checked_in_at = coalesce(camp_signups.checked_in_at, now());

  -- Update camp counters
  update public.bank_camps
     set attendees_checked_in = attendees_checked_in + 1,
         units_collected = units_collected + coalesce(p_units_donated, 1)
   where id = p_camp_id;

  -- Update donor stats
  update public.donors
     set donations_count = donations_count + coalesce(p_units_donated, 1),
         last_donation_date = current_date
   where id = v_target_donor_id
   returning first_name, blood_group, donations_count into v_donor_name, v_blood_group, v_new_donations;

  -- Check & award badge based on count
  if v_new_donations >= 25 then
    insert into public.donor_badges (donor_id, badge_code, badge_name, description)
    values (v_target_donor_id, 'centurion', 'Centurion Lifesaver', 'Completed 25+ blood donations')
    on conflict do nothing;
    update public.donors set badge_level = 'diamond' where id = v_target_donor_id;
  elsif v_new_donations >= 10 then
    insert into public.donor_badges (donor_id, badge_code, badge_name, description)
    values (v_target_donor_id, 'platinum_savior', 'Platinum Savior', 'Completed 10 blood donations')
    on conflict do nothing;
    update public.donors set badge_level = 'platinum' where id = v_target_donor_id;
  elsif v_new_donations >= 5 then
    insert into public.donor_badges (donor_id, badge_code, badge_name, description)
    values (v_target_donor_id, 'gold_lifesaver', 'Gold Lifesaver', 'Completed 5 blood donations')
    on conflict do nothing;
    update public.donors set badge_level = 'gold' where id = v_target_donor_id;
  elsif v_new_donations >= 3 then
    insert into public.donor_badges (donor_id, badge_code, badge_name, description)
    values (v_target_donor_id, 'silver_guardian', 'Silver Guardian', 'Completed 3 blood donations')
    on conflict do nothing;
    update public.donors set badge_level = 'silver' where id = v_target_donor_id;
  elsif v_new_donations >= 1 then
    insert into public.donor_badges (donor_id, badge_code, badge_name, description)
    values (v_target_donor_id, 'bronze_hero', 'Bronze Hero', 'First lifesaver donation recorded')
    on conflict do nothing;
    update public.donors set badge_level = 'bronze' where id = v_target_donor_id;
  end if;

  insert into public.audit_logs(actor_id, action, target_type, target_id, meta)
  values (auth.uid(), 'camp_donor_checkin', 'camp', p_camp_id::text,
          jsonb_build_object('donor_id', v_target_donor_id, 'units', p_units_donated));

  return jsonb_build_object(
    'ok', true,
    'donor_id', v_target_donor_id,
    'first_name', v_donor_name,
    'blood_group', v_blood_group,
    'total_donations', v_new_donations
  );
end $$;

-- ---------------------------------------------------------------------------
-- 3. In-App Notifications Center
-- ---------------------------------------------------------------------------
create table if not exists public.notifications (
  id              uuid primary key default gen_random_uuid(),
  recipient_id    uuid references auth.users(id) on delete cascade,
  recipient_role  text not null default 'all', -- 'all', 'donor', 'requester', 'bank_staff', 'admin'
  title           text not null check (char_length(title) <= 120),
  body            text not null check (char_length(body) <= 500),
  category        text not null default 'system' check (category in ('emergency','camp','milestone','system','stock')),
  payload         jsonb not null default '{}'::jsonb,
  is_read         boolean not null default false,
  created_at      timestamptz not null default now()
);

create index if not exists notifications_recipient_idx on public.notifications (recipient_id, is_read, created_at desc);
create index if not exists notifications_role_idx on public.notifications (recipient_role, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists notifications_select on public.notifications;
create policy notifications_select on public.notifications
  for select to authenticated, anon
  using (
    recipient_id is null
    or recipient_id = auth.uid()
    or recipient_role = 'all'
    or public.is_admin()
  );

drop policy if exists notifications_insert on public.notifications;
create policy notifications_insert on public.notifications
  for insert to authenticated, anon
  with check (true);

drop policy if exists notifications_update on public.notifications;
create policy notifications_update on public.notifications
  for update to authenticated, anon
  using (
    recipient_id = auth.uid()
    or public.is_admin()
  );

grant select, insert, update on public.notifications to authenticated, anon;

