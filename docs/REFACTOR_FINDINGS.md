# BloodNorms — Refactor Findings

**Generated:** 2026-11-07  
**Status:** Phase 0 Audit Complete  
**Severity scale:** 🔴 CRITICAL · 🟠 HIGH · 🟡 MEDIUM · 🟢 LOW

---

## 🔴 CRITICAL — SECRETS COMMITTED TO GIT HISTORY

### Finding F-001 · Secrets in Committed `.env` File

| Field | Detail |
|---|---|
| **File** | `.env` (committed in git) |
| **Git commits** | `328166b`, `0f58fe4` |
| **Severity** | 🔴 CRITICAL |

**What happened:**  
The `.env` file containing live production credentials was committed to git in at least two commits. The following secrets are exposed in git history:

1. `SUPABASE_SERVICE_ROLE_KEY` — full database admin access, bypasses all RLS
2. `SUPABASE_JWT_SECRET` — allows forging authentication tokens
3. `WHATSAPP_ACCESS_TOKEN` — Meta Graph API access token
4. `WHATSAPP_WEBHOOK_VERIFY_TOKEN` — webhook verification secret
5. `GEMINI_API_KEY` — Google Generative Language API key
6. `WHATSAPP_PHONE_NUMBER_ID` — Meta phone number ID (semi-public but should not be in git)
7. `WHATSAPP_BUSINESS_ACCOUNT_ID` — Meta business account ID (semi-public)

**Risk:**
- Anyone with read access to this git repository can extract a Supabase service role key that bypasses ALL row-level security, giving full read/write/delete access to the entire BloodNorms database, including donor health data.
- The JWT secret allows an attacker to forge authentication tokens and impersonate any user, including admins.
- The WhatsApp access token allows sending messages on behalf of BloodNorms.

**Required immediate actions (BEFORE any other work):**

1. **Rotate every secret immediately:**
   - Supabase: Dashboard → Project Settings → API → Regenerate service role key AND reset JWT secret
   - Google: Google Cloud Console → APIs & Services → Credentials → Delete and recreate the Gemini API key
   - Meta: Meta Developer Portal → App → WhatsApp → Invalidate and regenerate the access token and verify token

2. **Remove the secret from git history** (AFTER rotation so the new secrets are never committed):
   ```bash
   git filter-repo --path .env --invert-paths
   # Then force-push to all remotes
   ```
   Or use BFG Repo Cleaner.

3. **Fix the `.gitignore`** to include `.env` and `assets/.env` (see Finding F-002).

4. **Notify team members** that this repo's history should be treated as compromised until rotation is confirmed.

**Note:** The `SUPABASE_ANON_KEY` is intentionally public (safe to commit, used in client code). The `defaultSupabaseAnonKey` hardcoded in `app_constants.dart` is acceptable per Supabase's design.

---

### Finding F-002 · `.gitignore` Does Not Exclude `.env`

| Field | Detail |
|---|---|
| **File** | `.gitignore` |
| **Severity** | 🔴 CRITICAL (enables F-001) |

The root `.gitignore` does not contain `.env` or `assets/.env`. This means every future save of real credentials will also be committed to git.

**Fix:** Add to `.gitignore`:
```
# Environment files (never commit real values)
.env
.env.local
.env.production
.env.staging
assets/.env
!.env.example
```

---

## 🟠 HIGH — Architecture & Code Quality

### Finding F-003 · `supabase_service.dart` is 3,886 Lines (God File)

| Field | Detail |
|---|---|
| **File** | `lib/core/services/supabase_service.dart` |
| **Lines** | 3,886 |
| **Severity** | 🟠 HIGH |

This single file contains:
- 8 domain model classes (`BloodBankModel`, `DonorCardModel`, `CampModel`, `DonorBadgeModel`, `InAppNotificationModel`, `RequestAlertModel`, and more)
- 1 giant `SupabaseService` singleton class with 100+ methods covering every domain (donors, banks, requests, admin, maintenance, exports, cost tracking, notifications, camps, etc.)
- All database query logic mixed together

**Suggested split plan (behavior-neutral — only moving code):**

