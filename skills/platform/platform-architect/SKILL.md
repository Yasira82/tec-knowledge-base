---
name: platform-architect
description: "When planning or reviewing any architectural decision on the TEC platform — validate against C-47 Kernel Spec, check existing ADRs, and enforce Platform Constitution before any implementation."
metadata:
  version: 1.0.0
  tier: CRITICAL
  domain: platform
---

# TEC Platform Architect

Guardian of the TEC Platform Constitution (C-47). No architectural decision passes without this validation.

## Pre-Decision Checklist

```
□ Does this break any System Invariant? (C-47 §3)
□ Does this violate any of the 10 Forbidden Behaviors? (C-47 §4)
□ Does this weaken a downstream invariant? (Policy Precedence — C-47 §6)
□ Is there an existing ADR that covers this? (C-64)
□ Which service OWNS the affected entity? (C-68 Domain Ownership)
□ Does this require a new ADR? (if yes → use templates/new-adr/)
□ What is the blast radius? (which repos are affected?)
```

## Policy Precedence (NEVER violate)

```
1. Kernel Invariants          ← supreme authority (C-47)
2. Service Final Enforcement  ← service says no → operation FAILS
3. Gateway Access Policy      ← gateway says no → DENY
4. SDK Pre-validation         ← contracts layer
5. UI Assumptions             ← weakest — cannot override upstream

Rule: upstream layer NEVER weakens downstream invariant.
```

## Architecture Binding Map (C-47 §12)

| Rule | Enforced At | Never Bypass |
|------|-------------|-------------|
| JWT verify() | Gateway + shared | Never use jwt.decode() |
| No localStorage tokens | Policy CI | HttpOnly cookies ONLY |
| DECIMAL(20,8) Pi amounts | DB schema | Never JS Number |
| balance >= 0 | DB constraint | Hard DB constraint |
| userId from session | Policy CI | Never from req.body |
| Payment state machine | payment-service | ALLOWED_TRANSITIONS only |
| Outbox pattern | payment-service | Never bypass outbox |
| BFF isolation | All frontends | /api/bff/* only |

## ADR Required Before

- Any change to `/hub?pay=1` URL pattern
- Any change to cookie names (tec_access_token, tec_csrf, tec_user)
- Any new inter-service communication pattern
- Any breaking API contract change
- Any new service or app added
- Any change to payment state machine

## Entity Ownership (Domain Ownership Matrix — C-68)

| Entity | Owner Service | Forbidden |
|--------|--------------|----------|
| Principal / Session | tec-auth-service | Other services validating Pi tokens |
| Wallet / LedgerEntry | wallet (via gateway) | Direct DB mutation |
| Payment | tec-payment-service | Commerce creating payments directly |
| Order | tec-commerce-service | Payment service owning orders |
| Asset | tec-asset-service | Client-side ownership derivation |

## Consistency Requirements

```
Identity reads        → STRONG (always)
Wallet balance write  → STRONG (always)
Wallet balance read   → STRONG (always)
Payment transitions   → STRONG (always)
Notifications         → EVENTUAL (ok)
Analytics             → EVENTUAL (ok)
Commerce projections  → EVENTUAL (ok)
```
