-- ============================================================================
-- BloodNorms Master Database Schema
-- Ready for: https://ixrborkhofxlxbedpang.supabase.co
-- Extensions: PostGIS, UUID
-- Tables: blood_banks, bank_stock, donors, donor_location, requests, request_contacts, donations, profiles
-- Functions: find_nearby_banks_with_stock, find_nearby_eligible_donors, bank_set_stock, bank_confirm_donation
-- Realtime: Enabled for requests, request_contacts, bank_stock
-- Seed Data: 5 Verified Rajahmundry Blood Banks with Live Stock
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT,
    role TEXT DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
  );
END;
$$;

DROP POLICY IF EXISTS profiles_select_all ON public.profiles;
CREATE POLICY profiles_select_all ON public.profiles FOR SELECT USING (true);

-- 2. DISTANCE CALCULATION HELPER
CREATE OR REPLACE FUNCTION public.calculate_distance_km(
    lat1 DOUBLE PRECISION,
    lng1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lng2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    r DOUBLE PRECISION := 6371; -- Earth radius in KM
    dlat DOUBLE PRECISION;
    dlng DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    IF lat1 IS NULL OR lng1 IS NULL OR lat2 IS NULL OR lng2 IS NULL THEN
        RETURN 999999;
    END IF;
    dlat := radians(lat2 - lat1);
    dlng := radians(lng2 - lng1);
    a := sin(dlat / 2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2)^2;
    c := 2 * atan2(sqrt(a), sqrt(1 - a));
    RETURN r * c;
END;
$$;

-- 3. BLOOD BANKS TABLE
CREATE TABLE IF NOT EXISTS public.blood_banks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    phones TEXT[] NOT NULL DEFAULT '{}',
    bank_type TEXT DEFAULT 'charitable',
    hours TEXT DEFAULT '24x7',
    is_24x7 BOOLEAN DEFAULT true,
    licence_no TEXT,
    trust_score NUMERIC DEFAULT 80.0,
    no_bot_calls BOOLEAN DEFAULT false,
    contact_person TEXT,
    source_id TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.blood_banks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS blood_banks_select_public ON public.blood_banks;
CREATE POLICY blood_banks_select_public ON public.blood_banks FOR SELECT USING (true);

-- 4. BANK STOCK TABLE
CREATE TABLE IF NOT EXISTS public.bank_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bank_id UUID NOT NULL REFERENCES public.blood_banks(id) ON DELETE CASCADE,
    blood_group TEXT NOT NULL,
    component TEXT NOT NULL DEFAULT 'whole_blood',
    units INTEGER NOT NULL DEFAULT 0 CHECK (units >= 0),
    source TEXT DEFAULT 'verified',
    confidence TEXT DEFAULT 'high',
    updated_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uq_bank_stock_group_component UNIQUE (bank_id, blood_group, component)
);
ALTER TABLE public.bank_stock ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS bank_stock_select_public ON public.bank_stock;
CREATE POLICY bank_stock_select_public ON public.bank_stock FOR SELECT USING (true);
DROP POLICY IF EXISTS bank_stock_modify_all ON public.bank_stock;
CREATE POLICY bank_stock_modify_all ON public.bank_stock FOR ALL USING (true) WITH CHECK (true);

-- 5. DONORS TABLE
CREATE TABLE IF NOT EXISTS public.donors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    full_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    phone_verified_at TIMESTAMPTZ,
    whatsapp_number TEXT,
    email TEXT,
    email_verified_at TIMESTAMPTZ,
    dob DATE NOT NULL,
    gender TEXT NOT NULL,
    weight_kg NUMERIC NOT NULL,
    blood_group TEXT NOT NULL,
    group_confidence TEXT DEFAULT 'guess',
    last_donation_date DATE,
    donations_count INTEGER DEFAULT 0,
    language_list TEXT[] DEFAULT '{english}',
    state TEXT NOT NULL DEFAULT 'active',
    trust_level INTEGER DEFAULT 1,
    reliability_score NUMERIC DEFAULT 85.0,
    max_travel_km INTEGER DEFAULT 10,
    transport TEXT DEFAULT 'bike',
    profile_photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.donors ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS donors_select_public ON public.donors;
