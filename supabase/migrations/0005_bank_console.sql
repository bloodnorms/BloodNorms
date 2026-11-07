-- ============================================================================
-- BloodNorms | 0005_bank_console.sql
-- The blood bank side: staff accounts, invites, stock updates with history,
-- "expected donors" view, donation confirmation/rejection at the bank, camps.
-- Staff never touch tables directly: every write goes through a checked function.
-- Tested on PostgreSQL 16 + PostGIS 3.4 (supabase/tests/30_bank_console_tests.sql)
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Staff and invites
-- ---------------------------------------------------------------------------
create table if not exists public.bank_staff (
  user_id      uuid primary key references auth.users(id) on delete cascade,   -- one bank per person
  bank_id      uuid not null references public.blood_banks(id) on delete cascade,
  role         text not null default 'bank_staff' check (role in ('bank_admin','bank_staff')),
  display_name text check (char_length(display_name) <= 60),
  active       boolean not null default true,
  created_at   timestamptz not null default now()
);
create index if not exists bank_staff_bank_idx on public.bank_staff (bank_id);
alter table public.bank_staff enable row level security;
drop policy if exists bank_staff_select_self_or_admin on public.bank_staff;
create policy bank_staff_select_self_or_admin on public.bank_staff
  for select to authenticated using (user_id = auth.uid() or public.is_admin());
grant select on public.bank_staff to authenticated;

create table if not exists public.bank_staff_invites (
  id           uuid primary key default gen_random_uuid(),
  bank_id      uuid not null references public.blood_banks(id) on delete cascade,
  phone_e164   text not null check (phone_e164 ~ '^\+91[6-9][0-9]{9}$'),
  role         text not null default 'bank_staff' check (role in ('bank_admin','bank_staff')),
  display_name text,
  invited_by   uuid references auth.users(id) on delete set null,
  expires_at   timestamptz not null default (now() + interval '14 days'),
  accepted_at  timestamptz,
  created_at   timestamptz not null default now()
);
create unique index if not exists bank_staff_invites_open on public.bank_staff_invites (phone_e164, bank_id) where accepted_at is null;
alter table public.bank_staff_invites enable row level security;
drop policy if exists bank_staff_invites_admin_select on public.bank_staff_invites;
create policy bank_staff_invites_admin_select on public.bank_staff_invites
  for select to authenticated using (public.is_admin());
grant select on public.bank_staff_invites to authenticated;

create or replace function public.my_bank_id() returns uuid
language sql stable security definer set search_path = public as $$
  select s.bank_id from public.bank_staff s where s.user_id = auth.uid() and s.active;
$$;
create or replace function public.my_bank_role() returns text
language sql stable security definer set search_path = public as $$
  select s.role from public.bank_staff s where s.user_id = auth.uid() and s.active;
$$;

