# BloodNorms — Environments & Infrastructure Matrix (ENVIRONMENTS.md)

**Role:** Principal DevOps & Infrastructure Architect  
**Scope:** Client Apps, Voice Gateway, Edge Functions, Database Core  
**Version:** 1.0.0

---

## 1. Environments Overview

| Dimension | Local (`development`) | Staging (`staging`) | Production (`production`) |
|---|---|---|---|
| **Purpose** | Offline dev, unit tests, load tests | E2E verification, partner testing | Real Indian emergency response |
| **Flutter Web Host** | `http://localhost:3000` | `https://staging.bloodnorms.org` | `https://bloodnorms.org` |
| **Voice Gateway URL** | `ws://localhost:8080/twilio/stream` | `wss://voice-stage.bloodnorms.org/twilio/stream` | `wss://voice.bloodnorms.org/twilio/stream` |
| **Voice Gateway Runtime** | Node.js 22 / Docker Compose | Google Cloud Run (1 instance) | Google Cloud Run (Auto: 2–20 instances) |
| **Database** | Local PostGIS / Docker | Supabase Staging Project | Supabase Multi-AZ PostgreSQL 15 |
| **Telephony** | Synthetic Mock Audio Stream | Twilio Test Credentials | Twilio Production Telecom Carrier |
| **Speech Engine** | `MockSpeechProvider` | Gemini Live Test Project | Google Cloud Vertex / Gemini Live Pro |
| **WhatsApp API** | Console / Mock Webhook | Meta Cloud API Test Number | Meta Verified Business Account |

---

## 2. Secrets Management & Vault Isolation

1. **Client Build Rule:** Flutter binary assets (`assets/.env`) must NEVER receive server secrets. Only public anon keys and OSM parameters are bundled.
2. **Local Environment:** Root `.env` (strictly Git-ignored).
3. **Staging & Production:**
   - Secrets managed via **Google Secret Manager**:
     - `VOICE_GATEWAY_SECRET`
     - `GEMINI_API_KEY`
     - `SUPABASE_SERVICE_ROLE_KEY`
     - `WHATSAPP_TOKEN`
   - Injected into Cloud Run containers via environment variable secret references at boot time.
