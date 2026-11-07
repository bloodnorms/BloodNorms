// ============================================================================
// BloodNorms Voice Gateway | index.ts
//
// Application entry point. Bootstraps the gateway server and handles
// graceful shutdown on SIGINT/SIGTERM signals.
// ============================================================================

import { env } from "./config/env.js";
import { logger } from "./lib/logger.js";
import { GatewayServer } from "./server/http-server.js";

const server = new GatewayServer();

server.listen(env.PORT, () => {
  logger.info({ port: env.PORT, env: env.NODE_ENV }, "[VoiceGateway] Server running");
});

function handleShutdown(signal: string): void {
  logger.info({ signal }, "[VoiceGateway] Graceful shutdown initiated");
  server.close(() => {
    logger.info("[VoiceGateway] Server closed successfully");
    process.exit(0);
  });
}

process.on("SIGINT", () => handleShutdown("SIGINT"));
process.on("SIGTERM", () => handleShutdown("SIGTERM"));
