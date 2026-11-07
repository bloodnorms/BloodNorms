# BloodNorms — Security Audit Findings & Remediation Log

**Audit Period:** November 2026  
**Auditor:** Principal Backend & Database Architect, Application Security Engineer  
**Scope:** Complete BloodNorms stack (`lib/`, `voice-gateway/`, `supabase/`, `assets/`, `docs/`)

---

## Executive Summary

| Finding ID | Severity | CWE | Vulnerability Title | Status |
|---|---|---|---|---|
| **BUG-001** | **CRITICAL** | CWE-798 | Hardcoded Server Secrets in Client Binary (`assets/.env`) & Tracked in Git | **REMEDIATED** |
| **BUG-002** | **MEDIUM** | CWE-1236 | Potential CSV Formula Injection in Spreadsheet Exports | **REMEDIATED** |
| **BUG-003** | **HIGH** | CWE-306 | Unauthenticated & Uncapped WebSocket Upgrades in Voice Gateway | **REMEDIATED** |
| **BUG-004** | **MEDIUM** | CWE-284 | Missing Explicit Concurrency Limits on Voice Gateway Media Streams | **REMEDIATED** |
| **BUG-005** | **HIGH** | CWE-284 | Over-Permissive RLS Policies on Sensitive Operational Tables | **REMEDIATED** |
| **BUG-006** | **HIGH** | CWE-862 | Anonymous Execution of State-Mutating RPC Stored Procedures | **REMEDIATED** |
| **BUG-007** | **MEDIUM** | CWE-426 | Role-Mutable `search_path` on Database Functions | **REMEDIATED** |
| **BUG-008** | **MEDIUM** | CWE-284 | Unrestricted Public Overwrite Policy on Storage Buckets | **REMEDIATED** |
| **BUG-009** | **LOW** | CWE-400 | Unindexed Foreign Key Constraints Causing Query Exhaustion | **REMEDIATED** |

---

## Detailed Findings & Remediations

### BUG-001: Server Secrets in Client Assets & Git Tracking
- **Vulnerability:** `assets/.env` was tracked in Git and contained live backend secrets (`SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`, `WHATSAPP_ACCESS_TOKEN`, `GEMINI_API_KEY`). Because Flutter assets are bundled directly into the compiled binary, these keys were extractable by untrusted clients.
- **Affected File:** `assets/.env`, `.env`
- **CVSS Score:** 9.1 (Critical)
- **Remediation Applied:**
  1. Removed `assets/.env` and `.env` from Git tracking (`git rm --cached`).
  2. Verified `.gitignore` pattern matching to prevent re-addition.
  3. Replaced `assets/.env` content with a sanitized client configuration template containing only public anon keys and OSM parameters.
  4. Added `assets/.env.example` as a clean, public documentation guide.

### BUG-002: CSV Formula Injection (CWE-1236)
- **Vulnerability:** Unsanitized user inputs starting with `=`, `+`, `-`, or `@` could trigger dynamic command execution (DDE) when opened by administrators in spreadsheet software.
- **Affected File:** `lib/features/admin_console/services/admin_export_service.dart`
- **CVSS Score:** 6.5 (Medium)
- **Remediation Applied:** Implemented single-quote prefix neutralization in `sanitizeCsvCell` across all export flows.

### BUG-003: Voice Gateway WebSocket Authentication
- **Vulnerability:** The Voice Gateway WebSocket endpoint `/twilio/stream` allowed upgrade requests without validating caller credentials when default tokens were present.
- **Affected File:** `voice-gateway/src/server/http-server.ts`
- **CVSS Score:** 7.5 (High)
- **Remediation Applied:** Enforced mandatory token validation on HTTP upgrade via `?secret=` or `Authorization: Bearer`.

### BUG-004: Voice Gateway Concurrency & Payload Guards
- **Vulnerability:** Absence of concurrency limits and payload bounds on WebSocket connections could allow denial of service via memory exhaustion.
- **Affected File:** `voice-gateway/src/server/http-server.ts`, `voice-gateway/src/sessions/call-session.ts`
- **CVSS Score:** 5.3 (Medium)
- **Remediation Applied:** Added `MAX_CONCURRENT_CALLS = 50` cap and `maxPayload: 65536` (64 KB) frame size limits.

### BUG-005: Over-Permissive RLS Policies on Sensitive Operational Tables
- **Vulnerability:** Operational tables (`audit_logs`, `voice_calls`, `inbound_sessions`, `message_events`, `request_access_keys`) had permissive `ALL` policies with `USING (true) WITH CHECK (true)` granted to the `public` role, permitting anonymous users to inspect and modify administrative audit logs and telephony call records.
- **Affected Tables:** `audit_logs`, `voice_calls`, `inbound_sessions`, `message_events`, `request_access_keys`
- **CVSS Score:** 8.2 (High)
- **Remediation Applied:** Dropped broad `_all` policies in migration `0021_harden_performance_and_security.sql`. Replaced with least-privilege policies: SELECT restricted strictly to authenticated administrators (`is_admin()`), INSERT scoped to authenticated services.

### BUG-006: Anonymous Execution of State-Mutating RPC Procedures
- **Vulnerability:** PostgreSQL grants `EXECUTE` to `PUBLIC` by default on all functions. Mutating routines (`bank_set_stock`, `bank_confirm_donation`, `dispatch_request_to_donors`, `find_nearby_eligible_donors`, `is_admin`) were executable by unauthenticated anonymous callers via PostgREST RPC endpoints.
- **Affected Procedures:** `public.bank_set_stock`, `public.bank_confirm_donation`, `public.dispatch_request_to_donors`, `public.find_nearby_eligible_donors`, `public.is_admin`
- **CVSS Score:** 8.6 (High)
- **Remediation Applied:** Executed `REVOKE EXECUTE ... FROM PUBLIC, anon;` and granted access strictly to `authenticated` and `service_role`. Converted public read procedures to `SECURITY INVOKER`.

### BUG-007: Role-Mutable `search_path` on Database Functions
- **Vulnerability:** Stored procedures `calculate_distance_km` and `nearest_banks` lacked an explicit `search_path` setting, allowing potential schema-poisoning attacks when executed by privileged roles.
- **Affected Procedures:** `public.calculate_distance_km`, `public.nearest_banks`
- **CVSS Score:** 6.1 (Medium)
- **Remediation Applied:** Added `SET search_path = 'public'` to procedure declarations in migration `0021_harden_performance_and_security.sql`.

### BUG-008: Unrestricted Public Overwrite Policy on Storage Buckets
- **Vulnerability:** `storage.objects` had `storage_public_update` enabled with `USING (true)`, allowing unauthenticated callers to overwrite existing donation slips and identification proofs.
- **Affected Buckets:** `slips`, `proofs`
- **CVSS Score:** 6.3 (Medium)
- **Remediation Applied:** Dropped `storage_public_update`. Enforced strict insert scoping `WITH CHECK (bucket_id IN ('slips', 'proofs'))`.

### BUG-009: Unindexed Foreign Key Constraints
- **Vulnerability:** 12 foreign keys lacked supporting B-tree covering indexes, causing sequential scans on parent deletions and joins during emergency dispatching.
- **Affected Constraints:** 12 foreign keys across `bank_camps`, `bank_staff`, `donations`, `camp_signups`, `request_contacts`, `inbound_sessions`, `request_access_keys`.
- **CVSS Score:** 3.1 (Low)
- **Remediation Applied:** Created 12 covering B-tree indexes in migration `0021_harden_performance_and_security.sql`.
