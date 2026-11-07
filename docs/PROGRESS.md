# BloodNorms — Progress Log

## Status: All Phases Fully Implemented & Verified
**Date:** 6 November 2026

### Completed Milestones
- **Phase 0 — Foundation**: Flutter project scaffolding, Cupertino design tokens, Apple typography scale, color system with blood group family colors, GoRouter routing, Supabase service layer.
- **Phase 1 — Requester Flow**:
  - Home screen (`/`) with 176px pulsing hero button, language switch (EN/TE/HI), and Donor/Banks/WhatsApp CTAs.
  - Blood group screen (`/group`) with 4x2 family colored tiles & "Don't know" sheet.
  - Units & Urgency (`/units`) with 64px tabular big stepper (1–10 units), segmented urgency selector, and blood component sheet.
  - Location picker (`/location`) with OpenStreetMap tiles, draggable pin, GPS pill, and Nominatim search.
  - Nearest Banks (`/banks` & `/b`) with stock freshness ring, 24x7 chips, and direct dialer.
  - Request Details (`/details`) with patient name, hospital name, and universal compatibility toggle.
  - Review & Send (`/review`) with summary card and < 10s wave dispatch.
  - Live Tracking (`/live/:id`) with expanding radar search rings, 3 counters, donor cards with phone reveal, and 6-digit code entry.
- **Phase 2 — Donor App**:
  - Resumable 8-stage Onboarding Wizard (`/donor/onboarding`) with phone OTP, email, 6 consents, bio (18-65, weight >= 45kg), 10 health questions, and travel radius (3-100 km).
  - Donor Home (`/donor`) with Active status ring, next donation progress ring, Availability switch with 7/30/90 days pause, and badges.
  - Wallet-style Donation Pass (`/donor/ticket/:id`) with large spaced 6-digit donation code.
  - Alerts tab with Accept / Decline actions.
  - Camps tab with voluntary blood drives and 1-tap Join / Leave.
  - Profile with DPDP Act JSON data export and permanent account deletion.
- **Phase 3 — Blood Bank Console (`/bank`)**:
  - 8 blood groups x 4 components stock grid with steppers and "All same as before" time refresh.
  - 6-digit passcode keypad for confirming donations.
  - Not Donated / Deferral flow with reason sheet.
  - Expected donors list for requests within 3 km without phone numbers.
  - Camps and Staff account management.
- **Phase 4 — Admin Console (`/admin`)**:
  - macOS window style desktop layout & mobile tabs.
  - Live emergency requests table with Widen, Compatible, and Freeze actions.
  - Needs Human queue for non-WhatsApp callers and exhausted rings.
  - Inbound AI voice minute tracker vs. 60-minute daily cap.
  - Platform Kill Switch with confirmation dialog.
  - Audit log.
- **Phase 5 & 6 — Inbound Assistants & Voice Gateway**:
  - Meta WhatsApp Cloud API Edge Function with STOP opt-out and session state machine.
  - Twilio Voice Edge Function with Keypad IVR in English, Telugu, and Hindi.
  - Node 22 + TypeScript Voice Gateway (`voice-gateway/`) bridging Twilio Media Streams to Google Gemini Live API with barge-in support and zero DB credentials.
- **Phase 7 — Matching Engine**:
  - `engine-tick` Edge Function handling 20s distributed lease, expanding rings (0.5 to 100 km), gates at 70/90/100 km, and 3x wave contacts.
- **Phase 8 — Cross-Cutting & Verification**:
  - 11 automated test suites passing: BR-04 compatibility, BR-06..08 rings & gates, §14.3 string budget (< 28 chars) across English, Telugu, and Hindi.
  - GitHub Actions CI workflow configured.

