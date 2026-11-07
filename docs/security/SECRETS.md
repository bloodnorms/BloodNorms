# BloodNorms — Secrets Classification & Key Management Policy

**Policy Document:** SEC-POL-001  
**Classification:** Internal Engineering Guidelines  
**Audience:** All Core Developers, DevOps Engineers, and AI Agents

---

## 1. Secrets Inventory & Classification Matrix

| Secret Identifier | Classification | Permitted Location | Forbidden Locations | Rotation Cadence |
|---|---|---|---|---|
| `SUPABASE_ANON_KEY` | **Public Client Key** | `assets/.env`, Client Bundle, Web JS | Public GitHub READMEs | Annual |
| `SUPABASE_PUBLISHABLE_KEY` | **Public Client Key** | `assets/.env`, Client Bundle | Public GitHub READMEs | Annual |
| `SUPABASE_SERVICE_ROLE_KEY` | **Tier 1 Critical Secret** | Root `.env` (Server only), Deployment Vault | `assets/.env`, Git commits, Client code | 90 Days |
| `SUPABASE_JWT_SECRET` | **Tier 1 Critical Secret** | Root `.env` (Server only), Supabase Vault | `assets/.env`, Git commits, Client code | 180 Days |
| `GEMINI_API_KEY` | **Tier 1 Critical Secret** | Voice Gateway Environment, Cloud Run Secrets | `assets/.env`, Client code, Logs | 90 Days |
| `WHATSAPP_ACCESS_TOKEN` | **Tier 2 Secret** | Root `.env`, Admin Console Encrypted Store | `assets/.env`, Git commits | 60 Days (System User Token) |
| `VOICE_GATEWAY_SECRET` | **Tier 2 Secret** | Voice Gateway Env, Twilio Webhook Param | Public repositories | 90 Days |
| `ADMIN_CONSOLE_PIN` | **Operational Token** | SharedPreferences (Local device only) | Database tables, Network headers | User-managed |

---

## 2. Hard Security Rules

1. **Client Isolation:**
   `assets/.env` is compiled into the Flutter application binary. It must NEVER contain any key with `SERVICE_ROLE`, `SECRET`, `JWT`, or server-side admin privileges.
2. **Git Exclusion:**
   Both root `.env` and `assets/.env` are strictly excluded in `.gitignore`. Developers must initialize local environments from `.env.example` and `assets/.env.example`.
3. **No Secrets in Logs:**
   Logger adapters in Flutter (`debugPrint`) and Node.js (`pino`) must mask or omit tokens, passwords, and webhook authentication headers.
4. **Key Rotation Runbook:**
   When rotating Supabase service keys:
   - Generate new key in Supabase Dashboard (Settings → API).
   - Update Secret Manager in Cloud Run / deployment orchestrator.
   - Verify zero downtime via `/health` endpoint.
   - Revoke previous key.
