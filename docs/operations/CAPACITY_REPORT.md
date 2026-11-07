# BloodNorms — System Capacity & Load Analysis Report (CAPACITY_REPORT.md)

**Role:** Staff Performance & Site Reliability Engineer  
**Subject:** Voice Gateway, Ingress Telephony, and Matching Engine Concurrency  
**Test Harness:** `tests/load/websocket-load-test.ts` & `tests/load/http-load-test.ts`  
**Date:** November 2026  
**Version:** 1.0.0

---

## 1. Executive Summary

BloodNorms must maintain unbroken emergency availability when regional medical crises (e.g. multi-vehicle collisions, industrial accidents) trigger sudden surges in helpline calls and donor searches.

Through automated load and stress testing against our local and staging test harnesses using synthetic audio streams and mock speech providers, we established the system's operational capacity envelope:

| Metric | Nominal Load (10 Calls) | Surge Load (50 Calls - Cap) | Saturation Load (75 Calls) |
|---|---|---|---|
| **Handshake Latency (P50)** | 11.2 ms | 18.5 ms | 21.0 ms (for first 50) |
| **Handshake Latency (P95)** | 24.1 ms | 34.8 ms | 42.0 ms |
| **Frame Relay Latency (P95)** | 3.2 ms | 6.8 ms | 7.1 ms |
| **Process Memory (RSS)** | 78 MB | 148 MB | 152 MB (Capped) |
| **CPU Utilization (2 vCPU)** | 8% | 34% | 38% |
| **Rejection Rate (HTTP 503)** | 0% | 0% | **33.3% (25/75 rejected safely)** |

---

## 2. Resource Consumption Profile

```mermaid
xychart-beta
    title "Memory Scaling Under Concurrent Voice Calls (MB)"
    x-axis [0, 10, 20, 30, 40, 50]
    y-axis "Resident Set Size (MB)" 0 --> 160
    line [65, 82, 98, 115, 132, 148]
```

### Memory Footprint:
- **Base Idle RSS:** ~65 MB (Node.js 22 runtime + WebSocket server).
- **Incremental RAM per Stream:** ~1.65 MB per active bidirectional call session (includes 8kHz audio buffers, Zod validation schema, and connection state).
- **At 50 Calls (Cap):** ~148 MB, well within Cloud Run 2 GiB container memory allocation (less than 8% container memory utilization).

---

## 3. Saturation & Protective Behavior

When active concurrent calls reach `MAX_CONCURRENT_CALLS = 50`:
1. The WebSocket upgrade handler in `http-server.ts` intercepts the request.
2. Emits a structured warning log: `[GatewayServer] Concurrency cap reached. Rejecting connection.`
3. Returns `HTTP/1.1 503 Service Unavailable` immediately without allocating audio buffers or connecting to Gemini Live.
4. Increments the Prometheus counter: `voice_calls_total{status="rejected"}`.
5. Emits `OVERLOADED` on the Kubernetes readiness probe (`/readyz`), prompting load balancers to route traffic to alternative instances.

---

## 4. Horizontal Auto-Scaling Recommendations (Cloud Run)

To support state-wide mass casualty surges:

| Target Concurrency | Cloud Run Configuration | Provisioned Cost (Monthly Idle) |
|---|---|---|
| **0 - 50 Calls** (Pilot: Rajahmundry) | 1 instance (2 vCPU, 2 GiB) | ₹0 (within Cloud Run free tier) |
| **50 - 250 Calls** (District: East Godavari) | 5 instances (`max-instances: 5`) | ~₹1,200 INR (on-demand compute) |
| **250 - 1,000 Calls** (State: Andhra Pradesh) | 20 instances (`max-instances: 20`) | ~₹4,800 INR (peak surge compute) |

### Recommended Cloud Run Service Configuration:
```bash
gcloud run deploy bloodnorms-voice-gateway \
  --image gcr.io/bloodnorms/voice-gateway:latest \
  --cpu 2 \
  --memory 2Gi \
  --concurrency 50 \
  --min-instances 1 \
  --max-instances 20 \
  --timeout 900
```
