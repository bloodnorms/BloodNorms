# BloodNorms Authentication Architecture & GoTrue Hygiene Policy

**Document Reference:** SEC-AUTH-001  
**Classification:** Internal Security Standard  
**Subsystem:** Supabase Auth (GoTrue) & Application Identity Management

---

## 1. Authentication Configuration Parameters

| Parameter | Recommended Setting | Production Rationale |
|---|---|---|
| **JWT Access Token Expiry** | 900 seconds (15 minutes) | Limits exposure window if a client token is intercepted. |
| **Refresh Token Expiry** | 30 days | Balances seamless mobile login with bounded session lifetime. |
| **Refresh Token Rotation** | **ENABLED** | Every refresh issues a new token; older tokens are invalidated immediately. |
| **Detect Refresh Token Reuse**| **ENABLED** | If a used token is presented, all sessions for the user are immediately revoked. |
| **Minimum Password Length** | 12 characters | Prevents brute-force dictionary attacks against staff accounts. |
| **Password Complexity** | Uppercase, lowercase, digits, symbols | Enforces entropy on administrative credentials. |
| **Multi-Factor Auth (MFA)** | Enforced for Admin / Staff | Mandatory TOTP authenticator app verification. |
| **Email Confirmation** | Enabled | Verifies ownership before grant of elevated privileges. |
| **Anonymous Sign-Ins** | Disabled in production | Prevents fake user creation and role confusion. |

---

## 2. JWT Claims & Authorization Rules

> [!CAUTION]
> **Never use `user_metadata` in RLS policies or authorization checks.**
> In Supabase GoTrue, `raw_user_meta_data` is freely modifiable by the end-user via `supabase.auth.updateUser()`. Any role, tenant, or permission stored in `user_metadata` can be spoofed by a malicious client.

### Authorized Claims Placement
- **Role & Tenant Assignment:** Stored exclusively in `raw_app_meta_data` (set only by `service_role` or database triggers) or relational tables (`public.profiles`, `public.bank_staff`).
- **RLS Query Pattern:** Always check `auth.uid()` against verified database tables:
  ```sql
  -- Correct Pattern: Database Table Lookup
  create policy "bank_staff_read" on public.bank_stock
    for select to authenticated
    using (
      exists (
        select 1 from public.bank_staff
        where bank_staff.bank_id = bank_stock.bank_id
          and bank_staff.user_id = (select auth.uid())
      )
    );
  ```

---

## 3. Session Revocation & Step-Up Governance

1. **Remote Session Revocation:** When an admin account exhibits anomalous activity, all active refresh tokens in `auth.refresh_tokens` are deleted, forcing instant re-authentication across all mobile and web devices.
2. **Break-Glass Emergency Escalation:** High-impact operations (releasing regional kill switch, altering spending caps, executing Tier 3 exports) mandate a fresh 6-digit numeric step-up passcode and a minimum 10-character justified reason recorded in `audit_logs`.
3. **Four-Eyes Governance:** Maker-checker enforcement requires two distinct authorized users (`checker_id <> maker_id`).

---

## 4. Supabase Dashboard Configuration Checklist

The following controls are managed exclusively through the Supabase Cloud Management Dashboard and cannot be set via SQL migrations:

- [ ] **Auth -> URL Configuration:**
  - Site URL set strictly to production domain: `https://app.bloodnorms.org`
  - Redirect URLs allowlist limited strictly to:
    - `https://app.bloodnorms.org/**`
    - `io.bloodnorms.app://login-callback`
    - `http://localhost:3000/**` (Development environment only)
- [ ] **Auth -> Security:**
  - Enable "Secure email change" (requires verification of both old and new addresses).
  - Enable "Manual linking" for third-party OAuth providers.
- [ ] **Auth -> Multi-Factor (MFA):**
  - Enable TOTP factor.
  - Set Max Enrolled Factors to 2.
- [ ] **Auth -> Rate Limits:**
  - Email signups: 10 per hour per IP.
  - SMS OTPs: 5 per hour per phone number.

