# BloodNorms — Security Hardening Change Log

All notable security enhancements, architectural boundaries, and vulnerability mitigations are recorded here.

---

## [2.1.0] - November 2026 - Supabase Backend & Database Hardening

### Added
- **Sequential Migration `0021_harden_performance_and_security.sql`:**
  - 12 covering B-tree indexes on foreign key constraints (`bank_camps`, `bank_staff`, `donations`, `camp_signups`, `request_contacts`, `inbound_sessions`, `request_access_keys`).
  - Scoped storage object upload policy for `slips` and `proofs` buckets.
  - Dedicated least-privilege RLS policies on `audit_logs`, `voice_calls`, `inbound_sessions`, `message_events`, and `request_access_keys`.
- **Database Documentation Suite:**
  - `docs/backend/CURRENT_STATE.md`: Full audit of PostgreSQL 17 cluster, schemas, tables, and advisors.
  - `docs/backend/IMPROVEMENT_PLAN.md`: Ranked Tier 1 and Tier 2 hardening roadmap.
  - `docs/backend/SCHEMA.md`: Mermaid entity-relationship diagram and table technical specifications.
  - `docs/security/ACCESS_MATRIX.md`: Live table vs role RBAC matrix.
  - `docs/security/AUTH_CONFIG.md`: GoTrue token lifecycles, session hygiene, and dashboard checklist.
  - `docs/backend/MCP_USAGE.md`: Safe developer operating protocols and prompt injection defenses.
  - `docs/backend/FINAL_REPORT.md`: Comprehensive executive report.

### Changed
- **Function Privileges:** Revoked anonymous execution from mutating routines (`bank_set_stock`, `bank_confirm_donation`, `dispatch_request_to_donors`, `find_nearby_eligible_donors`, `is_admin`); granted strictly to `authenticated` and `service_role`.
- **Security Invoker:** Converted public read routines (`find_nearby_banks_with_stock`, `nearest_banks`) from `SECURITY DEFINER` to `SECURITY INVOKER`.
- **Search Path Hardening:** Explicitly pinned `SET search_path = 'public'` on all custom stored procedures.
- **RLS Policy Deduplication:** Dropped conflicting `bank_stock_modify_all` on `bank_stock`, resolving database linter warnings.
- **Storage Protection:** Dropped unauthenticated `storage_public_update`, preventing file tampering in S3 storage buckets.

### Verified
- Supabase performance advisor `unindexed_foreign_keys` dropped from 12 findings to 0.
- Supabase performance advisor `multiple_permissive_policies` dropped from 5 findings to 0.
- Supabase security advisor `function_search_path_mutable` dropped from 2 findings to 0.
- All 98 Flutter test suites passing (`00:19 +98: All tests passed!`).
- Zero compilation errors and zero warnings in `flutter analyze`.
- All 13/13 Node.js Voice Gateway unit and integration tests passing.

---

## [2.0.0] - November 2026 - Security Engineering & Monorepo Hardening

### Added
- **Authenticated WebSocket Upgrades:** Enforced bearer/query token validation on Voice Gateway `/twilio/stream` media stream endpoints.
- **Concurrency Protections:** Added active call limit (`MAX_CONCURRENT_CALLS = 50`) and 64 KB payload bounds on voice gateway WebSockets.
- **CSV Formula Sanitization:** Automated neutralization of spreadsheet command injection (`=`, `+`, `-`, `@`) in `AdminExportService` and `DataExportsView`.
- **Environment Isolation:** Added `assets/.env.example` safe client template and added strict Git exclusion for all `.env` variants.
- **Security Documentation Suite:** Authoring of `THREAT_MODEL.md`, `FINDINGS.md`, `SECRETS.md`, `CHECKLIST.md`, and `CHANGE_LOG.md`.

### Changed
- **Sanitized Client Assets:** Completely scrubbed `assets/.env` of service role keys, JWT secrets, Gemini API keys, and Meta access tokens.
- **Untracked Sensitive Files:** Removed tracked `.env` and `assets/.env` from Git repository tree.
- **Sanitized Health Endpoint:** `/health` endpoint on Voice Gateway now emits structured status, uptime, and call count without disclosing stack traces or host internals.

### Verified
- Zero leaked secrets across Git index.
- 77/77 regression and security tests passing.
- DPDP compliance boundaries verified across admin queries.
