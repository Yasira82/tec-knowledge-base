# C-105 — ANALYTICS INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Planned State]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Domain]
**Decision Status:** [Recommended]

> ⚠️ **SCOPE — read with C-122.** This charter is the **product / BI-surface**
> view of Analytics (mission, revenue tiers, dashboards). The **constitutional
> runtime** definition — Analytics as the Tier-1 **Intelligence Runtime** /
> *Reality Infrastructure* ("what is happening?"), the Reality↔Trust duality with
> Zone, the §5 disclosure boundary, and engine-vs-surface ownership — lives in
> **C-122 (Analytics Constitutional Runtime Charter)**, the higher-authority doc.
> Where the two differ, **C-122 governs the runtime; C-105 governs the product surface.**

---

## 1. MISSION

Transform raw economic activity across the TEC platform into structured intelligence — metrics, trends, and signals — that power merchant decisions, platform governance, and TEC AI reasoning.

---

## 2. INSTITUTIONAL ROLE

```
System of Intelligence — Economic Intelligence Infrastructure
```

---

## 3. ECONOMIC PURPOSE

تحويل البيانات إلى معرفة قابلة للتنفيذ.

- بدون Analytics: platform تعمل عمياء
- بوجود Analytics: merchants يحسّنوا، platform تحكم أفضل، AI يستدل بدقة
- اقتصادياً: intelligence = competitive advantage → retention → growth

---

## 4. AUTHORITY BOUNDARY

### Owns
- Metric aggregation and storage
- Trend computation and signal generation
- Dashboard data delivery (merchants, platform admins)
- Event stream processing (from all 12 services)

### Does NOT Own
- Raw transaction truth (owned by tec-payment-service)
- Order truth (owned by tec-commerce-service)
- Identity truth (owned by tec-auth-service)
- Governance decisions based on analytics (owned by SYSTEM)

### Interface Points
```
OUTBOUND:
  /api/analytics/merchant    → merchant dashboard metrics
  /api/analytics/platform    → platform health metrics
  TEC AI signals             → intelligence for reasoning (C-104)
  SYSTEM risk signals        → anomaly detection for governance (C-110)

INBOUND:
  Redis Streams (XREADGROUP) → events from all 12 services
  payment.completed.v1       → transaction signals
  order.created.v1           → commerce signals
  auth.login.success.v1      → engagement signals
  tec-analytics-service:4007 → backend service
```

---

## 5. TECHNICAL ARCHITECTURE

```
Backend: tec-analytics-service (Port 4007)
  NestJS + Prisma + PostgreSQL (Supabase for analytics DB)
  Redis Streams consumer: XREADGROUP for event ingestion
  Event processing: at-least-once, consumers are idempotent
  Aggregation: time-window rollups (1h, 24h, 7d, 30d)

Frontend (planned):
  Hub Analytics Dashboard (/hub/analytics)
  Merchant Dashboard in Commerce (/dashboard/analytics)
  Next.js 15, @yasser172/tec-ui charts (to be built)

Data Flow:
  All 12 services → Redis Streams → tec-analytics-service
  → PostgreSQL/Supabase → BFF routes → Dashboards + TEC AI

Consistency Model:
  Eventual consistency (analytics tolerates lag — C-47 §6)
  No strong consistency requirement for aggregations
  Event delivery: at-least-once (consumer idempotency required)

Existing:
  /api/bff/metrics in Hub → 24h payment observability ✅
  tec-analytics-service deployed on Railway (Port 4007) ✅
```

---

## 6. SECURITY MODEL

```
Data Access:
  Merchant sees ONLY their own metrics (merchantId from session)
  Platform admin sees aggregate metrics (AdminActor + audit trail)
  No cross-merchant data leakage (enforced at BFF layer)

Data Governance:
  Analytics data classified as non-sensitive BUT logged (Invariant #9)
  Aggregated data anonymization for external reports
  Retention policy: raw events 90 days, aggregates 2 years

Auditability:
  All analytics queries logged with actor context
  Admin access to raw events requires justification
```

---

## 7. REVENUE MODEL

**Business Intelligence (B2B)**

| Tier | Features | Price |
|------|----------|-------|
| Merchant Basic | 24h + 7d metrics (included in Commerce) | FREE |
| Merchant Pro | 30d trends + cohort analysis | PRO tier |
| Enterprise | Custom reports + API access | Enterprise |
| Platform Intelligence | Market intelligence reports | External |

---

## 8. KEY METRICS (of the Analytics service itself)

