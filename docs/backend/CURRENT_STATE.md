# BloodNorms Backend & Database Architecture — Current State Audit

**Audit Date:** November 2026  
**Auditor:** Principal Backend & Database Architect, Application Security Engineer  
**Database Stack:** Supabase (PostgreSQL 17.11.0.018, PostGIS 3.4, GoTrue Auth, Realtime, Storage)  
**Connected Target:** Active Development Cluster (`ixrborkhofxlxbedpang`, Region: `ap-southeast-1`)

---

## 1. Executive Environment Profile

| Attribute | Configured State | Security Evaluation |
|---|---|---|
| **Project Ref** | `ixrborkhofxlxbedpang` | Development / Sprint Instance |
| **PostgreSQL Version** | `17.11.0.018` | Current GA Engine |
| **PostGIS Extension** | Installed in `public` | Flagged by database linter (system tables in public) |
| **Connection Pooling** | Supavisor (Port 6543 / 5432) | Configured |
| **Auth Subsystem** | Supabase GoTrue Auth | Active (0 users in development environment) |
| **Storage Engine** | S3-Compatible Buckets (`slips`, `proofs`) | Public read enabled, upload restricted |
| **Realtime Engine** | Supabase Realtime CDC (`supabase_realtime`) | CDC enabled on 4 core tables |

---

## 2. Database Schema & Table Inventory

The operational database contains 20 core tables in the `public` schema:

| Table Name | Primary Key | Row Level Security | Row Count | Purpose & Domain Entity |
|---|---|---|---|---|
| `public.app_settings` | `key (text)` | **ENABLED** | 11 | Platform feature flags, kill switches, operational thresholds |
| `public.audit_logs` | `id (uuid)` | **ENABLED** | 1 | Immutable audit trail for administrative operations |
| `public.bank_camps` | `id (uuid)` | **ENABLED** | 3 | Regional blood donation camps organized by banks |
| `public.bank_staff` | `id (uuid)` | **ENABLED** | 0 | Hospital/bank staff identity mapping (`user_id` -> `bank_id`) |
| `public.bank_stock` | `(bank_id, group, comp)` | **ENABLED** | 9 | Real-time blood unit inventory per bank and component |
| `public.bank_stock_history` | `id (uuid)` | **ENABLED** | 0 | Historical ledger of inventory updates |
| `public.blood_banks` | `id (uuid)` | **ENABLED** | 5 | Verified blood banks and storage centers registry |
| `public.camp_signups` | `id (uuid)` | **ENABLED** | 0 | Donor RSVPs for scheduled community donation camps |
| `public.donations` | `id (uuid)` | **ENABLED** | 2 | Completed donation records and verification codes |
| `public.donor_location` | `donor_id (uuid)` | **ENABLED** | 5 | Geographic coordinates and travel radius bounds for donors |
| `public.donors` | `id (uuid)` | **ENABLED** | 5 | Volunteer blood donors registry |
| `public.inbound_sessions` | `id (uuid)` | **ENABLED** | 0 | IVR and WhatsApp conversational triage states |
| `public.message_events` | `id (uuid)` | **ENABLED** | 10 | Dispatch lifecycle events (WhatsApp, SMS, IVR) |
| `public.pincodes` | `pincode (text)` | **ENABLED** | 7 | Andhra Pradesh regional postal code geofencing |
| `public.profiles` | `id (uuid)` | **ENABLED** | 0 | User profile extensions linked to `auth.users` |
| `public.request_access_keys` | `id (uuid)` | **ENABLED** | 0 | Ephemeral access tokens for emergency seeker tracking |
| `public.request_contacts` | `id (uuid)` | **ENABLED** | 8 | Donor response state machine per emergency request |
| `public.requests` | `id (uuid)` | **ENABLED** | 4 | In-flight emergency blood requests and concentric rings |
| `public.spatial_ref_sys` | `srid (integer)` | **SYSTEM** | 8500 | PostGIS spatial coordinate reference system registry |
| `public.voice_calls` | `id (uuid)` | **ENABLED** | 3 | Voice gateway call telemetry and duration metrics |

---

## 3. Baseline Database Advisors Findings (Prior to Hardening)

### A. Performance Linter (`supabase db advisors --type performance`)
1. **Unindexed Foreign Keys (12 Constraints):**
   - `public.bank_camps (bank_id)`
   - `public.bank_staff (bank_id)`
   - `public.bank_stock_history (bank_id)`
   - `public.camp_signups (donor_id)`
   - `public.donations (bank_id)`
   - `public.donations (donor_id)`
   - `public.donations (request_id)`
   - `public.donor_location (donor_id)`
   - `public.inbound_sessions (request_id)`
   - `public.request_access_keys (request_id)`
   - `public.request_contacts (donor_id)`
   - `public.request_contacts (request_id)`
2. **Multiple Permissive Policies (5 Warnings):**
   - Table `public.bank_stock` had multiple permissive policies for `SELECT` (`bank_stock_modify_all` with `cmd: ALL` + `bank_stock_select_public` with `cmd: SELECT`), causing redundant policy evaluation on every query.

### B. Security Linter (`supabase db advisors --type security`)
1. **Mutable `search_path` (2 Functions):**
   - `public.calculate_distance_km` had no `search_path` set.
   - `public.nearest_banks` was `SECURITY DEFINER` with no `search_path` set.
2. **Anonymous Callable `SECURITY DEFINER` Functions (10 Warnings):**
   - Mutating routines (`bank_confirm_donation`, `bank_set_stock`, `dispatch_request_to_donors`, `find_nearby_eligible_donors`, `is_admin`) granted `EXECUTE` to `PUBLIC` and `anon`.
3. **Public Extension & System Tables:**
   - PostGIS installed in `public`, exposing `public.spatial_ref_sys`.

---

## 4. Row Level Security & Access Grants Baseline

Prior to migration `0021_harden_performance_and_security.sql`, table privileges were broadly granted:
- `GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;`
- Operational tables (`audit_logs`, `voice_calls`, `inbound_sessions`, `message_events`) had permissive `ALL` policies allowing `anon` full read and write access.
- `storage.objects` had `storage_public_update` allowing untrusted callers to overwrite uploaded slips and proofs.

---

## 5. Realtime & Edge Functions State

### Realtime Publications
The publication `supabase_realtime` includes:
- `public.bank_stock`
- `public.requests`
- `public.request_contacts`
- `public.bank_camps`

### Edge Functions
Three Deno TypeScript functions exist in `supabase/functions/`:
1. `engine-tick`: 20-second lease loop matching concentric search rings (0.5 km to 100 km) and handling gates at 70/90/100 km.
2. `twilio-voice`: Inbound emergency IVR handling language selection (Telugu, Hindi, English) and bridging audio streams to Cloud Run Voice Gateway when `voice_mode = 'ai'`.
3. `whatsapp-webhook`: Meta WhatsApp Cloud API webhook router handling opt-outs (`STOP`), confirmations (`YES`), and emergency assistance.

