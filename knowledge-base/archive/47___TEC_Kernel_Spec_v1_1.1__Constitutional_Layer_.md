> **⚠️ ARCHIVED — Historical Reference Only**
> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Status:** Superseded — the canonical, system-bound Kernel Spec is
> [`C-47_Kernel_Spec_Architecture_Binding.md`](../C-47_Kernel_Spec_Architecture_Binding.md).
> This file is the fuller "Authoritative Draft v1.1.1" retained for history.
> Do not cite as current state. Resolves the orphan flagged in C-02 / C-80.

---

# 🟦 TEC Kernel Spec v1.1.1

## 🧠 Platform Constitutional Layer

**Version:** 1.1.1
**Status:** Authoritative Draft
**Scope:** TEC Ecosystem (Frontend + SDK + Gateway + Services)
**History:** v1.0 (April 13) → v1.1 (April 14) → v1.1.1 (April 14)
**Changes in v1.1.1:** ServiceActor reclassified as platform actor, Principal definition refined, causationId added to event/command model, Sensitive vs Non-sensitive operations classification, exceptional payment paths, contract mismatch refinement, 3 wording improvements.

---

## 1. 🎯 Purpose

TEC Kernel Spec defines the constitutional rules of the platform.

It is not code.
It is not a service.
It is not an implementation.

> It is the single source of truth for all **platform-level** behavior decisions.

**Goals:**
- Eliminate rule duplication across layers
- Ensure consistent system behavior
- Define authoritative contracts for all services
- Standardize identity, wallet, payment, and event systems
- Prevent architectural drift

---

## 2. 📦 Scope

**Inside Kernel Spec:**
- Identity rules
- Wallet rules
- Payment lifecycle rules
- Permission model
- Event taxonomy
- Command model
- API/SDK contracts
- System invariants
- Forbidden behaviors
- Canonical entities
- Consistency guarantees
- Policy precedence
- Violation handling
- Sensitive operation classification

**Outside Kernel Spec:**
- UI implementation
- Database engine choice
- Framework selection (NestJS / Express)
- Infrastructure (Redis, Railway, etc.)

---

## 3. 🧠 Core Principles

**P1 — Single Source of Truth**
All rules exist in one canonical definition.

**P2 — No Rule Duplication**
No business rule is redefined differently across layers.

**P3 — Strict State Transitions**
All domain state changes must follow explicit lifecycle rules.

**P4 — Event-Driven Truth**
Events represent facts, not actions.

**P5 — Layer Responsibility Separation**
- SDK = contracts
- Gateway = orchestration
- Services = execution
- Kernel = definition

**P6 — Fail Closed**
> When contract validity, actor identity, permission scope, or state integrity is uncertain, the system must deny or halt the operation by default.

This is non-negotiable for a financial/identity-driven platform.

---

## 4. 🆔 Identity Rules

**Identity Definition:**
A user has exactly one canonical identity across the system.

**Identity Sources:**
- Pi Network Identity (external)
- TEC Identity (internal mapping layer)

**Rules:**
- Identity must always resolve to a single principal
- Session ≠ Identity (sessions are temporary)
- Identity cannot be mutated, only extended (metadata)

**Forbidden:**
- Multiple active identities per user session
- Cross-user session impersonation without explicit permission layer

---

## 4A. 📐 Canonical Entities

All services must use these entity definitions consistently. No service may redefine or extend them without Kernel Spec amendment.

| Entity | Owner | Description |
|--------|-------|-------------|
| `Principal` | auth | The canonical security subject resolved by the platform for any authenticated operation. Links to permission checks, actor context, and identity/session distinction. |
| `Identity` | identity | Persistent user profile linked to Pi Network ID |
| `Session` | auth | Temporary authenticated context (JWT + cookies) |
| `Wallet` | wallet | Pi wallet bound to exactly one Identity |
| `LedgerEntry` | wallet | Immutable record of every balance mutation |
| `Payment` | payment | Pi payment with strict lifecycle state machine |
| `Order` | commerce | Commercial transaction linked to Payment |
| `Subscription` | commerce | Recurring service access agreement |
| `Asset` | asset | Digital asset owned by an Identity |
| `Notification` | notification | Message delivered to an Identity |
| `ServiceActor` | platform | Internal authenticated system actor propagated by gateway/services. Not a domain-owned business entity. |
| `AdminActor` | auth | Privileged human operator with audit trail |

**Rules:**
- Every entity must have a unique ID (UUID v4)
- Every entity must have `createdAt` and `updatedAt` timestamps
- Cross-service entity references use ID only — never embedded objects
- Entity schema changes require Kernel Spec version bump
- `api-gateway` is never owner of business entities; it may only carry or validate context

---

## 5. 💰 Wallet Rules

**Wallet Ownership:**
- Each wallet is bound to a single identity
- Wallet is source of truth for balance

**Invariants:**
- Balance can never be negative
- Every balance mutation must have:
  - actor
  - reason
  - timestamp
  - correlationId

**Rules:**
- No direct balance mutation without ledger event
- Wallet state must be reconstructible from events (audit-safe design)

---

## 6. 💳 Payment Rules

**Lifecycle:**

```
created
  ├─> approved
  │     ├─> completed ✅
  │     ├─> failed ❌
  │     └─> cancelled 🚫
  ├─> failed ❌
  └─> cancelled 🚫
```

**Valid transitions:**
- `created` → `approved` | `failed` | `cancelled`
- `approved` → `completed` | `failed` | `cancelled`
- `completed` → (terminal — no further transitions)
- `failed` → (terminal — no further transitions)
- `cancelled` → (terminal — no further transitions)

