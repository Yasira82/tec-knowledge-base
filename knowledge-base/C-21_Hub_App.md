# C-21 — HUB APP
## hub.tecosystem.app — Core Identity + Payment Hub

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

---

## 1. ROLE

Hub هو محور الـ ecosystem:
```
Identity     ← Pi Login + Profile + KYC
Wallet       ← Balance + Transactions
Payments     ← Pi.createPayment() — الـ domain الأساسي
SSO Provider ← يوثق للـ apps التانية
Notifications ← FCM + Realtime
Subscriptions ← FREE/PRO/ENTERPRISE
PaymentModal  ← Cross-app payments
```

---

## 2. KEY FILES

```
tec-frontend/
  middleware.ts                           ← Page protection + CSRF ✅
  src/app/
    hub/
      page.tsx                            ← PaymentModal + ExternalPayment ✅
      components/
        PaymentModal.tsx                  ← Cross-app payment modal ✅
    api/
      auth/
        pi-login/route.ts                 ← Sets 4 cookies ✅
        refresh/route.ts                  ← httpOnly:false ✅
        sso/route.ts                      ← SSO token issuer
  src/lib-client/pi/
    pi-auth.ts                            ← loginWithPi + refresh + dedup
    pi-payment.ts                         ← U2A/A2U flows
    pi-session.ts                         ← piSession state machine
```

---

## 3. PAYMENTMODAL — Cross-App Payment

```typescript
// After success:
window.location.href =
  `${returnUrl}?payment_status=success&txid=${txid}&payment_id=${id}`;

// On close/cancel:
window.location.href = returnUrl;
```

---

## 4. SSO PROVIDER

```typescript
const token = await new SignJWT({
  accessToken: userAccessToken,
  user:        userData,
  jti:         randomUUID(),       // replay protection
})
.setProtectedHeader({ alg: 'HS256' })
.setExpirationTime('5m')          // short-lived
.sign(secret);
```

---

## 5. OPEN ISSUES

```
⚠️ NEW-A: NEXT_PUBLIC_API_GATEWAY_URL في 30+ BFF routes
⚠️ prisma/schema.prisma موجود في frontend repo (anti-pattern)
```