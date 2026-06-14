# C-40 — OPEN VIOLATIONS MAP
## Current Issues + Priority + Fix

**Last Updated:** 14 June 2026

---

## LIFECYCLE

```
OPEN → IN REMEDIATION → CLOSED → VERIFIED
Only VERIFIED (with test evidence) counts toward score
```

---

## P1 — يمنع Mainnet

### NEW-B: INTERNAL_SECRET — Ops Task Only

| Field | Value |
|-------|-------|
| Severity | P1 |
| Status | ⚠️ OPS ONLY — كود OK |
| Repo | tec-core-backend (tec-payment-service) |

الكود اتصلح (z.string().min(32) + process.exit(1)) — الـ fix الوحيد الباقي هو set الـ env var على Railway:

```bash
# Generate once — same value for all 4 services
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Set INTERNAL_SECRET on Railway:
# tec-api-gateway, tec-auth-service, tec-payment-service, tec-commerce-service
```

Test: Start payment-service بدون INTERNAL_SECRET → crash immediately

---

## P2 — يؤثر على Score

### NEW-C: Payment BFF CSRF Exclusion Undocumented

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | OPEN |
| File | Commerce/src/middleware.ts |

المشكلة:
  CSRF_EXCLUDED = ['/api/bff/payment/']
  Payment mutations بدون CSRF — محتاج توثيق رسمي

القرار المعماري المبرر:
  JWT verification في كل BFF route
  Idempotency-Key يمنع replay
  HTTPS فقط

Fix: أضف ADR (Architecture Decision Record) في Architecture Binding
Test: Document الـ decision رسمياً

---

### NEW-E: tec-ui Package No Tests

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | OPEN |
| Repo | Tec-ui |

Fix: Tests لـ:
  - buildHubPayUrl (URL building)
  - getPaymentReturnParams (URL parsing)
  - formatPi / parsePiAmount
  - TEC_DOMAINS constants

---

### NEW-F: Tec-Ecommerce Undocumented

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | OPEN |

يحتاج:
  □ Pi App ID مسجل في Pi Developer Portal؟
  □ ecommerce.tecosystem.app domain مؤكد؟
  □ Tests مكتوبة
  □ Architecture Binding محدث

---

### NEW-G: Dual-Mode Payment Not in Architecture Binding

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | OPEN |

Fix: حدّث Architecture Binding بـ:
  - Dual-Mode Payment pattern documented
  - __TEC_PI_FOREIGN_SESSION behavior
  - Per-app Pi App ID requirement
  - FOREIGN_SESSION detection in layout.tsx

---

## DEFERRED (Post-Mainnet)

### VM-NEW-009: Wallet Schema Cross-Domain Models

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | DEFERRED |

المشكلة:
  tec-wallet-service/prisma/schema.prisma
  model User, Session, Payment, TwoFactorAuth
  هذه models تنتمي لـ auth-service + payment-service

Fix (post-Mainnet):
  Remove cross-domain models من wallet schema
  Wallet يملك فقط: Wallet + Transaction + ProcessedEvent + AuditLog

---

### VM-NEW-014: Gateway Monolith

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | DEFERRED |

المشكلة:
  tec-api-gateway/src/main.ts = 27KB
  كل الـ logic في ملف واحد
  AppModule فارغ

Fix (post-Mainnet):
  Extract middleware لـ modules
  Use NestJS DI properly

---

### ISS-010: Prometheus Not Unified

| Field | Value |
|-------|-------|
| Severity | P2 |
| Status | DEFERRED |

المشكلة:
  Prometheus في payment-service فقط
  مفيش unified observability

Fix (post-Mainnet):
  أضف Prometheus لكل الـ services
  Centralized Grafana dashboard

---

## VERIFIED ✅ (Closed Correctly)

### P1 Violations — All Closed

| ID | Description | Closed |
|----|-------------|--------|
| NEW-A | NEXT_PUBLIC_ Gateway Exposure → API_GATEWAY_URL في 48 BFF routes | June 2026 |
| NEW-B (code) | INTERNAL_SECRET: z.string().min(32) + process.exit(1) | June 2026 |
| NEW-D | tec-auth 95% coverage — 46 tests | June 2026 |
| NEW-I | Assets Mode 2 + ADR-007 | June 1, 2026 |
| NEW-J | Ecommerce Mode 1 + ADR-007 | June 3, 2026 |

### Payment Schema Fixes (June 14, 2026)

| ID | Description | PR | Status |
|----|-------------|----|---------|
| ECM-01 | Commerce approve/complete: camelCase→snake_case schema mismatch | PR #20 | ✅ Merged |
| ECM-02 | Ecommerce approve/complete: GW 503 (missing NEXT_PUBLIC_ fallback) | PR #25 | ⏳ Pending merge |

### Security Foundations

```
✅ jwt.decode() → jwt.verify() + HS256
✅ PI_SANDBOX: z.enum() (no default)
✅ PI_SANDBOX startup warning
✅ DECIMAL(20,8) + balance>=0
✅ CSRF in middleware
✅ Redis rate limiting (distributed)
✅ timingSafeEqual everywhere
✅ CORS explicit whitelist (all 5 domains)
✅ Policy CI active (blocks decode/wildcard/localStorage)
✅ SDK setAuthToken: includes all 7 clients
✅ TecSdkConfig: single definition
✅ Docker: .dockerignore + non-root USER
✅ continue-on-error: removed from build/test/deploy
✅ Wallet IDOR: authenticate middleware added
✅ BFF bypasses: all closed
✅ Dependabot: major bumps disabled
```

---

## SUMMARY

```
P0 Open:  0
P1 Open:  0 (NEW-B code done — ops task only)
P2 Open:  4 (NEW-C, NEW-E, NEW-F, NEW-G)
Deferred: 3 (post-Mainnet)

Next action: merge Ecommerce PR #25 → set INTERNAL_SECRET on Railway
```
