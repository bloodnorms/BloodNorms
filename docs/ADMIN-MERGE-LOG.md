# BloodNorms — Admin Console Merge Log
**Comprehensive Requirement Decision Matrix (Part B vs. Existing Platform)**  
*Rules: KEEP existing features in place; MERGE overlapping features into unified consoles; add NEW features behind progressive flags.*

---

## 1. Roles, Permissions & Approvals (Section 1)

| Requirement ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `ROL-1` | `public.admin_users.role` (support, admin, super_admin) | **MERGE** | Built-in roles expanded from 3 to 10 (`oncall`, `bank_manager`, `content_editor`, `clinical_reviewer`, `legal_officer`, `analyst`, `finance`) while keeping legacy role column intact. | `RBAC-1` |
| `ROL-2` | Direct boolean admin checks | **NEW** | Module-by-action permission matrix (`module.action`) with deny-by-default logic and custom role builder. | `RBAC-2` |
| `ROL-3` | Phone OTP login | **MERGE** | MFA TOTP (aal2) mandatory for admin access; step-up verification before sensitive actions (exports, role changes). | `RBAC-3` |
| `ROL-4` | None | **NEW** | Break-glass temporary elevation protocol (max 2 hours) with mandatory reason and super admin alert. | `RBAC-4` |
| `APR-1` | None | **NEW** | Four-eyes maker-checker approval matrix (caps, eligibility, AI prompts, broadcasts > 200, Tier 3 exports). | `APR-1` |
| `APR-2` | None | **NEW** | Approvals inbox (pending, mine, history) with diff viewer and 24-hour expiration window. | `APR-2` |

---

## 2. Maintenance Mode & Scoped Switches (Section 2)

| Requirement ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `MNT-1` | Top bar notification & kill switch | **MERGE** | Big Maintenance toggle integrated into Command Center & top bar with ⌘K command shortcut. | `MNT-T1` |
| `MNT-2` | Global toggle | **NEW** | 8 independent maintenance scopes (Web, Donor, Bank, Public, WhatsApp, Phone, API, Admin) with trilingual message editor. | `MNT-T2` |
| `MNT-3` | None | **NEW** | Maintenance scheduling with recurring windows, pre-announcement banners, and one-click extension (+15/30/60m). | `MNT-T3` |
| `MNT-4` | None | **NEW** | In-flight request policy selector (continue active vs. freeze vs. emergency bypass). Default: active continues. | `MNT-T4` |
| `MNT-5` | None | **NEW** | Bypass allowlist for named admins, test phone numbers, and whitelisted testing IP addresses. | `MNT-T5` |
| `MNT-6` | `app_settings.kill_switch_active` | **KEEP** | Kill switch stops outbound dispatches; maintenance governs user UX. Both coexist with amber/red banners. | `MNT-T6` |
| `MNT-7` | Admin write access | **MERGE** | Enabling permitted for admin/oncall; extending >4h requires step-up TOTP; disabling requires admin role. | `MNT-T7` |
| `MNT-8` | None | **NEW** | Optional syndication to public status page and live incident banner. | `MNT-T8` |
| `MNT-9` | None | **NEW** | Cached middleware (5s TTL) with static HTML fallback fail-open architecture. | `MNT-T9` |
| `MNT-10` | `public.audit_logs` | **MERGE** | Maintenance history table logging who, why, duration, and requests impacted. | `MNT-T10` |

---

## 3. Data Export & Reporting Centre (Section 3)

| Requirement ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `EXP-1` | Client-side JSON export | **NEW** | Export builder supporting CSV, XLSX, JSON, and PDF with column choosers, date ranges, and row-count preview. | `EXP-T1` |
| `EXP-2` | None | **NEW** | Asynchronous background export runner via private storage bucket `admin-exports` with 15-min signed links. | `EXP-T2` |
| `EXP-3` | None | **NEW** | Watermarking, exporter SHA-256 hash stamp, and audit record in `data_exports`. | `EXP-T3` |
| `EXP-4` | None | **NEW** | CSV injection prevention (`=`, `+`, `-`, `@` neutralization) and UTF-8 BOM encoding for Telugu/Hindi. | `EXP-T4` |
| `EXP-5` | None | **NEW** | Everywhere Download button on every admin data table and record inspector. | `EXP-T5` |
| `EXP-6` | None | **NEW** | Scheduled automated exports (daily, weekly, monthly) delivered via secure notification links. | `EXP-T6` |
| `EXP-7` | None | **NEW** | Saved export templates and "re-run last export" shortcuts. | `EXP-T7` |
| `EXP-8` | None | **NEW** | Export telemetry and spike detection alerts (e.g. >5 Tier 3 exports in 24 hours). | `EXP-T8` |
| `EXP-9` | None | **NEW** | Config as Code: export/import platform settings, prompts, and rate cards as JSON with diff review. | `EXP-T9` |
| `EXP-10` | None | **NEW** | Safe query builder over allow-listed reporting views (`rpt_*`), strictly excluding health/PII tables. | `EXP-T10` |
| `EXP-LED-1` | `public.requests` query | **MERGE** | Full Request Ledger dataset (Section 3.3) tracking lifecycle, rings, gates, outcomes, and itemized INR costs. | `EXP-T11` |
| `EXP-LED-2` | `public.request_contacts` query | **MERGE** | Full Contact Ledger dataset (Section 3.4) tracking every donor wave, channel result, ETA, and verification code. | `EXP-T12` |
| `EXP-CST-1` | None | **NEW** | Cost computation engine with `cost_rate_card` (Meta, telephony, Gemini AI rates) and `cost_events` ledger. | `COST-T1` |

