# Security Findings & Vulnerability Audit Report

**Audit Date:** 2026-11-07  
**Evaluator:** Senior QA Lead & Security Researcher  
**Target:** BloodNorms Platform (Web App, Voice Gateway, Supabase)  
**Overall Risk Posture:** **CRITICAL RISK (IMMEDIATE ACTION REQUIRED)**  

---

## 1. Top Blocker Vulnerability

> [!CAUTION]
> ### SEC-VULN-01: Critical Secret Leak — Service Role Key and Master JWT Secret Packaged in Public Client Assets
> **Severity:** **BLOCKER (CVSS v3.1: 10.0 / CRITICAL)**  
> **CWE:** CWE-312 (Cleartext Storage of Sensitive Information) / CWE-522 (Insufficiently Protected Credentials)  
> **Affected Files:** `assets/.env` -> `build/web/assets/assets/.env`  
> **Public Exposure Route:** `GET http://<domain>/assets/assets/.env`  

#### A. Attack Vector & Proof of Concept
During static and automated browser audits, it was discovered that `pubspec.yaml` registers the entire `assets/` directory as client asset bundles:
```yaml
flutter:
  assets:
    - assets/
```
Because developers placed production/staging `.env` containing server-only secrets into `assets/.env`, Flutter's web compiler automatically copied this file directly into the public web root at `build/web/assets/assets/.env`.

Any anonymous internet attacker can issue a standard HTTP GET:
```bash
curl -i http://localhost:5000/assets/assets/.env
```
And retrieve HTTP 200 OK containing:
```env
SUPABASE_URL=https://ixrborkhofxlxbedpang.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi... # <--- CRITICAL DATABASE BYPASS KEY
SUPABASE_JWT_SECRET=...                  # <--- MASTER TOKEN FORGERY KEY
GEMINI_API_KEY=AIzaSy...                 # <--- UNRESTRICTED AI KEY
```

#### B. Impact
1. **Total Database Compromise:** With `SUPABASE_SERVICE_ROLE_KEY`, an attacker bypasses all Row-Level Security (RLS) policies and gains unconditional `SUPERUSER` privileges to read, mutate, and drop all tables.
2. **DPDP Act Legal Breach:** Complete exfiltration of donor phone numbers, hospital records, and emergency requests, leading to severe regulatory penalties under India's Digital Personal Data Protection (DPDP) Act 2023.
3. **Master Token Forgery:** With `SUPABASE_JWT_SECRET`, an attacker can forge administrative JWT tokens and impersonate any super-admin user.

#### C. Immediate Remediation Steps
1. **Rotate Keys Immediately:** In Supabase Dashboard -> Project Settings -> API, regenerate the `service_role` secret and JWT secret.
2. **Purge `assets/.env`:** Delete `assets/.env` from git and the filesystem.
3. **Strict Client Separation:** The web and mobile apps must strictly read ONLY `SUPABASE_URL` and `SUPABASE_ANON_KEY` from environment variables passed during compilation (`--dart-define`).

---

## 2. Additional Ranked Security Vulnerabilities

### SEC-VULN-02: CSV Formula Injection (Formula / DDE Injection)
- **Severity:** **MAJOR (CVSS v3.1: 7.2 / HIGH)**
- **CWE:** CWE-1236 (Improper Neutralization of Formula Elements in CSV File)
- **Location:** `lib/features/admin_console/widgets/data_exports_view.dart`
- **Description:**  
  The data export engine exports donor registries, emergency requests, and hospital logs directly to CSV format by concatenating raw string fields. If an attacker inputs a patient name or attendant phone number starting with `=cmd|' /C calc'!A0` or `@SUM(1+1)*cmd`, opening the resulting CSV in Microsoft Excel or LibreOffice executes arbitrary commands via Dynamic Data Exchange (DDE).
- **Remediation:**  
  Prepend a single quote (`'`) or tab to any cell value starting with `=`, `+`, `-`, or `@` prior to serialization.

---

### SEC-VULN-03: PostgREST Schema Mismatch & Missing Tables Exposure
- **Severity:** **MEDIUM (CVSS v3.1: 5.3 / MEDIUM)**
- **CWE:** CWE-200 (Exposure of Sensitive Information to an Unauthorized Actor)
- **Location:** Supabase PostgREST Schema
- **Description:**  
  Browser console logs expose missing tables (`public.hospitals`, `public.requester_profiles`, `public.partners`, `public.approval_requests`, `public.safety_incidents`, `public.dpdp_requests`, `public.data_exports`, `public.notifications`) with internal schema error codes (PGRST205, 42703).
- **Impact:**  
  Information leakage assists attackers in mapping backend schema discrepancies and finding unmigrated endpoints.
- **Remediation:**  
  Ensure all migrations are applied via CI/CD before releasing new frontend bundles.

---

## 3. DPDP Act & Privacy Compliance Verification

In accordance with Section 4 of the architectural requirements (DPDP Act Compliance):

| Privacy Requirement | Audit Verification | Status |
| :--- | :--- | :---: |
| **Donor Health Answers** | Verified unexported and excluded from admin registry views | **PASS (COMPLIANT)** |
| **Call Audio & Transcripts** | Voice Gateway stream passes PCM audio directly without persisting to disk or database | **PASS (COMPLIANT)** |
| **Immutable Audit Logs** | `audit_logs` table trigger rejects `UPDATE` and `DELETE` | **PASS (COMPLIANT)** |
| **Four-Eyes Governance** | High-impact actions (>200 recipient broadcasts) enforce second-admin maker-checker verification | **PASS (COMPLIANT)** |
| **Erasure Registry (DPDP)** | DPDP registry view available in governance section | **PASS (COMPLIANT)** |

