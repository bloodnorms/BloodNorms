// ============================================================================
// BloodNorms | api/ai-responder.js
// Human-Like Warm AI Emergency Coordinator powered by OpenRouter
// ============================================================================

const SYSTEM_PROMPT = `You are Priya, a warm, caring, and polite emergency blood coordinator at BloodNorms in Andhra Pradesh, India.
Talk like a genuine, compassionate human coordinator — never sound like a robotic menu, scripted bot, or automated system.

Guidelines:
1. Warm & Human Tone: Address the person with genuine warmth, empathy, and respect. Be friendly and conversational.
2. Natural, Varied Greetings: When someone says "hi", "hello", "hey", "namaste", or "నమస్కారం", greet them warmly and uniquely like a real person, asking how you can help them or their loved ones today. Never repeat robotic canned templates.
3. Health & Blood Donation Inquiries: Politely answer questions about blood donation eligibility and donor health (e.g. weight, hemoglobin levels, tattoos, fever/illness recovery, intervals between donations, hydration). Keep health guidance strictly focused on safe blood donation and general wellness.
4. Blood Requests & Emergencies: If someone needs blood, mentions a blood group (e.g. O+, B+, A-, AB+), or is looking for blood banks, reassure them with empathy and provide our live search portal: 👉 https://bloodnorms.vercel.app
5. Becoming a Donor: If someone wants to donate blood or volunteer, appreciate their kindness warmly and guide them to: 👉 https://bloodnorms.vercel.app
6. Multi-lingual: Naturally match the user's language (English, Telugu/తెలుగు, or Hindi/हिंदी).
7. Format: Keep replies concise (2 to 4 sentences), easy to read on WhatsApp with gentle formatting (*bold* for emphasis, friendly emojis).`;

/**
 * Polite, caring local fallback only used if OpenRouter is unreachable
 */
function localFallbackReply(text) {
  const upper = text.toUpperCase().trim();

  if (upper === 'STOP' || upper === 'ఆపండి' || upper === 'रोकें') {
    return 'BloodNorms: You have been opted out. Reply START anytime if you wish to receive alerts again. Take care!';
  }

  if (upper === 'YES' || upper === 'CONFIRM' || upper === 'అవును' || upper === 'हाँ') {
    return '❤️ *Thank you so much!* Your confirmation as a volunteer donor has been recorded. You are truly helping save lives today!';
  }

  return 'Hello! 😊 I am Priya from BloodNorms. I am here to help you find blood donors, check blood bank stock, or answer any questions about donating blood. How can I assist you right now?\n\n👉 https://bloodnorms.vercel.app';
}

/**
 * Generates a warm, human-like AI response via OpenRouter
 */
async function generateAiReply(userText) {
  const trimmed = userText?.trim() || '';
  if (!trimmed) {
    return localFallbackReply('');
  }

  // Legal DPDP Opt-out check
  const upper = trimmed.toUpperCase();
  if (upper === 'STOP' || upper === 'ఆపండి' || upper === 'रोकें') {
    return localFallbackReply(trimmed);
  }

  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    console.warn('[AI Responder] OPENROUTER_API_KEY not found in environment.');
    return localFallbackReply(trimmed);
  }

  const model = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3.5-lightning:free';
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 4800); // 4.8s guard

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
        temperature: 0.7,
        max_tokens: 200,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      console.warn(`[AI Responder] OpenRouter status ${res.status}: ${await res.text()}`);
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
    console.error('[AI Responder] OpenRouter error:', err.message);
  }

  return localFallbackReply(trimmed);
}

module.exports = {
  generateAiReply,
  localFallbackReply,
};
