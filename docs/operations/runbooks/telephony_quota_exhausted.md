# Runbook: Telephony Account Credit Exhaustion (telephony_quota_exhausted.md)

**Severity:** P1 — CRITICAL  
**Target SLA:** Mitigate in < 15 mins  
**Trigger:** Twilio API returning HTTP 402 or balance < ₹5,000 INR  

---

## 1. Immediate Impact
Telephony carrier rejects inbound emergency calls before reaching Supabase webhooks or the Voice Gateway.

---

## 2. Immediate Diagnostic & Remediation

1. **Log in to Twilio Admin Console:**
   - URL: `https://console.twilio.com`
   - Navigate to **Billing** -> **Overview**.
   - Check current balance in USD/INR.

2. **Trigger Emergency Top-Up:**
   - Execute manual payment of $250 / ₹20,000 INR via corporate credit card.
   - Verify **Auto-Recharge** is enabled with threshold set to minimum $100.

3. **Check Phone Number Inbound Routing:**
   - Ensure +91 883 247 1234 webhook is correctly configured to:
     `https://<project-ref>.supabase.co/functions/v1/twilio-voice`
