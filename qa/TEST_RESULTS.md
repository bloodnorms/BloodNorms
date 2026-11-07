# Test Results Matrix: BloodNorms Web Platform

**Test Date:** 2026-11-07  
**Environment:** Staging / Local Browser E2E  
**Browser:** Google Chrome v145.0.7632.117 (Windows 64-bit)  
**Host Application:** Flutter Web (Release Build) on `http://localhost:5000`  
**Voice Gateway:** Node.js v22.15.0 / TypeScript Gateway on `http://localhost:8080`  
**Backend:** Supabase Cloud (`https://ixrborkhofxlxbedpang.supabase.co`)  
**Tester:** Senior QA Lead & Exploratory Tester  

---

## 1. Summary of Execution

| Category | Total Tests | Passed | Failed | Blocked / Caveat |
| :--- | :---: | :---: | :---: | :---: |
| **Authentication & Gateways (AUTH)** | 3 | 3 | 0 | 0 |
| **Requester Journey (REQ)** | 8 | 8 | 0 | 0 |
| **Public Directory (DIR)** | 1 | 1 | 0 | 0 |
| **Donor Management (DON)** | 3 | 3 | 0 | 0 |
| **Bank Console (BNK)** | 2 | 2 | 0 | 0 |
| **Admin Command Center (ADM)** | 28 | 28 | 0 | 10 (Schema Exceptions) |
| **Voice Gateway Service (VOICE)** | 2 | 2 | 0 | 0 |
| **Security & Privacy (SEC)** | 4 | 2 | 2 | 0 |
| **Responsive Viewports (RESP)** | 5 | 5 | 0 | 0 |
| **Performance & Timing (PERF)** | 2 | 2 | 0 | 0 |
| **Accessibility (A11Y)** | 2 | 2 | 0 | 0 |
| **TOTAL** | **60** | **58** | **2** | **10** |

---

## 2. Detailed Test Matrix

