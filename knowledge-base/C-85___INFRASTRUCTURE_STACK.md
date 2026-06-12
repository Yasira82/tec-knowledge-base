# C-85 — ECONOMIC INFRASTRUCTURE STACK

## TEC Ecosystem — Layer Identity & Build Sequencing

> Status: DRAFT — Strategic Reference
> Authority: Platform Architecture
> Version: 2.0 — June 2026
> Warning: Post-Portal content — no implementation before Gate A
> Truth State: [Future Vision] — Layer 0 only is [Current State]
> Governance State: [Draft]
> Verification State: [Unverified]
> Authority Scope: [Platform]

---

# 1. THE 9-LAYER INFRASTRUCTURE MODEL

TEC is not a collection of apps.
TEC is an Economic Operating Infrastructure for Pi Network.

Each layer answers one essential question and holds a distinct infrastructure identity:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Pi Network                                                         │
│  Blockchain + Settlement + Wallet                                   │
│  (Foundation — not owned by TEC)                                    │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 1: IDENTITY INFRASTRUCTURE          [Current State]          │
│  Hub Auth + Trust + Verification                                    │
│  "Who are you in the Pi economy?"                                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 2: REALITY INFRASTRUCTURE            [Planned → Future]      │
│  Life + Connection + Explorer                                       │
│  System of Record — "What is your economic reality?"               │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 3: INTELLIGENCE INFRASTRUCTURE       [Planned State]         │
│  Analytics                                                          │
│  "What is happening economically?"                                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 4: GOVERNANCE INFRASTRUCTURE         [Current State partial] │
│  SYSTEM (API Gateway + ADRs + Policy CI + Kill Switches)            │
│  "What rules govern the economy?"                                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 5: COORDINATION INFRASTRUCTURE       [Future Vision]         │
│  Nexus                                                              │
│  "What should happen next?"                                         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 6: RISK INFRASTRUCTURE               [Future Vision]         │
│  ALERT + NX                                                         │
│  "What threatens the economy?"                                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 7: REASONING INFRASTRUCTURE          [Future Vision]         │
│  TEC AI — Institutional Reasoning Runtime                           │
│  (Cross-layer — consumes all layers, produces Recommendations)      │
│  "What does the economic evidence mean?"                            │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 8: ACCESS INFRASTRUCTURE             [Current State]         │
│  Hub — Unified Access Platform                                      │
│  "How does the user access TEC's economic operating infrastructure?"│
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│  Layer 9: PRODUCTION INFRASTRUCTURE         [Current State]         │
│  Commerce + Assets + Ecommerce + Apps                               │
│  Systems of Production — "Where does economic value get created?"   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                     Economic Activity
```

---

# 2. THREE-WAY SYSTEM MODEL

```
System of Record      (TEC Infrastructure Layers 1-6)
  → defines economic reality
  → owns the authoritative state of: identity, assets, transactions, relationships
  → Truth Owner

System of Reasoning   (TEC AI — Layer 7)
  → interprets economic reality
  → consumes: events + state + governance rules from all layers
  → produces: Recommendations / Reasoning / Guidance
  → NEVER executes — only advises
  → Recommendation Owner

System of Access      (Hub — Layer 8)
  → provides access to TEC economic reality
  → SSO Authority + Identity Root + Payment Orchestrator
  → Access Owner

Systems of Production (Apps — Layer 9)
  → create economic value within the infrastructure
  → Commerce / Assets / Ecommerce / Future Apps
  → Execution Owner (within their sovereign domain)
```

Constitutional Rule:
```
System of Record defines what is true.
System of Reasoning interprets what is true.
System of Access delivers what is true.
Systems of Production operate within what is true.
None of the above may contradict the Record.
```

---

# 3. INFRASTRUCTURE VS INTERFACE

Infrastructure = State + Authority + Verification (answers: what IS?)
```
  Identity Infrastructure   → IS the identity of users
  Reality Infrastructure    → IS the economic context
  Intelligence Infrastructure → IS the economic data
  Governance Infrastructure  → IS the rule system
  Coordination Infrastructure → IS the orchestration
  Risk Infrastructure        → IS the protection layer
  Reasoning Infrastructure   → IS the interpretation layer
```

Interface / Interaction = Channel + Delivery (answers: how is it ACCESSED?)
```
  Hub (Web)       → Access via browser UI
  VAPI            → Access via voice / natural language
  Mobile          → Access via native app
  Email / Push    → Access via notification
  External API    → Access via developer API
```

Constitutional Rule:
```
VAPI is NOT a Domain.
VAPI is NOT an Infrastructure Layer.
VAPI is an Interaction Runtime — the first implementation of
the Natural Language Coordination Interface.
VAPI answers: "How does a user speak to TEC's economic infrastructure?"
```

---

# 4. LAYER DEFINITIONS

## IDENTITY INFRASTRUCTURE (Layer 1)
```
Truth State: [Current State]
Apps: Hub (auth layer)

