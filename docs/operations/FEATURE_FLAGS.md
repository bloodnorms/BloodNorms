# BloodNorms — Feature Flag System & Rollout Specification (FEATURE_FLAGS.md)

**Role:** Principal Operations & Release Engineer  
**Strategy:** Trunk-Based Development with Progressive Safety Flags  
**Version:** 1.0.0

---

## 1. Feature Flag Philosophy: Safe by Default

In emergency response software, unfinished or non-validated logic must never leak into critical patient matching paths.

### The Golden Rules:
1. **Default OFF:** Every new capability or behavioral guardrail must default strictly to `false` / `OFF`.
2. **Dynamic Inversion:** Flags are stored in PostgreSQL `app_settings` and can be toggled in real-time via the Admin Console without redeploying binaries.
3. **Audit Trail:** Every flag change is permanently captured in `audit_logs`.

---

## 2. Complete Feature Flag Catalog

| Flag Key | Type | Default | Blast Radius | Description |
|---|---|---|---|---|
| `cost_guardrails.enabled` | Boolean | `false` (OFF) | Telephony / AI Streaming | Enforces spending caps and drops calls exceeding 10 minutes. |
| `maintenance_mode.active` | Boolean | `false` (OFF) | All Client Applications | Displays emergency maintenance banner and redirects to 108. |
| `voice_mode.mode` | String | `'ivr'` | Inbound Helpline Calls | Controls telephony agent mode: `'ivr'` (Keypad) or `'ai'` (Gemini Live). |
| `step_up_elevation_enforced` | Boolean | `false` (OFF) | Admin Governance | Mandates 6-digit TOTP verification before approving mutations. |
| `suppression_list_filtering` | Boolean | `true` (ON) | Matching Engine Dispatch | Excludes donors registered in `suppression_list` (DND / opt-out). |
| `strict_spatial_filtering` | Boolean | `true` (ON) | Camp Broadcasting | Strictly bounds camp broadcasts to in-radius donors. |

---

## 3. Flag Lifecycle & Deprecation

1. **Phase 1: In Development** — Flag defined with default `false`. Covered by automated unit and widget tests.
2. **Phase 2: Internal Canary** — Enabled on Staging environment (`staging.bloodnorms.org`).
3. **Phase 3: Controlled Rollout** — Enabled on Production with active monitoring.
4. **Phase 4: Hardening & Cleanup** — Once a flag has run stably in production for 60 consecutive days, the conditional branch is merged as permanent baseline behavior and the flag is retired.
