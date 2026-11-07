// ============================================================================
// BloodNorms | supabase/functions/_shared/types.ts
//
// Common TypeScript type contracts shared across Supabase Edge Functions.
// ============================================================================

export interface RequestRecord {
  id: string;
  patient_first_name: string;
  blood_group: string;
  component: string;
  units_needed: number;
  units_accepted: number;
  urgency: string;
  hospital_name: string;
  hospital_area: string;
  hospital_lat: number;
  hospital_lng: number;
  current_ring_km: number;
  approved_up_to_km: number;
  wave_number: number;
  wave_expires_at: string;
  needed_by: string;
  status: string;
}

export interface DonorRecord {
  id: string;
  full_name: string;
  blood_group: string;
  phone?: string;
  state: string;
  is_away?: boolean;
}

export interface MessageEvent {
  channel: "whatsapp" | "sms" | "voice";
  direction: "inbound" | "outbound";
  phone_masked: string;
  event_type: string;
  status: string;
  payload_meta?: Record<string, unknown>;
}

