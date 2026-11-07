# Runbook: Emergency Voice Gateway Outage (voice_gateway_outage.md)

**Severity:** P1 — CRITICAL  
**Target SLA:** Triage in < 5 mins; Mitigate in < 10 mins  
**Trigger:** Voice Gateway `/healthz` returning non-200 or connection refused  

---

## 1. Immediate Impact
Inbound callers dialing the emergency helpline (+91 883 247 1234) cannot establish real-time audio streams with the Gemini AI agent.

---

## 2. Immediate Mitigation (Fallback to Keypad IVR)
If the Voice Gateway container is crashing or unreachable, switch the platform to automated keypad IVR mode immediately so callers can still request blood via keypad numbers:

```sql
-- Execute in Supabase SQL editor or via Admin Console
update public.app_settings
set value = jsonb_set(value, '{mode}', '"ivr"')
where key = 'voice_mode';
```
*Result: Twilio inbound webhook immediately serves TwiML `<Gather>` instead of attempting WebSocket streaming.*

---

## 3. Investigation & Diagnostic Steps

1. **Check Cloud Run Service Status:**
   ```bash
   gcloud run services describe bloodnorms-voice-gateway --region asia-south1
   ```
2. **Inspect Container Logs for Crash Traces:**
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=bloodnorms-voice-gateway AND severity>=ERROR" --limit 50
   ```
3. **Verify Upstream Secret Configuration:**
   Ensure `GEMINI_API_KEY` and `VOICE_GATEWAY_SECRET` in Secret Manager are active and not revoked.

---

## 4. Recovery & Verification

1. Once the container is healthy (`curl -i https://voice.bloodnorms.org/healthz` returns 200 OK):
2. Switch `voice_mode` back to `'ai'`:
   ```sql
   update public.app_settings
   set value = jsonb_set(value, '{mode}', '"ai"')
   where key = 'voice_mode';
   ```
3. Perform a test call to helpline to confirm bidirectional audio and Sulafat voice playback.
