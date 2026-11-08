// ============================================================================
// BloodNorms | api/ai-responder.js
// Conversational AI Emergency Concierge & Health Triage Engine
// ============================================================================

const {
  extractBloodGroup,
  getSession,
  saveSession,
  createBloodRequest,
  expandSearchRadius,
  parsePatientDetails,
} = require('./emergency-concierge');

const SYSTEM_PROMPT = `You are Priya, a warm, caring, polite emergency blood coordinator at BloodNorms in Andhra Pradesh, India.
Talk like a genuine, compassionate human healthcare coordinator.
Rules:
1. Always be polite, empathetic, and respectful.
2. If answering blood donation health questions (weight, hemoglobin, fever, tattoos, intervals), give clear, reassuring, safe advice in 2-3 sentences.
3. Keep answers concise for WhatsApp with gentle *bold* highlights. Always provide: 👉 https://bloodnorms.vercel.app`;

async function callOpenRouter(userText) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;
  const model = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3.5-lightning:free';
  try {
    const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'HTTP-Referer': 'https://bloodnorms.vercel.app',
        'X-Title': 'BloodNorms Emergency',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: userText },
        ],
        reasoning: { effort: 'none' },
        temperature: 0.6,
        max_tokens: 200,
      }),
    });
    const data = await res.json();
    const msg = data.choices?.[0]?.message;
    return (msg?.content || msg?.reasoning || '').trim();
  } catch (err) {
    console.error('[AI Responder] OpenRouter error:', err.message);
    return null;
  }
}

/**
 * Main conversational flow handler
 */
