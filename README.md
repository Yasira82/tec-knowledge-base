# TEC Knowledge Base

> **TEC — Pi-Native Economic Coordination Infrastructure**
> "24 Apps. One Identity. One Wallet. One World."

[![Platform](https://img.shields.io/badge/Platform-Pi%20Network%20MAINNET-6d28d9?style=flat-square)](https://minepi.com)
[![Status](https://img.shields.io/badge/Status-Phase%200%20Hardening-f59e0b?style=flat-square)](#)
[![Apps](https://img.shields.io/badge/Live%20Apps-4-22c55e?style=flat-square)](#)
[![Services](https://img.shields.io/badge/Railway%20Services-12-3b82f6?style=flat-square)](#)
[![KB](https://img.shields.io/badge/KB%20Contents-C--00%20→%20C--86-8b5cf6?style=flat-square)](#)

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

---

## Repository Structure

```
tec-knowledge-base/
├── README.md                          ← You are here
├── CLAUDE.md                          ← AI assistant navigation index
│
├── knowledge-base/                    ← All 62 platform knowledge contents
│   ├── C-00.md                        ← Platform Constitution (highest authority)
│   ├── C-01.md → C-86.md             ← Full knowledge base
│   └── C-57___MASTER_CONTENTS_INDEX.md ← Complete index of all contents
│
├── architecture/
│   └── PLATFORM_ARCHITECTURE.md      ← System architecture reference
│
└── governance/
    └── TEC_GOVERNANCE_CHARTER_v1.1.md ← Platform governance charter
```

---

## Quick Navigation

### Current State
| Document | Description |
|----------|-------------|
| [C-02 Current State](knowledge-base/C-02___CURRENT_STATE_AND_VIOLATIONS.md) | Live platform state, open violations |
| [C-77 Strategic Analysis](knowledge-base/C-77___STRATEGIC_ANALYSIS___RISK_ASSESSMENT.md) | Risk register, execution roadmap |
| [C-78 Operations](knowledge-base/C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md) | SLOs, incidents, reliability |
| [C-82 Maturity](knowledge-base/C-82___PLATFORM_MATURITY_EVOLUTION.md) | PRI score (7.25/10), expansion gates |

### Architecture & Decisions
| Document | Description |
|----------|-------------|
| [C-00 Constitution](knowledge-base/C-00.md) | Platform constitution — highest authority |
| [C-64 ADR System](knowledge-base/C-64___ADR_SYSTEM.md) | All ADRs (ADR-001 → ADR-007) |
| [C-67 Source of Truth](knowledge-base/C-67___SOURCE_OF_TRUTH_MATRIX.md) | Authority hierarchy & conflict resolution |
| [C-68 Domain Ownership](knowledge-base/C-68___DOMAIN_OWNERSHIP_MATRIX.md) | Single write authority per domain |
| [Architecture Page](architecture/PLATFORM_ARCHITECTURE.md) | Full system architecture reference |

### Payment & Identity
| Document | Description |
|----------|-------------|
| [C-12 Dual-Mode Payment](knowledge-base/C-12___DUAL_MODE_PAYMENT.md) | Mode 1 (Hub redirect) + Mode 2 (direct) |
| [C-76 ADR-007](knowledge-base/C-76___ADR-007.md) | Pi Payment Ownership Authority — CRITICAL |
| [C-63 Pi Integration](knowledge-base/C-63___PI_NETWORK_INTEGRATION.md) | Pi SDK patterns & known behaviors |
| [C-71 Financial Integrity](knowledge-base/C-71___FINANCIAL_INTEGRITY_SPEC.md) | DECIMAL(20,8), atomic wallet ops |

### Engineering & Governance
| Document | Description |
|----------|-------------|
| [C-41 Engineering Roadmap](knowledge-base/C-41___ENGINEERING_ROADMAP.md) | Phase 0 → Phase 3 path |
| [C-43 CI/CD](knowledge-base/C-43___CI_CD_DEVOPS.md) | Pipeline, deploy gates |
| [C-75 Release Governance](knowledge-base/C-75___RELEASE_GOVERNANCE_SPEC.md) | Release gates, migration rules |
| [C-57 Master Index](knowledge-base/C-57___MASTER_CONTENTS_INDEX.md) | All 62 contents indexed |

### Future Vision
| Document | Description |
|----------|-------------|
| [C-83 EVL/ESL](knowledge-base/C-83___EVL_ESL.md) | Economic Visual/State Language |
| [C-84 Runtime Constitution](knowledge-base/C-84___RUNTIME_CONSTITUTION.md) | Runtime gates A→E |
| [C-85 Infrastructure Stack](knowledge-base/C-85___INFRASTRUCTURE_STACK.md) | Layer build sequence |
| [C-86 Temporal Governance](knowledge-base/C-86___TEMPORAL_GOVERNANCE.md) | Distributed temporal authority |

---

## Platform at a Glance

### Live Now (Phase 0)

| App | Role | Domain |
|-----|------|--------|
| **Hub** | Control Plane / Conductor | hub.tecosystem.app |
| **Commerce** | Merchant Dashboard (Reference Impl) | tecosystem.app/commerce |
| **Assets** | Digital Ownership / NFTs | tecosystem.app/assets |
| **Ecommerce** | Consumer Marketplace | tecosystem.app/shop |

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
Current-State Documents (C-02, C-78, C-82)
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
```

---

## Phase 0 — Current Priority

```
□ Fix NEW-B: INTERNAL_SECRET required on Railway (ops task)
□ tec-ui v1.2.0 publish
□ All apps tests ≥ 60%
□ External audit ≥ 9.5
□ Pi Developer Portal submission
```

---

*Knowledge Base v2.0 — June 2026*
*Authority: Yasser (CEO/Founder) | GitHub: Yasira82 | npm: @yasser172*
