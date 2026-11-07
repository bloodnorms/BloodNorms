# BloodNorms — Refactor Plan

**Version:** 1.0  
**Author:** Principal Software Architect  
**Date:** 2026-11-07  
**Status:** APPROVED FOR EXECUTION

---

## Phase 0 Baseline

| Check | Result |
|---|---|
| `flutter test` | ✅ 77 / 77 tests passing |
| `flutter analyze` | ⚠️ 45 issues (all `avoid_print` in `scripts/test_whatsapp.dart`, info-level only) |
| `flutter build` | Not run (requires platform SDKs; app compiles per CI) |
| Git status | 1 unstaged change: `test/location_service_test.dart` (modified, not ours) |

**All refactor phases must end with 77/77 tests and ≤ 45 lint issues.**

---

## 1. Current Structure

```
c:\BloodNorms\
├─ lib/
│  ├─ main.dart                                  (84 lines — OK)
│  ├─ core/
│  │  ├─ constants/
│  │  │  ├─ app_constants.dart                   (48 lines — OK)
│  │  │  ├─ blood_groups.dart                    (95 lines — OK)
│  │  │  └─ rings.dart                           (52 lines — OK)
│  │  ├─ i18n/
│  │  │  └─ app_localizations.dart               (216 lines — slightly over)
│  │  ├─ router/
│  │  │  └─ app_router.dart                      (109 lines — OK)
│  │  ├─ services/
│  │  │  ├─ supabase_service.dart                (3,886 lines — ⛔ GOD FILE)
│  │  │  ├─ whatsapp_service.dart                (321 lines — over limit)
│  │  │  └─ location_service.dart               (150 lines — OK)
│  │  ├─ theme/
│  │  │  ├─ app_colors.dart                      (39 lines — duplicate wrapper)
│  │  │  ├─ app_theme.dart                       (64 lines — OK)
│  │  │  ├─ app_typography.dart                  (33 lines — duplicate)
│  │  │  ├─ duo_colors.dart                      (43 lines — brand-name)
│  │  │  └─ duo_typography.dart                  (83 lines — brand-name)
│  │  └─ widgets/
│  │     ├─ connectivity_banner.dart             (152 lines — over limit)
│  │     ├─ duo_blood_tile.dart                  (121 lines — brand-name)
│  │     ├─ duo_bottom_nav_bar.dart              (104 lines — brand-name)
│  │     ├─ duo_button.dart                      (328 lines — ⛔ OVER + brand-name)
│  │     ├─ duo_header_bar.dart                  (102 lines — brand-name)
│  │     ├─ duo_keypad.dart                      (223 lines — over + brand-name)
│  │     ├─ duo_meter.dart                       (199 lines — brand-name)
│  │     ├─ duo_notification_bell.dart           (317 lines — over + brand-name)
│  │     ├─ duo_radar_card.dart                  (246 lines — over + brand-name)
│  │     ├─ duo_segmented_control.dart           (100 lines — brand-name)
│  │     ├─ duo_stepper.dart                     (173 lines — brand-name)
│  │     ├─ duo_text_field.dart                  (131 lines — brand-name)
│  │     └─ not_found_screen.dart               (144 lines — OK)
│  └─ features/
│     ├─ admin_console/screens/
│     │  └─ admin_console_screen.dart            (3,047 lines — ⛔ GOD SCREEN)
│     ├─ bank_console/screens/
│     │  └─ bank_console_screen.dart             (1,767 lines — ⛔ OVER)
│     ├─ donor/screens/
│     │  ├─ donor_alerts_screen.dart             (336 lines — over)
│     │  ├─ donor_camps_screen.dart              (697 lines — ⛔ OVER)
│     │  ├─ donor_home_screen.dart               (456 lines — over)
│     │  ├─ donor_onboarding_screen.dart         (638 lines — ⛔ OVER)
│     │  ├─ donor_profile_screen.dart            (1,165 lines — ⛔ OVER)
│     │  └─ donor_ticket_screen.dart             (606 lines — ⛔ OVER)
│     └─ requester/
│        ├─ providers/
│        │  └─ request_flow_provider.dart        (185 lines — over + global var)
│        └─ screens/
│           ├─ banks_list_screen.dart            (373 lines — over)
│           ├─ blood_group_screen.dart           (199 lines — OK border)
│           ├─ home_screen.dart                  (1,941 lines — ⛔ GOD SCREEN)
│           ├─ live_tracking_screen.dart         (1,128 lines — ⛔ OVER)
│           ├─ location_screen.dart              (332 lines — over)
│           ├─ public_banks_screen.dart          (351 lines — over)
│           ├─ request_details_screen.dart       (260 lines — over)
│           ├─ review_send_screen.dart           (266 lines — over)
│           └─ units_urgency_screen.dart         (239 lines — over)
├─ supabase/
│  ├─ 00_master_schema.sql
│  ├─ functions/
│  │  ├─ engine-tick/index.ts
│  │  ├─ twilio-voice/index.ts
│  │  └─ whatsapp-webhook/index.ts
│  └─ migrations/ (0001–0017)
├─ voice-gateway/
│  ├─ src/index.ts                               (149 lines — OK but no structure)
│  ├─ Dockerfile
│  ├─ package.json
│  ├─ tsconfig.json
│  └─ README.md
├─ test/ (17 test files, 77 tests)
├─ scripts/test_whatsapp.dart
├─ docs/ (mixed working notes + architecture)
├─ android/ ios/ web/ assets/
├─ .github/workflows/ci.yml
├─ pubspec.yaml
├─ analysis_options.yaml
└─ .env  ⚠️ CONTAINS SECRETS (see F-001)
```

