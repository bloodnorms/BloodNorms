// ============================================================================
// BloodNorms Voice Gateway | tests/http-server.test.ts
//
// Integration tests for HTTP endpoints, upgrade security, and concurrency bounds.
// ============================================================================

import test from "node:test";
import assert from "node:assert/strict";
import http from "node:http";
import { WebSocket } from "ws";
import { GatewayServer } from "../dist/server/http-server.js";

function makeRequest(
  port: number,
  path: string,
  headers: Record<string, string> = {}
): Promise<{ statusCode: number; headers: http.IncomingHttpHeaders; body: string }> {
  return new Promise((resolve, reject) => {
    http.get(`http://127.0.0.1:${port}${path}`, { headers }, (res) => {
      let body = "";
      res.on("data", (chunk) => (body += chunk));
      res.on("end", () => resolve({ statusCode: res.statusCode || 0, headers: res.headers, body }));
      res.on("error", reject);
    });
  });
}

test("GatewayServer: GET /health returns 200 OK and health telemetry with X-Request-Id", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    const res = await makeRequest(port, "/health", { "x-request-id": "test-req-12345" });
    assert.equal(res.statusCode, 200);
    assert.equal(res.headers["x-request-id"], "test-req-12345");
    const data = JSON.parse(res.body);
    assert.equal(data.status, "healthy");
    assert.equal(typeof data.uptime_seconds, "number");
    assert.equal(data.active_calls, 0);
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});

test("GatewayServer: GET /livez and /readyz return 200 OK probes", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    const livez = await makeRequest(port, "/livez");
    assert.equal(livez.statusCode, 200);
    assert.equal(livez.body, "OK");

    const readyz = await makeRequest(port, "/readyz");
    assert.equal(readyz.statusCode, 200);
    assert.equal(readyz.body, "READY");
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});

test("GatewayServer: GET /metrics returns Prometheus exposition format", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    const res = await makeRequest(port, "/metrics");
    assert.equal(res.statusCode, 200);
    assert.ok(res.body.includes("voice_gateway_uptime_seconds"));
    assert.ok(res.body.includes("voice_calls_active"));
    assert.ok(res.body.includes("voice_calls_total"));
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});

test("GatewayServer: GET unknown path returns 404 Not Found", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    const res = await makeRequest(port, "/invalid-endpoint");
    assert.equal(res.statusCode, 404);
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});

test("GatewayServer: rejects WebSocket upgrade to unauthorized path", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    await new Promise<void>((resolve, reject) => {
      const ws = new WebSocket(`ws://127.0.0.1:${port}/unauthorized-stream`);
      ws.on("open", () => reject(new Error("Expected connection to be rejected")));
      ws.on("error", () => resolve());
    });
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});

test("GatewayServer: connects via WebSocket on /twilio/stream and tracks active calls", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const port = server.getPort();

  try {
    const ws = new WebSocket(`ws://127.0.0.1:${port}/twilio/stream?secret=voice_secret`);

    await new Promise<void>((resolve, reject) => {
      ws.on("open", resolve);
      ws.on("error", reject);
    });

    assert.equal(server.getActiveCalls(), 1);

    ws.close();
    await new Promise((r) => setTimeout(r, 60));
    assert.equal(server.getActiveCalls(), 0);
  } finally {
    await new Promise<void>((resolve) => server.close(resolve));
  }
});
