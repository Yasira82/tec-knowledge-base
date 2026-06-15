---
name: knowledge-orchestrator
description: "When working on any TEC platform task — automatically load the right knowledge documents, route to the correct specialist skill, and enforce platform invariants before any action."
metadata:
  version: 1.0.0
  tier: CRITICAL
  domain: platform
  auto_activate: true
---

# TEC Knowledge Orchestrator

You are the conductor of the TEC Federated Platform knowledge system. Before any task, load the right context and route to the right specialist.

## Auto-Load Protocol (run on every session start)

```
1. ALWAYS load → knowledge-base/C-02___CURRENT_STATE_.md        (what's done, what's open)
2. ALWAYS load → knowledge-base/C-47___KERNEL_SPEC___PLATFORM_CONSTITUTION.md  (constraints)
3. On demand  → knowledge-base/C-57___MASTER_CONTENTS_INDEX.md  (navigation)
4. On demand  → knowledge-base/C-64___ADR_SYSTEM.md             (before any arch decision)
```

## Task → Knowledge Routing

| Task Type | Load First | Skill to Invoke |
|-----------|-----------|------------------|
| Bug / regression | C-02 + relevant ADR | `/diagnose` |
| New feature | C-47 + C-41 + C-64 | `/grill-with-docs` then `/tdd` |
| Payment change | C-76 (ADR-007) + C-71 | `payment-expert` skill |
| BFF route change | C-47 §5 + C-69 | `bff-patterns` skill |
| Auth change | C-01 + tec-auth CLAUDE.md | `/clean-code-guard` |
| UI/design change | tec-ui CLAUDE.md | `bff-patterns` + `/tdd` |
| Architecture decision | C-64 + C-47 | `platform-architect` skill |
| Security concern | C-47 P6 + C-78 | `security-reviewer` skill |
| Docs update | C-57 + Truth Framework | `/docs-guard` |
| Knowledge gap detected | C-57 master index | Create new C-document |
| Session ending | All open items | `/handoff` |

## Platform Invariants (check before EVERY action)

```
✓ P6 Fail Closed: when in doubt → DENY
✓ Wallet balance never negative
✓ Payment requires approval before completion
✓ Identity = ONE principal always
✓ Every financial action has audit trail
✓ Terminal states are FINAL
✓ No state mutation without ActorContext
✓ Events are immutable facts
✓ Each entity owned by ONE service
```

## Cross-Repo Orchestration Map

```
SSO change      → coordinate: tec-auth + all 4 apps
Payment URL     → coordinate: all 4 apps + C-76 ADR required
tec-ui version  → coordinate: ALL 4 apps simultaneously
Gateway change  → coordinate: tec-sdk first → then apps
Backend deploy  → tec-core-backend FIRST → tec-sdk → apps
```

## Knowledge Gap Detection

If a question arises that no C-document answers:
1. Note the gap
2. Propose new C-XX document
3. Use `templates/new-c-document/C-XX-TEMPLATE.md`
4. Invoke `/docs-guard` before committing

## Truth Framework (apply to every knowledge statement)

```
Truth State:     [Current State] | [Planned] | [Future Vision] | [Speculation]
Governance:      [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]
Verification:    [Code Verified] | [Runtime Verified] | [Documentation Verified] | [Assumed]
```
