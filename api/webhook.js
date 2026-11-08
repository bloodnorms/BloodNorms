// ============================================================================
// BloodNorms | api/webhook.js
// Meta WhatsApp Cloud API Production Webhook & AI Responder Gateway
// ============================================================================

const { generateAiReply } = require('./ai-responder');

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

      console.log(`[WhatsApp Webhook] Received ${messageType} from ${from}: "${text}"`);

      // Generate conversational AI / intelligent triage reply
      const reply = await generateAiReply(text);
      await sendWhatsAppMessage(from, reply);

      return res.status(200).json({ status: 'success', from });
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
