# BloodNorms — Security Audit Findings & Remediation Log

**Audit Period:** November 2026  
**Auditor:** Principal Security Engineer & Structure Architect  
**Scope:** Complete BloodNorms monorepo (`lib/`, `voice-gateway/`, `supabase/`, `assets/`, `docs/`)

---

## Executive Summary

| Finding ID | Severity | CWE | Vulnerability Title | Status |
|---|---|---|---|---|
| **BUG-001** | **CRITICAL** | CWE-798 | Hardcoded Server Secrets in Client Binary (`assets/.env`) & Tracked in Git | **REMEDIATED** |
| **BUG-002** | **MEDIUM** | CWE-1236 | Potential CSV Formula Injection in Spreadsheet Exports | **REMEDIATED** |
| **BUG-003** | **HIGH** | CWE-306 | Unauthenticated & Uncapped WebSocket Upgrades in Voice Gateway | **REMEDIATED** |
| **BUG-004** | **MEDIUM** | CWE-284 | Missing Explicit Concurrency Limits on Voice Gateway Media Streams | **REMEDIATED** |

---

## Detailed Findings & Remediations

### BUG-001: Server Secrets in Client Assets & Git Tracking
- **Vulnerability:** `assets/.env` was tracked in Git and contained live backend secrets (`SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`, `WHATSAPP_ACCESS_TOKEN`, `GEMINI_API_KEY`). Because Flutter assets are bundled directly into the compiled APK/web binary, these keys were extractable by untrusted clients.
- **Affected File:** `assets/.env`, `.env`
- **CVSS Score:** 9.1 (Critical)
- **Remediation Applied:**
  1. Removed `assets/.env` and `.env` from Git tracking (`git rm --cached`).
  2. Verified `.gitignore` pattern matching to prevent re-addition.
  3. Replaced `assets/.env` content with a sanitized client configuration template containing only public anon keys and OSM parameters.
  4. Added `assets/.env.example` as a clean, public documentation guide.

### BUG-002: CSV Formula Injection (CWE-1236)
- **Vulnerability:** Unsanitized user inputs (e.g. donor names, addresses, hospital designations) starting with `=`, `+`, `-`, or `@` could trigger dynamic command execution (DDE) when opened by administrators in spreadsheet software such as Microsoft Excel or LibreOffice Calc.
- **Affected File:** `lib/features/admin_console/widgets/data_exports_view.dart`, `lib/features/admin_console/services/admin_export_service.dart`
- **CVSS Score:** 6.5 (Medium)
- **Remediation Applied:**
  1. Implemented `sanitizeCsvCell` in `AdminExportService` and `SupabaseService`.
  2. Applied automated prefixing of single quote (`'`) to all cell values initiating with trigger characters (`=`, `+`, `-`, `@`).
  3. Integrated `_buildSanitizedCsv` into `DataExportsView` clipboard and download export flows.
  4. Verified with automated regression tests in `test/admin_am3_am4_test.dart`.

### BUG-003: Voice Gateway WebSocket Authentication
- **Vulnerability:** The Voice Gateway WebSocket endpoint `/twilio/stream` allowed upgrade requests without validating caller credentials when default tokens were present, exposing the Gemini Live speech pipeline to unauthorized media injection.
- **Affected File:** `voice-gateway/src/server/http-server.ts`
- **CVSS Score:** 7.5 (High)
- **Remediation Applied:**
  1. Enforced strict token validation on HTTP upgrade via `?secret=` URL parameter or `Authorization: Bearer` header.
  2. Configured mandatory rejection in production environments when secrets are unconfigured.

### BUG-004: Voice Gateway Concurrency & Payload Guards
- **Vulnerability:** Absence of concurrency limits and payload bounds on WebSocket connections could allow denial of service via memory exhaustion or socket flooding.
- **Affected File:** `voice-gateway/src/server/http-server.ts`, `voice-gateway/src/sessions/call-session.ts`
- **CVSS Score:** 5.3 (Medium)
- **Remediation Applied:**
  1. Implemented `MAX_CONCURRENT_CALLS = 50` cap returning `503 Service Unavailable` when saturated.
  2. Enforced `maxPayload: 65536` (64 KB) on WebSocket server.
  3. Added payload size checks and event structure validation in `CallSession`.
