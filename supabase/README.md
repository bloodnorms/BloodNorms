# BloodNorms — Supabase Backend & Database Architecture

## Overview

BloodNorms uses Supabase (PostgreSQL 15 + PostGIS) as its real-time, zero-cold-start backend. The schema enforces strict privacy controls (DPDP compliance, irreversible health question hashing, immutable audit logs) and spatial proximity querying using PostGIS `ST_DWithin` functions.

---

## Directory Structure

```
supabase/
├─ migrations/                       # 17 sequential forward-only migrations
│  ├─ 0001_init.sql                 # Baseline schema: donors, requests, banks
│  ├─ 0002_cron.sql                 # Automated pg_cron background maintenance
│  ├─ 0003_storage.sql              # Supabase storage buckets & policies
│  ├─ 0004_inbound.sql              # Inbound IVR & WhatsApp session states
│  ├─ 0005_bank_console.sql         # Blood bank stock & staff management
│  ├─ 0006_roles.sql                # RBAC roles and permissions
│  ├─ 0007_milestones_and_notifications.sql # Gamification badges & in-app alerts
│  ├─ 0008_admin_expansion_am0.sql  # Master built-in admin roles & feature flags
│  ├─ 0009_admin_am1_approvals.sql  # Four-eyes governance & maker-checker rules
│  ├─ 0010_admin_am2_maintenance.sql # Scoped maintenance windows
│  ├─ 0011_admin_am3_exports.sql    # Masked data exports & CSV injection shields
│  ├─ 0012_admin_am4_ledgers_and_costs.sql # INR telecom cost attribution ledger
│  ├─ 0013_admin_am5_operations_desks.sql  # Requester fraud profiles & needs-human
│  ├─ 0014_admin_am6_am7_am8_expansion.sql # Verified hospitals GPS registry & AI studio
│  ├─ 0015_admin_am9_am10_am11.sql  # Clinical safety incidents & DPDP compliance
│  ├─ 0016_geo_targeted_broadcasts.sql # Regional broadcasts & suppression breakdown
│  └─ 0017_location_aware_camps_and_preferences.sql # Multi-location camps & travel radius
├─ functions/                       # Deno TypeScript Edge Functions
│  ├─ _shared/                      # Shared CORS, types, and clients
│  ├─ engine-tick/                  # 20-second matching loop (rings, waves, gates)
│  ├─ twilio-voice/                 # Inbound IVR & Media Stream bridge
│  └─ whatsapp-webhook/             # Meta WhatsApp Cloud API webhook router
├─ 00_master_schema.sql             # Consolidated bootstrap schema
└─ README.md                        # This document
```

---

## Edge Functions Summary

### 1. `engine-tick`
- **Trigger:** Scheduled every 20 seconds via `pg_cron` or external scheduler.
- **Role:** Distributed lease-based request processor. Advances concentric search rings (0.5 km to 100 km), gates at 70/90/100 km, contacts 3x needed units per wave, transitions to `enough_donors` or `exhausted`.

### 2. `twilio-voice`
- **Trigger:** Webhook from Twilio Voice when an emergency caller dials in.
- **Role:** Trilingual IVR (Telugu, Hindi, English). If `voice_mode` is `"ai"`, streams audio to the Cloud Run Voice Gateway via Twilio Media Streams.

### 3. `whatsapp-webhook`
- **Trigger:** Webhook from Meta WhatsApp Cloud API.
- **Role:** Handles inbound chat messages, language selection, blood group confirmation, camp RSVPs, and immediate opt-out processing on "STOP" / "ఆపండి" / "रोकें".

---

## Hard Privacy & Security Rules

1. **Immutable Audit Logs:** The `public.audit_logs` table has a database trigger `trg_audit_logs_immutable` that rejects any `UPDATE` or `DELETE` with SQLSTATE `42501`.
2. **Four-Eyes Governance:** Mutation operations requiring two-party approval strictly enforce `checker_id <> maker_id`.
3. **Health Questionnaire Privacy:** Donor medical responses are encrypted and never exposed in admin queries or CSV exports.
4. **Formula Injection Shield:** All exported spreadsheet cells neutralize `=`, `+`, `-`, and `@` prefixes with a leading apostrophe.

---

## Local Development & Deployment

```bash
# Link project
supabase link --project-ref <your-project-ref>

# Apply pending migrations
supabase db push

# Deploy edge functions
supabase functions deploy engine-tick
supabase functions deploy twilio-voice
supabase functions deploy whatsapp-webhook
```

