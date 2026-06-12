# C-02 — CURRENT STATE
## Score + Violations + Mainnet Checklist

**Last Updated:** May 2026

---

## 1. SCORE

| المصدر | Score |
|---|---|
| Self-Assessed | ~8.5/10 |
| External Audit (expected) | ~7.0–7.5/10 |
| Target | **9.5/10** |
| Gap الحقيقي | ~2.0–2.5 نقطة |

> ⚠️ Pattern موثق: كل external audit بيسقط الـ score بـ 1.5–2.0 نقطة

### Score Breakdown

| Category | Score | Notes |
|---|---|---|
| Payment | 9.0 | Outbox + CB + Idempotency ✅ |
| Security-Auth | 8.5 | JWT + HS256 + CSRF ✅ |
| Security-DB | 9.0 | DECIMAL + balance>=0 ✅ |
| Security-Infra | 8.0 | NEXT_PUBLIC_ exposure issue |
| Backend | 8.0 | Gateway monolith 27KB |
| Frontend-Hub | 7.5 | BFF clean ✅ |
| Frontend-Apps | 7.5 | Commerce + Assets مكتملين |
| SDK | 8.5 | Dual CJS+ESM + Zod ✅ |
| CI/CD | 8.0 | Policy CI active ✅ |
| Observability | 5.0 | Prometheus في payment فقط |
| Governance | 6.0 | 4 repos جديدة غير موثقة |

---

## 2. CI STATUS

| Repo | CI | Notes |
|---|---|---|
| Tec-core-backend | ✅ | Policy CI + test matrix |
| Tec-App (Hub) | ✅ | Vitest + Playwright |
| Tec-Commerce | ✅ | Vitest passing |
| Tec-Assets | ⚠️ | Tests coverage منخفض |
| Tec-Ecommerce | ⚠️ | Tests لم تُكتب |
| TEC-SDK | ✅ | ZWC scan + prepublish gate |

---

## 3. OPEN VIOLATIONS

### P1 — يمنع Mainnet

| ID | الملف | الوصف |
|---|---|---|
| NEW-A | Hub: src/app/api/*/route.ts (30+ files) | NEXT_PUBLIC_API_GATEWAY_URL في server routes |
| NEW-B | payment-service/src/config/env.ts | INTERNAL_SECRET: optional — يجب required |
| NEW-D | tec-auth package | لا tests |
| NEW-I | Tec-Assets | Mode 2 Payment مفقود |
| NEW-J | Tec-Ecommerce | Mode 1 مفقود |

### P2 — يؤثر على Score

| ID | الوصف |
|---|---|
| NEW-E | tec-ui: لا tests |
| NEW-F | Tec-Ecommerce: غير موثق |
| NEW-G | Dual-Mode Payment: غير موثق في Architecture Binding |
| VM-NEW-009 | Wallet schema: cross-domain (deferred post-Mainnet) |
| VM-NEW-014 | Gateway main.ts 27KB monolith (deferred) |

---

## 4. MAINNET CHECKLIST

```
Infrastructure:
  ✅ 12 Railway services Active
  ✅ PostgreSQL per-service isolation
  ✅ Redis Streams event bus
  ✅ Cloudflare R2 storage
  ✅ Vercel frontend deployments

Security:
  ✅ JWT verify() + HS256 everywhere
  ✅ Policy as Code CI active
  ✅ CSRF validated in middleware
  ✅ Rate limiting Redis (distributed)
  ✅ timingSafeEqual for secrets
  ✅ balance >= 0 DB constraint
  ✅ DECIMAL(20,8) for Pi amounts
  □ NEXT_PUBLIC_ → API_GATEWAY_URL fix (NEW-A)
  □ INTERNAL_SECRET required (NEW-B)

Content:
  ✅ Hub: core features
  ✅ Commerce: Products + Orders + Payment
  ✅ Assets: Portfolio + NFT + Marketplace
  ✅ Ecommerce: Shop + Payment

Final Gate:
  □ External audit ≥ 9.5
  □ Zero P1 violations
  □ PI_SANDBOX=false verified
  □ Pi Network developer portal submission
```

---

## 5. CONFIRMED STRENGTHS (7 Audits)

```
✅ Payment: Outbox + Circuit Breaker + Idempotency + State Machine
✅ Auth: JWT rotation + Redis blacklist + CSRF
✅ Wallet: $transaction + upsert + balance>=0
✅ SDK: dual CJS+ESM + Zod + withRetry
✅ Policy CI: blocks decode() + wildcard + localStorage
✅ Dual-Mode Payment: Commerce = Reference Implementation
✅ Shared Packages: tec-auth + tec-ui + tec-sdk published
```