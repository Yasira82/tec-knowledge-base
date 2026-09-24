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

## Implementation Status (2026-09-13)

> **Verification:** `[Code Verified]` — read from `tec-identity-service/src/modules/nexus/`.
> This section exists because the charter **understated** what is built: a persisted saga
> engine with compensation is running, and nothing here said so. Audit:
> `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` §1.

### Built — the §5 workflow engine's CONTROL PLANE is real

| §5 concept | In code | Where |
|---|---|---|
| Workflow definition | `TemplateDef` — 3 governed templates (`checkout-saga`, `asset-transfer-saga`, `subscription-renewal`), each step naming its owning service, whether it moves Pi, its compensating action, and — since #310 — its **callable target** (`call` / `compensationCall`) or the endpoint it waits on (`needs`) | `templates.ts` |
| Step execution | `NexusDispatcher` — the one place a step becomes a real call. Host from env (NEW-A), `x-internal-key` for the service + `x-actor-*` for the **original human** (P1-1), bounded timeout, typed outcome, never throws | `nexus.dispatcher.ts` |
| Saga data flow | `NexusRun.input` (the workflow's parameters) + `NexusStep.output` + `CallDef.capture` — how step 2 confirms the order step 0 opened | `schema.prisma` · `nexus.dispatcher.ts` |
| Workflow state + history | `NexusRun` (status · cursor · error) + ordered `NexusStep[]`, `@@unique([run_id, idx])` | `schema.prisma` |
| Step execution gate | `advance()` — acts only from `PENDING`/`RUNNING`, at the exact cursor | `nexus.service.ts` |
| **Saga compensation** | `fail()` — every already-`DONE` step that declares a compensation has it **dispatched** in reverse order, and only then is it `COMPENSATED`. A compensation that cannot run leaves its step `FAILED` and ends the run `FAILED`, naming what was left behind | `nexus.service.ts` |
| Human-in-the-loop | A U2A payment step **halts** at `AWAITING_PAYMENT`. The engine never fakes a payment (Invariant #8 / §6) | `nexus.service.ts` |
| Resume after the human acts | `payment.completed.v1` consumer reads `metadata.nexusRunId` → `resumeByPayment`, state-guarded and idempotent | `nexus.consumer.ts` |
| Owner scope (P6) | Every read and write is scoped to the session identity; another owner's run is 403 | `nexus.service.ts` |

### The bottleneck this section used to name — CLOSED (2026-09-13)

This section previously read: *"the engine advances its own state. It does not call any
service… there is no external side effect."* That was true, and it was the platform's
single largest gap. It is closed, in three merged increments.

| Increment | What changed | PR |
|---|---|---|
| **Dispatcher + refusal** | A step is DISPATCHED to its owning service (env-resolved host, `x-internal-key`, original-actor headers, bounded timeout, typed outcome, never throws). A step with no callable target is **REFUSED** — it can no longer reach `DONE`. Compensations are dispatched too, and `COMPENSATED` is only reported when they actually ran. | tec-core-backend **#310** |
| **First real workflow** | `NexusRun.user_id` + commerce's internal renewability check → `subscription-renewal` runs end to end, with real Pi in the middle. | **#311** |
| **The remaining two** | `NexusRun.input` + `NexusStep.output` + `capture`, commerce `reserve`/`release`, asset `lock`/`unlock` → `checkout-saga` and `asset-transfer-saga` run. | **#312** |

> **The finding that mattered most.** The catalog said four endpoints were missing, and
> they were — but adding them alone would have changed nothing. A run carried **no
> parameters** (which products? which listing?) and no step could see what an earlier step
> produced (which order?). *You cannot reserve inventory for an order that does not exist.*
> The gap was an engine capability wearing an endpoint's clothes, and only building it
> showed that.

```prisma
service String // owning service that executes it   ← was: "that WOULD execute it"
```

### Two corrections the build forced into the catalog

1. **Both sagas ended with a second payment step** ("Complete the payment"). U2A
   create → approve → complete is **one** user action and payment-service's outbox owns
   the rest, so that step modelled a payment nobody would ever be asked to make — the run
   would have halted at `AWAITING_PAYMENT` forever. Removed; a test now pins **exactly one
   payment step per template**.

2. **"Cancel the payment" as a compensation is FORBIDDEN, not merely unimplemented.**
   `completed` is terminal (Invariant #7) and transitioning out of it is Forbidden
   Behavior #9. The reversal is an **A2U refund** — a new payment, owned by
   payment-service. So a payment step declares its compensation with **no callable**, and
   a run that fails after the money moved ends **FAILED**, naming the payment that stands.
   A person then decides what happens next.

   > `COMPENSATED` means *"no partial state is left"*. Claiming it over a payment that
   > actually moved is worse than FAILED: FAILED sends a human to look, COMPENSATED tells
   > them not to bother. It would be a lie about money.

**Still `[Future Vision]`:** parallel workflows, conditional branching beyond the linear
cursor, AI-agent workflows, and merchant-authored templates.

**Honest status:** `[Code Verified]`, not `[Runtime Verified]`. The chain fires when
`tec-identity-service` has its schema pushed and redeployed, the four services hold each
other's `*_SERVICE_URL` + `INTERNAL_SECRET`, and a real run is driven end to end.

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

Reduce the cost of coordination between multiple parties.

- Without Nexus: every coordination needs manual intervention → friction → deals fall through
- With Nexus: complex economic workflows execute automatically → scale
- Economically: automation of coordination = more economic activity at the same headcount

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
