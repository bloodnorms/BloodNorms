# BloodNorms — Security Policy & Operational Hardening

## Reporting Security Vulnerabilities

We take the security and privacy of emergency requesters, volunteer blood donors, and blood bank staff with the utmost seriousness.

If you discover a security vulnerability or leaked credential within this project:
- **Do NOT create a public GitHub issue.**
- Email the security team immediately at: `security@bloodnorms.org`
- Include a technical description of the vulnerability, steps to reproduce, and impact assessment.
- We will acknowledge receipt within 24 hours and coordinate responsible disclosure.

---

## 1. Secrets Handling & Credential Isolation

- **Client Binary Safety:**
  - The Flutter application bundle (`assets/.env`) must ONLY contain public, client-safe variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, OpenStreetMap URLs).
  - High-privilege secrets (`SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`, `WHATSAPP_ACCESS_TOKEN`, `GEMINI_API_KEY`) must NEVER be placed in `assets/.env`.
- **Git Repository Safeguards:**
  - `.env`, `.env.*`, and `assets/.env` are strictly excluded in `.gitignore`.
  - In the event of an accidental commit of a secret, the secret must be **rotated immediately at the provider console** before rewriting repository history.

---

## 2. Hard Privacy Boundaries (§0.3 TRD / PRD)

1. **Donor Medical Confidentiality:**
   - Pre-donation health questionnaire answers are stored in an encrypted/hashed format and are never exposed via admin views, staff dashboards, or data exports.
2. **Inbound Call Audio & Transcripts:**
   - Inbound telephony audio streamed between Twilio Media Streams and Gemini Live is ephemeral. Neither raw audio nor speech-to-text transcripts are persisted in database tables or logs.
3. **Data Export Sanitization:**
   - All spreadsheet exports (CSV) neutralize CSV Formula Injection by prepending `'` to cell values beginning with `=`, `+`, `-`, or `@`.
   - Tier 3 exports containing identifiable data require Four-Eyes approval and cryptographic watermarking.

---

## 3. Database Security & Governance

- **Immutable Audit Trail:**
  - All administrative mutations are recorded in `public.audit_logs`.
  - The PostgreSQL trigger `trg_audit_logs_immutable` raises SQLSTATE `42501` on any attempt to execute `UPDATE` or `DELETE`, guaranteeing an append-only legal record.
- **Four-Eyes Maker-Checker Enforcement:**
  - High-impact operations (large geo-broadcasts, emergency killswitch, financial rate cards) require two distinct admin identities (`checker_id <> maker_id`).
- **Row Level Security (RLS):**
  - RLS is enabled on all tables containing user or donor records.
  - Donors can only view and mutate their own profile and availability records.

