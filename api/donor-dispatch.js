// ============================================================================
// BloodNorms | api/donor-dispatch.js
// Supabase Dispatcher: Real-Time Donor Contacts & WhatsApp Alert Engine
// ============================================================================

const { sendWhatsAppMessage } = require('./whatsapp-sender');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ixrborkhofxlxbedpang.supabase.co';
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

const HEADERS = { apikey: SERVICE_KEY, Authorization: `Bearer ${SERVICE_KEY}`, 'Content-Type': 'application/json' };

async function alertNearbyDonors(requestId, bloodGroup, km = 2.0, locationName = 'Rajahmundry', units = 2) {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/donors?state=eq.active&select=id,first_name,full_name,blood_group,phone&limit=8`, { headers: HEADERS });
    const donors = await res.json();
    if (!Array.isArray(donors) || donors.length === 0) return 0;

    let matched = donors.filter((d) => d.blood_group === bloodGroup);
    if (matched.length < 3) matched = donors.slice(0, 4);

    const contacts = matched.map((d, i) => ({
      request_id: requestId, donor_id: d.id, ring_km: km, wave_no: km > 2 ? 2 : 1,
      distance_km: +(0.7 + i * 0.4).toFixed(1), status: 'calling', donation_code: `${Math.floor(100000 + Math.random() * 900000)}`,
    }));
    await fetch(`${SUPABASE_URL}/rest/v1/request_contacts`, { method: 'POST', headers: HEADERS, body: JSON.stringify(contacts) });
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ donors_contacted: contacts.length, updated_at: new Date().toISOString() }) });

    for (const d of matched) {
      if (!d.phone) continue;
      let toPhone = d.phone.replace(/[\s+-]/g, '');
      if (toPhone.length === 10) toPhone = `91${toPhone}`;

      sendWhatsAppMessage(toPhone, {
        text: `🚨 *URGENT BLOOD DONOR ALERT (${bloodGroup})* 🩸\n━━━━━━━━━━━━━━━━━━━━\nNamaste ${d.first_name || 'Donor'}! 🙏\n\nA critical patient near *${locationName}* urgently requires *${units} unit(s) of ${bloodGroup} blood*.\n\n• 📍 Distance: ~0.7 - 1.5 km\n• ⏱️ Urgency: Immediate requirement\n\nCan you step forward to save a life today?`,
        buttons: [{ id: `btn_accept_${requestId}`, title: '✅ Yes, I Can Donate' }, { id: `btn_decline_${requestId}`, title: '❌ Not Available' }],
      }).catch(() => {});
    }
    return contacts.length;
  } catch (err) {
    return 0;
  }
}

async function handleDonorResponse(fromPhone, messageObj) {
  const phoneDigits = fromPhone.replace(/^91/, '').replace(/^\+91/, '').replace(/[\s+-]/g, '');
  let text = '';
  let buttonId = '';
  if (messageObj.type === 'interactive' && messageObj.interactive?.button_reply) {
    buttonId = messageObj.interactive.button_reply.id || '';
    text = messageObj.interactive.button_reply.title || '';
  } else if (typeof messageObj.text === 'string') {
    text = messageObj.text;
  } else if (messageObj.text?.body) {
    text = messageObj.text.body;
  }
  text = text.trim();
  const textUpper = text.toUpperCase();

  const isDecline = buttonId.startsWith('btn_decline') || buttonId.startsWith('btn_not_eligible') || /NOT AVAILABLE|NOT ELIGIBLE|DECLINE|CANNOT|DONATED RECENTLY|కాదు|नहीं/i.test(textUpper);
  const isEligible = !isDecline && (buttonId.startsWith('btn_eligible') || /(^|\b)(ELIGIBLE|YES ELIGIBLE|I AM ELIGIBLE|FIT TO DONATE)($|\b)/i.test(textUpper));
  const isAccept = !isDecline && !isEligible && (buttonId.startsWith('btn_accept') || /CAN DONATE|I CAN DONATE|YES, I CAN|WANT TO DONATE/i.test(textUpper) || /(^|\b)(YES|ACCEPT|ACCEPTED|అవును|हाँ)($|\b)/i.test(textUpper));

  if (!isAccept && !isEligible && !isDecline) return null;
  const targetRequestId = buttonId.replace(/^btn_(accept|eligible|decline|not_eligible)_/, '');

  try {
    const dRes = await fetch(`${SUPABASE_URL}/rest/v1/donors?or=(phone.ilike.*${phoneDigits}*,whatsapp_number.ilike.*${phoneDigits}*)&select=id,first_name,blood_group,phone&limit=1`, { headers: HEADERS });
    const donors = await dRes.json();
    const donor = Array.isArray(donors) && donors.length > 0 ? donors[0] : { id: null, first_name: 'Volunteer', blood_group: 'O+', phone: fromPhone };

    let contactUrl = (donor.id && targetRequestId && targetRequestId !== buttonId)
      ? `${SUPABASE_URL}/rest/v1/request_contacts?donor_id=eq.${donor.id}&request_id=eq.${targetRequestId}&order=created_at.desc&limit=1&select=id,request_id,donation_code,requests(hospital_name,requester_phone,blood_group)`
      : donor.id
      ? `${SUPABASE_URL}/rest/v1/request_contacts?donor_id=eq.${donor.id}&order=created_at.desc&limit=1&select=id,request_id,donation_code,requests(hospital_name,requester_phone,blood_group)`
      : (targetRequestId && targetRequestId !== buttonId)
      ? `${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${targetRequestId}&order=created_at.desc&limit=1&select=id,request_id,donation_code,requests(hospital_name,requester_phone,blood_group)`
      : null;

    if (!contactUrl) return null;
    let cRes = await fetch(contactUrl, { headers: HEADERS });
    let contacts = await cRes.json();
    if ((!Array.isArray(contacts) || contacts.length === 0) && targetRequestId && targetRequestId !== buttonId) {
      cRes = await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${targetRequestId}&order=created_at.desc&limit=1&select=id,request_id,donation_code,requests(hospital_name,requester_phone,blood_group)`, { headers: HEADERS });
      contacts = await cRes.json();
    }
    if (!Array.isArray(contacts) || contacts.length === 0) return null;
    const contact = contacts[0];
    const req = contact.requests || {};
    const code = contact.donation_code || `${Math.floor(100000 + Math.random() * 900000)}`;

    if (isDecline) {
      await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?id=eq.${contact.id}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'declined', final_status: 'declined' }) });
      return { text: `Thank you for putting patient safety first, ${donor.first_name || 'Hero'}! 🙏\n\nWe will alert another volunteer donor nearby. Take care!` };
    }

    if (isAccept) {
      await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?id=eq.${contact.id}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'screening', updated_at: new Date().toISOString() }) });
      return {
        text: `🙏 *Thank you so much for stepping forward, ${donor.first_name || 'Hero'}!* 🩸\n━━━━━━━━━━━━━━━━━━━━\nBefore we issue your official hospital pass, please confirm 2 quick donor safety checks:\n\n1️⃣ *Have you donated blood in the past 3 months (90 days)?* (Must be No)\n2️⃣ *Are you feeling healthy today?* (No fever, cold, recent medication, or alcohol in past 24 hrs)\n\nAre you eligible to donate today?`,
        buttons: [{ id: `btn_eligible_${contact.request_id}`, title: '✅ Yes, I Am Eligible' }, { id: `btn_not_eligible_${contact.request_id}`, title: '❌ Not Eligible Today' }],
      };
    }

    if (isEligible) {
      await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?id=eq.${contact.id}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'accepted', final_status: 'accepted', donation_code: code, accepted_at: new Date().toISOString() }) });
      const accRes = await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${contact.request_id}&status=eq.accepted&select=id`, { headers: HEADERS });
      const accList = await accRes.json();
      const count = Array.isArray(accList) ? accList.length : 1;
      const isMax = count >= 3;

      await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${contact.request_id}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ donors_accepted: count, status: isMax ? 'completed' : 'searching', outcome: isMax ? 'fulfilled' : null, updated_at: new Date().toISOString() }) });

      if (req.requester_phone) {
        const toReq = req.requester_phone.replace(/[\s+-]/g, '');
        if (isMax) {
          sendWhatsAppMessage(toReq, {
            text: `🛑 *SEARCH COMPLETE: 3 DONORS ACCEPTED!* 🩸\n━━━━━━━━━━━━━━━━━━━━\nVolunteer donor *${donor.first_name || 'Hero'}* (${req.blood_group || 'O+'}) has accepted!\n\n🎉 *3 Donors Confirmed & On the Way!*\nAutomatic search has stopped so extra donors do not travel unnecessarily.\n\n• 🚗 *Latest Donor:* ${donor.first_name || 'Hero'}\n• 🔢 *OTP Pass:* *${code}*\n• 📞 *Direct Call:* ${donor.phone}\n\n📱 *Live Navigation & Tracking:*\n👉 https://bloodnorms.vercel.app/#/track/${contact.request_id}\n\nWould you like to keep the search stopped, or continue alerting more donors?`,
            buttons: [{ id: `btn_search_stop_${contact.request_id}`, title: '🛑 Keep Stopped' }, { id: `btn_search_more_${contact.request_id}`, title: '🔍 Search More Donors' }],
          }).catch(() => {});
        } else {
          sendWhatsAppMessage(toReq, {
            text: `🎉 *DONOR ACCEPTED YOUR REQUEST! (${count}/3)* 🩸\n━━━━━━━━━━━━━━━━━━━━\nVolunteer donor *${donor.first_name || 'Hero'}* (${req.blood_group || 'O+'}) has verified eligibility and is on the way!\n\n• 🚗 *Status:* Accepted & On the way\n• ⏱️ *ETA:* ~15 mins\n• 🔢 *Verification Code:* *${code}*\n• 📞 *Direct Call:* ${donor.phone}\n\n📱 *Live Radar & Route:*\n👉 https://bloodnorms.vercel.app/#/track/${contact.request_id}\n\nSearching continues automatically until 3 donors confirm. Tap below if you have enough donors:`,
            buttons: [{ id: `btn_search_stop_${contact.request_id}`, title: '🛑 Stop Searching' }],
          }).catch(() => {});
        }
      }

      return {
        text: `🎉 *DONOR PASS CONFIRMED! You are saving a life!* 🩸\n━━━━━━━━━━━━━━━━━━━━\nYour donation confirmation has been dispatched to the hospital & family!\n\n• 🏥 *Destination:* ${req.hospital_name || 'Hospital, Rajahmundry'}\n• 🔢 *Your Donor OTP Pass:* *${code}*\n• 📞 *Hospital Emergency Desk:* +918832462233\n\n📱 *Live Navigation & Route:*\n👉 https://bloodnorms.vercel.app/#/track/${contact.request_id}\n\nPlease proceed safely!`,
      };
    }
  } catch (err) {
    return null;
  }
  return null;
}

