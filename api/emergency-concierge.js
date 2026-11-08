// ============================================================================
// BloodNorms | api/emergency-concierge.js
// Stateful WhatsApp Emergency Intake & Donor Search Concierge
// ============================================================================

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ixrborkhofxlxbedpang.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

/**
 * Normalizes blood group variations (e.g. "o positive", "O+", "b-")
 */
function extractBloodGroup(text) {
  if (!text) return null;
  const n = text.toLowerCase().replace(/[\s_-]+/g, ' ').trim();
  const map = {
    'o pos': 'O+', 'o positive': 'O+', 'o+': 'O+',
    'o neg': 'O-', 'o negative': 'O-', 'o-': 'O-',
    'a pos': 'A+', 'a positive': 'A+', 'a+': 'A+',
    'a neg': 'A-', 'a negative': 'A-', 'a-': 'A-',
    'b pos': 'B+', 'b positive': 'B+', 'b+': 'B+',
    'b neg': 'B-', 'b negative': 'B-', 'b-': 'B-',
    'ab pos': 'AB+', 'ab positive': 'AB+', 'ab+': 'AB+',
    'ab neg': 'AB-', 'ab negative': 'AB-', 'ab-': 'AB-',
  };
  for (const [key, val] of Object.entries(map)) {
    if (n === key || n.includes(` ${key} `) || n.startsWith(`${key} `) || n.endsWith(` ${key}`)) {
      return val;
    }
  }
  return null;
}

/**
 * Fetches active inbound session for phone number
 */
async function getSession(phoneE164) {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/inbound_sessions?phone_e164=eq.${encodeURIComponent(phoneE164)}&channel=eq.whatsapp&order=updated_at.desc&limit=1`, {
      headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` },
    });
    const rows = await res.json();
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } catch (err) {
    console.error('[Concierge] Error fetching session:', err);
    return null;
  }
}

/**
 * Saves or updates inbound session
 */
async function saveSession(phoneE164, state, slots, requestId = null) {
  try {
    const body = {
      phone_e164: phoneE164,
      channel: 'whatsapp',
      state,
      slots: slots || {},
      request_id: requestId,
      updated_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 45 * 60 * 1000).toISOString(),
    };
    await fetch(`${SUPABASE_URL}/rest/v1/inbound_sessions`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify(body),
    });
  } catch (err) {
    console.error('[Concierge] Error saving session:', err);
  }
}

/**
 * Creates live blood request in Supabase
 */
async function createBloodRequest(phoneE164, slots, details) {
  try {
    const body = {
      blood_group: slots.blood_group || 'O+',
      units_needed: details.units || 1,
      urgency: 'now',
      hospital_name: slots.location?.name || 'Hospital, Rajahmundry',
      hospital_lat: slots.location?.lat || 17.0005,
      hospital_lng: slots.location?.lng || 81.7800,
      hospital_area: slots.location?.name || 'Danavaipeta',
      patient_first_name: details.name || 'Patient',
      patient_age: details.age || 35,
      relation: 'family',
      reason: details.reason || 'Emergency need',
      requester_phone: phoneE164,
      requester_name: 'Family Coordinator',
      origin: 'whatsapp',
      status: 'searching',
      current_ring_km: 2.0,
    };
    const res = await fetch(`${SUPABASE_URL}/rest/v1/requests`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      },
      body: JSON.stringify(body),
    });
    const rows = await res.json();
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } catch (err) {
    console.error('[Concierge] Error creating request:', err);
    return null;
  }
}

/**
 * Updates search radius for active request
 */
async function expandSearchRadius(requestId, km) {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ current_ring_km: km, updated_at: new Date().toISOString() }),
    });
  } catch (err) {
    console.error('[Concierge] Error expanding radius:', err);
  }
}

/**
 * Parses user-provided patient details
 */
function parsePatientDetails(text) {
  const unitsMatch = text.match(/(\d+)\s*(unit|units|pkt|pkts|bottles)/i) || text.match(/(\d+)\s*units?/i);
  const units = unitsMatch ? parseInt(unitsMatch[1], 10) : 2;

  const ageMatch = text.match(/(\d{1,2})\s*(yrs|yr|years|y\/o|age)/i) || text.match(/,\s*(\d{1,2})\s*,/);
  const age = ageMatch ? parseInt(ageMatch[1], 10) : 40;

  const parts = text.split(/[,;\n]/).map((p) => p.trim()).filter(Boolean);
  const name = parts[0] ? parts[0].replace(/\b(name|patient|mr|mrs|sri)\b[:\s]*/i, '').trim() : 'Patient';
  const reason = parts.length > 2 ? parts[2] : (text.includes('accident') ? 'Accident surgery' : 'Emergency medical need');

  return { name, age, units, reason };
}

module.exports = {
  extractBloodGroup,
  getSession,
  saveSession,
  createBloodRequest,
  expandSearchRadius,
  parsePatientDetails,
};
