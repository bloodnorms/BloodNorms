// ============================================================================
// BloodNorms | supabase/functions/whatsapp-webhook/index.ts
// Meta WhatsApp Cloud API Inbound Webhook Router & Requester Assistant
// ============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const WHATSAPP_VERIFY_TOKEN = Deno.env.get("WHATSAPP_VERIFY_TOKEN") ?? "bloodnorms_wa_verify";
const WHATSAPP_TOKEN = Deno.env.get("WHATSAPP_TOKEN") ?? "";
const PHONE_NUMBER_ID = Deno.env.get("WHATSAPP_PHONE_NUMBER_ID") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req: Request) => {
  const url = new URL(req.url);

  // 1. Meta Webhook Verification (GET)
  if (req.method === "GET") {
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === WHATSAPP_VERIFY_TOKEN) {
      return new Response(challenge, { status: 200 });
    }
    return new Response("Forbidden", { status: 403 });
  }

  // 2. Incoming Messages (POST)
  if (req.method === "POST") {
    try {
      const body = await req.json();
      const entry = body.entry?.[0];
      const changes = entry?.changes?.[0];
      const value = changes?.value;
      const message = value?.messages?.[0];

      if (!message) {
        return new Response("OK", { status: 200 });
      }

      const from = message.from; // e164 number without '+'
      const phoneE164 = `+${from}`;
      const messageType = message.type;

      // Handle STOP command immediately per BR-14
      if (messageType === "text") {
        const text = message.text.body.trim().toUpperCase();
        if (text === "STOP" || text === "ఆపండి" || text === "रोकें") {
          await handleOptOut(phoneE164);
          await sendWhatsAppText(from, "BloodNorms: You have been opted out. You will not receive any more alerts. Reply START to resume.");
          return new Response("OK", { status: 200 });
        }
      }

      // Router: Check if requester or donor flow
      // 1. Check existing inbound session
      const { data: session } = await supabase
        .from("inbound_sessions")
        .select("*")
        .eq("phone_e164", phoneE164)
        .gt("expires_at", new Date().toISOString())
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (!session) {
        // Start new requester session with greeting and 3 language buttons
        await supabase.from("inbound_sessions").insert({
          phone_e164: phoneE164,
          channel: "whatsapp",
          state: "ask_group",
          slots: {},
        });

        await sendWhatsAppButtons(from, "Welcome to BloodNorms. We help you find blood in minutes from honest blood banks and verified donors.\n\nChoose language / భాష / भाषा:", [
          { id: "lang_en", title: "English" },
          { id: "lang_te", title: "తెలుగు" },
          { id: "lang_hi", title: "हिन्दी" },
        ]);
      } else {
        // Continue state machine
        await handleSessionState(from, phoneE164, session, message);
      }

      return new Response("OK", { status: 200 });
    } catch (err) {
      console.error("Webhook processing error:", err);
      return new Response("Internal Server Error", { status: 500 });
    }
  }

  return new Response("Method not allowed", { status: 405 });
});

async function handleOptOut(phone: string) {
  // Find donor and suspend/opt-out
  const { data: donorPriv } = await supabase
    .from("donor_private")
    .select("donor_id")
    .eq("phone_e164", phone)
    .maybeSingle();

  if (donorPriv) {
    await supabase
      .from("donors")
      .update({ state: "paused", paused_until: "2099-01-01" })
      .eq("id", donorPriv.donor_id);
  }
}

async function handleSessionState(from: string, phone: string, session: any, message: any) {
  const text = message.text?.body?.trim() ?? "";
  const interactive = message.interactive;
  const buttonId = interactive?.button_reply?.id ?? interactive?.list_reply?.id;

  // Simple state progression
  if (session.state === "ask_group") {
    await supabase.from("inbound_sessions").update({ state: "ask_location", slots: { ...session.slots, group: text || "O+" } }).eq("id", session.id);
    await sendWhatsAppText(from, "Blood group noted. Please share your hospital location pin or type the area name (e.g., Rajahmundry):");
  } else if (session.state === "ask_location") {
    // Show nearest banks
    const { data: banks } = await supabase.rpc("nearest_banks", {
      p_lat: 17.0005,
      p_lng: 81.7820,
      p_group: session.slots?.group ?? "O+",
      p_component: "whole_blood",
      p_limit: 3,
    });

    let bankMsg = "Nearest Blood Banks:\n";
    if (banks && banks.length > 0) {
      banks.forEach((b: any, i: number) => {
        bankMsg += `\n${i + 1}. ${b.name}\n   Stock: ${b.stock_units} units · ${b.distance_km} km\n   Phone: ${b.phones?.[0] ?? "N/A"}\n`;
      });
      bankMsg += "\nAlways call before you go.";
    }

    await sendWhatsAppText(from, bankMsg);
    await sendWhatsAppButtons(from, "Would you like to search verified volunteer donors nearby?", [
      { id: "search_donors", title: "Search Donors" },
      { id: "got_blood", title: "Got Blood" },
    ]);
  }
}

async function sendWhatsAppText(to: string, bodyText: string) {
  if (!WHATSAPP_TOKEN || !PHONE_NUMBER_ID) return;
  await fetch(`https://graph.facebook.com/v19.0/${PHONE_NUMBER_ID}/messages`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${WHATSAPP_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      messaging_product: "whatsapp",
      to,
      type: "text",
      text: { body: bodyText },
    }),
  });
}

async function sendWhatsAppButtons(to: string, bodyText: string, buttons: Array<{ id: string; title: string }>) {
  if (!WHATSAPP_TOKEN || !PHONE_NUMBER_ID) return;
  await fetch(`https://graph.facebook.com/v19.0/${PHONE_NUMBER_ID}/messages`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${WHATSAPP_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      messaging_product: "whatsapp",
      to,
      type: "interactive",
      interactive: {
        type: "button",
        body: { text: bodyText },
        action: {
          buttons: buttons.map(b => ({
            type: "reply",
            reply: { id: b.id, title: b.title.substring(0, 20) },
          })),
        },
      },
    }),
  });
}

