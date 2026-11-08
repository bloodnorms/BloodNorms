// ============================================================================
// BloodNorms | api/emergency-concierge.js
// Stateful WhatsApp Emergency Intake & Donor Search Concierge
// ============================================================================

const {
  alertNearbyDonors,
  confirmDonorAcceptance,
  updatePatientDetails,
  expandSearchRadius,
} = require('./donor-dispatch');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ixrborkhofxlxbedpang.supabase.co';
const SERVICE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY || '';

function getSupabaseKey() {
  return SERVICE_KEY;
}

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
    if (n === key || n.includes(` ${key} `) || n.startsWith(`${key} `) || n.endsWith(` ${key}`) || n.includes(`${key}`)) {
      return val;
    }
  }
  return null;
}

/**
 * Normalizes location text to known Rajahmundry / AP areas
 */
function normalizeLocation(text) {
  if (!text) return 'Rajahmundry';
  const clean = text.replace(/\b(location|area|place|near|at|hospital)\b/gi, '').trim();
  if (/diwancheruvu|diwanchervuvu|divancheruvu/i.test(clean)) {
    return 'Diwancheruvu, Rajahmundry';
  }
  if (/danavaipeta|danavaypeta/i.test(clean)) {
    return 'Danavaipeta, Rajahmundry';
  }
  if (/morampudi/i.test(clean)) {
    return 'Morampudi, Rajahmundry';
  }
  if (/lalacheruvu/i.test(clean)) {
    return 'Lalacheruvu, Rajahmundry';
  }
  if (/kakinada/i.test(clean)) {
    return 'Kakinada';
  }
  return clean || 'Rajahmundry';
}

/**
 * Fetches active inbound session for phone number
 */
const SESSIONS = new Map();

async function getSession(phoneE164) {
  if (SESSIONS.has(phoneE164)) {
    return SESSIONS.get(phoneE164);
  }
  const key = getSupabaseKey();
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/inbound_sessions?phone_e164=eq.${encodeURIComponent(phoneE164)}&channel=eq.whatsapp&order=updated_at.desc&limit=1`, {
      headers: { apikey: key, Authorization: `Bearer ${key}` },
    });
    const rows = await res.json();
    const session = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
    if (session) SESSIONS.set(phoneE164, session);
    return session;
  } catch (err) {
    return null;
  }
}

async function saveSession(phoneE164, state, slots, requestId = null) {
  const sessionObj = {
    phone_e164: phoneE164,
    channel: 'whatsapp',
    state,
    slots: slots || {},
    request_id: requestId,
    updated_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
  };
  SESSIONS.set(phoneE164, sessionObj);

  const key = getSupabaseKey();
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/inbound_sessions`, {
      method: 'POST',
      headers: { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', Prefer: 'return=minimal' },
      body: JSON.stringify(sessionObj),
    });
  } catch (err) {}
}

async function createBloodRequest(phoneE164, slots, details) {
  const key = getSupabaseKey();
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
      reason: details.reason || 'Accident surgery',
      requester_phone: phoneE164,
      requester_name: 'Family Coordinator',
      origin: 'whatsapp',
      status: 'searching',
      current_ring_km: 2.0,
    };
    const res = await fetch(`${SUPABASE_URL}/rest/v1/requests`, {
      method: 'POST',
      headers: { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', Prefer: 'return=representation' },
      body: JSON.stringify(body),
    });
    const rows = await res.json();
    const created = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
    if (created) {
      await alertNearbyDonors(created.id, slots.blood_group || 'O+', 2.0);
    }
    return created;
  } catch (err) {
    return null;
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
  normalizeLocation,
  getSession,
  saveSession,
  createBloodRequest,
  expandSearchRadius,
  confirmDonorAcceptance,
  updatePatientDetails,
  parsePatientDetails,
};