---

## 2. Target Structure

```
c:\BloodNorms\
├─ lib/
│  ├─ main.dart                        (bootstrap only, ~80 lines)
│  ├─ app/
│  │  ├─ app.dart                      (BloodNormsApp widget)
│  │  ├─ providers.dart                (all root-level Riverpod providers)
│  │  └─ router.dart                   (renamed from core/router/app_router.dart)
│  ├─ features/
│  │  ├─ requester/
│  │  │  ├─ screens/                   (thin screen files, each ≤ 150 lines)
│  │  │  ├─ widgets/                   (extracted sub-widgets)
│  │  │  ├─ providers/
│  │  │  │  └─ request_flow_provider.dart  (without global var)
│  │  │  ├─ services/
│  │  │  │  └─ blood_request_service.dart  (extracted from supabase_service.dart)
│  │  │  └─ index.dart
│  │  ├─ donor/
│  │  │  ├─ screens/                   (thin)
│  │  │  ├─ widgets/                   (extracted sub-widgets)
│  │  │  ├─ services/
│  │  │  │  └─ donor_service.dart      (extracted from supabase_service.dart)
│  │  │  └─ index.dart
│  │  ├─ bank_console/
│  │  │  ├─ screens/                   (thin shell)
│  │  │  ├─ widgets/                   (8+ extracted workspaces)
│  │  │  ├─ services/
│  │  │  │  └─ bank_service.dart       (extracted from supabase_service.dart)
│  │  │  └─ index.dart
│  │  └─ admin_console/
│  │     ├─ screens/
│  │     │  └─ admin_console_screen.dart  (thin shell ~100 lines)
│  │     ├─ widgets/                   (20 entity workspaces, each its own file)
│  │     ├─ services/
│  │     │  └─ admin_service.dart      (extracted from supabase_service.dart)
│  │     └─ index.dart
│  └─ shared/
│     ├─ models/                       (extracted from supabase_service.dart)
│     │  ├─ blood_bank_model.dart
│     │  ├─ donor_card_model.dart
│     │  ├─ camp_model.dart
│     │  ├─ donor_badge_model.dart
│     │  ├─ notification_model.dart
│     │  └─ request_alert_model.dart
│     ├─ services/
│     │  └─ supabase_client.dart       (init + .client only, ~60 lines)
│     ├─ widgets/                      (renamed from core/widgets)
│     │  ├─ action_button.dart         (was duo_button.dart)
│     │  ├─ blood_group_tile.dart      (was duo_blood_tile.dart)
│     │  ├─ app_nav_bar.dart           (was duo_bottom_nav_bar.dart)
│     │  ├─ screen_header.dart         (was duo_header_bar.dart)
│     │  ├─ pin_keypad.dart            (was duo_keypad.dart)
│     │  ├─ progress_meter.dart        (was duo_meter.dart)
│     │  ├─ notification_bell.dart     (was duo_notification_bell.dart)
│     │  ├─ donor_radar_card.dart      (was duo_radar_card.dart)
│     │  ├─ segmented_picker.dart      (was duo_segmented_control.dart)
│     │  ├─ quantity_stepper.dart      (was duo_stepper.dart)
│     │  ├─ app_text_field.dart        (was duo_text_field.dart)
│     │  ├─ connectivity_banner.dart   (keep name, same location)
│     │  └─ not_found_screen.dart      (keep)
│     ├─ constants/                    (moved from core/constants)
│     │  ├─ app_constants.dart
│     │  ├─ blood_groups.dart
│     │  └─ rings.dart
│     ├─ theme/                        (moved from core/theme)
│     │  ├─ brand_colors.dart          (merged duo_colors + app_colors)
│     │  ├─ brand_typography.dart      (merged duo_typography + app_typography)
│     │  └─ app_theme.dart
│     ├─ i18n/
│     │  └─ app_localizations.dart
│     └─ utils/
│        └─ location_utils.dart        (small pure helpers)
├─ supabase/
│  ├─ config.toml                      (if exists, keep)
│  ├─ 00_master_schema.sql
│  ├─ functions/
│  │  ├─ _shared/                      (new: common deno helpers)
│  │  │  └─ cors.ts
│  │  ├─ engine-tick/
│  │  │  └─ index.ts                   (keep, well-sized at 116 lines)
│  │  ├─ twilio-voice/
│  │  │  └─ index.ts                   (keep, 104 lines)
│  │  └─ whatsapp-webhook/
│  │     └─ index.ts                   (keep, 232 lines — slightly over but acceptable)
│  ├─ migrations/                      (never touch applied migrations)
│  └─ README.md                        (new)
├─ voice-gateway/
│  ├─ src/
│  │  ├─ server/
│  │  │  └─ http-server.ts             (HTTP + WebSocket bootstrap)
│  │  ├─ sessions/
│  │  │  └─ call-session.ts            (session state)
│  │  ├─ providers/
│  │  │  └─ gemini-live-adapter.ts     (Gemini Live WS connection)
│  │  ├─ config/
│  │  │  └─ env.ts                     (zod-validated env — package already has zod)
│  │  └─ types/
│  │     └─ index.ts
│  ├─ tests/
│  ├─ Dockerfile
│  ├─ package.json
│  ├─ tsconfig.json
│  ├─ .env.example                     (new)
│  └─ README.md                        (improved)
├─ test/                               (unchanged — 17 test files)
├─ scripts/
│  └─ test-whatsapp.dart               (renamed, with lint ignore comment)
├─ docs/
│  ├─ REFACTOR_PLAN.md                 (this file)
│  ├─ REFACTOR_FINDINGS.md
│  ├─ decisions/
│  │  ├─ 001-flutter-stack.md
│  │  ├─ 002-supabase-postgis.md
│  │  ├─ ... (one ADR per decision from DECISIONS.md)
│  └─ working-notes/                   (moved informal docs here)
│     ├─ ADMIN-INVENTORY.md
│     ├─ ADMIN-MERGE-LOG.md
│     ├─ ICON-MAP.md
│     ├─ PROGRESS.md
│     └─ SIVA-TODO.md
├─ android/ ios/ web/ assets/          (unchanged)
├─ .github/
│  └─ workflows/
│     └─ ci.yml                        (improved: check all 17 migrations)
├─ pubspec.yaml                        (unchanged)
├─ analysis_options.yaml               (improved lint rules)
├─ .gitignore                          (add .env entries)
├─ .env.example                        (scrubbed — no real values)
├─ .env                                (NOT committed — add to .gitignore)
├─ README.md                           (expanded)
├─ ARCHITECTURE.md                     (new)
├─ CONTRIBUTING.md                     (new)
├─ AGENTS.md                           (new)
└─ SECURITY.md                         (new)
```

