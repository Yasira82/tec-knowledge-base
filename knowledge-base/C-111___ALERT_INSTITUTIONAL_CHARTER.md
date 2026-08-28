# C-111 — ALERT INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Assumed]
**Authority Scope:** [Domain]
**Decision Status:** [Exploratory]

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**Alert is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `alert.tecosystem.app` · **Pi App ID:** `alert-3ag1` · **APP_SOURCE:** `alert`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_ALERT` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---

## 1. MISSION

Detect, classify, and escalate economic risks, operational anomalies, and system threats before they cause financial harm or trust erosion in the TEC ecosystem.

---

## 2. INSTITUTIONAL ROLE

```
System of Risk — Economic Risk Infrastructure
```

ALERT is the **early warning system** of the TEC economic runtime. It monitors all 12 services and surfaces threats that require human attention or automated response before damage occurs.

---

## 3. ECONOMIC PURPOSE

تقليل الخسائر والانحرافات في وقتها.

- بدون ALERT: مشاكل تظهر بعد فوات الأوان → user trust erosion
- بوجود ALERT: مشاكل تُكتشف وتُحل قبل تأثير المستخدم
- اقتصادياً: loss prevention value > cost of building ALERT

---

## 4. AUTHORITY BOUNDARY

### Owns
- Risk signal collection and aggregation
- Anomaly detection algorithms
- Alert classification (P0/P1/P2 severity)
- Escalation routing (to admin, to NX, to SYSTEM)
- Incident timeline and context assembly

### Does NOT Own
- Incident resolution (owned by the affected service)
- Governance response (owned by SYSTEM — C-110)
- Security enforcement (owned by NX — C-112)
- Payment reversal authority (owned by tec-payment-service)

### Interface Points
```
OUTBOUND:
  Alert notifications  → Admin (Yasser) via tec-notification-service
  P0 escalation        → NX (C-112) for security response
  Governance signals   → SYSTEM (C-110) for policy review
  Analytics correlation → C-105 for trend context

INBOUND:
  All 12 services      → operational metrics + error rates
  payment.failed.v1    → payment failure spikes
  auth.login.failed.v1 → brute force detection
  analytics anomalies  → C-105 — statistical deviation signals
  NX threat signals    → C-112 — security threat context
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Alert Engine: NestJS (part of tec-core-backend or standalone)
  Signal Collection: Redis Streams consumer (all service events)
  Anomaly Detection: Statistical models on rolling time windows
  Alert Storage: PostgreSQL (alert history + resolution log)
  Notification Delivery: tec-notification-service (4008)
  Dashboard: Hub admin panel (/admin/alerts)

Anomaly Detection Patterns:
  Payment failure spike: > 5% failure rate in 5min window
  Auth failure spike:    > 20 failed logins per user per hour
  Balance anomaly:       wallet balance drop > 50% in 1 transaction
  Service latency:       P95 > 5s for any critical service
  Error rate:            > 1% 5xx on any BFF route

Alert Severity Classification:
  P0: Payment system down, auth service failure, data breach
  P1: Elevated failure rate, suspicious activity, service degradation
  P2: Performance regression, unusual patterns, threshold warnings

Alert Lifecycle:
  Signal detected → classified → notification sent → acknowledged
  → in resolution → resolved → postmortem created
```

---

## 6. SECURITY MODEL

```
Alert Data Sensitivity:
  Alerts contain system state — HIGH sensitivity
  Admin-only access to alert dashboard
  Alert notifications: secure channel only (not public webhook)

False Positive Management:
  Every alert suppression requires manual acknowledgment + reason
  Suppression audit: log who suppressed what and why
  Suppression TTL: max 24h (re-evaluates daily)

Anti-Tampering:
  Alert history is append-only (immutable)
  Alert resolution requires admin actor + justification
  Cannot delete alerts (only mark as resolved)
```

---

## 7. REVENUE MODEL

**Indirect (Loss Prevention)**

ALERT's economic value is measured in prevented losses and uptime protection. Its cost must be justified against the cost of incidents it prevents.

---

## 8. KEY METRICS

```
Mean Time to Alert (MTTA):  < 2min for P0, < 10min for P1
Mean Time to Resolve (MTTR): < 30min for P0 (target)
False Positive Rate:         < 10% of alerts
Alert Coverage:              100% of C-47 invariants monitored
P0 Miss Rate:                0 (no P0 incident goes unalerted)
Incident Postmortem Rate:    100% for P0, ≥ 80% for P1
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Uptime Insurance** — ALERT catches issues before users notice
- **Trust Preservation** — users never see prolonged outages
- **C-47 Runtime Enforcement** — monitors invariant violations in real-time
- **Postmortem Culture** — every P0 becomes a learning that improves the platform

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Payment failure spike detection
  → Service availability monitoring (12 Railway services)
  → Admin notification (email/push)

Phase 2:
  → ML-based anomaly detection (beyond threshold rules)
  → Automated P1 response (circuit breaker activation)
  → Alert correlation (multiple signals = single incident)

Phase 3:
  → Economic Risk Intelligence Network
  → Predictive alerting (pattern recognition before incident)
  → External risk signals (Pi Network health monitoring)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P1:**
```
[P1-1] P0 Alert Protocol (Immediate)
  Define escalation path for P0 right now:
  payment-service down → who gets notified → in what order → how fast?
  This exists in C-78 (Incident Response) but not as running code.
  Must be automated before Mainnet.

[P1-2] SLO Monitoring
  Implement monitoring for the SLOs defined in C-62 and C-78.
  Payment success rate ≥ 95%, auth availability ≥ 99.9%.
  If SLO breached → automatic P1 alert.
```

**P2:**
```
[P2-1] Payment Orphan Detection
  Cron: every 60min, detect payments in 'approved' state for > 30min.
  Alert P1, trigger /api/bff/payment/resolve.
```

---

## 12. INTEGRATION MAP

```
This charter (C-111) depends on:
  All 12 tec-core-backend services → signal sources
  C-105 ANALYTICS → anomaly context from analytics
  C-112 NX       → security threat signals
  C-110 SYSTEM   → governance escalation path

Other charters depend on this one for:
  C-110 SYSTEM   → policy violation signals for governance review
  C-112 NX       → security risk context
  C-100 HUB      → admin sees platform health via Hub admin panel
```
