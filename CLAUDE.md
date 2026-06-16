# TEC Knowledge Base

Centralized knowledge base for the TEC Federated Platform Ecosystem.

## Structure

```
knowledge-base/     # Platform knowledge (C-00 → C-99 + C-100→C-115)
governance/         # Platform governance documents
```

## Contents

| Range | Domain |
|-------|--------|
| C-00 | Platform Constitution |
| C-01–C-02 | Identity + Current State |
| C-10–C-16 | Architecture + Rules |
| C-20–C-23 | Backend + Apps + SDK |
| C-30–C-32 | Vision + App Blueprints |
| C-40–C-49 | Engineering + Violations + Roadmap |
| C-50–C-58 | Session + Patterns + Protocols |
| C-59–C-66 | Templates + Code + Guides |
| C-67–C-78 | Governance + Integrity + Operations |
| C-82–C-92 | Future Vision + Execution Governance |
| C-79 | Institutional Memory Constitution (Tier-2 Asset) |
| C-93–C-99 | Institutional Operating Loop Constitutions (Tier-1 + Tier-2) |
| C-80 | Engineering Assessment Report |
| C-100–C-115 | App Institutional Charters (Economic Infrastructure) |

## Governance

- `governance/TEC_GOVERNANCE_CHARTER_v1.2.md` — Platform governance charter

## Navigation

For full index → `knowledge-base/C-57___MASTER_CONTENTS_INDEX.md`

## Authority Hierarchy

C-00 → C-67 → ADRs (C-64) → Current State docs → Runtime Evidence → Code

## Truth Framework

Every architectural statement must declare:
- Truth State: [Current State] | [Planned State] | [Future Vision] | [Speculation]
- Governance State: [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]
- Verification: [Documentation Verified] | [Code Verified] | [Runtime Verified] | [Assumed]

## Version

Knowledge Base v3.4.0 | Governance Charter v1.2


---

## Skills

Available via plugin — invoke automatically when the situation matches:

| Situation | Skill |
|-----------|-------|
| Updating or reviewing any knowledge-base document | `/docs-guard` |
| Stress-testing an architectural decision against existing ADRs | `/grill-with-docs` |
| Converting a strategic discussion into a PRD | `/to-prd` |
| Breaking a roadmap item into GitHub Issues | `/to-issues` |
| Session is getting long or context is filling up | `/handoff` |