---

## 3. File Mapping Table

### 3A. Files That Move / Rename

| Old Path | New Path | Type | Risk |
|---|---|---|---|
| `lib/core/constants/app_constants.dart` | `lib/shared/constants/app_constants.dart` | Move | Low — update imports |
| `lib/core/constants/blood_groups.dart` | `lib/shared/constants/blood_groups.dart` | Move | Low |
| `lib/core/constants/rings.dart` | `lib/shared/constants/rings.dart` | Move | Low |
| `lib/core/i18n/app_localizations.dart` | `lib/shared/i18n/app_localizations.dart` | Move | Low |
| `lib/core/router/app_router.dart` | `lib/app/router.dart` | Move | Low |
| `lib/core/services/location_service.dart` | `lib/shared/services/location_service.dart` | Move | Low |
| `lib/core/services/whatsapp_service.dart` | `lib/shared/services/messaging_service.dart` | Move + Rename | Medium |
| `lib/core/theme/app_colors.dart` | _(merged into brand_colors.dart — deleted)_ | Delete | Low |
| `lib/core/theme/app_theme.dart` | `lib/shared/theme/app_theme.dart` | Move | Low |
| `lib/core/theme/app_typography.dart` | _(merged into brand_typography.dart — deleted)_ | Delete | Low |
| `lib/core/theme/duo_colors.dart` | `lib/shared/theme/brand_colors.dart` | Move + Rename | Medium |
| `lib/core/theme/duo_typography.dart` | `lib/shared/theme/brand_typography.dart` | Move + Rename | Medium |
| `lib/core/widgets/connectivity_banner.dart` | `lib/shared/widgets/connectivity_banner.dart` | Move | Low |
| `lib/core/widgets/duo_blood_tile.dart` | `lib/shared/widgets/blood_group_tile.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_bottom_nav_bar.dart` | `lib/shared/widgets/app_nav_bar.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_button.dart` | `lib/shared/widgets/action_button.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_header_bar.dart` | `lib/shared/widgets/screen_header.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_keypad.dart` | `lib/shared/widgets/pin_keypad.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_meter.dart` | `lib/shared/widgets/progress_meter.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_notification_bell.dart` | `lib/shared/widgets/notification_bell.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_radar_card.dart` | `lib/shared/widgets/donor_radar_card.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_segmented_control.dart` | `lib/shared/widgets/segmented_picker.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_stepper.dart` | `lib/shared/widgets/quantity_stepper.dart` | Move + Rename | Medium |
| `lib/core/widgets/duo_text_field.dart` | `lib/shared/widgets/app_text_field.dart` | Move + Rename | Medium |
| `lib/core/widgets/not_found_screen.dart` | `lib/shared/widgets/not_found_screen.dart` | Move | Low |
| `scripts/test_whatsapp.dart` | `scripts/test-whatsapp.dart` | Rename | Low |
| `docs/ADMIN-INVENTORY.md` | `docs/working-notes/ADMIN-INVENTORY.md` | Move | Low |
| `docs/ADMIN-MERGE-LOG.md` | `docs/working-notes/ADMIN-MERGE-LOG.md` | Move | Low |
| `docs/ICON-MAP.md` | `docs/working-notes/ICON-MAP.md` | Move | Low |
| `docs/PROGRESS.md` | `docs/working-notes/PROGRESS.md` | Move | Low |
| `docs/SIVA-TODO.md` | `docs/working-notes/SIVA-TODO.md` | Move | Low |
| `docs/DECISIONS.md` | `docs/decisions/000-index.md` | Move + Format | Low |

