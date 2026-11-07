# BloodNorms — Legal Review & Statutory Questions (LEGAL_REVIEW_QUESTIONS.md)

**Role:** Staff Compliance Architect  
**Audience:** Legal Counsel, Board of Directors, Medical Ethics Committee  
**Date:** November 2026  
**Status:** Open for Legal Counsel Review

---

## 1. Executive Summary

BloodNorms operates at the intersection of medical emergency response, Indian telecommunications regulation, and the India Digital Personal Data Protection Act (DPDP Act) 2023. Prior to scaling beyond the East Godavari pilot to national deployment, legal counsel must formally advise on the five questions detailed below.

---

## 2. Key Legal Questions for Formal Counsel Opinion

### Question 1: National Blood Transfusion Council (NBTC) vs. DPDP Erasure
- **Context:** Under NBTC guidelines and the Drugs and Cosmetics Act (1940), licensed blood banks are required to maintain donor registers and donation batch histories for at least 5 years. Under DPDP Act Section 12, a donor has the Right to Erasure.
- **Question:** When an individual donates blood at a verified hospital through BloodNorms and subsequently exercises their DPDP Right to Erasure, does the NBTC 5-year statutory retention mandate override the platform's duty to purge the donor's record from operational matching tables?
- **Engineering Recommendation:** Retain a sanitized, non-contact clinical batch identifier in blood bank ledger tables, while executing hard erasure of contact information (`phone_number`, push tokens) and suppressing future dispatches.

### Question 2: Emergency Grounds (§7c) vs. Pre-Consent for Family Callers
- **Context:** Stressed family members dialing the emergency helpline (+91 883 247 1234) need blood immediately. Presenting a legal consent terms agreement via voice before routing to matching could delay life-saving transfusions.
- **Question:** Does Section 7(c) of the DPDP Act 2023 ("responding to a medical emergency involving a threat to the life or immediate health of the Data Principal") fully exempt the platform from obtaining pre-call consent before processing patient blood group and hospital location?

### Question 3: Mass Casualty Incident (MCI) Four-Eyes Exemption
- **Context:** Our four-eyes governance rule blocks emergency broadcasts to > 200 donors without dual maker-checker authorization.
- **Question:** During a declared disaster or Mass Casualty Incident (e.g. train derailment, industrial explosion), does our Break-Glass Protocol (single executive override with recorded clinical rationale) fulfill liability standards under the National Disaster Management Act (NDMA) 2005?

### Question 4: WhatsApp Cloud API & Cross-Border Processing
- **Context:** Meta's WhatsApp Cloud API routes message payloads through global cloud infrastructure before reaching recipients in India.
- **Question:** Does sending template donor alerts containing masked patient hospital names violate Indian data localization or cross-border transfer restrictions under DPDP Act Section 16?

### Question 5: Ephemeral AI Voice Gateway Telephony Compliance
- **Context:** BloodNorms streams voice calls over WebSockets directly to Google Gemini Live API in real-time, discarding all audio frames upon call completion (zero recording or transcript storage).
- **Question:** Does this ephemeral speech architecture comply with Department of Telecommunications (DoT) Unified License regulations regarding call detail records (CDRs) and lawful interception?
