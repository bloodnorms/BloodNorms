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
```