---

## 4. Module Catalogue (Section 4)

### 4.1 Command Centre (`CMD-1` to `CMD-8`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `CMD-1` | Overview Section KPI cards | **MERGE** | Live strip with active requests, contacted, accepted, standby, exhausted, stuck, and needs-human with SLA colors. | `CMD-T1` |
| `CMD-2` | Inbound tab health status | **MERGE** | Comprehensive health lights (WhatsApp, Telephony, Gemini Live, Supabase, Cloud Run, Hosting, Email, Tick lag). | `CMD-T2` |
| `CMD-3` | Telemetry counters | **MERGE** | Daily numbers display: WhatsApp by category, calls and minutes, AI voice minutes vs cap, spend vs budget. | `CMD-T3` |
| `CMD-4` | None | **NEW** | Alert feed with unacknowledged priority, open incidents, and expiring credentials/tokens. | `CMD-T4` |
| `CMD-5` | Live Map tab | **MERGE** | Multi-layer live map: requests, masked donor supply counts, bank freshness pins, and camp sites. | `CMD-T5` |
| `CMD-6` | Section 9 Kill Switch banner | **MERGE** | Dual-banner status bar: Red banner for Kill Switch, Amber banner for Maintenance Mode, environment badge. | `CMD-T6` |
| `CMD-7` | None | **NEW** | On-call card displaying current responder, next shift handover, and versioned shift notes. | `CMD-T7` |
| `CMD-8` | Fixed grid layout | **MERGE** | Customizable widgets with drag-and-drop layout and personal task inbox. | `CMD-T8` |

### 4.2 Live Requests (`LIV-1` to `LIV-9`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `LIV-1` | Live Monitor Section 1 table | **KEEP** | Interactive table and map with live SLA timers (time to first accept, time to enough donors). | `LIV-T1` |
| `LIV-2` | Widen, Compatible, Freeze, Close | **MERGE** | Extended in-flight controls: change units, urgency, hospital pin, mark fake, mark duplicate with audit trail. | `LIV-T2` |
| `LIV-3` | None | **NEW** | In-request donor controls: manual donor addition, remove contact, force-promote standby, cancel donor. | `LIV-T3` |
| `LIV-4` | None | **NEW** | Requester actions: resend live link, resend gate question, answer gate on behalf (reasoned & audited). | `LIV-T4` |
| `LIV-5` | None | **NEW** | "Why nobody yet?" explainer analyzing exclusion rules per ring without exposing private health data. | `LIV-T5` |
| `LIV-6` | `_contactsSub` stream | **MERGE** | Detailed per-contact audit view showing channel attempts, template IDs, call durations, and status codes. | `LIV-T6` |
| `LIV-7` | None | **NEW** | Printable Request Case File PDF generator with timeline, rings, outcomes, and costs. | `LIV-T7` |
| `LIV-8` | Single-request actions | **NEW** | Bulk emergency operations: freeze all in area, close expired, pause waves during incident. | `LIV-T8` |
| `LIV-9` | Realtime Supabase channels | **MERGE** | Realtime updates with desktop notifications for exhausted requests and abuse flags. | `LIV-T9` |

### 4.3 Needs-Human Case Desk (`NHD-1` to `NHD-5`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `NHD-1` | Section 2 Needs Human queue | **MERGE** | Extended queue types: exhausted rings, callers without WhatsApp, wrong numbers, failed bank codes, complaints. | `NHD-T1` |
| `NHD-2` | Resolve / Escalate actions | **MERGE** | Full case lifecycle: claim, assign, reassign, snooze, due time, SLA breach countdown, internal notes. | `NHD-T2` |
| `NHD-3` | None | **NEW** | Volunteer call scripts with one-tap outcome logging and auto-generated follow-up bank tasks. | `NHD-T3` |
| `NHD-4` | None | **NEW** | Auto-assignment engine (round-robin, language routing, regional territory routing). | `NHD-T4` |
| `NHD-5` | Basic click handlers | **NEW** | Keyboard triage shortcuts (J/K navigation, Enter to open, E to claim), bulk resolve, and duplicate merge. | `NHD-T5` |

