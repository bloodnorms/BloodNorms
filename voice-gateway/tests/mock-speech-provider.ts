// ============================================================================
// BloodNorms Voice Gateway | tests/mock-speech-provider.ts
//
// In-memory mock implementation of SpeechProvider for deterministic testing.
// Never connects to real Google Gemini Live API.
// ============================================================================

import type { SpeechProvider, SpeechProviderCallbacks } from "../dist/types/index.js";

export class MockSpeechProvider implements SpeechProvider {
  public isConnected: boolean = false;
  public sentAudioChunks: string[] = [];
  public callbacks: SpeechProviderCallbacks | null = null;
  public closed: boolean = false;

  async connect(callbacks: SpeechProviderCallbacks): Promise<void> {
    this.callbacks = callbacks;
    this.isConnected = true;
    this.closed = false;
  }

  sendAudio(base64Payload: string): void {
    if (!this.isConnected) {
      throw new Error("Cannot send audio when disconnected");
    }
    this.sentAudioChunks.push(base64Payload);
  }

  close(): void {
    this.isConnected = false;
    this.closed = true;
    if (this.callbacks?.onClose) {
      this.callbacks.onClose();
    }
  }

  // Test helper methods
  simulateModelAudio(base64Audio: string): void {
    if (this.callbacks?.onAudio) {
      this.callbacks.onAudio(base64Audio);
    }
  }

  simulateInterruption(): void {
    if (this.callbacks?.onInterrupted) {
      this.callbacks.onInterrupted();
    }
  }

  simulateError(err: Error): void {
    if (this.callbacks?.onError) {
      this.callbacks.onError(err);
    }
  }
}