-- server-only: after a phone login, turn open invites for that phone into staff access
create or replace function public.accept_bank_invites_for_user(p_user_id uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_phone text; v_inv public.bank_staff_invites;
begin
  select '+' || ltrim(u.phone, '+') into v_phone from auth.users u where u.id = p_user_id;
  if v_phone is null then return null; end if;
  select * into v_inv from public.bank_staff_invites
   where phone_e164 = v_phone and accepted_at is null and expires_at > now()
   order by created_at desc limit 1;
  if not found then return null; end if;
  insert into public.bank_staff(user_id, bank_id, role, display_name)
  values (p_user_id, v_inv.bank_id, v_inv.role, v_inv.display_name)
  on conflict (user_id) do update set bank_id = excluded.bank_id, role = excluded.role, active = true;
  update public.bank_staff_invites set accepted_at = now() where id = v_inv.id;
  insert into public.audit_logs(actor_id, action, target_type, target_id) values (p_user_id, 'bank_invite_accepted', 'bank', v_inv.bank_id::text);
  return v_inv.bank_id;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Stock history (every change, from any source)
-- ---------------------------------------------------------------------------
create table if not exists public.bank_stock_history (
  id             bigint generated always as identity primary key,
  bank_id        uuid not null references public.blood_banks(id) on delete cascade,
  blood_group    public.blood_group not null,
  component      public.blood_component not null,
  units          int not null,
  previous_units int,
  source         text not null,
  updated_by     uuid,
  created_at     timestamptz not null default now()
);
create index if not exists bank_stock_history_idx on public.bank_stock_history (bank_id, created_at desc);
alter table public.bank_stock_history enable row level security;
drop policy if exists bank_stock_history_select on public.bank_stock_history;
create policy bank_stock_history_select on public.bank_stock_history
  for select to authenticated using (bank_id = public.my_bank_id() or public.is_admin());
grant select on public.bank_stock_history to authenticated;

create or replace function public.bank_stock_log() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.bank_stock_history(bank_id, blood_group, component, units, previous_units, source, updated_by)
  values (new.bank_id, new.blood_group, new.component, new.units,
          case when tg_op = 'UPDATE' then old.units end, new.source, new.updated_by);
  return null;
end $$;

drop trigger if exists bank_stock_log on public.bank_stock;
create trigger bank_stock_log after insert or update on public.bank_stock
  for each row execute function public.bank_stock_log();

-- ---------------------------------------------------------------------------
-- 3. Bank staff actions (all checked, all audited)
-- ---------------------------------------------------------------------------
-- rows example: [{"group":"O+","component":"whole_blood","units":4}, ...]
create or replace function public.bank_set_stock(p_rows jsonb) returns int
language plpgsql security definer set search_path = public as $$
declare v_bank uuid := public.my_bank_id(); r jsonb; n int := 0; v_units int;
begin
  if v_bank is null then raise exception 'not bank staff' using errcode = '42501'; end if;
  if not public.rl_hit('bank_stock:' || auth.uid()::text, 3600, 120) then
    raise exception 'too many updates' using errcode = '54000';
  end if;
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) not between 1 and 40 then
    raise exception 'bad payload' using errcode = '22023';
  end if;
  for r in select * from jsonb_array_elements(p_rows) loop
    v_units := (r ->> 'units')::int;
    if v_units is null or v_units < 0 or v_units > 500 then raise exception 'bad units' using errcode = '22023'; end if;
    insert into public.bank_stock(bank_id, blood_group, component, units, source, updated_by, updated_at)
    values (v_bank, (r ->> 'group')::public.blood_group,
            coalesce(r ->> 'component', 'whole_blood')::public.blood_component, v_units, 'bank', auth.uid(), now())
    on conflict (bank_id, blood_group, component)
    do update set units = excluded.units, source = 'bank', updated_by = excluded.updated_by, updated_at = now();
    n := n + 1;
  end loop;
  insert into public.audit_logs(actor_id, action, target_type, target_id, meta)
  values (auth.uid(), 'bank_set_stock', 'bank', v_bank::text, jsonb_build_object('rows', n));
  return n;
end $$;

create or replace function public.bank_update_info(p_phones text[], p_hours text, p_is_24x7 boolean, p_address text)
returns void language plpgsql security definer set search_path = public as $$
declare v_bank uuid := public.my_bank_id(); p text;
begin
  if v_bank is null or public.my_bank_role() <> 'bank_admin' then raise exception 'not allowed' using errcode = '42501'; end if;
  if p_phones is not null then
    foreach p in array p_phones loop
      if p !~ '^\+?[0-9][0-9 \-]{6,17}$' then raise exception 'bad phone' using errcode = '22023'; end if;
    end loop;
  end if;
  update public.blood_banks
     set phones = coalesce(p_phones, phones), hours = coalesce(p_hours, hours),
         is_24x7 = coalesce(p_is_24x7, is_24x7), address = coalesce(p_address, address)
   where id = v_bank;
  insert into public.audit_logs(actor_id, action, target_type, target_id) values (auth.uid(), 'bank_update_info', 'bank', v_bank::text);
end $$;

-- donors who accepted a request near this bank (no phone numbers, no codes)
create or replace function public.bank_expected_donors()
returns table (first_name text, blood_group public.blood_group, eta_minutes int,
               status public.contact_status, request_id uuid, distance_band text)
language sql stable security definer set search_path = public, extensions as $$
  select k.first_name, k.blood_group, k.eta_minutes, k.status, k.request_id, k.distance_band
    from public.blood_banks b
    join public.requests r on st_dwithin(r.hospital_geo, b.geo, 3000)
                          and r.status in ('searching','waiting_requester','enough_donors')
    join public.request_donor_cards k on k.request_id = r.id and k.status in ('accepted','on_the_way','arrived')
   where b.id = public.my_bank_id()
   order by k.eta_minutes nulls last;
$$;

-- the donor tells the 6-digit code at the bank; staff enter it
create or replace function public.bank_confirm_donation(p_code text, p_donor_last4 text default null) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_bank uuid := public.my_bank_id(); v_n int; d public.donations; c public.request_contacts;
        v_first text; v_group public.blood_group; v_req_group public.blood_group;