### 4.4 Requesters & Abuse Prevention (`REQ-1` to `REQ-5`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `REQ-1` | In-request requester name/phone | **NEW** | Requester profile registry: history, cancellation rate, feedback given, abuse score, and linked devices. | `REQ-T1` |
| `REQ-2` | None | **NEW** | Platform blocklist / never-contact registry with reason, expiry, and masked last-4 lookup. | `REQ-T2` |
| `REQ-3` | None | **NEW** | Algorithmic fake-request detector (velocity, repeated hospitals, odd-hour bursts, duplicate coordinates). | `REQ-T3` |
| `REQ-4` | None | **NEW** | Doctor's prescription slip review desk: view encrypted image, verify badge, and auto-delete on timer. | `REQ-T4` |
| `REQ-5` | `rl_hit` SQL function | **MERGE** | Rate-limit overrides for named phone numbers with temporary expiry and telemetry dashboard. | `REQ-T5` |

### 4.5 Donors (`DON-A1` to `DON-A10`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `DON-A1` | Section 6 Donors Registry table | **MERGE** | Extended filter matrix: state, group, area, channel, trust level, fatigue meters, cooling dates, and tags. | `DON-T1` |
| `DON-A2` | Basic group filters | **NEW** | Dynamic donor segments and bulk messaging/tagging with four-eyes approval for operations >200 donors. | `DON-T2` |
| `DON-A3` | Donor profile card | **MERGE** | Safe profile view: contact history, fatigue counters (6h/7d/monthly), consents. Never health answers or exact pin. | `DON-T3` |
| `DON-A4` | None | **NEW** | "Why not matched?" simulation tool testing donor eligibility against hypothetical requests. | `DON-T4` |
| `DON-A5` | Suspend, Promote, Pause | **MERGE** | Complete donor governance: trust score, blood group confirm, force health re-check, anonymize, delete approval. | `DON-T5` |
| `DON-A6` | None | **NEW** | Duplicate donor detector and merge utility with approval. | `DON-T6` |
| `DON-A7` | None | **NEW** | CSV donor import with per-row consent proof, dry-run validation, approval, and 24-hour rollback. | `DON-T7` |
| `DON-A8` | None | **NEW** | Donor supply intelligence: spatial heatmap, rare-group availability, recruitment funnel, and re-check calendar. | `DON-T8` |
| `DON-A9` | Masked phone display | **MERGE** | Reveal-PII button with reason prompt, MFA step-up, rate limit, and immutable data-access log recording. | `DON-T9` |
| `DON-A10` | None | **NEW** | Multi-tier donor data exporter strictly adhering to privacy constraints. | `DON-T10` |

### 4.6 Donations Ledger (`DNT-1` to `DNT-4`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `DNT-1` | `public.donations` table | **MERGE** | Unified Donations Ledger tracking requests, donors, banks, 6-digit codes, confirmations, and rejections. | `DNT-T1` |
| `DNT-2` | `bank_confirm_donation` | **MERGE** | Admin confirmation/rejection override for code failures, dispute resolution queue, and fraud monitoring. | `DNT-T2` |
| `DNT-3` | None | **NEW** | Confirmation impact preview: calculates donor cooling period, trust increment, and kit eligibility. | `DNT-T3` |
| `DNT-4` | None | **NEW** | Aggregate donation analytics by time period, blood bank, blood group, and recruitment source. | `DNT-T4` |

### 4.7 Blood Banks (`BNK-A1` to `BNK-A10`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `BNK-A1` | Section 5 Banks registry | **MERGE** | Create, edit, deactivate, CSV import, map pin drag-and-drop geocoding QA, and complete audit history. | `BNK-T1` |
| `BNK-A2` | 8-group stock stepper desk | **MERGE** | Stock management with CSV bulk update, history log with source attribution, and single-change rollback. | `BNK-T2` |
| `BNK-A3` | Stock freshness indicator | **MERGE** | Freshness leaderboard ranking banks by staleness, Call-to-verify task queue, and "All unchanged" refresh. | `BNK-T3` |
| `BNK-A4` | Trust score counter | **MERGE** | Trust score adjustments with reason logging, discrepancy reports ("not found"), and reliability scorecards. | `BNK-T4` |
| `BNK-A5` | `public.bank_staff` | **MERGE** | Staff invite manager, role assignments (`bank_admin`, `bank_staff`), deactivation, and facility reassignments. | `BNK-T5` |
| `BNK-A6` | 24x7 chips & hours | **MERGE** | Facility profile: phone directory, licensing details, e-RaktKosh integration ID, partnership MoU documents. | `BNK-T6` |
| `BNK-A7` | None | **NEW** | Automated reminder rules (stale after 12h, max 2/day, quiet hours respect) and test reminder trigger. | `BNK-T7` |
| `BNK-A8` | None | **NEW** | Bank onboarding checklist (site visit, staff invites, initial stock entry, verification training). | `BNK-T8` |
| `BNK-A9` | None | **NEW** | Staff broadcast messaging via approved WhatsApp utility templates with delivery telemetry. | `BNK-T9` |
| `BNK-A10` | None | **NEW** | Multi-tier export for banks, inventory, stock history, and operational scorecards. | `BNK-T10` |