```
lib/
├─ shared/models/
│  ├─ blood_bank_model.dart       (BloodBankModel)
│  ├─ donor_card_model.dart       (DonorCardModel)
│  ├─ camp_model.dart             (CampModel)
│  ├─ donor_badge_model.dart      (DonorBadgeModel)
│  ├─ notification_model.dart     (InAppNotificationModel)
│  └─ request_alert_model.dart    (RequestAlertModel)
├─ shared/services/
│  └─ supabase_client.dart        (SupabaseService.initialize, .client, .currentUser)
├─ features/requester/services/
│  └─ blood_bank_service.dart     (getNearestBanks, submitRequest, etc.)
├─ features/donor/services/
│  └─ donor_service.dart          (getDonorProfile, updateAvailability, etc.)
├─ features/admin_console/services/
│  └─ admin_service.dart          (admin-only methods)
└─ features/bank_console/services/
   └─ bank_service.dart           (bank staff methods)
```

**Risk:** HIGH — requires careful import updating across all 10+ screen files. Must be done file by file with lint/test verification after each.

---

### Finding F-004 · `admin_console_screen.dart` is 3,047 Lines (God Screen)

| Field | Detail |
|---|---|
| **File** | `lib/features/admin_console/screens/admin_console_screen.dart` |
| **Lines** | 3,047 |
| **Severity** | 🟠 HIGH |

This screen contains all 20 admin entity workspaces, the sidebar, navigation logic, all data fetching calls, all UI widgets, and all business logic in one file.

**Suggested split (behavior-neutral):**
```
lib/features/admin_console/
├─ screens/
│  └─ admin_console_screen.dart     (thin shell: sidebar + router ~100 lines)
├─ widgets/
│  ├─ admin_sidebar.dart            (sidebar + navigation)
│  ├─ dashboard_cockpit.dart        (entity 0)
│  ├─ live_crisis_radar.dart        (entity 1)
│  ├─ needs_human_queue.dart        (entity 2)
│  ├─ regional_broadcast_center.dart (entity 3)
│  ├─ blood_camps_manager.dart      (entity 4)
│  ├─ blood_centers_desk.dart       (entity 5)
│  ├─ hospitals_registry.dart       (entity 6)
│  ├─ donors_registry.dart          (entity 7)
│  ├─ requester_fraud_shield.dart   (entity 8)
│  ├─ community_alliances.dart      (entity 9)
│  ├─ ai_voice_studio.dart          (entity 10)
│  ├─ whatsapp_telecom_ledger.dart  (entity 11)
│  ├─ approvals_quorum_desk.dart    (entity 12)
│  ├─ financial_ledgers.dart        (entity 13)
│  ├─ data_exports_engine.dart      (entity 14)
│  ├─ safety_incidents_desk.dart    (entity 15)
│  ├─ dpdp_compliance_registry.dart (entity 16)
│  ├─ maintenance_switches.dart     (entity 17)
│  ├─ platform_config.dart          (entity 18)
│  └─ audit_logs_viewer.dart        (entity 19)
└─ services/
   └─ admin_service.dart
```

---

### Finding F-005 · `home_screen.dart` is 1,941 Lines (Mixed Responsibilities)

| Field | Detail |
|---|---|
| **File** | `lib/features/requester/screens/home_screen.dart` |
| **Lines** | 1,941 |
| **Severity** | 🟠 HIGH |

The home screen contains inline widget definitions, data fetching logic (Supabase calls), business logic, and animation controllers all mixed together in one file.

---

### Finding F-006 · `bank_console_screen.dart` is 1,767 Lines

| Field | Detail |
|---|---|
| **File** | `lib/features/bank_console/screens/bank_console_screen.dart` |
| **Lines** | 1,767 |
| **Severity** | 🟠 HIGH |

Same pattern as admin console. All 8+ bank sections mixed into one screen file.

---

### Finding F-007 · Hardcoded Credentials in `app_constants.dart`

| Field | Detail |
|---|---|
| **File** | `lib/core/constants/app_constants.dart`, lines 45–46 |
| **Severity** | 🟠 HIGH |

`defaultSupabaseUrl` and `defaultSupabaseAnonKey` are hardcoded in source as fallback values. While the anon key is safe to expose, this pattern means:
1. The URL and anon key will appear in every compiled binary (web bundle, APK, IPA)
2. There is no fail-fast startup behavior — the app silently falls back instead of alerting developers when env is misconfigured
3. Future developers may not notice that real credentials can live in source code this way

