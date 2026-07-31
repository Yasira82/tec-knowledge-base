# C-121 — INSTITUTIONAL KNOWLEDGE PIPELINE

## TEC Ecosystem — The Sequential Intelligence Chain

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Platform]`

---
## Implementation Status — Value Chain (2026-07-31)

> **Truth State:** `[Current State]` for the edges below · `[Future Vision]` for the full 7-layer pipeline
> **Verification:** `[Code Verified]` (merged to `main`) — not yet `[Runtime Verified]`

**Rule 3 — Data Flows Forward** now has its first live, event-driven edges in
production code. The **reputation value chain** (a user-layer branch of the pipeline)
is wired end-to-end in `tec-identity-service`:

| Edge | Signal (C-70) | Direction | Status |
|------|---------------|-----------|--------|
| Epic → Legend | `epic.project.completed.v1` | create → earn | ✅ Code Verified (merged) |
| Zone → Legend | `zone.badge.issued.v1` | verify → earn | ✅ Code Verified (merged) |
| Elite → VIP | live tier check (no event) | recognition → experience | ✅ Code Verified (merged) |
| → Legend (consumer) | ingests both streams, idempotent by `eventId` | — | ✅ Code Verified (merged) |

Producer: `src/events/stream-emitter.ts` (Redis Streams; fail-safe no-op without
`REDIS_URL`). Consumer: `legend.consumer.ts` (group `identity-legend`).

**Runtime gate:** these edges fire only when `REDIS_URL` is set on
`tec-identity-service` **and** the Legend consumer runs. Until then the emit is a logged
no-op — hence `[Code Verified]`, **not** `[Runtime Verified]`.

The **Legend → Elite** edge is now also wired: `EliteService.evaluateOwner` grants
criteria-based recognition from Legend evidence (Analytics `score_*` relayed + verified
counts), GOLD/PLATINUM gated behind a human PANEL. `[Code Verified]` (tec-core-backend #159).

**Still future:** the canonical infrastructure pipeline
(Hub → Life → Connection → Zone → Analytics → Nexus → TEC AI), and richer multi-signal
Elite scoring as Analytics matures (the V1 engine grants on one metric per program).

---

## PREAMBLE

The most important architectural discovery in TEC.

TEC's core infrastructure components are not parallel.
They are sequential.

They form a pipeline:

```
Identity → Context → Relationships → Verification →
Intelligence → Coordination → Reasoning
```

Each layer:
- Consumes the output of the previous layer
- Produces input for the next layer
- Has a single, non-transferable function

Break any link and the pipeline produces incomplete intelligence.

This document defines the constitutional rules of that pipeline.

---

## 1. THE PIPELINE

```
┌─────────────────────────────────────────────────────────┐
│           INSTITUTIONAL KNOWLEDGE PIPELINE               │
└─────────────────────────────────────────────────────────┘

LAYER 0 — SETTLEMENT
  Pi Network
  "Where does value settle?"
  Output: Verified Pi transactions + wallet state

        ↓

LAYER 1 — IDENTITY
  Hub
  "Who are you in Pi?"
  Input:  Pi Network identity
  Output: Verified Pi user + session + SSO

        ↓

LAYER 2 — PERSONAL CONTEXT
  Life
  "What matters to you?"
  Input:  Hub identity
  Output: Goals, preferences, records, personal context

        ↓

LAYER 3 — RELATIONSHIPS
  Connection
  "Who matters to you?"
  Input:  Life context + Hub identity
  Output: Relationship graph, trust signals, communities

        ↓

LAYER 4 — VERIFICATION
  Zone
  "What can be trusted?"
  Input:  Connection signals + Commerce/Assets activity
  Output: Verified entities, evidence records, trust scores

        ↓

LAYER 5 — INTELLIGENCE
  Analytics
  "What is happening?"
  Input:  Zone verified data + all economic activity
  Output: Patterns, trends, metrics, signals

        ↓

LAYER 6 — COORDINATION
  Nexus
  "What should happen next?"
  Input:  Analytics signals + human intent
  Output: Coordinated workflows (with human approval)

        ↓

LAYER 7 — REASONING
  TEC AI
  "What do I recommend?"
  Input:  Zone knowledge + Analytics patterns + all layers
  Output: Personalized recommendations + insights

        ↓

