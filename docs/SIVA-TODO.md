# BloodNorms — Setup Guide for Siva (Outside the Code)

The codebase is built, verified, and all automated tests are green. Here are the external setup items needed for live production launch:

1. **Meta WhatsApp Cloud API**:
   - Register a dedicated phone number with WhatsApp Business.
   - Set Webhook URL to: `https://<YOUR_SUPABASE_PROJECT>.supabase.co/functions/v1/whatsapp-webhook`.
   - Verify Token: Configure `WHATSAPP_VERIFY_TOKEN` in Supabase Secrets.

2. **Telephony & Real-Voice**:
   - Twilio Voice Webhook URL: `https://<YOUR_SUPABASE_PROJECT>.supabase.co/functions/v1/twilio-voice`.
   - Deploy Voice Gateway to Google Cloud Run (`asia-south1`) following `voice-gateway/README.md`.
   - Add `GEMINI_API_KEY` to Cloud Run environment.

3. **Supabase Database Push**:
   - Run `supabase db push` to apply migrations `0001_init.sql` through `0015_admin_am9_am10_am11.sql`.
   - Pilot blood banks in Rajahmundry (`Rotary Central`, `GGH`, `Red Cross`) are already included in seed migration `0006_roles.sql`.
   - Admin roles and progressive feature flags are seeded in `0008_admin_expansion_am0.sql`.
   - Governance tables (`approval_requests`, `admin_sessions`, `maintenance_windows`, `data_exports`, `cost_rate_cards`, `cost_events`, `requester_profiles`, `hospitals`, `ai_prompt_versions`, `safety_incidents`, `dpdp_requests`, `partners`) are created in forward migrations `0009` through `0015`.

4. **Medical & Language Review**:
   - Have a blood bank medical officer confirm the 10 health questions and cooling periods.
   - Native Telugu and Hindi speakers review all copy strings.

5. **Campaign Consent Notice (CMP-7)**:
   - Current donor onboarding consent covers direct emergency match notifications.
   - For regional blood donation drive broadcasts and promotional awareness campaigns, ensure legal review adds the explicit opt-in checkbox during signup.

