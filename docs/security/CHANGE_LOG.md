# BloodNorms — Security Hardening Change Log

All notable security enhancements, architectural boundaries, and vulnerability mitigations are recorded here.

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