### 3B. Symbol Rename Table

| Old Symbol | New Symbol | File(s) Affected |
|---|---|---|
| `DuoColors` | `BrandColors` | All files importing `duo_colors.dart` |
| `DuoTypography` | `BrandTypography` | All files importing `duo_typography.dart` |
| `DuoButton` | `ActionButton` | All screen files using the button |
| `DuoBloodTile` | `BloodGroupTile` | `blood_group_screen.dart`, others |
| `DuoBottomNavBar` | `AppNavBar` | `donor_home_screen.dart`, others |
| `DuoHeaderBar` | `ScreenHeader` | Multiple screens |
| `DuoKeypad` | `PinKeypad` | `bank_console_screen.dart` |
| `DuoMeter` | `ProgressMeter` | Multiple screens |
| `DuoNotificationBell` | `NotificationBell` | `home_screen.dart`, others |
| `DuoRadarCard` | `DonorRadarCard` | `live_tracking_screen.dart` |
| `DuoSegmentedControl` | `SegmentedPicker` | Multiple screens |
| `DuoStepper` | `QuantityStepper` | Multiple screens |
| `DuoTextField` | `AppTextField` | Multiple screens |
| `WhatsAppService` | `MessagingService` | Admin console, main |
| `globalRequestFlow` | _(removed — wrap in ChangeNotifierProvider)_ | `request_flow_provider.dart` + screens |

### 3C. Files Extracted from `supabase_service.dart`

