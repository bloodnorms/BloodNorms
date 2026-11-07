# BloodNorms — Cost & Usage Control Architecture (COST_CONTROL.md)

**Role:** Staff Operations & Financial Systems Architect  
**Scope:** Telephony, AI Speech Engine, Messaging APIs, Infrastructure  
**Version:** 1.0.0

---

## 1. Unit Economics of an Emergency Match

BloodNorms operates on an honest, non-commercial emergency response model. Every rupee spent on third-party APIs directly powers an urgent blood rescue.

| Service Component | Provider | Unit Rate (INR) | Typical Emergency Cycle Usage | Estimated Cost |
|---|---|---|---|---|
| **Inbound Family Helpline** | Twilio Programmable Voice | ₹1.80 / min | 1.5 minutes triage | ₹2.70 |
| **Bilingual AI Voice Agent** | Google Gemini Live API | ₹3.20 / min | 1.5 minutes streaming | ₹4.80 |
| **WhatsApp Donor Alerts** | Meta Cloud API | ₹0.85 / template | 5 matching donors | ₹4.25 |
| **Geocoding & Map Tiles** | OpenStreetMap / Nominatim | ₹0.00 (Self-hosted/OSM) | 1 search + 1 tile view | ₹0.00 |
| **Total Typical Response Cost** | | | | **₹11.75 INR** |

---

## 2. Progressive Safety Guardrails (Flags Default to OFF)

To ensure life-saving calls are never interrupted during genuine crises, all spending caps and automatic cutoffs sit behind **progressive feature flags that default strictly to false / OFF**:

```json
{
  "guardrails_enabled": false,
  "spending_cap_enforced": false,
  "max_duration_enforced": false
}
```

### Safety Guardrail Thresholds (When Activated by Human Executive):
1. **Max Call Duration:** 10 minutes (600 seconds). Prevents hung lines or orphaned WebSockets.
2. **Daily Spend Soft Cap:** ₹50,000 INR. Triggers P2 alert to operations team without dropping live calls.
3. **Hard Emergency Killswitch:** Accessible via executive four-eyes approval matrix. Immediately halts AI voice streaming and redirects calls to nearest district blood bank numbers.

---

## 3. Financial Telemetry & Ledger Immutability

1. **`usage_events` Table:** Every billable transaction (voice call completion, WhatsApp template dispatch) records an immutable ledger entry.
2. **Database Trigger:** `trg_usage_events_immutable` rejects any `UPDATE` or `DELETE`, ensuring full financial auditability for philanthropic donors and hospital partners.
3. **Daily Spend Reconciliation:** Automated query computes daily burn rate by service for executive dashboards.