What it answers: "Who are you in the Pi economy?"

Components:
  tec-auth-service → Pi identity verification
  tec-identity-service → TEC profile + KYC status
  tec-kyc-service → KYC verification workflow
  SSO → single identity across all TEC apps

NOT: just a login screen | just a JWT service
```

## REALITY INFRASTRUCTURE (Layer 2)

### Life — Personal Economic Context Infrastructure
```
Truth State: [Planned State] — Committed post-Portal
Build trigger: POST-PORTAL (Gate A)

What it answers: "Who am I becoming economically?"

Core: Personal spending timeline + budget + cashflow + economic trajectory
System of Record for: personal economic context

NOT: productivity app | journal | todo list
Why Reality-layer: Life defines the personal economic context that
  Intelligence interprets and Coordination acts on.
```

### Connection — Economic Relationship Infrastructure
```
Truth State: [Future Vision]
Build trigger: ≥ 10,000 active users + economic graph has data
Gate: B

What it answers: "Who should coordinate with you economically?"

Core: Economic Discovery + Trust Resolution + Opportunity Matching
System of Record for: economic relationships between Pi entities

NOT: social media | feed app | followers platform
Why data-first: Connection without economic graph = LinkedIn with zero connections.
```

### Explorer — Economic Discovery Infrastructure
```
Truth State: [Future Vision]
Build trigger: ≥ 10,000 economic entities + topology worth exploring
Gate: B + Analytics mature

What it answers: "What economic entities exist and how are they connected?"

Core: Entity discovery + topology navigation + relationship mapping
System of Record for: the discoverable economic topology of Pi Network

NOT: block explorer | search engine only
Why data-first: Explorer without topology = search engine with no results.
```

## INTELLIGENCE INFRASTRUCTURE (Layer 3)

### Analytics
```
Truth State: [Planned State] — backend exists, UI needed
Build trigger: POST-PORTAL (immediately)
Gate: A

What it answers: "What is happening economically?"

Existing: analytics-service :5011 (Railway, Supabase)

UI layer needed:
  Economic Intelligence    → capital flow, transaction velocity
  Ecosystem Health         → runtime health, governance pressure
  Risk Intelligence        → anomaly detection, fraud signals

NOT: charts app | vanity metrics | page-view analytics
```

## GOVERNANCE INFRASTRUCTURE (Layer 4)

### SYSTEM
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

## COORDINATION INFRASTRUCTURE (Layer 5)

### Nexus
```
Truth State: [Future Vision]
Build trigger: Connection + Analytics + Events mature
Gate: C + D

What it answers: "What should happen next in the economy?"

Constitutional rule (C-84): Nexus orchestrates. NEVER executes economic actions.

NOT: Zapier clone | Autonomous AI engine
```

## RISK INFRASTRUCTURE (Layer 6)

### ALERT
```
Truth State: [Future Vision]
Build trigger: Analytics + Event streams mature
Gate: C

What it answers: "What threatens the economy?"

NOT: notification system | toast service
Why after Analytics: Alert without observability = fire alarm with no sensors.
```

## REASONING INFRASTRUCTURE (Layer 7)

### TEC AI — Institutional Reasoning Runtime
```
Truth State: [Future Vision]
Build trigger: Gates D + D.5 PASSED + sufficient data
Gate: D+ (requires Economic Runtime MVP operational)
Commitment: [Tentative]

What it answers: "What does the economic evidence mean?"

Nature:
  NOT an App
  NOT a Domain
  NOT an AI chatbot
  IS:  Cross-layer Institutional Reasoning Runtime

Inputs (consumes all layers):
  Economic events + state from all services
  Governance rules from SYSTEM
  Risk signals from ALERT
  Relationship context from Connection
  Intelligence signals from Analytics

Outputs (produces only):
  Recommendations
  Reasoning chains (explainable)
  Guidance signals
  Governance interpretations

Constitutional Rules:
  TEC AI MUST NOT execute economic actions.
  TEC AI MUST NOT move funds.
  TEC AI MUST NOT alter governance rules.
  Every recommendation MUST be reproducible + explainable.
  Human override ALWAYS available.

Package: @tec/reasoning-runtime (Gate E)
```

### VAPI — Natural Language Coordination Interface
```
Truth State: [Future Vision]
Build trigger: Gate E (Adaptive Runtime)
Commitment: [Exploratory]

Nature:
  NOT a Domain
  NOT an Infrastructure Layer
  IS:  Interaction Runtime
  IS:  First implementation of Natural Language Coordination Interface

What it answers: "How does a user speak to TEC's economic infrastructure?"

