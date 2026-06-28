# C-122 — ANALYTICS CONSTITUTIONAL RUNTIME CHARTER

## TEC Ecosystem — Intelligence Runtime

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Platform + Ecosystem]`

---

## PREAMBLE

Analytics is NOT a dashboard.

Analytics is NOT charts, KPIs, or reports.

Analytics is NOT a BI tool.

Analytics is:

```
The Intelligence Runtime
of the Pi Ecosystem.
```

It answers one question:

```
"What is happening?"
```

Its tagline framing:

```
Zone      = Trust Infrastructure   ("what can be trusted?")
Analytics = Reality Infrastructure  ("what is actually true?")
```

Dashboards, charts, and reports are **surfaces** Analytics renders.
They are not what Analytics *is*. Analytics is the runtime that turns
events, activities, transactions, relationships, and verified signals
into **measurable reality**.

---

## 1. THE PROBLEM ANALYTICS SOLVES

Pi Network has 47M+ pioneers and a growing ecosystem of projects,
merchants, and builders. But the Pi ecosystem has NO:

- Market intelligence (what is being adopted, where, how fast)
- Merchant intelligence (who is growing, who is trusted, who retains)
- Builder intelligence (who ships, who has influence)
- Network intelligence (how the ecosystem is actually moving)

Today, when anyone — a Pioneer, a merchant, the Pi Core Team — asks:

```
"Is Pi commerce actually growing?"
"Which merchants are real businesses?"
"Where is capital flowing in the Pi economy?"
```

There is no measured answer. There is only anecdote.

Analytics provides the measured answer.

```
Glassnode    answers "what is happening" for Bitcoin.
Messari/Dune answer  "what is happening" for crypto.
Analytics    answers "what is happening" for Pi.
```

---

## 2. CONSTITUTIONAL CLASSIFICATION

```
Tier:      TIER 1 — Constitutional Runtime
Question:  "What is happening?"
Domain:    analytics.tecosystem.app (TEC surface) + future ecosystem-grade asset
Level:     Same constitutional level as Hub and Zone
```

Analytics is consumed BY other components.
Analytics is NOT primarily consumed BY users directly.

```
Hub       provides identity.
Analytics measures what that identity does.
```
```
Zone      provides verified evidence.
Analytics turns verified evidence into patterns and reality.
```
```
Nexus     coordinates what should happen next.
Analytics tells Nexus what is happening now.
```
```
TEC AI    reasons about what to do.
Analytics gives TEC AI the measured reality to reason over.
```

### The Reality ↔ Trust duality (constitutional)

```
Zone      = Trust Infrastructure   — records and serves verified evidence.
Analytics = Reality Infrastructure — measures what is actually happening.

Together with Hub (Identity), these are the three pillars of the Kernel.
Trust without Reality is blind. Reality without Trust is noise.
```

---

## 3. WHAT ANALYTICS OWNS

Analytics owns the **intelligence engine** — computation, aggregation,
pattern and signal generation. It does NOT own the data's truth (the
producing services do) and it does NOT own each app's screen.

```
The Engine (sovereign to Analytics):
  Metric aggregation        → time-window rollups (1h / 24h / 7d / 30d)
  Trend + signal computation → growth, retention, distribution, anomalies
  Pattern detection          → cross-domain correlations
  Forecast inputs            → series prepared for TEC AI reasoning

Per-app intelligence (engine-powered, surface owned by the app):
  Personal Analytics   → inside Life       (Life Score, goals, capital growth)
  Commerce Analytics   → inside Commerce    (sales, conversion, merchant perf)
  Assets Analytics     → inside Assets      (portfolio value, returns, liquidity)
  Connection Analytics → inside Connection  (relationship density, influence)
  FundX Analytics      → inside FundX        (capital flow, investor activity)
  Estate Analytics     → inside Estate       (price/rental trends, demand/supply)
  Zone Analytics       → inside Zone         (verification activity, reputation)

The Ecosystem Layer (sovereign to Analytics — the real power):
  Ecosystem Metrics    → active projects, merchants, verified builders, volume
  Adoption Reports     → Pi commerce adoption, regional trends, penetration
  Merchant Intelligence→ top / fastest-growing / highest-trust / retention
  Builder Intelligence → top developers, projects created, influence
  Capital Intelligence → investment trends, sector analysis, funding activity