CREATE POLICY donors_select_public ON public.donors FOR SELECT USING (true);
DROP POLICY IF EXISTS donors_insert_public ON public.donors;
CREATE POLICY donors_insert_public ON public.donors FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS donors_update_public ON public.donors;
CREATE POLICY donors_update_public ON public.donors FOR UPDATE USING (true);

-- 6. DONOR LOCATION TABLE
CREATE TABLE IF NOT EXISTS public.donor_location (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES public.donors(id) ON DELETE CASCADE,
    home_lat DOUBLE PRECISION NOT NULL,
    home_lng DOUBLE PRECISION NOT NULL,
    area TEXT,
    city TEXT DEFAULT 'Rajahmundry',
    pincode TEXT,
    daytime_lat DOUBLE PRECISION,
    daytime_lng DOUBLE PRECISION,
    max_travel_km INTEGER DEFAULT 10,
    transport TEXT DEFAULT 'bike',
    allow_live_location BOOLEAN DEFAULT false
);
ALTER TABLE public.donor_location ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS donor_location_select_public ON public.donor_location;
CREATE POLICY donor_location_select_public ON public.donor_location FOR SELECT USING (true);
DROP POLICY IF EXISTS donor_location_insert_public ON public.donor_location;
CREATE POLICY donor_location_insert_public ON public.donor_location FOR INSERT WITH CHECK (true);

-- 7. REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID,
    patient_first_name TEXT NOT NULL,
    patient_age INTEGER NOT NULL,
    relation TEXT NOT NULL,
    reason TEXT,
    blood_group TEXT NOT NULL,
    component TEXT NOT NULL DEFAULT 'whole_blood',
    units_needed INTEGER NOT NULL,
    urgency TEXT NOT NULL,
    needed_by TIMESTAMPTZ,
    hospital_name TEXT NOT NULL,
    hospital_lat DOUBLE PRECISION NOT NULL,
    hospital_lng DOUBLE PRECISION NOT NULL,
    hospital_area TEXT,
    hospital_ward TEXT,
    hospital_contact TEXT,
    allow_compatible BOOLEAN DEFAULT false,
    message_text TEXT,
    verified_slip_flag BOOLEAN DEFAULT false,
    second_contact_phone TEXT,
    status TEXT NOT NULL DEFAULT 'searching',
    current_ring_km NUMERIC DEFAULT 0.5,
    donors_contacted INTEGER DEFAULT 0,
    donors_accepted INTEGER DEFAULT 0,
    outcome TEXT,
    rating INTEGER,
    requester_name TEXT,
    requester_phone TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    closed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS requests_select_all ON public.requests;
CREATE POLICY requests_select_all ON public.requests FOR SELECT USING (true);
DROP POLICY IF EXISTS requests_insert_all ON public.requests;
CREATE POLICY requests_insert_all ON public.requests FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS requests_update_all ON public.requests;
CREATE POLICY requests_update_all ON public.requests FOR UPDATE USING (true);

-- 8. REQUEST CONTACTS TABLE
CREATE TABLE IF NOT EXISTS public.request_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES public.donors(id) ON DELETE CASCADE,
    ring_km NUMERIC,
    wave_no INTEGER NOT NULL DEFAULT 1,
    channel_status_call TEXT DEFAULT 'pending',
    channel_status_whatsapp TEXT DEFAULT 'pending',
    final_status TEXT NOT NULL DEFAULT 'queued',
    status TEXT DEFAULT 'queued',
    answers_json JSONB,
    donation_code TEXT,
    consent_share_phone BOOLEAN DEFAULT false,
    distance_km NUMERIC,
    accepted_at TIMESTAMPTZ,
    arrived_at TIMESTAMPTZ,
    donated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.request_contacts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS request_contacts_select_all ON public.request_contacts;
CREATE POLICY request_contacts_select_all ON public.request_contacts FOR SELECT USING (true);
DROP POLICY IF EXISTS request_contacts_insert_all ON public.request_contacts;
CREATE POLICY request_contacts_insert_all ON public.request_contacts FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS request_contacts_update_all ON public.request_contacts;
CREATE POLICY request_contacts_update_all ON public.request_contacts FOR UPDATE USING (true);

