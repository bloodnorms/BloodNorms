# 🩸 BloodNorms

> **Emergency Blood-Donor Finder for India — Fast, Real, Safe.**

BloodNorms is a full-stack emergency blood coordination platform built for India, initially piloted in **Rajahmundry, Andhra Pradesh**. It connects blood requesters, volunteer donors, blood bank staff, and platform administrators through a unified, real-time system — combining a **Flutter cross-platform app**, a **Supabase PostgreSQL backend**, a **WhatsApp AI chatbot** (served via Vercel serverless functions), and a **comprehensive admin command center**.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Key Features](#-key-features)
3. [System Architecture](#-system-architecture)
4. [Technology Stack](#-technology-stack)
5. [Application Portals & User Roles](#-application-portals--user-roles)
   - [Requester Portal](#1-requester-portal-public-web--mobile)
   - [Donor App](#2-donor-app-donordart)
   - [Blood Bank Console](#3-blood-bank-console-bank)
   - [Admin Console](#4-admin-console-admin)
6. [WhatsApp AI Concierge (Serverless Backend)](#-whatsapp-ai-concierge-serverless-backend)
7. [Database Architecture](#-database-architecture)
   - [Core Enums](#core-enums)
   - [Tables Overview](#tables-overview)
   - [Key RPC Functions](#key-rpc-functions)
   - [Row Level Security (RLS)](#row-level-security-rls)
   - [Realtime Channels](#realtime-channels)
8. [Database Migrations](#-database-migrations)
9. [Navigation & Routing](#-navigation--routing)
10. [State Management](#-state-management)
11. [Design System](#-design-system)
12. [Internationalization (i18n)](#-internationalization-i18n)
13. [Maps & Geolocation](#-maps--geolocation)
14. [AI & Voice Integration](#-ai--voice-integration)
15. [Security & Compliance](#-security--compliance)
16. [Cost & Financial Telemetry](#-cost--financial-telemetry)
17. [RBAC — Roles & Permissions](#-rbac--roles--permissions)
18. [CI/CD Pipeline](#-cicd-pipeline)
19. [Deployment](#-deployment)
20. [Environment Configuration](#-environment-configuration)
21. [Project Structure](#-project-structure)
22. [Getting Started](#-getting-started)
23. [Seed Data](#-seed-data)
24. [Testing](#-testing)

---

## 🌐 Project Overview

BloodNorms solves a critical, life-threatening gap in emergency healthcare in India: the inability to quickly locate and mobilize blood donors during a medical crisis. The platform operates across multiple channels:

- **Web App** (Flutter Web, deployed on Vercel) — Accessible from any browser.
- **Android & iOS Apps** — Native mobile experiences via Flutter.
- **WhatsApp Bot** — AI-powered emergency intake for anyone with a WhatsApp number, no app download required.
- **24×7 Helpline** — Phone-based intake with AI voice concierge.

**Pilot City:** Rajahmundry, East Godavari District, Andhra Pradesh, India  
**Coordinates:** Lat 17.0005, Lng 81.7800  
**Production URL:** [https://bloodnorms.vercel.app](https://bloodnorms.vercel.app)

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🚨 Emergency Request Wizard | 6-step guided wizard: blood group → units → location → hospital → details → review & send |
| 📡 Live Donor Radar | Real-time OpenStreetMap map showing expanding search rings and accepted donors |
| 💬 WhatsApp AI Concierge | Stateful 5-step WhatsApp intake using OpenRouter LLM (Priya bot) |
| 🩺 Donor Portal | Full donor lifecycle: onboarding, availability toggle, alerts, camps, badges |
| 🏥 Blood Bank Console | Staff portal for real-time stock updates, donation confirmation via 6-digit OTP |
| 🛡️ Admin Command Center | Full platform oversight: 10 roles, approval queues, broadcasts, kill switch, telemetry |
| 🎖️ Donor Badges & Milestones | Bronze → Silver → Gold → Platinum → Diamond badge progression system |
| 📢 Geo-Targeted Broadcasts | Regional WhatsApp/SMS broadcasts with four-eyes approval for >200 recipients |
| 🗓️ Blood Donation Camps | Bank staff can create, manage, and check-in donors at donation drives |
| 🔔 In-App Notification Center | Real-time notification system for emergencies, camps, and milestones |
| 🌍 Multilingual Support | English, Telugu (తెలుగు), Hindi (हिन्दी) |
| 🔒 Privacy-First Architecture | Donor PII partitioned in separate tables; phone numbers never shared without consent |
| ⚖️ DPDP Act Compliance | Suppression registry, 90-day ephemeral data purge, immutable audit logs |
| 💰 Cost Guardrails | Per-request cost tracking for WhatsApp, voice, and AI services in INR |
| 📊 Platform Telemetry | Usage events ledger, admin analytics, aggregate exports |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER (Flutter)                          │
│                                                                         │
│   Requester App (/)  │  Donor App (/donor)  │  Bank Console (/bank)    │
│                      │                      │  Admin Console (/admin)  │
│         Flutter Web + Android + iOS (GoRouter, Riverpod)               │
└────────────────────────────┬────────────────────────────────────────────┘
                             │  supabase_flutter SDK
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     SUPABASE BACKEND                                    │
│                                                                         │
│  PostgreSQL 16 + PostGIS 3.4   │  Auth (Phone OTP / Magic Link)        │
│  21 SQL Migrations             │  Realtime WebSocket Channels          │
│  Row Level Security (RLS)      │  Storage (Proof Uploads)              │
│  RPC Functions (all audited)   │  pg_cron (Scheduled Purge)            │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
         ┌───────────────────┴──────────────────────┐
         ▼                                           ▼
┌─────────────────────┐                 ┌───────────────────────────────┐
│  VERCEL SERVERLESS  │                 │  META WHATSAPP CLOUD API      │
│  (Node.js, /api)    │◄───────────────►│  webhook.js → ai-responder.js │
│                     │                 │  → donor-dispatch.js          │
│  - webhook.js       │                 │  → whatsapp-sender.js         │
│  - ai-responder.js  │                 │  → emergency-concierge.js     │
│  - donor-dispatch.js│                 └───────────────────────────────┘
│  - whatsapp-sender  │
│  - emergency-       │
│    concierge.js     │                 ┌───────────────────────────────┐
└─────────────────────┘                 │  OPENROUTER AI GATEWAY        │
                                        │  (nvidia/nemotron-3.5-free)   │
                                        │  Priya Conversational Bot     │
                                        └───────────────────────────────┘
```

---

## 🛠️ Technology Stack

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | 3.44.1 | Cross-platform app (Web, Android, iOS) |
| **Dart SDK** | ^3.12.1 | Programming language |
| **go_router** | ^14.6.2 | Navigation & deep linking |
| **flutter_riverpod** | ^2.6.1 | State management |
| **supabase_flutter** | ^2.8.0 | Supabase client SDK |
| **flutter_map** | ^7.0.2 | OpenStreetMap-based maps |
| **latlong2** | ^0.9.1 | Geospatial coordinate types |
| **geolocator** | ^13.0.2 | Device GPS location |
| **flutter_dotenv** | ^5.2.1 | Environment variable loading |
| **shared_preferences** | ^2.3.3 | Local persistent storage |
| **intl** | ^0.20.1 | Internationalization & date formatting |
| **url_launcher** | ^6.3.1 | Deep links (tel:, wa.me, http) |
| **crypto** | ^3.0.6 | SHA-256 phone hashing for suppression |
| **device_preview** | ^1.3.1 | Multi-device UI testing |
| **flutter_localizations** | SDK | Material/Cupertino i18n delegates |

### Backend
| Technology | Purpose |
|---|---|
| **Supabase** | Hosted PostgreSQL, Auth, Realtime, Storage |
| **PostgreSQL 16** | Primary relational database |
| **PostGIS 3.4** | Geospatial indexing & queries (GiST indexes on geography columns) |
| **Supabase Realtime** | WebSocket-based live data subscriptions |
| **pg_cron** | Scheduled background jobs |
| **Row Level Security (RLS)** | Fine-grained data access control per user/role |

### Serverless API (Vercel)
| Technology | Purpose |
|---|---|
| **Node.js 22** | Serverless function runtime |
| **Vercel** | Hosting for Flutter Web PWA + API serverless functions |
| **Meta WhatsApp Cloud API** | Outbound messages, interactive buttons, incoming webhooks |
| **OpenRouter AI** | LLM gateway for Priya conversation bot |
| **Google Gemini API** | Voice AI / speech-to-speech intake (Gemini Live) |

---

## 👥 Application Portals & User Roles

BloodNorms has four distinct portals served from the same Flutter codebase, each with its own route namespace.

---

### 1. Requester Portal (Public Web + Mobile)

**Route:** `/` through `/live/:id`  
**Audience:** Anyone who needs blood — family members, hospital staff, patients

#### Request Flow (6-Step Wizard)

```
/ (Home)
  └─► /group        — Select blood group (A+, A-, B+, B-, AB+, AB-, O+, O-)
        └─► /units  — Select units needed (1-10) + urgency (Now / 6h / 24h / Planned)
              └─► /location   — Pick hospital location on OSM map or by search
                    └─► /banks   — View nearest blood banks with live stock
                          └─► /details  — Patient name, age, ward, notes
                                └─► /review  — Summary review before dispatching
                                      └─► /live/:id  — Live Radar & Donor Tracking
```

#### Home Screen Components

| Widget | Purpose |
|---|---|
| `HeroCard` | Full-width emergency CTA with active request awareness |
| `ActiveEmergencyCard` | Live banner if an active search is in progress |
| `ClosedRequestBanner` | Dismissible banner for fulfilled/cancelled requests |
| `ImmediateAssistanceRow` | WhatsApp bot shortcut + helpline call button |
| `ActionCardsRow` | "Become a Donor" and "Find Blood Camps" quick links |
| `AdvisoryNoticeCard` | Voluntary & free-service notice |
| `PlatformStatsCard` | Live counters: registered donors, blood centres, camps organised |
| `CampaignAndCoverageFooter` | Pilot coverage info and campaign banner |

#### Live Tracking Screen (`/live/:id`)

- **OpenStreetMap** (`flutter_map`) with animated ring radius marker
- Real-time accepted donor cards (first name, blood group, distance band, ETA)
- 6-digit **OTP Donor Pass** display for hospital verification
- Call donor button (direct tel: deep link)
- Supabase Realtime subscription on `requests` and `request_contacts` tables

#### Public Blood Banks Directory (`/b`)

- Lists all blood banks in the system
- Displays live stock levels per blood group and component
- Address, phone numbers, trust score, 24×7 indicator
- Powered by `find_nearby_banks_with_stock` RPC

---

### 2. Donor App (`/donor`)

**Route:** `/donor`, `/donor/alerts`, `/donor/camps`, `/donor/profile`, `/donor/onboarding`, `/donor/ticket/:id`  
**Audience:** Registered volunteer blood donors

#### Tabs

| Tab | Route | Purpose |
|---|---|---|
| Home | `/donor` | Dashboard, availability toggle, donation stats, latest alert |
| Alerts | `/donor/alerts` | Active blood requests matching donor's blood group |
| Camps | `/donor/camps` | Upcoming blood donation camps, sign-up / leave |
| Profile | `/donor/profile` | Donor profile, badges, settings |

#### Donor Onboarding (`/donor/onboarding`)

Multi-step registration form collecting:
- Personal details: Name, Gender, Date of Birth, Weight (≥40 kg)
- Blood group + confidence level (self-reported → bank-confirmed)
- Contact: Phone (E.164 `+91XXXXXXXXXX`), WhatsApp, Email
- Location: Area, City, Pincode, Max travel distance, Transport mode
- Health screening (encrypted answers via `donor_health` table)
- Quiet hours & monthly request cap preferences
- Consent recording (purpose, text version, channel, IP hash)

#### Donor Badge System

Badges are awarded automatically via the `bank_check_in_camp_attendee` SQL function:

| Badge | Code | Requirement |
|---|---|---|
| 🥉 Bronze Hero | `bronze_hero` | 1st donation |
| 🥈 Silver Guardian | `silver_guardian` | 3 donations |
| 🥇 Gold Lifesaver | `gold_lifesaver` | 5 donations |
| 🏆 Platinum Savior | `platinum_savior` | 10 donations |
| 💎 Diamond Centurion | `centurion` | 25+ donations |

#### Donor Ticket (`/donor/ticket/:id`)

- Shows the full request details for a specific blood request
- Displays the 6-digit donation OTP pass
- Provides hospital navigation and direct contact info

---

### 3. Blood Bank Console (`/bank`)

**Route:** `/bank`  
**Audience:** Blood bank staff and administrators

A tabbed dashboard for bank staff to manage their blood bank operations.

#### Tabs

| Tab | Purpose |
|---|---|
| **Stock** | Update live blood inventory per blood group and component (Whole Blood, Red Cells, Platelets, Plasma) |
| **Confirm Donation** | Enter a donor's 6-digit OTP to confirm a donation at the bank |
| **Expected Donors** | View donors who accepted a request near the bank and are on the way |
| **Camps** | View, create, and manage blood donation camps. Check in attendees |
| **More** | Bank profile, settings, and additional options |

#### Stock Management

- Supports 4 blood components: `whole_blood`, `red_cells`, `platelets`, `plasma`
- 8 blood groups: A+, A-, B+, B-, AB+, AB-, O+, O-
- Stock updates use the `bank_set_stock` RPC (rate-limited: 120 updates/hour)
- Every stock change is logged to `bank_stock_history` via trigger
- Multi-bank selector: staff can be linked to a specific bank via `bank_staff` table

#### Donation Confirmation Flow

1. Donor arrives at bank with their OTP code
2. Bank staff enters the 6-digit code into the console
3. `bank_confirm_donation` RPC validates code, updates `donations` table, increments `donations_count` on donor
4. Trust level set to 3 (proven) on successful confirmation

#### Camp Management

- Create camps with venue, coordinates, capacity, start/end times
- Set camp status: `draft`, `published`, `cancelled`, `done`
- View all signups with donor name and blood group
- Check in attendees via `bank_check_in_camp_attendee` RPC (awards badges automatically)
- Rate-limited: 5 camps per bank per day

#### Access Control (Bank-Side RBAC)

| Role | Capabilities |
|---|---|
| `bank_staff` | Update stock, confirm donations, view expected donors |
| `bank_admin` | All staff actions + create camps, update bank info, manage staff invites |

Staff are linked to banks via the `bank_staff` table. Invites are managed through `bank_staff_invites` (14-day expiry). On first login, the `accept_bank_invites_for_user` function automatically upgrades the user to staff.

---

### 4. Admin Console (`/admin`)

**Route:** `/admin`  
**Audience:** Platform administrators

A full operations command center with a sidebar navigation tree and a workspace canvas. The layout is **responsive**: a permanent sidebar on screens ≥ 720px wide, or a hamburger drawer on mobile.

#### Admin Console Architecture

```
AdminConsoleScreen
├── AdminConsoleController (ChangeNotifier — ListenableBuilder)
├── AdminSidebar (categories + items tree)
│   ├── AdminSidebarNavigationTree
│   ├── AdminSidebarCategoryTile
│   ├── AdminSidebarDirectItem
│   └── AdminSidebarFooter
├── AdminHeader (page title, sync, quick-actions)
└── AdminWorkspaceCanvas
    └── AdminWorkspaceRouter (routes to the active workspace view)
```

#### Sidebar Navigation Sections

| Section | Pages / Views |
|---|---|
| **Overview** | Dashboard, Platform Stats, Live Map |
| **Requests** | Active Requests, Request History |
| **Donors** | Donor Directory, Donor Operations |
| **Blood Banks** | Banks Directory, Blood Stock Management |
| **Communications** | Broadcast Center, WhatsApp Templates, Inbound Sessions |
| **Campaigns** | Blood Donation Camps, Camp Signups |
| **Governance** | Approvals Queue, Audit Logs, Feature Flags, Algorithm Settings |
| **Safety** | Safety Evaluation, Step-Up Auth |
| **Platform** | Maintenance Mode, Kill Switch, Platform Settings |
| **Analytics** | Telemetry, Cost Ledger, Usage Events, Exports |
| **Directory** | Blood Banks Directory Cards |

#### Key Admin Services

| Service | File | Responsibilities |
|---|---|---|
| `AdminBroadcastService` | `admin_broadcast_service.dart` | Geo-targeted audience preview + dispatch |
| `AdminBankOperationsService` | `admin_bank_operations_service.dart` | Bank management operations |
| `AdminBankStockService` | `admin_bank_stock_service.dart` | Cross-bank stock management |
| `AdminCampOperationsService` | `admin_camp_operations_service.dart` | Campaign and camp operations |
| `AdminCostLedgerService` | `admin_cost_ledger_service.dart` | Financial usage tracking |
| `AdminDirectoryService` | `admin_directory_service.dart` | Blood bank directory management |
| `AdminDonorOperationsService` | `admin_donor_operations_service.dart` | Donor lifecycle management |
| `AdminExportService` | `admin_export_service.dart` | Tiered data exports (Tier 1/2/3) |
| `AdminFeatureFlagsService` | `admin_feature_flags_service.dart` | Progressive feature flag management |
| `AdminGovernanceService` | `admin_governance_service.dart` | Approvals, audit, compliance |
| `AdminMaintenanceService` | `admin_maintenance_service.dart` | Maintenance mode scheduling |
| `AdminOperationsService` | `admin_operations_service.dart` | Live request operations |
| `AdminPartnerService` | `admin_partner_service.dart` | Partner integrations |
| `AdminPlatformService` | `admin_platform_service.dart` | Platform settings & configuration |
| `AdminRbacService` | `admin_rbac_service.dart` | Role/permission management |
| `AdminSafetyEvalService` | `admin_safety_eval_service.dart` | Safety evaluation workflows |
| `AdminStepUpService` | `admin_step_up_service.dart` | Step-up authentication for sensitive actions |
| `AdminTelemetryService` | `admin_telemetry_service.dart` | Usage events and cost analytics |
| `AdminVoiceAiConfigService` | `admin_voice_ai_config_service.dart` | AI voice prompt configuration |
| `AdminWhatsappTemplateService` | `admin_whatsapp_template_service.dart` | WhatsApp message template management |
| `BroadcastAudienceFilter` | `broadcast_audience_filter.dart` | Local Haversine audience computation |
| `BroadcastHistoryStore` | `broadcast_history_store.dart` | Broadcast history persistence |
| `ApprovalCacheStore` | `approval_cache_store.dart` | Four-eyes approval caching |

#### Four-Eyes Approval (Broadcasts)

Broadcasts targeting **more than 200 recipients** require a second admin to approve via the `AdminFourEyesDialog`. This prevents mass accidental outreach and is enforced both in the Flutter UI and at the database layer via `approval_requests`.

#### Kill Switch

A platform-wide emergency kill switch is available to `super_admin` and `oncall` roles. Engaging the kill switch:
- Halts all outbound WhatsApp/SMS messages
- Pauses active donor search operations
- Displays maintenance banners to users

---

## 💬 WhatsApp AI Concierge (Serverless Backend)

The `/api` directory contains 5 Node.js serverless functions deployed on Vercel.

### Files

| File | Responsibility |
|---|---|
| `webhook.js` | Meta webhook handshake (GET) and incoming message router (POST) |
| `ai-responder.js` | Stateful 5-step emergency intake conversation flow |
| `emergency-concierge.js` | Session management, blood group extraction, location resolution, request creation |
| `donor-dispatch.js` | Nearby donor alerting, donor response handling, acceptance workflow |
| `whatsapp-sender.js` | Outbound WhatsApp message sender with text + interactive buttons |

### WhatsApp Conversation Flow (Priya Bot)

```
User texts WhatsApp number
        │
        ▼
webhook.js — routes to ai-responder.js or donor-dispatch.js
        │
        ▼
State: awaiting_blood_group
  ► Priya greets: "What blood group is needed?"
  ► Interactive buttons: O+ | B+ | O-
        │
        ▼
State: awaiting_location
  ► "Where is the patient? Send location pin or type area name"
  ► Accepts GPS pin OR text (Diwancheruvu, GGH, Danavaipeta, etc.)
        │
        ▼
State: awaiting_choice
  ► Shows nearest blood banks with phone numbers
  ► "Would you like us to alert volunteer donors?"
  ► Buttons: 🚀 Find Donors Now | Change Blood Group
        │
        ▼
State: awaiting_details
  ► "Reply with: Patient Name & Age, Reason, Units needed, Time"
        │
        ▼
State: search_active
  ► Creates blood request in Supabase
  ► Calls alertNearbyDonors() — sends WhatsApp alerts to matched donors
  ► Sends Live Radar link: https://bloodnorms.vercel.app/#/track/:id
  ► Button: 🛑 Stop Searching
```

### Donor Response Flow

When a donor receives an alert and responds:

```
Donor: ✅ Yes, I Can Donate
        │
        ▼
donor-dispatch.js: handleDonorResponse()
  ► Updates request_contacts status → 'screening'
  ► Sends eligibility check: "Donated in last 3 months? Feeling healthy?"
        │
        ▼
Donor: ✅ Yes, I Am Eligible
        │
        ▼
  ► Updates status → 'accepted'
  ► Generates 6-digit OTP pass (donation_code)
  ► Sends OTP + hospital address to donor
  ► Notifies requester: "Donor accepted! (count/3)"
  ► Auto-stops search after 3 acceptances
```

### Blood Group Normalization

The `extractBloodGroup()` function normalizes all variants:
- `"o positive"` → `O+`
- `"b neg"` → `B-`
- `"ab+"` → `AB+`

### Location Resolution

The `resolveLocation()` function maps text or GPS coordinates to known Rajahmundry localities:
- GPS coordinate range checks for Diwancheruvu, Danavaipeta
- Fuzzy text matching for common locality names
- Falls back to Rajahmundry center coordinates

---

## 🗄️ Database Architecture

**Database:** PostgreSQL 16 + PostGIS 3.4  
**Hosted on:** Supabase (`ixrborkhofxlxbedpang.supabase.co`)

### Core Enums

```sql
blood_group:    A+, A-, B+, B-, AB+, AB-, O+, O-
blood_component: whole_blood, red_cells, platelets, plasma
request_urgency: now, within_6h, within_24h, planned
request_status: searching, waiting_requester, enough_donors,
                exhausted, fulfilled, cancelled, expired
contact_status: queued, contacting, accepted, standby, declined,
                no_answer, ineligible, on_the_way, arrived, donated, cancelled
donor_state:    draft, pending, active, paused, suspended, deleted
trust_level:    unverified, phone_verified, fully_verified, proven
```

### Tables Overview

#### Blood Banks

| Table | Purpose |
|---|---|
| `blood_banks` | Master directory of all blood banks (PostGIS `geography(Point,4326)`) |
| `bank_stock` | Live blood inventory per bank, group, and component |
| `bank_stock_history` | Immutable stock change log (triggered on every INSERT/UPDATE) |
| `bank_staff` | Staff-to-bank linkage with role (`bank_admin`, `bank_staff`) |
| `bank_staff_invites` | Pending staff invitations (14-day expiry, phone-verified) |
| `bank_camps` | Blood donation drives with geo-coordinates and capacity |
| `camp_signups` | Donor-camp signup records |

#### Donors (Privacy-Partitioned)

| Table | Purpose |
|---|---|
| `donors` | Public donor profile (name, blood group, stats, state, badge level) |
| `donor_private` | PII partition: phone, WhatsApp, email (separated for privacy) |
| `donor_location` | Home geo, city, pincode, max travel distance, transport mode |
| `donor_health` | Encrypted health screening answers with 6-month expiry |
| `donor_prefs` | Quiet hours, monthly request cap, critical call preference |
| `donor_badges` | Earned milestone badges with certificate URLs |
| `consents` | Full consent audit trail with IP hash and text version |

#### Requests & Matching

| Table | Purpose |
|---|---|
| `requests` | Blood requests with ring-expansion state machine |
| `request_contacts` | Donor contact records per request (channel, status, OTP code) |
| `request_donor_cards` | Privacy-safe donor cards visible to the requester family |
| `donations` | Confirmed donation records with 6-digit verification code |

#### Administration & System

| Table | Purpose |
|---|---|
| `admin_users` | Admin role assignments (support, admin, super_admin) |
| `admin_roles` | 10 built-in role definitions |
| `admin_permissions` | 22 module-level permission codes |
| `admin_role_permissions` | Role-to-permission mapping matrix |
| `admin_user_roles` | User-to-role assignments with expiry and break-glass |
| `approval_requests` | Four-eyes approval workflow records |
| `feature_flags` | Progressive feature flag registry |
| `app_settings` | Key-value platform configuration store |
| `audit_logs` | Immutable action audit trail (all admin writes) |
| `message_events` | WhatsApp/SMS send/receive event log (phone masked) |
| `webhook_events` | Idempotency registry for webhook deduplication |
| `abuse_reports` | User-submitted abuse/fake-request reports |
| `rate_limits` | Sliding-window rate limiter buckets |

#### Analytics & Compliance

| Table | Purpose |
|---|---|
| `usage_events` | Immutable per-event cost ledger (WhatsApp, voice, AI — INR) |
| `suppression_list` | SHA-256 hashed phone numbers for DND/opt-out registry |
| `regional_broadcasts` | Geo-targeted broadcast records with cost and suppression stats |
| `notifications` | In-app notification center for all user roles |
| `inbound_sessions` | WhatsApp conversation state (stateful 5-step intake) |

### Key RPC Functions

```sql
-- Find blood banks near a point with live stock
find_nearby_banks_with_stock(lat, lng, blood_group, radius_km)

-- Find eligible volunteer donors near a hospital
find_nearby_eligible_donors(hospital_lat, hospital_lng, blood_group,
                             allow_compatible, radius_km)

-- Blood compatibility matrix (pure SQL, immutable)
is_compatible(donor_group blood_group, request_group blood_group) → boolean

-- Bank staff: batch-update stock (rate-limited, audited)
bank_set_stock(rows jsonb) → int

-- Bank staff: confirm a donation by OTP code
bank_confirm_donation(code text, donor_last4 text) → jsonb

-- Bank staff: reject a donation
bank_reject_donation(code text, reason text) → boolean

-- Bank staff: view expected donors arriving
bank_expected_donors() → table

-- Camp management
bank_create_camp(title, venue, area, lat, lng, starts, ends, capacity)
bank_set_camp_status(camp_id, status)
bank_check_in_camp_attendee(camp_id, donor_id, phone, units_donated) → jsonb

-- Donor: join/leave a camp
join_camp(camp_id) → boolean
leave_camp(camp_id)

-- Admin: geo-targeted broadcast preview
preview_broadcast_audience(camp_id, city, lat, lng, radius_km,
                             respect_travel_cap, blood_group, channel) → jsonb

-- Admin: dispatch geo broadcast
dispatch_geo_broadcast(title, message, broadcast_type, camp_id, city,
                        lat, lng, radius_km, blood_group, channel) → jsonb

-- Compliance: check suppression
check_phone_suppressed(phone_hash, channel) → boolean

-- Compliance: purge expired ephemeral data (90-day DPDP)
purge_expired_ephemeral_data() → table(purged_requests, purged_notifications)

-- Rate limiter
rl_hit(bucket text, window_seconds int, max int) → boolean

-- Role helpers
is_admin() → boolean
has_admin_role(required_role text) → boolean
my_bank_id() → uuid
my_bank_role() → text
```

### Row Level Security (RLS)

RLS is enabled on **all tables**. Key policies:

| Table | Policy |
|---|---|
| `blood_banks`, `bank_stock` | Public read (anyone) |
| `donors` | Owner read/write OR admin |
| `donor_private` | Owner only OR admin (strict PII isolation) |
| `donor_location`, `donor_prefs` | Owner OR admin |
| `requests` | Requester (owner) OR contacted donor (read) OR admin |
| `request_donor_cards` | Requester (owner) OR admin |
| `audit_logs` | Admin read only |
| `usage_events` | Authenticated + service_role read; anyone insert |
| `notifications` | Own notifications OR role='all' OR admin |
| `bank_stock_history` | Own bank staff OR admin |
| `bank_camps` | Public read (published, future) OR own bank staff OR admin |
| `suppression_list` | Authenticated + service_role read |

### Realtime Channels

Three Postgres tables are published to `supabase_realtime` for live subscriptions:

| Channel | Table | Used By |
|---|---|---|
| `public:requests_realtime` | `requests` | Live Tracking screen, Home Screen active card |
| `public:stock_realtime` | `bank_stock` | Bank Console, Admin Stock View |
| `public:message_events` | `message_events` | Admin Communications dashboard |
| `public:camps_realtime` | `bank_camps` | Donor Camps tab, Admin Camps view |
| `public:notifications` | `notifications` | In-app Notification Bell |

---

## 📦 Database Migrations

All schema changes are managed as ordered, forward-only, additive SQL migrations under `supabase/migrations/`.

| Migration | Description |
|---|---|
| `0001_init.sql` | Core enums, blood banks, bank stock, donors (privacy-partitioned), requests, request contacts, request donor cards, donations, audit logs, RLS, rate limiter, blood compatibility function |
| `0002_cron.sql` | pg_cron scheduled jobs (auto-expand ring, expiry cleanup) |
| `0003_storage.sql` | Supabase Storage buckets for donation proof uploads |
| `0004_inbound.sql` | WhatsApp inbound session state table, pincodes lookup |
| `0005_bank_console.sql` | Bank staff & invites, stock history trigger, bank RPC functions, blood donation camps, camp signups |
| `0006_roles.sql` | Admin roles hierarchy, Rajahmundry pilot seed data for blood banks and stock |
| `0007_milestones_and_notifications.sql` | Donor milestone badges, camp check-in with auto-badge award, in-app notifications center |
| `0008_admin_expansion_am0.sql` | 10 built-in admin roles, 22 permission codes, role-permission matrix, user-role assignments, feature flags, audit log immutability |
| `0009_admin_am1_approvals.sql` | Four-eyes approval workflow (`approval_requests` table, approval RPC functions) |
| `0010_admin_am2_maintenance.sql` | Maintenance mode scheduling, platform status broadcasting |
| `0011_admin_am3_exports.sql` | Tiered data export system (Tier 1: aggregate, Tier 2: masked, Tier 3: full PII with step-up auth) |
| `0012_admin_am4_ledgers_and_costs.sql` | Cost ledger functions, per-service billing rates |
| `0013_admin_am5_operations_desks.sql` | Operations desk views: live requests, donor management, bank operations |
| `0014_admin_am6_am7_am8_expansion.sql` | AI voice config management, WhatsApp template registry, partner integration tables |
| `0015_admin_am9_am10_am11.sql` | Advanced admin modules: clinical review, legal officer queue, analyst dashboards |
| `0016_geo_targeted_broadcasts.sql` | `regional_broadcasts` table, `preview_broadcast_audience` RPC, `dispatch_geo_broadcast` with four-eyes check |
| `0017_location_aware_camps_and_preferences.sql` | Donor city/area/travel-radius columns, camp city/district/radius columns, enhanced broadcast preview with per-area suppression telemetry |
| `0018_performance_indexes.sql` | 18 additional covering indexes for geospatial, temporal, and foreign key performance |
| `0019_usage_events_and_cost_guardrails.sql` | Immutable `usage_events` financial ledger, immutability trigger, app_settings cost guardrail seed |
| `0020_retention_and_suppression.sql` | Cryptographic suppression list (SHA-256 phone hashes), DPDP 90-day ephemeral purge function, 60-day notification purge |
| `0021_harden_performance_and_security.sql` | 12 unindexed FK covering indexes, PostGIS spatial_ref_sys RLS, immutable `search_path` hardening, least-privilege RLS on sensitive tables, anon execution revocation on state-mutating functions |

---

## 🗺️ Navigation & Routing

BloodNorms uses **GoRouter** (`go_router ^14.6.2`) with declarative routes, deep-link support, and a 404 not-found fallback.

### Route Map

| Path | Screen | Audience |
|---|---|---|
| `/` | `HomeScreen` | Requester — Entry point |
| `/group` | `BloodGroupScreen` | Requester — Step 1: Blood group |
| `/units` | `UnitsUrgencyScreen` | Requester — Step 2: Units + urgency |
| `/location` | `LocationPickerScreen` | Requester — Step 3: Hospital location |
| `/banks` | `BanksListScreen` | Requester — Step 4: Nearby banks |
| `/details` | `RequestDetailsScreen` | Requester — Step 5: Patient details |
| `/review` | `ReviewSendScreen` | Requester — Step 6: Review & submit |
| `/live/:id` | `LiveTrackingScreen` | Requester — Live donor radar |
| `/track/:id` | `LiveTrackingScreen` | Alias for WhatsApp links |
| `/r/:id` | `LiveTrackingScreen` | Short alias |
| `/b` | `PublicBanksScreen` | Public — Blood banks directory |
| `/donor` | `DonorHomeScreen` (tab 0) | Donor — Home dashboard |
| `/donor/alerts` | `DonorHomeScreen` (tab 1) | Donor — Active alerts |
| `/donor/camps` | `DonorHomeScreen` (tab 2) | Donor — Blood donation camps |
| `/donor/profile` | `DonorHomeScreen` (tab 3) | Donor — Profile & badges |
| `/donor/onboarding` | `DonorOnboardingScreen` | Donor — Registration wizard |
| `/donor/ticket/:id` | `DonorTicketScreen` | Donor — Specific request ticket |
| `/bank` | `BankConsoleScreen` | Bank Staff — Operations console |
| `/admin` | `AdminConsoleScreen` | Admin — Command center |

### Vercel SPA Rewrite

The `vercel.json` configures all non-API requests to be served by `index.html`, enabling Flutter Web's hash-based routing:

```json
{
  "rewrites": [
    { "source": "/((?!api/).*)", "destination": "/index.html" }
  ]
}
```

---

## 🔄 State Management

BloodNorms uses **Flutter Riverpod** (`flutter_riverpod ^2.6.1`) for reactive state management alongside **ChangeNotifier** pattern for complex stateful controllers.

### Providers

| Provider | Type | Purpose |
|---|---|---|
| `requestFlowProvider` | `ChangeNotifierProvider<RequestFlowNotifier>` | The 6-step requester wizard state (blood group, units, urgency, location, hospital, patient details) |

### Controllers (ChangeNotifier + ListenableBuilder)

| Controller | Used In | Responsibilities |
|---|---|---|
| `AdminConsoleController` | `AdminConsoleScreen` | All admin state: active page, sidebar expand state, all admin data, kill switch, broadcast dispatching |
| `LiveTrackingController` | `LiveTrackingScreen` | Realtime donor polling, ring expansion, map state |

### Local State

Screens use `StatefulWidget` + `setState` for screen-local state (tab indices, loading flags, inline data). `SharedPreferences` stores the current donor ID and donor profile across sessions.

---

## 🎨 Design System

### Theme

BloodNorms enforces a **pure white, light-only theme** with no dark mode support (`ThemeMode.light` hardcoded, `darkTheme` also set to `AppTheme.lightTheme`).

### Brand Colors (`BrandColors`)

| Token | Hex | Usage |
|---|---|---|
| `background` | `#FFFFFF` | App background |
| `surfaceSoft` | `#F8F9FA` | Screen background |
| `surfaceMuted` | `#F1F3F4` | Disabled surfaces |
| `borderSubtle` | `#E8EAED` | Card borders |
| `borderStrong` | `#DADCE0` | Input borders |
| `primaryAction` | `#1F1F1F` | Primary buttons, CTAs |
| `accent` | `#5B5BF0` | Blue-violet accent, links |
| `accentTint` | `#EEF0FF` | Accent backgrounds |
| `statusSuccess` | `#1E8E3E` | Confirmed, active |
| `statusWarning` | `#B06000` | Caution states |
| `statusError` | `#D93025` | Error, critical |
| `textPrimary` | `#202124` | Headings, body |
| `textSecondary` | `#5F6368` | Subtitles, captions |
| `textMuted` | `#9AA0A6` | Placeholders, disabled |
| `whatsApp` | `#25D366` | WhatsApp CTAs |
| `red` | `#E52E2E` | Blood/emergency accent |

### Shape Tokens

| Token | Value | Usage |
|---|---|---|
| `radiusPill` | 999.0 | Full-pill buttons |
| `radiusCard` | 16.0 | Cards |
| `radiusInput` | 12.0 | Text fields |
| `radiusDialog` | 24.0 | Bottom sheets, modals |
| `minTouchTarget` | 44.0 | Accessibility minimum |

### Typography

Font family: **`BrandTypography.fontFamily`** — applied consistently across all admin and app text.

### Shared Widget Library

BloodNorms has an extensive shared widget library in `lib/shared/widgets/`:

| Widget | Purpose |
|---|---|
| `ActionButton` | Full-width pill-shaped primary CTA |
| `AppNavBar` | Bottom navigation bar with AppNavItem |
| `AppSearchField` | Styled search input |
| `AppStatCard` | Stats display card |
| `AppTextField` | Standard text input |
| `AppPageHeader` | Standard page header |
| `AppPillButton` | Outline/filled pill button |
| `AppEmptyState` | Empty state illustration + message |
| `AppErrorState` | Error state with retry |
| `BloodGroupTile` | Blood group selector tile |
| `CodeDisplayDots` | 6-dot OTP code display |
| `ConnectivityBanner` | Offline/online status banner |
| `DonorRadarCard` | Donor card for the live radar |
| `DonorStatBadge` | Donation count badge pill |
| `HeroEmergencyButton` | Full-width emergency action button |
| `NotificationBell` | Bell icon with unread count badge |
| `NotificationItemTile` | Individual notification row |
| `NotificationsSheet` | Bottom sheet notification center |
| `PinKeypad` | 6-digit PIN input keypad |
| `ProgressMeter` | Animated circular/linear progress |
| `QuantityStepper` | +/- unit increment stepper |
| `RadarPainter` | Custom painter for the circular radar rings |
| `ScreenHeader` | Reusable app bar with back/close |
| `SegmentedPicker` | Multi-segment selector (e.g., urgency) |
| `SpeechBubble` | Chat-bubble style tooltip |
| `StepProgressBar` | Multi-step wizard progress indicator |
| `NotFoundScreen` | GoRouter 404 fallback |

---

## 🌐 Internationalization (i18n)

BloodNorms supports **three languages** via a custom `AppLocalizations` delegate:

| Language | Code | Script |
|---|---|---|
| English | `en` | Latin |
| Telugu | `te` | తెలుగు |
| Hindi | `hi` | हिन्दी |

The language can be switched from the Home Screen navigation drawer at runtime.  
Strings are defined in `lib/shared/i18n/localized_strings.dart` and accessed via `AppLocalizations.of(context).t('key')` or typed getters (`.need`, `.donor`, `.banks`).

**String Budget:** UI strings ≤ 28 characters; helper strings ≤ 80 characters.

---

## 🗺️ Maps & Geolocation

BloodNorms uses **100% free, open-source** mapping infrastructure — zero Google Maps billing.

| Service | URL | Usage |
|---|---|---|
| **OpenStreetMap Tiles** | `tile.openstreetmap.org` | Map background tiles via `flutter_map` |
| **Nominatim Geocoding** | `nominatim.openstreetmap.org` | Address → coordinates lookup |
| **Device GPS** | `geolocator` package | Hospital location picker |

### Geospatial Features

- **PostGIS** `geography(Point, 4326)` columns on `blood_banks.geo`, `donor_location.home_geo`, `requests.hospital_geo`, `bank_camps.geo`
- **GiST indexes** on all geography columns for fast spatial queries
- **Haversine distance** in SQL (`calculate_distance_km`) and in Dart (`geo_utils.dart`) for client-side distance sorting
- **Ring expansion**: Requests start with a 0.5 km search radius and expand automatically until donors are found (up to 50 km approved, configurable)
- **`ST_DWithin`** used in `bank_expected_donors()` to find donors within 3 km of the bank

---

## 🤖 AI & Voice Integration

| Integration | Provider | Purpose |
|---|---|---|
| **Priya Chatbot** | OpenRouter (`nvidia/nemotron-3.5-lightning:free`) | WhatsApp emergency intake LLM |
| **Gemini Live** | Google Gemini API | Voice-to-voice speech intake for requester triage |
| **AI Voice Config** | Admin Console (`admin_voice_ai_config_service.dart`) | Manage AI prompt versions, publish approved prompts |

### Priya Bot (OpenRouter)

The `callOpenRouter()` function in `ai-responder.js` uses the OpenRouter API to generate contextual, warm responses when user messages don't match the expected state machine patterns. The LLM is instructed to:
- Act as "Priya from BloodNorms"
- Respond with helpful emojis (🙏, 🩸, 🏥, ✅)
- Keep responses under 2-3 sentences
- Never output URLs
- Temperature: 0.5, Max tokens: 180

---

## 🔒 Security & Compliance

### Data Privacy Architecture

- **Donor PII partitioning**: Phone numbers and email are stored in `donor_private`, completely separated from the public `donors` table. Requesters only ever see `first_name`, `blood_group`, and `distance_band` via `request_donor_cards`.
- **Phone masking**: All `message_events` records store only `phone_masked` (never full numbers).
- **Consent audit**: Every user consent is recorded in `consents` with text version, channel, and IP hash.
- **Encrypted health data**: `donor_health.encrypted_answers` stores health screening answers in encrypted form.

### DPDP Act Compliance (India 2023)

| Compliance Measure | Implementation |
|---|---|
| **Right to opt-out** | `suppression_list` with SHA-256 phone hash. STOP message processing in WhatsApp bot |
| **Data minimization** | 90-day purge of fulfilled/expired/cancelled requests via `purge_expired_ephemeral_data()` |
| **Notification retention** | 60-day purge of delivered in-app notifications |
| **Immutable audit trail** | `audit_logs` and `usage_events` have immutability triggers rejecting UPDATE/DELETE |
| **Consent recording** | Full `consents` table with version, channel, and IP hash |
| **Data access logging** | `donors.reveal_pii` permission creates audit log entries on PII access |

### Rate Limiting

The `rl_hit(bucket, window_seconds, max)` function provides sliding-window rate limiting:

| Operation | Limit |
|---|---|
| Bank stock updates | 120/hour per staff |
| Donation confirmation attempts | 60/hour per staff |
| Failed confirmation attempts | 10/hour (then locked) |
| Camp creation | 5/day per bank |

### Audit Log Immutability

An `AFTER UPDATE OR DELETE` trigger on `audit_logs` raises an exception, making the audit trail tamper-proof. The same pattern is applied to `usage_events`.

### Admin Step-Up Authentication

Sensitive admin actions (Tier 3 PII exports, kill switch release) require step-up authentication via `AdminStepUpService`, adding a second-factor challenge beyond the user's session.

---

## 💰 Cost & Financial Telemetry

BloodNorms tracks every billable API call in the immutable `usage_events` table.

### Tracked Services

| Service Key | Unit Type | Usage |
|---|---|---|
| `meta_whatsapp` | messages | Outbound WhatsApp messages |
| `twilio_voice` | minutes | Outbound voice calls |
| `gemini_live` | seconds | Voice AI transcription |

### Cost Guardrails

The `app_settings` table stores guardrail configuration (default: all OFF for production safety):
```json
{
  "cost_guardrails": {
    "enabled": false,
    "daily_limit_inr": 500,
    "per_request_limit_inr": 50,
    "alert_threshold_inr": 400
  }
}
```

### WhatsApp Broadcast Pricing

The `preview_broadcast_audience` RPC estimates cost at **₹0.85 per WhatsApp marketing message** before dispatching any broadcast, giving admins full cost visibility before the four-eyes approval gate.

---

## 🛡️ RBAC — Roles & Permissions

### 10 Built-In Admin Roles

| Role | Description |
|---|---|
| `super_admin` | Full system access, promote admins, release kill switch |
| `admin` | Day-to-day operations, settings, campaigns, exports |
| `support` | Read-limited: look up, resend messages, opt-out |
| `oncall` | Live requests, needs-human queue, kill switch enable |
| `bank_manager` | Banks, stock, partners, staff invites |
| `content_editor` | Copy, help pages, translations (cannot publish alone) |
| `clinical_reviewer` | Approve health questions and eligibility constants |
| `legal_officer` | Consent texts, policies, data-rights queue |
| `analyst` | Aggregate dashboards, Tier 1 exports only |
| `finance` | Cost, caps, invoices, renewals, rate cards |

### 22 Permission Codes

Permissions are grouped by module and assigned to roles in the `admin_role_permissions` table:

```
requests.view / .edit / .close
donors.view / .edit / .reveal_pii / .delete
banks.view / .edit
camps.view / .edit
broadcasts.create / .approve
maintenance.edit
kill_switch.engage / .release
ai_voice.edit / .publish
exports.export_aggregate / .export_masked / .export_full
audit.view
```

### Break-Glass Protocol

User-role assignments in `admin_user_roles` support optional `expires_at` for time-limited access and `break_glass` flag for emergency privilege escalation with mandatory audit logging.

---

## ⚙️ CI/CD Pipeline

GitHub Actions workflow at `.github/workflows/ci.yml` runs on every push/PR to `main`.

### Jobs

| Job | Runs On | Steps |
|---|---|---|
| **Flutter Lint & Tests** | `ubuntu-latest` + Flutter 3.44.1 | `flutter pub get` → `flutter analyze` → `flutter test --coverage` |
| **Voice Gateway Build** | `ubuntu-latest` + Node.js 22 | `npm ci` → `npm run build` (TypeCheck) → `npm test` |
| **SQL Migrations Integrity** | `ubuntu-latest` | Verifies ≥ 20 migration files present in `supabase/migrations/` |

---

## 🚀 Deployment

### Flutter Web (Vercel)

The Flutter app is compiled to web and served as a static site on Vercel:
- **Build output:** `public/` directory
- **PWA:** Configured with `web/manifest.json` and `web/icons/`
- **CanvasKit:** Included in `public/canvaskit/` for high-fidelity rendering
- **Routing:** All paths rewrite to `index.html` for Flutter's hash routing

### Vercel Serverless API

The `/api` directory is auto-detected by Vercel as serverless functions:
- `api/webhook.js` → deployed as `/api/webhook`
- `api/ai-responder.js` → internal module
- `api/emergency-concierge.js` → internal module
- `api/donor-dispatch.js` → internal module
- `api/whatsapp-sender.js` → internal module

### Android & iOS

Built using standard Flutter toolchain:
```bash
flutter build apk --release         # Android APK
flutter build appbundle --release   # Google Play AAB
flutter build ios --release         # iOS (requires Xcode)
```

---

## ⚙️ Environment Configuration

The `.env` file is loaded at startup via `flutter_dotenv`. All values can be overridden via system environment variables.

```env
# ── Supabase Core ──────────────────────────────────────
SUPABASE_URL=https://ixrborkhofxlxbedpang.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_PUBLISHABLE_KEY=<publishable-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>   # Backend/Admin ONLY — never in client builds
SUPABASE_JWT_SECRET=<jwt-secret>

# ── OpenStreetMap (100% free, no API key required) ─────
OSM_TILE_SERVER=https://tile.openstreetmap.org/{z}/{x}/{y}.png
OSM_NOMINATIM_URL=https://nominatim.openstreetmap.org/

# ── Pilot City Defaults ────────────────────────────────
DEFAULT_PILOT_CITY=Rajahmundry
DEFAULT_PILOT_STATE=Andhra Pradesh
DEFAULT_PILOT_LAT=17.0005
DEFAULT_PILOT_LNG=81.7800

# ── WhatsApp Business Cloud API ────────────────────────
WHATSAPP_PHONE_NUMBER_ID=<phone-number-id>
WHATSAPP_BUSINESS_ACCOUNT_ID=<business-account-id>
WHATSAPP_ACCESS_TOKEN=<access-token>
WHATSAPP_WEBHOOK_VERIFY_TOKEN=bloodnorms_wa_verify

# ── AI & Voice ─────────────────────────────────────────
OPENROUTER_API_KEY=<openrouter-key>
OPENROUTER_MODEL=nvidia/nemotron-3.5-lightning:free
GEMINI_API_KEY=<gemini-key>

# ── Platform ───────────────────────────────────────────
EMERGENCY_HELPLINE_PHONE=+91 883 247 1234
APP_ENVIRONMENT=production     # development | staging | production
DEBUG_MODE=false
```

> **Security:** Never commit `SUPABASE_SERVICE_ROLE_KEY`, `WHATSAPP_ACCESS_TOKEN`, or AI keys to version control. Use `.gitignore` and Vercel environment variables for production secrets.

---

## 📁 Project Structure

```
BloodNorms/
├── .env                          # Environment configuration
├── .gitignore
├── pubspec.yaml                  # Flutter dependencies
├── vercel.json                   # Vercel deployment config
├── analysis_options.yaml         # Dart linter config
│
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions CI pipeline
│
├── api/                          # Vercel Serverless Functions (Node.js)
│   ├── webhook.js               # WhatsApp webhook entrypoint
│   ├── ai-responder.js          # Priya conversation engine
│   ├── emergency-concierge.js   # Session management + request creation
│   ├── donor-dispatch.js        # Donor alerting + response handling
│   └── whatsapp-sender.js       # Outbound WhatsApp message sender
│
├── supabase/
│   ├── 00_master_schema.sql     # Standalone full schema (seed + functions)
│   └── migrations/              # 21 ordered SQL migration files
│       ├── 0001_init.sql
│       ├── 0002_cron.sql
│       ├── ...
│       └── 0021_harden_performance_and_security.sql
│
├── lib/
│   ├── main.dart                # App entry point
│   ├── app/
│   │   ├── app.dart             # Root MaterialApp.router widget
│   │   ├── providers.dart       # Root Riverpod providers
│   │   └── router.dart          # GoRouter route definitions
│   │
│   ├── features/
│   │   ├── requester/           # Requester wizard + live tracking
│   │   │   ├── screens/         # HomeScreen, BloodGroupScreen, UnitsUrgencyScreen,
│   │   │   │                    # LocationPickerScreen, BanksListScreen,
│   │   │   │                    # RequestDetailsScreen, ReviewSendScreen,
│   │   │   │                    # LiveTrackingScreen, PublicBanksScreen
│   │   │   ├── controllers/     # LiveTrackingController
│   │   │   ├── providers/       # RequestFlowProvider (wizard state)
│   │   │   ├── services/        # RequesterService
│   │   │   └── widgets/         # HomeScreen widgets, LiveTracking widgets
│   │   │
│   │   ├── donor/               # Donor app
│   │   │   ├── screens/         # DonorHomeScreen, DonorAlertsScreen,
│   │   │   │                    # DonorCampsScreen, DonorProfileScreen,
│   │   │   │                    # DonorOnboardingScreen, DonorTicketScreen
│   │   │   ├── services/        # DonorService
│   │   │   └── widgets/         # Donor dashboard, alerts, camps tabs
│   │   │
│   │   ├── bank_console/        # Blood Bank Staff Console
│   │   │   ├── screens/         # BankConsoleScreen
│   │   │   ├── services/        # CampService, BankService
│   │   │   └── widgets/         # StockTabView, ConfirmDonationTabView,
│   │   │                        # ExpectedDonorsTabView, BankCampsTabView,
│   │   │                        # BankMoreTabView, BankConsoleNavBar
│   │   │
│   │   └── admin_console/       # Admin Command Center
│   │       ├── screens/         # AdminConsoleScreen
│   │       ├── controllers/     # AdminConsoleController,
│   │       │                    # AdminNavigationMixin, AdminBroadcastMixin,
│   │       │                    # AdminPlatformLoader
│   │       ├── services/        # 20 admin service files (see table above)
│   │       └── widgets/         # AdminSidebar, AdminHeader, AdminWorkspaceCanvas,
│   │                            # AdminWorkspaceRouter, all workspace views
│   │
│   └── shared/
│       ├── constants/           # AppConstants, BloodGroups
│       ├── i18n/                # AppLocalizations, localized_strings.dart
│       ├── models/              # BloodBankModel, CampModel, DonorBadgeModel,
│       │                        # DonorCardModel, NotificationModel, RequestAlertModel,
│       │                        # WhatsAppModels
│       ├── services/            # SupabaseService (singleton facade + extensions),
│       │                        # RealtimeService, NotificationService,
│       │                        # LocationService, MessagingService,
│       │                        # WhatsApp audit/config/parser services
│       ├── theme/               # AppTheme, BrandColors, BrandTypography
│       ├── utils/               # GeoUtils (Haversine), PhoneUtils
│       └── widgets/             # 30+ shared UI components
│
├── android/                     # Android-specific configuration
├── ios/                         # iOS-specific configuration
├── web/                         # Flutter Web shell (index.html, manifest, icons)
└── public/                      # Compiled Flutter Web output (served by Vercel)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.44.1+ (stable channel)
- Dart SDK 3.12.1+
- Node.js 22+ (for API functions)
- A Supabase project with the migrations applied

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/bloodnorms.git
cd bloodnorms
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Environment

Copy and populate `.env`:

```bash
cp .env .env.local
# Fill in your Supabase, WhatsApp, and AI API credentials
```

### 4. Apply Database Migrations

Using the Supabase CLI:

```bash
supabase db push
```

Or run migrations manually in order from `supabase/migrations/` on your Supabase SQL editor.

### 5. Run the Flutter App

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# With Device Preview (multi-device testing)
flutter run --dart-define=DEVICE_PREVIEW=true
```

### 6. Run the WhatsApp API Locally (Vercel Dev)

```bash
npm i -g vercel
vercel dev
```

---

## 🌱 Seed Data

The database ships with **Rajahmundry pilot seed data** in `0006_roles.sql` and `00_master_schema.sql`:

### Blood Banks (Rajahmundry)

| Bank | Type | 24×7 | Trust Score |
|---|---|---|---|
| GGH Blood Bank (Government General Hospital) | Government | ✅ | 92 |
| Indian Red Cross Society Blood Centre | Red Cross | ❌ | 88 |
| Swatantra Blood Bank | Charitable | ✅ | 78 |
| Bollineni Superspeciality Hospital Blood Bank | Hospital | ✅ | 85 |
| Suraksha Rotary Blood Centre | Charitable | ❌ | 72 |
| Rotary Central Blood Bank | Charitable | ✅ | 85 |

### Sample Donors (Rajahmundry)

| Name | Blood Group | Trust Level | Donations | Reliability |
|---|---|---|---|---|
| Anil Varma | B+ | 3 (Proven) | 3 | 95% |
| Suresh Reddy | B+ | 2 | 2 | 88% |
| Pooja Sharma | O+ | 3 (Proven) | 4 | 98% |
| Ravi Teja | A+ | 1 | 0 | 80% |
| Venkatesh Rao | O- | 3 (Proven) | 6 | 99% |

---

## 🧪 Testing

### Flutter Tests

```bash
flutter test                    # Run all tests
flutter test --coverage         # With coverage report
flutter analyze                 # Static analysis (lint)
```

### API Tests

```bash
cd voice-gateway
npm test                        # Unit + integration tests
```

### SQL Integrity

The CI pipeline verifies that all 21 migration files are present before any deployment:

```bash
count=$(ls -1 supabase/migrations/0*.sql | wc -l)
# Must be >= 20
```

### Manual Testing Checklist

The platform is designed for the following key user journeys to be manually verified:

1. **Emergency Request Flow**: Home → Blood Group → Units → Location → Banks → Details → Review → Live Radar
2. **Donor Onboarding**: `/donor/onboarding` → Full registration → Dashboard
3. **WhatsApp Bot**: Text blood group → Send location pin → Find donors → Patient details → Radar link
4. **Bank Stock Update**: `/bank` → Stock tab → Update units → Save → Verify in Supabase
5. **Donation Confirmation**: Bank console → Confirm Donation tab → Enter 6-digit OTP → Confirm
6. **Admin Broadcast**: `/admin` → Communications → Compose → Preview audience → Dispatch (or four-eyes if >200)
7. **Donor Badge Award**: Camp check-in → Verify badge awarded in `donor_badges` table

---

## 📞 Support

**Emergency Helpline:** +91 883 247 1234  
**WhatsApp:** Message the registered WhatsApp Business number  
**Production App:** [https://bloodnorms.vercel.app](https://bloodnorms.vercel.app)

---

> *BloodNorms — Every second counts. Every drop matters. 🩸*

