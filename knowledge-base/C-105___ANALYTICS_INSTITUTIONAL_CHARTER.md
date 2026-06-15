# C-105 — ANALYTICS INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Planned State
**Governance State:** Draft
**Verification State:** Documentation Verified (service exists at Port 4007, frontend connection pending)
**Authority Scope:** Domain
**Decision Status:** Recommended

---

## 1. MISSION

Analytics is the intelligence substrate of the TEC ecosystem — the system that captures, aggregates, and exposes every economic signal from every app, creating the data foundation on which AI reasoning and platform governance operate.

---

## 2. INSTITUTIONAL ROLE

**System of Intelligence** — The platform's nervous system.

```
Settlement → RECORD → REASONING → Access → Construction → Production → Economic Activity → Settlement
                ↑
            ANALYTICS
         (feeds Reasoning)
```

Analytics occupies the Record position but feeds the Reasoning position (TEC AI). Without Analytics, there is no data for AI to reason on, no metrics for operators to govern from, and no SLO evidence for reliability decisions.

---

## 3. ECONOMIC PURPOSE

Analytics exists to make the invisible visible in the Pi economy:

- **Payment Observability**: 24h payment success rates, failure modes, volume trends
- **User Behavior**: Where users spend time, what they buy, what they abandon
- **Merchant Performance**: Product views → conversion funnel per merchant
- **Ecosystem Health**: Pi circulation velocity, active user trends, retention cohorts
- **Anomaly Detection**: Spike in failures, unusual payment patterns, sudden drops

Without Analytics, platform operators are flying blind. Hub currently exposes a 24h metrics endpoint (`/api/bff/metrics`) — Analytics is the service that powers this and must become the authoritative data layer.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Event ingestion pipeline (all platform events flow through here)
- Aggregation and time-series storage
- Metrics API exposed to other services
- Dashboard data for Hub admin panel
- Retention cohort analysis
- Real-time event stream (WebSocket via tec-realtime-service relay)

### Does NOT Own
- Raw transaction records (tec-payment-service owns the source of truth)
- User identity (tec-auth-service)
- Event definitions (each service defines its own events — Analytics ingests them)
- AI inference (TEC AI owns — Analytics provides the data)

### Interface Points
```
Exposes to ecosystem:
  - GET /api/metrics/24h     : 24h payment observability (currently powers Hub /api/bff/metrics)
  - GET /api/metrics/user    : per-user analytics (PRO feature)
  - GET /api/metrics/merchant: per-merchant funnel (Commerce)
  - GET /api/metrics/platform: ecosystem health (admin only)
  - POST /api/events/ingest  : event ingestion endpoint (internal only)
  - WebSocket: real-time metric streams

Consumed from (event sources):
  - tec-payment-service (4002): payment.created, payment.completed, payment.failed
  - tec-commerce-service (4003): order.created, order.fulfilled, product.viewed
  - tec-auth-service (4001): auth.login, auth.logout, auth.refresh
  - tec-asset-service (4006): asset.minted, asset.transferred
  - All frontend apps: page views, button clicks (client-side events via BFF)
```

---

## 5. TECHNICAL ARCHITECTURE

### Current State
- tec-analytics-service exists at Port 4007 on Railway
- Hub `/api/bff/metrics` currently calls tec-analytics-service for 24h payment data
- Frontend analytics dashboard: NOT YET CONNECTED (Phase 0 gap)

### Planned Stack
- NestJS (consistent with other tec-core-backend services)
- PostgreSQL: time-series event storage with DECIMAL(20,8) for Pi amounts
- Redis: real-time aggregation cache (TTL: 60s for live metrics)
- tec-realtime-service (4009): relay for WebSocket event streams
- TimescaleDB extension (Phase 2): for efficient time-series queries at scale

### Event Ingestion Pattern
```typescript
// Events follow platform naming convention (C-47 §Event Model)
interface PlatformEvent {
  eventId:       string  // UUID v4
  eventType:     string  // e.g. 'payment.completed.v1'
  timestamp:     string  // ISO 8601
  actorId:       string  // who triggered
  actorType:     'user' | 'service' | 'admin'
  correlationId: string  // trace ID
  causationId?:  string
  payload:       Record<string, unknown>
}
// Events are IMMUTABLE once ingested — Invariant 5
```

### Aggregation Architecture
```
Raw events → Redis buffer (60s window)
           → PostgreSQL time-series (permanent)
           → Pre-computed aggregates (hourly cron)
             → Metrics API responses (< 100ms)

Real-time:
Raw events → Redis pub/sub → tec-realtime-service (4009) → WebSocket clients
```

### 24h Metrics Endpoint (currently in production)
```typescript
// GET /api/bff/metrics (Hub)
// Powers Hub dashboard payment observability
interface Metrics24h {
  totalPayments: number
  successRate: number      // percentage
  failureRate: number      // percentage
  volume: string           // Pi amount (DECIMAL string)
  avgLatency: number       // milliseconds
  hourlyBreakdown: HourlyBucket[]
}
```

### Data Retention Policy
```
Raw events:          90 days (then aggregated + deleted)
Hourly aggregates:   2 years
Daily aggregates:    Forever (platform economic history)
User-level data:     Deleted on account closure (GDPR analog)
Payment events:      7 years (financial record requirement)
```