ECONOMIC ACTIVITY
  Commerce / Assets / FundX / Estate / Explorer
  "What do users transact?"

        ↓

LAYER 0 — SETTLEMENT (loop)
  Pi Network settles all transactions
```

---

## 2. WHY THE ORDER MATTERS

### Hub must come before Life

```
Life manages personal context.
Personal context requires verified identity.
Hub provides verified identity.

Life without Hub = anonymous personal data.
That is not personal context. That is noise.
```

### Life must come before Connection

```
Connection manages relationships between people.
Relationships require knowing who each person is.
Life provides that context per person.

Connection without Life = linking anonymous nodes.
That is not a relationship graph. That is a web.
```

### Connection must come before Zone

```
Zone verifies trust claims.
Trust claims come from relationships and economic activity.
Connection generates relationship signals.

Zone without Connection = static directory.
Useful but not intelligent.
Zone with Connection = dynamic trust verification.
```

### Zone must come before Analytics (at full intelligence)

```
Analytics generates intelligence from data.
Intelligence is only as good as the data it processes.
Zone transforms unverified data into verified evidence.

Analytics without Zone = intelligence from noise.
Analytics with Zone = intelligence from verified signal.
```

### Analytics must come before TEC AI

```
TEC AI reasons from patterns.
Patterns come from Analytics.
Accurate patterns require verified data (Zone).

TEC AI without Analytics = reasoning without observation.
TEC AI without Zone = reasoning from unverified claims.
TEC AI with both = institutional economic intelligence.
```

### Zone must precede FundX and Estate

```
FundX connects investors with opportunities.
Estate connects buyers with sellers.
Both require verified counterparties.

FundX without Zone = connecting strangers.
Estate without Zone = anonymous property transactions.
Both with Zone = trusted economic coordination.
```

---

## 3. CONSTITUTIONAL RULES

### Rule 1 — Sequential Dependency

```
No component may be fully utilized
before the components it depends on are operational.

OPERATIONAL means:
  - Live in production
  - Serving real users
  - Generating real data

NOT operational means:
  - Technically deployed but no users
  - Documentation exists but not built
  - Planned but not yet running
```

### Rule 2 — Single Function

```
Each pipeline layer answers exactly one question.
No layer may answer a question owned by another layer.

VIOLATION EXAMPLES:
  Life computing trust scores → Zone's function
  Zone making recommendations → TEC AI's function
  TEC AI executing transactions → Nexus + payment-service
  Nexus making autonomous decisions → Constitutional violation (C-84)
```

### Rule 3 — Data Flows Forward

```
Data flows from earlier layers to later layers.
Later layers do not produce primary data for earlier layers.

ALLOWED:
  Connection → Zone (trust signals)
  Zone → Analytics (verified evidence)
  Analytics → TEC AI (patterns)

NOT ALLOWED:
  TEC AI → Connection (AI should not define relationships)
  Zone → Hub (verification cannot override identity)
  Analytics → Life (aggregate intelligence cannot define personal context)
```

### Rule 4 — Human Override at Layer 7

```
TEC AI (Layer 7) produces recommendations only.
Nexus (Layer 6) coordinates workflows with human approval.

Neither may:
  Execute economic actions autonomously
  Move funds without explicit human confirmation
  Override human economic decisions

This rule is absolute. No exceptions.
Authority: C-84 Constitutional Rule 4.
```

### Rule 5 — Zone Independence

```
Zone (Layer 4) must be designed to serve
the entire Pi ecosystem — not only TEC.

Zone APIs must be accessible to:
  All TEC apps (internal consumption)
  All Pi developers (external consumption)
  Pi Core Team (official registry potential)

Zone cannot be artificially restricted to TEC users.
Restricting Zone = destroying its network effect.
```

### Rule 6 — Pipeline Integrity Gate

```
Before building any Layer N component:
  Verify that Layer N-1 is operational.
  If Layer N-1 is not operational:
    Building Layer N is premature.
    Intelligence will be degraded.
    Network effects will not compound.

Example:
  Before building TEC AI:
    ✓ Zone must be operational
    ✓ Analytics must be operational
    ✓ Sufficient data density (10k+ users)
  
  TEC AI before these gates = generic AI, not economic AI.
