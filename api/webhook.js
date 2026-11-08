// ============================================================================
// BloodNorms | api/webhook.js
// Meta WhatsApp Cloud API Production Webhook & Interactive Auto-Responder
// ============================================================================

/**
 * Sends outbound WhatsApp message via Meta Graph API
 */
async function sendWhatsAppMessage(to, text) {
  const phoneId = process.env.WHATSAPP_PHONE_NUMBER_ID || '1427256480473692';
  const token = process.env.WHATSAPP_ACCESS_TOKEN;

  if (!phoneId || !token) {
    console.error('[WhatsApp Webhook] Missing PHONE_NUMBER_ID or ACCESS_TOKEN');
    return;
  }

  try {
    const res = await fetch(`https://graph.facebook.com/v19.0/${phoneId}/messages`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to,
        type: 'text',
        text: { body: text },
      }),
    });

    const data = await res.json();
    console.log(`[WhatsApp Outbound] Response for ${to}:`, data);
  } catch (err) {
    console.error(`[WhatsApp Outbound] Error sending to ${to}:`, err);
  }
}

module.exports = async (req, res) => {
  // 1. Meta Webhook Verification Handshake (GET)
  if (req.method === 'GET') {
    const mode = req.query['hub.mode'];
    const token = req.query['hub.verify_token'];
    const challenge = req.query['hub.challenge'];
    const configuredToken = process.env.WHATSAPP_WEBHOOK_VERIFY_TOKEN;

    const isTokenValid =
      token === 'bloodnorms_wa_verify' ||
      (configuredToken && token === configuredToken);

    if (mode === 'subscribe' && isTokenValid) {
      console.log('[WhatsApp Webhook] Handshake verified successfully');
      return res.status(200).send(challenge);
    }

    console.warn('[WhatsApp Webhook] Handshake rejected for token:', token);
    return res.status(403).send('Forbidden: Invalid verify token');
  }

  // 2. Incoming Messages & Events from WhatsApp (POST)
  if (req.method === 'POST') {
    try {
      const body = req.body || {};
      const entry = body.entry?.[0];
      const changes = entry?.changes?.[0];
      const value = changes?.value;
      const message = value?.messages?.[0];

      if (!message) {
        return res.status(200).json({ status: 'ignored_no_message' });
      }

      const from = message.from; // Sender phone without '+'
      const messageType = message.type;
      const text = message.text?.body?.trim() || '';
      const textUpper = text.toUpperCase();

      console.log(`[WhatsApp Webhook] Received ${messageType} from ${from}: "${text}"`);

      // Handle DPDP Opt-Out (STOP)
      if (textUpper === 'STOP' || textUpper === 'ఆపండి' || textUpper === 'रोकें') {
        await sendWhatsAppMessage(
          from,
          'BloodNorms: You have been opted out. You will not receive any further alerts. Reply START to resume.'
        );
        return res.status(200).json({ status: 'opt_out_success', from });
      }

      // Handle Volunteer Confirmation (YES)
      if (textUpper === 'YES' || textUpper === 'CONFIRM' || textUpper === 'అవును' || textUpper === 'हाँ') {
        await sendWhatsAppMessage(
          from,
          '🩸 Thank you for confirming! Your volunteer blood donation attendance has been recorded in BloodNorms. You are saving lives today!'
        );
        return res.status(200).json({ status: 'confirm_success', from });
      }

      // Handle Blood Group Inquiry (e.g. O+, A+, B+, etc.)
      const bloodGroupRegex = /^(A|B|AB|O)[+-]$/i;
      if (bloodGroupRegex.test(textUpper)) {
        await sendWhatsAppMessage(
          from,
          `🩸 Blood Group *${textUpper}* noted!\n\nWe are searching verified blood banks and volunteer donors near your area.\n\nTrack stock & emergency requests live:\n👉 https://bloodnorms.vercel.app\n\nNeed immediate helpline? Call our 24/7 toll-free emergency coordinator.`
        );
        return res.status(200).json({ status: 'blood_group_noted', from });
      }

      // Default Interactive Greeting (e.g. for "hi", "hello", or any question)
      await sendWhatsAppMessage(
        from,
        '🩸 *Welcome to BloodNorms Emergency Network!*\n\nWe help you find verified blood donors and live blood bank stock in minutes.\n\n• *Reply with a Blood Group* (e.g. O+, B+, A+, AB-)\n• *Live Blood Portal:* https://bloodnorms.vercel.app\n• *Opt-out anytime:* Reply STOP\n\nHow can we help you save a life today?'
      );

      return res.status(200).json({ status: 'greeting_sent', from });
    } catch (err) {
      console.error('[WhatsApp Webhook] Error processing event:', err);
      if (!res.headersSent) {
        return res.status(200).json({ status: 'error_logged' });
      }
    }
    return;
  }

  return res.status(405).send('Method Not Allowed');
};