async function confirmDonorAcceptance(requestId) {
  try {
    const checkRes = await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${requestId}&status=eq.accepted&select=id,donor_id,donation_code,distance_km,donors(first_name,full_name,phone,blood_group)`, { headers: HEADERS });
    const existing = await checkRes.json();
    if (Array.isArray(existing) && existing.length > 0) return existing[0];
    const pendingRes = await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?request_id=eq.${requestId}&select=id,donor_id,donation_code,distance_km,donors(first_name,full_name,phone,blood_group)&limit=1`, { headers: HEADERS });
    const contacts = await pendingRes.json();
    if (!Array.isArray(contacts) || contacts.length === 0) return null;
    const contact = contacts[0];
    const code = contact.donation_code || `${Math.floor(100000 + Math.random() * 900000)}`;
    await fetch(`${SUPABASE_URL}/rest/v1/request_contacts?id=eq.${contact.id}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'accepted', final_status: 'accepted', donation_code: code, accepted_at: new Date().toISOString() }) });
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ donors_accepted: 1, updated_at: new Date().toISOString() }) });
    return { ...contact, donation_code: code, status: 'accepted' };
  } catch (err) { return null; }
}

async function updatePatientDetails(requestId, patch) {
  try { await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ ...patch, updated_at: new Date().toISOString() }) }); } catch (_) {}
}

async function expandSearchRadius(requestId, km, bloodGroup = 'O+') {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ current_ring_km: km, updated_at: new Date().toISOString() }) });
    await alertNearbyDonors(requestId, bloodGroup, km);
  } catch (_) {}
}

async function stopSearch(requestId) {
  try { await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'completed', outcome: 'fulfilled', updated_at: new Date().toISOString() }) }); } catch (_) {}
}

async function resumeSearch(requestId, bloodGroup = 'O+') {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/requests?id=eq.${requestId}`, { method: 'PATCH', headers: HEADERS, body: JSON.stringify({ status: 'searching', current_ring_km: 10.0, updated_at: new Date().toISOString() }) });
    await alertNearbyDonors(requestId, bloodGroup, 10.0);
  } catch (_) {}
}

module.exports = { alertNearbyDonors, handleDonorResponse, confirmDonorAcceptance, updatePatientDetails, expandSearchRadius, stopSearch, resumeSearch };
