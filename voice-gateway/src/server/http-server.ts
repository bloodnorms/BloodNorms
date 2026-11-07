// ============================================================================
// BloodNorms Voice Gateway | server/http-server.ts
//
// HTTP, Prometheus metrics, and WebSocket server with health probes,
// distributed correlation IDs, concurrency caps, and authenticated upgrades.
// ============================================================================

import http from "node:http";
import crypto from "node:crypto";
import { WebSocketServer, WebSocket } from "ws";
import { env } from "../config/env.js";
import { logger } from "../lib/logger.js";
import { metrics } from "../lib/metrics.js";
import { CallSession } from "../sessions/call-session.js";

const MAX_CONCURRENT_CALLS = 50;

export class GatewayServer {
  private server: http.Server;
  private wss: WebSocketServer;
  private activeCalls = 0;

  constructor() {
    this.server = http.createServer((req, res) => this.handleHttpRequest(req, res));
    this.wss = new WebSocketServer({ noServer: true, maxPayload: 65536 });
    this.setupUpgradeHandler();
    this.setupWebSocketHandler();
  }

  private handleHttpRequest(req: http.IncomingMessage, res: http.ServerResponse): void {
    const reqId = (req.headers["x-request-id"] as string) || crypto.randomUUID();
    res.setHeader("X-Request-Id", reqId);

    const url = req.url || "/";
    const method = req.method || "GET";

    if (method === "GET" && (url === "/health" || url === "/healthz")) {
      metrics.recordHttpRequest(method, url, 200);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        status: "healthy",
        uptime_seconds: Math.floor(process.uptime()),
        active_calls: this.activeCalls,
      }));
      return;
    }

    if (method === "GET" && url === "/livez") {
      metrics.recordHttpRequest(method, url, 200);
      res.writeHead(200, { "Content-Type": "text/plain" });
      res.end("OK");
      return;
    }

    if (method === "GET" && url === "/readyz") {
      const isReady = this.activeCalls < MAX_CONCURRENT_CALLS;
      const status = isReady ? 200 : 503;
      metrics.recordHttpRequest(method, url, status);
      res.writeHead(status, { "Content-Type": "text/plain" });
      res.end(isReady ? "READY" : "OVERLOADED");
      return;
    }

    if (method === "GET" && url === "/metrics") {
      metrics.setActiveCalls(this.activeCalls);
      metrics.recordHttpRequest(method, url, 200);
      res.writeHead(200, { "Content-Type": "text/plain; version=0.0.4; charset=utf-8" });
      res.end(metrics.toPrometheusText());
      return;
    }

    metrics.recordHttpRequest(method, url, 404);
    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("Not Found");
  }

  private setupUpgradeHandler(): void {
    this.server.on("upgrade", (req, socket, head) => {
      const host = req.headers.host || "localhost";
      const url = new URL(req.url || "", `http://${host}`);

      if (url.pathname !== "/twilio/stream") {
        socket.destroy();
        return;
      }

      if (this.activeCalls >= MAX_CONCURRENT_CALLS) {
        metrics.recordCallOutcome("rejected");
        logger.warn(
          { activeCalls: this.activeCalls, ip: req.socket.remoteAddress },
          "[GatewayServer] Concurrency cap reached. Rejecting connection."
        );
        socket.write("HTTP/1.1 503 Service Unavailable\r\n\r\n");
        socket.destroy();
        return;
      }

      const secretParam = url.searchParams.get("secret");
      const authHeader = req.headers["authorization"]?.replace(/^Bearer\s+/i, "");
      const providedToken = secretParam || authHeader;
      const expectedSecret = env.VOICE_GATEWAY_SECRET;

      const isProduction = env.NODE_ENV === "production";
      const isSecretConfigured = expectedSecret && expectedSecret !== "voice_secret";

      if (isProduction || isSecretConfigured) {
        if (!providedToken || providedToken !== expectedSecret) {
          metrics.recordCallOutcome("rejected");
          logger.warn(
            { ip: req.socket.remoteAddress },
            "[GatewayServer] Unauthorized upgrade attempt rejected"
          );
          socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
          socket.destroy();
          return;
        }
      }

      this.wss.handleUpgrade(req, socket, head, (ws) => {
        this.wss.emit("connection", ws, req);
      });
    });
  }

  private setupWebSocketHandler(): void {
    this.wss.on("connection", (ws: WebSocket) => {
      this.activeCalls++;
      metrics.setActiveCalls(this.activeCalls);
      logger.info({ activeCalls: this.activeCalls }, "[GatewayServer] Twilio caller connected");

      new CallSession(ws);

      ws.on("close", () => {
        this.activeCalls = Math.max(0, this.activeCalls - 1);
        metrics.setActiveCalls(this.activeCalls);
        metrics.recordCallOutcome("completed");
        logger.info({ activeCalls: this.activeCalls }, "[GatewayServer] Twilio caller disconnected");
      });
    });
  }

  listen(port: number, callback?: () => void): void {
    this.server.listen(port, callback);
  }

  getActiveCalls(): number {
    return this.activeCalls;
  }

  getPort(): number {
    const addr = this.server.address();
    return addr && typeof addr === "object" ? addr.port : 0;
  }

  close(callback?: () => void): void {
    this.wss.close();
    this.server.close(callback);
  }
}
