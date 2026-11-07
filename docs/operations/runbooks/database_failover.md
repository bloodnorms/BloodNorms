# Runbook: Database Lock Contention & Failover (database_failover.md)

**Severity:** P1 / P2  
**Target SLA:** Triage in < 5 mins; Mitigate in < 15 mins  
**Trigger:** `DatabaseSlowQueries` alert or PostgREST 504 gateway timeout  

---

## 1. Immediate Impact
Patient emergency requests cannot claim locks via `claim_requests_for_tick`; donor coordinates cannot be resolved.

---

## 2. Immediate Diagnostic Queries

Run the following in the Supabase SQL editor:

```sql
-- 1. Identify long-running transactions blocking other queries
select pid, now() - xact_start as duration, query, state
from pg_stat_activity
where state != 'idle' and now() - xact_start > interval '5 seconds'
order by duration desc;

-- 2. Find explicit table locks
select relation::regclass, mode, granted, pid
from pg_locks
where not granted;
```

---

## 3. Mitigation Actions

### Action A: Terminate Blocking Query
If an unindexed query or rogue migration is holding an exclusive table lock:
```sql
select pg_terminate_backend(<BLOCKING_PID>);
```

### Action B: Restart Connection Pooler (PgBouncer / Supavisor)
If connection slots are exhausted (`FATAL: remaining connection slots are reserved for non-replication superuser connections`):
1. In Supabase Dashboard: Navigate to **Database** -> **Connection Pooling**.
2. Click **Restart Pooler**.

### Action C: Standby Replica Failover
If the primary multi-AZ node suffered hardware failure, Supabase executes automated failover within 60 seconds. Verify that new primary accepts writes:
```sql
select pg_is_in_recovery(); -- Must return false
```
