// ============================================================================
// BloodNorms Voice Gateway | lib/logger.ts
//
// Structured logger instance with sensitive payload redaction.
// Adheres to Hard Privacy Line 2: Never log raw caller audio or PII transcripts.
// ============================================================================

import pino from "pino";
import { env } from "../config/env.js";

export const logger = pino({
  level: env.NODE_ENV === "production" ? "info" : "debug",
  redact: ["payload", "data", "audio", "transcript"],
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
});

