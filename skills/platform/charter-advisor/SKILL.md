---
name: charter-advisor
description: "When working on any app within the TEC ecosystem — before modifying code, architecture, or CLAUDE.md — load the app's Institutional Charter (C-100→C-115 infra apps + C-124→C-131 user-layer apps) to understand its engineering authority, security model, and P0/P1/P2 gaps."
metadata:
  version: 1.0.0
  tier: CRITICAL
  domain: governance
---

# TEC Charter Advisor

Before modifying any TEC app, consult its Institutional Charter. Charter > CLAUDE.md > Code.

## Authority Rule

```
C-00  Platform Constitution       ← supreme
  ↓
C-67  Source of Truth Matrix
  ↓
ADRs  (C-64: ADR-001→ADR-007)
  ↓
App Institutional Charter (C-100→C-115 + C-124→C-131)   ← must read FIRST per app
  ↓
App CLAUDE.md
  ↓
Code
```

**If Charter conflicts with CLAUDE.md → Charter wins.**
**If CLAUDE.md conflicts with Code → CLAUDE.md wins.**

---

## Charter Registry

> **Deployed** column = the fleet SSoT (`architecture/app-fleet.yaml`): 🟢 Live ·
> 🟡 Live · financial mechanics gated · ⚪ Planned (not deployed). Each charter's
> **header** still declares the *full runtime* Truth State (mostly `[Future Vision]`);
> its **`## Deployment Status`** section is the live V0/V1 (`[Runtime Verified]`).

| Charter | App | System Role | Deployed |
|---------|-----|-------------|----------|
| [C-100](../../../knowledge-base/C-100___HUB_INSTITUTIONAL_CHARTER.md) | Hub | System of Access — Control Plane | 🟢 Live |
| [C-101](../../../knowledge-base/C-101___COMMERCE_INSTITUTIONAL_CHARTER.md) | Commerce | System of Production (Reference Impl) | 🟢 Live |
| [C-102](../../../knowledge-base/C-102___ASSETS_INSTITUTIONAL_CHARTER.md) | Assets | Digital Asset Infrastructure | 🟢 Live |
| [C-103](../../../knowledge-base/C-103___ECOMMERCE_INSTITUTIONAL_CHARTER.md) | Ecommerce | Consumer Marketplace | 🟢 Live |
| [C-104](../../../knowledge-base/C-104___TEC_AI_INSTITUTIONAL_CHARTER.md) | TEC AI | System of Reasoning | ⚪ Planned (`[Planned State]`) |
| [C-105](../../../knowledge-base/C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md) | Analytics | System of Intelligence | 🟢 Live |
| [C-106](../../../knowledge-base/C-106___LIFE_INSTITUTIONAL_CHARTER.md) | Life | System of Record (Personal) | 🟢 Live |
| [C-107](../../../knowledge-base/C-107___CONNECTION_INSTITUTIONAL_CHARTER.md) | Connection | Economic Relationship Infrastructure | 🟢 Live |
| [C-108](../../../knowledge-base/C-108___EXPLORER_INSTITUTIONAL_CHARTER.md) | Explorer | Economic Discovery Infrastructure | 🟢 Live |
| [C-109](../../../knowledge-base/C-109___NEXUS_INSTITUTIONAL_CHARTER.md) | Nexus | System of Coordination | 🟢 Live |
| [C-110](../../../knowledge-base/C-110___SYSTEM_INSTITUTIONAL_CHARTER.md) | SYSTEM | System of Governance | 🟢 Live |
| [C-111](../../../knowledge-base/C-111___ALERT_INSTITUTIONAL_CHARTER.md) | ALERT | Notification Hub / System of Risk | 🟢 Live |
| [C-112](../../../knowledge-base/C-112___NX_INSTITUTIONAL_CHARTER.md) | NX | Opportunity Exchange (repurposed, ADR-010) | 🟢 Live |
| [C-113](../../../knowledge-base/C-113___FUNDX_INSTITUTIONAL_CHARTER.md) | FundX | Capital Coordination Infrastructure | 🟡 Live · pools gated |
| [C-114](../../../knowledge-base/C-114___ESTATE_INSTITUTIONAL_CHARTER.md) | Estate | Real Estate Coordination | 🟢 Live |
| [C-115](../../../knowledge-base/C-115___DX_INSTITUTIONAL_CHARTER.md) | DX | Developer Platform / System of Construction | 🟢 Live |
| [C-124](../../../knowledge-base/C-124___NBF_BUSINESS_FOUNDATION_RUNTIME.md) | NBF | Business Foundation Runtime | 🟢 Live |
| [C-125](../../../knowledge-base/C-125___EPIC_CREATION_RUNTIME.md) | Epic | Creation Runtime | 🟢 Live |
| [C-126](../../../knowledge-base/C-126___LEGEND_REPUTATION_RUNTIME.md) | Legend | Reputation Runtime | 🟢 Live |
| [C-127](../../../knowledge-base/C-127___ELITE_EXCELLENCE_RUNTIME.md) | Elite | Excellence Runtime | 🟢 Live |
| [C-128](../../../knowledge-base/C-128___VIP_PREMIUM_EXPERIENCE_RUNTIME.md) | VIP | Premium Experience Runtime | 🟢 Live |
| [C-129](../../../knowledge-base/C-129___INSURE_RISK_PROTECTION_RUNTIME.md) | Insure | Risk Protection Runtime | 🟡 Live · escrow gated |
| [C-130](../../../knowledge-base/C-130___TITAN_ENTERPRISE_OS_RUNTIME.md) | Titan | Enterprise OS Runtime | 🟢 Live |
| [C-131](../../../knowledge-base/C-131___BROOKFIELD_INFRASTRUCTURE_RUNTIME.md) | Brookfield | Infrastructure Runtime | 🟡 Live · investment/REITs gated |