### 4.8 Hospitals, Places & Coverage (`HOS-1` to `HOS-5`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `HOS-1` | Hospital name string in requests | **NEW** | Master hospital directory with multilingual aliases (EN, TE, HI), coordinates, and blood center phones. | `HOS-T1` |
| `HOS-2` | `public.pincodes` table | **MERGE** | PIN code manager with coordinate correction, CSV re-import, and unresolved lookup error logging. | `HOS-T2` |
| `HOS-3` | `AppConstants.defaultPilotCity` | **NEW** | Multi-city coverage manager: polygon boundaries, localized wave minutes, and launch readiness stages. | `HOS-T3` |
| `HOS-4` | None | **NEW** | Geocoding failure review queue with one-click alias resolution. | `HOS-T4` |
| `HOS-5` | None | **NEW** | Multilingual place and blood group terminology dictionary with automated validation tests. | `HOS-T5` |

### 4.9 Camps, Drives & Campaigns (`CMP-1` to `CMP-7`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `CMP-1` | Section 4 Camps table | **MERGE** | Blood donation camp lifecycle: create, edit, venue pin, capacity, attendee check-in, and unit counters. | `CMP-T1` |
| `CMP-2` | None | **NEW** | Institutional blood drive manager (colleges, NSS, corporate) with QR tracking and conversion leaderboards. | `CMP-T2` |
| `CMP-3` | Section 3 Regional Broadcast | **MERGE** | Advanced broadcast builder: audience segmentation, multilingual preview, cost estimation, and approval. | `CMP-T3` |
| `CMP-4` | None | **NEW** | Communication guards: purpose-matched consent verification, weekly message caps, and instant STOP opt-out. | `CMP-T4` |
| `CMP-5` | Broadcast history log | **MERGE** | Campaign calendar with template A/B testing, campaign cloning, and historical archiving. | `CMP-T5` |
| `CMP-6` | None | **NEW** | Campaign audience export and per-recipient delivery funnel reports. | `CMP-T6` |
| `CMP-7` | General consent flags | **NEW** | Specific separate consent tracking for awareness and camp drives as noted in `docs/SIVA-TODO.md`. | `CMP-T7` |

### 4.10 WhatsApp Message Centre (`WAC-1` to `WAC-11`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `WAC-1` | Section 8 telemetry counters | **MERGE** | Granular message counts and costs per template, category (utility, auth, service, marketing), and language. | `WAC-T1` |
| `WAC-2` | Message events log | **MERGE** | WhatsApp delivery funnel (sent, delivered, read, failed) with Meta error codes and plain-language reasons. | `WAC-T2` |
| `WAC-3` | Template editing modal | **MERGE** | Meta template sync, multilingual variable validation, category change alerts, and versioning. | `WAC-T3` |
| `WAC-4` | None | **NEW** | WhatsApp Business Phone number health: quality rating, messaging tier, token expiration countdown. | `WAC-T4` |
| `WAC-5` | `public.message_events` | **MERGE** | Masked message log with request/donor lookup and failed dispatch retry queue. | `WAC-T5` |
| `WAC-6` | Test broadcast trigger | **MERGE** | Direct communications tool: test allowlist message, 24-hour customer service window chat, resend system alert. | `WAC-T6` |
| `WAC-7` | `public.inbound_sessions` | **MERGE** | Conversation session inspector with state transitions, force-expire, and slot inspection. | `WAC-T7` |
| `WAC-8` | None | **NEW** | Human takeover inbox allowing live agent intervention with hand-back-to-bot control. | `WAC-T8` |
| `WAC-9` | STOP keyword handler | **MERGE** | Opt-out compliance desk: STOP counts, per-template opt-out spikes, and manual opt-in proof repository. | `WAC-T9` |
| `WAC-10` | None | **NEW** | Versioned trilingual quick-reply canned responses for support staff. | `WAC-T10` |
| `WAC-11` | None | **NEW** | Webhook telemetry log with replay capabilities and signature validation counters. | `WAC-T11` |

