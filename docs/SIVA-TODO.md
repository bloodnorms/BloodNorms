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
   - Run `supabase db push` to apply migrations `0001_init.sql` through `0006_roles.sql`.
   - Pilot blood banks in Rajahmundry (`Rotary Central`, `GGH`, `Red Cross`) are already included in seed migration `0006_roles.sql`.

4. **Medical & Language Review**:
   - Have a blood bank medical officer confirm the 10 health questions and cooling periods.
   - Native Telugu and Hindi speakers review all copy strings.