### Admin Console Complete Expansion (Milestones AM0 to AM12)
- **Milestone AM0 — Inventory & Merge Log**:
  - Generated [`docs/ADMIN-INVENTORY.md`](file:///C:/BloodNorms/docs/ADMIN-INVENTORY.md) documenting baseline routes, 11 sections, 16 SQL functions, and settings keys.
  - Generated [`docs/ADMIN-MERGE-LOG.md`](file:///C:/BloodNorms/docs/ADMIN-MERGE-LOG.md) mapping all requirements in Part B to KEEP, MERGE, or NEW.
  - Applied forward-only migration [`supabase/migrations/0008_admin_expansion_am0.sql`](file:///C:/BloodNorms/supabase/migrations/0008_admin_expansion_am0.sql) defining the 10 built-in roles, module.action permission matrix, progressive feature flags (default OFF in production), and immutable audit logs trigger.
  - Added service layer methods `isFeatureEnabled`, `getFeatureFlags`, `setFeatureFlag`, `hasAdminPermission`, and `getAdminRoles` in `SupabaseService`.
  - Added and verified automated test suite [`test/admin_merge_test.dart`](file:///C:/BloodNorms/test/admin_merge_test.dart).

- **Milestone AM1 — Access, Governance, Step-Up & Four-Eyes Approvals (`ROL-1..4`, `APR-1..2`)**:
  - Created forward-only migration [`supabase/migrations/0009_admin_am1_approvals.sql`](file:///C:/BloodNorms/supabase/migrations/0009_admin_am1_approvals.sql) implementing `admin_sessions` with remote session revocation, `approval_requests` with strict four-eyes maker-checker separation (`checker_id <> maker_id`), 24-hour expiration window, and `admin_step_up_tokens` with 5-minute validity.
  - Added methods in `SupabaseService`: `submitApprovalRequest`, `getApprovalRequests`, `decideApprovalRequest`, `verifyStepUpCode`, `hasActiveStepUp`, `getActiveAdminSessions`, `revokeAdminSession`, `requestBreakGlassElevation`.
  - Created and verified test suite [`test/admin_am1_test.dart`](file:///C:/BloodNorms/test/admin_am1_test.dart) (6/6 passing).

- **Milestone AM2 — Maintenance Mode & Scoped Switches (`MNT-1..10`)**:
  - Created forward-only migration [`supabase/migrations/0010_admin_am2_maintenance.sql`](file:///C:/BloodNorms/supabase/migrations/0010_admin_am2_maintenance.sql) implementing `maintenance_windows` with 8 independent scopes (`web`, `donor`, `bank`, `public`, `whatsapp`, `phone`, `api`, `admin`), in-flight policy options (`continue_active`, `freeze`, `emergency_bypass`), and bypass allowlist.
  - Added methods in `SupabaseService`: `checkMaintenanceStatus`, `getMaintenanceWindows`, `setMaintenanceMode`, `extendMaintenanceWindow`, `isMaintenanceActive`.
  - Created and verified test suite [`test/admin_am2_maintenance_test.dart`](file:///C:/BloodNorms/test/admin_am2_maintenance_test.dart) (5/5 passing).

- **Milestone AM3 — Data Export & Reporting Engine (`EXP-1..10`)**:
  - Created forward-only migration [`supabase/migrations/0011_admin_am3_exports.sql`](file:///C:/BloodNorms/supabase/migrations/0011_admin_am3_exports.sql) implementing `data_exports`, `export_templates`, `scheduled_exports`, and safe reporting views (`rpt_*`).
  - Added CSV formula injection neutralization (`=`, `+`, `-`, `@`), UTF-8 BOM encoding, and SHA-256 watermarking.
  - Enforced four-eyes governance on Tier 3 (identifiable records) export generation.
  - Added methods in `SupabaseService`: `createDataExport`, `getDataExports`, `sanitizeCsvCell`.

- **Milestone AM4 — Ledgers & Telecom Cost Engine (`EXP-LED-1..2`, `FIN-1..5`)**:
  - Created forward-only migration [`supabase/migrations/0012_admin_am4_ledgers_and_costs.sql`](file:///C:/BloodNorms/supabase/migrations/0012_admin_am4_ledgers_and_costs.sql) implementing `cost_rate_cards` (Meta WhatsApp utility/marketing, Twilio Voice min, Gemini Live min, SMS failover) and `cost_events` ledger attributed to emergency requests.
  - Added methods in `SupabaseService`: `getCostRateCards`, `recordCostEvent`, `getDailySpendSummary`.
  - Created and verified test suite [`test/admin_am3_am4_test.dart`](file:///C:/BloodNorms/test/admin_am3_am4_test.dart) (7/7 passing).

- **Milestones AM5..AM11 — Operations, People, AI Studio, Safety, DPDP & Partners**:
  - Applied migrations [`supabase/migrations/0013_admin_am5_operations_desks.sql`](file:///C:/BloodNorms/supabase/migrations/0013_admin_am5_operations_desks.sql), [`supabase/migrations/0014_admin_am6_am7_am8_expansion.sql`](file:///C:/BloodNorms/supabase/migrations/0014_admin_am6_am7_am8_expansion.sql), and [`supabase/migrations/0015_admin_am9_am10_am11.sql`](file:///C:/BloodNorms/supabase/migrations/0015_admin_am9_am10_am11.sql).
  - Implemented `requester_profiles` with abuse scoring, `prescription_reviews` with 7-day auto-purge, `needs_human_cases`, `on_call_shifts`, `hospitals` GPS registry, `ai_prompt_versions` governance, `ai_eval_runs` (60-dialogue synthetic runner), `safety_incidents` desk (P1..P4), `dpdp_requests` compliance, and `partners` registry (Red Cross, Rotary, Lions, NSS).
  - Added and verified test suite [`test/admin_am5_am11_test.dart`](file:///C:/BloodNorms/test/admin_am5_am11_test.dart) (6/6 passing).

- **Milestone AM12 — Hardening, Privacy Verification & Final Acceptance**:
  - Implemented and verified [`test/admin_am12_security_audit_test.dart`](file:///C:/BloodNorms/test/admin_am12_security_audit_test.dart) (6/6 passing).
  - Strict verification of §0.3 Hard Privacy Lines:
    1. Donor health answers are strictly unreadable, unexported, and unlogged across all admin paths.
    2. Call audio and transcripts are never stored in database or exported.
    3. Secrets, OTP tokens, and API credentials are encrypted or masked.
    4. Immutable audit logs reject any UPDATE or DELETE operations via database trigger `trg_audit_logs_immutable`.
    5. Four-eyes separation strictly enforces maker != checker.
    6. Progressive feature flags default to false (OFF) for production safety.

- **Milestone AM13 — Multi-Location Aware Donors & Geo-Fenced Blood Camp Broadcasting**:
  - Forward-only migrations:
    - [`supabase/migrations/0016_geo_targeted_broadcasts.sql`](file:///c:/BloodNorms/supabase/migrations/0016_geo_targeted_broadcasts.sql) (`regional_broadcasts` ledger, `preview_broadcast_audience` RPC, `dispatch_geo_broadcast` with Four-Eyes check >200 recipients).
    - [`supabase/migrations/0017_location_aware_camps_and_preferences.sql`](file:///c:/BloodNorms/supabase/migrations/0017_location_aware_camps_and_preferences.sql) (Donors location, `is_away` out-of-station toggle, travel radius preference, bank camp target radius, detailed suppression breakdown).
  - **Donor App (`donor_camps_screen.dart` & `donor_profile_screen.dart` & `donor_onboarding_screen.dart`)**:
    - Real Haversine distance calculated for every camp from donor's GPS coordinates.
    - Camps sorted nearest first with dynamic zone badges (`IN YOUR ZONE` vs `OUTSIDE ZONE`).
    - Region & City switcher (`Rajahmundry`, `Kakinada`, `Visakhapatnam`, `Vijayawada`, `Guntur`, `Eluru`, `All`) with radius stepper chips (5, 15, 25, 50, 100 km).
    - Dedicated "Location & Alert Preferences" modal allowing donors to set primary city, area, travel radius cap, and "Currently Away / Out of Town" pause switch.
  - **Blood Bank Console (`bank_console_screen.dart`)**:
    - "Schedule Blood Drive" dialog for scheduling camps with venue, city, area, capacity, and target radius.
    - 3-button card actions: `CHECK-IN`, `ROSTER`, and `BROADCAST`.
    - Bank staff can preview live audience in radius, see out-of-region suppression count, and dispatch regional WhatsApp outreach.
  - **Admin Console (`admin_console_screen.dart`)**:
    - Section 3 (Regional Broadcast Center) with 3-tab audience inspector modal:
      1. `In-Radius Audience`: matched donors with distance, blood group, area.
      2. `Suppressed Donors`: excluded donors with city, distance, and explicit exclusion reason.
      3. `Neighborhood Breakdown`: locality/area distribution of donors.
  - Automated tests:
    - [`test/geo_broadcast_test.dart`](file:///c:/BloodNorms/test/geo_broadcast_test.dart) (5/5 passing).
    - [`test/region_aware_camps_broadcast_test.dart`](file:///c:/BloodNorms/test/region_aware_camps_broadcast_test.dart) (7/7 passing).
  - Overall status: **67 / 67 automated tests passing cleanly**, **0 issues in flutter analyze**.