begin
  if v_bank is null then raise exception 'not bank staff' using errcode = '42501'; end if;
  if p_code is null or p_code !~ '^[0-9]{6}$' then raise exception 'bad code' using errcode = '22023'; end if;
  if not public.rl_hit('bank_confirm:' || auth.uid()::text, 3600, 60) then
    raise exception 'too many attempts' using errcode = '54000';
  end if;
  select count(*) into v_n
    from public.donations dn
    join public.request_contacts rc on rc.id = dn.contact_id
    left join public.donor_private dp on dp.donor_id = dn.donor_id
   where dn.code = p_code and dn.status = 'pending' and rc.status in ('accepted','on_the_way','arrived')
     and (p_donor_last4 is null or right(dp.phone_e164, 4) = p_donor_last4);
  if v_n = 0 then
    if not public.rl_hit('bank_confirm_fail:' || auth.uid()::text, 3600, 10) then
      raise exception 'locked for an hour' using errcode = '54000';
    end if;
    return jsonb_build_object('ok', false, 'reason', 'not_found');
  end if;
  if v_n > 1 then return jsonb_build_object('ok', false, 'reason', 'ambiguous'); end if;

  select dn.* into d
    from public.donations dn
    join public.request_contacts rc on rc.id = dn.contact_id
    left join public.donor_private dp on dp.donor_id = dn.donor_id
   where dn.code = p_code and dn.status = 'pending' and rc.status in ('accepted','on_the_way','arrived')
     and (p_donor_last4 is null or right(dp.phone_e164, 4) = p_donor_last4);
  select * into c from public.request_contacts where id = d.contact_id for update;
  select blood_group into v_req_group from public.requests where id = c.request_id;

  update public.donations set status = 'confirmed', confirmed_by = 'bank', confirmed_at = now(), bank_id = v_bank where id = d.id;
  update public.request_contacts set status = 'donated' where id = c.id;
  update public.donors
     set last_donation_date = current_date, donations_count = donations_count + 1,
         trust_level = 3,
         group_confidence = case when blood_group = v_req_group then 'bank_confirmed' else group_confidence end
   where id = c.donor_id returning first_name, blood_group into v_first, v_group;
  insert into public.audit_logs(actor_id, action, target_type, target_id) values (auth.uid(), 'bank_confirm_donation', 'donation', d.id::text);
  return jsonb_build_object('ok', true, 'first_name', v_first, 'blood_group', v_group, 'request_id', c.request_id);
end $$;

-- the doctor deferred the donor, or the donor never came
create or replace function public.bank_reject_donation(p_code text, p_reason text) returns boolean
language plpgsql security definer set search_path = public as $$
declare v_bank uuid := public.my_bank_id(); d public.donations;
begin
  if v_bank is null then raise exception 'not bank staff' using errcode = '42501'; end if;
  if p_reason not in ('deferred_medical','not_present','other') then raise exception 'bad reason' using errcode = '22023'; end if;
  select dn.* into d from public.donations dn
    join public.request_contacts rc on rc.id = dn.contact_id
   where dn.code = p_code and dn.status = 'pending' and rc.status in ('accepted','on_the_way','arrived')
   limit 1;
  if not found then return false; end if;
  update public.donations set status = 'rejected', bank_id = v_bank where id = d.id;
  update public.request_contacts
     set status = 'declined', answers = answers || jsonb_build_object('bank_reject', p_reason)
   where id = d.contact_id;
  insert into public.audit_logs(actor_id, action, target_type, target_id, meta)
  values (auth.uid(), 'bank_reject_donation', 'donation', d.id::text, jsonb_build_object('reason', p_reason));
  return true;
end $$;

