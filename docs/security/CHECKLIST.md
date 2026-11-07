# BloodNorms — Production Release Security Checklist

This checklist must be verified and signed off before releasing any production build of BloodNorms.

---

## 1. Credentials & Secrets Isolation
- [x] `assets/.env` contains **only** public keys (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, OSM endpoints).
- [x] No `SUPABASE_SERVICE_ROLE_KEY` or `SUPABASE_JWT_SECRET` exists in `assets/.env`.
- [x] No `GEMINI_API_KEY` exists in `assets/.env`.
- [x] No `.env` files are tracked in Git (`git status` and `git ls-files` report zero tracked `.env` files).
- [x] Server secrets are stored in secure deployment vaults (e.g. Google Secret Manager).

## 2. DPDP Act Privacy & Healthcare Boundaries
- [x] Pre-donation donor health questionnaires are completely unreadable and excluded from all admin views.
- [x] Telephony voice streams and transcripts are ephemeral (zero retention in database tables).
- [x] Distance queries use privacy bands (fuzzy masking) rather than exact donor GPS coordinates.
- [x] Data export requests are logged on the immutable ledger with SHA-256 watermarks.

## 3. Governance & Administrative Safety
- [x] High-impact mutations (broadcast reach > 200 donors, rate card modifications, Tier 3 exports) enforce Four-Eyes maker-checker separation (`checker_id != maker_id`).
- [x] Emergency platform killswitch is functional and tested.
- [x] All CSV export generators sanitize formula injection (`=`, `+`, `-`, `@`).
- [x] Database trigger unconditionally rejects `UPDATE` and `DELETE` on `audit_logs`.

## 4. Network & Microservice Hardening
- [x] Voice Gateway rejects unauthenticated WebSocket upgrade attempts.
- [x] Voice Gateway enforces max concurrency cap (50 concurrent calls) and max payload limit (64 KB).
- [x] Voice Gateway `/health` endpoint emits only sanitized status data.
- [x] Deno Edge Functions enforce CORS headers and JWT verification on private endpoints.

## 5. Verification Commands
```bash
# Static analysis
flutter analyze

# Full test suite
flutter test

# Voice gateway build
cd voice-gateway && npm run build
```
