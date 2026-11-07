# ADR 005: Hard Privacy Lines and Immutable Legal Audit Logs

## Status
Accepted

## Context
Handling personal health and contact data under India's Digital Personal Data Protection (DPDP) Act mandates strict purpose limitation, non-disclosure of medical questionnaires, and tamper-proof operational recordkeeping.

## Decision
Establish six irreversible architectural privacy boundaries:
1. Donor health questionnaire responses are never queryable or exported in administrative reporting.
2. Inbound call audio and transcripts are never stored in the database.
3. Database triggers (`trg_audit_logs_immutable`) raise SQL exception `42501` on any attempt to `UPDATE` or `DELETE` audit log rows.
4. Four-eyes maker-checker governance enforces that the initiator of high-impact mutations cannot be the approver.
5. High-risk data exports (Tier 3) require explicit Four-Eyes approval tokens and cryptographic watermarking.
6. Formula injection attacks in CSV exports are neutralized by prepending `'` to `=`, `+`, `-`, and `@` characters.

