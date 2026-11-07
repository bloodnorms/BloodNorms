# BloodNorms — Metrics & Telemetry Reference (METRICS.md)

**Role:** Staff Site Reliability Engineer  
**Scope:** Voice Gateway, HTTP Ingress, Database Telemetry  
**Version:** 1.0.0

---

## 1. Metrics Catalog

The Voice Gateway exposes standard Prometheus metrics at `GET /metrics`:

| Metric Name | Type | Labels | Description |
|---|---|---|---|
| `voice_gateway_uptime_seconds` | Gauge | none | Uptime of the running Node.js process in seconds. |
| `voice_gateway_memory_bytes` | Gauge | `type="rss\|heap_used\|heap_total"` | Memory allocation metrics in bytes. |
| `voice_calls_active` | Gauge | none | Current number of active Twilio <-> Gemini bidirectional streams. Max: 50. |
| `voice_calls_total` | Counter | `status="completed\|failed\|rejected"` | Total voice calls processed since process start. |
| `http_requests_total` | Counter | `method`, `path`, `status` | Total HTTP requests handled by the gateway server. |

---

## 2. Key PromQL Query Patterns

### Active Call Saturation Ratio
```promql
voice_calls_active / 50
```

### Voice Call Rejection Rate (Capacity Saturation)
```promql
sum(rate(voice_calls_total{status="rejected"}[5m])) / sum(rate(voice_calls_total[5m]))
```

### HTTP Request Rate by Endpoint
```promql
sum by (path) (rate(http_requests_total[5m]))
```

---

## 3. Service Level Objectives (SLOs) & SLIs

| Service Domain | Service Level Indicator (SLI) | Service Level Objective (SLO) | Measurement Window |
|---|---|---|---|
| **Emergency Voice Ingress** | Fraction of successful WebSocket upgrades (`status="completed"`) | **>= 99.9%** | Rolling 30 days |
| **Barge-in Interruption Latency** | Time from caller speech to Twilio buffer clearance | **< 250 ms (P95)** | Rolling 7 days |
| **Helpline Liveness** | Fraction of `/healthz` checks returning 200 | **>= 99.95%** | Rolling 30 days |
| **Matching Tick Cycle** | Duration of `engine-tick` lease cycle | **< 5.0 s (P99)** | Rolling 24 hours |
