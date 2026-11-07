# Runbook: Speech AI Latency & Quota Degradation (high_latency_gemini.md)

**Severity:** P2 — MAJOR  
**Target SLA:** Triage in < 15 mins; Mitigate in < 20 mins  
**Trigger:** Voice call latency P95 > 500ms or error rate > 5%  

---

## 1. Immediate Impact
Callers experience delayed speech responses, conversational overlap, or dropped turns when speaking with the helpline assistant.

---

## 2. Diagnostic Steps

1. **Check Google Cloud Quota Utilization:**
   - Navigate to Google Cloud Console -> **APIs & Services** -> **Gemini Live API**.
   - Review **Audio Tokens per Minute (TPM)** and **Requests per Minute (RPM)**.
   - If quota is reaching 100%, request an emergency quota increase.

2. **Check Interruption Events in Gateway Logs:**
   - Look for repeated `[CallSession] Speech provider error` in Voice Gateway logs.

---

## 3. Mitigation: Graceful Degradation

If the Gemini speech model is experiencing regional latency or upstream Google outages:

```sql
-- Switch voice helpline to automated Keypad IVR mode
update public.app_settings
set value = jsonb_set(value, '{mode}', '"ivr"')
where key = 'voice_mode';
```

Callers immediately transition to pressing `1` for Telugu, `2` for Hindi, `3` for English with zero speech model dependency.
