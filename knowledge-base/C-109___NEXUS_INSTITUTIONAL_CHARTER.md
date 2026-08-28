# C-109 — NEXUS INSTITUTIONAL CHARTER
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

**Nexus is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `nexus.tecosystem.app` · **Pi App ID:** `nexus-3x2v` · **APP_SOURCE:** `nexus`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_NEXUS` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---

## 1. MISSION

Orchestrate economic coordination between TEC actors — users, merchants, services, and AI agents — through governed workflows, execution routing, and asynchronous coordination primitives.

---

## 2. INSTITUTIONAL ROLE

```
System of Coordination — Economic Coordination Infrastructure
```

Nexus is the **coordination fabric** of the TEC runtime. When multiple actors need to cooperate on an economic outcome (multi-party deals, conditional workflows, agent orchestration), Nexus is the orchestration layer.

---

## 3. ECONOMIC PURPOSE

تقليل تكلفة التنسيق بين الأطراف المتعددة.

- بدون Nexus: كل coordination يحتاج manual intervention → friction → deals fall through
- بوجود Nexus: complex economic workflows execute automatically → scale
- اقتصادياً: automation of coordination = more economic activity at same headcount

---

## 4. AUTHORITY BOUNDARY

### Owns
- Workflow definition and execution
- Execution routing (which service handles which step)
- Actor coordination (synchronous + asynchronous)
- Workflow state and history
- Conditional logic and branching

### Does NOT Own
- Business rules inside workflows (owned by domain services)
- Governance authority (owned by SYSTEM — C-110)
- Payment processing (owned by tec-payment-service)
- Truth of any entity (each service owns its own entity truth)
- AI reasoning (owned by TEC AI — C-104)

### Interface Points
```
OUTBOUND:
  Workflow execution  → any TEC service via API Gateway
  Execution events    → Redis Streams (workflow.step.completed.v1)
  Coordination state  → TEC AI (C-104) for intelligent routing

INBOUND:
  Workflow triggers   → users, merchants, services, AI agents
  Governance policies → SYSTEM (C-110) — what workflows are allowed
  Capability registry → C-94 — what Nexus can orchestrate
  Service responses   → all 12 tec-core-backend services
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Workflow Engine: Temporal.io (or custom Redis-based state machine)
    Recommendation: Temporal.io for durability and retry guarantees
  State Storage: PostgreSQL (workflow history) + Redis (active state)
  tec-core-backend integration: via API Gateway (4000) + INTERNAL_SECRET
  Event Bus: Redis Streams (XADD/XREADGROUP)

Workflow Patterns:
  Sequential:  Step A → Step B → Step C
  Parallel:    [Step A, Step B] → wait for both → Step C
  Conditional: if condition → Step A else Step B
  Saga:        distributed transaction with compensating actions

Saga Pattern (Critical for financial workflows):
  Payment Saga:
    1. Reserve inventory (commerce-service)
    2. Create payment (payment-service)
    3. Confirm inventory (commerce-service)
    4. Complete payment (payment-service)
    Compensating: if step 3 fails → cancel payment, release inventory

Consistency:
  Workflow state: strong consistency (single workflow owner)
  Cross-service coordination: saga pattern (compensating transactions)
  At-least-once execution: workflows are idempotent by design

Actor Context:
  Every workflow execution carries ActorContext (C-47 §4)
  Nexus is a ServiceActor when calling other services
  Audit trail: every workflow step logged with correlationId
```

---

## 6. SECURITY MODEL

```
Workflow Authorization:
  Only SYSTEM-approved workflow types can be registered
  Workflow execution requires valid ActorContext
  Cross-service calls: ServiceActor + INTERNAL_SECRET required

Governance Boundary:
  Nexus cannot execute workflows that bypass governance
  SYSTEM policies evaluated before workflow start
  Forbidden: workflow that bypasses payment-service for Pi transfers

Audit Requirements:
  Every workflow step: actorId, timestamp, input_hash, output_hash
  Workflow history retained for 2 years (financial workflows)
  Failed workflows: preserved for diagnosis (not deleted)

P6 Fail Closed:
  Missing actor context on workflow trigger → REJECT
  Unknown workflow type → REJECT
  SYSTEM policy violation → REJECT with audit log
```

---

## 7. REVENUE MODEL

**Indirect (Economic Efficiency)**

| Channel | Mechanism | Value |
|---------|-----------|-------|
| Automation | More transactions at same headcount | Platform-level |
| Enterprise Workflows | Custom workflow templates | Enterprise tier |
| Agent Orchestration | AI agent coordination (TEC AI + DX) | Phase 3 |

Nexus value is measured in transactions enabled, not direct revenue.

---

## 8. KEY METRICS

```
Workflow Success Rate:   ≥ 99% (end-to-end completion)
Saga Compensation Rate:  < 1% (% of workflows requiring rollback)
Execution Latency (P95): < 2s per workflow step
Workflow Durability:     100% (no lost workflow state on service restart)
Actor Context Coverage:  100% (every step has valid ActorContext)
Audit Trail Completeness: 100%
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Transaction Complexity Enabler** — multi-party deals that would otherwise be manual
- **Agent Orchestration Foundation** — TEC AI agents operate through Nexus
- **Saga Infrastructure** — reliable distributed transactions across 12 services
- **Economic Automation** — reduces operational cost of complex economic activity

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Basic sequential workflows (checkout saga, asset transfer saga)
  → Compensation/rollback for payment failures
  → Workflow history and status API

Phase 2:
  → Parallel workflows (multi-party deals)
  → TEC AI integration (intelligent routing)
  → Custom workflow templates for merchants

Phase 3:
  → Economic Coordination Runtime
  → AI agent workflows (autonomous economic actors)
  → Cross-ecosystem coordination (beyond TEC)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Workflow Engine Decision
  Temporal.io vs Redis-based state machine.
  Key criteria: durability, replay guarantees, Railway compatibility.
  Recommendation: Temporal.io Cloud (avoid self-hosting).

[P0-2] Saga Pattern Definition
  Define compensating actions for each critical workflow type before launch.
  Especially: payment saga + asset transfer saga.
```

**P1:**
```
[P1-1] ActorContext Propagation
  Nexus must propagate the ORIGINAL actor's context (not replace with
  ServiceActor context) through all workflow steps.
  This ensures audit trail traces back to human actor.
```

---

## 12. INTEGRATION MAP

```
This charter (C-109) depends on:
  C-110 SYSTEM    → workflow type governance + approval
  C-94  CAPABILITY REGISTRY → what can be orchestrated
  C-104 TEC AI    → intelligent routing for complex decisions
  All 12 tec-core-backend services → execution targets

Other charters depend on this one for:
  C-104 TEC AI    → agent orchestration
  C-113 FUNDX     → investment pool workflows
  C-114 ESTATE    → property transaction workflows
  C-115 DX        → automated deployment workflows
```
