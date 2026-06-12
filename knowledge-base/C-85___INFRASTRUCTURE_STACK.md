# C-85 — ECONOMIC INFRASTRUCTURE STACK

## TEC Ecosystem — Layer Identity & Build Sequencing

> Status: DRAFT — Strategic Reference
> Authority: Platform Architecture
> Version: 1.0 — June 2026
> Warning: Post-Portal content — no implementation before Gate A
> Truth State: [Future Vision] — Layer 0 only is [Current State]
> Governance State: [Draft]
> Verification State: [Unverified]
> Authority Scope: [Platform]

---

# 1. THE INFRASTRUCTURE STACK

TEC is not a collection of apps.
TEC is an Economic Operating Infrastructure for Pi Network.

Each layer answers one essential question:

| Layer | Question | Infrastructure Identity |
|-------|----------|------------------------|
| Hub | Who are you? | Identity Infrastructure |
| Wallet | What do you have? | Settlement Infrastructure |
| Payments | How does value move? | Transaction Infrastructure |
| Assets | What do you own? | Ownership Infrastructure |
| Commerce | What do you trade? | Transaction Layer |
| Ecommerce | What do you buy? | Consumer Layer |
| FundX | Where does capital flow? | Capital Infrastructure |
| Connection | Who should coordinate? | Coordination Infrastructure |
| Analytics | What is happening economically? | Intelligence Infrastructure |
| Explorer | What exists and how connects? | Discovery Infrastructure |
| Nexus | What should happen next? | Orchestration Infrastructure |
| SYSTEM | What rules govern the economy? | Governance Infrastructure |
| ALERT | What threatens the economy? | Risk Intelligence Infrastructure |

---

# 2. DEPENDENCY CHAIN (Build Order — Absolute)

```
LAYER 0 — EXISTS NOW (Portal scope)        [Current State]
├── Hub          (Identity)
├── Commerce     (Transactions)
├── Assets       (Ownership)
└── Ecommerce    (Consumer)

LAYER 1 — POST-PORTAL (Gate A required)   [Planned State]
├── Analytics    ← backend EXISTS (:5011) — needs Intelligence UI layer
└── Life         ← retention layer

LAYER 2 — GROWTH (Gate B — 10k+ users)   [Future Vision]
├── Connection   ← needs real economic graph data
├── Explorer     ← needs topology to explore
└── FundX        ← legal + KYC maturity required

LAYER 3 — PLATFORM (Gate C + D)           [Future Vision]
├── Nexus        ← needs Connection + Analytics + Events mature
├── SYSTEM       ← partially EXISTS as Gateway + Policy CI + ADRs + Kill Switches
└── ALERT        ← needs Analytics + Event streams mature
```

---

# 3. LAYER DEFINITIONS

## ANALYTICS
```
Truth State: [Planned State] — backend exists, UI needed
Build trigger: POST-PORTAL (immediately)
Gate: A

What it solves: "What is happening economically?"

Existing: analytics-service :5011 (Railway, Supabase)

UI layer needed:
  Economic Intelligence    → capital flow, transaction velocity
  Ecosystem Health         → runtime health, governance pressure
  Risk Intelligence        → anomaly detection, fraud signals

NOT: charts app | vanity metrics | page-view analytics
```

## CONNECTION
```
Truth State: [Future Vision]
Build trigger: ≥ 10,000 active users + economic graph has data
Gate: B

What it solves: "Who should coordinate?"

Core: Economic Discovery + Trust Resolution + Opportunity Matching

NOT: social media | feed app | followers platform

Why data-first: Connection without economic graph = LinkedIn with zero connections.
```

## EXPLORER
```
Truth State: [Future Vision]
Build trigger: ≥ 10,000 economic entities + topology worth exploring
Gate: B + Analytics mature

What it solves: "What exists and how is it connected?"

NOT: block explorer | search engine only

Why data-first: Explorer without topology = search engine with no results.
```

