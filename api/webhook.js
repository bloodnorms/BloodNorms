// ============================================================================
// BloodNorms | api/webhook.js
// Meta WhatsApp Cloud API Production Webhook & AI Responder Gateway
// ============================================================================

const { handleUserInteraction } = require('./ai-responder');
const { sendWhatsAppMessage } = require('./whatsapp-sender');

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

      // Generate conversational AI / emergency intake concierge reply
      const reply = await handleUserInteraction(message, from);
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
