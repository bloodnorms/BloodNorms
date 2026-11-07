// ============================================================================
// BloodNorms Voice Gateway | config/env.ts
//
// Validated environment configuration with fail-fast startup behavior.
// ============================================================================

import { z } from "zod";

const envSchema = z.object({
  PORT: z.coerce.number().default(8080),
  GEMINI_API_KEY: z.string().default(""),
  VOICE_GATEWAY_SECRET: z.string().default("voice_secret"),
  GEMINI_LIVE_MODEL: z.string().default("gemini-2.0-flash-exp"),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
});

export type EnvConfig = z.infer<typeof envSchema>;

export const env: EnvConfig = envSchema.parse(process.env);