---

## Economic Runtime Lifecycle

Every charter must map its app to a stage in this cycle:

```
Settlement → Record → Reasoning → Access → Construction → Production → Economic Activity → Settlement
    ↑                                                                                           |
    └───────────────────────────────────────────────────────────────────────────────────────────┘

Hub        → System of Access
Commerce   → System of Production (reference implementation)
Assets     → Digital Asset Infrastructure
Ecommerce  → Consumer Marketplace → Economic Activity
Analytics  → System of Intelligence → feeds Reasoning
Life       → System of Record → Settlement (personal)
TEC AI     → System of Reasoning
Nexus      → System of Coordination → connects all layers
```

---

## Charter Load Protocol

When working on any TEC app — load the charter FIRST:

### Step 1 — Identify the app
```
Hub / tec-app           → C-100
Commerce / tec-commerce → C-101
Assets / tec-assets     → C-102
Ecommerce / tec-ecommerce → C-103
TEC AI                  → C-104
Analytics               → C-105
Life                    → C-106
Connection              → C-107
Explorer                → C-108
Nexus                   → C-109
SYSTEM                  → C-110
ALERT                   → C-111
NX (Opportunity Exchange, ADR-010) → C-112
FundX                   → C-113
Estate                  → C-114
DX                      → C-115
NBF / tec-nbf           → C-124
Epic / tec-epic         → C-125
Legend / tec-legend     → C-126
Elite / tec-elite       → C-127
VIP / tec-vip           → C-128
Insure / tec-insure     → C-129
Titan / tec-titan       → C-130
Brookfield / tec-brookfield → C-131
```

### Step 2 — Read Charter sections
Every charter contains:
1. **Mission** — what this app does + economic function
2. **Authority Boundary** — what this app owns vs what it consumes from platform
3. **Technical Architecture** — stack, services, integration map
4. **Security Model** — authentication, session, Pi payment mode
5. **Engineering Updates Required** — P0/P1/P2 gaps (most important for Phase 0)
6. **Integration Map** — cross-charter dependencies

### Step 3 — Check P0/P1/P2 gaps before implementing
Never implement a feature in a charter-covered app without first reading its **Engineering Updates Required** section. Adding a feature that conflicts with a P0 gap is a platform violation.

---

## Phase 0 Apps — Critical Engineering Gaps

### Hub (C-100) — System of Access
```
P0: INTERNAL_SECRET must be set on Railway (NEW-B — ops task)
P1: BFF-first rule — all wallet/payment fetches via /api/bff/*
P1: PAL (Pi Abstraction Layer) — PiRuntime.* replaces window.Pi.*
P2: Hub analytics dashboard
```

