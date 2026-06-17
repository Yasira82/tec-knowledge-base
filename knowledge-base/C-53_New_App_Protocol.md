# C-53 — NEW APP CREATION PROTOCOL
## الخطوات الكاملة لبناء أي App جديدة

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


---

## القاعدة الأولى

> **Commerce = Reference Implementation**
> قبل أي app جديدة → تأكد Commerce Mode1+Mode2 شغالين
> أي مشكلة في Commerce قبل البدء → حلها أولاً

---

## DAY 1 — SETUP (2-3 ساعات)

### Step 1: Clone Template
```bash
# Yasira82/tec-template-base → الـ base لكل app
git clone https://github.com/Yasira82/tec-template-base Tec-[AppName]
cd Tec-[AppName]

# غيّر الـ package name
# package.json → name: "tec-[appname]"
```

### Step 2: Pi Developer Portal
```
1. افتح develop.pi
2. Create New App
3. App Name: TEC [AppName]
4. Domain: [appname].tecosystem.app
5. احفظ الـ App ID → NEXT_PUBLIC_PI_APP_ID
```

### Step 3: Vercel Setup
```
1. Import repo من Yasira82/Tec-[AppName]
2. Domain: [appname].tecosystem.app
3. Framework: Next.js
4. Environment Variables (اضيفهم كلهم من C-44)
```

### Step 4: Environment Variables
```env
# .env.local (نفس C-44 بالظبط — غيّر القيم فقط)
NEXT_PUBLIC_PI_APP_ID=[new_app_id]
NEXT_PUBLIC_PI_SANDBOX=false
NEXT_PUBLIC_APP_NAME=TEC [AppName]
NEXT_PUBLIC_APP_SOURCE=[appname]
NEXT_PUBLIC_APP_URL=https://[appname].tecosystem.app
NEXT_PUBLIC_HUB_URL=https://hub.tecosystem.app
API_GATEWAY_URL=https://api-gateway-production-6a68.up.railway.app
JWT_SECRET=[same_as_all_apps]
SSO_SECRET=[same_as_all_apps]
```

### Step 5: Gateway CORS
```typescript
// Tec-core-backend: tec-api-gateway/src/main.ts
// أضف الـ domain الجديد
const ALLOWED_ORIGINS = [
  'https://hub.tecosystem.app',
  'https://commerce.tecosystem.app',
  'https://assets.tecosystem.app',
  'https://ecommerce.tecosystem.app',
  'https://[appname].tecosystem.app',  // ← أضف هنا
];
```

### Step 6: Payment Service Source
```typescript
// Tec-core-backend: tec-payment-service/src/services/payment.service.ts
// أضف الـ source الجديد في getPiApiKey()
const getPiApiKey = (source: string): string => {
  switch (source) {
    case 'commerce':  return env.PI_API_KEY_COMMERCE;
    case 'assets':    return env.PI_API_KEY_ASSETS;
    case 'ecommerce': return env.PI_API_KEY_ECOMMERCE;
    case '[appname]': return env.PI_API_KEY_[APPNAME]; // ← أضف
    default:          return env.PI_API_KEY_HUB;
  }
};

// env.ts — أضف الـ key الجديد
PI_API_KEY_[APPNAME]: z.string().min(1),
```

### Step 7: GitHub Repo
```bash
# Create repo: Yasira82/Tec-[AppName]
git remote set-url origin https://github.com/Yasira82/Tec-[AppName]
git push -u origin main
```

---

## WEEK 1 — STRUCTURE

### Step 8: Middleware Setup
```typescript
// middleware.ts (root)
import { createAuthMiddleware } from '@yasser172/tec-auth/middleware';

export default createAuthMiddleware({
  protectedRoutes: ['/app', '/[appname]'],
  csrfExcluded:   ['/api/bff/payment/'],
});
```