```

---

## 4. WHAT THE PIPELINE PRODUCES

At each stage, a different type of value emerges:

```
After Layer 0 (Pi Network):
  Economic settlement capability

After Layer 1 (Hub):
  Verified digital identity

After Layer 2 (Life):
  Personal economic context

After Layer 3 (Connection):
  Economic relationship graph

After Layer 4 (Zone):
  Institutional trust layer

After Layer 5 (Analytics):
  Economic intelligence

After Layer 6 (Nexus):
  Coordinated economic action

After Layer 7 (TEC AI):
  Personalized economic intelligence

Full pipeline operational:
  Economic Operating System
  — a complete infrastructure for human economic coordination
```

---

## 5. THE MINIMUM VIABLE PIPELINE

Not all layers need to be complete for value to exist.

```
MVP Pipeline (Phase 0 — NOW):
  Pi Network + Hub + Commerce + Assets + Ecommerce
  = Basic economic platform
  = Transactions work
  = Users can buy, sell, own

Standard Pipeline (Phase A-B):
  + Life + Analytics + Zone V1 + Connection
  = Economic platform with trust + context
  = Users have meaningful data + verified entities

Full Pipeline (Phase D+):
  + Nexus + TEC AI + Zone V3
  = Economic Operating System
  = Full coordination + reasoning + verified intelligence
```

---

## 6. THE COMPOUNDING EFFECT

The pipeline's power is in its compounding nature:

```
Each layer makes every subsequent layer more valuable.

Hub alone: identity = basic access
Hub + Life: identity + context = personalized access
Hub + Life + Connection: + trust graph = social identity
Hub + Life + Connection + Zone: + verification = trusted identity
Hub + Life + Connection + Zone + Analytics: + intelligence = understood identity
Hub + Life + Connection + Zone + Analytics + TEC AI: + reasoning = economically intelligent identity

The final value is not the sum of layers.
It is the product.

This is why the pipeline must be built sequentially.
Skipping layers does not accelerate growth —
it limits the maximum achievable intelligence.
```

---

## 7. COMPARISON WITH ALTERNATIVES

### Super App Model (WeChat, Grab)

```
WeChat approach:
  All features in one app
  Monolithic intelligence
  Platform lock-in

TEC approach:
  Separated layers with clear boundaries
  Distributed intelligence (each layer specializes)
  Infrastructure standard (Zone, Analytics are ecosystem-wide)

WeChat knows: what you transacted
TEC knows: who you are + who you trust + what matters + what is verified + what is happening

The difference is not features.
The difference is intelligence depth.
```

### Siloed App Model (traditional fintech)

```
Traditional approach:
  Each app has its own data
  No shared intelligence layer
  Users re-enter context for each app

TEC approach:
  Shared context (Life)
  Shared trust (Zone)
  Shared intelligence (Analytics + TEC AI)
  Users' context travels with them across all apps

The difference is not UX.
The difference is economic memory.
```

---

## 8. RELATIONSHIP TO OTHER CONTENTS

| Content | Relationship |
|---------|-------------|
| C-119 | Economic OS Model — defines the tier structure that pipeline sits within |
| C-120 | Zone Charter — implements Layer 4 of this pipeline |
| C-84 | Runtime Constitution — Rule 4 (human override) governs Layer 6+7 |
| C-85 | Infrastructure Stack — C-121 refines the stack into a sequential pipeline |
| C-83 | EVL Design System — visual language for pipeline components |
| C-68 | Domain Ownership — one question per layer is enforced here |
| C-64 | ADRs — ADR-007 (payment) governs economic action at pipeline exit |

---

## FINAL STATEMENT

```
TEC does not build apps.
TEC builds a pipeline.

Each component in the pipeline
answers one question
that the previous component cannot answer.

Together:

Hub answers:       "Who are you?"
Life answers:      "What matters to you?"
Connection answers: "Who matters to you?"
Zone answers:      "What can be trusted?"
Analytics answers: "What is happening?"
Nexus answers:     "What should happen next?"
TEC AI answers:    "What do I recommend?"

These seven questions,
answered in sequence,
by seven specialized components,
constitute the world's first
Pi-native Economic Operating System.

The pipeline is the product.
The components are the means.
The Pi economy is the purpose.
```
