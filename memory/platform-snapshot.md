# TEC Platform Snapshot
## Fast-Load Current State — Session Start Reference

> Load this file at session start for instant platform context.
> For full details → C-02___CURRENT_STATE_.md

**Snapshot Version:** v3.3.2 | **Last Updated:** 16 June 2026

---

## Platform Identity

```
TEC — Pi-Native Economic Coordination Infrastructure
"24 Apps. One Identity. One Wallet. One World."
Phase: 0 → Pre-Mainnet Hardening (→ Audit)
Score: Self ~8.5/10 | External target: 9.5/10
Pi SDK Mode: PI_SANDBOX=false (Mainnet)
```

---

## Live Apps (4)

| App | Domain | Charter | Status |
|-----|--------|---------|--------|
| Hub | hub.tecosystem.app | C-100 | ✅ Phase 0 |
| Commerce | tec-commerce-app.vercel.app | C-101 | ✅ Phase 0 |
| Assets | assets.tecosystem.app | C-102 | ✅ Phase 0 |
| Ecommerce | ecommerce.tecosystem.app | C-103 | ✅ Phase 0 |

---

## Pi App IDs

| App | Pi App ID |
|-----|----------|
| Hub | `tec-app-923b947851f9dfe1` |
| Commerce | `commerce-app-68aa99081fc1897a` |
| Assets | `assets-app-af2fb490e7b03db7` |
| Ecommerce | `ecommerce-app-71ca4d3e462eaf54` |

---

## Backend Services (Railway — 12 Active)

```
Gateway  :4000  │  Auth    :4001  │  Payment :4002  │  Commerce :4003
Identity :4004  │  KYC     :4005  │  Asset   :4006  │  Analytics:4007
Notify   :4008  │  Realtime:4009  │  Storage :4010  │  Wallet   :4011
```

INTERNAL_SECRET: ✅ Set on all 4 critical services (Railway)

---

## npm Packages

| Package | Version | Coverage |
|---------|---------|----------|
| @yasser172/tec-ui | v1.2.1 | 80% (75 tests) |
| @yasser172/tec-auth | latest | 95% stmt / 92.98% branch |
| @yasser172/tec-sdk | latest | — |
| tec-shared | latest | — |

---

## CI Status

| Repo | CI | Coverage |
|------|----|----------|
| Hub (tec-app) | ✅ GREEN (2026 tests — commit 275d6fd0) | ≥60% |
| Ecommerce | ✅ GREEN (commit 33d2d141) | ≥60% |
| Commerce | ✅ | ≥60% |
| Assets | ✅ | ≥60% |
| tec-auth | ✅ | 95% |
| tec-ui | ✅ | 80% |
| tec-knowledge-base | ✅ (validate-skills: 16/16, validate-charters: 16/16) | — |

---

## P1 Violations

| ID | Status | Note |
|----|--------|------|
| NEW-A | ✅ CLOSED | Railway URLs removed — BFF proxy in place |
| NEW-B | ⚠️ OPS ONLY | INTERNAL_SECRET — set on Railway (ops task) |
| NEW-D | ✅ CLOSED | tec-auth-service 95% coverage |
| NEW-J | ✅ CLOSED | Ecommerce cart shipped |
| NEW-K | ✅ CLOSED | Hub sub-pages (KYC, Subscription, Notifications, Profile) |
| NEW-L | ✅ CLOSED | useWallet → /api/bff/wallet/balance |

**Active violations: 1 (NEW-B — ops only, not code)**

---

## Pending PRs

| PR | Repo | Status |
|----|------|--------|
| #27 | tec-ecommerce | Pending merge → main |
| #24 | tec-app (Hub) | Pending merge → main |

---

## Knowledge Base

```
Version:    v3.2.0
Documents:  91 (C-00 → C-115)
Skills:     16 (platform:7, engineering:2, design:2, marketing:5)
Agents:     3 (cmo-advisor, growth-advisor, design-system-advisor)
Commands:   7
Charters:   16 (C-100→C-115)
```

---

## Authority Hierarchy (Quick Reference)

```
C-00  Platform Constitution
  ↓ C-67  Source of Truth Matrix
    ↓ ADRs  (C-64: ADR-001→ADR-007)
      ↓ C-77  Strategic Analysis + Risk
        ↓ Current-State Docs (C-02, C-78)
          ↓ App Charters (C-100→C-115)
            ↓ App CLAUDE.md files
              ↓ Runtime Evidence
                ↓ Code
                  ↓ Assumptions  ← lowest
```

---

## Critical Rules (Never Forget)

```
P6 Fail Closed:      doubt in identity/permission/state → DENY
ADR-007:             isHubNavigation() before EVERY Pi payment
BFF-first:           all client data → /api/bff/* (never /api/wallet/*)
INTERNAL_SECRET:     x-internal-key on all inter-service calls
No jwt.decode():     ALWAYS jwt.verify() — Policy CI enforces
No localStorage:     tokens in HttpOnly cookies ONLY
No body.userId:      identity ALWAYS from tec_user cookie
No NEXT_PUBLIC_*:    for internal service URLs (NEW-A pattern)
DECIMAL(20,8):       all Pi amounts in DB
balance >= 0:        DB constraint — wallet never negative
```

---

## Release Chain

```
tec-core-backend  →  tec-sdk  →  tec-auth  →  tec-ui  →  [4 apps simultaneously]
    (deploy)          (npm)       (npm)        (npm)        (Vercel)
```

---

## Next Actions (from C-02 Session 9)

```
1. External Re-Audit → target 8.5–9.0/10 (كل fixes على main ✅)
2. Fix port conflict: C-10/C-20 (5001) vs README/Charters (4001)
3. Fix Commerce domain: tec-commerce-app.vercel.app vs commerce.tecosystem.app
4. Add Truth State headers to C-00→C-23 (~35% coverage now)
5. Pi Developer Portal submission
```

---

*For full current state → knowledge-base/C-02___CURRENT_STATE_.md*
*For full platform architecture → architecture/PLATFORM_ARCHITECTURE.md*
*For all documents → knowledge-base/C-57___MASTER_CONTENTS_INDEX.md*
