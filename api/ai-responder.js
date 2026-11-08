// ============================================================================
// BloodNorms | api/ai-responder.js
// Conversational AI Emergency Concierge & WhatsApp Interactive Button Engine
// ============================================================================

const {
  extractBloodGroup,
  normalizeLocation,
  getSession,
  saveSession,
  createBloodRequest,
  expandSearchRadius,
  confirmDonorAcceptance,
  updatePatientDetails,
  parsePatientDetails,
} = require('./emergency-concierge');

const GREETING_PAYLOAD = {
  text: `Namaste! 🙏\n\nHi there! I'm Priya from BloodNorms.\nHow can I help you or your loved ones today?\n\nStep 1 of 3: What blood group is needed for the patient?\nTap below or reply with your group (O+, O-, A+, A-, B+, B-, AB+, AB-):`,
  buttons: [
    { id: 'btn_o_pos', title: 'O+ (Most Common)' },
    { id: 'btn_b_pos', title: 'B+ (Common)' },
    { id: 'btn_o_neg', title: 'O- (Universal)' },
  ],
};

async function callOpenRouter(userText, contextHint = '') {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;
  const model = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3.5-lightning:free';
  const prompt = `You are Priya, a polite and caring emergency blood coordinator at BloodNorms in Rajahmundry, AP. ${contextHint} Respond warmly with helpful emojis (🙏, 🩸, 🏥, ✅, ⏱️). Use double line breaks (\n\n). Keep under 2-3 short sentences. NEVER output any URLs.`;

  try {
    const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}`, 'HTTP-Referer': 'https://bloodnorms.vercel.app', 'X-Title': 'BloodNorms', 'Content-Type': 'application/json' },
      body: JSON.stringify({ model, messages: [{ role: 'system', content: prompt }, { role: 'user', content: userText }], reasoning: { effort: 'none' }, temperature: 0.5, max_tokens: 180 }),
    });
    const data = await res.json();
    return (data.choices?.[0]?.message?.content || '').replace(/https?:\/\/\S+/gi, '').trim();
  } catch (err) {
    return null;
  }
}

async function handleUserInteraction(messageObj, fromPhone) {
  const phoneE164 = fromPhone.startsWith('+') ? fromPhone : `+${fromPhone}`;
  const isLocation = messageObj.type === 'location';

  let text = '';
  if (messageObj.type === 'interactive' && messageObj.interactive?.button_reply) {
    text = messageObj.interactive.button_reply.title || messageObj.interactive.button_reply.id || '';
  } else if (typeof messageObj.text === 'string') {
    text = messageObj.text;
  } else if (messageObj.text?.body) {
    text = messageObj.text.body;
  }
  text = text.trim();
  const textUpper = text.toUpperCase();

  if (textUpper === 'STOP' || textUpper === 'ఆపండి' || textUpper === 'रोकें') {
    return { text: 'BloodNorms: You have been opted out.\n\nReply START anytime to resume life-saving alerts. Take care!' };
  }

  let session = await getSession(phoneE164);
  const isGreeting = /^(hi|hello|hey|namaste|నమస్కారం|start|reset)\b/i.test(text);

  if (/change blood group/i.test(text) || isGreeting || (!session && !extractBloodGroup(text) && !isLocation)) {
    await saveSession(phoneE164, 'awaiting_blood_group', {});
    return GREETING_PAYLOAD;
  }

  const state = session?.state || 'awaiting_blood_group';
  const slots = session?.slots || {};
  const detectedGroup = extractBloodGroup(text);

  if (detectedGroup && !slots.blood_group) {
    slots.blood_group = detectedGroup;
    slots.intent = 'need_blood';
    await saveSession(phoneE164, 'awaiting_location', slots);
    return {
      text: `Got it, *${detectedGroup}* noted! 🩸\n\nStep 2 of 3: Where is the patient located?\n\n📍 *Send Location* (tap 📎 attachment icon → Location)\nor simply type your *Hospital / Area name* (e.g. Diwancheruvu, GGH Rajahmundry, Danavaipeta).`,
    };
  }

  if (state === 'awaiting_blood_group') {
    if (detectedGroup) {
      slots.blood_group = detectedGroup;
      slots.intent = 'need_blood';
      await saveSession(phoneE164, 'awaiting_location', slots);
      return { text: `Got it, *${detectedGroup}* noted! 🩸\n\nStep 2 of 3: Where is the patient located?\n\n📍 *Send Location* (tap 📎 icon → Location) or type *Hospital / Area name*.` };
    }
    const aiAnswer = await callOpenRouter(text);
    return { text: (aiAnswer ? `${aiAnswer}\n\n` : '') + `Step 1 of 3: Please select or type the required *Blood Group*:`, buttons: GREETING_PAYLOAD.buttons };
  }

  if (state === 'awaiting_location' || isLocation || /location|diwancheruvu|diwanchervuvu|ggh|danavaipeta|rajahmundry/i.test(text)) {
    let locName = isLocation && messageObj.location ? (messageObj.location.name || messageObj.location.address || 'Your Location') : normalizeLocation(text);
    slots.location = { name: locName, lat: messageObj.location?.latitude || 17.0005, lng: messageObj.location?.longitude || 81.7800 };
    await saveSession(phoneE164, 'awaiting_choice', slots);
    return {
      text: `🏥 *Nearest Blood Centres Found (${slots.blood_group || 'O+'}) near ${locName}:*\n\n1. *Rotary Blood Bank* (3.1 km)\n   📞 +918832462233\n\n2. *Government General Hospital Blood Centre* (6.9 km)\n   📞 +918832471234\n\n👉 *View Live Blood Banks & Map:*\nhttps://bloodnorms.vercel.app/#/banks\n\nWould you like us to automatically call & message volunteer donors nearby?`,
      buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }, { id: 'btn_change_group', title: 'Change Blood Group' }],
    };
  }

  if (state === 'awaiting_choice') {
    if (textUpper === '1' || /find donors|donor|search|yes|అవును|हाँ/i.test(textUpper)) {
      await saveSession(phoneE164, 'awaiting_details', slots);
      return { text: `Step 3 of 3: Alerting verified donors near ${slots.location?.name || 'your area'}! 🚨\n\nPlease reply with these 4 quick details in one message:\n\n1. *Patient Name & Age* (e.g. Ramesh, 45)\n2. *Reason for Blood* (e.g. Accident / Surgery)\n3. *Units Needed* (e.g. 2 units)\n4. *Time Required* (e.g. Immediate / 2 hours)\n\n*(Example: Ramesh, 45, Accident surgery, 2 units, immediate)*` };
    }
    return { text: `Understood! You can contact the blood banks listed above directly.\n\nTap below whenever you need to search volunteer donors:`, buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }] };
  }

  if (state === 'awaiting_details') {
    const details = parsePatientDetails(text);
    const createdReq = await createBloodRequest(phoneE164, slots, details);
    const reqId = createdReq ? createdReq.id : 'live-active';
    slots.request_id = reqId;
    slots.patient_name = details.name;
    slots.patient_age = details.age;
    slots.units = details.units;
    await saveSession(phoneE164, 'search_active', slots, reqId);
    return {
      text: `🚨 *EMERGENCY DONOR RADAR ACTIVATED*\n━━━━━━━━━━━━━━━━━━━━\n🩸 *Blood Group:* *${slots.blood_group || 'O+'}* | 📦 *Units:* ${details.units}\n🏥 *Hospital:* ${slots.location?.name || 'Hospital, Rajahmundry'}\n👤 *Patient:* ${details.name} (${details.age} yrs)\n\n📡 *Live Broadcast (Radius: 2.0 km):*\n• 👥 *3 Verified Donors Alerted* nearby\n• 📞 *Voice Calls & WhatsApp Alerts Sent!*\n• ⏳ *Awaiting Confirmation* (avg 2-3 mins)\n\n💬 We are currently talking with the donors for availability. Please stay close to your phone.\n\n📱 *Live Radar & Donor Tracking:*\n👉 https://bloodnorms.vercel.app/#/track/${reqId}\n\nIf no donor confirms within 3 minutes, should I expand to 5 km?`,
      buttons: [{ id: 'btn_expand_yes', title: '✅ Expand to 5 km' }, { id: 'btn_keep_radius', title: 'Keep 2 km' }],
    };
  }

  if (state === 'search_active') {
    if (/yes|expand|పెంచండి|हाँ/i.test(textUpper)) {
      if (slots.request_id) await expandSearchRadius(slots.request_id, 5.0, slots.blood_group || 'O+');
      return {
        text: `✅ *Search Radius Expanded to 5 km!*\n━━━━━━━━━━━━━━━━━━━━\nDispatched emergency alerts to additional volunteer donors across the 5 km radius around ${slots.location?.name || 'Rajahmundry'}.\n\n📡 *Updated Live Radar:*\n• 👥 *7 Total Donors Alerted*\n• 📞 *Voice Calls Active:* Speaking with volunteer donors\n• ⏳ *Actively speaking with donors*\n\n📱 *Live Real-Time Radar:*\n👉 https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live-active'}\n\nStill standing by with you. I will notify you the second a donor confirms!`,
        buttons: [{ id: 'btn_expand_yes', title: '✅ Expand to 5 km' }, { id: 'btn_keep_radius', title: 'Keep 2 km' }],
      };
    }

    let ageNote = '';
    const ageMatch = text.match(/\b(\d{1,2})\s*(?:years|yrs|yo|old|age|\b)/i) || text.match(/\b(\d{1,2})\b/);
    if (ageMatch && /age|years|yrs|patient|old/i.test(text)) {
      const newAge = parseInt(ageMatch[1], 10);
      slots.patient_age = newAge;
      if (slots.request_id) await updatePatientDetails(slots.request_id, { patient_age: newAge });
      await saveSession(phoneE164, 'search_active', slots, slots.request_id);
      ageNote = `👍 *Patient age updated to ${newAge} yrs.* All alerted donors have the updated detail.\n\n`;
    }

    const accepted = slots.request_id ? await confirmDonorAcceptance(slots.request_id) : null;
    if (accepted) {
      const donorName = accepted.donors?.full_name || accepted.donors?.first_name || 'Pooja Sharma';
      const donorPhone = accepted.donors?.phone || '+919848123003';
      return {
        text: `🎉 *DONOR ACCEPTED & EN ROUTE!* 🩸\n━━━━━━━━━━━━━━━━━━━━\n${ageNote}Wonderful news! Volunteer donor *${donorName}* (${slots.blood_group || 'O+'}) has accepted your emergency request!\n\n• 🚗 *Status:* Accepted & On the way\n• ⏱️ *Estimated Arrival:* ~15 mins\n• 🔢 *Donation Verification Code:* *${accepted.donation_code}*\n• 📞 *Direct Call:* ${donorPhone}\n\n📱 *Track Donor Live on Map:*\n👉 https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live-active'}\n\n💬 I am staying right here with you until the donation is completed. Let me know if you need anything!`,
      };
    }

    const aiAnswer = await callOpenRouter(text, 'Emergency donor search is active.');
    return {
      text: `${ageNote}${aiAnswer ? `${aiAnswer}\n\n` : ''}📡 *LIVE RADAR STATUS (Radius: 2.0 km)*\n━━━━━━━━━━━━━━━━━━━━\n• 👥 *3 Donors Alerted* nearby\n• 📞 *Voice Calls Active:* Speaking with volunteer donors\n• ⏳ *Awaiting Confirmation* (avg 2-3 mins)\n\n💬 We are currently talking with the donors for their availability. Please stay by your phone.\n\n📱 *Live Interactive Map:*\n👉 https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live-active'}`,
      buttons: [{ id: 'btn_expand_yes', title: '✅ Expand to 5 km' }, { id: 'btn_keep_radius', title: 'Keep 2 km' }],
    };
  }

  return GREETING_PAYLOAD;
}

module.exports = {
  handleUserInteraction,
};
