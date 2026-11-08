// ============================================================================
// BloodNorms | api/ai-responder.js
// OpenRouter AI & Fast Intent Triage Engine for WhatsApp
// ============================================================================

const SYSTEM_PROMPT = `You are BloodNorms Emergency AI, an empathetic, rapid triage assistant for emergency blood requests and donor coordination in Andhra Pradesh, India.
Rules:
1. Reply in 2-3 concise, helpful sentences with WhatsApp markdown (*bold*, emoji). Keep under 50 words.
2. If the user needs blood or asks for blood stock/donors, extract their blood group if mentioned and include: 👉 https://bloodnorms.vercel.app
3. If the user wants to donate or register as a donor, direct them to: 👉 https://bloodnorms.vercel.app
4. Match the user's language naturally (English, Telugu/తెలుగు, or Hindi/हिंदी).
5. Never provide prescription medical advice or clinical diagnoses.`;

/**
 * Normalizes common blood group variations (e.g. "o positive", "O+", "b neg")
 */
function extractBloodGroup(text) {
  const normalized = text.toLowerCase().replace(/[\s_-]+/g, ' ').trim();
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
    if (normalized === key || normalized.includes(` ${key} `) || normalized.startsWith(`${key} `) || normalized.endsWith(` ${key}`)) {
      return val;
    }
  }
  return null;
}

/**
 * Fast local heuristic fallback when AI key is pending or network is slow
 */
function localFallbackReply(text) {
  const upper = text.toUpperCase().trim();
  const bloodGroup = extractBloodGroup(text);

  if (upper === 'STOP' || upper === 'ఆపండి' || upper === 'रोकें') {
    return 'BloodNorms: You have been opted out. Reply START anytime to resume life-saving alerts.';
  }

  if (upper === 'YES' || upper === 'CONFIRM' || upper === 'అవును' || upper === 'हाँ') {
    return '🩸 *Thank you for confirming!* Your volunteer blood donation attendance is recorded in BloodNorms. You are saving lives today!';
  }

  if (bloodGroup) {
    return `🩸 Blood Group *${bloodGroup}* noted!\n\nWe are searching verified blood banks and volunteer donors in your area.\n\nTrack live stock & emergency requests:\n👉 https://bloodnorms.vercel.app\n\nNeed immediate coordinator support? Call our 24/7 emergency pilot helpline.`;
  }

  if (/donate|donor|register|దానం|రక్తదానం/i.test(text)) {
    return '🩸 *Become a Hero with BloodNorms!*\n\nRegister as a verified volunteer donor to receive emergency alerts near you:\n👉 https://bloodnorms.vercel.app\n\nEvery donation can save up to 3 lives!';
  }

  return '🩸 *Welcome to BloodNorms Emergency Network!*\n\nTell us what you need in plain words (e.g. *"Need O+ in Rajahmundry"*, *"O positive"*, or *"Want to donate"*).\n\n• *Live Blood Portal:* https://bloodnorms.vercel.app\n• *Opt-out anytime:* Reply STOP\n\nHow can we help save a life right now?';
}

/**
 * Generates an intelligent, fast AI response via OpenRouter (with local fallback)
 */
async function generateAiReply(userText) {
  const trimmed = userText?.trim() || '';
  if (!trimmed) {
    return localFallbackReply('');
  }

  // 1. Direct blood group shorthand fast-path (0ms latency)
  const directBloodGroup = extractBloodGroup(trimmed);
  if (directBloodGroup && trimmed.length <= 15) {
    return localFallbackReply(trimmed);
  }

  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    console.log('[AI Responder] OPENROUTER_API_KEY not configured yet. Using instant local triage.');
    return localFallbackReply(trimmed);
  }

  // 2. OpenRouter Free & Fast Model Execution
  const model = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3.5-lightning:free';
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 4500); // 4.5s guard

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
          { role: 'user', content: trimmed },
        ],
        reasoning: { effort: 'none' },
        temperature: 0.2,
        max_tokens: 180,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      console.warn(`[AI Responder] OpenRouter returned ${res.status}: ${await res.text()}`);
      return localFallbackReply(trimmed);
    }

    const data = await res.json();
    const message = data.choices?.[0]?.message;
    const reply = (message?.content || message?.reasoning || '').trim();
    if (reply) {
      return reply;
    }
  } catch (err) {
    clearTimeout(timeoutId);
    console.error('[AI Responder] OpenRouter call error/timeout:', err.message);
  }

  return localFallbackReply(trimmed);
}

module.exports = {
  extractBloodGroup,
  generateAiReply,
  localFallbackReply,
};