### 4.11 Calls & Telephony (`CAL-1` to `CAL-7`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `CAL-1` | Telephony call telemetry | **MERGE** | Call metrics: calls and minutes by provider, language, outcome, concurrency peaks, and calculated cost. | `CAL-T1` |
| `CAL-2` | Provider selector (Twilio/Exotel) | **MERGE** | Telephony provider manager: virtual numbers inventory, renewal dates, balance monitoring, low-balance alerts. | `CAL-T2` |
| `CAL-3` | Calling hours & retries | **MERGE** | Outbound calling policy: calling windows, retry backoff intervals, caller ID rotation, urgency thresholds. | `CAL-T3` |
| `CAL-4` | Twilio IVR Edge Function | **MERGE** | Keypad IVR menu tree editor with multilingual TTS generation, preview, and test-call bench. | `CAL-T4` |
| `CAL-5` | `public.voice_calls` | **MERGE** | Masked call log with request linkage, drop reasons, and fallback-to-keypad events. | `CAL-T5` |
| `CAL-6` | None | **NEW** | Inbound telephony controls: inbound toggle, caller blocklist, and after-hours emergency message. | `CAL-T6` |
| `CAL-7` | None | **NEW** | Callback queue for callers requesting telephone assistance. | `CAL-T7` |

### 4.12 AI Voice Studio (`AIV-1` to `AIV-13`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `AIV-1` | Section 7 Prompt & Persona editor | **MERGE** | Multilingual prompt manager (EN, TE, HI) with draft, test, approval, diff viewer, and rollback. | `AIV-T1` |
| `AIV-2` | Fixed lines in prompt | **MERGE** | Fixed lines editor: 108 emergency redirection, financial refusal, silence fillers, repeat-back lines. | `AIV-T2` |
| `AIV-3` | None | **NEW** | Safety linter blocking prompt publication if mandatory 108 safety lines or boundaries are removed. | `AIV-T3` |
| `AIV-4` | Temperature & minutes cap | **MERGE** | Voice settings: engine selection (Gemini Live), voice sample auditioning, language fallback, daily cap. | `AIV-T4` |
| `AIV-5` | Section 7 Triage Simulator | **MERGE** | Automated 60-dialogue evaluation runner with 95% pass-rate requirement before live publishing. | `AIV-T5` |
| `AIV-6` | None | **NEW** | Human listening test rater sheets (naturalness, understanding, pronunciation, safety). | `AIV-T6` |
| `AIV-7` | None | **NEW** | Canary rollout engine (10% traffic split to evaluate fallback rate against production baseline). | `AIV-T7` |
| `AIV-8` | Inbound session list | **MERGE** | Live session monitor showing state, slots, and tool names only (strictly zero audio or transcripts stored). | `AIV-T8` |
| `AIV-9` | None | **NEW** | AI voice issue tracker linking reported misunderstandings to specific prompt versions. | `AIV-T9` |
| `AIV-10` | None | **NEW** | Multilingual pronunciation dictionary for blood groups, hospital landmarks, and Godavari place names. | `AIV-T10` |
| `AIV-11` | None | **NEW** | Keypad fallback analytics tracking why calls dropped from Gemini Live to IVR. | `AIV-T11` |
| `AIV-12` | Telemetry counters | **MERGE** | AI voice cost telemetry: minutes consumed, cost per fulfilled request, and budget forecasts. | `AIV-T12` |
| `AIV-13` | None | **NEW** | Ephemeral staging-only debug transcript capture with 24-hour auto-purge (strictly forbidden in prod). | `AIV-T13` |

### 4.13 Matching Engine Control (`ENG-A1` to `ENG-A9`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `ENG-A1` | Section 9 Engine settings | **MERGE** | Engine tuning: rings, wave minutes, multipliers, fatigue limits, and municipal overrides. | `ENG-T1` |
| `ENG-A2` | Bio limits in onboarding | **MERGE** | Medical eligibility constants (18-65 age, >=45kg weight, donation gaps) with clinical approval. | `ENG-T2` |
| `ENG-A3` | 10 Health questions | **MERGE** | Health question set versioning with clinical reviewer sign-off. Answers remain strictly encrypted. | `ENG-T3` |
| `ENG-A4` | None | **NEW** | Dry-run engine simulator testing candidate count per ring on hypothetical requests without messaging. | `ENG-T4` |
| `ENG-A5` | `engine-tick` Edge Function | **MERGE** | Matching engine telemetry: tick lag, queue size, lease ownership, and dead-letter retry desk. | `ENG-T5` |
| `ENG-A6` | Platform Kill Switch | **MERGE** | Scoped kill switch: global, WhatsApp only, calls only, new requests only, donor alerts only. | `ENG-T6` |
| `ENG-A7` | None | **NEW** | Disaster Mode: temporary expansion of search rings and wave caps for mass-casualty events with expiry. | `ENG-T7` |
| `ENG-A8` | `public.app_settings` flags | **MERGE** | Centralized Feature Flag Management console (REL-1). | `ENG-T8` |
| `ENG-A9` | Compatibility test suite | **KEEP** | Read-only blood group compatibility matrix and rules-in-force auditor. | `ENG-T9` |

