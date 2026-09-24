# C-41 — ENGINEERING ROADMAP
## Path to 9.5/10 + Portal Submission

> **Truth State:** `[Current State]`
> **Governance State:** `[ADR Approved]`
> **Verification:** `[Documentation Verified]`

**Last Updated:** 24 September 2026 — status reconciled with `architecture/app-fleet.yaml`.

> **Where this roadmap stands:** Phases 0, 1 and 2 are **complete**. All 24 apps have been
> live on Mainnet with real Pi since July 2026 (`app-fleet.yaml`: 21 `live-verified`,
> 3 `live-readonly-gated`). Everything below is the historical record of how the platform
> got there; current open work is in **C-02** and `audits/KB_REMEDIATION_PLAN_2026-09-24.md`.

---

## 1. SCORE PROJECTION

```
Session 3 (External):    7.65/10
Session 8 (Architectural Review): 9.1/10
                          Knowledge Architecture: 9.5+/10
────────────────────────────────────────────────────────
Target (External Audit): ≥ 9.5/10 → Portal Submission
```

---

## 2. PHASE 0 — P1 Violations (DONE ✅)

```
✅ NEW-A: API_GATEWAY_URL في 48 BFF routes (Hub)
✅ NEW-B: INTERNAL_SECRET required (payment-service/env.ts)
✅ NEW-D: tec-auth 95% coverage — 46 tests (4 files)
✅ NEW-I: Assets Mode 2 + ADR-007 (June 1, 2026)
✅ NEW-J: Ecommerce Mode 1 + ADR-007 (June 3, 2026)
✅ CORS: all 5 domains in Gateway + Auth + Payment
✅ Dependabot: major bumps disabled
✅ 12 Railway services: all active
✅ Policy CI: no continue-on-error
```

---

## 3. PHASE 1 — Portal Readiness (DONE ✅)

### tec-ui v1.2.1 ✅ DONE

```
✅ createU2APayment() في @yasser172/tec-ui/payment
✅ PaymentModal component
✅ C-83 Phase 1: CSS tokens
✅ SemanticDomain TypeScript type
✅ Published @yasser172/tec-ui v1.2.1
✅ Tested على Commerce
✅ Updated Assets + Ecommerce → v1.2.1
✅ 75 tests + 80% coverage
```

### P2 Violations ✅ ALL CLOSED

```
✅ NEW-C: ADR-006 موثق في C-64
✅ NEW-E: tec-ui 75 tests + 80% coverage
✅ NEW-F: Pi App IDs في C-01 + CLAUDE.md
✅ NEW-G: Dual-Mode في ADR-002 + C-12
```

### External Audit — superseded (all apps went live on Mainnet in July 2026)

```
□ Submit for external audit (كل fixes على main ✅)
□ Fix any new findings
□ Target: ≥ 9.5/10
```

### Final Gate

```
✅ PI_SANDBOX=false verified everywhere
✅ Zero P1 violations
✅ Zero P2 violations
□ External audit ≥ 9.5
→ Pi Network Developer Portal submission
```

---

## 4. PHASE 2 — Post-Portal (Layer 1) (DONE ✅)

```
✅ Analytics UI — live (analytics.tecosystem.app)
✅ Life app — live, full C-106 charter (Session 51)
✅ SYSTEM UI — live (system.tecosystem.app)
✅ tec-ui — past v1.3.0; v3.0.0 on the Pi amber (C-83, Session 46)
```

---

## 7. CONTENT FREEZE RULE

```
(historical) No new contents after C-86 before Portal.
Documentation inflation risk.
Lifted once the Portal gate passed — C-87 → C-135 were added afterwards.
→ C-77 §11 Rule #2
```

---

## Related Contents

```
C-40 — Violations Map
C-55 — Scoring Strategy
C-75 — Release Governance
C-82 — Platform Maturity
C-85 — Infrastructure Stack
```