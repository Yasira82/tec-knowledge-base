C-40 — OPEN VIOLATIONS MAP

Current Issues + Priority + Fix

Last Updated: May 2026 (revised — NEW-I extracted as independent section)

LIFECYCLE

OPEN → IN REMEDIATION → CLOSED → VERIFIED
Only VERIFIED (with test evidence) counts toward score

P1 — يمنع Mainnet (5 violations)

NEW-A: NEXT_PUBLIC_ Gateway Exposure

Severity: P1
Status:   OPEN
Repos:    Hub (30+ files) + Commerce + Assets + Ecommerce

المشكلة:
  NEXT_PUBLIC_API_GATEWAY_URL → يتضمن في client bundle
  أي user يفتح DevTools يشوف Railway URL

Fix:
  server-only routes: استخدم API_GATEWAY_URL (بدون NEXT_PUBLIC_)
  File: src/app/api/*/route.ts في كل الـ apps
  Code:
    const GW = process.env.API_GATEWAY_URL
            ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL;

Test: DevTools → Network → BFF request headers → لا يظهر Railway URL

NEW-B: INTERNAL_SECRET Optional

Severity: P1
Status:   OPEN
File:     tec-payment-service/src/config/env.ts

المشكلة:
  INTERNAL_SECRET: z.string().min(1).optional()
  لو مش set → inter-service auth يفشل silently

Fix:
  INTERNAL_SECRET: z.string().min(32, {
    message: 'INTERNAL_SECRET must be at least 32 chars'
  })
  + startup guard: if (!env.INTERNAL_SECRET) process.exit(1)

Test: Start payment-service بدون INTERNAL_SECRET → crash

NEW-D: tec-auth Package No Tests

Severity: P1
Status:   OPEN
Repo:     tec-auth

المشكلة:
  Auth package بدون test coverage = خطر على كل الـ apps

Fix: كتابة tests لـ:
  - createAuthMiddleware (middleware behavior)
  - getAccessToken (cookie parsing)
  - CSRF validation
  - SSO flow (ssoRedirect + buildSsoUrl)
  - refreshAccessToken (dedup queue)

Test: vitest --coverage → 60%+ على auth functions

NEW-I: Tec-Assets — Mode 2 Payment مفقود

Severity: P1
Status:   OPEN
Repo:     Tec-Assets

المشكلة:
  Assets عندها Mode 1 فقط (Hub redirect)
  ناقصها Mode 2 (Pi.createPayment() مباشر على assets domain)
  Commerce = Reference Implementation — عندها الوضعين
  Assets لازم تكون زي Commerce بالظبط

الأماكن المتأثرة:
  - NFT Minting: بيروح Hub/mint (Mode 1 فقط)
  - Marketplace Buy: بيروح Hub?pay=1 (Mode 1 فقط)
  - Transfer: مفيش payment flow واضح

Fix:
  1. أضف Pi.init() polling في src/app/layout.tsx
     (نفس Commerce layout.tsx بالظبط)
  2. أضف src/lib/pi-payment.ts
     (نفس Commerce — بعد tec-ui v1.2.0 import منه)
  3. أضف BFF routes:
     /api/bff/payment/create|approve|complete|resolve-incomplete
  4. في NFTUploadModal + MarketplaceTab:
     Mode 2: Pi.createPayment() مباشر لو Pi ready
     Mode 1: handleBuy() → Hub redirect fallback
  5. أضف PI_API_KEY_ASSETS في payment-service getPiApiKey()

Test:
  □ Mode 2: Mint NFT → Pi.createPayment() مباشر → Success
  □ Mode 2: Buy asset → Pi.createPayment() مباشر → Success
  □ Mode 1: Hub redirect → PaymentModal → Success
  □ FOREIGN_SESSION: Hub session → Assets → Mode 2 شغال
  □ Commerce لسه شغال بعد التغيير

NEW-J: Tec-Ecommerce — Mode 1 Payment مفقود

Severity: P1
Status:   OPEN
Repo:     Tec-Ecommerce

المشكلة:
  Ecommerce عندها Mode 2 فقط (Pi.createPayment مباشر)
  ناقصها Mode 1 (Hub redirect fallback)
  لو Pi SDK مش جاهز → handleBuy بترجع بدون أي fallback
  المستخدم مش بيعرف إيه المشكلة

الكود الحالي:
  shop/page.tsx:70 → handleBuy
  if (!window.Pi || !piReady || inFlight.current) return; ← silent fail!

Fix:
  أضف Hub redirect fallback في handleBuy:
    if (!window.Pi || !piReady) {
      handleBuy({ amount, memo, productId, returnUrl, source: 'ecommerce' });
      return;
    }
  import handleBuy من @yasser172/tec-ui/payment (بعد v1.2.0)

Test:
  □ Mode 1: Hub redirect → PaymentModal → Success
  □ Mode 2: Pi.createPayment مباشر → Success
  □ Pi SDK timeout → fallback لـ Hub تلقائي
  □ Commerce لسه شغال بعد التغيير

P2 — يؤثر على Score

NEW-C: Payment BFF CSRF Exclusion Undocumented

Severity: P2
Status:   OPEN
File:     Commerce/src/middleware.ts

المشكلة:
  CSRF_EXCLUDED = ['/api/bff/payment/']
  Payment mutations بدون CSRF — محتاج توثيق رسمي

القرار المعماري المبرر:
  JWT verification في كل BFF route
  Idempotency-Key يمنع replay
  HTTPS فقط

Fix: أضف ADR (Architecture Decision Record) في Architecture Binding
Test: Document الـ decision رسمياً

NEW-E: tec-ui Package No Tests

Severity: P2
Status:   OPEN
Repo:     Tec-ui

Fix: Tests لـ:
  - buildHubPayUrl (URL building)
  - getPaymentReturnParams (URL parsing)
  - formatPi / parsePiAmount
  - TEC_DOMAINS constants

NEW-F: Tec-Ecommerce Undocumented

Severity: P2
Status:   OPEN
Repo:     Tec-Ecommerce

يحتاج:
  □ Pi App ID مسجل في Pi Developer Portal؟
  □ ecommerce.tecosystem.app domain مؤكد؟
  □ Tests مكتوبة
  □ Architecture Binding محدث

NEW-G: Dual-Mode Payment Not in Architecture Binding

Severity: P2
Status:   OPEN

Fix: حدّث Architecture Binding بـ:
  - Dual-Mode Payment pattern documented
  - __TEC_PI_FOREIGN_SESSION behavior
  - Per-app Pi App ID requirement
  - FOREIGN_SESSION detection in layout.tsx

DEFERRED (Post-Mainnet)

VM-NEW-009: Wallet Schema Cross-Domain Models

Severity: P2
Status:   DEFERRED

المشكلة:
  tec-wallet-service/prisma/schema.prisma
  model User, Session, Payment, TwoFactorAuth
  هذه models تنتمي لـ auth-service + payment-service

Fix (post-Mainnet):
  Remove cross-domain models من wallet schema
  Wallet يملك فقط: Wallet + Transaction + ProcessedEvent + AuditLog

VM-NEW-014: Gateway Monolith

Severity: P2
Status:   DEFERRED

المشكلة:
  tec-api-gateway/src/main.ts = 27KB
  كل الـ logic في ملف واحد
  AppModule فارغ

Fix (post-Mainnet):
  Extract middleware لـ modules
  Use NestJS DI properly

ISS-010: Prometheus Not Unified

Severity: P2
Status:   DEFERRED

المشكلة:
  Prometheus في payment-service فقط
  مفيش unified observability

Fix (post-Mainnet):
  أضف Prometheus لكل الـ services
  Centralized Grafana dashboard

VERIFIED (Closed Correctly)

✅ jwt.decode() → jwt.verify() + HS256
✅ PI_SANDBOX: z.enum() (no default)
✅ PI_SANDBOX startup warning
✅ DECIMAL(20,8) + balance>=0
✅ CSRF in middleware
✅ Redis rate limiting (distributed)
✅ timingSafeEqual everywhere
✅ CORS explicit whitelist
✅ Policy CI active (blocks decode/wildcard/localStorage)
✅ SDK setAuthToken: includes all 7 clients (P1-19)
✅ TecSdkConfig: single definition (P1-20)
✅ Docker: .dockerignore + non-root USER
✅ continue-on-error: removed from build/test/deploy
✅ Wallet IDOR: authenticate middleware added
✅ BFF bypasses: all closed