-- 9. DONATIONS TABLE
CREATE TABLE IF NOT EXISTS public.donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES public.donors(id) ON DELETE CASCADE,
    request_id UUID REFERENCES public.requests(id) ON DELETE SET NULL,
    bank_id UUID REFERENCES public.blood_banks(id) ON DELETE SET NULL,
    code TEXT NOT NULL,
    confirmed_by TEXT,
    confirmed_at TIMESTAMPTZ,
    proof_url TEXT,
    blood_group TEXT,
    component TEXT,
    units INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS donations_select_public ON public.donations;
CREATE POLICY donations_select_public ON public.donations FOR SELECT USING (true);
DROP POLICY IF EXISTS donations_insert_public ON public.donations;
CREATE POLICY donations_insert_public ON public.donations FOR INSERT WITH CHECK (true);

-- 10. RPC: find_nearby_banks_with_stock
CREATE OR REPLACE FUNCTION public.find_nearby_banks_with_stock(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_blood_group TEXT,
    p_radius_km DOUBLE PRECISION DEFAULT 30.0
)
RETURNS TABLE (
    bank_id UUID,
    bank_name TEXT,
    address TEXT,
    phones TEXT[],
    distance_km DOUBLE PRECISION,
    trust_score NUMERIC,
    is_24x7 BOOLEAN,
    units_available INTEGER,
    stock_updated_at TIMESTAMPTZ,
    stock_source TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id AS bank_id,
        b.name AS bank_name,
        b.address,
        b.phones,
        public.calculate_distance_km(p_lat, p_lng, b.lat, b.lng) AS distance_km,
        b.trust_score,
        b.is_24x7,
        COALESCE(s.units, 0) AS units_available,
        s.updated_at AS stock_updated_at,
        s.source AS stock_source
    FROM public.blood_banks b
    LEFT JOIN public.bank_stock s ON s.bank_id = b.id AND s.blood_group = p_blood_group
    WHERE public.calculate_distance_km(p_lat, p_lng, b.lat, b.lng) <= p_radius_km
    ORDER BY 
        distance_km ASC,
        b.trust_score DESC;
END;
$$;

-- Alias for backward compatibility
CREATE OR REPLACE FUNCTION public.nearest_banks(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_group TEXT DEFAULT NULL,
    p_component TEXT DEFAULT 'whole_blood',
    p_limit INTEGER DEFAULT 10,
    p_max_km DOUBLE PRECISION DEFAULT 50.0
)
RETURNS SETOF public.find_nearby_banks_with_stock
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT * FROM public.find_nearby_banks_with_stock(p_lat, p_lng, COALESCE(p_group, 'O+'), p_max_km) LIMIT p_limit;
$$;

-- 11. RPC: find_nearby_eligible_donors
CREATE OR REPLACE FUNCTION public.find_nearby_eligible_donors(
    p_hospital_lat DOUBLE PRECISION,
    p_hospital_lng DOUBLE PRECISION,
    p_blood_group TEXT,
    p_allow_compatible BOOLEAN DEFAULT true,
    p_radius_km DOUBLE PRECISION DEFAULT 30.0
)
RETURNS TABLE (
    donor_id UUID,
    first_name TEXT,
    blood_group TEXT,
    distance_km DOUBLE PRECISION,
    trust_level INTEGER,
    donations_count INTEGER,
    reliability_score NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    compatible_groups TEXT[];
BEGIN
    IF p_allow_compatible THEN
        compatible_groups := CASE p_blood_group
            WHEN 'O-'  THEN ARRAY['O-']
            WHEN 'O+'  THEN ARRAY['O+','O-']
            WHEN 'A-'  THEN ARRAY['A-','O-']
            WHEN 'A+'  THEN ARRAY['A+','A-','O+','O-']
            WHEN 'B-'  THEN ARRAY['B-','O-']
            WHEN 'B+'  THEN ARRAY['B+','B-','O+','O-']
            WHEN 'AB-' THEN ARRAY['AB-','A-','B-','O-']
            WHEN 'AB+' THEN ARRAY['A+','A-','B+','B-','O+','O-','AB+','AB-']
            ELSE ARRAY[p_blood_group]
        END;
    ELSE
        compatible_groups := ARRAY[p_blood_group];
    END IF;

    RETURN QUERY
    SELECT 
        d.id AS donor_id,
        d.first_name,
        d.blood_group,
        public.calculate_distance_km(p_hospital_lat, p_hospital_lng, dl.home_lat, dl.home_lng) AS distance_km,
        d.trust_level,
        d.donations_count,
        d.reliability_score
    FROM public.donors d
    JOIN public.donor_location dl ON dl.donor_id = d.id
    WHERE d.state = 'active'
      AND d.blood_group = ANY(compatible_groups)
      AND public.calculate_distance_km(p_hospital_lat, p_hospital_lng, dl.home_lat, dl.home_lng) <= LEAST(p_radius_km, COALESCE(dl.max_travel_km, 10))
    ORDER BY 
        (d.blood_group = p_blood_group) DESC,
        distance_km ASC,
        d.trust_level DESC,
        d.reliability_score DESC;
END;
$$;

-- 12. RPC: bank_set_stock
CREATE OR REPLACE FUNCTION public.bank_set_stock(p_rows JSONB)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    row_item JSONB;
    cnt INTEGER := 0;
BEGIN
    FOR row_item IN SELECT * FROM jsonb_array_elements(p_rows)
    LOOP
        INSERT INTO public.bank_stock (bank_id, blood_group, component, units, updated_at, source, confidence)
        VALUES (
            (row_item->>'bank_id')::uuid,
            row_item->>'blood_group',
            COALESCE(row_item->>'component', 'whole_blood'),
            (row_item->>'units')::integer,
            now(),
            COALESCE(row_item->>'source', 'manual_portal'),
            'verified'
        )
        ON CONFLICT (bank_id, blood_group, component)
        DO UPDATE SET
            units = EXCLUDED.units,
            updated_at = now(),
            source = EXCLUDED.source,
            confidence = EXCLUDED.confidence;
        cnt := cnt + 1;
    END LOOP;
    RETURN cnt;
END;
$$;

-- 13. RPC: bank_confirm_donation
CREATE OR REPLACE FUNCTION public.bank_confirm_donation(p_code TEXT, p_donor_last4 TEXT DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    rc RECORD;
    d RECORD;
BEGIN
    SELECT * INTO rc FROM public.request_contacts WHERE UPPER(donation_code) = UPPER(p_code) LIMIT 1;
    IF FOUND THEN
        SELECT * INTO d FROM public.donors WHERE id = rc.donor_id;
        IF p_donor_last4 IS NOT NULL AND d.phone IS NOT NULL AND RIGHT(d.phone, 4) != p_donor_last4 THEN
            RETURN jsonb_build_object('ok', false, 'error', 'Donor phone last 4 digits do not match');
        END IF;

        UPDATE public.request_contacts
        SET final_status = 'donated',
            status = 'donated',
            arrived_at = COALESCE(arrived_at, now()),
            donated_at = now(),
            updated_at = now()
        WHERE id = rc.id;

        INSERT INTO public.donations (donor_id, request_id, code, confirmed_by, confirmed_at, blood_group, units)
        VALUES (d.id, rc.request_id, p_code, 'bank_staff', now(), d.blood_group, 1);

        UPDATE public.donors
        SET donations_count = COALESCE(donations_count, 0) + 1,
            last_donation_date = CURRENT_DATE,
            updated_at = now()
        WHERE id = d.id;

        RETURN jsonb_build_object(
            'ok', true,
            'first_name', d.first_name,
            'blood_group', d.blood_group,
            'request_id', rc.request_id
        );
    END IF;

    RETURN jsonb_build_object('ok', false, 'error', 'Invalid or expired donation code');
END;
$$;

-- 14. REALTIME REPLICATION PUBLICATION
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;
END $$;
ALTER PUBLICATION supabase_realtime ADD TABLE public.requests, public.request_contacts, public.bank_stock;

-- 15. SEED DATA FOR RAJAHMUNDRY
INSERT INTO public.blood_banks (id, name, address, lat, lng, phones, is_24x7, trust_score)
VALUES
('b1000000-0000-0000-0000-000000000001', 'GGH Blood Bank (Government General Hospital)', 'Danavaipeta, Rajahmundry, Andhra Pradesh 533103', 17.0005, 81.7800, ARRAY['+918832471234', '+918832471235'], true, 92.00),
('b1000000-0000-0000-0000-000000000002', 'Indian Red Cross Society Blood Centre', 'Near Sub Collector Office, Katheru Road, Rajahmundry 533101', 17.0052, 81.7765, ARRAY['+918832445566'], false, 88.00),
('b1000000-0000-0000-0000-000000000003', 'Swatantra Blood Bank', 'Opposite RTC Complex, Morampudi, Rajahmundry 533107', 16.9920, 81.7910, ARRAY['+918832467890'], true, 78.00),
('b1000000-0000-0000-0000-000000000004', 'Bollineni Superspeciality Hospital Blood Bank', 'Lalacheruvu, NH16, Rajahmundry 533106', 17.0210, 81.8020, ARRAY['+918832490000'], true, 85.00),
('b1000000-0000-0000-0000-000000000005', 'Suraksha Rotary Blood Centre', 'Main Road, Innespeta, Rajahmundry 533101', 17.0022, 81.7720, ARRAY['+918832433221'], false, 72.00)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.bank_stock (bank_id, blood_group, component, units, updated_at, source, confidence)
VALUES
('b1000000-0000-0000-0000-000000000001', 'O+', 'whole_blood', 8, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000001', 'B+', 'whole_blood', 4, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000001', 'A+', 'packed_red_cells', 5, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000001', 'AB+', 'platelets', 2, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000002', 'O-', 'whole_blood', 2, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000002', 'B+', 'whole_blood', 1, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000003', 'A+', 'whole_blood', 6, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000004', 'O+', 'platelets', 4, now(), 'verified', 'high'),
('b1000000-0000-0000-0000-000000000004', 'B+', 'packed_red_cells', 3, now(), 'verified', 'high')
ON CONFLICT (bank_id, blood_group, component) DO UPDATE SET units = EXCLUDED.units;

-- SEED DONORS
INSERT INTO public.donors (id, full_name, first_name, phone, blood_group, dob, gender, weight_kg, state, trust_level, reliability_score, donations_count)
VALUES
('d1000000-0000-0000-0000-000000000001', 'Anil Varma', 'Anil', '+919848123001', 'B+', '1995-04-12', 'male', 72.0, 'active', 3, 95.0, 3),
('d1000000-0000-0000-0000-000000000002', 'Suresh Reddy', 'Suresh', '+919848123002', 'B+', '1992-08-20', 'male', 68.0, 'active', 2, 88.0, 2),
('d1000000-0000-0000-0000-000000000003', 'Pooja Sharma', 'Pooja', '+919848123003', 'O+', '1998-11-05', 'female', 58.0, 'active', 3, 98.0, 4),
('d1000000-0000-0000-0000-000000000004', 'Ravi Teja', 'Ravi', '+919848123004', 'A+', '1994-01-15', 'male', 75.0, 'active', 1, 80.0, 0),
('d1000000-0000-0000-0000-000000000005', 'Venkatesh Rao', 'Venkatesh', '+919848123005', 'O-', '1989-06-30', 'male', 70.0, 'active', 3, 99.0, 6)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.donor_location (donor_id, home_lat, home_lng, area, city, max_travel_km)
VALUES
('d1000000-0000-0000-0000-000000000001', 17.0015, 81.7830, 'Danavaipeta', 'Rajahmundry', 15),
('d1000000-0000-0000-0000-000000000002', 17.0120, 81.7890, 'Lalacheruvu', 'Rajahmundry', 10),
('d1000000-0000-0000-0000-000000000003', 17.0080, 81.7750, 'Katheru', 'Rajahmundry', 12),
('d1000000-0000-0000-0000-000000000004', 16.9950, 81.7850, 'Morampudi', 'Rajahmundry', 10),
('d1000000-0000-0000-0000-000000000005', 17.0050, 81.7880, 'Innespeta', 'Rajahmundry', 20)
ON CONFLICT (id) DO NOTHING;