---

## 6. SECURITY MODEL

### Authentication
- Event ingestion: `x-internal-key: ${INTERNAL_SECRET}` required (services only)
- User analytics: tec_user cookie required — only own data
- Merchant analytics: merchant role verified from tec_user cookie
- Admin analytics: AdminActor context + audit trail required

### Authorization
- User A CANNOT access User B's analytics (P6 Fail Closed)
- Merchant A CANNOT see Merchant B's performance data
- Aggregated platform analytics: admin only
- AI service access: ServiceActor context required

### Privacy Model
```
PII in events: NEVER store raw PII in event payload
User identification: actorId (UUID) only — map to identity separately
Aggregated data: anonymized at k>=10 (never expose data about <10 users)
Event deletion: cascading delete on account closure
```

---

## 7. REVENUE MODEL

### Direct
1. **PRO Analytics Dashboard**: Advanced merchant/user analytics (gate behind PRO subscription)
2. **Enterprise Analytics API**: Raw data access for enterprise merchants via API key
3. **Custom Reports**: Platform operator pays for tailored analytics exports

### Indirect
- Analytics data → TEC AI → better recommendations → higher conversion → transaction fees
- Merchant performance insights → merchant retention and PRO upgrade
- Platform health visibility → faster incident response → higher availability → user trust

---

## 8. KEY METRICS

### SLOs (Analytics must measure itself)
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Event ingestion latency | < 500ms P95 | > 2s P95 |
| Analytics service availability | ≥ 99.5% | < 99.0% |
| Metrics API response time | < 100ms P95 | > 500ms P95 |
| Event loss rate | < 0.01% | > 0.1% |
| Data retention compliance | 100% of deleted accounts purged | Any violation |

### Platform KPIs (Analytics reports on these)
| Metric | Target | Frequency |
|--------|--------|----------|
| Payment success rate (platform) | ≥ 95% | Continuous |
| DAU/MAU ratio | ≥ 20% | Weekly |
| Pi circulation velocity | Increasing trend | Monthly |
| Cross-app session rate | ≥ 40% | Weekly |
| Merchant conversion rate | ≥ 3% (view → purchase) | Weekly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Platform Nervous System**: Every service emits events; Analytics aggregates them into ecosystem awareness
2. **AI Data Foundation**: Provides TEC AI (C-104) with the training signal for all recommendations
3. **Operator Visibility**: Hub admin panel would be blind without Analytics — it provides the 24h metrics
4. **SLO Evidence**: Analytics is the data source for all platform SLO verification
5. **Anomaly Surface**: Unusual patterns in Analytics feed ALERT (C-111) for risk management

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2)
- Connect all 4 frontend apps to emit client-side events via BFF
- Hub analytics dashboard: DAU, payment rates, subscription distribution
- Merchant analytics dashboard in Commerce: conversion funnel, revenue trend
- Real-time payment success rate widget (5s refresh via WebSocket)

### Phase 2 (Month 3–4)
- TimescaleDB migration for efficient time-series at scale
- Cohort analysis: retention curves by signup date, acquisition channel
- A/B test result tracking: measure feature impact on conversion
- Connection (C-107) social graph analytics

### Phase 3 (Month 5–8)
- Ecosystem economic dashboard: platform GDP in Pi, velocity, sector breakdown
- Predictive analytics: 30-day payment volume forecast
- Cross-platform identity analytics (with consent): user journey across all apps
- Public Pi economy index: anonymized aggregate export for Pi Network reporting

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Complete before Phase 1)**
1. **Frontend connection**: Connect Hub, Commerce, Assets, Ecommerce to emit events to tec-analytics-service — currently only Hub /api/bff/metrics calls the service
2. **Event schema enforcement**: Define and validate all event types with Zod schemas — currently unvalidated
3. **Event immutability**: Add DB constraint ensuring no UPDATE on event records (Invariant 5)

**P1 — High Priority (Phase 1)**
4. **Admin analytics API**: Authenticated admin endpoint for platform-wide metrics (required for Hub admin panel)
5. **Merchant analytics BFF route**: `/api/bff/metrics/merchant` for Commerce merchant dashboard
6. **Event deletion cascade**: Implement account closure → event deletion pipeline
7. **Privacy k-anonymity**: Enforce k>=10 minimum cohort for any aggregated data

**P2 — Medium Priority (Phase 2)**
8. **TimescaleDB migration**: Scale time-series queries beyond 90-day raw event retention
9. **Real-time WebSocket relay**: tec-realtime-service (4009) integration for live metrics
10. **Cost-per-action attribution**: Track which features drive which revenue events

---

## 12. INTEGRATION MAP

```
C-105 (ANALYTICS) receives events from:
← ALL platform services: payment, auth, commerce, assets (event sources)
← ALL frontend apps: client-side events via BFF

C-105 (ANALYTICS) feeds data to:
→ C-100 (HUB)        : 24h metrics dashboard (/api/bff/metrics) — currently live
→ C-101 (COMMERCE)   : Merchant performance dashboard (Phase 1)
→ C-104 (TEC AI)     : Event streams for recommendation engine
→ C-109 (NEXUS)      : Ecosystem coordination metrics
→ C-110 (SYSTEM)     : Governance participation data
→ C-111 (ALERT)      : Anomaly signals for risk management
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