| New File | Contents Extracted | Priority |
|---|---|---|
| `lib/shared/models/blood_bank_model.dart` | `BloodBankModel` class | Phase 1A |
| `lib/shared/models/donor_card_model.dart` | `DonorCardModel` class | Phase 1A |
| `lib/shared/models/camp_model.dart` | `CampModel` class | Phase 1A |
| `lib/shared/models/donor_badge_model.dart` | `DonorBadgeModel` class | Phase 1A |
| `lib/shared/models/notification_model.dart` | `InAppNotificationModel` class | Phase 1A |
| `lib/shared/models/request_alert_model.dart` | `RequestAlertModel` class | Phase 1A |
| `lib/shared/services/supabase_client.dart` | `SupabaseService` init + `client` getter | Phase 1B |
| `lib/features/requester/services/blood_request_service.dart` | Requester-domain methods | Phase 1B |
| `lib/features/donor/services/donor_service.dart` | Donor-domain methods | Phase 1B |
| `lib/features/bank_console/services/bank_service.dart` | Bank staff methods | Phase 1B |
| `lib/features/admin_console/services/admin_service.dart` | Admin methods | Phase 1B |

### 3D. Files Extracted from `admin_console_screen.dart`

| New File | Responsibility | Approx Lines |
|---|---|---|
| `admin_console_screen.dart` (trimmed) | Sidebar shell + entity router | ~100 |
| `widgets/admin_sidebar.dart` | Sidebar navigation widget | ~200 |
| `widgets/dashboard_cockpit.dart` | Entity 0: Overview KPI cards | ~150 |
| `widgets/live_crisis_radar.dart` | Entity 1: Live requests table | ~150 |
| `widgets/needs_human_queue.dart` | Entity 2: Queue view | ~100 |
| `widgets/regional_broadcast_center.dart` | Entity 3: Geo broadcast | ~150 |
| `widgets/blood_camps_manager.dart` | Entity 4: Camps CRUD | ~150 |
| `widgets/blood_centers_desk.dart` | Entity 5: Banks & stock | ~150 |
| `widgets/hospitals_registry.dart` | Entity 6: Hospital registry | ~100 |
| `widgets/donors_registry.dart` | Entity 7: Donors list | ~150 |
| `widgets/requester_fraud_shield.dart` | Entity 8: Abuse profiles | ~100 |
| `widgets/community_alliances.dart` | Entity 9: NGO partners | ~100 |
| `widgets/ai_voice_studio.dart` | Entity 10: AI voice simulator | ~150 |
| `widgets/whatsapp_telecom_ledger.dart` | Entity 11: WhatsApp ledger | ~150 |
| `widgets/approvals_quorum_desk.dart` | Entity 12: Four-eyes approvals | ~150 |
| `widgets/financial_ledgers.dart` | Entity 13: Cost ledgers | ~100 |
| `widgets/data_exports_engine.dart` | Entity 14: Exports | ~150 |
| `widgets/safety_incidents_desk.dart` | Entity 15: Safety | ~100 |
| `widgets/dpdp_compliance_registry.dart` | Entity 16: DPDP | ~100 |
| `widgets/maintenance_switches.dart` | Entity 17: Maintenance | ~100 |
| `widgets/platform_config.dart` | Entity 18: Config | ~80 |
| `widgets/audit_logs_viewer.dart` | Entity 19: Audit chain | ~100 |

---

## 4. Rename Risks and Non-Breaking Rules

### Safe to rename without DB/API risk:
- Dart class names (compile-time only)
- Dart file names (import paths, compile-time only)
- Dart widget names (render-time, no serialization)
- Local Dart constants (compile-time only)

### MUST NOT rename (would break deployed contracts):
- Supabase table names (e.g., `donors`, `requests`, `bank_camps`)
- Supabase column names (e.g., `blood_group`, `phone_e164`)
- Supabase RPC function names (e.g., `find_nearby_banks_with_stock`, `claim_requests_for_tick`)
- Edge function URL paths (e.g., `/twilio-voice`, `/whatsapp-webhook`, `/engine-tick`)
- App route paths (`/`, `/group`, `/units`, `/location`, `/banks`, `/b`, `/donor`, `/bank`, `/admin`, `/live/:id`)
- Env variable names used by Supabase secrets store (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, etc.)
- Twilio webhook URL (`/twilio/stream` in voice-gateway)
- Meta WhatsApp webhook registered URL

---

## 5. Execution Order

Each step ends with `flutter test` + `flutter analyze` before proceeding.

### Step 0 (Immediate — Security):
1. Add `.env` and `assets/.env` to `.gitignore`
2. Fix `.env.example` — replace real URL/key values with placeholders
3. Scrub `analysis_options.yaml` — add lint ignore for `scripts/` dir
4. Verify `assets/.env` does NOT contain service-role key or other server secrets
5. Document F-001 rotation instructions (this plan)