### 4.14 Content, Localisation & Legal Texts (`CNT-1` to `CNT-6`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `CNT-1` | `AppLocalizations` classes | **MERGE** | Copy deck editor for all string keys in EN, TE, HI with automated 28-character budget validator. | `CNT-T1` |
| `CNT-2` | None | **NEW** | Native speaker translation workflow with diff viewer and review sign-offs. | `CNT-T2` |
| `CNT-3` | Static help pages | **MERGE** | Multilingual FAQ, how-it-works, and error message publisher with 80-character maximum brevity. | `CNT-T3` |
| `CNT-4` | Onboarding consents | **MERGE** | Versioned Privacy Policy and Terms of Service editor with legal officer approval and re-consent triggers. | `CNT-T4` |
| `CNT-5` | None | **NEW** | Release notes publisher, public incident announcement editor, and certificate copy customizer. | `CNT-T5` |
| `CNT-6` | None | **NEW** | Multilingual, multi-device preview simulator before publishing copy updates. | `CNT-T6` |

### 4.15 Safety, Incidents & Data Rights (`SAF-1` to `SAF-8`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `SAF-1` | None | **NEW** | Safety reports queue: abuse complaints, wrong-number reports, and bank mismatch grievances. | `SAF-T1` |
| `SAF-2` | None | **NEW** | Wrong-person and privacy incident register (always P1 priority) with immediate notification runbook. | `SAF-T2` |
| `SAF-3` | None | **NEW** | P1 to P4 Incident management desk with public status-page syndication and 3-day post-mortem review. | `SAF-T3` |
| `SAF-4` | Donor Profile DPDP Export/Delete | **MERGE** | DPDP Act Data-Rights Queue (Export, Delete, Rectify, Withdraw) with 7-day statutory clock tracking. | `SAF-T4` |
| `SAF-5` | `public.consents` table | **MERGE** | Consent audit explorer tracking timestamp, version, and channel for every donor consent. | `SAF-T5` |
| `SAF-6` | `0002_cron.sql` cleanup jobs | **MERGE** | Retention monitor verifying automated purge jobs (rate limits 2d, messages 90d, requests 90d). | `SAF-T6` |
| `SAF-7` | None | **NEW** | Formal statutory data breach register and Grievance Officer desk. | `SAF-T7` |
| `SAF-8` | Kill switch | **MERGE** | Panic protocol: freeze all outbound, revoke all ephemeral capability links, force-logout all admins. | `SAF-T8` |

### 4.16 Analytics & Reports (`ANL-1` to `ANL-8`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `ANL-1` | Overview metrics ribbon | **MERGE** | Comprehensive PRD Section 1.1 KPI dashboard with historical trends, targets, and SLO error budgets. | `ANL-T1` |
| `ANL-2` | None | **NEW** | Multi-dimensional conversion funnel (Request &rarr; Contacted &rarr; Agreed &rarr; Donated). | `ANL-T2` |
| `ANL-3` | None | **NEW** | Unmet demand analytics: spatial map of exhausted requests and donor shortages by blood group. | `ANL-T3` |
| `ANL-4` | Donor stats | **MERGE** | Donor cohort retention, response velocity by time of day, and fatigue correlation. | `ANL-T4` |
| `ANL-5` | Bank scorecards | **MERGE** | Blood bank accuracy and freshness trends based on requester fulfillment feedback. | `ANL-T5` |
| `ANL-6` | None | **NEW** | Unit economics dashboard: cost per contact, cost per accept, cost per verified unit by channel. | `ANL-T6` |
| `ANL-7` | None | **NEW** | Custom reporting query builder with small-number suppression (<5) on all aggregate metrics. | `ANL-T7` |
| `ANL-8` | None | **NEW** | Period-over-period comparative analysis with event annotations (e.g. camps held, policy changes). | `ANL-T8` |

### 4.17 Finance, Cost & Renewals (`FIN-1` to `FIN-5`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `FIN-1` | None | **NEW** | Provider spend tracker (Meta, Telephony, Gemini Live, Supabase, Cloud Run) with budget variance. | `FIN-T1` |
| `FIN-2` | None | **NEW** | Rate-card configuration desk with four-eyes approval and retrospective cost recalculation. | `FIN-T2` |
| `FIN-3` | Minutes cap | **MERGE** | Multi-resource spend caps (daily contacts, AI minutes, monthly INR budget) with 50/80/100% threshold alerts. | `FIN-T3` |
| `FIN-4` | None | **NEW** | Renewals calendar: WhatsApp Business tokens, virtual number leases, domain names, and SSL certs. | `FIN-T4` |
| `FIN-5` | None | **NEW** | Cost anomaly detection alerts notifying super admin of unexpected billing surges. | `FIN-T5` |

