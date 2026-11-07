-- ============================================================================
-- BloodNorms | 0006_roles.sql
-- Admin roles: support (read-only), admin (operational), super_admin (Siva only).
-- Initial seed for pilot city (Rajahmundry, East Godavari, AP).
-- ============================================================================

set search_path = public, extensions;

-- Function to check admin role levels
create or replace function public.has_admin_role(p_required_role text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.admin_users
     where user_id = auth.uid()
       and (
         role = 'super_admin' or
         (p_required_role = 'admin' and role in ('admin', 'super_admin')) or
         (p_required_role = 'support' and role in ('support', 'admin', 'super_admin'))
       )
  );
$$;

-- Seed initial Blood Banks in Rajahmundry pilot city
insert into public.blood_banks (
  name, address, city, district, state, pincode, geo, phones, bank_type, is_24x7, hours, trust_score
) values
(
  'Rotary Central Blood Bank',
  'Near Danavaipeta Park, Main Road',
  'Rajahmundry',
  'East Godavari',
  'Andhra Pradesh',
  '533103',
  st_setsrid(st_makepoint(81.7820, 17.0005), 4326)::geography,
  array['+918832471234', '+919848123456'],
  'charitable',
  true,
  'Open 24 Hours',
  85
),
(
  'Government General Hospital Blood Bank',
  'Opposite Collectorate, Hospital Road',
  'Rajahmundry',
  'East Godavari',
  'Andhra Pradesh',
  '533101',
  st_setsrid(st_makepoint(81.7774, 16.9944), 4326)::geography,
  array['+918832467890'],
  'government',
  true,
  'Open 24 Hours',
  75
),
(
  'Indian Red Cross Society Blood Centre',
  'Red Cross Bhavan, Gandhipuram',
  'Rajahmundry',
  'East Godavari',
  'Andhra Pradesh',
  '533104',
  st_setsrid(st_makepoint(81.7915, 17.0120), 4326)::geography,
  array['+918832445566'],
  'red_cross',
  false,
  '08:00 AM - 08:00 PM',
  90
)
on conflict do nothing;

-- Seed sample stock for each bank
insert into public.bank_stock (bank_id, blood_group, component, units, source, updated_at)
select
  b.id,
  g.grp::public.blood_group,
  'whole_blood'::public.blood_component,
  case g.grp
    when 'O+' then 6
    when 'B+' then 8
    when 'A+' then 4
    when 'AB+' then 2
    when 'O-' then 1
    when 'A-' then 1
    else 0
  end,
  'bank',
  now() - interval '25 minutes'
from public.blood_banks b
cross join (
  values ('A+'), ('A-'), ('B+'), ('B-'), ('AB+'), ('AB-'), ('O+'), ('O-')
) as g(grp)
on conflict (bank_id, blood_group, component) do update set
  units = excluded.units,
  updated_at = excluded.updated_at;

-- Seed key pincodes in Rajahmundry region
insert into public.pincodes (pincode, office_name, district, state, geo, lat, lng)
values
  ('533101', 'Rajahmundry HO', 'East Godavari', 'Andhra Pradesh', st_setsrid(st_makepoint(81.7774, 16.9944), 4326)::geography, 16.9944, 81.7774),
  ('533103', 'Danavaipeta SO', 'East Godavari', 'Andhra Pradesh', st_setsrid(st_makepoint(81.7820, 17.0005), 4326)::geography, 17.0005, 81.7820),
  ('533104', 'Aryapuram SO', 'East Godavari', 'Andhra Pradesh', st_setsrid(st_makepoint(81.7915, 17.0120), 4326)::geography, 17.0120, 81.7915)
on conflict (pincode) do nothing;

