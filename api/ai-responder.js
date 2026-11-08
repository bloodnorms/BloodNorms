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
  stopSearch,
  resumeSearch,
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

function resolveLocation(locationObj, fallbackText = '') {
  const lat = locationObj?.latitude ? Number(locationObj.latitude) : null;
  const lng = locationObj?.longitude ? Number(locationObj.longitude) : null;
  let name = (locationObj?.name || locationObj?.address || '').trim();

  if (lat && lng) {
    if (!name || name === 'Your Location') {
      if (lat >= 17.03 && lat <= 17.09 && lng >= 81.82 && lng <= 81.88) {
        name = 'Diwancheruvu, Rajahmundry';
      } else if (lat >= 16.98 && lat <= 17.03 && lng >= 81.75 && lng <= 81.81) {
        name = 'Danavaipeta / GGH, Rajahmundry';
      } else {
        name = `GPS (${lat.toFixed(4)}, ${lng.toFixed(4)}), Rajahmundry`;
      }
    }
    return { name, lat, lng };
  }

  name = normalizeLocation(fallbackText);
  if (/diwancheruvu|diwanchervuvu/i.test(name)) return { name: 'Diwancheruvu, Rajahmundry', lat: 17.0481, lng: 81.8421 };
  if (/danavaipeta/i.test(name)) return { name: 'Danavaipeta, Rajahmundry', lat: 17.0005, lng: 81.7820 };
  return { name: name || 'Rajahmundry', lat: 17.0005, lng: 81.7800 };
}

