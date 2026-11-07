# BloodNorms — Data Inventory & Classification Register (DATA_INVENTORY.md)

**Role:** Chief Privacy & Compliance Architect  
**Legal Framework:** India Digital Personal Data Protection Act (DPDP Act) 2023  
**Classification Standard:** BloodNorms 3-Tier Data Privacy Framework  
**Version:** 1.0.0

---

## 1. Classification Tiers

| Tier | Sensitivity | Examples | Security Controls |
|---|---|---|---|
| **Tier 1** | **Operational / Non-Personal** | Blood groups, hospital addresses, camp dates, available units | Public or authenticated read; cached freely. |
| **Tier 2** | **Personal Data (PII)** | Donor first name, masked phone (`+918832 •••••`), city, district | RLS enforced; role-based access; audit logging. |
| **Tier 3** | **Sensitive Personal Data (SPII)** | Full phone number, raw health responses, caller voice streams | **Hard Privacy Lines:** Voice streams never stored; health responses unreadable in admin; 4-eyes approval for unmasking. |

---

## 2. Complete Entity & Field Inventory

| Entity / Table | Field | Classification | Legal Basis (DPDP §4) | Storage & Encryption | Retention | Access Roles |
|---|---|---|---|---|---|---|
| `donors` | `id`, `user_id` | Tier 2 (PII) | Consent (Donor Signup) | PostgreSQL (AES-256) | Active + 3 years | Donor, System |
| `donors` | `blood_group` | Tier 1 (Clinical) | Vital Interests (Medical) | PostgreSQL (AES-256) | Active + 3 years | Donor, Bank, Requester (anonymized) |
| `donors` | `lat`, `lng`, `city` | Tier 2 (PII) | Vital Interests (Medical) | PostgreSQL (PostGIS) | Active account | Donor, Matching Engine |
| `donors` | `phone_number` | Tier 3 (SPII) | Vital Interests (Medical) | PostgreSQL (Encrypted) | Active account | System only (Masked to Admin) |
| `donor_health_answers` | `question_responses`| Tier 3 (SPII) | Consent (Medical) | In-memory validation only | **Zero DB Storage** | **STRICTLY NONE (Unreadable)** |
| `requests` | `patient_name` | Tier 2 (PII) | Vital Interests (Medical) | PostgreSQL (AES-256) | 90 days after close | Requester, Assigned Donors |
| `requests` | `hospital_name`, `units` | Tier 1 (Clinical) | Vital Interests (Medical) | PostgreSQL (AES-256) | 90 days after close | All users in matching ring |
| `voice_calls` | `call_sid`, `duration` | Tier 1 (Operational) | Legitimate Uses (Audit) | PostgreSQL (AES-256) | 1 year | Admin, Operations |
| `voice_calls` | `audio_stream`, `transcript` | Tier 3 (SPII) | N/A | **Zero Disk / Zero DB** | **0 seconds (Ephemeral RAM only)** | **NONE (Hard Privacy Line 2)** |
| `audit_logs` | `actor_id`, `action`, `payload` | Tier 1 / 2 | Legal Compliance (Audit) | PostgreSQL (Immutable) | 7 years | Admin (Read-only) |
| `suppression_list` | `phone_hash` | Tier 2 (Pseudonymized) | Compliance (Opt-out) | SHA-256 Hash | Indefinite until unblock | System, Matching Engine |

---

## 3. Lawful Grounds for Processing (DPDP Act 2023)

Under Section 4 and Section 7 of the DPDP Act 2023:
1. **Section 7(c) (Medical Emergency):** Processing for responding to a medical emergency involving a threat to the life or immediate health of the Data Principal or another individual.
2. **Section 6 (Consent):** Explicit opt-in consent gathered during donor registration in trilingual text (English, Telugu, Hindi).
3. **Section 8 (Data Principal Rights):** Right to withdraw consent and request erasure honored via `STOP` webhook or privacy portal.