```

> **Engine vs Surface rule:** "Commerce Analytics" is a surface **owned by
> Commerce**, **powered by** the Analytics engine. It is not a second analytics
> domain. This preserves C-119 Rule 1 (one question per component) and C-68
> domain ownership: Analytics owns the *measurement*, each app owns its *view*.

---

## 4. WHAT ANALYTICS DOES NOT OWN

```
❌ Transaction truth    → tec-payment-service (Analytics reads ID-only refs)
❌ Order truth          → tec-commerce-service
❌ Identity truth       → tec-auth-service / Hub
❌ Verified evidence    → Zone (Analytics consumes it; never re-issues it)
❌ Recommendations      → TEC AI (Analytics describes; it does not advise)
❌ Coordination/workflow→ Nexus (Analytics describes; it does not act)
❌ Governance decisions → System
❌ Each app's UI surface → the owning app (Analytics powers it)
```

**Constitutional boundary (the neighbours):**

| Component | Question | Function |
|-----------|----------|----------|
| **Zone** | what can be **trusted**? | issues verified facts |
| **Analytics** | what **is happening**? | turns facts into measured reality |
| **Nexus** | what should happen **next**? | turns reality into workflows |
| **TEC AI** | what should **I do**? | turns reality into recommendations |

```
Analytics DESCRIBES reality.
It does NOT recommend (TEC AI) and does NOT coordinate (Nexus).
Any recommendation or action logic inside Analytics is a boundary violation.
```

---

## 5. THE DISCLOSURE BOUNDARY (the most important rule)

Analytics aggregates across **every** domain. An engine that *sees*
everything is safe ONLY if what it *exposes* is strictly bounded.

```
Analytics may AGGREGATE across all domains.
Analytics may DISCLOSE exactly one of three forms:

  1. OWN-SCOPE   → your data, to you
       (scope derived from the session actorId — never a query/body param)

  2. AGGREGATE   → de-identified, internal or external
       (k-anonymity threshold; re-identification is forbidden)

  3. SOVEREIGN   → AdminActor + full audit trail (C-47)
```

```
Disclosing one individual's data to another party
= constitutional violation (P6 Fail Closed).

"Sees everything" is permitted.
"Exposes everything" is forbidden.
This is the line between Reality Infrastructure and surveillance.
```

This binds: C-105 §6 (merchant isolation), C-17 (Data Privacy & Retention),
C-19 (Fraud/Abuse/AML), Kernel Invariant #9 (non-sensitive still logged).

---

## 6. INPUT MODEL — OPERATIONAL vs INSTITUTIONAL

Analytics ingests in two layers with different integrity guarantees:

```
(a) Operational Analytics  — consumes RAW events (Redis Streams from services)
      Purpose: speed, ops metrics, internal dashboards, live health
      Integrity: best-effort, eventual (C-47 §6)

(b) Institutional / Ecosystem Analytics — builds on Zone-VERIFIED facts
      Purpose: any intelligence PUBLISHED (merchant/builder/ecosystem reports)
      Integrity: must trace to verified evidence (C-120 / C-121 pipeline)
```

```
Rule: any insight DISCLOSED externally must be built on verified facts,
      not raw events. Raw-event speed is for internal/operational use only.
