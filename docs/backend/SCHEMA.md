# BloodNorms Backend & Database Architecture — Schema Specification

**Engine:** PostgreSQL 17 + PostGIS  
**Schema Namespace:** `public` (Application Domain), `storage` (Binary Assets), `auth` (Identity)  
**Security Model:** Deny-First Row Level Security (RLS) on all exposed tables

---

## 1. Entity-Relationship Architecture

```mermaid
erDiagram
    BLOOD_BANKS ||--o{ BANK_STOCK : "holds"
    BLOOD_BANKS ||--o{ BANK_CAMPS : "organizes"
    BLOOD_BANKS ||--o{ BANK_STAFF : "employs"
    BLOOD_BANKS ||--o{ DONATIONS : "receives"
    
    DONORS ||--|| DONOR_LOCATION : "has_location"
    DONORS ||--o{ CAMP_SIGNUPS : "rsvps"
    DONORS ||--o{ DONATIONS : "completes"
    DONORS ||--o{ REQUEST_CONTACTS : "receives_alert"
    
    REQUESTS ||--o{ REQUEST_CONTACTS : "dispatches"
    REQUESTS ||--o{ DONATIONS : "fulfills"
    REQUESTS ||--o{ INBOUND_SESSIONS : "initiates"
    REQUESTS ||--o{ REQUEST_ACCESS_KEYS : "authenticated_by"

    BLOOD_BANKS {
        uuid id PK
        text name
        text address
        numeric lat
        numeric lng
        text[] phones
        boolean is_24x7
        numeric trust_score
    }

    BANK_STOCK {
        uuid bank_id PK,FK
        text blood_group PK
        text component PK
        integer units
        text source
        text confidence
        timestamptz updated_at
    }

    DONORS {
        uuid id PK
        text phone
        text blood_group
        text state
        integer trust_level
        integer donations_count
        numeric reliability_score
        date last_donation_date
    }

    DONOR_LOCATION {
        uuid donor_id PK,FK
        numeric home_lat
        numeric home_lng
        integer max_travel_km
        timestamptz updated_at
    }

    REQUESTS {
        uuid id PK
        text blood_group
        integer units_needed
        integer units_accepted
        text status
        numeric current_ring_km
        numeric approved_up_to_km
        timestamptz needed_by
        timestamptz closed_at
    }

    REQUEST_CONTACTS {
        uuid id PK
        uuid request_id FK
        uuid donor_id FK
        numeric ring_km
        numeric distance_km
        text status
        text final_status
        text donation_code
        timestamptz accepted_at
    }

    DONATIONS {
        uuid id PK
        uuid donor_id FK
        uuid request_id FK
        uuid bank_id FK
        text code
        text blood_group
        integer units
        timestamptz confirmed_at
    }

    AUDIT_LOGS {
        uuid id PK
        text action
        text actor_id
        text entity_type
        text entity_id
        jsonb metadata
        timestamptz created_at
    }

    VOICE_CALLS {
        uuid id PK
        text call_sid
        text mode
        integer duration_sec
        numeric cost_inr
        timestamptz created_at
    }
```

---

## 2. Table-by-Table Technical Specifications

### 2.1 `public.blood_banks`
- **Description:** Verified hospital blood banks, regional blood centers, and storage facilities.
- **Primary Key:** `id` (UUID).
- **Spatial Coordinates:** `lat` (double precision), `lng` (double precision), `location` (geography point).
- **RLS Access:** `SELECT` allowed for all users (`anon`, `authenticated`). `INSERT/UPDATE/DELETE` restricted to admins.

### 2.2 `public.bank_stock`
- **Description:** Real-time unit availability per blood group and component.
- **Composite Primary Key:** `(bank_id, blood_group, component)`.
- **Foreign Key:** `bank_id` references `blood_banks(id)` on delete cascade.
- **Covering Index:** Compound lookup on `(bank_id, blood_group)`.
- **RLS Access:** `SELECT` open for public discovery; `UPDATE` strictly restricted to verified `bank_staff` or administrators.

### 2.3 `public.donors`
- **Description:** Registered voluntary blood donors with verification and reliability metrics.
- **Primary Key:** `id` (UUID).
- **Security Constraints:** Health questionnaire answers are strictly forbidden from this table. Plaintext phone numbers are masked in administrative views.
- **RLS Access:** `INSERT` open for volunteer onboarding. `SELECT` restricted to self-profile or authenticated administrative review.

### 2.4 `public.donor_location`
- **Description:** Geographic home station and maximum voluntary dispatch radius.
- **Primary Key & Foreign Key:** `donor_id` references `donors(id)` on delete cascade.
- **Covering Index:** `idx_donor_location_donor_id`.

### 2.5 `public.requests`
- **Description:** Emergency blood requirements driving the 14 concentric search rings.
- **Primary Key:** `id` (UUID).
- **State Machine:** `open` -> `searching` -> `enough_donors` -> `closed` / `expired`.

### 2.6 `public.request_contacts`
- **Description:** In-flight donor contact attempts, wave responses, and donation verification codes.
- **Primary Key:** `id` (UUID).
- **Foreign Keys:** `request_id` references `requests(id)`, `donor_id` references `donors(id)`.
- **Covering Indexes:** `idx_request_contacts_request_id`, `idx_request_contacts_donor_id`.

### 2.7 `public.audit_logs`
- **Description:** Immutable system audit trail capturing administrative mutations.
- **Primary Key:** `id` (UUID).
- **Immutability Guarantee:** Database trigger `trg_audit_logs_immutable` raises exception `42501` on any attempt to execute `UPDATE` or `DELETE`.
- **RLS Access:** `SELECT` restricted to verified administrators (`is_admin()`). Anonymous access strictly denied.

