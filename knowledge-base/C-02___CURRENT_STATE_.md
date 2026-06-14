# C-02 — CURRENT STATE
## Living Document — Updated End of Every Session

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `claude/gifted-knuth-1yhom3`

**Last Updated:** 14 June 2026 (Session 5)

---

## SCORE

| المصدر | Score |
|--------|-------|
| Self | ~8.5/10 |
| External (قبل Session 4 fixes) | 7.1/10 avg (Ecom 5.5 / Hub 6.5 / Commerce 7.0 / Assets 7.5) |
| External (متوقع بعد الـ fixes) | **~8.5–9.0/10** |
| الهدف | **9.5/10** |

---

## DONE ✅ (تراكمي)

| Item | التفاصيل |
|------|----------|
| P1 violations | كلها closed (NEW-A → NEW-J) |
| Security audit (10 items) | PRs #22 Ecommerce + #65 Backend + #19 Commerce + #21 Hub |
| Tests ≥ 60% | كل repos — tec-auth 95% (46 tests) |
| Commerce schema fix | PR #20 merged |
| Ecommerce 503 fix | PR #25 merged |
| Mode 1 + Mode 2 + ADR-007 | كل 4 apps |
| CORS | 5 domains في Gateway + Auth + Payment |
| Hub sub-pages | KYC + Subscription + Notifications + Profile |
| Session Start protocol | في CLAUDE.md — 4 repos |
| tec-ui v1.2.1 | PaymentModal + createU2APayment() + 75 tests 80% |
| Consumer apps on v1.2.1 | Ecommerce + Commerce + Assets ✅ |
| NEW-C | ADR-006 في C-64 — CSRF exclusion موثق ✅ |
| NEW-E | tec-ui 75 tests 80% coverage ✅ |
| NEW-F | Pi App ID: `ecommerce-app-71ca4d3e462eaf54` + `ecommerce.tecosystem.app` — C-01 + CLAUDE.md ✅ |
| NEW-G | Dual-Mode في ADR-002 (C-64) + C-12 ✅ |
| **NEW-B** | **INTERNAL_SECRET set على Railway — 4 services ✅** |
| External Audit fixes — Commerce | PR #23 → merged main — حذف 12 Railway URL من client bundle + x-internal-key + Zod + 503 + ADR-007 ✅ |
| External Audit fixes — Assets | PR #12 → merged main — createHandler debug logs + CSRF + x-internal-key + 503 + next.config.js PI_SANDBOX guard ✅ |
| **Comprehensive Audit fixes — Ecommerce** | **PR #27 → pending merge** — حذف hardcoded Railway URLs (sdk.ts + PiTestClient + ci.yml) + CSRF على كل POST BFF routes + 503 guards + ADR-007 fix (store page) + Zod على payment/create + orders ✅ |
| **Comprehensive Audit fixes — Hub** | **PR #24 → pending merge** — حذف console.logs من provision + payment/create / حذف JWT decode without verify / x-internal-key على wallet/balance / حذف NEXT_PUBLIC_ من ci.yml + .env.example ✅ |
| **Comprehensive Audit fixes — Commerce** | **pushed to main** — حذف legacy /api/payment/ routes (unsecured) + حذف /api/debug endpoint + migrate callers إلى BFF routes + حذف NEXT_PUBLIC_ fallback ✅ |
| **Comprehensive Audit fixes — Assets** | **pushed to main** — حذف NEXT_PUBLIC_ fallback من 5 files + CSRF على 4 payment BFF routes ✅ |
| **Hub — JWT decode forbidden fix** | **pushed to main** (SHA: 687247d) — `getUserIdFromToken()` via `jwt.decode()` حُذفت — userId يجي من `tec_user` cookie بدلها (C-47 P6 + Forbidden #2) ✅ |
| **Hub — CI test fixes** | **pushed to main** (SHAs: 56e57b9c + 275d6fd0) — 8 tests أُضيف لها `tec_user` cookie بعد كسرها بسبب الـ JWT decode fix + `vi.resetAllMocks()` لـ test isolation ✅ |
| **Hub CI green** | **✅ CONFIRMED** — 2026 tests passing على commit 275d6fd0 (conclusion: success) |

---

## PENDING ⚠️

| Item | الإجراء |
|------|----------|
| **Ecommerce PR #27** | Merge to main |
| **Hub PR #24** | Merge to main (أو التحقق إذا كانت التغييرات اتعملت على main مباشرة) |
| Commerce + Assets + Hub Pi App IDs | Register على Pi Developer Portal + وثّق في C-01 |

---

## NEXT 🔴 (Portal path)

```
1. Merge PRs #27 (Ecommerce) + #24 (Hub) — تحقق من conflicts مع main
2. External Audit إعادة — المتوقع 8.5–9.0 بعد الـ fixes
3. Fix أي findings جديدة
4. Portal Submission → Pi Network
```

---

## PLATFORM STATE

```
12 Railway services:   Active — INTERNAL_SECRET set ✅
4 apps (Vercel):      Hub + Commerce + Assets + Ecommerce
4 npm packages:       tec-auth + tec-ui (v1.2.1) + tec-sdk + tec-shared
PI_SANDBOX:           false (Mainnet)
tec-auth coverage:    95% (46 tests)
tec-ui coverage:      80% (75 tests)
Hub CI:               ✅ GREEN — 2026 tests passing (commit 275d6fd0)
All 4 apps:           Mode 1 + Mode 2 + ADR-007 ✅
All P1 violations:    ✅ ZERO
All P2 violations:    ✅ ZERO (post Session 4)
Ecommerce Pi App ID:  ecommerce-app-71ca4d3e462eaf54
Comm/Assets/Hub IDs:  ⚠️ محتاجين تسجيل على Pi Developer Portal
External Audit score: 5.5–7.5 → fixes applied → re-audit مطلوب
Pending PRs:          #27 Ecommerce + #24 Hub → merge to main
```

---

## WHAT WAS FIXED (Session 5 — Hub CI fixes)

### Tec-App (Hub) — pushed directly to main
| Finding | Fix |
|---------|-----|
| FORBIDDEN: `jwt.decode()` بدون verify في `payment/create/route.ts` | حذف `getUserIdFromToken()` — userId يجي من `tec_user` cookie via `getUserIdFromCookie()` |
| 8 tests كسرت بعد الـ JWT fix | أُضيف `cookies: { tec_user: encodeURIComponent(JSON.stringify({ id: userId })) }` لكل test محتاج يوصل للـ gateway |
| Test isolation: `vi.clearAllMocks()` مش كافي | غُيّر لـ `vi.resetAllMocks()` في `beforeEach` + `mockResolvedValueOnce` بدل `mockResolvedValue` |

---

## WHAT WAS FIXED (Session 4 — Comprehensive Audit)

### Tec-Ecommerce — PR #27 (branch → main)
| Finding | Fix |
|---------|-----|
| P1: hardcoded Railway URL في src/lib/sdk.ts | `API_GATEWAY_URL ?? ''` |
| P1: 12 hardcoded Railway URLs في PiTestClient.tsx client bundle | حذف SERVICES array كاملة |
| P1: NEXT_PUBLIC_API_GATEWAY_URL في ci.yml | حذف من build step |
| P1: NEXT_PUBLIC_ fallback في 8 BFF routes | حذف fallback، keep `API_GATEWAY_URL ?? ''` |
| P1: CSRF missing على كل POST BFF routes | CSRF double-submit على approve + complete + create + orders |
| P1: Missing 503 guard في payment/create + stores + products | أضفنا على كل route |
| P1: ADR-007 broken في store/[id]/page.tsx | isHubNavigation() أول check في handleBuy |
| P1: Missing Zod في payment/create + orders POST | CreateSchema + OrderSchema |

### Tec-App (Hub) — PR #24 (branch → main)
| Finding | Fix |
|---------|-----|
| P1: console.log يسرب token prefix + response في provision/route.ts | حذف كل console.log (keep console.error فقط) |
| P1: console.log يسرب cookies + body + userId في payment/create/route.ts | حذف كل console.log |
| P2: JWT decode without verify (FORBIDDEN) في payment/create | حذف getUserIdFromToken() — userId من tec_user cookie بدلها |
| P2: Missing x-internal-key في wallet/balance/route.ts | أضفنا header |
| P1: NEXT_PUBLIC_API_GATEWAY_URL في ci.yml + root .env.example | حذف من الاثنين |

### Tec-Commerce — pushed to main
| Finding | Fix |
|---------|-----|
| P1: Legacy /api/payment/approve (no CSRF, 4 console.logs) | حذف الملف — callers migrated إلى /api/bff/payment/approve |
| P1: Legacy /api/payment/complete (no CSRF, logs) | حذف الملف — callers migrated |
| P1: Legacy /api/payment/resolve-incomplete | حذف الملف — callers migrated |
| P1: /api/debug endpoint (zero auth, info disclosure) | حذف الملف |
| P1: NEXT_PUBLIC_ fallback في payment/create + resolve-incomplete | حذف fallback |
| P2: handleCancelPending يكلم legacy route | migrated إلى /api/bff/payment/resolve-incomplete |

### Tec-Assets — pushed to main
| Finding | Fix |
|---------|-----|
| P1: NEXT_PUBLIC_ fallback في 5 files (payment routes + nft/upload) | حذف fallback من كل file |
| P2: CSRF missing على 4 payment POST BFF routes | CSRF double-submit على approve + complete + create + resolve |

---

## UPDATE PROTOCOL

```
آخر كل session — قبل الإغلاق:
☐ أضف لـ DONE كل حاجة اتخلصت
☐ احذف من PENDING كل حاجة اتحلت
☐ حدّث NEXT بالأولوية الجديدة
☐ حدّث Last Updated
```
