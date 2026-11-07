# Instructions for AI Coding Assistants (AGENTS.md)

Welcome to the BloodNorms codebase. As an autonomous AI engineer, you must adhere strictly to the engineering rules below to keep the architecture clean, maintainable, and production-grade for years to come.

---

## 1. The Core Architectural Philosophy

1. **Behavior-Neutral Refactoring:** When asked to refactor, make zero changes to UI appearance, user flows, route definitions, or API contracts. Refactoring means moving code, splitting files, improving naming, and adding documentation.
2. **Never Commit Secrets:**
   - Client applications (`assets/.env`) must NEVER receive service role keys, JWT secrets, WhatsApp system access tokens, or Gemini API keys.
   - All server-only secrets live exclusively in the root `.env` or in deployment secret stores.
3. **Run Quality Gates Before Reporting Success:**
   - Always run `flutter analyze` and `flutter test`.
   - Never complete a task with failing tests or newly introduced compilation errors.

---

## 2. File Organization Rules

- **Where do new files go?**
  - Shared domain models: `lib/shared/models/`
  - Reusable UI widgets: `lib/shared/widgets/`
  - Reusable services: `lib/shared/services/`
  - Feature-specific UI: `lib/features/<feature_name>/widgets/`
  - Feature-specific screens: `lib/features/<feature_name>/screens/`
  - Feature-specific state: `lib/features/<feature_name>/providers/`
  - Feature-specific API calls: `lib/features/<feature_name>/services/`
- **File Size Constraint:**
  - Target: 50–150 lines.
  - Hard limit: 200 lines per file (except timestamped database migrations and generated code).
  - If a file approaches 200 lines, extract helper widgets or sub-services immediately.
- **Screen Files Must Be Thin:**
  - Screen files (`*_screen.dart`) must ONLY compose child widgets and bind to state providers.
  - Never place direct HTTP calls, Supabase RPC queries, or 100+ line widget trees inside a screen's `build` method.

---

## 3. Naming Rules

- **Use Domain Names Only:**
  - All names must describe the blood donation and emergency response domain: `BloodBankModel`, `QuantityStepper`, `ActionButton`, `DonorRadarCard`.
  - NEVER use names derived from external third-party consumer products (e.g. Duolingo, Uber, Tinder).
  - Banned file/class prefixes: `duo_*`, `helper`, `utils2`, `stuff`, `temp`, `manager` without domain context.

---

## 4. Hard Privacy Lines (DPDP Act Compliance)

1. **Donor Health Answers:** Strictly unreadable, unexported, and unlogged across all admin views and data export routines.
2. **Call Audio & Transcripts:** Never stored in the database, never written to disk, never printed in debug logs.
3. **Immutable Audit Logs:** The `audit_logs` table has a database trigger rejecting `UPDATE` and `DELETE`. Never write code attempting to mutate or delete audit log entries.
4. **Four-Eyes Governance:** Any high-impact mutation (broadcast > 200 donors, rate card changes, Tier 3 exports) mandates maker-checker separation (`checker_id <> maker_id`).

---

## 5. Verification Commands

Before ending your response, run:
```bash
flutter analyze
flutter test
```
If you touch `voice-gateway/`:
```bash
cd voice-gateway
npm run build
npm test
```

---

## 6. Operations & Reliability Rules for Agents

1. **Zero-Downtime Migrations:**
   - All migrations in `supabase/migrations/` must follow sequential naming (`00XX_*.sql`), be strictly additive, and use `IF NOT EXISTS` / `IF EXISTS`.
   - Never drop columns or tables in step 1; follow the 4-phase expand/contract migration cycle defined in `docs/operations/MIGRATION_RULES.md`.
2. **Progressive Guardrails Default OFF:**
   - Any new spending cap, call duration restriction, or behavior-altering safeguard must sit behind a feature flag in `app_settings` that defaults strictly to `false` (OFF).
3. **Telemetry & Log Redaction:**
   - Always propagate `X-Request-Id` across service boundaries.
   - All logs must redact phone numbers (`+918832 •••••`), bearer tokens, raw audio frames, and speech transcripts.
4. **Resilience & Graceful Draining:**
   - All server processes must intercept `SIGTERM` / `SIGINT` and permit active emergency calls to conclude naturally before exiting.
5. **No Undocumented Alerts:**
   - Every new alert must be registered in `docs/operations/ALERTS.md` with an actionable runbook in `docs/operations/runbooks/`.

---

## 7. UI and UX Rules for Agents

1. **Light Theme Strictness:**
   - Light theme only (`color-scheme: light`). Never add dark-mode toggles or dark variants.
   - Canvas is `#FFFFFF`, surfaces are `#F8F9FA`, borders are `#E8EAED`.
2. **One Primary Action Pill Per View:**
   - Exactly ONE near-black `#1F1F1F` pill button (`AppPillButtonVariant.primary`) per screen.
   - All secondary buttons must be outlined or tonal.
3. **Pill-Shaped Geometry:**
   - All buttons, badges, and search bars must use `BrandColors.radiusPill` (`999.0`).
   - Cards use `BrandColors.radiusCard` (`16.0`). Dialogs use `BrandColors.radiusDialog` (`24.0`).
4. **No Raw Hex Values or Hardcoded Sizes:**
   - Always use `BrandColors.*` and `BrandTypography.*`. Never write `Color(0xFF...)` in view files.
5. **3-Year-Old Simple Language & Minimum 44px Touch Targets:**
   - Use Grade-5 plain words ("Triage queue", "Connected centers").
   - Every interactive element must have a touch target of at least 44x44 dp.
6. **Adhere to the Component Library:**
   - Use `AppPillButton`, `AppStatCard`, `AppSearchField`, `AppPageHeader`, `AppEmptyState`, `AppErrorState`, and `SegmentedPicker`.
7. **File Size Strictness:**
   - Target: 50–150 lines. Hard limit: 200 lines. Extract sub-widgets immediately if approaching 200 lines.

