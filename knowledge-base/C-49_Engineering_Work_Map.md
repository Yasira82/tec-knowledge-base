# C-49 — ENGINEERING WORK MAP
## خريطة العمل الهندسية الشاملة

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


**Version:** 1.0 — May 2026

---

## ⚡ STATUS UPDATE — June 2026

```
PHASE 0 — ALL DONE ✅:
  ✅ NEW-A: NEXT_PUBLIC_ → API_GATEWAY_URL (48 routes)
  ✅ NEW-B: INTERNAL_SECRET required
  ✅ NEW-D: tec-auth 95% coverage (46 tests)
  ✅ NEW-I: Assets Mode 2 + ADR-007
  ✅ NEW-J: Ecommerce Mode 1 + ADR-007
  ✅ CORS: all 5 domains
  ✅ Dependabot: major bumps disabled

CURRENT FOCUS — Portal:
  □ tec-ui v1.2.0
  □ External audit ≥ 9.5
  → Portal submission
```

---

## PART 1 — TEC-UI PAYMENT UPDATE

### createU2APayment — Mode 2 Direct Payment

```typescript
export const createU2APayment = async (
  amount:     number,
  memo:       string,
  metadata:   Record<string, unknown>,
  internalId: string,
): Promise<PaymentResult> => {
  return new Promise(async (resolve) => {
    if (!window.Pi) {
      resolve({ status: 'error', success: false, message: 'Pi SDK not ready' });
      return;
    }

    const timer = setTimeout(() => {
      resolve({ status: 'error', success: false, message: 'Payment timed out' });
    }, 90_000);

    window.Pi.createPayment(
      { amount, memo, metadata: { ...metadata, internalId } },
      {
        onReadyForServerApproval: async (piPaymentId) => {
          await fetch('/api/bff/payment/approve', { method: 'POST', ... });
        },
        onReadyForServerCompletion: async (piPaymentId, txid) => {
          const res = await fetch('/api/bff/payment/complete', { method: 'POST', ... });
          resolve(res.ok
            ? { status: 'completed', success: true, paymentId: internalId, txid }
            : { status: 'error', success: false });
        },
        onCancel:  () => resolve({ status: 'cancelled', success: false }),
        onError: (err) => resolve({ status: 'error', success: false, message: err.message }),
      },
    );
  });
};
```

---

## PART 2 — WORK MAP PER APP

### 2.1 HUB

```
□ KYC UI (/hub/kyc)
□ Subscription UI (/hub/subscription)
□ Notifications Center (/hub/notifications)
□ Profile completion (/hub/profile)
□ Fix NEW-A: API_GATEWAY_URL server-only
```

### 2.2 COMMERCE — Reference Implementation

```
□ npm install @yasser172/tec-ui@1.2.0
□ استبدل src/lib/pi-payment.ts بـ import من tec-ui
□ اختبر Mode 1 + Mode 2
□ لا تغير BFF routes
```

### 2.5 LIFE — Phase 1 (Post-Mainnet)

```
Spending Timeline + Budget System + Cashflow Dashboard
life-service جديد في Tec-core-backend
يقرأ من: wallet-service + payment-service + analytics-service
```

---

## PART 4 — NEW APP CREATION CHECKLIST

```
DAY 1 — Setup:
  □ Clone tec-template-base → Tec-[AppName]
  □ Register Pi App ID في Pi Developer Portal
  □ Create Vercel project → [appname].tecosystem.app
  □ أضف domain في Gateway CORS
  □ أضف App source في payment-service getPiApiKey()
  □ Add GitHub repo → Yasira82/Tec-[AppName]

BEFORE LAUNCH:
  □ اختبر payment من Hub → App
  □ اختبر payment من App مباشرة
  □ اختبر SSO
  □ اختبر على Pi Browser
```