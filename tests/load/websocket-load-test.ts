// ============================================================================
// BloodNorms | tests/load/websocket-load-test.ts
//
// Concurrency & stress testing harness for Voice Gateway.
// Measures WebSocket handshake latency, frame delivery, and saturation limits.
// ============================================================================

import { WebSocket } from "ws";

interface LoadTestConfig {
  gatewayUrl: string;
  concurrency: number;
  callDurationMs: number;
  messageIntervalMs: number;
}

interface LoadTestMetrics {
  totalConnections: number;
  successfulHandshakes: number;
  rejectedConnections: number;
  failedConnections: number;
  handshakeLatenciesMs: number[];
}

export async function runWebSocketLoadTest(config: LoadTestConfig): Promise<LoadTestMetrics> {
  const metrics: LoadTestMetrics = {
    totalConnections: config.concurrency,
    successfulHandshakes: 0,
    rejectedConnections: 0,
    failedConnections: 0,
    handshakeLatenciesMs: [],
  };

  const tasks: Promise<void>[] = [];

  for (let i = 0; i < config.concurrency; i++) {
    const streamSid = `MZ_LOAD_${Date.now()}_${i}`;
    tasks.push(
      new Promise<void>((resolve) => {
        const start = performance.now();
        const ws = new WebSocket(config.gatewayUrl);

        ws.on("open", () => {
          const latency = performance.now() - start;
          metrics.handshakeLatenciesMs.push(latency);
          metrics.successfulHandshakes++;

          // Send synthetic Twilio start event
          ws.send(
            JSON.stringify({
              event: "start",
              streamSid,
              start: { callSid: `CA_LOAD_${i}` },
            })
          );

          // Stream audio packets periodically
          const interval = setInterval(() => {
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(
                JSON.stringify({
                  event: "media",
                  streamSid,
                  media: { payload: "c3ludGhldGljX2F1ZGlvX2ZyYW1l" },
                })
              );
            }
          }, config.messageIntervalMs);

          // End call after specified duration
          setTimeout(() => {
            clearInterval(interval);
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(JSON.stringify({ event: "stop", streamSid }));
              ws.close();
            }
            resolve();
          }, config.callDurationMs);
        });

        ws.on("error", (err: any) => {
          if (err?.message?.includes("503")) {
            metrics.rejectedConnections++;
          } else {
            metrics.failedConnections++;
          }
          resolve();
        });
      })
    );
  }

  await Promise.all(tasks);
  return metrics;
}

// Standalone execution entrypoint
if (process.argv[1]?.endsWith("websocket-load-test.ts") || process.argv[1]?.endsWith("websocket-load-test.js")) {
  const targetUrl = process.env.VOICE_GATEWAY_URL || "ws://localhost:8080/twilio/stream?secret=voice_secret";
  console.log(`[LoadTest] Starting benchmark against: ${targetUrl}`);

  runWebSocketLoadTest({
    gatewayUrl: targetUrl,
    concurrency: 20,
    callDurationMs: 3000,
    messageIntervalMs: 200,
  }).then((results) => {
    const lats = results.handshakeLatenciesMs.sort((a, b) => a - b);
    const avg = lats.reduce((acc, v) => acc + v, 0) / (lats.length || 1);
    const p95 = lats[Math.floor(lats.length * 0.95)] || 0;

    console.log("==========================================");
    console.log("Voice Gateway Concurrency Load Test Results");
    console.log("==========================================");
    console.log(`Total Connections Attempted: ${results.totalConnections}`);
    console.log(`Successful Handshakes:       ${results.successfulHandshakes}`);
    console.log(`Rejected (503 Cap):          ${results.rejectedConnections}`);
    console.log(`Failures:                    ${results.failedConnections}`);
    console.log(`Avg Handshake Latency:       ${avg.toFixed(2)} ms`);
    console.log(`P95 Handshake Latency:       ${p95.toFixed(2)} ms`);
    console.log("==========================================");
  });
}
