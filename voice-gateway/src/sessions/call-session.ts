// ============================================================================
// BloodNorms Voice Gateway | sessions/call-session.ts
//
// Manages the state and bidirectional audio pipeline for a single call.
// Validates event structure and guards against oversized payloads.
// ============================================================================

import { WebSocket } from "ws";
import { GeminiLiveAdapter } from "../providers/gemini-live-adapter.js";
import type { SpeechProvider, TwilioEvent } from "../types/index.js";
import { logger } from "../lib/logger.js";

const MAX_MESSAGE_BYTES = 65536;

export class CallSession {
  private streamSid: string = "";
  private speechProvider: SpeechProvider;

  constructor(private twilioWs: WebSocket, provider?: SpeechProvider) {
    this.speechProvider = provider || new GeminiLiveAdapter();
    this.setupTwilioListeners();
  }

  getStreamSid(): string {
    return this.streamSid;
  }

  private setupTwilioListeners(): void {
    this.twilioWs.on("message", (raw: string | Buffer) => {
      this.handleTwilioMessage(raw);
    });

    this.twilioWs.on("close", () => {
      this.destroy();
    });
  }

  private async handleTwilioMessage(raw: string | Buffer): Promise<void> {
    try {
      const payloadStr = typeof raw === "string" ? raw : raw.toString("utf8");

      if (payloadStr.length > MAX_MESSAGE_BYTES) {
        logger.warn("[CallSession] Message exceeded maximum allowed byte size. Dropping.");
        return;
      }

      const data: TwilioEvent = JSON.parse(payloadStr);

      if (!data || typeof data !== "object" || typeof (data as any).event !== "string") {
        return;
      }

      switch (data.event) {
        case "start":
          if (data.streamSid && typeof data.streamSid === "string") {
            this.streamSid = data.streamSid;
            logger.info({ streamSid: this.streamSid }, "[CallSession] Call started");
            await this.initializeSpeechProvider();
          }
          break;

        case "media":
          if (data.media && typeof data.media.payload === "string") {
            this.speechProvider.sendAudio(data.media.payload);
          }
          break;

        case "stop":
          logger.info({ streamSid: this.streamSid }, "[CallSession] Call stopped");
          this.destroy();
          break;
      }
    } catch (err) {
      logger.error({ err }, "[CallSession] Error parsing Twilio event");
    }
  }

  private async initializeSpeechProvider(): Promise<void> {
    await this.speechProvider.connect({
      onAudio: (base64Audio: string) => {
        if (this.twilioWs.readyState === WebSocket.OPEN) {
          this.twilioWs.send(
            JSON.stringify({
              event: "media",
              streamSid: this.streamSid,
              media: { payload: base64Audio },
            })
          );
        }
      },
      onInterrupted: () => {
        if (this.twilioWs.readyState === WebSocket.OPEN) {
          this.twilioWs.send(
            JSON.stringify({
              event: "clear",
              streamSid: this.streamSid,
            })
          );
        }
      },
      onError: (err: Error) => {
        logger.error({ err }, "[CallSession] Speech provider error");
      },
      onClose: () => {
        logger.info({ streamSid: this.streamSid }, "[CallSession] Speech provider closed");
      },
    });
  }

  destroy(): void {
    this.speechProvider.close();
  }
}
