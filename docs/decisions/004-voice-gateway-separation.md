# ADR 004: Decoupled Cloud Run Voice Gateway Architecture

## Status
Accepted

## Context
Inbound telephony from stressed families dialing the emergency helpline requires bidirectional, full-duplex audio streaming over WebSockets between Twilio Media Streams and Google Gemini Live Speech-to-Speech API. Supabase Edge Functions (Deno HTTP) cannot maintain long-lived stateful audio WebSockets with continuous PCM buffering and audio transcoding.

## Decision
Separate the real-time audio pipeline into an independent containerized microservice (`voice-gateway/`) hosted on Google Cloud Run, implemented in Node.js 22 with TypeScript and the `ws` library.

## Consequences
### Positive
- Strict isolation of sensitive database credentials: the Voice Gateway holds **zero database credentials or service role keys**.
- Sub-second audio latency and native barge-in (caller interruption) support.
- Encapsulation of telephony and AI vendor protocols behind common interfaces.

