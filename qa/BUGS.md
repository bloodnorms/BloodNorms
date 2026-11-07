# Bug Log: BloodNorms Platform Audit & E2E Testing

**Date:** 2026-11-07  
**Test Environment:** Windows 11 / Chrome v145.0 (Headless & Headed)  
**Host Application:** Flutter Web (Release Build) / Voice Gateway (Node.js 22)  
**Backend:** Supabase Cloud (`https://ixrborkhofxlxbedpang.supabase.co`)  
**QA Lead:** Senior QA Lead & Exploratory Attacker  

---

## Bug Index

| Bug ID | Title | Severity | Priority | Type | Status |
| :--- | :--- | :---: | :---: | :---: | :---: |
| [`BUG-001`](#bug-001-critical-secret-leak-service-role-key--jwt-secret-in-client-assets) | Critical Secret Leak: Service Role Key & JWT Secret in Client Assets | **Blocker** | **P0** | Security | OPEN |
| [`BUG-002`](#bug-002-postgrest-exception-column-donorstotal_donations-does-not-exist) | PostgREST Exception: `column donors.total_donations does not exist` | **Critical** | **P1** | Reliability / Schema | OPEN |
| [`BUG-003`](#bug-003-missing-database-tables-in-supabase-schema-cache-http-404) | Missing Database Tables in Supabase Schema Cache (HTTP 404) | **Critical** | **P1** | Reliability / Schema | OPEN |
| [`BUG-004`](#bug-004-missing-rpc-function-publicget_daily_spend_summary) | Missing RPC Function `public.get_daily_spend_summary` (HTTP 404) | **Major** | **P2** | Reliability / Backend | OPEN |
| [`BUG-005`](#bug-005-csv-formula-injection-in-data-exports-engine) | CSV Formula Injection in Data Exports Engine | **Major** | **P2** | Security | OPEN |
| [`BUG-006`](#bug-006-flutter-web-hash-url-strategy-breaks-direct-browser-paths) | Flutter Web Hash URL Strategy Breaks Direct Browser Paths | **Minor** | **P3** | Usability / Routing | OPEN |

---

### BUG-001: Critical Secret Leak: Service Role Key & JWT Secret in Client Assets

- **Severity:** Blocker
- **Priority:** P0
- **Type:** Security (Secret Exposure / Privilege Escalation)
- **Environment:** Production & Staging Flutter Web / Mobile builds
- **Preconditions:** None (Accessible to unauthenticated external users)
- **Steps to Reproduce:**
  1. Open a browser or terminal.
  2. Send an HTTP GET request to `http://<domain>:5000/assets/assets/.env`.
  3. Inspect the returned plaintext response.
- **Expected Behavior:**
  Client assets must NEVER contain server secrets, service role keys, master JWT secrets, or cloud API keys. The file `assets/.env` should either not exist or contain only public anonymous client keys.
- **Actual Behavior:**
  The server responds with HTTP 200 OK and 4,699 bytes of configuration containing:
  - `SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...` (Full database bypass key)
  - `SUPABASE_JWT_SECRET=...` (Allows forging arbitrary auth tokens)
  - `GEMINI_API_KEY=...` (Unrestricted AI API key)
- **Evidence:**
  - Automated Suite 4 Log:
    ```json
    "httpAccessAssetsAssets": {
      "status": 200,
      "length": 4699,
      "isSecret": true
    }
    ```
  - Physical file on disk: `build/web/assets/assets/.env`
- **Console & Network Logs:**
  `GET http://localhost:5000/assets/assets/.env HTTP/1.1 -> 200 OK (Content-Type: text/plain; size: 4699)`
- **Root Cause Hypothesis:**
  In `pubspec.yaml`, the entire `assets/` directory is registered as an asset bundle (`- assets/`). Because `assets/.env` contains production server credentials rather than public stubs, Flutter’s asset compiler copies `assets/.env` verbatim into `build/web/assets/assets/.env`, which the SPA server serves statically.
- **Suggested Fix:**
  1. Immediately rotate the Supabase Service Role Key and JWT Secret in Supabase Cloud Dashboard.
  2. Delete `assets/.env` or remove all secrets from it, leaving only `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
  3. Remove `- assets/` or add `.env` to `.gitignore` so it is never packaged into client distributions.

---

### BUG-002: PostgREST Exception: `column donors.total_donations does not exist`

- **Severity:** Critical
- **Priority:** P1
- **Type:** Reliability / Database Schema Mismatch
- **Environment:** Admin Console (`/#/admin`)
- **Preconditions:** Admin navigates to Donors Registry or Dashboard
- **Steps to Reproduce:**
  1. Navigate to `http://localhost:5000/#/admin`.
  2. Observe browser DevTools console while `AdminConsoleController.loadAllAdminData()` executes.
- **Expected Behavior:**
  `SupabaseService.getAllDonors()` successfully fetches donor records without query syntax errors.
- **Actual Behavior:**
  Supabase PostgREST returns HTTP 400 Bad Request:
  ```
  [PAGE CONSOLE error]: Failed to load resource: the server responded with a status of 400 ()
  [PAGE CONSOLE log]: getAllDonors error: PostgrestException(message: column donors.total_donations does not exist, code: 42703, details: , hint: null)
  ```
- **Evidence:**
  - Captured in `qa/evidence/route_crawl_results.json` and task log `task-1539`.
- **Root Cause Hypothesis:**
  The Flutter query in `SupabaseService.getAllDonors()` executes:
  `.from('donors').select('id, full_name, blood_group, city, status, total_donations, last_donation_date')`.
  The active Postgres schema in the remote Supabase project has a column named `donation_count` or does not have `total_donations`.
- **Suggested Fix:**
  Align the SQL migration and Flutter client query. Either add `total_donations INT DEFAULT 0` to table `donors` or update the query to select `donation_count`.

---

### BUG-003: Missing Database Tables in Supabase Schema Cache (HTTP 404)

- **Severity:** Critical
- **Priority:** P1
- **Type:** Reliability / Missing Migrations
- **Environment:** Admin Command Center (`/#/admin`) and Bank Console (`/#/bank`)
- **Preconditions:** Admin loads workspace data
- **Steps to Reproduce:**
  1. Navigate to `http://localhost:5000/#/admin`.
  2. Monitor DevTools Network panel.
- **Expected Behavior:**
  All admin management views load their respective data stores from Supabase.
- **Actual Behavior:**
  Eight distinct database queries fail with HTTP 404 Not Found (PGRST205 - Table not found in schema cache):
  1. `public.hospitals`
  2. `public.requester_profiles`
  3. `public.partners`
  4. `public.approval_requests`
  5. `public.safety_incidents`
  6. `public.dpdp_requests`
  7. `public.data_exports`
  8. `public.notifications`
- **Evidence:**
  - Console excerpts from real Chrome session:
    ```
    PostgrestException(message: Could not find the table 'public.hospitals' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.requester_profiles' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.partners' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.approval_requests' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.safety_incidents' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.dpdp_requests' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.data_exports' in the schema cache, code: PGRST205)
    PostgrestException(message: Could not find the table 'public.notifications' in the schema cache, code: PGRST205)
    ```
- **Root Cause Hypothesis:**
  The schema migrations in `supabase/migrations/` have not been applied to the remote Supabase project `ixrborkhofxlxbedpang`. While the Flutter app handles empty lists gracefully (using mock fallback data), live data persistence fails.
- **Suggested Fix:**
  Run `supabase db push` or apply all unapplied migrations to the target Supabase instance.

---

### BUG-004: Missing RPC Function `public.get_daily_spend_summary`

- **Severity:** Major
- **Priority:** P2
- **Type:** Reliability / Backend RPC
- **Environment:** Admin Console (`/#/admin`)
- **Preconditions:** Admin loads dashboard spend metrics
- **Steps to Reproduce:**
  1. Navigate to `http://localhost:5000/#/admin`.
  2. Inspect network call to `/rest/v1/rpc/get_daily_spend_summary`.
- **Expected Behavior:**
  Function returns daily spend aggregation for WhatsApp and voice gateway calls.
- **Actual Behavior:**
  Returns HTTP 404:
  `PostgrestException(message: Could not find the function public.get_daily_spend_summary(p_target_date) in the schema cache, code: PGRST202)`
- **Evidence:**
  - Captured in `qa/evidence/route_crawl_results.json`.
- **Root Cause Hypothesis:**
  The SQL function `get_daily_spend_summary` is defined in local migration files but has not been deployed to the remote database.
- **Suggested Fix:**
  Deploy the RPC function migration using Supabase CLI.

---

### BUG-005: CSV Formula Injection in Data Exports Engine

- **Severity:** Major
- **Priority:** P2
- **Type:** Security (CSV / Formula Injection - CWE-1236)
- **Environment:** Admin Console -> Governance -> Data Exports Engine
- **Preconditions:** Admin exports donor or requester CSV records
- **Steps to Reproduce:**
  1. Register a donor or patient with name `=cmd|' /C calc'!A0` or `@SUM(1+1)*cmd`.
  2. In Admin Console -> Data Exports Engine, export the Donor Registry CSV.
  3. Open the downloaded CSV in Microsoft Excel or LibreOffice Calc.
- **Expected Behavior:**
  Export routines sanitize cell values starting with `=`, `+`, `-`, or `@` by prepending a single quote (`'`) or tab character to neutralize executable formula payloads.
- **Actual Behavior:**
  In `lib/features/admin_console/widgets/data_exports_view.dart`, values are joined into raw CSV strings without sanitizing formula prefixes.
- **Evidence:**
  - Suite 4 static & runtime audit:
    `CSV Formula Injection Status: { hasSanitization: false }`
- **Root Cause Hypothesis:**
  CSV builder string concatenation lacks a cell sanitization wrapper function.
- **Suggested Fix:**
  Implement a sanitizer function before writing CSV rows:
  ```dart
  String sanitizeCsvCell(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.startsWith('=') || str.startsWith('+') || str.startsWith('-') || str.startsWith('@')) {
      return "'$str";
    }
    return str;
  }
  ```

---

### BUG-006: Flutter Web Hash URL Strategy Breaks Direct Browser Paths

- **Severity:** Minor
- **Priority:** P3
- **Type:** Usability / Routing
- **Environment:** Flutter Web
- **Preconditions:** User pastes `http://<domain>/admin` directly into browser address bar
- **Steps to Reproduce:**
  1. Enter `http://localhost:5000/admin` into Chrome address bar without `/#/`.
  2. Observe where the browser lands.
- **Expected Behavior:**
  App router resolves `/admin` and opens the Admin Command Center.
- **Actual Behavior:**
  SPA fallback serves `index.html`, but Flutter Web initializes with default route `/` (Home landing) because path URL strategy is not activated.
- **Evidence:**
  - Automated smoke test: `http://localhost:5000/admin` rendered Home page screenshot (`smoke-01-home.png`). Only `http://localhost:5000/#/admin` navigated to the admin console.
- **Root Cause Hypothesis:**
  `usePathUrlStrategy()` from `package:flutter_web_plugins/url_strategy.dart` is not called in `lib/main.dart`.
- **Suggested Fix:**
  In `lib/main.dart`, import `package:flutter_web_plugins/url_strategy.dart` and call `usePathUrlStrategy()` inside `main()` before `runApp()`.

