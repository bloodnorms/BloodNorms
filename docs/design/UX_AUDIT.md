# BloodNorms — Admin Console UX Audit (UX_AUDIT.md)

**Role:** Principal Product Designer & Senior Frontend Engineer  
**Date:** November 2026  
**Scope:** Complete BloodNorms Executive Operations & Admin Command Center (`/admin`)  
**Design Inspiration:** Clean, airy, minimal, soft-pill design language inspired by Google Stitch (`stitch.withgoogle.com`)  
**Status:** Audit Complete  

---

## 1. Executive Summary & Problem Statement

The BloodNorms Admin Console provides operations management across emergency donor matching, hospital blood stock, volunteer camps, WhatsApp alerts, AI voice helpline triage, and four-eyes security governance.

While functionally complete, the current user experience suffers from visual and cognitive friction:
1. **Dark & Heavy Aesthetic:** The existing `#121316` dark sidebar and `#1F1F1F` high-density frames feel heavy, intimidating, and industrial rather than calm and welcoming.
2. **Action Confusion (Too Many Competing Buttons):** Screens frequently place 2 to 4 filled red or green buttons side-by-side with equal visual weight, violating the "One screen, one job" rule.
3. **Information Overload:** Dense data tables with 8–10 columns are displayed on initial load without progressive disclosure, overwhelming operators under emergency stress.
4. **Hardcoded Styling & Inconsistent Radii:** Button and card corners vary between 8px, 12px, 16px, and 24px across different sub-views, with raw hex colors scattered in component files.

---

## 2. Comprehensive Screen & View Inventory

The Admin Console contains 24 modular sub-views routed via `AdminWorkspaceRouter` and `AdminSidebar`:

| Screen / View ID | Route / View Name | User's ONE Main Goal | Main Action Today | Clicks to Act | Confusion & Cognitive Noise Today |
|---|---|---|---|---|---|
| **V01: Cockpit** | `dashboard` | Get real-time situational awareness of active crises | Open Crisis Radar | 1 click | 5 red stat cards competing for attention; dense emergency requests table below the fold. |
| **V02: Radar** | `crisis_radar` | Monitor expanding search rings in real-time | Widen Search (+5 km) | 1 click | Radar pulse animation is visually busy; lacks friendly empty state when no active emergency. |
| **V03: Needs Human** | `needs_human` | Triage requests where matching engine reached max rings | Call Hospital Coordinator | 1 click | Technical error logs shown by default instead of plain human instructions. |
| **V04: Broadcast** | `broadcast_dispatch` | Send geo-targeted emergency alert to volunteer donors | Dispatch Broadcast | 2 clicks | 3 sliders, city drop-downs, and audience counters packed in a single card with no visual hierarchy. |
| **V05: Broadcast History**| `broadcast_history` | Review past emergency broadcast dispatches & delivery | Filter Past Broadcasts | 1 click | Dense table with technical message IDs and raw timestamps. |
| **V06: Camps Manager** | `camps` | Schedule and coordinate community blood donation drives | Add New Blood Camp | 1 click | Long form in dialog with 10 fields; lacks progressive disclosure. |
| **V07: Bank Stock** | `blood_banks_stock` | Monitor and balance emergency blood unit inventories | Update Units (+/-) | 1 click | 8 blood group steppers in a dense grid; numbers feel small and hard to read at a glance. |
| **V08: Donors Registry** | `donors_registry` | Look up volunteer donor profiles & verify availability | Pause / Unpause Donor | 1 click | Full table showing 8 columns; search bar not prominent. |
| **V09: Hospitals** | `hospitals_registry` | Manage verified partner hospitals & helplines | Verify New Hospital | 1 click | Lacks quick phone dial action; coordinates shown as raw numbers. |
| **V10: Requester Shield**| `requester_shield` | Protect platform against automated phone spam | Block Abusive Number | 1 click | Red flags and technical abuse metrics presented aggressively. |
| **V11: Partners** | `community_partners` | Coordinate with youth NGO & university networks | Add Partner Chapter | 1 click | Cluttered cards with non-standard card padding. |
| **V12: Approvals** | `approvals_queue` | Four-eyes maker-checker authorization for mutations | Approve / Reject | 2 clicks | Warning banner is harsh yellow; approval reasons not prominently displayed. |
| **V13: Data Exports** | `data_exports` | Generate sanitized compliance and operational reports | Export Tier 2 Masked CSV | 1 click | Technical CSV format jargon; Tier 3 request flow lacks clear guidance. |
| **V14: DPDP Registry** | `dpdp_registry` | Process user erasure requests & manage DND list | Process Erasure Request | 1 click | Legalistic wording; suppression list hash shown raw. |
| **V15: Killswitch** | `killswitch_settings` | Immediate platform-wide emergency pause | Activate Killswitch | 2 clicks | Warning icons flashing; feels frightening rather than calm and controlled. |
| **V16: Safety Desk** | `safety_desk` | Review clinical deferrals and donor adverse incidents | Log Safety Incident | 1 click | Medical clinical codes shown without plain-language explanations. |
| **V17: Algorithm** | `algorithm_settings` | Tune matching rings, wave timings, and gates | Save Ring Parameters | 1 click | 14 ring inputs in a raw text grid; easy to make typos. |
| **V18: Audit Trail** | `audit_logs` | Security & compliance audit log forensics | Search Audit Logs | 1 click | JSON payload viewer is technical and uncapped in width. |
| **V19: Voice Prompts** | `voice_prompts` | Version telephony agent conversational prompts | Save Prompt Version | 1 click | Wide monospace textarea with small save button at bottom. |
| **V20: Voice Sim** | `voice_simulator` | Simulate phone call with Gemini Live speech assistant | Start Test Call | 1 click | Two competing buttons ("Start Call" and "Reset Session"); waveform looks noisy. |
| **V21: Voice Safety** | `voice_safety` | Run trilingual clinical safety benchmark | Run 60-Dialogue Eval | 1 click | Progress bar is thin; test case list is dense. |
| **V22: WhatsApp Bot** | `whatsapp_bot` | Test interactive WhatsApp bot triage conversation | Send Test Message | 1 click | Simulator chat bubbles cramped; raw JSON debug toggle visible. |
| **V23: WhatsApp Templates**| `whatsapp_templates`| Review Meta-approved notification templates | Edit Template Copy | 1 click | Preview bubble styling doesn't match authentic WhatsApp message view. |
| **V24: WhatsApp Gateway**| `whatsapp_telecom` | Monitor Meta Graph API credentials & throughput | Test Connection | 1 click | Token input shows warning banner; diagnostic steps scattered. |