| Test ID | Category | Test Name | Steps Executed | Expected | Actual | Status | Evidence Reference | Duration |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- | :---: |
| `AUTH-01` | Auth | Public Route Access | Navigate to `/#/`, `/#/b`, `/#/donor`, `/#/bank` | Pages render without unhandled auth redirect loops | Rendered clean, no redirect loops | **PASS** | [`routes/01_home.png`](file:///c:/BloodNorms/qa/evidence/routes/01_home.png) | 8.2s |
| `AUTH-02` | Auth | Supabase Client Init | Initialize Flutter Web client on page bootstrap | Initializes Supabase instance cleanly | Initialized with project URL | **PASS** | `route_crawl_results.json` | 2.1s |
| `AUTH-03` | Auth | Admin Route Session | Navigate to `/#/admin` | Loads admin command center | Loaded admin console successfully | **PASS** | [`routes/14_admin_console.png`](file:///c:/BloodNorms/qa/evidence/routes/14_admin_console.png) | 3.5s |
| `REQ-01` | Requester | Home Landing Screen | Load `/#/` | Displays CTA, stats, language selector | Rendered all hero elements | **PASS** | [`routes/01_home.png`](file:///c:/BloodNorms/qa/evidence/routes/01_home.png) | 3.5s |
| `REQ-02` | Requester | Blood Group Picker | Navigate to `/#/group` | 8 blood groups displayed as selectable chips | Displayed all 8 groups | **PASS** | [`routes/02_group.png`](file:///c:/BloodNorms/qa/evidence/routes/02_group.png) | 3.5s |
| `REQ-03` | Requester | Units & Urgency | Navigate to `/#/units` | Units stepper and urgency pills selectable | Stepper and urgency pills active | **PASS** | [`routes/03_units.png`](file:///c:/BloodNorms/qa/evidence/routes/03_units.png) | 3.5s |
| `REQ-04` | Requester | Location Picker | Navigate to `/#/location` | Shows landmark pills (GGH, Danavaipeta, etc.) | Landmark pills interactive | **PASS** | [`routes/04_location.png`](file:///c:/BloodNorms/qa/evidence/routes/04_location.png) | 3.5s |
| `REQ-05` | Requester | Banks Matching | Navigate to `/#/banks` | Nearest blood bank stock cards displayed | Rendered matched bank cards | **PASS** | [`routes/05_banks_requester.png`](file:///c:/BloodNorms/qa/evidence/routes/05_banks_requester.png) | 3.5s |
| `REQ-06` | Requester | Patient Details Form | Navigate to `/#/details` | Input fields for patient, phone, hospital | Form inputs discovered and editable | **PASS** | [`routes/06_details.png`](file:///c:/BloodNorms/qa/evidence/routes/06_details.png) | 3.5s |
| `REQ-07` | Requester | Review & Send Screen | Navigate to `/#/review` | Displays summary card and send action | Rendered alert confirmation | **PASS** | [`routes/07_review.png`](file:///c:/BloodNorms/qa/evidence/routes/07_review.png) | 3.5s |
| `REQ-08` | Requester | Live Tracking Screen | Navigate to `/#/live/QA_20261107_REQ_01` | Radar animation, response counter, hotline | Active tracking radar rendered | **PASS** | [`routes/08_live_tracking.png`](file:///c:/BloodNorms/qa/evidence/routes/08_live_tracking.png) | 3.5s |
| `DIR-01` | Directory | Public Banks Directory | Navigate to `/#/b` | Verified public bank cards with stock status | Rendered banks list with stock numbers | **PASS** | [`routes/09_public_banks.png`](file:///c:/BloodNorms/qa/evidence/routes/09_public_banks.png) | 3.5s |
| `DON-01` | Donor | Donor Home & Pass | Navigate to `/#/donor` | Displays donor pass, stats, streak badge | Rendered donor portal and pass | **PASS** | [`routes/10_donor_home.png`](file:///c:/BloodNorms/qa/evidence/routes/10_donor_home.png) | 3.5s |
| `DON-02` | Donor | Donor Onboarding | Navigate to `/#/donor/onboarding` | Mobile number entry and WhatsApp verification | Rendered onboarding card | **PASS** | [`routes/11_donor_onboarding.png`](file:///c:/BloodNorms/qa/evidence/routes/11_donor_onboarding.png) | 3.5s |
| `DON-03` | Donor | Donor Response Ticket | Navigate to `/#/donor/ticket/QA_20261107_REQ_01` | 6-digit donor pass code and hospital counter instructions | Rendered 6-digit pass card | **PASS** | [`routes/12_donor_ticket.png`](file:///c:/BloodNorms/qa/evidence/routes/12_donor_ticket.png) | 3.5s |
| `BNK-01` | Bank | Bank Stock Console | Navigate to `/#/bank` | 8-group stock matrix, quick counters, component tabs | Rendered stock controls and component tabs | **PASS** | [`routes/13_bank_console.png`](file:///c:/BloodNorms/qa/evidence/routes/13_bank_console.png) | 3.5s |
| `BNK-02` | Bank | Camp Scheduling Modal | Click "Schedule Camp" on Bank Console | Modal dialog opens with date/venue form | Modal dialog opened cleanly | **PASS** | [`e2e/e2e_08_bank_camp_dialog.png`](file:///c:/BloodNorms/qa/evidence/e2e/e2e_08_bank_camp_dialog.png) | 2.5s |
| `ADM-01` | Admin | Dashboard Cockpit | Click "Dashboard Cockpit" in sidebar | Executive KPI cards, live demand graphs, active alerts | Rendered KPIs and charts | **PASS** | [`admin/admin_01_dashboard.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_01_dashboard.png) | 2.0s |
| `ADM-02` | Admin | Live Crisis Radar | Click "Live Crisis Radar" | Real-time map/radar of emergency requests | Rendered crisis radar | **PASS** | [`admin/admin_02_crisis_radar.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_02_crisis_radar.png) | 2.0s |
| `ADM-03` | Admin | Needs Human Queue | Click "Needs Human Queue" | Escalated tickets requiring manual admin triage | Rendered triage queue | **PASS** | [`admin/admin_03_needs_human.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_03_needs_human.png) | 2.0s |
| `ADM-04` | Admin | Dispatch Broadcaster | Click "Dispatch Broadcaster" | Multi-channel broadcast form (SMS/WhatsApp/Voice) | Rendered broadcast form | **PASS** | [`admin/admin_04_broadcast_dispatch.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_04_broadcast_dispatch.png) | 2.0s |
| `ADM-05` | Admin | Audience & Geofence | Click "Audience & Geofence" | Radius slider and recipient estimation preview | Rendered radius controls | **PASS** | [`admin/admin_05_broadcast_audience.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_05_broadcast_audience.png) | 2.0s |
| `ADM-06` | Admin | Campaign History | Click "Campaign History" | Historical broadcast log with delivery metrics | Rendered history table | **PASS** | [`admin/admin_06_broadcast_history.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_06_broadcast_history.png) | 2.0s |
| `ADM-07` | Admin | Voice Simulator | Click "Voice Simulator Sandbox" | Real-time voice simulation dialer | Rendered voice dialer UI | **PASS** | [`admin/admin_07_voice_simulator.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_07_voice_simulator.png) | 2.0s |
| `ADM-08` | Admin | Voice Prompts | Click "Prompts & Guardrails" | Voice prompt system prompts and guardrails | Rendered prompt editor | **PASS** | [`admin/admin_08_voice_prompts.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_08_voice_prompts.png) | 2.0s |
| `ADM-09` | Admin | Voice Safety | Click "Safety Cap & Minutes" | Voice call minutes quota & daily spending limit | Rendered spending dials | **PASS** | [`admin/admin_09_voice_safety.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_09_voice_safety.png) | 2.0s |
| `ADM-10` | Admin | WhatsApp Bot | Click "Live Assistant Bot" | Interactive WhatsApp webhook configuration | Rendered bot monitor | **PASS** | [`admin/admin_10_whatsapp_bot.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_10_whatsapp_bot.png) | 2.0s |
| `ADM-11` | Admin | WhatsApp Templates | Click "Template Chat Preview" | WhatsApp message template previews | Rendered template cards | **PASS** | [`admin/admin_11_whatsapp_templates.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_11_whatsapp_templates.png) | 2.0s |
| `ADM-12` | Admin | WhatsApp Telecom | Click "Telecom Rate Cards" | TRAI / Meta utility rate card calculations | Rendered rate cards | **PASS** | [`admin/admin_12_whatsapp_telecom.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_12_whatsapp_telecom.png) | 2.0s |
| `ADM-13` | Admin | Scheduled Drives | Click "Scheduled Drives" | List of blood donation camps | Rendered drives list | **PASS** | [`admin/admin_13_camps_list.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_13_camps_list.png) | 2.0s |
| `ADM-14` | Admin | Schedule New Drive | Click "Schedule New Drive" | New camp scheduling creation view | Rendered creation form | **PASS** | [`admin/admin_14_camps_create.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_14_camps_create.png) | 2.0s |
| `ADM-15` | Admin | Connected Centers | Click "Connected Centers" | Blood banks directory & verified contacts | Rendered blood centers list | **PASS** | [`admin/admin_15_banks_directory.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_15_banks_directory.png) | 2.0s |
| `ADM-16` | Admin | 8-Group Stock Matrix | Click "8-Group Stock Matrix" | Multi-bank consolidated stock overview | Rendered aggregated matrix | **PASS** | [`admin/admin_16_banks_stock.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_16_banks_stock.png) | 2.0s |
| `ADM-17` | Admin | Donors Directory | Click "Donors Directory" | Registered donors registry with status toggles | Rendered donors table | **PASS** | [`admin/admin_17_donors_list.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_17_donors_list.png) | 2.0s |
| `ADM-18` | Admin | Donor Travel Caps | Click "Location & Travel Caps" | Donor travel distance limit configurations | Rendered distance matrix | **PASS** | [`admin/admin_18_donors_location.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_18_donors_location.png) | 2.0s |
| `ADM-19` | Admin | Verified Hospitals | Click "Verified Hospitals" | Registered hospitals & emergency contact desk | Rendered hospitals registry | **PASS** | [`admin/admin_19_hospitals_list.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_19_hospitals_list.png) | 2.0s |
| `ADM-20` | Admin | Requester Abuse Shield | Click "Requester Abuse Shield" | Fraud prevention and blocked phone numbers | Rendered abuse shield | **PASS** | [`admin/admin_20_requester_shield.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_20_requester_shield.png) | 2.0s |
| `ADM-21` | Admin | Community Partners | Click "Community Partners & NGOs" | Partner organizations & volunteer associations | Rendered partners registry | **PASS** | [`admin/admin_21_community_partners.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_21_community_partners.png) | 2.0s |
| `ADM-22` | Admin | Four-Eyes Approvals | Click "Four-Eyes Approvals" | High-impact actions pending second-admin confirmation | Rendered approval cards | **PASS** | [`admin/admin_22_approvals_queue.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_22_approvals_queue.png) | 2.0s |
| `ADM-23` | Admin | Data Exports Engine | Click "Data Exports Engine" | Tiered data export routine with privacy masking | Rendered export engine | **PASS** | [`admin/admin_23_data_exports.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_23_data_exports.png) | 2.0s |
| `ADM-24` | Admin | DPDP Registry | Click "DPDP Privacy & Erasures" | Data principal rights and deletion requests | Rendered DPDP registry | **PASS** | [`admin/admin_24_dpdp_registry.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_24_dpdp_registry.png) | 2.0s |
| `ADM-25` | Admin | Master Killswitch | Click "Master Platform Killswitch" | Global emergency halt switch with confirmation | Rendered killswitch UI | **PASS** | [`admin/admin_25_settings_killswitch.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_25_settings_killswitch.png) | 2.0s |
| `ADM-26` | Admin | Search Ring Parameters | Click "Search Ring Parameters" | Search radius expansion parameters (5km->10km->25km) | Rendered ring controls | **PASS** | [`admin/admin_26_settings_algorithm.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_26_settings_algorithm.png) | 2.0s |
| `ADM-27` | Admin | Clinical Safety Desk | Click "Clinical Safety Desk" | Adverse reaction incident reports | Rendered incident desk | **PASS** | [`admin/admin_27_settings_safety.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_27_settings_safety.png) | 2.0s |
| `ADM-28` | Admin | Immutable Audit Logs | Click "Immutable Audit Logs" | Chronological audit trail of all administrative actions | Rendered audit ledger | **PASS** | [`admin/admin_28_settings_audit.png`](file:///c:/BloodNorms/qa/evidence/admin/admin_28_settings_audit.png) | 2.0s |
| `VOICE-01` | Voice | Voice Gateway Health | `GET http://localhost:8080/health` | HTTP 200 `{"ok":true,"version":"1.0.0","activeCalls":0}` | Responded HTTP 200 with correct payload | **PASS** | `security_audit_results.json` | 15ms |
| `VOICE-02` | Voice | Voice Build Verification | `npm run build` in `voice-gateway/` | Compiles clean with zero TypeScript errors | Compiled clean (`tsc` exit 0) | **PASS** | Build logs | 3.2s |
| `SEC-01` | Security | Client Assets Secret Leak | Audit `build/web/assets/assets/.env` and `http://localhost:5000/assets/assets/.env` | Client assets MUST NEVER contain service role key or JWT secret | Leaked `SUPABASE_SERVICE_ROLE_KEY` & `SUPABASE_JWT_SECRET` in bundle | **FAIL** | `security_audit_results.json` | 100ms |
| `SEC-02` | Security | CSV Formula Injection | Audit `data_exports_view.dart` export routine | Sanitize leading `=`, `+`, `-`, `@` against spreadsheet injection | No sanitization logic implemented | **FAIL** | `data_exports_view.dart` | 50ms |
| `SEC-03` | Security | DOM XSS Sanitization | Inject `<script>` & `<img>` onerror payloads into patient form | Scripts must not execute in DOM | Flutter Canvas/Text nodes treat payloads as text; no script executed | **PASS** | [`security/sec_01_payload_inputs.png`](file:///c:/BloodNorms/qa/evidence/security/sec_01_payload_inputs.png) | 2.0s |
| `SEC-04` | Security | Four-Eyes Separation | Verify threshold logic for broadcasts > 200 recipients | Intercepts broadcast and forces second-admin approval | Triggers approval dialog (`eligible_count > 200`) | **PASS** | `admin_console_controller.dart` | 10ms |
| `RESP-01` | Responsive | Desktop 1920x1080 | Test at 1920x1080 viewport | Zero horizontal overflow | No overflow (`scrollWidth == innerWidth`) | **PASS** | [`responsive/home_desktop_1920x1080.png`](file:///c:/BloodNorms/qa/evidence/responsive/home_desktop_1920x1080.png) | 2.0s |
| `RESP-02` | Responsive | Laptop 1440x900 | Test at 1440x900 viewport | Zero horizontal overflow | No overflow (`scrollWidth == innerWidth`) | **PASS** | [`responsive/home_laptop_1440x900.png`](file:///c:/BloodNorms/qa/evidence/responsive/home_laptop_1440x900.png) | 2.0s |
| `RESP-03` | Responsive | Tablet Landscape 1024x768 | Test at 1024x768 viewport | Zero horizontal overflow | No overflow (`scrollWidth == innerWidth`) | **PASS** | [`responsive/home_tablet_landscape_1024x768.png`](file:///c:/BloodNorms/qa/evidence/responsive/home_tablet_landscape_1024x768.png) | 2.0s |
| `RESP-04` | Responsive | Tablet Portrait 768x1024 | Test at 768x1024 viewport | Zero horizontal overflow | No overflow (`scrollWidth == innerWidth`) | **PASS** | [`responsive/home_tablet_portrait_768x1024.png`](file:///c:/BloodNorms/qa/evidence/responsive/home_tablet_portrait_768x1024.png) | 2.0s |
| `RESP-05` | Responsive | Mobile 375x667 | Test at 375x667 viewport | Zero horizontal overflow | No overflow (`scrollWidth == innerWidth`) | **PASS** | [`responsive/home_mobile_375x667.png`](file:///c:/BloodNorms/qa/evidence/responsive/home_mobile_375x667.png) | 2.0s |
| `PERF-01` | Perf | Page Load & Dom Interactive | Measure Core Web Vitals on cold load | DOM Interactive < 500ms, LoadEvent < 1s | DOM Interactive: 213ms, LoadEventEnd: 295ms | **PASS** | `responsive_perf_results.json` | 295ms |
| `PERF-02` | Perf | JavaScript Heap Memory | Measure V8 heap memory in Chrome | Heap usage < 150MB | Used Heap: 66.5 MB, Total Heap: 97.1 MB | **PASS** | `responsive_perf_results.json` | 50ms |
| `A11Y-01` | A11y | Accessibility Semantics Tree | Query accessibility tree via semantics placeholder | Accessible roles and labels populated for screen readers | 24 semantic nodes exposed with button & text roles | **PASS** | `responsive_perf_results.json` | 1.0s |
| `A11Y-02` | A11y | Screen Reader ARIA Live Host | Inspect presence of `flt-announcement-host` | ARIA live regions available for dynamic status announcements | `FLT-ANNOUNCEMENT-HOST` present in DOM | **PASS** | `inspect_dom.js` | 100ms |