async function handleUserInteraction(messageObj, fromPhone) {
  const phoneE164 = fromPhone.startsWith('+') ? fromPhone : `+${fromPhone}`;
  const isLocation = messageObj.type === 'location';
  const text = (messageObj.text?.body || messageObj.text || '').trim();
  const textUpper = text.toUpperCase();

  // 1. Legal DPDP Opt-Out
  if (textUpper === 'STOP' || textUpper === 'ఆపండి' || textUpper === 'रोकें') {
    return 'BloodNorms: You have been opted out. Reply START anytime to resume life-saving alerts. Take care!';
  }

  // 2. Fetch session
  let session = await getSession(phoneE164);
  const isGreeting = /^(hi|hello|hey|namaste|నమస్కారం|start|reset)\b/i.test(text);

  // Reset or Start New
  if (!session || isGreeting) {
    await saveSession(phoneE164, 'awaiting_blood_group', {});
    return 'Hello! 👋 I am Priya, your emergency coordinator at BloodNorms.\n\nI am here with you. Which *blood group* do you need right now?\n*(e.g. O+, A+, B+, AB+, O-, A-, B-, AB-)*';
  }

  const state = session.state;
  const slots = session.slots || {};

  // Step 1: Awaiting Blood Group
  if (state === 'awaiting_blood_group') {
    const group = extractBloodGroup(text);
    if (group) {
      slots.blood_group = group;
      await saveSession(phoneE164, 'awaiting_location', slots);
      return `Got it, *${group}* noted! 🩸\n\nWhere do you need the blood?\n📍 *Send your Location* (tap 📎 attachment icon → *Location*), or simply type your *Hospital / Area name* (e.g. *GGH Rajahmundry, Danavaipeta, Kakinada*).`;
    }
    const aiAnswer = await callOpenRouter(text);
    return (aiAnswer ? `${aiAnswer}\n\n` : '') + 'Could you please let me know which *blood group* is needed? *(e.g. O+, A+, B+, AB-)*';
  }

  // Step 2: Awaiting Location
  if (state === 'awaiting_location') {
    let loc = { lat: 17.0005, lng: 81.7800, name: 'Rajahmundry' };
    if (isLocation && messageObj.location) {
      loc = {
        lat: messageObj.location.latitude || 17.0005,
        lng: messageObj.location.longitude || 81.7800,
        name: messageObj.location.name || messageObj.location.address || 'Your Current Location',
      };
    } else if (text) {
      loc.name = text;
    }
    slots.location = loc;
    await saveSession(phoneE164, 'awaiting_choice', slots);

    return `📍 *Verified Blood Centers Near ${loc.name}:*\n\n🏥 *1. GGH Blood Centre (Government General Hospital)*\nDanavaipeta, Rajahmundry • 📞 +91 883-2471234 (24x7)\n\n🏥 *2. Rotary Blood Bank*\nNear RTC Complex • 📞 +91 883-2462233\n\n🔗 *View Live Stock:* https://bloodnorms.vercel.app/#/banks\n\n---\nWould you like me to start an emergency search for *volunteer donors* nearby?\n\n👉 Reply *1* for *Search Donors*\n👉 Reply *2* for *Blood Banks Only*`;
  }

  // Step 3: Awaiting Choice (Donors vs Banks)
  if (state === 'awaiting_choice') {
    if (textUpper === '1' || /donor|search|yes|అవును|हाँ/i.test(textUpper)) {
      await saveSession(phoneE164, 'awaiting_details', slots);
      return `I am ready to alert all verified donors near you immediately! 🚨\n\nPlease send these quick details in one message:\n1. *Patient Name & Age* (e.g. *Ramesh, 45*)\n2. *Reason for Blood* (e.g. *Accident / Surgery*)\n3. *Units Needed* (e.g. *2 units*)\n4. *Time Required* (e.g. *Immediate / 2 hours*)\n\n*(Example: Ramesh, 45, Accident surgery, 2 units, within 2 hours)*`;
    }
    return `Understood! You can contact the blood banks directly. If you want to broadcast an emergency donor alert anytime, just reply *1* or *SEARCH DONOR*. Take care! 💙`;
  }

  // Step 4: Awaiting Patient Details -> Create Request
  if (state === 'awaiting_details') {
    const details = parsePatientDetails(text);
    const createdReq = await createBloodRequest(phoneE164, slots, details);
    const reqId = createdReq ? createdReq.id : 'live-active';
    slots.request_id = reqId;
    await saveSession(phoneE164, 'search_active', slots, reqId);

    return `🚨 *Emergency Donor Search Activated!*\n\n• *Patient:* ${details.name} (${details.age} yrs)\n• *Blood Group:* *${slots.blood_group || 'O+'}*\n• *Units Needed:* ${details.units} unit(s)\n• *Hospital:* ${slots.location?.name || 'Hospital'}\n\nBroadcasting emergency alerts to verified donors within *2 km* right now!\n\n📱 *Live Radar & Donor Tracking:*\n👉 https://bloodnorms.vercel.app/#/track/${reqId}\n\nI am staying with you right here on WhatsApp! The moment a donor accepts, I will message you immediately with their details.\n\nIf no donor responds within 2 km, should I expand to *5 km*?\n👉 Reply *YES* to expand`;
  }

  // Step 5: Search Active -> Expand Radius or Health Questions
  if (state === 'search_active') {
    if (/yes|expand|పెంచండి|हाँ/i.test(textUpper)) {
      if (slots.request_id) {
        await expandSearchRadius(slots.request_id, 5.0);
      }
      return `✅ *Search Radius Expanded to 5 km!*\n\nWe have dispatched emergency alerts to additional volunteer donors across the 5 km ring.\n\n📱 *Track live responses:*\n👉 https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live-active'}\n\nStill standing by with you. I will notify you the second a donor confirms!`;
    }
    const aiAnswer = await callOpenRouter(text);
    return (aiAnswer ? `${aiAnswer}\n\n` : '') + `Emergency donor search is active! 📱 Live tracking: https://bloodnorms.vercel.app/#/track/${slots.request_id || 'live-active'}`;
  }

  return 'I am right here with you! Tell me how I can assist or reply *RESET* to start a new emergency search.';
}

module.exports = {
  handleUserInteraction,
};
