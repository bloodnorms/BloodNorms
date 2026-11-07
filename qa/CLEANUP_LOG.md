# Test Data Audit & Cleanup Verification Log

**Date:** 2026-11-07  
**Test Session Prefix:** `QA_20261107_*`  
**QA Lead:** Senior QA Lead  

---

## 1. Test Data Inventory & Audit

During end-to-end exploratory testing and browser automation suites, all injected test entries were strictly tagged using the mandatory session identifier `QA_20261107_*`.

| Data Object | Identifier / Payload | Target View | Persistence Status | Action Required |
| :--- | :--- | :--- | :---: | :---: |
| **Requester Request** | `QA_20261107_REQ_01` | `/#/live/QA_20261107_REQ_01` | Ephemeral (URL Route Param only) | None (No remote record created) |
| **Patient Profile** | `QA_20261107_Patient_Deepak` | `/#/details` | Ephemeral (Local Form State) | None (Not persisted to remote DB) |
| **Attendant Contact** | `QA_20261107_Attendant` | `/#/details` | Ephemeral (Local Form State) | None (Not persisted to remote DB) |
| **Donor Ticket ID** | `QA_20261107_DONOR_TKT_01` | `/#/donor/ticket/QA_20261107_DONOR_TKT_01` | Ephemeral (URL Route Param only) | None (No remote record created) |
| **XSS Payload** | `<script>alert("QA_XSS")</script>` | `/#/details` Input 0 | Sanitized in DOM | None (No remote record created) |
| **SQLi Payload** | `' OR '1'='1' --` | `/#/details` Input 1 | Sanitized in DOM | None (No remote record created) |

---

## 2. Cleanup Verification

Because remote Supabase tables (`public.requester_profiles`, `public.hospitals`, `public.dpdp_requests`) are unmigrated in the remote database (HTTP 404), no database rows were created or left behind.

The local and staging databases remain in a clean, non-polluted state.

