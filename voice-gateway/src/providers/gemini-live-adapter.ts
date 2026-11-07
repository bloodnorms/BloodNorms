// ============================================================================
// BloodNorms Voice Gateway | providers/gemini-live-adapter.ts
//
// Adapter for Google Gemini Live Speech-to-Speech API.
// Implements the vendor-agnostic SpeechProvider interface.
// ============================================================================

import { WebSocket } from "ws";
import { env } from "../config/env.js";
import { logger } from "../lib/logger.js";
import type { SpeechProvider, SpeechProviderCallbacks } from "../types/index.js";

export class GeminiLiveAdapter implements SpeechProvider {
  private ws: WebSocket | null = null;
  private callbacks: SpeechProviderCallbacks | null = null;

  get isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }

  async connect(callbacks: SpeechProviderCallbacks): Promise<void> {
    this.callbacks = callbacks;

    if (!env.GEMINI_API_KEY) {
      logger.warn("GEMINI_API_KEY not configured; speech session will not stream");
      return;
    }

    const endpoint = `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=${env.GEMINI_API_KEY}`;
    this.ws = new WebSocket(endpoint);

    this.ws.on("open", () => {
      logger.info("[GeminiLive] Connected to speech-to-speech session");
      this.sendSetupConfiguration();
    });

    this.ws.on("message", (raw: string) => {
      this.handleServerMessage(raw);
    });

    this.ws.on("error", (err: Error) => {
      logger.error({ err }, "[GeminiLive] Socket error");
      this.callbacks?.onError(err);
    });

    this.ws.on("close", () => {
      logger.info("[GeminiLive] Session closed");
      this.callbacks?.onClose();
      this.ws = null;
    });
  }

  sendAudio(base64Payload: string): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(
        JSON.stringify({
          realtimeInput: {
            mediaChunks: [
              { mimeType: "audio/pcm;rate=16000", data: base64Payload },
            ],
          },
        })
      );
    }
  }

  close(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  private sendSetupConfiguration(): void {
    if (!this.ws) return;
    this.ws.send(
      JSON.stringify({
        setup: {
          model: `models/${env.GEMINI_LIVE_MODEL}`,
          generationConfig: {
            responseModalities: ["AUDIO"],
            speechConfig: {
              voiceConfig: {
                prebuiltVoiceConfig: { voiceName: "Sulafat" },
              },
            },
          },
          systemInstruction: {
            parts: [
              {
                text: "You are the automated BloodNorms assistant. Speak warmly, briefly and calmly in Telugu, Hindi or English. Collect blood group, units, and hospital area. Never invent facts. Say you are an automated assistant.",
              },
            ],
          },
        },
      })
    );
  }

  private handleServerMessage(raw: string): void {
    try {
      const msg = JSON.parse(raw);
      const audioData = msg.serverContent?.modelTurn?.parts?.[0]?.inlineData?.data;

      if (audioData && this.callbacks) {
        this.callbacks.onAudio(audioData);
      }

      if (msg.serverContent?.interrupted && this.callbacks) {
        this.callbacks.onInterrupted();
      }
    } catch (e) {
      logger.error({ err: e }, "[GeminiLive] Response parsing error");
    }
  }
}

