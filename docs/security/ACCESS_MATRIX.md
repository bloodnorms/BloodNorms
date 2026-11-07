# BloodNorms Security Architecture — Role-Based Access Control Matrix

**Document Reference:** SEC-MAT-001  
**Classification:** Internal Security Baseline  
**Compliance Standard:** India DPDP Act 2023 & Least Privilege Architecture

---

## 1. Permission Legend

| Symbol | Description |
|---|---|
| **ALLOW** | Unrestricted operation within role definition |
| **DENY** | Strictly forbidden; rejected by RLS or database trigger |
| **OWN** | Scoped strictly to the authenticated user's own records (`auth.uid() = user_id`) |
| **TENANT** | Scoped strictly to the user's hospital/bank assignment (`bank_staff.bank_id`) |
| **ADMIN** | Requires administrative privilege (`profiles.role IN ('admin', 'super_admin')`) |

---

## 2. Table-to-Role Permissions Matrix

| Entity Table | Anonymous (`anon`) | Volunteer Donor | Emergency Requester | Bank Staff | Platform Admin | Super Admin | Service Role (`backend`) |
|---|---|---|---|---|---|---|---|
| **`public.blood_banks`** | SELECT | SELECT | SELECT | SELECT | ALL | ALL | ALL |
| **`public.bank_stock`** | SELECT | SELECT | SELECT | SELECT, TENANT(U) | ALL | ALL | ALL |
| **`public.bank_staff`** | DENY | DENY | DENY | TENANT(S) | ALL | ALL | ALL |
| **`public.bank_camps`** | SELECT | SELECT | SELECT | TENANT(ALL) | ALL | ALL | ALL |
| **`public.camp_signups`** | DENY | OWN(S,I,U) | DENY | TENANT(S) | ALL | ALL | ALL |
| **`public.donors`** | INSERT(Register) | OWN(S,U) | DENY | DENY | ADMIN(S,U)* | ALL | ALL |
| **`public.donor_location`** | DENY | OWN(S,U) | DENY | DENY | ADMIN(S) | ALL | ALL |
| **`public.donor_health_answers`** | **DENY** | **DENY** | **DENY** | **DENY** | **DENY** | **DENY** | **DENY** (Hashed) |
| **`public.requests`** | SELECT | SELECT | OWN(S,I,U) | SELECT | ALL | ALL | ALL |
| **`public.request_contacts`** | DENY | OWN(S,U) | OWN(S) | TENANT(S) | ALL | ALL | ALL |
| **`public.donations`** | DENY | OWN(S) | DENY | TENANT(S,I) | ALL | ALL | ALL |
| **`public.inbound_sessions`** | DENY | DENY | DENY | DENY | ADMIN(S) | ALL | ALL |
| **`public.voice_calls`** | DENY | DENY | DENY | DENY | ADMIN(S)* | ALL | ALL |
| **`public.message_events`** | DENY | DENY | DENY | DENY | ADMIN(S) | ALL | ALL |
| **`public.audit_logs`** | **DENY** | **DENY** | **DENY** | **DENY** | **ADMIN(S)** | **ADMIN(S)** | **INSERT ONLY** |
| **`public.app_settings`** | SELECT | SELECT | SELECT | SELECT | ADMIN(S,U) | ALL | ALL |
| **`public.pincodes`** | SELECT | SELECT | SELECT | SELECT | ALL | ALL | ALL |
| **`public.request_access_keys`**| DENY | DENY | OWN(S) | DENY | ADMIN(S) | ALL | ALL |
| **`public.usage_events`** | DENY | DENY | DENY | DENY | ADMIN(S) | ALL | ALL |
| **`public.suppression_list`** | DENY | DENY | DENY | DENY | ADMIN(S) | ALL | ALL |
| **`storage.objects (slips)`** | INSERT | OWN(S,I) | OWN(S,I) | TENANT(S) | ALL | ALL | ALL |
| **`storage.objects (proofs)`**| INSERT | OWN(S,I) | OWN(S,I) | TENANT(S) | ALL | ALL | ALL |

*\*Note: Administrative views mask phone numbers (`+91 8832 •••••`) and strictly exclude audio frames and speech transcripts.*

---

## 3. Hard Security & Privacy Invariants

1. **Audit Log Non-Repudiation:** `audit_logs` triggers reject all `UPDATE` and `DELETE` queries with SQLSTATE `42501`. Neither platform admins nor super admins can modify or purge entries.
2. **Donor Health Answers Irreversibility:** Donor eligibility screening is validated client-side and via cryptographically salted hashes. Plaintext health questionnaires are never stored in PostgreSQL tables.
3. **Telephony Privacy Boundary:** `voice_calls` records store duration, call SID, and cost in INR. Audio media and text transcripts are never written to disk or database tables.
4. **Anonymous Lockdown:** Anonymous (`anon`) role access is restricted exclusively to public emergency discovery (`find_nearby_banks_with_stock`, `nearest_banks`, `pincodes`) and donor self-registration.

