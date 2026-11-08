// ============================================================================
// BloodNorms | api/whatsapp-sender.js
// Outbound Meta WhatsApp Graph API Dispatcher (Buttons & Text)
// ============================================================================

async function sendWhatsAppMessage(to, payload) {
  const phoneId = process.env.WHATSAPP_PHONE_NUMBER_ID || '1427256480473692';
  const token = process.env.WHATSAPP_ACCESS_TOKEN;

  if (!phoneId || !token) {
    console.error('[WhatsApp Webhook] Missing PHONE_NUMBER_ID or ACCESS_TOKEN');
    return null;
  }

  let body;
  if (typeof payload === 'object' && payload.buttons && payload.buttons.length > 0) {
    body = {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to,
      type: 'interactive',
      interactive: {
        type: 'button',
        body: { text: payload.text },
        action: {
          buttons: payload.buttons.slice(0, 3).map((b) => ({
            type: 'reply',
            reply: { id: b.id, title: b.title.substring(0, 20) },
          })),
        },
      },
    };
  } else {
    const text = typeof payload === 'string' ? payload : (payload.text || '');
    body = {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to,
      type: 'text',
      text: { body: text },
    };
  }

  try {
    const res = await fetch(`https://graph.facebook.com/v19.0/${phoneId}/messages`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (err) {
    console.error(`[WhatsApp Outbound] Error sending to ${to}:`, err);
    return null;
  }
}

module.exports = { sendWhatsAppMessage };