## NEXUS
```
Truth State: [Future Vision]
Build trigger: Connection + Analytics + Events mature
Gate: C + D

What it solves: "What should happen next?"

Constitutional rule (C-84): Nexus orchestrates. NEVER executes economic actions.

NOT: Zapier clone | Autonomous AI engine
```

## SYSTEM
```
Truth State: [Current State — partially]
Status: PARTIALLY EXISTS NOW

Already implemented:
  API Gateway      → routing governance
  Policy CI        → code-level enforcement
  ADR System       → architectural decision governance
  Kill Switches    → PAYMENTS_ENABLED, MODE1_ENABLED, etc.
  C-78             → operational governance framework

Remaining (post-Portal):
  Runtime Registry UI  → visual topology of 12 services
  Governance Dashboard → ADR compliance, gate status
  Blast Radius Map     → visual failure domain display

NOT a new app. It already exists. Needs unified control interface.
```

## ALERT
```
Truth State: [Future Vision]
Build trigger: Analytics + Event streams mature
Gate: C

What it solves: "What threatens the economy?"

NOT: notification system | toast service

Why after Analytics: Alert without observability = fire alarm with no sensors.
```

---

# 4. COMPLETE INFRASTRUCTURE MESH (Post-Scale)

```
Explorer   → discovers the economy
Analytics  → understands the economy
Connection → connects the economy
Nexus      → orchestrates the economy
SYSTEM     → governs the economy
ALERT      → protects the economy

Together: Economic Operating Infrastructure for Pi Network
```

---

# 5. EXTERNAL API EVOLUTION

| Phase | Capability |
|-------|-----------|
| Phase 2 | Analytics economic signals API |
| Phase 3 | Connection trust + relevance API |
| Phase 3 | Explorer topology API |
| Phase 4 | Nexus orchestration API |
| Phase 4 | SYSTEM governance API |

This is when TEC stops being an app ecosystem and becomes Economic Infrastructure.

---

# 6. BUILD SEQUENCE (ABSOLUTE — DO NOT SKIP)

```
NOW — Portal:
  ✅ NEW-A + NEW-B + NEW-D + NEW-J closed
  □  tec-ui v1.2.0 publish
  □  External audit ≥ 9.5
  □  Submit Portal

POST-PORTAL (Phase 1):
  Analytics UI      ← backend exists, build intelligence layer
  Life              ← retention engine
  SYSTEM UI         ← governance dashboard for existing infrastructure
  Hub hardening     ← KYC + Subscription maturity

PHASE 2 (Gate B — 10k users):
  Connection        ← economic graph has real data
  Explorer          ← topology worth exploring
  FundX             ← capital infrastructure (legal required)

PHASE 3 (Gate C+D):
  Nexus             ← orchestrates mature layers
  ALERT             ← detects in mature analytics

PHASE 4 (Gate E):
  External APIs
  Economic Infrastructure for Pi ecosystem
```

---

# 7. ANTI-PATTERNS

```
❌ Building Connection before economic graph has data
❌ Building Explorer before topology exists
❌ Building Nexus before layers to orchestrate
❌ Building ALERT before Analytics is mature
❌ Treating SYSTEM as a new app (it already exists)
❌ Building any Phase 3+ before Portal submission
❌ Creating documentation without execution
```

---

# 8. RELATIONSHIP TO OTHER CONTENTS

| Content | Relationship |
|---------|-------------|
| C-82 Platform Maturity | Build sequence maps to maturity stages |
| C-83 EVL/ESL | Semantic domains map to infrastructure layers |
| C-84 Runtime Constitution | Gates govern infrastructure build sequence |

---

# FINAL STATEMENT

```
The question is not: "What apps should TEC build?"
The question is: "What infrastructure questions does the Pi economy need answered?"

Explorer answers:   What exists?
Analytics answers:  What is happening?
Connection answers: Who should coordinate?
Nexus answers:      What should happen next?
SYSTEM answers:     What rules govern?
ALERT answers:      What threatens?

Build the answers in order.
Build them when the data exists.
Build them when the governance is ready.
Then TEC becomes infrastructure. Not just ecosystem.
```