**Suggested fix:** Remove the fallback constants; require the env vars to be present. The app already logs a warning when they are absent — upgrade to a thrown exception in debug/staging mode.

---

### Finding F-008 · `duo_*` Naming Convention Derives from "Duolingo"

| Field | Detail |
|---|---|
| **Files** | `duo_colors.dart`, `duo_typography.dart`, `duo_button.dart`, `duo_blood_tile.dart`, `duo_bottom_nav_bar.dart`, `duo_header_bar.dart`, `duo_keypad.dart`, `duo_meter.dart`, `duo_notification_bell.dart`, `duo_radar_card.dart`, `duo_segmented_control.dart`, `duo_stepper.dart`, `duo_text_field.dart` |
| **Severity** | 🟠 HIGH |

All shared UI widgets are named `duo_*` after Duolingo's design system. Per the Golden Rule, names must describe OUR domain and not imitate other products.

**Suggested rename map:**

| Old Name | New Name | Rationale |
|---|---|---|
| `duo_colors.dart` / `DuoColors` | `brand_colors.dart` / `BrandColors` | Describes our brand, not theirs |
| `duo_typography.dart` / `DuoTypography` | `brand_typography.dart` / `BrandTypography` | |
| `duo_button.dart` / `DuoButton` | `action_button.dart` / `ActionButton` | Describes its role |
| `duo_blood_tile.dart` / `DuoBloodTile` | `blood_group_tile.dart` / `BloodGroupTile` | Domain-specific |
| `duo_bottom_nav_bar.dart` / `DuoBottomNavBar` | `app_nav_bar.dart` / `AppNavBar` | |
| `duo_header_bar.dart` / `DuoHeaderBar` | `screen_header.dart` / `ScreenHeader` | |
| `duo_keypad.dart` / `DuoKeypad` | `pin_keypad.dart` / `PinKeypad` | |
| `duo_meter.dart` / `DuoMeter` | `progress_meter.dart` / `ProgressMeter` | |
| `duo_notification_bell.dart` / `DuoNotificationBell` | `notification_bell.dart` / `NotificationBell` | |
| `duo_radar_card.dart` / `DuoRadarCard` | `donor_radar_card.dart` / `DonorRadarCard` | |
| `duo_segmented_control.dart` / `DuoSegmentedControl` | `segmented_picker.dart` / `SegmentedPicker` | |
| `duo_stepper.dart` / `DuoStepper` | `quantity_stepper.dart` / `QuantityStepper` | |
| `duo_text_field.dart` / `DuoTextField` | `app_text_field.dart` / `AppTextField` | |

> [!WARNING] This rename touches import statements in ALL 10+ screen files. Must be executed as a single atomic rename pass with lint verification after each file.

---

### Finding F-009 · `AppColors` is a Thin Wrapper Around `DuoColors` (Duplication)

| Field | Detail |
|---|---|
| **Files** | `lib/core/theme/app_colors.dart`, `lib/core/theme/duo_colors.dart` |
| **Severity** | 🟡 MEDIUM |

`AppColors` duplicates every constant from `DuoColors` as forwarding aliases. After renaming (F-008), `BrandColors` can be used directly and `AppColors` removed, or `AppColors` can become the canonical source and `DuoColors`/`BrandColors` removed.

---

### Finding F-010 · Duplicate Theme Files

| Field | Detail |
|---|---|
| **Files** | `app_typography.dart` and `duo_typography.dart`; `app_colors.dart` and `duo_colors.dart` |
| **Severity** | 🟡 MEDIUM |

Each concept has two files. Consolidate to one per concept after resolving F-008/F-009.

---

### Finding F-011 · `globalRequestFlow` — Bare Global Variable Antipattern

| Field | Detail |
|---|---|
| **File** | `lib/features/requester/providers/request_flow_provider.dart`, line 184 |
| **Severity** | 🟡 MEDIUM |

`final globalRequestFlow = RequestFlowNotifier()` is a module-level global. This project already uses `flutter_riverpod`; the notifier should be wrapped in a `ChangeNotifierProvider` and consumed via `ref.read` or `ref.watch`, not accessed as a global. This can cause test isolation issues and makes state lifetime uncontrollable.

**Suggested fix:** Wrap in `ChangeNotifierProvider<RequestFlowNotifier>((_) => RequestFlowNotifier())` in the app providers.

---

