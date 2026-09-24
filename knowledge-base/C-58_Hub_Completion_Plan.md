# C-58 — HUB COMPLETION PLAN
## KYC + Subscription + Notifications — what is left for Mainnet

> **Truth State:** `[Planned State]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`

---


---

## ⚠️ The important discovery

> The Dashboard pages are already built in `/dashboard`
> The problem is not the pages themselves
> The problem is: integration + NEXT_PUBLIC_ + the upgrade flow

---

## 1. WHAT EXISTS (from the actual code)

### ✅ Already exists

```
Dashboard Pages:
  /dashboard/kyc/page.tsx          ✅ كامل — status + upload + submit
  /dashboard/subscription/page.tsx ✅ كامل — current plan + upgrade
  /dashboard/notifications/page.tsx ✅ كامل — list + read + unread

BFF Routes:
  /api/kyc/start         ✅
  /api/kyc/upload        ✅
  /api/kyc/submit        ✅
  /api/kyc/status        ✅
  /api/bff/kyc/status    ✅
  /api/subscriptions     ✅ (plans + status + upgrade)
  /api/notifications     ✅
  /api/notifications/[id]/read    ✅
  /api/notifications/unread-count ✅
  /api/notifications/read-all     ✅
  /api/bff/notifications/list     ✅
  /api/bff/notifications/unread   ✅

Hub page.tsx:
  ✅ notifCount موجود + realtime via useRealtimeNotifications
  ✅ userKyc + userPro checks موجودين
  ✅ onNotifClick → /dashboard/notifications

Hooks:
  ✅ useKyc — status + upload + submit
  ✅ useNotifications — list + read + unread
  ✅ useRealtimeNotifications — WebSocket live updates
```

---

## 2. WHAT'S MISSING — the actual problems

### Problem 1: NEXT_PUBLIC_ in every BFF route

```typescript
// ❌ في كل الـ routes (subscription, kyc, notifications)
const GATEWAY = process.env.API_GATEWAY_URL  ✅ (FIXED — NEW-A June 2026)!;

// ✅ الصح (NEW-A violation fix)
const GATEWAY = process.env.API_GATEWAY_URL
             ?? process.env.API_GATEWAY_URL  ✅ (FIXED — NEW-A June 2026)!;
```

**Impact:** every BFF route exposes the Railway URL to the browser

---

### Problem 2: Subscription upgrade flow incomplete

```
/dashboard/subscription/page.tsx موجود
لكن الـ upgrade flow:
  ❌ مش واضح إزاي البيانات بتتحدث بعد Payment
  ❌ Subscription upgrade عبر Pi payment — flow مش مربوط

المطلوب:
  المستخدم يضغط Upgrade → Pi.createPayment() → subscription تتحدث
  ده محتاج:
    Mode 2: Pi.createPayment مباشر على Hub domain ✅ (Hub يدعم Pi.init)
    BFF: /api/bff/subscription/upgrade route
    بعد payment success: invalidate subscription cache
```

---

### Problem 3: KYC Document Upload — Storage

```
/api/kyc/upload موجود
لكن:
  ❓ Cloudflare R2 presigned URL موجود؟
  ❓ File validation (type + size) موجود في BFF؟
  ❓ Progress indicator موجود في UI؟

Dashboard KYC page بتعمل upload لكن
مش واضح لو الـ storage integration كاملة
```

---

### Problem 4: Hub → Dashboard Navigation

```
Hub page عندها onNotifClick → /dashboard/notifications
لكن:
  ❓ لو user مش logged in في Hub → SSO redirect صح؟
  ❓ Hub /hub route مش protected في middleware بالصح؟

الحالي في middleware.ts:
  matcher: /hub/:path* ← protected ✅
```

---

## 3. WORK PLAN

### Phase A — Fix NEXT_PUBLIC_ (before anything else)

```
Files to fix:
  src/app/api/kyc/*/route.ts         (4 files)
  src/app/api/subscriptions/route.ts (1 file)
  src/app/api/notifications/*/route.ts (4 files)
  src/app/api/bff/notifications/*/route.ts (2 files)
  src/app/api/bff/kyc/*/route.ts (1 file)

Change:
  const GATEWAY = process.env.API_GATEWAY_URL
               ?? process.env.API_GATEWAY_URL  ✅ (FIXED — NEW-A June 2026)!;
```