### Step 9: Layout.tsx — Pi.init()
```typescript
// src/app/layout.tsx
// نفس الكود من Commerce بالظبط — غيّر NEXT_PUBLIC_PI_APP_ID فقط
const piInitScript = `(function(){
  var tries = 0;
  function setReady() {
    window.__TEC_PI_READY = true;
    window.dispatchEvent(new Event('tec-pi-ready'));
  }
  function initPi() {
    if (tries++ >= 40) return;
    if (!window.Pi) { setTimeout(initPi, 150); return; }
    try {
      window.Pi.init({
        version: '2.0',
        sandbox: false,
        appId: '${process.env.NEXT_PUBLIC_PI_APP_ID}'
      });
      setReady();
    } catch(e) {
      if (String(e).includes('already') || String(e).includes('initialized')) {
        window.__TEC_PI_FOREIGN_SESSION = true;
        setReady();
      } else { setTimeout(initPi, 150); }
    }
  }
  initPi();
})();`;
```

### Step 10: BFF Payment Routes
```
# Copy من Commerce بالظبط
src/app/api/bff/payment/
  create/route.ts
  approve/route.ts
  complete/route.ts
  resolve-incomplete/route.ts

# Copy من Commerce كمان
src/app/api/auth/
  pi-login/route.ts
  refresh/route.ts
  sso-callback/route.ts
  logout/route.ts
```

### Step 11: Payment في الـ Page
```typescript
// import من tec-ui (بعد v1.2.0)
import {
  createPaymentRecord,
  createU2APayment,
  handleBuy,
  getPaymentReturnParams,
  clearPaymentParams,
  PaymentModal,
} from '@yasser172/tec-ui/payment';

const APP_SOURCE = process.env.NEXT_PUBLIC_APP_SOURCE ?? '[appname]';
const APP_URL    = process.env.NEXT_PUBLIC_APP_URL ?? '';
const HUB_URL    = process.env.NEXT_PUBLIC_HUB_URL ?? '';

// Mode 2: Direct
const handleDirectPay = async (item) => {
  const id = await createPaymentRecord(item.price, item.id, item.title, APP_SOURCE);
  if (!id) return;
  const result = await createU2APayment(item.price, item.title, {}, id);
  // handle result
};

// Mode 1: Hub redirect
const handleHubPay = (item) => handleBuy({
  amount:    item.price,
  memo:      item.title,
  productId: item.id,
  returnUrl: `${APP_URL}/app`,
  source:    APP_SOURCE,
});
```

---

## WEEK 2-3 — CONTENT + TESTS

### Step 12: اكتب المحتوى
```
Focus على MVP:
  - الـ feature الأساسية بس
  - لا تبني كل شيء دفعة واحدة
  - اختبر الدفع أولاً ثم باقي الـ features
```

### Step 13: Vitest Tests
```typescript
// vitest.config.ts — نفس Commerce
// src/app/app/__tests__/[page].test.ts
// target: ≥ 60% coverage
```

### Step 14: GitHub Actions CI
```yaml
# .github/workflows/ci.yml — نفس Commerce
# lint → test → build
```

---

## BEFORE LAUNCH — الـ Checklist النهائي

```
□ Pi App ID مسجل في Pi Developer Portal ✅
□ Domain في Vercel ✅
□ Domain في Gateway CORS ✅
□ API_GATEWAY_URL server-only (مش NEXT_PUBLIC_) ✅
□ PI_SANDBOX=false في Vercel dashboard ✅
□ JWT_SECRET نفس باقي الـ apps ✅

اختبر الدفع:
□ Mode 1: Hub redirect → PaymentModal → Success ✅
□ Mode 2: Pi.createPayment مباشر → Success ✅
□ FOREIGN_SESSION: ادخل من Hub أولاً → ثم الـ app → Mode 2 شغال ✅
□ على Pi Browser (WebView) ← الأهم ✅

□ SSO: من Hub → يروح الـ app الجديدة ✅
□ Vitest tests ≥ 60% ✅
□ CI green ✅
□ Commerce لسه شغال (مالتأثرش) ✅
```