### Finding F-012 · `WhatsApp*` Naming in Domain Code

| Field | Detail |
|---|---|
| **File** | `lib/core/services/whatsapp_service.dart` |
| **Severity** | 🟡 MEDIUM |

`WhatsAppService` is a class name derived from a third-party brand. The file and class can be renamed to `messaging_service.dart` / `MessagingService`, or `meta_messaging_service.dart` / `MetaMessagingService` (acceptable since it's inside a provider adapter). The rule is that cross-domain names should not use brand names; inside the adapter file itself it is acceptable.

---

## 🟡 MEDIUM — Configuration & Tooling

### Finding F-013 · `.env.example` Contains Real Project URL and Anon Key

| Field | Detail |
|---|---|
| **File** | `.env.example`, line 10–11 |
| **Severity** | 🟡 MEDIUM |

The example file shows the real `SUPABASE_URL` (`ixrborkhofxlxbedpang`) and a real-looking `SUPABASE_ANON_KEY`. The URL and anon key are safe to expose (by Supabase design) but it sets a bad precedent — contributors may copy the pattern and add real service-role keys. Recommend replacing with clearly fake placeholder values like `https://your-project-ref.supabase.co`.

---

### Finding F-014 · CI Workflow Only Checks First 6 Migrations

| Field | Detail |
|---|---|
| **File** | `.github/workflows/ci.yml` |
| **Severity** | 🟡 MEDIUM |

The `database-lint` job checks for the presence of migrations 0001–0006 only. There are now 17 migrations. The check will pass even if migrations 0007–0017 are accidentally deleted.

**Fix:** Use a wildcard: `ls supabase/migrations/00*.sql | wc -l` and assert count >= 17.

---

### Finding F-015 · No `analysis_options.yaml` Customization

| Field | Detail |
|---|---|
| **File** | `analysis_options.yaml` |
| **Severity** | 🟡 MEDIUM |

The file inherits `flutter_lints` but enables no additional rules. For a production codebase:
- `prefer_single_quotes: true`
- `avoid_print: true` (currently only info-level, all 45 baseline issues are `avoid_print`)
- `always_declare_return_types: true`
- `prefer_const_constructors: true`
- `directives_ordering: true`

---

### Finding F-016 · `voice-gateway` Has Zero Tests

| Field | Detail |
|---|---|
| **File** | `voice-gateway/` |
| **Severity** | 🟡 MEDIUM |

The voice gateway has no test file or test runner configured.

---

### Finding F-017 · `voice-gateway/src/index.ts` Has No WebSocket Authentication

| Field | Detail |
|---|---|
| **File** | `voice-gateway/src/index.ts`, line 29 |
| **Severity** | 🟠 HIGH |

The WebSocket `upgrade` handler accepts any connection to `/twilio/stream` without verifying a Twilio webhook signature or any other authentication token. The `VOICE_GATEWAY_SECRET` env variable is loaded but never used.

**Suggested fix:** Validate the `X-Twilio-Signature` header or verify `VOICE_GATEWAY_SECRET` as a bearer token on the upgrade request before accepting the WebSocket.

---

### Finding F-018 · `twilio-voice` Edge Function Logs Hardcoded Default Phone

| Field | Detail |
|---|---|
| **File** | `supabase/functions/twilio-voice/index.ts`, line 77 |
| **Severity** | 🟡 MEDIUM |

If `From` is not in the query params, the code uses `"+918832471234"` as the caller's number, which is the emergency helpline number. A call log entry with the helpline's own number as the caller is misleading and could confuse audit queries.

---

### Finding F-019 · `engine-tick` Does Not Dispatch Donor Contacts

| Field | Detail |
|---|---|
| **File** | `supabase/functions/engine-tick/index.ts` |
| **Severity** | 🟡 MEDIUM |

The tick function advances ring state and wave numbers but does not actually query or notify donors. The actual notification dispatch (WhatsApp/SMS) presumably happens inside `claim_requests_for_tick` RPC in the database. This should be explicitly documented.

---

### Finding F-020 · `__pycache__` and `.pyc` Files in Root

| Field | Detail |
|---|---|
| **Path** | `c:\BloodNorms\__pycache__\test_supabase_flow.cpython-313.pyc` |
| **Severity** | 🟢 LOW |

A Python bytecode cache from a one-off test script is in the repo root. The script itself (`test_supabase_flow.py`) is not visible in the git-tracked file list, suggesting only the compiled cache was committed. Add `__pycache__/` and `*.pyc` to `.gitignore` and delete the directory.

---

### Finding F-021 · `assets/.env` Also Exists (Dual Config)

| Field | Detail |
|---|---|
| **File** | `assets/.env` |
| **Severity** | 🟡 MEDIUM |

The app tries to load `.env` from both the root and `assets/`. Having two files doubles the chance of them getting out of sync. The `assets/.env` is the one that ships inside the Flutter build (it's listed in `pubspec.yaml` under `assets/`). This means secrets in `assets/.env` go into the compiled app binary.

**Risk:** The `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, and `WHATSAPP_ACCESS_TOKEN` must NEVER be in `assets/.env` because they will be bundled into the web JavaScript bundle and mobile binaries where any user can extract them.

**Verify immediately:** Check whether `assets/.env` contains only the anon key (safe) or service-role key (critical exposure).

---

### Finding F-022 · 45 Baseline Lint Issues (All `avoid_print` in CLI Script)

| Field | Detail |
|---|---|
| **File** | `scripts/test_whatsapp.dart` |
| **Severity** | 🟢 LOW |

All 45 baseline lint issues are `avoid_print` violations in the CLI diagnostic script. Since this is a standalone CLI tool (not production Flutter code), `print` is acceptable. The fix is to either:
1. Add `// ignore_for_file: avoid_print` at the top of the script, OR
2. Move the script outside the Flutter analysis scope (exclude in `analysis_options.yaml`)

---

### Finding F-023 · `docs/` Contains Informal Working Notes as Top-Level Files

| Field | Detail |
|---|---|
| **Files** | `docs/SIVA-TODO.md`, `docs/ADMIN-MERGE-LOG.md`, `docs/ADMIN-INVENTORY.md`, `docs/ICON-MAP.md`, `docs/PROGRESS.md` |
| **Severity** | 🟢 LOW |

Developer working notes are mixed with documentation. These should be moved to `docs/working-notes/` or removed if superseded. The final docs structure should only contain audience-facing references.

---

## Security Findings Summary

| ID | Severity | Title | Status |
|---|---|---|---|
| F-001 | 🔴 CRITICAL | Secrets committed to git | **Rotate immediately** |
| F-002 | 🔴 CRITICAL | `.env` not in `.gitignore` | Fix in Phase 0 |
| F-003 | 🟠 HIGH | 3,886-line God service file | Phase 1 |
| F-004 | 🟠 HIGH | 3,047-line God screen file | Phase 1 |
| F-005 | 🟠 HIGH | 1,941-line home screen | Phase 1 |
| F-006 | 🟠 HIGH | 1,767-line bank console screen | Phase 1 |
| F-007 | 🟠 HIGH | Hardcoded fallback credentials in source | Phase 1 |
| F-008 | 🟠 HIGH | `duo_*` brand-derived widget names | Phase 1 |
| F-017 | 🟠 HIGH | No WebSocket auth in voice gateway | Phase 2 |
| F-009 | 🟡 MEDIUM | Duplicate color wrapper | Phase 1 |
| F-010 | 🟡 MEDIUM | Duplicate theme files | Phase 1 |
| F-011 | 🟡 MEDIUM | Global variable for Riverpod state | Phase 1 |
| F-012 | 🟡 MEDIUM | Brand name in service class | Phase 1 |
| F-013 | 🟡 MEDIUM | Real URL in `.env.example` | Phase 0 |
| F-014 | 🟡 MEDIUM | CI only checks 6/17 migrations | Phase 2 |
| F-015 | 🟡 MEDIUM | Weak lint configuration | Phase 0 |
| F-018 | 🟡 MEDIUM | Hardcoded fallback phone in edge function | Phase 2 |
| F-019 | 🟡 MEDIUM | Engine-tick dispatch not visible in code | Document |
| F-020 | 🟢 LOW | `__pycache__` committed | Phase 0 |
| F-021 | 🟡 MEDIUM | Dual `.env` files, assets/.env ships in binary | **Verify now** |
| F-022 | 🟢 LOW | 45 `avoid_print` lint issues in CLI script | Phase 0 |
| F-023 | 🟢 LOW | Working notes mixed with docs | Phase 2 |