async function callOpenRouter(userText, contextHint = '') {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;
  const model = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3.5-lightning:free';
  const prompt = `You are Priya, a polite and caring emergency blood coordinator at BloodNorms in Rajahmundry. ${contextHint} Respond warmly with helpful emojis (🙏, 🩸, 🏥, ✅). Use double line breaks. Keep under 2-3 short sentences. NEVER output URLs.`;

  try {
    const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}`, 'HTTP-Referer': 'https://bloodnorms.vercel.app', 'X-Title': 'BloodNorms', 'Content-Type': 'application/json' },
      body: JSON.stringify({ model, messages: [{ role: 'system', content: prompt }, { role: 'user', content: userText }], reasoning: { effort: 'none' }, temperature: 0.5, max_tokens: 180 }),
    });
    const data = await res.json();
    return (data.choices?.[0]?.message?.content || '').replace(/https?:\/\/\S+/gi, '').trim();
  } catch (_) {
    return null;
  }
}

async function handleUserInteraction(messageObj, fromPhone) {
  const phoneE164 = fromPhone.startsWith('+') ? fromPhone : `+${fromPhone}`;
  const isLocation = messageObj.type === 'location' || !!messageObj.location;

  let text = '';
  let buttonId = '';
  if (messageObj.type === 'interactive' && messageObj.interactive?.button_reply) {
    buttonId = messageObj.interactive.button_reply.id || '';
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

  if (buttonId.startsWith('btn_search_stop') || /stop searching|keep stopped|stop donor|found enough|stop search/i.test(textUpper)) {
    const reqId = buttonId.replace('btn_search_stop_', '');
    if (reqId) await stopSearch(reqId);
    await saveSession(phoneE164, 'search_completed', {}, reqId);
    return {
      text: `🛑 *Emergency Donor Search Stopped* ✅\n━━━━━━━━━━━━━━━━━━━━\nWe have stopped alerting additional volunteer donors.\n\nAll donors who previously accepted remain confirmed on your Live Radar:\n👉 https://bloodnorms.vercel.app/#/track/${reqId || 'live'}\n\nWishing the patient a safe and speedy recovery! 🙏`,
      buttons: [{ id: `btn_search_more_${reqId}`, title: '🔍 Search More Donors' }],
    };
  }

  if (buttonId.startsWith('btn_search_more') || /search more|continue searching|search donors|more donors/i.test(textUpper)) {
    const reqId = buttonId.replace('btn_search_more_', '');
    if (reqId) await resumeSearch(reqId, 'O+');
    await saveSession(phoneE164, 'search_active', {}, reqId);
    return {
      text: `📡 *Emergency Donor Search Resumed!* 🩸\n━━━━━━━━━━━━━━━━━━━━\nExpanding radius to alert more volunteer donors.\n\nLive responses update in real time below:\n👉 https://bloodnorms.vercel.app/#/track/${reqId || 'live'}\n\nStanding by with you! 🙏`,
      buttons: [{ id: `btn_search_stop_${reqId}`, title: '🛑 Stop Searching' }],
    };
  }

  let session = await getSession(phoneE164);
  const slots = session?.slots || {};
  const state = session?.state || 'awaiting_blood_group';

  // 1. WhatsApp Location Pin Intake (Handles location sent at any step!)
  if (isLocation) {
    const loc = resolveLocation(messageObj.location, text);
    slots.location = loc;
    if (slots.blood_group) {
      await saveSession(phoneE164, 'awaiting_choice', slots);
      return {
        text: `🏥 *Nearest Blood Centres Found (${slots.blood_group}) near ${loc.name}:*\n\n1. *Rotary Blood Bank* (3.1 km)\n   📞 +918832462233\n\n2. *Government General Hospital Blood Centre* (6.9 km)\n   📞 +918832471234\n\n👉 *View Live Blood Banks & Map:*\nhttps://bloodnorms.vercel.app/#/banks\n\nWould you like us to automatically call & message volunteer donors nearby?`,
        buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }, { id: 'btn_change_group', title: 'Change Blood Group' }],
      };
    } else {
      await saveSession(phoneE164, 'awaiting_blood_group', slots);
      return {
        text: `📍 Location received: *${loc.name}* ✅\n\nStep 1 of 3: What blood group is needed for the patient?\nTap below or reply with your group (O+, O-, A+, A-, B+, B-, AB+, AB-):`,
        buttons: GREETING_PAYLOAD.buttons,
      };
    }
  }

  const isGreeting = /^(hi|hello|hey|namaste|నమస్కారం|start|reset)\b/i.test(text);
  if (/change blood group/i.test(text) || isGreeting || (!session && !extractBloodGroup(text))) {
    await saveSession(phoneE164, 'awaiting_blood_group', {});
    return GREETING_PAYLOAD;
  }

  const detectedGroup = extractBloodGroup(text);

  // 2. Blood Group Detection
  if (detectedGroup) {
    slots.blood_group = detectedGroup;
    slots.intent = 'need_blood';
    if (slots.location?.name) {
      await saveSession(phoneE164, 'awaiting_choice', slots);
      return {
        text: `🏥 *Nearest Blood Centres Found (${detectedGroup}) near ${slots.location.name}:*\n\n1. *Rotary Blood Bank* (3.1 km)\n   📞 +918832462233\n\n2. *Government General Hospital Blood Centre* (6.9 km)\n   📞 +918832471234\n\n👉 *View Live Blood Banks & Map:*\nhttps://bloodnorms.vercel.app/#/banks\n\nWould you like us to automatically call & message volunteer donors nearby?`,
        buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }, { id: 'btn_change_group', title: 'Change Blood Group' }],
      };
    }
    await saveSession(phoneE164, 'awaiting_location', slots);
    return {
      text: `Got it, *${detectedGroup}* noted! 🩸\n\nStep 2 of 3: Where is the patient located?\n\n📍 *Send Location* (tap 📎 attachment icon → Location)\nor simply type your *Hospital / Area name* (e.g. Diwancheruvu, GGH Rajahmundry, Danavaipeta).`,
    };
  }

  if (state === 'awaiting_blood_group') {
    const aiAnswer = await callOpenRouter(text);
    return { text: (aiAnswer ? `${aiAnswer}\n\n` : '') + `Step 1 of 3: Please select or type the required *Blood Group*:`, buttons: GREETING_PAYLOAD.buttons };
  }

  // 3. Text Location Intake
  if (state === 'awaiting_location' || /location|diwancheruvu|diwanchervuvu|ggh|danavaipeta|rajahmundry/i.test(text)) {
    const loc = resolveLocation(null, text);
    slots.location = loc;
    await saveSession(phoneE164, 'awaiting_choice', slots);
    return {
      text: `🏥 *Nearest Blood Centres Found (${slots.blood_group || 'O+'}) near ${loc.name}:*\n\n1. *Rotary Blood Bank* (3.1 km)\n   📞 +918832462233\n\n2. *Government General Hospital Blood Centre* (6.9 km)\n   📞 +918832471234\n\n👉 *View Live Blood Banks & Map:*\nhttps://bloodnorms.vercel.app/#/banks\n\nWould you like us to automatically call & message volunteer donors nearby?`,
      buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }, { id: 'btn_change_group', title: 'Change Blood Group' }],
    };
  }

  // 4. User Choice: Find Donors
  if (state === 'awaiting_choice') {
    if (textUpper === '1' || buttonId === 'btn_find_donors' || /find donors|donor|search|yes|అవును|हाँ/i.test(textUpper)) {
      await saveSession(phoneE164, 'awaiting_details', slots);
      return {
        text: `Step 3 of 3: Alerting verified donors near ${slots.location?.name || 'your area'}! 🚨\n\nPlease reply with these 4 quick details in one message:\n\n1. *Patient Name & Age* (e.g. Ramesh, 45)\n2. *Reason for Blood* (e.g. Accident / Surgery)\n3. *Units Needed* (e.g. 2 units)\n4. *Time Required* (e.g. Immediate / 2 hours)\n\n*(Example: Ramesh, 45, Accident surgery, 2 units, immediate)*`,
      };
    }
    return { text: `Understood! You can contact the blood banks listed above directly.\n\nTap below whenever you need to search volunteer donors:`, buttons: [{ id: 'btn_find_donors', title: '🚀 Find Donors Now' }] };
  }

  // 5. Patient Details & Radar Dispatch
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
      text: `🚨 *EMERGENCY DONOR RADAR ACTIVATED*\n━━━━━━━━━━━━━━━━━━━━\n🩸 *Blood Group:* *${slots.blood_group || 'O+'}* | 📦 *Units:* ${details.units}\n🏥 *Hospital:* ${slots.location?.name || 'Diwancheruvu, Rajahmundry'}\n👤 *Patient:* ${details.name} (${details.age} yrs)\n\n📡 *Live Broadcast Active:*\n• 👥 Verified volunteer donors alerted nearby\n• 🔄 Expanding search radius automatically until confirmed\n• 🛑 Search automatically stops once 3 donors accept\n\n💬 We are currently talking with donors for availability. Please stay by your phone.\n\n📱 *Live Radar & Donor Tracking:*\n👉 https://bloodnorms.vercel.app/#/track/${reqId}`,
      buttons: [{ id: `btn_search_stop_${reqId}`, title: '🛑 Stop Searching' }],
    };
  }

  return { text: `We are monitoring your emergency request! Live Radar:\n👉 https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live'}` };
}

module.exports = { handleUserInteraction, resolveLocation };
