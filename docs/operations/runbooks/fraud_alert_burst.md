# Runbook: Fraud, Abuse & Mass Dispatch Burst (fraud_alert_burst.md)

**Severity:** P2 — MAJOR  
**Target SLA:** Mitigate in < 15 mins  
**Trigger:** `TelephonyBudgetSurge` alert or > 500 WhatsApp alerts in 10 minutes  

---

## 1. Immediate Impact
Potential automated script or malicious actor creating fake emergency blood requests, exhausting platform budget and spamming volunteer donors.

---

## 2. Immediate Diagnostic Steps

1. **Query Top Dispatching Users in Last Hour:**
   ```sql
   select r.requester_phone, count(*) as req_count
   from public.requests r
   where r.created_at > now() - interval '1 hour'
   group by r.requester_phone
   order by req_count desc
   limit 10;
   ```

2. **Query Usage Events Surge by Service:**
   ```sql
   select service, sum(estimated_cost_inr) as spend_inr, count(*) as events
   from public.usage_events
   where created_at > now() - interval '1 hour'
   group by service;
   ```

---

## 3. Mitigation Actions

### Action A: Block Malicious Requester Number
```sql
update public.requester_profiles
set is_blocked = true, abuse_flag = true, block_reason = 'automated_spam_burst'
where phone_number = '<SUSPECT_PHONE>';
```

### Action B: Enforce Emergency Spending Cap
Activate the progressive cost guardrail flag:
```sql
update public.app_settings
set value = jsonb_set(value, '{enabled}', 'true')
where key = 'cost_guardrails';
```
