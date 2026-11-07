# BloodNorms — Data Retention & Disposal Policy Draft (RETENTION_POLICY_DRAFT.md)

**Role:** Data Protection Officer & Compliance Lead  
**Applicability:** All Production Environments & Cloud Services  
**Version:** 1.0.0 (DRAFT for Legal Board Review)

---

## 1. Purpose & Guiding Principles

This policy defines the mandatory retention periods and disposal procedures for digital data collected across the BloodNorms platform. In compliance with the India Digital Personal Data Protection Act (DPDP Act) 2023, data is retained only as long as necessary to fulfill the emergency medical purpose or comply with statutory requirements.

---

## 2. Retention Schedule by Data Category

| Data Category | Retention Period | Disposal Method | Trigger / Event |
|---|---|---|---|
| **Audio Streams & Transcripts** | **0 seconds (Immediate)** | Overwritten in RAM | Call termination |
| **Active Emergency Requests** | **90 days** post-resolution | Automated cryptographic purge | Fulfill / Expire / Cancel |
| **In-App Notifications** | **60 days** | Automated delete query | Delivery timestamp |
| **Donor Profile (Active)** | Duration of volunteer membership | Active in database | User opt-in |
| **Donor Profile (Deregistered)** | **72 hours** post-request | Hard delete from `donors` table | Right to Erasure request |
| **Voice Call Telemetry** | **365 days** | Rollup to monthly aggregate | Call end |
| **Audit Logs (`audit_logs`)** | **7 years** | Retained (Immutable) | Regulatory mandate |
| **Financial Ledger (`usage_events`)** | **7 years** | Retained (Immutable) | Indian Companies Act / Tax |
| **Suppression Registry (`suppression_list`)** | **Indefinite** | Retained as SHA-256 hash | Opt-out / DND mandate |

---

## 3. Automated Purge Routine

The scheduled maintenance job executes the stored procedure:
```sql
select * from public.purge_expired_ephemeral_data();
```
- **Execution Frequency:** Daily at 03:30 IST.
- **Safety Guarantee:** Executes within a single transaction; records total deleted row counts into `audit_logs` before committing.
