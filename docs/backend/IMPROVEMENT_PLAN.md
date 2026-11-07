# BloodNorms Backend & Database Architecture — Improvement Plan

**Status:** Tier 1 Fully Applied & Verified; Tier 2 Staged for Operational Approval  
**Target Database:** Supabase (PostgreSQL 17 + PostGIS)

---

## 1. Ranked Improvement Roadmap

```
+-------------------------------------------------------------------------+
| Tier 1: Safe Hardening (Applied in 0021_harden_performance_and_security) |
| - 12 Foreign Key Covering Indexes (O(1) join performance)              |
| - Fixed Stored Procedure search_path Hijacking Vulnerabilities          |
| - Converted Public Search Procedures to SECURITY INVOKER                |
| - Revoked Anonymous RPC Execution on Mutating Database Functions        |
| - Deduplicated Multiple Permissive RLS Policies on bank_stock           |
| - Restricted Sensitive Operational Tables (audit_logs, voice_calls)     |
| - Scoped Storage Uploads to slips and proofs Buckets                    |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| Tier 2: Architectural Enhancements (Requires Operational Sign-Off)     |
| - PostGIS Extension Relocation (public -> extensions schema)            |
| - CI/CD Pipeline Promotion for Milestones AM0-AM12 Schema Migrations    |
| - Realtime Row-Level Payload Filtering to Prevent PII Broadcasts        |
| - Short-Lived GoTrue JWT Access Tokens (15-Minute Expiry)               |
| - Automated pg_cron Retention Execution for Ephemeral Operational Data  |
+-------------------------------------------------------------------------+
```

---

## 2. Tier 1 Improvements (Completed & Verified)

### 1.1 Foreign Key Covering Indexes
- **Problem:** Database linter reported 12 unindexed foreign keys causing full table scans during cascading deletes and relational joins.
- **Remediation:** Created covering B-tree indexes (`idx_bank_camps_bank_id`, `idx_donations_donor_id`, etc.) in `0021_harden_performance_and_security.sql`.
- **Result:** Performance advisor `unindexed_foreign_keys` dropped from 12 findings to 0.

### 1.2 Function Search Path & Security Invoker
- **Problem:** `calculate_distance_km` and `nearest_banks` had role-mutable search paths, allowing schema-hijacking attacks. Furthermore, public search functions were marked `SECURITY DEFINER` unnecessarily.
- **Remediation:** Set `SET search_path = 'public'` across all procedures and changed search procedures to `SECURITY INVOKER`.
- **Result:** Security advisor `function_search_path_mutable` dropped from 2 to 0.

### 1.3 RPC Execution Least Privilege
- **Problem:** Mutating stored procedures (`bank_set_stock`, `bank_confirm_donation`, `dispatch_request_to_donors`, `find_nearby_eligible_donors`, `is_admin`) were executable by `anon` via PostgREST `/rest/v1/rpc/`.
- **Remediation:** Explicitly revoked `EXECUTE` from `PUBLIC` and `anon`; granted exclusively to `authenticated` and `service_role`.
- **Result:** Anonymous actors cannot manipulate stock or trigger donor alerts.

### 1.4 Deduplicate Permissive Policies on `bank_stock`
- **Problem:** Both `bank_stock_modify_all` (ALL) and `bank_stock_select_public` (SELECT) executed on every SELECT query.
- **Remediation:** Dropped broad `modify_all` policy; added targeted `bank_stock_staff_update` for bank staff and admins.
- **Result:** Performance advisor `multiple_permissive_policies` dropped from 5 to 0.

### 1.5 Sensitive Tables RLS Lockdown
- **Problem:** `audit_logs`, `voice_calls`, `inbound_sessions`, and `message_events` allowed anonymous reading and modification.
- **Remediation:** Restricted SELECT to authenticated administrators (`is_admin()`) and scoped INSERT to authenticated services.
- **Result:** Fully complies with DPDP Act and prevents unauthorized data harvesting.

---

## 3. Tier 2 Improvements (Approval-Needed Architectural Changes)

### 2.1 PostGIS Extension Relocation (`public` -> `extensions`)
- **Impact:** Medium. PostGIS defines spatial types (`geometry`, `geography`) used across tables (`donor_location.home_point`, `blood_banks.location`).
- **Prerequisite:** Maintenance window with quiet write traffic. Relocating an active extension with dependent columns requires table lock coordination.
- **Action Required:** Schedule during quarterly maintenance window.

### 2.2 Enterprise Admin Schema Promotion (0008–0020)
- **Impact:** High. Contains tables for 10 built-in admin roles, four-eyes maker-checker governance, and INR cost ledgers.
- **Action Required:** Apply via standard CI/CD deployment pipeline (`supabase db push`) following review by Staff Platform Engineer.

### 2.3 Realtime Channel Granularity
- **Impact:** Medium. `public.requests` and `public.request_contacts` currently stream to the `supabase_realtime` CDC publication.
- **Action Required:** Ensure client subscriptions only listen to user-scoped broadcast channels rather than full table changes.