```
Event Ingestion Lag:    < 5min (Redis Stream processing delay)
Aggregation Freshness:  24h window updated every 15 min
Dashboard Load Time:    < 2s (cached aggregates)
Data Accuracy:          100% (verified against payment-service truth)
Service Availability:   ≥ 99% (eventual — not identity-critical)
Merchant Query Isolation: 100% (no cross-merchant data)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Platform Intelligence** — enables data-driven governance
- **Merchant Empowerment** — merchants make better pricing/inventory decisions
- **TEC AI Fuel** — primary signal source for AI reasoning
- **ALERT Integration** — anomaly detection feeds risk infrastructure (C-111)

---

## 10. FUTURE EVOLUTION

```
Phase 1 (Post-Mainnet):
  → Hub analytics dashboard (/hub/analytics)
  → Merchant revenue analytics in Commerce
  → 7d + 30d time windows

Phase 2:
  → Real-time analytics (WebSocket via tec-realtime-service)
  → Cohort analysis (user segments)
  → Market intelligence reports (Pi ecosystem trends)

Phase 3:
  → External API (developers query TEC analytics)
  → AI-powered insights (TEC AI integration)
  → Predictive analytics (forecasting Pi transaction volume)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P1:**
```
[P1-1] Hub Analytics Dashboard
  /hub/analytics page needs to be built (Phase 1 roadmap item).
  Design: payment volume, active users, top apps, error rates.

[P1-2] Merchant Analytics in Commerce
  Commerce dashboard needs analytics section.
  Connect to tec-analytics-service (4007) via /api/bff/analytics.

[P1-3] Event Schema Standardization
  All 12 services must emit events with consistent schema:
  { eventId, timestamp, actorId, correlationId, domain, action, version, payload }
  Audit: verify all services follow C-70 Event Governance Spec.
```

**P2:**
```
[P2-1] Supabase Analytics Integration
  tec-analytics-service uses Supabase for analytics DB.
  Implement Row Level Security for merchant data isolation.

[P2-2] ALERT Integration
  Anomaly detection: analytics service emits risk signals
  to tec-notification-service when thresholds breached.
```

---

## 11a. IMPLEMENTATION STATUS (Session — June 2026)

**Truth State:** [Code Verified] for the items below · charter overall stays [Planned State] (not yet deployed / no Pi App ID).

A **standalone Analytics frontend** (`tec-analytics` repo → `analytics.tecosystem.app`,
from the 24-app rollout registry) now exists. This is a **third analytics surface**,
distinct from §11 P1-1 (Hub embed `/hub/analytics`) and P1-2 (Commerce embed) — both
of which remain to-build.

```
Built (code-verified, branch claude/tec-repos-review-ht2n8s — pre-deploy):
  ✅ App customized from tec-template-base v2 (identity, domain, slug, legal pages)
  ✅ BFF /api/bff/analytics/{overview,payments,users,events}
       → tec-analytics-service via gateway (^/api/analytics → /analytics)
       → auth: Bearer token + x-internal-key · fail-closed (401 w/o session)
  ✅ /app platform dashboard: overview cards + 30d payment volume + recent events
       (inline bar chart — tec-ui charts still pending, §5)
  ✅ Drift Detection CI gate (ADR-009 · C-12 §11 · ADR-007) — parity with the 4 live apps

Consumed contract (tec-analytics-service, code-verified):
  GET /analytics/overview · /payments · /users · /events?limit=N  →  { success, data }

Gap (blocks §6 merchant isolation):
  ⚠️ tec-analytics-service aggregates are PLATFORM-level — DailyMetric is keyed by date
     only, AnalyticsEvent carries user_id but no merchantId. Merchant-scoped metrics
     (§6 "merchant sees ONLY their own") require a SERVICE-side schema + aggregation
     change BEFORE the BFF can isolate. Until then the dashboard is platform/admin only.
```

---

## 12. INTEGRATION MAP

```
This charter (C-105) depends on:
  All 12 backend services → event sources via Redis Streams
  C-104 TEC AI  → analytics feeds AI reasoning
  C-111 ALERT   → anomaly signals feed risk detection

Other charters depend on this one for:
  C-100 HUB       → /api/bff/metrics (24h payment observability)
  C-101 COMMERCE  → merchant revenue analytics
  C-104 TEC AI    → signal input for recommendations
  C-111 ALERT     → risk thresholds + anomaly patterns
  C-110 SYSTEM    → platform health for governance decisions
```
