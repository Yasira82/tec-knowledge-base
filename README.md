# TEC Knowledge Base

> **TEC — Pi-Native Economic Coordination Infrastructure**
> "24 Apps. One Identity. One Wallet. One World."

[![Platform](https://img.shields.io/badge/Platform-Pi%20Network%20MAINNET-6d28d9?style=flat-square)](https://minepi.com)
[![Status](https://img.shields.io/badge/Status-Phase%200%20→%20Audit-f59e0b?style=flat-square)](#)
[![Apps](https://img.shields.io/badge/Live%20Apps-4-22c55e?style=flat-square)](#)
[![Services](https://img.shields.io/badge/Railway%20Services-12-3b82f6?style=flat-square)](#)
[![KB](https://img.shields.io/badge/KB%20Contents-C--00%20→%20C--115-8b5cf6?style=flat-square)](#)
[![Version](https://img.shields.io/badge/KB%20Version-v3.2.0-10b981?style=flat-square)](#)

---

## What Is TEC?

TEC is a **federated Pi-native economic coordination platform** — not a super app, not a monolithic SaaS. It is a collection of sovereign apps sharing a unified identity, wallet, and payment infrastructure built on Pi Network.

```
Pi Network  (Blockchain + Settlement + Wallet)
     ↓
TEC Economic Coordination Infrastructure
     ↓
Pi-Native Applications, Businesses, Communities
```

The **real product** is not the apps. The real product is the **Economic Coordination Infrastructure** — the identity layer, payment rails, event system, and governance contracts that power all 24 apps.

**Economic Runtime Lifecycle:**
```
Settlement → Record → Reasoning → Access → Construction → Production → Economic Activity → Settlement
```

---

## Repository Structure

```
tec-knowledge-base/
├── README.md                          ← You are here
├── CLAUDE.md                          ← AI assistant navigation index (v3.2.0)
│
├── knowledge-base/                    ← 94 platform knowledge contents (C-00 → C-115)
│   ├── C-00_*.md                      ← Platform Constitution (highest authority)
│   ├── C-01 → C-94                   ← Architecture, Engineering, Governance, Institutional Constitutions
│   ├── C-100 → C-115                 ← App Institutional Charters
│   └── C-57___MASTER_CONTENTS_INDEX.md ← Complete index of all 94 contents
│
├── skills/                            ← 16 Claude Code skills
│   ├── platform/                      ← payment-expert, platform-architect, security-reviewer…
│   ├── engineering/                   ← bff-patterns, tec-testing
│   ├── design/                        ← tec-design-system, ui-patterns
│   └── marketing/                     ← pi-growth, content-strategy, community-marketing…
│
├── agents/                            ← 3 advisory agents
├── commands/                          ← 7 Claude Code commands
├── templates/                         ← Scaffolds: skill, ADR, C-document
├── evals/                             ← CI quality gates
├── memory/                            ← Persistent memory configuration
├── architecture/
│   └── PLATFORM_ARCHITECTURE.md      ← System architecture reference
└── governance/
    └── TEC_GOVERNANCE_CHARTER_v1.2.md ← Platform governance charter
```

---

## Quick Navigation

### Current State
| Document | Description |
|----------|-------------|
| [C-02 Current State](knowledge-base/C-02___CURRENT_STATE_.md) | Live platform state — score, violations, checklist |
| [C-77 Strategic Analysis](knowledge-base/C-77___STRATEGIC_ANALYSIS___RISK_ASSESSMENT.md) | Risk register, execution roadmap |
| [C-78 Operations](knowledge-base/C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md) | SLOs, incidents, reliability |
| [C-57 Master Index](knowledge-base/C-57___MASTER_CONTENTS_INDEX.md) | All 94 contents indexed with quick lookup |
| [C-93 Institutional Verification Constitution](knowledge-base/C-93___INSTITUTIONAL_VERIFICATION_CONSTITUTION.md) | How reality becomes verified institutional state (Tier-1) |
| [C-94 Engineering Assessment](knowledge-base/C-94___ENGINEERING_ASSESSMENT_REPORT.md) | Gap analysis + remediation plan (June 2026) |

### Architecture & Decisions
| Document | Description |
|----------|-------------|
| [C-00 Constitution](knowledge-base/C-00_v3.0___PLATFORM_CONSTITUTION___ENGINEERING_GOVERNANCE.md) | Platform constitution — highest authority |
| [C-47 Kernel Spec](knowledge-base/C-47_Kernel_Spec_Architecture_Binding.md) | P6 Fail Closed + 10 Forbidden behaviors |
| [C-64 ADR System](knowledge-base/C-64___ARCHITECTURE_DECISION_RECORDS.md) | All ADRs (ADR-001 → ADR-007) |
| [C-67 Source of Truth](knowledge-base/C-67___SOURCE_OF_TRUTH_MATRIX.md) | Authority hierarchy & conflict resolution |
| [Architecture](architecture/PLATFORM_ARCHITECTURE.md) | Full system architecture reference |

### Payment & Identity
| Document | Description |
|----------|-------------|
| [C-12 Dual-Mode Payment](knowledge-base/C-12_Dual_Mode_Payment.md) | Mode 1 (Hub redirect) + Mode 2 (direct) |
| [C-76 ADR-007](knowledge-base/C-76___ADR-007.md) | Pi Payment Ownership Authority — CRITICAL |
| [C-63 Pi Integration](knowledge-base/C-63___PI_NETWORK_INTEGRATION_RULES.md) | Pi SDK patterns & known behaviors |
| [C-71 Financial Integrity](knowledge-base/C-71___FINANCIAL_INTEGRITY_SPEC.md) | DECIMAL(20,8), atomic wallet ops |

### Engineering & Governance
| Document | Description |
|----------|-------------|
| [C-41 Engineering Roadmap](knowledge-base/C-41_Engineering_Roadmap.md) | Phase 0 → Phase 3 path |
| [C-43 CI/CD](knowledge-base/C-43_CI_CD_DevOps.md) | Pipeline, deploy gates |
| [C-75 Release Governance](knowledge-base/C-75___RELEASE_GOVERNANCE_SPEC.md) | Release gates, migration rules |
| [C-68 Domain Ownership](knowledge-base/C-68___DOMAIN_OWNERSHIP_MATRIX.md) | Single write authority per domain |

### App Institutional Charters (C-100→C-115)
| Charter | App | System Role |
|---------|-----|-------------|
| [C-100](knowledge-base/C-100___HUB_INSTITUTIONAL_CHARTER.md) | Hub | System of Access |
| [C-101](knowledge-base/C-101___COMMERCE_INSTITUTIONAL_CHARTER.md) | Commerce | System of Production (Reference Impl) |
| [C-102](knowledge-base/C-102___ASSETS_INSTITUTIONAL_CHARTER.md) | Assets | Digital Asset Infrastructure |
| [C-103](knowledge-base/C-103___ECOMMERCE_INSTITUTIONAL_CHARTER.md) | Ecommerce | Consumer Marketplace |
| [C-104](knowledge-base/C-104___TEC_AI_INSTITUTIONAL_CHARTER.md) | TEC AI | System of Reasoning |
| [C-105](knowledge-base/C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md) | Analytics | System of Intelligence |
| [C-106](knowledge-base/C-106___LIFE_INSTITUTIONAL_CHARTER.md) | Life | System of Record (Personal) |
| [C-107](knowledge-base/C-107___CONNECTION_INSTITUTIONAL_CHARTER.md) | Connection | Economic Relationship Infrastructure |
| [C-108](knowledge-base/C-108___EXPLORER_INSTITUTIONAL_CHARTER.md) | Explorer | Economic Discovery Infrastructure |
| [C-109](knowledge-base/C-109___NEXUS_INSTITUTIONAL_CHARTER.md) | Nexus | System of Coordination |
| [C-110](knowledge-base/C-110___SYSTEM_INSTITUTIONAL_CHARTER.md) | SYSTEM | System of Governance |
| [C-111](knowledge-base/C-111___ALERT_INSTITUTIONAL_CHARTER.md) | ALERT | System of Risk |
| [C-112](knowledge-base/C-112___NX_INSTITUTIONAL_CHARTER.md) | NX | System of Security |
| [C-113](knowledge-base/C-113___FUNDX_INSTITUTIONAL_CHARTER.md) | FundX | Capital Coordination Infrastructure |
| [C-114](knowledge-base/C-114___ESTATE_INSTITUTIONAL_CHARTER.md) | Estate | Real Estate Coordination |
| [C-115](knowledge-base/C-115___DX_INSTITUTIONAL_CHARTER.md) | DX | System of Construction |

### Future Vision
| Document | Description |
|----------|-------------|
| [C-83 EVL/ESL](knowledge-base/C-83___EVL_ESL.md) | Economic Visual/State Language |
| [C-84 Runtime Constitution](knowledge-base/C-84___RUNTIME_CONSTITUTION.md) | Runtime gates A→E |
| [C-85 Infrastructure Stack](knowledge-base/C-85___INFRASTRUCTURE_STACK.md) | Layer build sequence |
| [C-87 Execution Governance](knowledge-base/C-87___EXECUTION_GOVERNANCE.md) | Command lifecycle + execution authority |
| [C-91 Engineering to Scale](knowledge-base/C-91___ENGINEERING_ROADMAP_TO_SCALE.md) | Scale gates + infrastructure evolution |

---

## Platform at a Glance

### Live Now (Phase 0 → Audit)

| App | Role | Domain | Charter |
|-----|------|--------|---------|
| **Hub** | Control Plane / Conductor | hub.tecosystem.app | [C-100](knowledge-base/C-100___HUB_INSTITUTIONAL_CHARTER.md) |
| **Commerce** | Merchant Dashboard (Reference Impl) | tec-commerce-app.vercel.app | [C-101](knowledge-base/C-101___COMMERCE_INSTITUTIONAL_CHARTER.md) |
| **Assets** | Digital Ownership / NFTs | assets.tecosystem.app | [C-102](knowledge-base/C-102___ASSETS_INSTITUTIONAL_CHARTER.md) |
| **Ecommerce** | Consumer Marketplace | ecommerce.tecosystem.app | [C-103](knowledge-base/C-103___ECOMMERCE_INSTITUTIONAL_CHARTER.md) |

### Backend Services (Railway — 12 Active)

```
Gateway  :4000  │  Auth    :4001  │  Payment :4002  │  Commerce :4003
Identity :4004  │  KYC     :4005  │  Asset   :4006  │  Analytics:4007
Notify   :4008  │  Realtime:4009  │  Storage :4010  │  Wallet   :4011
```

### Release Chain

```
tec-core-backend  →  tec-sdk  →  tec-auth  →  tec-ui  →  [4 apps simultaneously]
    (deploy)           (npm)       (npm)        (npm)        (Vercel)
```

---

## Authority Hierarchy

When documents conflict — this hierarchy resolves it:

```
C-00  Platform Constitution          ← highest authority
  ↓
C-67  Source of Truth Matrix
  ↓
ADRs  (C-64: ADR-001 → ADR-007)
  ↓
C-77  Strategic Analysis + Risk
  ↓
Current-State Documents (C-02, C-78)
  ↓
App Institutional Charters (C-100→C-115)
  ↓
App CLAUDE.md files
  ↓
Runtime Evidence (live system behavior)
  ↓
Code (verified in context)
  ↓
Assumptions                          ← lowest authority
```

---

## Truth Framework

Every architectural statement must declare:

| Label | Meaning |
|-------|---------|
| `[Current State]` | Verified to exist now |
| `[Planned State]` | Committed — not yet implemented |
| `[Future Vision]` | Direction agreed — not committed |
| `[Speculation]` | Hypothesis — no governance approval |

**Never present Planned State as Current State.**

---

## Governing Principles

```
Reliability > Expansion
Governance > Velocity
Economic Integrity > UI Convenience
Runtime Stability > Architectural Cleverness

No Runtime Without Events
No Events Without Ownership
No Ownership Without Governance
No Charter Without Engineering Substance
```

---

## Phase Status

```
Phase 0 — Pre-Mainnet:
  ✅ NEW-B: INTERNAL_SECRET set on Railway — all 4 services
  ✅ tec-ui v1.2.1 published — PaymentModal + createU2APayment + 80% tests
  ✅ All apps coverage ≥ 60%
  ✅ All P1 + P2 violations closed
  ✅ 16 App Institutional Charters (C-100→C-115)
  ⬜ External audit ≥ 9.5 (pending — PRs #27 + #24 first)
  ⬜ Pi Developer Portal submission

Phase 1 — After Mainnet:
  ⬜ Life MVP
  ⬜ Analytics UI
  ⬜ Connection MVP
```

---

*Knowledge Base v3.2.0 — June 2026*
*Authority: Yasser (CEO/Founder) | GitHub: Yasira82 | npm: @yasser172*
