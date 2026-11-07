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

