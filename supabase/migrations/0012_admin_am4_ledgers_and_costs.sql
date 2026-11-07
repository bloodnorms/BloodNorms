-- ============================================================================
-- BloodNorms | 0012_admin_am4_ledgers_and_costs.sql
-- Milestone AM4: Ledgers & Cost Engine (EXP-LED-1, EXP-LED-2, EXP-CST-1, FIN-1..5)
-- 1. cost_rate_cards table with default INR rates (Meta, Twilio, Gemini Live)
-- 2. cost_events ledger attributing itemized spend to emergency requests
-- 3. Stored procedures for per-request cost aggregation and daily spend analysis
-- Forward-only, additive, 100% backward-compatible.
-- ============================================================================
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- 1. Cost Rate Cards Table
-- ---------------------------------------------------------------------------
create table if not exists public.cost_rate_cards (
  id              uuid primary key default gen_random_uuid(),
  service_name    text not null unique,
  unit_cost_inr   numeric(10, 4) not null,
  unit_label      text not null default 'unit',
  effective_from  timestamptz not null default now(),
  updated_by      uuid references auth.users(id) on delete set null,
  updated_at      timestamptz not null default now()
);

alter table public.cost_rate_cards enable row level security;
drop policy if exists cost_rate_cards_policy on public.cost_rate_cards;
create policy cost_rate_cards_policy on public.cost_rate_cards for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.cost_rate_cards to authenticated, anon;

-- Pre-seed default industry rate card in Indian Rupees (INR)
insert into public.cost_rate_cards (service_name, unit_cost_inr, unit_label)
values
  ('whatsapp_utility', 0.3500, 'per delivered template'),
  ('whatsapp_marketing', 0.8500, 'per delivered template'),
  ('twilio_voice_min', 1.8000, 'per connected minute'),
  ('gemini_live_min', 2.4000, 'per streaming minute'),
  ('sms_failover', 0.2800, 'per SMS segment')
on conflict (service_name) do update
set unit_cost_inr = excluded.unit_cost_inr, updated_at = now();

-- ---------------------------------------------------------------------------
-- 2. Cost Events Ledger
-- ---------------------------------------------------------------------------
create table if not exists public.cost_events (
  id              uuid primary key default gen_random_uuid(),
  request_id      text references public.requests(id) on delete set null,
  service_name    text not null,
  units_consumed  numeric(10, 2) not null default 1.0,
  unit_cost_inr   numeric(10, 4) not null,
  total_cost_inr  numeric(10, 4) not null,
  meta_payload    jsonb not null default '{}'::jsonb,
  created_at      timestamptz not null default now()
);

create index if not exists cost_events_req_idx on public.cost_events (request_id, created_at desc);
create index if not exists cost_events_created_idx on public.cost_events (created_at desc);

alter table public.cost_events enable row level security;
drop policy if exists cost_events_policy on public.cost_events;
create policy cost_events_policy on public.cost_events for all to authenticated, anon using (true) with check (true);
grant select, insert, update on public.cost_events to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 3. Stored Procedure: record_cost_event
-- ---------------------------------------------------------------------------
create or replace function public.record_cost_event(
  p_request_id text,
  p_service_name text,
  p_units numeric default 1.0,
  p_meta jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_unit_rate numeric(10, 4);
  v_total_cost numeric(10, 4);
  v_id uuid;
begin
  select unit_cost_inr into v_unit_rate
    from public.cost_rate_cards
   where service_name = p_service_name;

  v_unit_rate := coalesce(v_unit_rate, 0.5000);
  v_total_cost := round(v_unit_rate * p_units, 4);

  insert into public.cost_events (
    request_id,
    service_name,
    units_consumed,
    unit_cost_inr,
    total_cost_inr,
    meta_payload
  ) values (
    p_request_id,
    p_service_name,
    p_units,
    v_unit_rate,
    v_total_cost,
    p_meta
  ) returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'event_id', v_id,
    'unit_rate', v_unit_rate,
    'total_cost_inr', v_total_cost
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Stored Procedure: get_daily_spend_summary
-- ---------------------------------------------------------------------------
create or replace function public.get_daily_spend_summary(p_target_date date default current_date)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total numeric := 0;
  v_breakdown jsonb;
begin
  select coalesce(sum(total_cost_inr), 0) into v_total
    from public.cost_events
   where date(created_at) = p_target_date;

  select jsonb_agg(sub) into v_breakdown
    from (
      select service_name, count(*) as count, sum(units_consumed) as units, sum(total_cost_inr) as total_inr
        from public.cost_events
       where date(created_at) = p_target_date
       group by service_name
    ) sub;

  return jsonb_build_object(
    'target_date', p_target_date,
    'total_spend_inr', v_total,
    'breakdown', coalesce(v_breakdown, '[]'::jsonb)
  );
end;
$$;

grant execute on function public.record_cost_event(text, text, numeric, jsonb) to authenticated, anon;
grant execute on function public.get_daily_spend_summary(date) to authenticated, anon;

