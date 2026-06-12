# C-41 — ENGINEERING ROADMAP
## Path to 9.5/10 + Portal Submission

**Last Updated:** June 2026

---

## 1. SCORE PROJECTION

```
Now (Self):              ~8.5/10
Now (External expected): ~7.0–7.5/10
────────────────────────────────
After tec-ui v1.2.0:    ~8.5+ external
After external audit:    9.5/10 ✅ → Submit
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

## 3. PHASE 1 — Portal Readiness (CURRENT)

### tec-ui v1.2.0 (BLOCKER)

```
□ createU2APayment() في @yasser172/tec-ui/payment
□ PaymentModal component
□ C-83 Phase 1: CSS tokens
□ SemanticDomain TypeScript type
□ Publish @yasser172/tec-ui v1.2.0
□ Test على Commerce أولاً
□ Update Assets + Ecommerce
```

### External Audit (BLOCKER)

```
□ Submit for external audit
□ Fix all findings
□ Target: ≥ 9.5/10
```

### Final Gate

```
□ PI_SANDBOX=false verified everywhere
□ Zero P1 violations (already ✅)
□ External audit ≥ 9.5
→ Pi Network Developer Portal submission
```

---

## 4. PHASE 2 — Post-Portal (Layer 1)

```
□ Analytics UI (backend :5011 موجود)
□ Life app (retention layer)
□ SYSTEM UI (governance dashboard)
□ tec-ui v1.3.0 + C-83 Phase 2
```

---

## 7. CONTENT FREEZE RULE

```
No new contents after C-86 before Portal.
Documentation inflation risk.
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