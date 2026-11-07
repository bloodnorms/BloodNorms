// ============================================================================
// BloodNorms Voice Gateway | types/index.ts
//
// Type definitions for Twilio media streams, session state, and speech providers.
// ============================================================================

export type TwilioEvent =
  | { event: "start"; streamSid: string; start: { callSid: string } }
  | { event: "media"; streamSid: string; media: { payload: string; track?: string; timestamp?: string } }
  | { event: "stop"; streamSid: string }
  | { event: "mark"; streamSid: string; mark: { name: string } };

export interface AudioChunk {
  mimeType: string;
  data: string; // base64 encoded audio
}

export interface SpeechProviderCallbacks {
  onAudio: (base64Audio: string) => void;
  onInterrupted: () => void;
  onError: (err: Error) => void;
  onClose: () => void;
}

export interface SpeechProvider {
  connect(callbacks: SpeechProviderCallbacks): Promise<void>;
  sendAudio(base64Payload: string): void;
  close(): void;
  readonly isConnected: boolean;
}