VAPI is a CHANNEL — like Hub (web), Mobile (native), Email (notification).
VAPI carries user intent to the TEC infrastructure.
VAPI does NOT define economic reality — it accesses it.
```

---

# 5. BUILD DEPENDENCY CHAIN (Absolute)

```
LAYER 0 — EXISTS NOW (Portal scope)        [Current State]
├── Hub          (Identity + Access)
├── Commerce     (Production — Transactions)
├── Assets       (Production — Ownership)
└── Ecommerce    (Production — Consumer)

LAYER 1 — POST-PORTAL (Gate A required)   [Planned State]
├── Analytics    ← backend EXISTS (:5011) — needs Intelligence UI layer
├── Life         ← Personal Economic Context Infrastructure
└── SYSTEM UI    ← governance dashboard (SYSTEM already exists)

LAYER 2 — GROWTH (Gate B — 10k+ users)   [Future Vision]
├── Connection   ← needs real economic graph data
├── Explorer     ← needs topology to explore
└── FundX        ← legal + KYC maturity required

LAYER 3 — PLATFORM (Gate C + D)           [Future Vision]
├── Nexus        ← needs Connection + Analytics + Events mature
└── ALERT        ← needs Analytics + Event streams mature

LAYER 4 — REASONING (Gate D+)            [Future Vision]
└── TEC AI       ← needs all Layers 1-6 mature + Economic Runtime MVP

LAYER 5 — INTERACTION (Gate E)           [Future Vision]
└── VAPI         ← Natural Language Coordination Interface
```

---

# 6. BUILD SEQUENCE (ABSOLUTE — DO NOT SKIP)

```
NOW — Portal:
  ✅ NEW-A + NEW-B + NEW-D + NEW-J closed
  □  tec-ui v1.2.0 publish
  □  External audit ≥ 9.5
  □  Submit Portal

POST-PORTAL (Phase 1 — Gate A):
  Analytics UI      ← backend exists, build intelligence layer
  Life              ← Personal Economic Context Infrastructure
  SYSTEM UI         ← governance dashboard for existing infrastructure
  Hub hardening     ← KYC + Subscription maturity

PHASE 2 (Gate B — 10k users):
  Connection        ← economic graph has real data
  Explorer          ← topology worth exploring
  FundX             ← capital infrastructure (legal required)

PHASE 3 (Gate C+D):
  Nexus             ← orchestrates mature layers
  ALERT             ← detects in mature analytics

PHASE 4 (Gate D+):
  TEC AI            ← Institutional Reasoning Runtime

PHASE 5 (Gate E):
  VAPI              ← Natural Language Coordination Interface
  External APIs     ← Economic Infrastructure for Pi ecosystem
```

---

# 7. EXTERNAL API EVOLUTION

| Phase | Capability |
|-------|----------|
| Phase 2 | Analytics economic signals API |
| Phase 3 | Connection trust + relevance API |
| Phase 3 | Explorer topology API |
| Phase 4 | Nexus orchestration API |
| Phase 4 | SYSTEM governance API |
| Phase 5 | TEC AI reasoning API |

This is when TEC stops being an app ecosystem and becomes Economic Infrastructure.

---

# 8. ANTI-PATTERNS

```
❌ Building Connection before economic graph has data
❌ Building Explorer before topology exists
❌ Building Nexus before layers to orchestrate
❌ Building ALERT before Analytics is mature
❌ Building TEC AI before Economic Runtime MVP operational
❌ Treating VAPI as a Domain (it is an Interaction channel)
❌ Treating TEC AI as an App (it is Reasoning Infrastructure)
❌ Treating SYSTEM as a new app (it already exists)
❌ Building any Phase 3+ before Portal submission
❌ Creating documentation without execution
```

---

# 9. RELATIONSHIP TO OTHER CONTENTS

| Content | Relationship |
|---------|-------------|
| C-82 Platform Maturity | Build sequence maps to maturity stages |
| C-83 EVL/ESL | Semantic domains map to infrastructure layers |
| C-84 Runtime Constitution | Gates govern infrastructure build sequence |
| C-86 Temporal Governance | Applies to all layer event ordering |
| C-87 Execution Governance | Authority + Ownership classification per layer |

---

# FINAL STATEMENT

```
The question is not: "What apps should TEC build?"
The question is: "What infrastructure questions does the Pi economy need answered?"

Identity answers:      Who are you?
Reality answers:       What is your economic context?
Intelligence answers:  What is happening?
Governance answers:    What rules apply?
Coordination answers:  What should happen next?
Risk answers:          What threatens?
Reasoning answers:     What does the evidence mean?
Access answers:        How do you interact with all of this?
Production answers:    Where does value get created?

Build the answers in order.
Build them when the data exists.
Build them when the governance is ready.
Then TEC becomes infrastructure. Not just ecosystem.
```
