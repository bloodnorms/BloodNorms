// ============================================================================
// BloodNorms Voice Gateway | sessions/call-session.ts
//
// Manages the state and bidirectional audio pipeline for a single call.
// ============================================================================

import { WebSocket } from "ws";
import { GeminiLiveAdapter } from "../providers/gemini-live-adapter.js";
import type { SpeechProvider, TwilioEvent } from "../types/index.js";
import { logger } from "../lib/logger.js";

export class CallSession {
  private streamSid: string = "";
  private speechProvider: SpeechProvider;

  constructor(private twilioWs: WebSocket) {
    this.speechProvider = new GeminiLiveAdapter();
    this.setupTwilioListeners();
  }

  private setupTwilioListeners(): void {
    this.twilioWs.on("message", (raw: string) => {
      this.handleTwilioMessage(raw);
    });

    this.twilioWs.on("close", () => {
      this.destroy();
    });
  }

  private async handleTwilioMessage(raw: string): Promise<void> {
    try {
      const data: TwilioEvent = JSON.parse(raw);

      switch (data.event) {
        case "start":
          this.streamSid = data.streamSid;
          logger.info({ streamSid: this.streamSid }, "[CallSession] Call started");
          await this.initializeSpeechProvider();
          break;

        case "media":
          this.speechProvider.sendAudio(data.media.payload);
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