---

## 3. UI Component & Styling Architecture Inventory

### 3.1 Styling Engine
- **Framework:** Flutter Material 3 (`useMaterial3: true`).
- **Styling Architecture:** Dart token classes (`BrandColors`, `BrandTypography`, `AppTheme`).
- **Current Aesthetic:** 3D tactile paper cards with 4px drop shadows (`bevelHeight = 4.0`), cardinal red primary identity (`#E52E2E`), and dark charcoal chrome (`#121316`).

### 3.2 Target Aesthetic (Inspired by Google Stitch)
- **Theme:** Pure light theme (`#FFFFFF` background, `#F8F9FA` soft surface, `#F1F3F4` muted hover).
- **Controls:** Fully rounded pill-shaped buttons, chips, and segmented controls (`BorderRadius.circular(999)`).
- **Cards:** 16px radius (`BorderRadius.circular(16)`), 1px subtle border (`#E8EAED`), flat or soft floating elevation (`0 8px 24px rgba(32,33,36,0.06)`).
- **Primary Button:** Confident near-black pill (`#1F1F1F`) with crisp white text. Exactly ONE per screen.
- **Accent:** Blue-violet `#5B5BF0` with soft tint `#EEF0FF` for active navigation pills and focus rings.
- **Typography:** Clean geometric sans-serif (Arial/system fallback) with generous line heights and sentence case everywhere.
- **Icons:** Material Symbols Rounded style, 400 weight, thin outline, always accompanied by words for primary actions.

---

## 4. Top UX Deficiencies to Resolve

1. **Eliminate the Dark Sidebar:** Replace the heavy `#121316` sidebar with a soft `#F8F9FA` surface featuring pill-shaped active items (`#EEF0FF` tint with `#5B5BF0` text).
2. **Apply the "One Screen, One Job" Rule:** Every view gets a standard `PageHeader` with a clear title, friendly one-line description, and a single prominent near-black pill action button in the top-right.
3. **Make Targets Forgiving:** All buttons, chips, and inputs must have a minimum tap target height of 44px with generous spacing.
4. **Calm Empty & Error States:** Replace blank tables and raw error texts with friendly illustrations, plain Grade-5 language, and single obvious recovery buttons.
5. **Prompt-Style Composer for Broadcasts:** Redesign the emergency broadcast view into an expansive, softly rounded composer with segmented choices below.
