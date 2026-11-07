// ============================================================================
// BloodNorms | tests/load/http-load-test.ts
//
// HTTP Ingress Burst and Health Probe Throughput Benchmark.
// ============================================================================

import http from "node:http";

interface HttpLoadConfig {
  baseUrl: string;
  totalRequests: number;
  concurrency: number;
  path: string;
}

export async function runHttpLoadTest(config: HttpLoadConfig): Promise<{
  successCount: number;
  errorCount: number;
  avgLatencyMs: number;
  p95LatencyMs: number;
}> {
  const latencies: number[] = [];
  let successCount = 0;
  let errorCount = 0;

  const queue = Array.from({ length: config.totalRequests });

  async function worker(): Promise<void> {
    while (queue.length > 0) {
      queue.pop();
      const start = performance.now();

      await new Promise<void>((resolve) => {
        const req = http.get(`${config.baseUrl}${config.path}`, (res) => {
          res.on("data", () => {});
          res.on("end", () => {
            const duration = performance.now() - start;
            latencies.push(duration);
            if (res.statusCode && res.statusCode < 400) {
              successCount++;
            } else {
              errorCount++;
            }
            resolve();
          });
        });

        req.on("error", () => {
          errorCount++;
          resolve();
        });
      });
    }
  }

  const workers = Array.from({ length: config.concurrency }, () => worker());
  await Promise.all(workers);

  latencies.sort((a, b) => a - b);
  const avgLatencyMs = latencies.reduce((acc, v) => acc + v, 0) / (latencies.length || 1);
  const p95LatencyMs = latencies[Math.floor(latencies.length * 0.95)] || 0;

  return { successCount, errorCount, avgLatencyMs, p95LatencyMs };
}

if (process.argv[1]?.endsWith("http-load-test.ts") || process.argv[1]?.endsWith("http-load-test.js")) {
  const targetBase = process.env.BASE_URL || "http://localhost:8080";
  console.log(`[HttpLoadTest] Testing ${targetBase}/healthz ...`);

  runHttpLoadTest({
    baseUrl: targetBase,
    totalRequests: 200,
    concurrency: 20,
    path: "/healthz",
  }).then((res) => {
    console.log("==========================================");
    console.log("HTTP Healthz Throughput Benchmark");
    console.log("==========================================");
    console.log(`Success:     ${res.successCount}`);
    console.log(`Errors:      ${res.errorCount}`);
    console.log(`Avg Latency: ${res.avgLatencyMs.toFixed(2)} ms`);
    console.log(`P95 Latency: ${res.p95LatencyMs.toFixed(2)} ms`);
    console.log("==========================================");
  });
}
