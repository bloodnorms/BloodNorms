// ============================================================================
// BloodNorms Voice Gateway | server/http-server.ts
//
// HTTP and WebSocket server with health check, concurrency caps, and authenticated upgrade.
// ============================================================================

import http from "node:http";
import { WebSocketServer, WebSocket } from "ws";
import { env } from "../config/env.js";
import { logger } from "../lib/logger.js";
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
    if (req.url === "/health" && req.method === "GET") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        status: "healthy",
        uptime_seconds: Math.floor(process.uptime()),
        active_calls: this.activeCalls,
      }));
      return;
    }

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

      // Concurrency protection: Reject if active calls reach capacity
      if (this.activeCalls >= MAX_CONCURRENT_CALLS) {
        logger.warn(
          { activeCalls: this.activeCalls, ip: req.socket.remoteAddress },
          "[GatewayServer] Concurrency cap reached. Rejecting connection."
        );
        socket.write("HTTP/1.1 503 Service Unavailable\r\n\r\n");
        socket.destroy();
        return;
      }

      // Security Check: Token parameter or Bearer header verification
      const secretParam = url.searchParams.get("secret");
      const authHeader = req.headers["authorization"]?.replace(/^Bearer\s+/i, "");
      const providedToken = secretParam || authHeader;
      const expectedSecret = env.VOICE_GATEWAY_SECRET;

      const isProduction = env.NODE_ENV === "production";
      const isSecretConfigured = expectedSecret && expectedSecret !== "voice_secret";

      if (isProduction || isSecretConfigured) {
        if (!providedToken || providedToken !== expectedSecret) {
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
      logger.info({ activeCalls: this.activeCalls }, "[GatewayServer] Twilio caller connected");

      new CallSession(ws);

      ws.on("close", () => {
        this.activeCalls = Math.max(0, this.activeCalls - 1);
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
