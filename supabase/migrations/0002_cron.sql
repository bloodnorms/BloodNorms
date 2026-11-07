-- ============================================================================
-- BloodNorms | 0002_cron.sql
-- Periodic matching tick, request expiration, live-link expiry
-- ============================================================================

-- Function to claim requests for processing
create or replace function public.claim_requests_for_tick(p_limit int default 5, p_lease_seconds int default 20)
returns setof public.requests
language plpgsql security definer set search_path = public as $$
begin
  return query
  update public.requests
     set tick_lease_until = now() + make_interval(secs => p_lease_seconds)
   where id in (
     select id from public.requests
      where status in ('searching', 'waiting_requester')
        and (tick_lease_until is null or tick_lease_until < now())
        and (wave_expires_at is null or wave_expires_at <= now())
      order by case urgency when 'now' then 1 when 'within_6h' then 2 when 'within_24h' then 3 else 4 end,
               created_at asc
      limit p_limit
      for update skip locked
   )
   returning *;
end $$;

-- Expire old requests that passed needed_by + 6h
create or replace function public.expire_old_requests()
returns int
language plpgsql security definer set search_path = public as $$
declare
  v_count int;
begin
  with expired as (
    update public.requests
       set status = 'expired',
           closed_at = now(),
           close_reason = 'time_expired'
     where status in ('searching', 'waiting_requester', 'enough_donors')
       and needed_by < (now() - interval '6 hours')
     returning id
  )
  select count(*) into v_count from expired;

  -- Clean up rate limits older than 2 days
  delete from public.rate_limits where reset_at < (now() - interval '2 days');

  return v_count;
end $$;