**Rules:**
- Every payment must be idempotent
- No payment can bypass approval stage in normal flow
- Completion must be confirmed via trusted event (Pi or internal gateway)
- Reconciliation must run for incomplete states

**Exceptional/System Paths:**
> Any exceptional path that bypasses normal flow must be explicitly designated as a system-controlled recovery path and auditable under Kernel Spec.

**Guarantees:**
- Exactly-once logical processing (via idempotency keys)
- Eventual consistency with wallet update

**Forbidden:**
- Direct wallet update without payment event
- Skipping approval/completion flow
- Transitioning from terminal state (`completed`, `failed`, `cancelled`)
- Ad-hoc system recovery without audit trail

---

## 7. 🔐 Permission Model

**Actor Types:**
- User
- Service
- Admin
- System

**Rules:**
- Every sensitive operation must define:
  - actor type
  - permission scope
  - validation layer

**Enforcement Layers:**
- SDK: client-side constraints
- Gateway: access control validation
- Services: final enforcement

---

## 7A. 🎭 Actor Context Envelope

Every sensitive operation must carry a standardized actor context:

```typescript
interface ActorContext {
  actorId: string;          // UUID of the actor
  actorType: 'user' | 'service' | 'admin' | 'system';
  sessionId?: string;       // JWT session identifier
  serviceName?: string;     // For service-to-service calls
  correlationId: string;    // Request/flow trace across services
  causationId?: string;     // What command/event produced this operation
  ip?: string;              // Client IP (user-facing only)
  origin?: string;          // Request origin domain
  timestamp: string;        // ISO 8601
}
```

**Rules:**
- Every financial operation MUST include full ActorContext
- Every auth operation MUST include full ActorContext
- Read-only public endpoints MAY omit ActorContext
- ActorContext is propagated via headers across service boundaries
- Missing ActorContext on sensitive operation → reject (P6 Fail Closed)

---

## 7B. 🔒 Operation Sensitivity Classification

### Sensitive Operations (ActorContext REQUIRED, Fail Closed applies):
- Auth: login, logout, refresh, token issuance
- Wallet: deposit, withdraw, transfer, balance mutation
- Payment: create, approve, complete, cancel, fail
- KYC: state changes, document submission
- Asset: ownership transfer
- Admin: any admin action
- Identity: profile mutations

### Non-Sensitive Operations (ActorContext OPTIONAL):
- Health endpoints (`/health` on all services)
- Public metadata reads
- Static asset serving
- Documentation endpoints
- Analytics read-only dashboards (public)

**Rule:**
> If an operation is not explicitly listed as non-sensitive, it is sensitive by default (P6).

---

## 8. 📡 Event Taxonomy

**Event Definition:**
An event is a **fact** that has already happened.

**Naming Convention:**
`domain.action.version`

**Examples:**
- `payment.completed.v1`
- `wallet.updated.v1`
- `auth.login.success.v1`

**Rules:**
- Events are immutable
- Events must include: eventId, timestamp, actor, correlationId, causationId

**Delivery Guarantees:**
- At-least-once delivery
- Idempotent consumers required

---

## 8A. 📨 Command Model

**Command Definition:**
A command is an **intent/request** — it may be accepted or rejected.

**Naming Convention:**
`VerbNoun` (imperative)

**Examples:**
- `ApprovePayment` → produces `payment.approved.v1`
- `DebitWallet` → produces `wallet.debited.v1`

---

## 9. 📑 Contract Model (SDK + APIs)

**Rules:**
- SDK must reflect Kernel Spec exactly
- SDK must never diverge from backend contracts
- Public application integration SHOULD occur through the SDK surface by default

---

## 10. ⚖️ System Invariants

1. Wallet balance cannot go negative
2. Payment cannot complete without approval
3. Identity must always resolve to one principal
4. Every financial action must have audit trail
5. Events must be immutable
6. No state mutation without actor context
7. Terminal states are final — no transitions from completed/failed/cancelled
8. Every entity has a single owner service
9. Non-sensitive classification does not exempt from logging

---

## 10A. 🔄 Consistency Model

| Domain | Consistency Level | Reason |
|--------|------------------|--------|
| Identity reads | **Strong** | Must always resolve to correct principal |
| Wallet balance (write path) | **Strong** | Financial accuracy |
| Wallet balance (read path) | **Strong** | User must see accurate balance |
| Payment state transitions | **Strong** | State machine integrity |
| Notifications | **Eventual** | Delivery delay acceptable |
| Analytics | **Eventual** | Aggregation tolerates lag |
| Commerce projections | **Eventual** | Cross-service data joins |
| Asset metadata | **Eventual** | Non-financial, read-heavy |

---

## 11. ⛔ Forbidden Behaviors

1. Direct DB mutation bypassing service layer
2. Payment completion without event verification
3. Cross-service shared database logic
4. Business logic inside API Gateway
5. Divergent SDK contracts vs backend behavior
6. Silent failure in financial flows
7. Reading another user's wallet/payment without authorization
8. Accepting operations with missing ActorContext on sensitive paths
9. Transitioning from terminal payment states
10. Ad-hoc system recovery without audit trail

---

## 12A. 🏛️ Policy Precedence

```
1. Kernel Invariants          (highest authority)
2. Service Final Enforcement
3. Gateway Access Policy
4. SDK Pre-validation
5. UI Assumptions             (lowest authority)
```

> **No upstream layer may weaken a downstream invariant.**

---

## 🧠 Final Architectural Statement

> TEC Kernel Spec is the constitutional source of truth for the ecosystem.
> It defines all system rules, state transitions, permissions, and event contracts.
> It is enforced consistently across SDK, Gateway, and domain services.
> When in doubt, fail closed. When in conflict, higher authority wins.
> No upstream layer may weaken a downstream invariant.
