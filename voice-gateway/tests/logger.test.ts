// ============================================================================
// BloodNorms Voice Gateway | tests/logger.test.ts
//
// Tests for structured logging and sensitive data redaction.
// ============================================================================

import test from "node:test";
import assert from "node:assert/strict";
import pino from "pino";

test("logger: redacts sensitive payload, audio, and transcript fields", () => {
  let loggedOutput = "";

  const testLogger = pino(
    {
      redact: ["payload", "data", "audio", "transcript"],
    },
    {
      write: (str) => {
        loggedOutput += str;
      },
    }
  );

  testLogger.info(
    {
      callSid: "CA_TEST_123",
      payload: "SENSITIVE_VOICE_BASE64_BYTES",
      audio: "RAW_AUDIO_STREAM",
      transcript: "Patient requires O+ blood urgently at Rajahmundry hospital",
    },
    "Processing call event"
  );

  const parsed = JSON.parse(loggedOutput);
  assert.equal(parsed.callSid, "CA_TEST_123");
  assert.equal(parsed.payload, "[Redacted]");
  assert.equal(parsed.audio, "[Redacted]");
  assert.equal(parsed.transcript, "[Redacted]");
});
