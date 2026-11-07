# BloodNorms — Alerts as Code Specification (ALERTS.md)

**Role:** Staff Site Reliability Engineer  
**Scope:** Voice Gateway, Edge Functions, PostgreSQL Core, Telephony Pipeline  
**Version:** 1.0.0

---

## 1. Alerting Philosophy & Severity Tiers

Alerts in BloodNorms are actionable, deduplicated, and mapped to specific runbooks.

| Tier | Name | Target SLA | Notification Channel | Behavior |
|---|---|---|---|---|
| **P1** | **CRITICAL** | < 5 mins | PagerDuty (Phone Call + Push) | Emergency matching or telephony pipeline halted; data loss risk |
| **P2** | **MAJOR** | < 15 mins | PagerDuty + Slack `#ops-incidents` | Degraded matching speed, high failure rate, cost anomalies |
| **P3** | **WARNING** | < 2 hours | Slack `#ops-alerts` | Capacity near threshold, non-blocking service warning |

---

## 2. Prometheus Alert Rules as Code

```yaml
groups:
  - name: bloodnorms_voice_gateway_alerts
    rules:
      - alert: VoiceGatewayNearCapacity
        expr: voice_calls_active >= 40
        for: 1m
        labels:
          severity: P2
          service: voice-gateway
        annotations:
          summary: "Voice Gateway approaching concurrency cap ({{ $value }}/50 calls)"
          description: "Active voice calls have exceeded 80% capacity for > 1 minute. Scale Cloud Run instances."
          runbook_url: "docs/operations/runbooks/high_latency_gemini.md"

      - alert: VoiceGatewayCallsSaturated
        expr: voice_calls_active >= 50
        for: 30s
        labels:
          severity: P1
          service: voice-gateway
        annotations:
          summary: "Voice Gateway saturated; new inbound calls getting rejected"
          description: "Active calls reached 50 cap. Inbound callers are receiving 503 Service Unavailable."
          runbook_url: "docs/operations/runbooks/voice_gateway_outage.md"

      - alert: HighVoiceCallFailureRate
        expr: rate(voice_calls_total{status="failed"}[5m]) / rate(voice_calls_total[5m]) > 0.05
        for: 2m
        labels:
          severity: P1
          service: voice-gateway
        annotations:
          summary: "Voice call failure rate exceeds 5%"
          description: "Over 5% of emergency calls failed in the last 5 minutes. Check Gemini API quotas."
          runbook_url: "docs/operations/runbooks/high_latency_gemini.md"

      - alert: VoiceGatewayHighMemory
        expr: voice_gateway_memory_bytes{type="heap_used"} / voice_gateway_memory_bytes{type="heap_total"} > 0.85
        for: 2m
        labels:
          severity: P2
          service: voice-gateway
        annotations:
          summary: "Voice Gateway heap usage above 85%"
          description: "Potential memory leak in WebSocket audio buffers."
          runbook_url: "docs/operations/runbooks/voice_gateway_outage.md"

  - name: bloodnorms_database_alerts
    rules:
      - alert: DatabaseSlowQueries
        expr: pg_stat_activity_max_tx_duration_seconds > 10
        for: 1m
        labels:
          severity: P2
          service: postgresql
        annotations:
          summary: "PostgreSQL transaction executing longer than 10s"
          description: "Possible table lock or unindexed spatial query during active surge."
          runbook_url: "docs/operations/runbooks/database_failover.md"

      - alert: TelephonyBudgetSurge
        expr: increase(bloodnorms_spend_inr_total[1h]) > 10000
        for: 5m
        labels:
          severity: P2
          service: billing
        annotations:
          summary: "Abnormal INR spend acceleration detected"
          description: "Spend rate exceeded ₹10,000 in one hour. Check for automated spam or loop."
          runbook_url: "docs/operations/runbooks/fraud_alert_burst.md"
```
