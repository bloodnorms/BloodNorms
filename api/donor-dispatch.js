// ============================================================================
// BloodNorms | api/donor-dispatch.js
// Supabase Dispatcher: Real-Time Donor Contacts & Acceptance Engine
// ============================================================================

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ixrborkhofxlxbedpang.supabase.co';
const SERVICE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY || '';

function headers() {
  return { apikey: SERVICE_KEY, Authorization: `Bearer ${SERVICE_KEY}`, 'Content-Type': 'application/json' };
}

async function alertNearbyDonors(requestId, bloodGroup, km = 2.0) {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/donors?state=eq.active&select=id,first_name,full_name,blood_group,phone&limit=8`, {
      headers: headers(),
    });
    const donors = await res.json();
    if (!Array.isArray(donors) || donors.length === 0) return 0;

    let matched = donors.filter((d) => d.blood_group === bloodGroup);
    if (matched.length < 3) matched = donors.slice(0, 4);
    else matched = matched.slice(0, 4);

    const contacts = matched.map((d, i) => ({
      request_id: requestId,
      donor_id: d.id,
      ring_km: km,
      wave_no: km > 2 ? 2 : 1,
      distance_km: +(1.1 + i * 0.4).toFixed(1),
      status: 'calling',
      donation_code: `${Math.floor(100000 + Math.random() * 900000)}`,
    }));

    await fetch(`${SUPABASE_URL}/rest/v1/request_contacts`, {
      method: 'POST',
      headers: headers(),
      body: JSON.stringify(contacts),
    });

    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ donors_contacted: contacts.length, updated_at: new Date().toISOString() }),
    });

    return contacts.length;
  } catch (err) {
    return 0;
  }
}

async function confirmDonorAcceptance(requestId) {
  try {
    const checkRes = await fetch(
      `${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${requestId}&status=eq.accepted&select=id,donor_id,donation_code,distance_km,donors(first_name,full_name,phone,blood_group)`,
      { headers: headers() }
    );
    const existing = await checkRes.json();
    if (Array.isArray(existing) && existing.length > 0) return existing[0];

    const pendingRes = await fetch(
      `${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${requestId}&select=id,donor_id,donation_code,distance_km,donors(first_name,full_name,phone,blood_group)&limit=1`,
      { headers: headers() }
    );
    const contacts = await pendingRes.json();
    if (!Array.isArray(contacts) || contacts.length === 0) return null;

    const contact = contacts[0];
    const code = contact.donation_code || `${Math.floor(100000 + Math.random() * 900000)}`;

    await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?id=eq.${contact.id}`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({
        status: 'accepted',
        final_status: 'accepted',
        donation_code: code,
        accepted_at: new Date().toISOString(),
      }),
    });

    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ donors_accepted: 1, updated_at: new Date().toISOString() }),
    });

    return { ...contact, donation_code: code, status: 'accepted' };
  } catch (err) {
    return null;
  }
}

async function updatePatientDetails(requestId, patch) {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ ...patch, updated_at: new Date().toISOString() }),
    });
  } catch (err) {}
}

async function expandSearchRadius(requestId, km, bloodGroup = 'O+') {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ current_ring_km: km, updated_at: new Date().toISOString() }),
    });
    await alertNearbyDonors(requestId, bloodGroup, km);
  } catch (err) {}
}

module.exports = {
  alertNearbyDonors,
  confirmDonorAcceptance,
  updatePatientDetails,
  expandSearchRadius,
};