### 4.18 Integrations & System Health (`SYS-1` to `SYS-8`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `SYS-1` | Inbound gateway health | **MERGE** | Infrastructure health monitors: Meta API, Telephony, Gemini Live, Cloud Run Gateway, Supabase DB. | `SYS-T1` |
| `SYS-2` | None | **NEW** | Webhook telemetry inspector with replay tool and idempotency table viewer. | `SYS-T2` |
| `SYS-3` | None | **NEW** | Secrets inventory register tracking rotation schedules (values are strictly never displayed). | `SYS-T3` |
| `SYS-4` | `0002_cron.sql` jobs | **MERGE** | Background cron jobs monitor tracking last run, duration, and manual trigger for safe jobs. | `SYS-T4` |
| `SYS-5` | None | **NEW** | Database health: storage consumption vs quota, active connection pool, migration execution status. | `SYS-T5` |
| `SYS-6` | None | **NEW** | API rate-limit monitoring and error-taxonomy classification. | `SYS-T6` |
| `SYS-7` | None | **NEW** | Environment configuration checklist, allowlist status, and active deployment version stamp. | `SYS-T7` |
| `SYS-8` | `0003_storage.sql` | **MERGE** | Private storage bucket browser (prescription slips, export files) with age tracking and manual purge. | `SYS-T8` |

### 4.19 Admin Users, Security & Audit (`ADU-1` to `ADU-6`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `ADU-1` | `public.admin_users` table | **MERGE** | Master admin directory: phone invitation, role assignment, MFA status, session revocation. | `ADU-T1` |
| `ADU-2` | Section 10 Audit Logs | **MERGE** | Append-only audit trail with tamper-evident hash chaining and data-access logging (who viewed PII & why). | `AUD-1` |
| `ADU-3` | None | **NEW** | Per-administrator alert subscriptions, notification channels, and quiet-hour rules. | `ADU-T3` |
| `ADU-4` | None | **NEW** | On-call duty roster, shift calendar, handover checklists, and swap requests. | `ADU-T4` |
| `ADU-5` | None | **NEW** | Break-glass elevation register with required 24-hour post-incident review tasks. | `ADU-T5` |
| `ADU-6` | None | **NEW** | Security posture overview: MFA adoption rate, stale accounts, failed logins, and export volumes. | `ADU-T6` |

### 4.20 Support Desk (`SUP-1` to `SUP-4`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `SUP-1` | None | **NEW** | Unified user timeline lookup by last 4 digits of phone or request ID (requests, messages, calls). | `SUP-T1` |
| `SUP-2` | Basic donor actions | **MERGE** | Support actions: resend message, manual opt-out/in with proof, donor pause, data anonymization. | `SUP-T2` |
| `SUP-3` | None | **NEW** | Inbound ticket inbox generated from HELP/REPORT messages and web forms with trilingual canned replies. | `SUP-T3` |
| `SUP-4` | Bank feedback modal | **MERGE** | User feedback & rating desk; testimonials stored and published strictly with verified user consent. | `SUP-T4` |

### 4.21 Partners, CRM & Expansion (`PRT-1` to `PRT-4`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `PRT-1` | None | **NEW** | Partner outreach CRM (hospitals, blood banks, colleges, NGOs, NSS clubs) with stage pipeline and MoUs. | `PRT-T1` |
| `PRT-2` | None | **NEW** | Campus ambassador program and referral code tracking with donor recruitment counts. | `PRT-T2` |
| `PRT-3` | None | **NEW** | Multi-city expansion launcher: milestone checklists, donor/bank targets, and launch stage gates. | `PRT-T3` |
| `PRT-4` | None | **NEW** | TRD Section 20 Launch Quality Gate checklist with verification evidence upload and sign-offs. | `PRT-T4` |

### 4.22 Kits & Recognition (`KIT-1` to `KIT-3`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `KIT-1` | None | **NEW** | Donor appreciation kit fulfillment queue (eligible, address collected post-donation, packed, shipped). | `KIT-T1` |
| `KIT-2` | Milestone Badges & Certificates | **KEEP** | Non-monetary recognition engine (Bronze Hero to Centurion) and digital appreciation certificates. | `KIT-T2` |
| `KIT-3` | None | **NEW** | Courier shipping batch exporter (Tier 3 full identifier export with mandatory approval). | `KIT-T3` |

