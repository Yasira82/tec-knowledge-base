# C-97 — Context Engine Constitution

> **Version:** v1.0
> **Truth State:** `[Speculation]`
> **Governance State:** `[Draft]`
> **Verification State:** `[Assumed]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Recommended]`
> **Commitment Level:** `[Exploratory]`

---

## Purpose

Define how TEC determines applicability — the bridge between Capability and Reasoning.

**C-94 defines:**
How institutional knowledge becomes executable capability.

**C-97 defines:**
How context determines whether and how a capability applies.

**C-92 defines:**
How institutions reason over verified capabilities.

---

## Constitutional Question

How does TEC determine what is applicable, for whom, when, and under what conditions?

---

## Core Constitutional Principle

```
Capability defines execution.
Context defines applicability.

A capability without context executes universally.
Universal execution without context = governance failure.

Context answers: Should this capability execute now?
Capability answers: How should it execute?
```

---

## Constitutional Rules

```
Capability without Context          = Universal Execution Risk
Context without Verification        = Unvalidated Applicability
Context without Governance          = Unauthorized Scope
Identity Context without SSO        = Fragmented Trust
Economic Context without Integrity  = Financial Risk
Governance Context without Authority = Unauthorized Action
Context Conflict without Resolution = System Inconsistency
```

---

## What C-97 Owns

| Asset | Description |
|-------|-------------|
| Context Engine | System that resolves current applicable context |
| Identity Context | Who is the actor? What is their verified identity? |
| Relationship Context | What institutional relationships apply? |
| Economic Context | What economic state applies to this actor? |
| Governance Context | What governance rules apply in this situation? |
| Runtime Context | What is the current operational state of the system? |
| App Context | Which app, which session, which flow? |

---

## Context Transformation Model

```
Request / Event
  ↓
Identity Resolution (Hub SSO — C-13)
  ↓
Relationship Resolution
  ↓
Economic State Resolution (wallet, tier, limits)
  ↓
Governance State Resolution (applicable rules)
  ↓
Runtime State Resolution (system health — C-92)
  ↓
Context Object
  ↓
Capability Selection (C-94)
  ↓
Reasoning (C-92)
```

---

## Context Domains

### Identity Context

> **Question:** Who is this actor, and what is their verified institutional identity?

Sources:
- Hub SSO (C-13)
- Pi Network identity (C-63)
- KYC status
- Role / authority level

Output: Verified identity with authority scope.

---

### Relationship Context

> **Question:** What institutional relationships apply to this actor?

Sources:
- Commerce relationships (merchant/consumer)
- Asset ownership
- Governance delegations
- Network position in Connection/Life apps

Output: Applicable relationship graph for this request.

---

### Economic Context

> **Question:** What economic constraints and state apply?

Sources:
- Wallet balance (C-71)
- Transaction limits
- Payment mode eligibility (C-12 Mode 1 vs Mode 2)
- Settlement state

Output: Economic applicability constraints.

---

### Governance Context

> **Question:** What governance rules govern this action?

Sources:
- ADRs (C-64)
- Institutional state (C-93)
- Active policies
- Authority boundaries (C-68)

Output: Applicable governance constraints.

---

### Runtime Context

> **Question:** Is the system in a state where this capability may execute?

Sources:
- Platform Health (C-92) — PHS score
- Circuit breaker state
- Degraded mode flags
- Active incidents (C-73)

Output: System readiness signal.

---

## Context and TEC AI

Context is the **primary input** to TEC AI reasoning.

TEC AI **may:**
- Consume context to select appropriate capabilities
- Adjust reasoning based on identity, economic, and governance context
- Explain why a capability was or was not applied given context
- Detect context anomalies

TEC AI **may NOT:**
- Bypass context requirements
- Override governance context
- Assume identity without verification
- Fabricate economic context

> AI reasoning quality is bounded by context quality.

---

## Context and Life, Connection, Explorer

These future apps are **heavily context-dependent**:

| App | Primary Context Dependency |
|-----|---------------------------|
| **Life** | Identity + Relationship + Economic context (personal record) |
| **Connection** | Relationship context (economic relationship graph) |
| **Explorer** | Economic + Governance context (discovery constraints) |

Without C-97, these apps would implement context resolution ad-hoc — creating fragmented, ungoverned applicability logic.

---

## Context and Governance

Context does not override governance.
Context *applies* governance.

Governance sets the rules.
Context determines which rules apply here and now.

---

## Context Conflict Resolution

When context signals conflict:

```
Identity Context > Relationship Context > Economic Context
(for authorization decisions)

Governance Context overrides all others
(for compliance decisions)

Runtime Context blocks all others
(when PHS < threshold — C-92)
```

---

## Tier-1 Constitutional Position

C-97 is a **required Tier-1 component** of the Institutional Operating Loop:

```
Capability (C-94)
  ↓
Context (C-97)   ← THIS DOCUMENT
  ↓
Reasoning (C-92)
```

Without C-97, there is no principled bridge between "what can be done" and "what should be done here."

---

## Architectural Conclusion

```
Capability defines what can be executed.
Context defines what should be executed — here, now, for this actor.

Context is not a filter on capability.
Context is the institutional lens through which
capability becomes appropriate action.

Without context, capability is ungoverned execution.
With context, capability becomes institutional intent.
```

---

## Related Documents

```
C-12  Dual-Mode Payment (economic context application)
C-13  Auth & SSO Architecture (identity context source)
C-47  Kernel Spec (governance context boundaries)
C-67  Source of Truth Matrix
C-71  Financial Integrity Spec (economic context rules)
C-92  Platform Health Model (runtime context source)
C-93  Institutional Verification Constitution
C-94  Governed Capability Constitution (capability input)
C-99  Institutional Governance Constitution (governance context rules)
```

---

*End of C-97 v1.0*
