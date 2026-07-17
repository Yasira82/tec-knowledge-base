# TEC Knowledge Base

> **TEC — Pi-Native Economic Coordination Infrastructure**
> "24 Apps. One Identity. One Wallet. One World."

[![Platform](https://img.shields.io/badge/Platform-Pi%20Network%20MAINNET-6d28d9?style=flat-square)](https://minepi.com)
[![Status](https://img.shields.io/badge/Status-24%20Apps%20Mainnet-22c55e?style=flat-square)](#)
[![Apps](https://img.shields.io/badge/Live%20Apps-24-22c55e?style=flat-square)](#)
[![Services](https://img.shields.io/badge/Railway%20Services-12-3b82f6?style=flat-square)](#)
[![KB](https://img.shields.io/badge/KB%20Contents-112-8b5cf6?style=flat-square)](#)
[![Version](https://img.shields.io/badge/KB%20Version-v3.10.0-10b981?style=flat-square)](#)

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
├── CLAUDE.md                          ← AI assistant navigation index (v3.10.0)
│
├── knowledge-base/                    ← 112 platform knowledge contents (C-00 → C-131)
│   ├── C-00_*.md                      ← Platform Constitution (highest authority)
│   ├── C-01 → C-99                   ← Architecture, Engineering, Governance, Institutional Operating Loop
│   ├── C-100 → C-131                 ← App and user-layer institutional charters
│   └── C-57___MASTER_CONTENTS_INDEX.md ← Complete index of all 112 contents
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
| [C-57 Master Index](knowledge-base/C-57___MASTER_CONTENTS_INDEX.md) | All 112 contents indexed with quick lookup |
| [C-93 Institutional Verification Constitution](knowledge-base/C-93___INSTITUTIONAL_VERIFICATION_CONSTITUTION.md) | How reality becomes verified institutional state (Tier-1) |
| [C-94 Governed Capability Constitution](knowledge-base/C-94___GOVERNED_CAPABILITY_CONSTITUTION.md) | How knowledge becomes executable capability (Tier-1) |
| [C-95 Institutional Knowledge Constitution](knowledge-base/C-95___INSTITUTIONAL_KNOWLEDGE_CONSTITUTION.md) | How institutional state becomes knowledge (Tier-1) |
| [C-96 Platform Runtime & Observability Constitution](knowledge-base/C-96___PLATFORM_RUNTIME_CONSTITUTION.md) | Health · Runtime Evidence · Visibility · 499 Incident Analysis — Code Verified |
| [C-97 Context Constitution](knowledge-base/C-97___CONTEXT_CONSTITUTION.md) | How capability becomes applicable action (Tier-1) |
| [C-99 Institutional Governance Constitution](knowledge-base/C-99___INSTITUTIONAL_GOVERNANCE_CONSTITUTION.md) | How authority becomes governance — closes the loop (Tier-1) |
| [C-80 Engineering Assessment](knowledge-base/C-80___ENGINEERING_ASSESSMENT_REPORT.md) | Gap analysis + remediation plan (June 2026) |

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

### Live on Mainnet

All **24 apps** are registered, deployed, and process real Pi on their
Pro/subscription surfaces. The canonical app IDs are in [C-01 §4](knowledge-base/C-01_Project_Identity.md);
the machine-readable fleet source is [`architecture/app-fleet.yaml`](architecture/app-fleet.yaml).
FundX pools, Insure escrow, and Brookfield investment/REIT mechanics remain read-only
and hard-gated; a live subscription is not custody readiness.

### Backend Services (Railway — 12 Active)

```
Gateway :3000  │  Auth    :5001  │  Wallet   :5002  │  Payment :5003
Identity:5004  │  Commerce:5005  │  Storage  :5006  │  Notify  :5007
KYC     :5008  │  Asset   :5009  │  Realtime :5010  │  Analytics:5011
```

> **Port Authority:** C-20 Backend Services Map (Code Verified)

### Release Chain

```
tec-core-backend  →  tec-sdk  →  tec-auth  →  tec-ui  →  [fleet apps]
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


## Registry Integrity (NEW in v3.6.0)

The Asset Registry is now **auto-generated** from file headers and **semantically validated** by CI. v1.0 (manual) had 17% semantic error rate; v2.0 (auto-generated) eliminates drift.

### Three governed assets

| Asset | Path | Role |
|-------|------|------|
| **Asset Registry** (auto-generated) | `architecture/asset-registry.yaml` | 112 C-docs + tier + truth_state + depends_on — DO NOT EDIT MANUALLY |
| **Integrity Rules** | `architecture/registry-integrity-rules.yaml` | 28 rules across 7 categories (schema, semantic, structural, governance, lifecycle, audit, coverage) |
| **Registry Integrity Engine** | `evals/check-registry-integrity.sh` | CI gate: validates registry against rules + against actual files |

### New CI gate

| Check | Severity | Rule |
|-------|----------|------|
| `evals/check-registry-integrity.sh` | **BLOCKING** | Registry MUST be auto-generated + semantically accurate + 100% coverage |

### Usage

```bash
# Auto-generate the registry from file headers (run after every C-doc edit)
python3 scripts/build-asset-registry.py

# Validate the registry
bash evals/check-registry-integrity.sh

# Analyze the blast radius of changing any document
python3 scripts/registry-impact-analysis.py C-67
```

See `knowledge-base/C-117___REGISTRY_INTEGRITY_CONSTITUTION.md` for the full constitution.

---


## Verification Authority Matrix (v3.6.1 — RESTORED)

The VAM defines **who can verify what, using which policy, at what confidence level**. Restored from v3.5.0 and now enforced by CI.

| Asset | Path | Role |
|-------|------|------|
| **VAM Manifest** | `manifests/verification-authority-matrix.yaml` | 7 verification tiers + 7 verification policies + per-tier requirements |
| **VAM Compliance Engine** | `evals/check-vam-compliance.sh` | CI gate: validates every current-state asset's verification_state against VAM requirements |

### Usage

```bash
# Validate VAM compliance
bash evals/check-vam-compliance.sh
```

See `manifests/verification-authority-matrix.yaml` for the full matrix.

---


## Dependency Propagation (NEW in v3.6.2)

The Dependency Propagation Runtime (DPR) automatically marks downstream documents as stale when an upstream document changes — closing the "Dependency Propagation Runtime" gap from v3.6.1.

| Asset | Path | Role |
|-------|------|------|
| **C-118 Constitution** | `knowledge-base/C-118___DEPENDENCY_PROPAGATION_CONSTITUTION.md` | Defines propagation rules + stale flag mechanism |
| **Propagation Engine** | `scripts/propagate-dependency.py` | Computes transitive closure of downstream dependents |
| **CDG Regenerator** | `scripts/regenerate-cdg.py` | Derives CDG from asset-registry (single source of truth) |

### v3.6.2 Engineering Fixes

| Fix | Impact |
|-----|--------|
| `depends_on` extraction moved from header (lines 1-30) to body (lines 30-200) | Eliminates 22 cycle errors |
| DAG-guarantee filter (only refs to HIGHER-authority docs) | Eliminates ALL V1_AUTHORITY_INVERSION + V6_CYCLE_DETECTED |
| C-01 moved to tier-1 (was tier-2-experimental — wrong) | Fixes R-GOV-008 violation |
| C-79 moved to tier-2 (was tier-1 — truth_state=speculation requires tier-2) | Fixes R-GOV-008 violation |
| `authoritative_for` claims prefixed with `c-NN-` for uniqueness | Eliminates ALL R-GOV-002 collisions |
| Generic headings excluded (Purpose, Scope, etc.) | Prevents claim collisions across docs |

### Usage

```bash
# Before editing C-93, see what will be affected
python3 scripts/propagate-dependency.py C-93

# Regenerate CDG from asset-registry (single source of truth)
python3 scripts/regenerate-cdg.py
```

See `knowledge-base/C-118___DEPENDENCY_PROPAGATION_CONSTITUTION.md` for the full constitution.

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
Session 18 — Mainnet Governance Baseline (v3.10.0):
  ✅ NEW-B: INTERNAL_SECRET set on Railway — all 4 services
  ✅ tec-ui v1.2.1 published — PaymentModal + createU2APayment + 80% tests
  ✅ All apps coverage ≥ 60%
  ✅ All P1 + P2 violations closed
  ✅ 16 App Institutional Charters (C-100→C-115)
  ✅ Truth Framework adoption 33% → 79% → 100% (auto-generated)  ← v3.5.0 + v3.6.0
  ✅ C-57 index drift corrected (31 descriptions fixed)            ← v3.5.0
  ✅ AHV Engine v1 + CDG manifest + Impact Analysis v1             ← v3.5.0
  ✅ C-116 Authority Automation Constitution                       ← v3.5.0
  ✅ LANGUAGE_POLICY.md + 90-Day Strategic Roadmap                 ← v3.5.0
  ✅ Asset Registry auto-generated (112/112 coverage)             ← v3.10.0
  ✅ R-SEMANTIC-001 catches institutional_role drift               ← v3.6.0
  ✅ C-117 Registry Integrity Constitution                         ← v3.6.0
  ✅ VAM restored + check-vam-compliance.sh (BLOCKING)            ← v3.6.1
  ✅ C-118 Dependency Propagation Constitution                    ← v3.6.2
  ✅ DAG-guaranteed depends_on (0 cycles + 0 inversions)           ← v3.6.2
  ✅ All 13 CI gates passing (0 errors)                            ← v3.10.0
  ✅ 28 rules across 7 categories (schema/semantic/structural/...) ← v3.6.0
  ✅ 24 apps registered and deployed on Mainnet; real-Pi subscription surfaces verified
  ⬜ External audit ≥ 9.5 and independently attributable production evidence
  ⬜ Deepen product capability one app at a time, preserving financial hard-gates
```

---

*Knowledge Base v3.10.0 — July 2026 (Session 18)*
*Authority: Yasser (CEO/Founder) | GitHub: Yasira82 | npm: @yasser172*
