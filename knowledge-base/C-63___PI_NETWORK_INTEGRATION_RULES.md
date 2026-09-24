# C-63 — PI NETWORK INTEGRATION RULES

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


Pi Browser + Pi SDK + Mainnet — the unified rules

⚠️ READ THIS BEFORE ANY Pi SDK CODE
✅ TEC is on Mainnet — PI_SANDBOX=false, always, no exceptions
✅ Pi Browser = a WebView — not a standard browser
✅ Every payment is real — real Pi transactions

## 1. Rule one — MAINNET ONLY

```typescript
// ✅ ALWAYS — في كل مكان بدون استثناء
Pi.init({ version: '2.0', sandbox: false, appId: NEXT_PUBLIC_PI_APP_ID });
PI_SANDBOX=false  // Railway env var
PI_SANDBOX=false  // Vercel env var

// ❌ NEVER في production
Pi.init({ sandbox: true });
PI_SANDBOX=true
```

## 2. PI APP ID — mandatory isolation

Every app has its own Pi App ID — not shared

| App | Env Var |
|-----|--------|
| Hub | `NEXT_PUBLIC_PI_APP_ID=hub_app_id` |
| Commerce | `NEXT_PUBLIC_PI_APP_ID=commerce_app_id` |
| Assets | `NEXT_PUBLIC_PI_APP_ID=assets_app_id` |
| Ecommerce | `NEXT_PUBLIC_PI_APP_ID=ecommerce_app_id` |

## 3. Pi.init() PATTERN — the same code in every app

```typescript
const piInitScript = `(function(){
  var tries = 0;
  function setReady() {
    window.__TEC_PI_READY = true;
    window.dispatchEvent(new Event('tec-pi-ready'));
  }
  function initPi() {
    if (tries++ >= 40) { window.__TEC_PI_ERROR = true; return; }
    if (typeof window.Pi === 'undefined') { setTimeout(initPi, 150); return; }
    try {
      window.Pi.init({ version: '2.0', sandbox: false, appId: '${process.env.NEXT_PUBLIC_PI_APP_ID}' });
      setReady();
    } catch(e) {
      var msg = String(e).toLowerCase();
      if (msg.includes('already') || msg.includes('initialized')) {
        window.__TEC_PI_FOREIGN_SESSION = true;
        setReady();
      } else { setTimeout(initPi, 150); }
    }
  }
  initPi();
})();`;
```

## 4. FOREIGN_SESSION — the critical rule

```
window.__TEC_PI_FOREIGN_SESSION
  false = الـ app عملت Pi.init() بنجاح — Mode 2 شغال مباشرة
  true  = Hub أو app تانية عملت Pi.init() قبلنا — Mode 2 لسه شغال!

✅ CRITICAL: الـ flag informational فقط
✅ Pi.createPayment() يشتغل في الحالتين
❌ NEVER تمنع payment بسبب FOREIGN_SESSION=true
```

## 5. Pi.authenticate() — the mandatory order

```typescript
window.Pi.authenticate(
  ['username', 'payments'],
  async (incomplete) => {
    const pid = incomplete?.identifier;
    if (!pid) return;
    await fetch('/api/bff/payment/resolve-incomplete', {
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify({ pi_payment_id: pid }),
    }).catch(() => {});
  }
);
```

## 6. Pi.createPayment() — the mandatory structure

```typescript
window.Pi.createPayment(
  { amount, memo, metadata: { internalId, source, ...appData } },
  {
    onReadyForServerApproval: async (piPaymentId) => { /* POST /api/bff/payment/approve */ },
    onReadyForServerCompletion: async (piPaymentId, txid) => { /* POST /api/bff/payment/complete */ },
    onCancel: (piPaymentId) => { /* User ألغى — مش error */ },
    onError: (error, payment) => { /* Pi SDK error */ },
  }
);
// ✅ 90s timeout إلزامي
const timer = setTimeout(() => done({ status: 'error', message: 'Payment timed out' }), 90_000);
```

## 7. NAVIGATION RULES — Pi Browser Critical

```typescript
// ✅ بعد Pi Login / Logout / Cookie Mutation فقط
window.location.href = '/hub';  // full reload

// ✅ Navigation عادية
router.push('/hub/profile');

// ❌ NEVER بعد login
router.push('/hub');  // cookies مش بتتحدث في Pi Browser
```

## 8. Pi BROWSER WEBVIEW — the constraints

| Problem | Fix |
|---------|------|
| Cookies are not sent | `sameSite:'none'` on every cookie |
| `document.cookie` is required | `httpOnly:false` on `tec_access_token` |
| Pi SDK loads slowly | polling 150ms × 40 = 6s |

## 9. CHECKLIST — before deploying any app

```
□ Pi App ID مسجل في Pi Developer Portal
□ Domain يطابق التسجيل
□ NEXT_PUBLIC_PI_APP_ID في Vercel
□ PI_SANDBOX=false في Vercel
□ PI_API_KEY_[SOURCE] في Railway payment-service
□ source مضاف في getPiApiKey() switch
□ Pi.init() script موجود في layout.tsx
□ اختبر على Pi Browser (مش regular browser)
□ اختبر FOREIGN_SESSION scenario
□ اختبر incomplete payment recovery
```