```

This reconciles the pipeline (C-119 §5 / C-121: Zone precedes Analytics)
with the deployed service (which ingests raw events from all services).

---

## 7. BUILD SEQUENCE — VERSIONS

### Analytics V1 — Platform Dashboard (NOW — code-verified)

**Gate:** none (backend `tec-analytics-service` already deployed)
**Status:** built — `analytics.tecosystem.app` (see C-105 §11a)

```
□✅ /api/bff/analytics/{overview,payments,users,events} → service via gateway
□✅ /app platform dashboard: overview + 30d payment volume + recent events
□  Operational only — platform/admin scope (no per-merchant isolation yet)
```

### Analytics V2 — Per-App Intelligence (Life + Commerce ready)

**Gate:** Life operational + merchant scoping in the service
**Data source:** per-domain events + own-scope disclosure (§5.1)

```
□ Service-side merchantId / actorId scoping (unblocks C-105 §6 isolation)
□ Personal Analytics surface in Life · Commerce Analytics surface in Commerce
□ tec-ui chart primitives (C-105 §5)
```

### Analytics V3 — Ecosystem Intelligence (Zone V2+ ready)

**Gate:** Zone evidence registry live (C-120 V2) + 5k+ users
**Data source:** Zone-verified facts (§6b) + cross-domain correlation

```
□ Ecosystem metrics + adoption reports + merchant/builder intelligence
□ Trust-score computation FOR Zone (Zone stores/serves — C-120 V3 rule)
□ De-identified aggregate disclosure (§5.2)
```

### Analytics V4 — Pi Ecosystem Observatory (external)

**Gate:** Zone V4 + TEC AI ready + data density (C-119 Phase D+)
**Data source:** all verified TEC + ecosystem layers

```
□ External API for Pi developers · adoption/market intelligence subscriptions
□ The point at which Analytics becomes a Pi ecosystem standard, not a TEC feature
```

---

## 8. THE EXTERNAL ASSET — Pi Ecosystem Observatory

```
Truth State for this section: [Future Vision] — Phase D+ (C-119 §7).
Building it before the pipeline has data density is premature.
```

Inside TEC, Analytics is the Intelligence Runtime. Outside TEC it can
become **Pi Ecosystem Observatory** — the measured view of the entire Pi
economy, the way Glassnode is for Bitcoin and Dune is for crypto, but
native to Pi and grounded in Zone-verified evidence.

```
Standard Value (C-119 §6): Analytics serves all Pi users, not only TEC users.
Its value compounds with Pi network size (47M+), not only TEC growth.
Ranking: Zone has the highest Standard Value; Analytics is second.
Sequence: the Observatory follows Zone V2+ — verified reality before
published reality. Reports without verified inputs would be noise.
```

---

## 9. INFRASTRUCTURE DEPENDENCIES

```
Hub          → identity (scopes own-disclosure §5.1)
Zone         → verified facts (institutional/published intelligence §6b)
Commerce     → transaction/order signals (V2+)
Assets/FundX → ownership + capital signals (V2+/V3+)
Connection   → relationship signals (V3+)
All services → raw events via Redis Streams (operational §6a)
TEC AI       → consumes Analytics output (Analytics never recommends)
```

---

## 10. KEY METRICS

```
Primary (Intelligence Quality):
  Event ingestion lag      (target < 5 min)
  Aggregation freshness     (24h window refreshed ≤ 15 min)
  Disclosure-boundary breaches (target: ZERO — §5 is non-negotiable)
  Data accuracy vs owning-service truth (target 100%)

Secondary (Ecosystem Impact):
  External report consumers · API calls from non-TEC developers
  Decisions measurably informed by Analytics (merchant/builder/capital)
```

---

## 11. CONSTITUTIONAL POSITION

```
Analytics sits between Zone and Nexus in the pipeline:

Zone (verification) → Analytics (intelligence) → Nexus (orchestration)

Analytics is the bridge between
"what has been verified as true" (Zone)
and "what should happen next" (Nexus) / "what to do" (TEC AI).

Without Analytics:
  TEC AI reasons without measured reality
  Nexus coordinates without knowing what is happening
  Merchants decide blind · the Pi economy has no measured self-image

With Analytics:
  Reality is measurable · the ecosystem can see itself
  Every downstream reasoning step stands on measured ground
```

---

## FINAL STATEMENT

```
Pi ecosystem has wallets.
Pi ecosystem has apps.
Pi ecosystem has (with Zone) trust.
Pi ecosystem does not have a measured image of itself.

Analytics provides that image.

Not by guessing —
but by aggregating events,
grounding them in verified evidence,
and turning them into measurable reality.

Hub identifies who is acting.
Zone verifies what can be trusted.
Analytics measures what is happening.
Nexus coordinates what should happen next.
TEC AI reasons about what to do.

If Zone is the Trust Infrastructure of the Pi economy,
Analytics is its Reality Infrastructure —
and the two, with Hub, are the Kernel.
```

---

## Related Documents

| Doc | Relationship |
|-----|--------------|
| C-119 | Economic Operating System Model — Analytics is a Tier-1 Constitutional Runtime defined by it |
| C-120 | Zone Constitutional Runtime Charter — the Trust↔Reality counterpart; Zone verifies, Analytics measures |
| C-121 | Institutional Knowledge Pipeline — Analytics is the Intelligence stage of the chain |
| C-105 | Analytics Institutional Charter — the product / BI-surface charter; this doc is the constitutional runtime above it |
| C-68 | Domain Ownership — Analytics owns exactly one question: "What is happening?" |
| C-17 | Data Privacy & Retention — governs the §5 disclosure boundary |