-- ---------------------------------------------------------------------------
-- 4. Blood camps
-- ---------------------------------------------------------------------------
create table if not exists public.bank_camps (
  id         uuid primary key default gen_random_uuid(),
  bank_id    uuid not null references public.blood_banks(id) on delete cascade,
  title      text not null check (char_length(btrim(title)) between 3 and 80),
  venue      text check (char_length(venue) <= 120),
  area       text,
  geo        geography(Point,4326) not null,
  starts_at  timestamptz not null,
  ends_at    timestamptz not null,
  capacity   int check (capacity between 1 and 5000),
  status     text not null default 'published' check (status in ('draft','published','cancelled','done')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);
create index if not exists bank_camps_geo_idx on public.bank_camps using gist (geo);
create index if not exists bank_camps_time_idx on public.bank_camps (starts_at);
alter table public.bank_camps enable row level security;
drop policy if exists bank_camps_public_read on public.bank_camps;
create policy bank_camps_public_read on public.bank_camps
  for select to anon, authenticated using (status = 'published' and ends_at > now() - interval '1 day');
drop policy if exists bank_camps_own_bank_read on public.bank_camps;
create policy bank_camps_own_bank_read on public.bank_camps
  for select to authenticated using (bank_id = public.my_bank_id() or public.is_admin());
grant select on public.bank_camps to anon, authenticated;

create table if not exists public.camp_signups (
  camp_id    uuid not null references public.bank_camps(id) on delete cascade,
  donor_id   uuid not null references public.donors(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (camp_id, donor_id)
);
alter table public.camp_signups enable row level security;
drop policy if exists camp_signups_own on public.camp_signups;
create policy camp_signups_own on public.camp_signups
  for select to authenticated using (donor_id = auth.uid() or public.is_admin());
grant select on public.camp_signups to authenticated;

create or replace function public.bank_create_camp(p_title text, p_venue text, p_area text,
  p_lat double precision, p_lng double precision, p_starts timestamptz, p_ends timestamptz, p_capacity int)
returns uuid language plpgsql security definer set search_path = public, extensions as $$
declare v_bank uuid := public.my_bank_id(); v_id uuid;
begin
  if v_bank is null or public.my_bank_role() <> 'bank_admin' then raise exception 'not allowed' using errcode = '42501'; end if;
  if p_lat not between 6 and 38 or p_lng not between 68 and 98 then raise exception 'location outside India' using errcode = '22023'; end if;
  if p_starts < now() - interval '1 hour' then raise exception 'camp in the past' using errcode = '22023'; end if;
  if not public.rl_hit('bank_camp:' || auth.uid()::text, 86400, 5) then raise exception 'too many camps today' using errcode = '54000'; end if;
  insert into public.bank_camps(bank_id, title, venue, area, geo, starts_at, ends_at, capacity, created_by)
  values (v_bank, btrim(p_title), p_venue, p_area, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          p_starts, p_ends, p_capacity, auth.uid()) returning id into v_id;
  insert into public.audit_logs(actor_id, action, target_type, target_id) values (auth.uid(), 'bank_create_camp', 'camp', v_id::text);
  return v_id;
end $$;

create or replace function public.bank_set_camp_status(p_camp_id uuid, p_status text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if p_status not in ('draft','published','cancelled','done') then raise exception 'bad status' using errcode = '22023'; end if;
  update public.bank_camps set status = p_status
   where id = p_camp_id and bank_id = public.my_bank_id() and public.my_bank_role() = 'bank_admin';
  if not found then raise exception 'not allowed' using errcode = '42501'; end if;
end $$;

create or replace function public.join_camp(p_camp_id uuid) returns boolean
language plpgsql security definer set search_path = public as $$
declare c public.bank_camps; v_count int;
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if not exists (select 1 from public.donors where id = auth.uid() and state = 'active') then
    raise exception 'active donor required' using errcode = '42501';
  end if;
  select * into c from public.bank_camps where id = p_camp_id and status = 'published' and ends_at > now();
  if not found then raise exception 'camp not open' using errcode = '22023'; end if;
  select count(*) into v_count from public.camp_signups where camp_id = p_camp_id;
  if c.capacity is not null and v_count >= c.capacity then return false; end if;
  insert into public.camp_signups(camp_id, donor_id) values (p_camp_id, auth.uid()) on conflict do nothing;
  return true;
end $$;

create or replace function public.leave_camp(p_camp_id uuid) returns void
language sql security definer set search_path = public as $$
  delete from public.camp_signups where camp_id = p_camp_id and donor_id = auth.uid();
$$;

create or replace function public.bank_camp_signups(p_camp_id uuid)
returns table (first_name text, blood_group public.blood_group, signed_at timestamptz)
language sql stable security definer set search_path = public as $$
  select d.first_name, d.blood_group, s.created_at
    from public.camp_signups s
    join public.bank_camps c on c.id = s.camp_id
    join public.donors d on d.id = s.donor_id
   where s.camp_id = p_camp_id and c.bank_id = public.my_bank_id()
   order by s.created_at;
$$;

