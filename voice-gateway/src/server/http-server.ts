// ============================================================================
// BloodNorms Voice Gateway | server/http-server.ts
//
// HTTP and WebSocket server with health check and authenticated upgrade.
// ============================================================================

import http from "node:http";
import { WebSocketServer, WebSocket } from "ws";
import { env } from "../config/env.js";
import { logger } from "../lib/logger.js";
import { CallSession } from "../sessions/call-session.js";

export class GatewayServer {
  private server: http.Server;
  private wss: WebSocketServer;
  private activeCalls = 0;

  constructor() {
    this.server = http.createServer((req, res) => this.handleHttpRequest(req, res));
    this.wss = new WebSocketServer({ noServer: true });
    this.setupUpgradeHandler();
    this.setupWebSocketHandler();
  }

  private handleHttpRequest(req: http.IncomingMessage, res: http.ServerResponse): void {
    if (req.url === "/health" && req.method === "GET") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ ok: true, version: "1.0.0", activeCalls: this.activeCalls }));
      return;
    }

    res.writeHead(404);
    res.end();
  }

  private setupUpgradeHandler(): void {
    this.server.on("upgrade", (req, socket, head) => {
      const host = req.headers.host || "localhost";
      const url = new URL(req.url || "", `http://${host}`);

      if (url.pathname !== "/twilio/stream") {
        socket.destroy();
        return;
      }

      // Security Check: Optional secret token parameter or header verification
      const secretParam = url.searchParams.get("secret");
      const authHeader = req.headers["authorization"]?.replace(/^Bearer\s+/i, "");
      const isSecretConfigured = env.VOICE_GATEWAY_SECRET && env.VOICE_GATEWAY_SECRET !== "voice_secret";

      if (isSecretConfigured) {
        const providedToken = secretParam || authHeader;
        if (providedToken !== env.VOICE_GATEWAY_SECRET) {
          logger.warn({ ip: req.socket.remoteAddress }, "[GatewayServer] Unauthorized upgrade attempt rejected");
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

  close(callback?: () => void): void {
    this.wss.close();
    this.server.close(callback);
  }
}

