# BloodNorms — Admin Console Inventory
**Baseline Inventory as of Milestone AM0**  
*Documenting all existing routes, screens, sections, SQL functions, app settings keys, and test suites prior to the expansion.*

---

## 1. Routes & Navigation

| Route | File / Component | Purpose & Access Control |
|---|---|---|
| `/admin` | [`AdminConsoleScreen`](file:///C:/BloodNorms/lib/features/admin_console/screens/admin_console_screen.dart) | Executive Operations & Superhero Admin Command Center. Responsive: Left categorized sidebar on Desktop (>=1024px) matching DevzeMart / Confidency OS; collapsible Drawer on mobile. Protected by admin session and role check. |
| `/bank` | [`BankConsoleScreen`](file:///C:/BloodNorms/lib/features/bank_console/screens/bank_console_screen.dart) | Blood bank staff console: stock management, keypad donation confirmation, expected donors list, camps management, attendee check-in. |
| `/donor` | [`DonorHomeScreen`](file:///C:/BloodNorms/lib/features/donor/screens/donor_home_screen.dart) | Donor portal: availability toggle, donation pass wallet, camps RSVP, profile and DPDP Act rights. |
| `/` | [`HomeScreen`](file:///C:/BloodNorms/lib/features/requester/screens/home_screen.dart) | Emergency requester portal, nearest banks lookup (`/banks`, `/b`), and live tracking (`/live/:id`). |

---

## 2. Admin Console Sections & Capabilities

`AdminConsoleScreen` currently manages 11 dedicated functional operational sections:

### Section 0: Overview & Command Center
- **KPI Metrics Ribbon**: Active emergency requests, total donors registered, verified blood banks, published donation drives, inbound voice minutes, and total live calls.
- **Header Actions**: Live Sync button (real-time Supabase refresh), In-App Notification Bell ([`DuoNotificationBell`](file:///C:/BloodNorms/lib/core/widgets/duo_notification_bell.dart)), and Quick Action shortcut sheet.

### Section 1: Live Monitor (War Room)
- **Active Requests Table**: Real-time request state, patient details, hospital name, units needed, current ring (km), and donors contacted/accepted.
- **Emergency In-Flight Actions**:
  - `Widen Ring` (+5 km expansion override).
  - `Toggle Compatible Groups` (enable/disable cross-matching on the fly).
  - `Freeze / Unfreeze` (suspend donor dispatch waves temporarily).
  - `Close Request` (with structured outcome logging: fulfilled / cancelled / expired).

### Section 2: Needs Human Queue
- **Case Desk**: Triages emergency requests requiring volunteer or staff intervention (callers without WhatsApp, exhausted search rings, ambiguous locations).
- **Actions**: `Resolve Case`, `Escalate to Coordinator`, internal notes, and direct hospital dialer.

### Section 3: Regional Broadcast
- **Broadcast Composer**: Multi-channel emergency message and camp invitation broadcaster.
- **Targeting**: Filter by Blood Group, Target Radius, and Delivery Channel (WhatsApp / SMS / In-App).
- **Broadcast History**: Live log of previously sent broadcasts with recipient count and delivery timestamp.

### Section 4: Blood Camps Management
- **Camp Drives Registry**: Active, published, and upcoming blood donation drives across Rajahmundry & Godavari region.
- **Capabilities**:
  - `Create Camp Modal`: Direct insert into `public.bank_camps` with title, venue, landmark, capacity, and date ranges.
  - `Edit Camp Modal`: Update status (draft, published, cancelled, done), venue, and capacity.
  - `Direct Broadcast Shortcut`: Pre-populates the broadcast composer with camp details for rapid donor mobilization.
  - `Delete Camp`: Soft/hard removal with audit record.
  - `Camp QR / Keypad Check-In`: Connects to `public.bank_check_in_camp_attendee` with units collected counters.

### Section 5: Banks & Inventory
- **Blood Bank Directory**: Master registry of hospitals and charitable blood centers (GGH, Rotary Central, Red Cross).
- **Capabilities**:
  - `Create Bank Modal`: Add new facility with 24x7 status, phones, coordinates, and address.
  - `Edit Bank Modal`: Update trust score, operational hours, and contact details.
  - `All 8 Groups Stock Desk`: Live inventory grid (A+, A-, B+, B-, AB+, AB-, O+, O-) with tactile 3D steppers for Whole Blood, PRBC, Platelets, and FFP.

### Section 6: Donors Registry
- **Donor Directory**: Comprehensive donor registry with state filtering (Active, Paused, Suspended, Verified).
- **Capabilities**:
  - `Create Donor Modal`: Direct manual onboarding with first name, phone, blood group, area, and weight.
  - `Edit Donor Modal`: Modify personal details, language preference, and travel radius.
  - `Promote / Demote Trust Level`: Adjust trust score (Level 1 to 3).
  - `Pause / Activate`: Temporary availability hold (7 / 30 / 90 days).
  - `Quick Communications`: Direct Click-to-Call and WhatsApp alert triggers.
  - `Milestone Badges Integration`: Automatic assignment of Bronze, Silver, Gold, Platinum, and Centurion honors.

### Section 7: AI Voice Agent Training & Simulator
- **Gemini Live AI Configuration**:
  - Model parameters (`temperature`, `model_name`, `daily_minutes_cap`).
  - System Prompt & Persona Editor.
  - Multilingual routing (Telugu, Hindi, English).
  - Safety guidelines and medical boundary constraints.
- **Interactive Triage Simulator**:
  - Live testing bench: input emergency caller transcript &rarr; evaluates intent &rarr; generates structured JSON triage response (blood group detected, urgency tier, bilingual confirmation dialogue).

### Section 8: WhatsApp & Telephony Setup
- **WhatsApp Template Manager**:
  - Template inventory (`emergency_blood_alert`, `camp_invitation_v1`, `blood_request_confirmation`).
  - Template editing modal and Meta status sync tracker.
- **Telephony & Call Routing**:
  - Active provider toggle (Twilio / Exotel).
  - Max concurrent call channels, retry attempts, and retry intervals.
- **Telemetry Counters**: Real-time counters for WhatsApp sent, delivered, read, and telephony minutes logged.

### Section 9: Platform Settings
- **Emergency Platform Kill Switch**: High-visibility safety toggle that stops platform-wide outbound contact instantly with confirmation modal.
- **Matching Engine Rules**: Wave minutes (default 3 mins), search rings (0.5 to 100 km), and fatigue limits (max 1 contact per 6 hours, max 3 per month).
- **Maintenance Mode Scopes**: Scoped switches for web, donor app, bank console, and API.

### Section 10: Audit Logs
- **Immutable Audit Trail**: Chronological activity feed queried from `public.audit_logs`.
- **Fields**: Timestamp, Actor ID, Action (`camp_create`, `stock_update`, `kill_switch_toggle`), Target Type, and Metadata.

---

## 3. Existing SQL Functions & Stored Procedures

| Schema | Function | Arguments | Description |
|---|---|---|---|
| `public` | `is_admin()` | None | Returns boolean if `auth.uid()` exists in `public.admin_users`. |
| `public` | `has_admin_role(text)` | `p_required_role` | Checks hierarchical role membership (`support`, `admin`, `super_admin`). |
| `public` | `ai_voice_seconds_today()` | None | Computes daily telephony/AI voice consumption against the 60-minute cap. |
| `public` | `bank_update_stock(...)` | `p_bank_id, p_group, p_component, p_units` | Audited blood stock level update; writes to `bank_stock_history`. |
| `public` | `bank_confirm_donation(...)` | `p_code, p_donor_last4` | Validates 6-digit donation code, marks contact as donated, increments donor trust. |
| `public` | `bank_reject_donation(...)` | `p_code, p_reason` | Records medical deferral or donor no-show; reopens search. |
| `public` | `bank_create_camp(...)` | `p_title, p_venue, p_area, p_lat, p_lng, ...` | Inserts validated camp drive with spatial geometry. |
| `public` | `bank_set_camp_status(...)` | `p_camp_id, p_status` | Status transition (`draft`, `published`, `cancelled`, `done`). |
| `public` | `bank_check_in_camp_attendee(...)` | `p_camp_id, p_donor_id, p_phone, p_units` | Checks in donor at camp, increments units, evaluates milestone badges. |
| `public` | `create_request_for_user(...)` | Complex parameters | Server-side request creator used by WhatsApp and Inbound Voice gateways. |
| `public` | `reveal_donor_phone_for_user(...)` | `p_request_id, p_contact_id` | Privacy gate: reveals phone only upon mutual consent and acceptance. |
| `public` | `nearest_banks(...)` | `p_lat, p_lng, p_limit, p_group` | Spatial PostGIS query ranking banks by distance and freshness. |
| `public` | `pincode_lookup(...)` | `p_code` | Looks up office name, district, coordinates for 6-digit Indian PIN codes. |
| `public` | `mint_request_access_key(...)` | `p_request_id, p_hash, p_ttl_hours` | Issues ephemeral capability keys for unauthenticated family tracking. |
| `public` | `resolve_request_access_key(...)` | `p_hash` | Resolves capability hash to active request without leaking user records. |
| `public` | `rl_hit(...)` | `p_key, p_window_seconds, p_max_hits` | Sliding-window rate limiter for brute-force prevention. |

---

## 4. App Settings Keys (`public.app_settings`)

| Key | Format | Purpose |
|---|---|---|
| `kill_switch_active` | `boolean` | Master emergency platform halt flag. |
| `kill_switch_updated_at` | `timestamptz` | Timestamp of last kill switch engagement/release. |
| `ai_voice_config` | `jsonb` | Model parameters, persona prompt, Telugu/Hindi/English guidelines, minute caps. |
| `whatsapp_templates` | `jsonb` | Cache of registered Meta WhatsApp Cloud message templates. |
| `telephony_settings` | `jsonb` | Active provider configuration, retry policy, calling hours. |
| `maintenance` | `jsonb` | Scoped maintenance configuration per surface (web, donor, bank, api). |
| `feature_flags` | `jsonb` | Feature flag registry governing progressive capability rollout. |

---

## 5. Automated Tests Inventory

| Test File | Total Tests | Focus Area & Specifications |
|---|---|---|
| `test/blood_group_test.dart` | 4 | BR-04 Compatibility matrix, universal O- donor, exact match. |
| `test/search_rings_test.dart` | 4 | BR-06 Rings expansion, BR-07 distance gates (70, 90, 100 km), BR-08 wave timing, privacy distance masking. |
| `test/localization_budget_test.dart` | 2 | §14.3 Localization parity (EN, TE, HI) and strict 28-character UI string budget. |
| `test/donor_badges_test.dart` | 3 | Milestone ladder progression (Bronze Hero to Centurion), model serialization, certificate verification seal format. |
| `test/camps_checkin_test.dart` | 2 | Backward-compatible model parsing, camp check-in attendance counters increment, units collected calculation. |
| `test/notifications_test.dart` | 4 | Notification serialization, active system announcements seeding, read marking, in-app notification dispatch. |
| `test/widget_test.dart` | 1 | Full BloodNorms smoke test. |
| **Total Test Count** | **20** | **100% Passing** (`flutter test`). |

