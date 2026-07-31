# C-105 — ANALYTICS INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification State:** [Runtime Verified]
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

## 11a. IMPLEMENTATION STATUS (updated Session 17 — July 2026: DEPLOYED + Runtime Verified)

**Truth State:** [Current State] · **Verification:** [Runtime Verified] — the app is
**live at `analytics.tecosystem.app`**; login (C-123 SSO) and the events dashboard were
verified against production Vercel logs on 2026-07-03. Revenue tiers (§7) and merchant
isolation (§6) remain [Planned State] — see the Gap note.

A **standalone Analytics frontend** (`tec-analytics` repo → `analytics.tecosystem.app`,
from the 24-app rollout registry) is now **deployed and live**. This is a **third
analytics surface**, distinct from §11 P1-1 (Hub embed `/hub/analytics`) and P1-2
(Commerce embed) — both of which remain to-build.

```
Live (runtime-verified in production, 2026-07-03):
  ✅ App customized from tec-template-base v2 (identity, domain, slug, legal pages)
  ✅ Hub SSO login — C-123 compliant (200 landing + verified entry + none/secure/Partitioned)
  ✅ BFF /api/bff/analytics/{overview,payments,users,events}
       → tec-analytics-service via gateway (^/api/analytics → /analytics)
       → auth: Bearer token + x-internal-key · fail-closed (401 w/o session)
       → server-only API_GATEWAY_URL (NEW-A: no gateway URL in the client bundle)
  ✅ /app platform dashboard: overview cards + 30d payment volume + recent events
       (inline bar chart — tec-ui charts still pending, §5)
  ✅ Drift Detection CI gate — parity with the 4 live apps (ADR-009 · C-12 §11 · ADR-007)
       + Analytics-specific checks: NEW-A (no NEXT_PUBLIC gateway var / Railway host in
       src) and §6 merchant isolation (identity from session cookie, never query/body)

Consumed contract (tec-analytics-service, runtime-verified):
  GET /analytics/overview · /payments · /users · /events?limit=N  →  { success, data }

Ops precondition (was the launch blocker, now resolved):
  ✅ Vercel needs server-only API_GATEWAY_URL (not NEXT_PUBLIC_*). Missing it returned
     503 on every /api/bff/analytics/* call while login still worked — added 2026-07-03.

Shipped Session 18 (2026-07-03, runtime-verified):
  ✅ Pi App ID REGISTERED in the Pi Developer Portal (prefix `analytics-822d98…`;
     full value = Vercel `NEXT_PUBLIC_PI_APP_ID`). The Portal "Process a Transaction"
     step is complete — a real Merchant Pro payment succeeded in both modes.
  ✅ §7 monetization LIVE — Merchant Pro subscription (10π/month, item `merchant_pro_monthly`)
     via the standalone app. Mode 1 (Hub modal) AND Mode 2 (in-app Pi) both verified.
     Required a payment-service fix: per-app Pi API key `PI_API_KEY_ANALYTICS` (see C-12 §11 —
     approving under the default Hub key returned 502).
  ✅ §6 merchant isolation — SLICE 1 (own-scope): GET /analytics/me/overview + the
     frontend "Your activity" panel. Any non-admin now sees ONLY their own aggregates
     (groupBy analytics_events WHERE user_id = session identity; identity from the verified
     token, never a param; 401 w/o user scope). Platform aggregates stay admin/internal
     (C-122 §5 disclosure boundary).
  ✅ §6 merchant isolation — SLICE 2 (seller-scoped "my sales"): the frontend
     "Your sales" panel (revenue / items sold / orders / top products / recent sales).
     ARCHITECTURE NOTE — the earlier plan ("push merchantId through payment.*/order.*
     events into analytics, then aggregate in analytics-service") was REJECTED: it would
     make Analytics re-derive transaction truth, violating this charter's data-ownership
     boundary. Instead the sales are aggregated by the OWNER, tec-commerce-service —
     `GET /commerce/orders/seller/sales-summary` (order_items WHERE product.seller_id =
     session identity AND order.status ∈ {PAID,PROCESSING,SHIPPED,DELIVERED}; money as
     strings, DECIMAL(20,8)). Analytics only PRESENTS it via BFF `/api/bff/analytics/me/sales`.
     Seller id is the verified session identity server-side, never a param (P6). Strong
     consistency (commerce truth) — not eventual.

  ✅ Legend Scoring (ADR-013) — Analytics now COMPUTES the six Legend dimension scores
     (merchant/creator/investor/collaborator/builder/overall) from its OWN AnalyticsEvent
     log (no cross-service read): a daily batch over recently-active users emits
     `legend.scores.updated.v1`; Legend writes its own profile (Invariant #8) + re-evaluates
     Elite. Absolute published curve (earned bar, not percentile); investor=0 until FundX.
     This is the intelligence half of the reputation chain (Legend → Elite unblocked).
     `[Code Verified]` — tec-core-backend #160.

Shipped Session 22 (2026-07-31, code-verified — tec-core-backend #161):
  ✅ Analytics is now the PRODUCER of `analytics.business.popularity.v1` (Explorer
     discovery-ranking signal, C-108). The daily Legend-scoring batch
     (`scoring.service.ts::runScoringBatch`, ADR-013) emits it per active owner
     alongside `legend.scores.updated.v1` — popularity = the owner's merchant-activity
     count, computed from Analytics' OWN AnalyticsEvent log (no cross-service read, §4
     boundary held). Explorer degrades gracefully when the signal is absent. This closed
     the events-catalog `planned → live` gap for that event (no consumer was left dangling).

Still pending:
  □ §11 P1-1/P1-2 embeds (Hub `/hub/analytics`, Commerce embed) — to-build
  □ Richer multi-signal scoring (weighting/decay) + historical backfill — ADR-013 revision
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
