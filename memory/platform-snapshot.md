# TEC Platform Snapshot
## Fast-Load Current State — Session Start Reference

> Load this file at session start for instant platform context.
> For full details → C-02___CURRENT_STATE_.md

**Snapshot Version:** v4.0.0 | **Last Updated:** 24 September 2026
**Rule for this file:** only facts that were checked against code or a canonical source on
the date above, and a pointer to that source. A number here without a source is how the
previous version said "Phase 0 · 4 live apps · tec-ui v1.2.1" for three months after all
three stopped being true.

---

## Platform Identity

```
TEC — Pi-Native Economic Coordination Infrastructure
"24 Apps. One Identity. One Wallet. One World."
Phase:       all 24 apps LIVE on Pi Mainnet with real Pi since July 2026
Pi SDK Mode: PI_SANDBOX=false (Mainnet); a paired Testnet fleet exists (C-02 Session 54)
```

---

## Live Apps — 24

Source of truth: **`architecture/app-fleet.yaml`** (domain · Pi App ID · APP_SOURCE · charter
· status). Cross-checked 2026-09-24 against the Hub registry (`tec-app` `_registry.ts`) and
the SSO allowlist — all 24 agree.

```
21 live-verified        — deployed + a real Pi payment verified in production
 3 live-readonly-gated  — FundX · Insure · Brookfield: subscription is live; pools / escrow /
                          investment stay read-only until legal + payment-service custody + SYSTEM
```

Pi App IDs: **C-01 §4** (canonical), mirrored in `app-fleet.yaml`.

---

## Backend Services (Railway — 12)

Source of truth: **C-20** (verified against `main.ts` + the gateway's boot routing table).

```
Gateway :3000  │  Auth     :5001  │  Wallet :5002  │  Payment  :5003
Asset   :5004  │  Identity :5005  │  Notify :5006  │  Storage  :5007
KYC     :5008  │  Commerce :5009  │  Realtime:5010 │  Analytics:5011
```
Public: **gateway + realtime only** (ADR-005, Session 56m). The other nine are private
(`*.railway.internal`) and reached only through the gateway with `x-internal-key`.

---

## npm Packages

Source of truth: **C-14** (each repo's `package.json` on `main`).

| Package | Version |
|---------|---------|
| @yasser172/tec-ui | 3.0.0 (Pi amber) |
| @yasser172/tec-auth | 1.2.0 |
| @yasser172/tec-sdk | 1.4.0 |
| @yasser172/tec-shared | 1.1.0 (inside tec-core-backend) |

---

## Violations

All P0/P1/P2 in C-40 are **closed** (NEW-M re-checked 2026-09-24; NEW-B closed — payment-service
now refuses to start without a ≥ 32-char `INTERNAL_SECRET`). Current open work: C-02 "Open after
this session" tables and `audits/KB_REMEDIATION_PLAN_2026-09-24.md`.

---

## Knowledge Base

```
C-docs:    116 files (C-00 → C-135, with reserved gaps)  — see C-57
Charters:  24 (C-100 → C-115, C-124 → C-131)
Skills:    16 · Agents: 3 · Commands: 8
Gates:     run `bash scripts/preflight.sh` — it prints the live count and runs exactly what CI runs
```

---

## Authority Hierarchy (Quick Reference)

```
C-00  Platform Constitution
  ↓ C-67  Source of Truth Matrix
    ↓ ADRs  (C-64)
      ↓ C-77  Strategic Analysis + Risk
        ↓ Current-State Docs (C-02, C-78)
          ↓ App Charters (C-100→C-115, C-124→C-131)
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
No localStorage:     tokens in cookies ONLY
No body.userId:      identity ALWAYS from the session, server-side
No NEXT_PUBLIC_*:    for internal service URLs (NEW-A pattern)
DECIMAL(20,8):       all Pi amounts in DB
balance >= 0:        DB constraint — wallet never negative
Session cookies:     Secure; SameSite=None; Partitioned — never lax (C-123 §2)
A session = BOTH:    tec_access_token AND tec_user (guard = /api/auth/me) — C-13 §4
Cookies only on 200: never on an XHR response, never on a redirect (C-123 LAW 1/2)
Pi can go silent:    Pi.authenticate may never answer in another app's context (C-123 §9)
```

---

## Release Chain

```
tec-core-backend  →  tec-sdk  →  tec-auth  →  tec-ui  →  [all apps, together]
    (deploy)          (npm)       (npm)        (npm)        (Vercel)
```

---

*For full current state → knowledge-base/C-02___CURRENT_STATE_.md*
*For full platform architecture → architecture/PLATFORM_ARCHITECTURE.md*
*For all documents → knowledge-base/C-57___MASTER_CONTENTS_INDEX.md*
