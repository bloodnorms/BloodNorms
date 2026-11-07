# BloodNorms — Supabase Backend & Database Architecture

## 1. Overview

BloodNorms uses Supabase (PostgreSQL 17 + PostGIS) as its real-time, zero-cold-start backend. The schema enforces strict privacy controls (DPDP compliance, immutable audit logs) and spatial proximity querying using PostGIS `ST_DWithin` functions.

---

## 2. Directory Structure

```
supabase/
├─ migrations/                       # Sequential forward-only migrations
│  ├─ 0001_init.sql                 # Baseline schema: donors, requests, banks
│  ├─ 0002_cron.sql                 # Automated pg_cron background maintenance
│  ├─ 0003_storage.sql              # Supabase storage buckets & policies
│  ├─ 0004_inbound.sql              # Inbound IVR & WhatsApp session states
│  ├─ 0005_bank_console.sql         # Blood bank stock & staff management
│  ├─ 0006_roles.sql                # RBAC roles and permissions
│  ├─ 0007_milestones_and_notifications.sql # Gamification badges & in-app alerts
│  ├─ ...                           # 0008-0020 Enterprise expansion milestones
│  └─ 0021_harden_performance_and_security.sql # Indexes, RLS, & procedure hardening
├─ functions/                       # Deno TypeScript Edge Functions
│  ├─ _shared/                      # Shared CORS, types, and clients
│  ├─ engine-tick/                  # 20-second matching loop (rings, waves, gates)
│  ├─ twilio-voice/                 # Inbound IVR & Media Stream bridge
│  └─ whatsapp-webhook/             # Meta WhatsApp Cloud API webhook router
├─ 00_master_schema.sql             # Consolidated bootstrap schema
└─ README.md                        # This document
```

---

## 3. Local Development Setup

### Prerequisites
- Docker Desktop (Running)
- Supabase CLI (`brew install supabase/tap/supabase` or `npm install -g supabase`)
- Deno v1.37+ (for local Edge Functions debugging)

### Commands
```bash
# Initialize and start local Supabase stack
supabase init
supabase start

# Check status of local containers
supabase status

# Reset local database to fresh state and apply all migrations
supabase db reset

# Create a new sequential migration
supabase migration new <descriptive_name>
```

---

## 4. Model Context Protocol (MCP) Safe Profiles

Create `.mcp.json` in your local workspace root (never commit personal access tokens):

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server@latest"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "sbp_your_scoped_personal_access_token",
        "SUPABASE_PROJECT_REF": "ixrborkhofxlxbedpang"
      }
    }
  }
}
```

> [!IMPORTANT]
> The Supabase MCP server is exclusively a development cluster tool. Connecting it to a production project ref is strictly prohibited by engineering policy. See `docs/backend/MCP_USAGE.md`.

---

## 5. Edge Functions Deployment & Verification

```bash
# Test functions locally
supabase functions serve engine-tick --no-verify-jwt
supabase functions serve twilio-voice --no-verify-jwt
supabase functions serve whatsapp-webhook --no-verify-jwt

# Deploy to development cluster
supabase functions deploy engine-tick
supabase functions deploy twilio-voice
supabase functions deploy whatsapp-webhook

# Configure secrets in Supabase Cloud
supabase secrets set \
  GEMINI_API_KEY=your_key \
  WHATSAPP_TOKEN=your_token \
  VOICE_GATEWAY_URL=wss://voice.bloodnorms.org/twilio/stream
```

---

## 6. Migration Governance Rules

1. **Sequential Naming:** Migrations follow `00XX_<descriptive_name>.sql`.
2. **Forward-Only & Idempotent:** Always use `CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`, and `DROP POLICY IF EXISTS`.
3. **Quality Gates:** Before merging any migration, execute:
   ```bash
   flutter test
   supabase db advisors --type security
   supabase db advisors --type performance
   ```