### Commerce (C-101) — Reference Implementation
```
P0: Merchant identity ALWAYS from tec_user cookie — never from request body
P1: Tests ≥ 60% (all BFF routes + payment handler)
P1: ADR-007 guard on every payment button
P2: Analytics integration with tec-analytics-service
```

### Assets (C-102) — Digital Asset Infrastructure
```
P0: Asset ownership ALWAYS from tec-asset-service — never derive client-side
P1: Tests ≥ 60%
P1: ADR-007 guard before every Pi payment
P2: Creator identity tied to Pi username from tec_user cookie
```

### Ecommerce (C-103) — Consumer Marketplace
```
P0: isHubNavigation() in 4 files — DO NOT REMOVE
P1: Tests ≥ 60% (useCart + BFF routes + payment handlers)
P1: PI_SANDBOX=false verified in production
P2: Pi App ID documented
```

---

## Charter vs App Conflict Resolution

When a charter and the app's CLAUDE.md disagree:

| Scenario | Resolution |
|----------|------------|
| Charter says "payment via Mode 1 only" but CLAUDE.md allows Mode 2 | Charter wins — update CLAUDE.md |
| CLAUDE.md has new pattern not in charter | Check if it violates charter authority boundary. If not → fine. If yes → update charter first |
| Charter says P0 gap exists but code already fixed it | Update charter Truth State + Engineering Updates section |
| Charter defines a phase (e.g., Phase 2) for a feature | Do NOT implement in Phase 0 — charter gates apply |

---

## Adding a New Charter

When a new app needs a charter:

1. Copy `templates/new-charter/` scaffold
2. Declare Truth State: `[Future Vision]` for new apps
3. Define System Role (must map to Economic Runtime Lifecycle)
4. Define Authority Boundary (what does this app OWN vs CONSUME)
5. Define Security Model (auth pattern + payment mode)
6. Add to C-57 Master Index (TIER 8)
7. Add to C-100→C-115 registry in PLATFORM_ARCHITECTURE.md Section 17
8. Update C-02 Current State

---

## Updating an Existing Charter

Required when:
- App ships a major feature
- Truth State transitions (e.g., `[Planned State]` → `[Current State]`)
- P0/P1/P2 gaps get resolved
- Engineering stack changes

Protocol:
1. Update charter Engineering Updates section
2. Update Truth State header if applicable
3. Update C-02 Current State
4. Commit with message: `docs(charter): C-1XX — [app name] [change summary]`

---

## Cross-Charter Dependency Map

```
Hub (C-100) — SSO authority for all apps
  ├── Commerce (C-101)  — reads Hub SSO cookies
  ├── Assets (C-102)    — reads Hub SSO cookies
  └── Ecommerce (C-103) — reads Hub SSO cookies

tec-core-backend → provides runtime to all 4 current apps
tec-ui           → shared design system for all 4 current apps
tec-auth         → auth package consumed by all 4 current apps
tec-sdk          → BFF SDK consumed by all 4 current apps

TEC AI (C-104) → will consume: Hub SSO + Analytics data
Analytics (C-105) → will consume: events from ALL apps
Life (C-106)    → will consume: Hub SSO + Payment history
Connection (C-107) → will consume: Life data + Analytics
Explorer (C-108) → will consume: Commerce data + Location
```

---

## Key Knowledge Base References

| Document | What It Tells You |
|----------|-------------------|
| C-00 | Platform Constitution — supreme authority |
| C-47 | Kernel Spec — P6 Fail Closed + 10 Forbidden behaviors |
| C-67 | Source of Truth Matrix — authority hierarchy |
| C-57 | Master Index — find any document |
| C-76 | ADR-007 — Pi payment ownership (Mode 1 vs 2) |
| C-64 | ADR system (ADR-001→ADR-007) |
| C-68 | Domain Ownership Matrix |
| C-71 | Financial Integrity Spec (DECIMAL(20,8)) |

---

## Checklist Before Modifying Any App

```
□ Read the app's Institutional Charter (C-100→C-115 + C-124→C-131)
□ Check Engineering Updates — are there P0/P1 gaps blocking this work?
□ Verify the change doesn't violate the Charter's Authority Boundary
□ Check Truth State — is this feature in scope for current phase?
□ Verify ADR-007 guard is present if touching any payment handler
□ Check cross-charter dependencies — does this affect other apps?
□ After implementing: update charter if Truth State or gaps changed
```