### Step 1A (Models — lowest risk):
- Extract all 6 model classes from `supabase_service.dart` into `lib/shared/models/`
- Update `supabase_service.dart` to import from the new files
- Verify 77/77 tests pass

### Step 1B (Service split):
- Split `supabase_service.dart` by domain into 4 feature services + 1 shared client
- Update screen imports
- Verify 77/77 tests pass

### Step 1C (Widget rename):
- Rename all 13 `duo_*` widgets to domain names
- Update all imports in screen files
- Rename class names inside the files
- Verify 77/77 tests pass

### Step 1D (Theme consolidation):
- Merge `duo_colors` → `brand_colors`, `duo_typography` → `brand_typography`
- Delete forwarding wrappers `app_colors.dart`, `app_typography.dart`
- Verify 77/77 tests pass

### Step 1E (Structural move):
- Move `core/constants/` → `shared/constants/`
- Move `core/i18n/` → `shared/i18n/`
- Move `core/theme/` → `shared/theme/`
- Move `core/widgets/` → `shared/widgets/`
- Move `core/router/app_router.dart` → `app/router.dart`
- Move `core/services/location_service.dart` → `shared/services/`
- Move `core/services/whatsapp_service.dart` → `shared/services/messaging_service.dart`
- Verify 77/77 tests pass

### Step 1F (Global var fix):
- Wrap `globalRequestFlow` in `ChangeNotifierProvider` in `app/providers.dart`
- Update all screens that reference `globalRequestFlow` to use `ref.read`
- Verify 77/77 tests pass

### Step 1G (Admin console split):
- Extract 20 entity workspace widgets from `admin_console_screen.dart`
- Thin the main screen file to ~100 lines
- Verify 77/77 tests pass

### Step 1H (Other screen splits):
- Split `home_screen.dart` into screen shell + sub-widgets
- Split `bank_console_screen.dart` into screen shell + sub-widgets
- Split oversized donor screens
- Verify 77/77 tests pass

### Step 2 (Voice gateway structure):
- Split `voice-gateway/src/index.ts` into `server/`, `sessions/`, `providers/`, `config/`
- Add `config/env.ts` with zod validation
- Add `.env.example` for voice gateway
- Add authentication to WebSocket upgrade handler (F-017)
- Verify existing functionality with smoke test

### Step 3 (Documentation):
- Write `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, `AGENTS.md`, `SECURITY.md`
- Write per-feature README files
- Write ADRs in `docs/decisions/`
- Move working notes to `docs/working-notes/`

### Step 4 (Config & CI):
- Improve `analysis_options.yaml`
- Fix CI to verify all 17 migrations
- Add `.editorconfig`

---

## 6. Decisions

### D-001: Keep `core/` or use `shared/`?
**Decision:** Rename `core/` → `shared/` to match the target architecture's `shared/` convention. The word "core" is overloaded and vague ("core of what?"). "Shared" precisely describes the purpose: code shared by all features. All imports will be updated.

### D-002: Keep existing feature folder structure or redesign?
**Decision:** Keep the existing `features/requester/`, `features/donor/`, `features/bank_console/`, `features/admin_console/` structure — it already follows feature-based organization. Only add the missing sub-folders (`widgets/`, `services/`, `index.dart`) within each feature.

### D-003: Migrate provider pattern?
**Decision:** Remove only the global variable anti-pattern (`globalRequestFlow`). Keep `ChangeNotifier` / `flutter_riverpod` as-is. No state management library swap.

### D-004: Keep Dart file naming convention?
**Decision:** Use `snake_case.dart` for files (Flutter convention), which the codebase already follows. No change needed.

### D-005: Handle `app_colors.dart` / `duo_colors.dart` duplication?
**Decision:** `duo_colors.dart` becomes `brand_colors.dart` (the canonical source). `app_colors.dart` is deleted (it was only a forwarding wrapper). All code uses `BrandColors` directly.

---

## 7. Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Import path update missed, breaking compile | High | High | Run `flutter analyze` after every file move |
| Test breaks due to service split | Medium | High | Split models first (zero logic change), then services |
| `duo_*` rename breaks widget test | Low | Medium | Widget test only tests smoke render; run after each rename batch |
| `globalRequestFlow` removal breaks screen state | Medium | High | Add provider, update all 7+ screen consumers before deleting the global |
| Admin console split introduces visual regression | Medium | High | Do widget-level extraction only (no logic change); no DB calls move |
| `.env` already in git history (F-001) | Confirmed | Critical | Rotate first; history purge is owner's responsibility |
