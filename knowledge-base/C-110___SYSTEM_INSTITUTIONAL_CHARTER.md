# C-110 — SYSTEM INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Platform]
**Decision Status:** [Exploratory]

---

## 1. MISSION

Be the constitutional authority of the TEC ecosystem — defining, enforcing, and auditing the policies, rules, and activation logic that govern every actor and every system in the platform.

---

## 2. INSTITUTIONAL ROLE

```
System of Governance — Institutional Authority Layer
```

SYSTEM is the **Economic Constitution Runtime**. C-47 (Kernel Spec) defines the rules. SYSTEM enforces them at runtime. Without SYSTEM, the platform has rules on paper but no runtime enforcement.

---

## 3. ECONOMIC PURPOSE

ضمان شرعية وثقة كل عملية اقتصادية.

- بدون SYSTEM: rules موجودة لكن enforcement غير مضمون
- بوجود SYSTEM: كل actor في النظام يعمل ضمن حدود معتمدة
- اقتصادياً: governance legitimacy → user trust → platform premium → higher Pi utility

---

## 4. AUTHORITY BOUNDARY

### Owns
- Platform policy definitions and versioning
- Actor activation and deactivation authority
- Subscription tier capability gating
- Capability certification approval (C-94)
- Governance workflow execution
- Policy violation response (C-47 violation matrix)
- Admin actor management and audit trail
- **Security Governance — "Security Center" (ADR-010, July 2026):** threat detection,
  security audit, access logs, device management, and incident response — the runtime
  security functions folded in from the retired NX-Security domain. (This is a
  System-internal governance concern, NOT a standalone app. Security *alerts* are
  surfaced by Alert/C-111; *verification/trust* stays in Zone/C-120. If security
  becomes a standalone Pi-community product it gets its own new domain — never `NX`.)

### Does NOT Own
- Technical enforcement (each service self-enforces against policy)
- Business logic (domain services own their logic)
- Payment processing (tec-payment-service)
- Identity verification (tec-auth-service)
- AI reasoning (TEC AI — C-104)

### Interface Points
```
OUTBOUND:
  Policy Registry API   → All services query for applicable policies
  Capability Registry   → C-94 — approve/reject capabilities
  Activation signals    → All apps (feature gating per subscription tier)
  Violation alerts      → ALERT (C-111) + NX (C-112)

INBOUND:
  Violation reports     → Any service detecting a rule violation
  Policy update requests → Admin actors (CEO/founder) only
  Audit events          → All 12 services stream governance events
  ALERT risk signals    → C-111 — anomaly escalation
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Admin Backend: NestJS (tec-governance-service, new service)
  Policy Storage: PostgreSQL (policy definitions + version history)
  Policy Cache: Redis (hot policy lookup, TTL: 5min)
  Audit Log: append-only PostgreSQL table (immutable events)
  Admin UI: Next.js 15 (admin-only, not public-facing)

Policy Schema:
  { policyId, domain, rule, version, activeSince,
    supersedes?, enforcement: 'hard'|'soft', violationResponse }

Capability Registry (C-94):
  { capabilityId, type, owner, verificationStatus,
    governanceStatus: 'proposed'|'designed'|'verified'|'certified'|'deprecated',
    version, certifiedAt?, certifiedBy? }

Subscription Gating:
  FREE:         basic Hub, basic Commerce, basic Ecommerce
  PRO:          Hub PRO, advanced analytics, TEC AI basic
  ENTERPRISE:   all features + custom workflows + API access
  Feature flags: checked server-side in BFF routes (never client-side)

Admin Authorization:
  AdminActor: special actor type with elevated access
  All admin actions: 2-person approval for destructive operations
  Admin audit trail: immutable, retained forever
  Admin access: Yasser only (CEO authority — C-47 Decision Authority)
```

---

## 6. SECURITY MODEL

```
Highest Security Component in TEC:
  SYSTEM compromise = full platform governance failure
  Admin access: hardware key requirement (recommended)
  Policy changes: require admin authentication + audit log entry

Policy Enforcement:
  Services PULL policies on startup + cache with TTL
  Policy changes propagate within 5min (TTL expiry)
  Hard enforcement: service rejects non-compliant requests immediately
  Soft enforcement: service logs violation + continues (for legacy compat)

Violation Response (C-47 matrix):
  Invariant violation     → Reject + ALERT signal
  Unknown actor context   → Deny (P6 Fail Closed)
  Terminal state attempt  → Reject 409 + audit log
  Contract mismatch       → Fail closed 500 + ALERT

Admin Audit:
  Every policy change: who, what, when, why (required justification)
  Policy rollback: always possible (versioned, never deleted)
  Admin actions: retained forever (cannot be deleted)
```

---

## 7. REVENUE MODEL

**Indirect (Ecosystem Trust)**

| Channel | Mechanism | Value |
|---------|-----------|-------|
| Ecosystem Stability | Governance → trust → Pi utility premium | Platform-level |
| Subscription Gating | SYSTEM enforces PRO/ENTERPRISE feature access | Subscription revenue |
| Compliance Certification | External builders can be SYSTEM-certified | DX revenue (Phase 3) |

---

## 8. KEY METRICS

```
Policy Propagation Latency:  < 5min (from policy change to all services)
Violation Detection Rate:    ≥ 99% (known violation types)
Admin Audit Completeness:    100% (no unlogged admin action)
Capability Certification Time: < 48h for standard capabilities
Policy Version Conflicts:    0 (exactly one active policy per rule)
Subscription Gate Accuracy:  100% (no PRO features served to FREE users)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Constitutional Authority** — makes C-47 rules executable, not just documented
- **Trust Foundation** — users trust platform because governance is verifiable
- **Subscription Revenue Enabler** — feature gating only works with SYSTEM
- **Capability Governance** — certifies what TEC AI and DX can do

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Policy registry (basic rules from C-47)
  → Subscription gating (FREE/PRO/ENTERPRISE)
  → Admin audit trail

Phase 2:
  → Capability certification workflow (C-94)
  → Violation detection + ALERT integration
  → Governance dashboard for platform analytics

Phase 3:
  → Economic Constitution Runtime
  → External governance (Pi builders can apply SYSTEM policies)
  → DAO-like governance evolution (community input with admin authority)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Subscription Gating (Immediate Need)
  Hub /hub/subscription page exists but gating logic is NOT implemented.
  Free users can currently access PRO features.
  Must be built before charging for PRO subscriptions.

[P0-2] Admin Actor Definition
  tec-auth-service needs AdminActor type with:
  - separate authentication flow (stronger than user auth)
  - mandatory audit log on every admin action
  - no production admin access without 2-person approval
```

**P1:**
```
[P1-1] Policy Registry v1
  Start with the 10 Forbidden Behaviors from C-47 as machine-readable
  policies. Each policy: ID, rule text, enforcement type, violation response.

[P1-2] Capability Registry v1
  Implement C-94 capability lifecycle for first 5 capabilities:
  payment, authentication, asset-transfer, order-creation, analytics-query.
```

---

## 12. INTEGRATION MAP

```
This charter (C-110) depends on:
  C-47  KERNEL SPEC  → constitutional source of truth for all policies
  C-94  CAPABILITY REGISTRY → governance layer for capabilities
  C-111 ALERT        → violation signals from risk detection
  C-112 NX           → security violation signals

All other charters depend on this one for:
  Policy definitions and enforcement
  Subscription tier gating
  Capability certification
  Violation response authority
```
