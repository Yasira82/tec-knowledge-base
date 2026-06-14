# C-50 — SESSION LOG
## Latest Updates + Decisions

---

## SESSION: 14 June 2026 — Security Audit Complete + Commerce Schema Fix

### ما تم خلال هذه المرحلة

**10 Security Audit Items — ALL CLOSED** (PRs merged في session سابق)

| PR | Repo | الـ Fix |
|----|------|--------|
| #22 ✅ | Tec-Ecommerce | Remove NEXT_PUBLIC_ fallback + strip userId from body + CSRF middleware |
| #65 ✅ | Tec-core-backend | Remove Railway URL from Swagger + HSTS headers + guard /health/detailed |
| #19 ✅ | Tec-Commerce | Remove Railway URL + Zod validation on payment routes + timing-safe CSRF |
| #21 ✅ | Tec-App | Pi amount z.string() + timing-safe CSRF + payment/create in middleware guard |

**10 Items Status:**
✅ #1 Railway URL in Swagger (→ relative URL)
✅ #2 Pi amount z.number() → z.string().regex() (Tec-App)
✅ #3 NEXT_PUBLIC_API_GATEWAY_URL fallback removed (Ecommerce)
✅ #4 userId in request body removed (بيجي x-user-id header)
✅ #5 Zod validation على payment/approve + complete (Commerce + Ecommerce)
✅ #6 CSRF على payment/create + timing-safe comparison (Hub middleware)
✅ #7 /health/detailed guarded with x-internal-key
✅ #8 HSTS + security headers on gateway
✅ #9 Timing-safe CSRF comparison (كل الـ 3 apps)
✅ #10 x-internal-key on payment callbacks

---

**Tests ≥ 60% — ALL REPOS** ✅

| Repo | Status |
|------|--------|
| tec-auth-service | 95% stmt / 92.98% branch / 100% lines |
| Tec-Commerce | ✅ ≥ 60% |
| Tec-Ecommerce | ✅ ≥ 60% |
| Tec-Assets | ✅ ≥ 60% |
| Tec-App (Hub) | ✅ |

---

**Commerce PR #20** ✅ Merged
- Schema mismatch: audit PRs غيّرت field names لـ camelCase (`paymentId`, `txid`) لكن client بيبعت snake_case
- Fix: رجع snake_case Zod schemas في approve + complete routes

**Ecommerce PR #25** ⚠️ Open — يحتاج قرار
- فُتح عشان 503 على approve/complete
- لكن PR #22 شال NEXT_PUBLIC_ fallback (security fix)
- الحل الصح: verify إن `API_GATEWAY_URL` (server-only) set في Vercel — لو صح → close PR #25
- لو `API_GATEWAY_URL` مش set في Vercel → أضفه كـ server-only env var

---

### الوضع بعد Session النهارده

| Item | Status |
|------|--------|
| P1 Violations | ✅ ZERO |
| Security Audit (10 items) | ✅ ALL CLOSED |
| Tests ≥ 60% | ✅ ALL REPOS |
| Commerce schema fix | ✅ PR #20 Merged |
| Ecommerce 503 | ⚠️ PR #25 — pending decision |
| **tec-ui v1.2.0** | 🔴 NEXT BLOCKER |
| External Audit ≥ 9.5 | 🔴 بعد tec-ui |
| Portal Submission | 🔴 آخر خطوة |

---

### Key Learnings (Session 14 June)

1. "Payment Expired" في Pi Browser = approve BFF مرجعش 2xx لـ Pi Network — ابدأ بـ Vercel function logs
2. create 201 + approve 503 = `API_GATEWAY_URL` undefined في Vercel (verify env var name first)
3. Audit PRs بتغير field names بدون verify مع client contracts — دايماً شوف pi-payment.ts
4. لو session سابق merge PR بيشيل feature (e.g. NEXT_PUBLIC_ fallback) — متعملش PR عكسي حيرجعه

---

## SESSION: June 2026 — P1 Violations + Security Hardening

### ما تم

✅ NEW-A → NEW-J: كل P1 violations closed
✅ CORS: all 5 domains
✅ ADR-007: كل 4 apps عندهم Mode 1 + Mode 2 + isHubNavigation()
✅ tec-auth: 95% coverage (46 tests)
✅ C-77 v5.0 + C-78 merged + C-82→C-86 أضيفوا

---

## SESSION: May 2026 — Engineering Governance Expansion

### ما تم

✅ C-63 → C-76: 14 content جديد
✅ ADR-001 → ADR-007 documented في C-64
✅ Source of Truth Matrix في C-67
✅ Domain Ownership, Event Governance, Financial Integrity, SLOs

---

### Key Learnings (Cumulative)

1. CORS must include ALL 5 app domains
2. usePiAuth → 401 loop إذا مفيش refresh route
3. Pi Browser caches pending payments server-side
4. Pi.createPayment 3rd param = onIncompletePaymentFound (undocumented)
5. Dependabot major bumps break monorepo silently
6. split('=')[1] truncates cookie values with '='
7. Server redirect before client cookie read = infinite loop
8. Over-engineering working code creates new bugs
9. expired_on_pi ≠ cleared from Pi Browser
10. Pi payment complete needs real txid
11. "Payment Expired" = check Vercel logs on /api/bff/payment/approve first
12. Audit PRs that rename fields break client contracts silently
13. Never add NEXT_PUBLIC_ fallback back if security PR removed it — fix the env var instead
