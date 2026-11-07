# BloodNorms — Architectural & Design Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | **Flutter + Dart Stack** | Single codebase delivers native iOS, Android, and Web PWA with 60fps performance and exact Apple design system reproduction. |
| 2 | **Supabase (PostgreSQL + PostGIS)** | Robust spatial distance matching (`st_dwithin`), Row Level Security for private health data, and Edge Functions without extra server costs. |
| 3 | **OpenStreetMap instead of Google Maps** | Free, zero billing risk, no API credit card lockouts. Uses `flutter_map` with Leaflet tiles. |
| 4 | **Cupertino Icons ONLY** | Conforms strictly to `05-UI-UX-DESIGN-SYSTEM.md §2`. No third-party or mixed icon sets. |
| 5 | **Strict String Budget (<= 28 chars)** | Enforces calm, clear, Apple-style UI across English, Telugu, and Hindi. Tested via automated test suite. |
| 6 | **Separated Voice Gateway** | Hosted on Cloud Run (Node 22 + TypeScript) to handle full-duplex WebSocket audio with Gemini Live API. Contains zero DB credentials. |
| 7 | **Channel-Verified Requesters** | Meta WhatsApp sender is trusted (no OTP). Phone callers require 1-tap WhatsApp confirmation to prevent caller-ID spoofing. |
| 8 | **Capability Links with SHA-256** | Stressed families can view live requests without logging in. Only hash is stored; links die within 24 hours of request closure. |
| 9 | **Hard Privacy Lines (§0.3)** | Donor health questionnaire answers are encrypted and strictly excluded from all admin views and export paths. Voice gateway streams audio directly without storing caller audio or transcripts. OTPs and raw API keys are never shown or exported. |
| 10 | **Database-Enforced Immutable Audit Logs** | `public.audit_logs` has a trigger `trg_audit_logs_immutable` that raises exception `42501` on any UPDATE or DELETE attempt, guaranteeing tamper-proof legal record. |
| 11 | **Four-Eyes Maker-Checker Governance** | High-impact actions (caps changes, broadcasts > 200, Tier 3 exports, rate card edits) mandate approval by a second person (`checker_id <> maker_id`) with 24-hour expiration. |
| 12 | **Scoped Maintenance Isolation** | 8 independent scopes (`web`, `donor`, `bank`, `public`, `whatsapp`, `phone`, `api`, `admin`) allow maintenance on specific channels while preserving emergency hotline and in-flight requests. |
| 13 | **Tiered Data Exports & CSV Protection** | Exports are categorized into Tier 1 (Aggregate), Tier 2 (Masked), and Tier 3 (Identifiable). All spreadsheet cells neutralize formula injection (`=`, `+`, `-`, `@`) and include SHA-256 watermark stamps. |
| 14 | **INR Telecom Cost Engine** | Real-time tracking of Meta WhatsApp templates (₹0.35/₹0.85), Twilio Voice (₹1.80/min), and Gemini Live (₹2.40/min) with per-request spend attribution. |
| 15 | **Progressive Rollout via Feature Flags** | All expanded admin features sit behind feature flags in `public.feature_flags` that default to `false` (OFF) in production until explicitly verified and activated. |
| 16 | **Multi-Location & Geo-Fenced Broadcasting** | Blood camp broadcasts and localized notifications are strictly scoped by venue coordinates, city/district, radius (km), and donor willing travel radius. Out-of-region donors (e.g. Kakinada, Visakhapatnam, Vijayawada) and donors marked 'Out of Station / Away' are strictly suppressed. Full three-way inspection (in-radius, suppressed with explicit reasons, and neighborhood breakdown) prevents donor fatigue and wasted spend. |

