// ============================================================================
// BloodNorms | voice-gateway/src/index.ts
// Cloud Run Voice Gateway: Twilio Media Streams <-> Gemini Live API
// ============================================================================

import http from "node:http";
import crypto from "node:crypto";
import { WebSocketServer, WebSocket } from "ws";

const PORT = parseInt(process.env.PORT || "8080", 10);
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";
const VOICE_GATEWAY_SECRET = process.env.VOICE_GATEWAY_SECRET || "voice_secret";
const GEMINI_LIVE_MODEL = process.env.GEMINI_LIVE_MODEL || "gemini-2.0-flash-exp";

let activeCalls = 0;

const server = http.createServer((req, res) => {
  if (req.url === "/health" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ ok: true, version: "1.0.0", activeCalls }));
    return;
  }
  res.writeHead(404);
  res.end();
});

const wss = new WebSocketServer({ noServer: true });

server.on("upgrade", (req, socket, head) => {
  const url = new URL(req.url || "", `http://${req.headers.host}`);
  if (url.pathname === "/twilio/stream") {
    wss.handleUpgrade(req, socket, head, (ws) => {
      wss.emit("connection", ws, req);
    });
  } else {
    socket.destroy();
  }
});

wss.on("connection", (ws: WebSocket) => {
  activeCalls++;
  console.log(`[VoiceGateway] Call connected. Active calls: ${activeCalls}`);

  let streamSid = "";
  let geminiWs: WebSocket | null = null;

  ws.on("message", (rawMessage: string) => {
    try {
      const data = JSON.parse(rawMessage);
      switch (data.event) {
        case "start":
          streamSid = data.streamSid;
          console.log(`[VoiceGateway] Call started. Stream SID: ${streamSid}`);
          // Initialize Gemini Live session if key is available
          if (GEMINI_API_KEY) {
            connectGeminiLive(ws, streamSid);
          }
          break;

        case "media":
          // Forward audio to Gemini Live
          if (geminiWs && geminiWs.readyState === WebSocket.OPEN) {
            const payload = data.media.payload; // base64 u-law 8k
            geminiWs.send(JSON.stringify({
              realtimeInput: {
                mediaChunks: [
                  { mimeType: "audio/pcm;rate=16000", data: payload }
                ]
              }
            }));
          }
          break;

        case "stop":
          console.log(`[VoiceGateway] Call stopped for stream: ${streamSid}`);
          if (geminiWs) geminiWs.close();
          break;
      }
    } catch (e) {
      console.error("[VoiceGateway] Message parsing error:", e);
    }
  });

  ws.on("close", () => {
    activeCalls = Math.max(0, activeCalls - 1);
    if (geminiWs) geminiWs.close();
    console.log(`[VoiceGateway] Call disconnected. Active calls: ${activeCalls}`);
  });
});

function connectGeminiLive(twilioWs: WebSocket, streamSid: string) {
  const geminiEndpoint = `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=${GEMINI_API_KEY}`;
  const gWs = new WebSocket(geminiEndpoint);

  gWs.on("open", () => {
    console.log("[GeminiLive] Connected to speech-to-speech session");
    // Send session configuration
    gWs.send(JSON.stringify({
      setup: {
        model: `models/${GEMINI_LIVE_MODEL}`,
        generationConfig: {
          responseModalities: ["AUDIO"],
          speechConfig: {
            voiceConfig: {
              prebuiltVoiceConfig: { voiceName: "Sulafat" }
            }
          }
        },
        systemInstruction: {
          parts: [{ text: "You are the automated BloodNorms assistant. Speak warmly, briefly and calmly in Telugu, Hindi or English. Collect blood group, units, and hospital area. Never invent facts. Say you are an automated assistant." }]
        }
      }
    }));
  });

  gWs.on("message", (raw: string) => {
    try {
      const msg = JSON.parse(raw);
      const audioData = msg.serverContent?.modelTurn?.parts?.[0]?.inlineData?.data;
      if (audioData && twilioWs.readyState === WebSocket.OPEN) {
        // Stream audio back to Twilio
        twilioWs.send(JSON.stringify({
          event: "media",
          streamSid,
          media: { payload: audioData }
        }));
      }

      // Check interruption / barge-in
      if (msg.serverContent?.interrupted && twilioWs.readyState === WebSocket.OPEN) {
        twilioWs.send(JSON.stringify({
          event: "clear",
          streamSid
        }));
      }
    } catch (e) {
      console.error("[GeminiLive] Response processing error:", e);
    }
  });

  gWs.on("error", (err) => {
    console.error("[GeminiLive] Socket error:", err);
  });
}

server.listen(PORT, () => {
  console.log(`[VoiceGateway] Server running on port ${PORT}`);
});

