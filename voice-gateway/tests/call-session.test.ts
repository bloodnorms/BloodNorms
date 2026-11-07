// ============================================================================
// BloodNorms Voice Gateway | tests/call-session.test.ts
//
// Unit tests for CallSession state machine, frame routing, and buffer clearance.
// ============================================================================

import test from "node:test";
import assert from "node:assert/strict";
import { EventEmitter } from "node:events";
import { CallSession } from "../dist/sessions/call-session.js";
import { MockSpeechProvider } from "./mock-speech-provider.ts";
import { WebSocket } from "ws";

class MockWebSocket extends EventEmitter {
  public readyState: number = WebSocket.OPEN;
  public sentMessages: string[] = [];

  send(data: string): void {
    this.sentMessages.push(data);
  }

  close(): void {
    this.readyState = WebSocket.CLOSED;
    this.emit("close");
  }
}

test("CallSession: handles start event and sets streamSid", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  ws.emit(
    "message",
    JSON.stringify({
      event: "start",
      streamSid: "MZ1234567890",
      start: { callSid: "CA9876543210" },
    })
  );

  // Allow async connect to resolve
  await new Promise((r) => setImmediate(r));

  assert.equal(session.getStreamSid(), "MZ1234567890");
  assert.equal(mockProvider.isConnected, true);
  session.destroy();
});

test("CallSession: forwards media chunks to speech provider", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  ws.emit(
    "message",
    JSON.stringify({
      event: "start",
      streamSid: "MZ_MEDIA_TEST",
      start: { callSid: "CA_MEDIA" },
    })
  );
  await new Promise((r) => setImmediate(r));

  ws.emit(
    "message",
    JSON.stringify({
      event: "media",
      streamSid: "MZ_MEDIA_TEST",
      media: { payload: "dGVzdF9hdWRpb19kYXRh" },
    })
  );

  assert.equal(mockProvider.sentAudioChunks.length, 1);
  assert.equal(mockProvider.sentAudioChunks[0], "dGVzdF9hdWRpb19kYXRh");
  session.destroy();
});

test("CallSession: sends media event to Twilio when speech provider produces audio", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  ws.emit(
    "message",
    JSON.stringify({
      event: "start",
      streamSid: "MZ_AUDIO_OUT",
      start: { callSid: "CA_OUT" },
    })
  );
  await new Promise((r) => setImmediate(r));

  mockProvider.simulateModelAudio("bW9kZWxfYXVkaW8=");

  assert.equal(ws.sentMessages.length, 1);
  const sent = JSON.parse(ws.sentMessages[0]);
  assert.equal(sent.event, "media");
  assert.equal(sent.streamSid, "MZ_AUDIO_OUT");
  assert.equal(sent.media.payload, "bW9kZWxfYXVkaW8=");
  session.destroy();
});

test("CallSession: sends clear event to Twilio on barge-in / interruption", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  ws.emit(
    "message",
    JSON.stringify({
      event: "start",
      streamSid: "MZ_CLEAR_TEST",
      start: { callSid: "CA_CLEAR" },
    })
  );
  await new Promise((r) => setImmediate(r));

  mockProvider.simulateInterruption();

  assert.equal(ws.sentMessages.length, 1);
  const sent = JSON.parse(ws.sentMessages[0]);
  assert.equal(sent.event, "clear");
  assert.equal(sent.streamSid, "MZ_CLEAR_TEST");
  session.destroy();
});

test("CallSession: drops messages exceeding 64KB without crashing", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  const oversized = "X".repeat(70000);
  ws.emit("message", oversized);

  assert.equal(mockProvider.sentAudioChunks.length, 0);
  session.destroy();
});

test("CallSession: cleanly closes speech provider on stop event", async () => {
  const ws = new MockWebSocket();
  const mockProvider = new MockSpeechProvider();
  const session = new CallSession(ws as unknown as WebSocket, mockProvider);

  ws.emit(
    "message",
    JSON.stringify({
      event: "start",
      streamSid: "MZ_STOP_TEST",
      start: { callSid: "CA_STOP" },
    })
  );
  await new Promise((r) => setImmediate(r));

  ws.emit(
    "message",
    JSON.stringify({
      event: "stop",
      streamSid: "MZ_STOP_TEST",
    })
  );

  assert.equal(mockProvider.closed, true);
});
