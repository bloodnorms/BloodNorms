// ============================================================================
// BloodNorms Voice Gateway | lib/metrics.ts
//
// Prometheus metrics collector exposing standard RED (Rate, Errors, Duration) metrics.
// Exposed via GET /metrics in standard Prometheus text format.
// ============================================================================

export class MetricsCollector {
  private activeCalls = 0;
  private callsTotal = {
    completed: 0,
    failed: 0,
    rejected: 0,
  };
  private callDurationsSeconds: number[] = [];
  private httpRequestsTotal = new Map<string, number>();

  setActiveCalls(count: number): void {
    this.activeCalls = Math.max(0, count);
  }

  recordCallOutcome(status: "completed" | "failed" | "rejected", durationSeconds?: number): void {
    this.callsTotal[status] = (this.callsTotal[status] || 0) + 1;
    if (durationSeconds !== undefined && durationSeconds >= 0) {
      this.callDurationsSeconds.push(durationSeconds);
      if (this.callDurationsSeconds.length > 500) {
        this.callDurationsSeconds.shift();
      }
    }
  }

  recordHttpRequest(method: string, path: string, statusCode: number): void {
    const key = `${method.toUpperCase()}_${path}_${statusCode}`;
    const current = this.httpRequestsTotal.get(key) || 0;
    this.httpRequestsTotal.set(key, current + 1);
  }

  toPrometheusText(): string {
    const mem = process.memoryUsage();
    const uptime = Math.floor(process.uptime());

    const lines: string[] = [
      "# HELP voice_gateway_uptime_seconds Number of seconds the service has been running.",
      "# TYPE voice_gateway_uptime_seconds gauge",
      `voice_gateway_uptime_seconds ${uptime}`,
      "",
      "# HELP voice_gateway_memory_bytes Process memory usage in bytes.",
      "# TYPE voice_gateway_memory_bytes gauge",
      `voice_gateway_memory_bytes{type="rss"} ${mem.rss}`,
      `voice_gateway_memory_bytes{type="heap_used"} ${mem.heapUsed}`,
      `voice_gateway_memory_bytes{type="heap_total"} ${mem.heapTotal}`,
      "",
      "# HELP voice_calls_active Number of currently active inbound voice media streams.",
      "# TYPE voice_calls_active gauge",
      `voice_calls_active ${this.activeCalls}`,
      "",
      "# HELP voice_calls_total Cumulative count of voice calls by outcome.",
      "# TYPE voice_calls_total counter",
      `voice_calls_total{status="completed"} ${this.callsTotal.completed}`,
      `voice_calls_total{status="failed"} ${this.callsTotal.failed}`,
      `voice_calls_total{status="rejected"} ${this.callsTotal.rejected}`,
      "",
      "# HELP http_requests_total Cumulative count of HTTP requests handled.",
      "# TYPE http_requests_total counter",
    ];

    for (const [key, count] of this.httpRequestsTotal.entries()) {
      const parts = key.split("_");
      const method = parts[0];
      const path = parts.slice(1, -1).join("_");
      const status = parts[parts.length - 1];
      lines.push(`http_requests_total{method="${method}",path="${path}",status="${status}"} ${count}`);
    }

    lines.push("");
    return lines.join("\n");
  }

  reset(): void {
    this.activeCalls = 0;
    this.callsTotal = { completed: 0, failed: 0, rejected: 0 };
    this.callDurationsSeconds = [];
    this.httpRequestsTotal.clear();
  }
}

export const metrics = new MetricsCollector();