### 4.23 Sandbox & Testing (`SBX-1` to `SBX-4`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `SBX-1` | None | **NEW** | Test mode banner and testing allowlist manager; production allowlist verified strictly empty. | `SBX-T1` |
| `SBX-2` | AI Triage Simulator | **MERGE** | End-to-end request simulation bench with synthetic donors, test WhatsApp messages, and test voice calls. | `SBX-T2` |
| `SBX-3` | None | **NEW** | User Acceptance Testing (UAT) trackable task checklists with evidence logging. | `SBX-T3` |
| `SBX-4` | None | **NEW** | Synthetic data generator (staging-only) with one-click database reset capability. | `SBX-T4` |

### 4.24 Alert Rules & Notification Centre (`ALR-1` to `ALR-3`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `ALR-1` | None | **NEW** | Configurable alert thresholds for TRD Section 14 (outages, tick stall, send failures, spend limits). | `ALR-T1` |
| `ALR-2` | None | **NEW** | Multi-channel delivery (WhatsApp, Email, In-App) with on-call escalation and temporary mute. | `ALR-T2` |
| `ALR-3` | `DuoNotificationBell` widget | **MERGE** | Centralized admin inbox consolidating alerts, approval requests, and @mentions with read state tracking. | `ALR-T3` |

### 4.25 Donor Engagement Automation (`AUT-1` to `AUT-3`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `AUT-1` | None | **NEW** | Automation rule builder: cooling period elapsed reminders, health re-check reminders, camp invitations. | `AUT-T1` |
| `AUT-2` | None | **NEW** | Per-rule audience previews, cost estimates, quiet-hour compliance, and execution run history. | `AUT-T2` |
| `AUT-3` | Fatigue rules in engine | **MERGE** | Global fatigue safeguard ensuring automated messages never exceed donor frequency thresholds. | `AUT-T3` |

### 4.26 Feedback & Surveys (`FDB-1` to `FDB-2`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `FDB-1` | Post-fulfillment feedback | **MERGE** | Trilingual post-request requester rating and donor pulse survey with configurable questions. | `FDB-T1` |
| `FDB-2` | None | **NEW** | Feedback analytics dashboard with automated profanity filtering and Tier 1/2 export capabilities. | `FDB-T2` |

### 4.27 Runbooks & Knowledge Base (`RBK-1` to `RBK-2`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `RBK-1` | None | **NEW** | Interactive operational runbooks (Kill Switch, Token Renewal, Database Restore, Telephony Outage). | `RBK-T1` |
| `RBK-2` | None | **NEW** | "Run a Drill" simulation mode recording response timings and linking runbooks to incident tickets. | `RBK-T2` |

### 4.28 Data Quality Centre (`DQ-1` to `DQ-3`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `DQ-1` | None | **NEW** | Data anomaly detectors: duplicate donors, unreachable phone numbers, unmapped PIN codes, stock glitches. | `DQ-T1` |
| `DQ-2` | None | **NEW** | One-click guided data fix utility with preview and rollback. | `DQ-T2` |
| `DQ-3` | None | **NEW** | Platform Data Health Score calculation with historical trend tracking. | `DQ-T3` |

### 4.29 Releases & Feature Flags (`REL-1` to `REL-3`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `REL-1` | `app_settings.feature_flags` | **MERGE** | Master Feature Flag Centre with owner, default states, municipal/percentage rollouts, and approval hooks. | `REL-T1` |
| `REL-2` | None | **NEW** | Deployment history registry with current build hash, release notes, and redeployment rollback checklist. | `REL-T2` |
| `REL-3` | None | **NEW** | Platform Read-Only Mode toggle preventing admin mutations during sensitive deployments. | `REL-T3` |

### 4.30 Global Search, Productivity & History (`GSR-1` to `GSR-6`)
| ID | Existing Item | Decision | Notes | Test ID |
|---|---|---|---|---|
| `GSR-1` | Section search controller | **MERGE** | Unified ⌘K / Ctrl+K Global Command Palette searching requests, masked donors, banks, and action commands. | `GSR-T1` |
| `GSR-2` | None | **NEW** | Field-level record revision history on all editable entities with one-click restore. | `GSR-T2` |
| `GSR-3` | None | **NEW** | 30-day Recycle Bin for banks, camps, campaigns, and templates (excluding privacy erasures). | `GSR-T3` |
| `GSR-4` | None | **NEW** | Saved views, pinned filter shortcuts, internal record comments with @mentions, and record watch lists. | `GSR-T4` |
| `GSR-5` | None | **NEW** | Bulk operations framework with dry-run verification, progress bar, undo window, and operations log. | `GSR-T5` |
| `GSR-6` | None | **NEW** | Printable PDF and CSV export generation across all admin data tables. | `GSR-T6` |