---

### Phase B — Subscription Upgrade Payment

```typescript
// src/app/dashboard/subscription/page.tsx
// أضف Pi payment flow للـ upgrade

const handleUpgrade = async (plan: 'PRO' | 'ENTERPRISE') => {
  const price = plan === 'PRO' ? 10 : 50; // 10π or 50π/month

  // Mode 2: مباشر على Hub domain (Pi.init موجود)
  const internalId = await createPaymentRecord(
    price,
    `subscription_${plan.toLowerCase()}`,
    `TEC ${plan} Subscription`,
    'hub'
  );
  if (!internalId) return;

  const result = await createU2APayment(
    price,
    `TEC ${plan} Subscription`,
    { plan, type: 'subscription' },
    internalId,
  );

  if (result.success) {
    // Update subscription via BFF
    await fetch('/api/bff/subscription/upgrade', {
      method: 'POST',
      credentials: 'include',
      headers: buildPaymentHeaders(),
      body: JSON.stringify({ plan, payment_id: internalId }),
    });
    // Refresh subscription data
    refreshSubscription();
  }
};
```

```typescript
// src/app/api/bff/subscription/upgrade/route.ts (جديد)
// يستدعي Gateway → auth-service → update subscription plan
```

---

### Phase C — KYC Flow Verification

```
□ اختبر upload flow من البداية للنهاية
□ تأكد R2 presigned URL شغال
□ تأكد status updates real-time
□ تأكد rejection flow + resubmit
```

---

### Phase D — Hub → Dashboard Links

```
Hub page → أضف quick action buttons:
  KYC:           → router.push('/dashboard/kyc')
  Subscription:  → router.push('/dashboard/subscription')
  Notifications: → /dashboard/notifications (موجود ✅)
  Wallet:        → /dashboard/wallet (موجود ✅)
```

---

## 4. SUBSCRIPTION PAYMENT — BFF Route

```typescript
// src/app/api/bff/subscription/upgrade/route.ts

import { NextRequest, NextResponse } from 'next/server';

const GW = process.env.API_GATEWAY_URL
        ?? process.env.API_GATEWAY_URL  ✅ (FIXED — NEW-A June 2026)!;

export async function POST(req: NextRequest) {
  const token = req.cookies.get('tec_access_token')?.value;
  if (!token) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { plan, payment_id } = await req.json();
  if (!['PRO', 'ENTERPRISE'].includes(plan)) {
    return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
  }

  const res = await fetch(`${GW}/api/v1/auth/subscription/upgrade`, {
    method:  'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization:  `Bearer ${token}`,
    },
    body: JSON.stringify({ plan, payment_id }),
  });

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

---

## 5. MAINNET READINESS CHECKLIST

```
KYC:
  ✅ Dashboard page مبنية
  ✅ BFF routes موجودة
  □ Fix NEXT_PUBLIC_ في KYC routes
  □ Verify R2 upload شغال في production
  □ Test full flow: start → upload → submit → verified

Subscription:
  ✅ Dashboard page مبنية (plans + current)
  ✅ Plans API موجود
  □ Fix NEXT_PUBLIC_ في subscription route
  □ Add upgrade Pi payment flow
  □ Add /api/bff/subscription/upgrade route
  □ Test upgrade: PRO → payment → subscription updated

Notifications:
  ✅ Dashboard page مبنية
  ✅ BFF routes موجودة
  ✅ Realtime via WebSocket (useRealtimeNotifications)
  ✅ Hub page تعرض unread count
  □ Fix NEXT_PUBLIC_ في notifications routes
  □ Test: payment → notification → realtime update
```

---

## 6. The recommended order

```
1. Fix NEXT_PUBLIC_ في كل الـ 11 routes (NEW-A)
   → ساعة واحدة

2. Add subscription upgrade payment flow
   → يوم واحد

3. Verify KYC R2 upload في production
   → اختبار + debug

4. Add Hub quick action links
   → ساعتين

5. Integration test: login → KYC → Subscription → Notification
   → نص يوم
```
