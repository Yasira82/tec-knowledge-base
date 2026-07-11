# C-12 — DUAL-MODE PAYMENT ARCHITECTURE
## أهم قاعدة معمارية في الـ Ecosystem

> **Truth State:** `[Current State]`
> **Governance State:** `[ADR Approved]` — ADR-002 + ADR-007 (C-76)
> **Verification:** `[Code Verified]`

---

## ⚠️ READ THIS BEFORE ANY PAYMENT CODE

> ✅ **Pi Network Mainnet** — PI_SANDBOX=false دايماً
> ✅ كل payment حقيقي — مش testnet

---

## 1. القاعدة الذهبية

كل app في TEC تدعم **وضعين للدفع في نفس الوقت:**

### Mode 1 — عبر Hub Redirect
```
App → hub.tecosystem.app/hub?pay=1&...
→ Hub PaymentModal → Pi.createPayment() على Hub domain
→ Redirect لـ return_url?payment_status=success&txid=X&payment_id=Y
```

### Mode 2 — مباشرة من الـ App
```
App → Pi.init() على domain الـ app
→ window.Pi.createPayment() مباشرة
→ BFF routes (/api/bff/payment/*)
→ Success في نفس الصفحة
```

---

## 2. Commerce = Reference Implementation ✅

---

## 3. __TEC_PI_FOREIGN_SESSION + hub-entry signal

| القيمة | المعنى |
|---|---|
| `false` | الـ app عملت Pi.init() بنجاح — دفع مباشر |
| `true` | Hub أو app تانية عملت Pi.init() قبلنا |

### hub-entry signal — إشارتين مش واحدة (July 2026)

`isHubNavigation()` كان بيعتمد على `document.referrer` بس. ده اتكسر لما
C-123 LAW 2 خلّى الـ SSO دخول للـ app يعدي على **landing page 200** بتكمل
بـ `location.replace()` — فالـ referrer بقى same-origin مش hub. النتيجة:
الـ apps عملت `Pi.init()` جوّه Pi Browser session مملوكة للـ Hub →
Hub PaymentModal (Mode 1) فشل بـ "Pi Network SDK was not initialized".

**العقد الحالي (كل الـ apps + template):**

```typescript
// 1) sso-callback landing script (قبل أي navigation):
if (document.referrer.toLowerCase().includes('hub.tecosystem.app')) {
  sessionStorage.setItem('__tec_hub_entry', '1');   // per-tab — نفس عمر ملكية الـ session
}

// 2) isHubNavigation() = flag OR referrer (src/lib-client/pi/hub-entry.ts):
sessionStorage['__tec_hub_entry'] === '1'
  || document.referrer.toLowerCase().includes('hub.tecosystem.app')

// 3) Pi init layer: hub entry ⇒ __TEC_PI_FOREIGN_SESSION = true + ready
//    ومن غير Pi.init() خالص — الـ init جوّه session مملوكة للـ Hub بيسمّمها.
```

> ⚠️ الـ flag مش token — ADR-001 لسه سليم. وأي تغيير في سلسلة hub→app
> navigation لازم يعيد التحقق من الإشارة دي (C-123 §8 gate 5).

---

## 4. Hub PaymentModal Flow

```
URL Params اللي Hub يستقبلها:
  /hub?pay=1
  &amount=X
  &memo=ENCODED_TEXT
  &product_id=PRODUCT_ID
  &return_url=ENCODED_RETURN_URL
  &source=commerce|assets|ecommerce

بعد النجاح:
  redirect → return_url?payment_status=success&txid=X&payment_id=Y
```

---

## 5. BFF Payment Routes

```
/api/bff/payment/create           ← ينشئ payment record
/api/bff/payment/approve          ← onReadyForServerApproval
/api/bff/payment/complete         ← onReadyForServerCompletion
/api/bff/payment/resolve-incomplete ← يحل incomplete payments
```

### create route — القواعد الحرجة:
```typescript
// ✅ userId من cookie — مش من body
const getUserId = (req: NextRequest): string | null => {
  const raw = req.cookies.get('tec_user')?.value ?? '';
  const u   = JSON.parse(decodeURIComponent(raw));
  return u?.id ?? u?.sub ?? null;
};

// ✅ API_GATEWAY_URL server-only — مش NEXT_PUBLIC_
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL
        ?? 'https://api-gateway-...';

// ✅ Idempotency-Key في كل payment call
headers: { 'Idempotency-Key': crypto.randomUUID() }
```

---

## 6. Backend Payment Lifecycle (5 States)

```
created → approved → completed ✅ (terminal)
created → cancelled ✅ (terminal)
approved → cancelled ✅ (terminal)
any → failed ✅ (terminal)
❌ NO transitions FROM terminal states
```

Patterns:
```
✅ Outbox Pattern
✅ Idempotency Keys (Redis NX)
✅ Circuit Breaker (5 failures → 60s open)
✅ Reconciliation (cron 60min)
```

---

## 7. PI_SANDBOX Rule

```typescript
PI_SANDBOX: z.enum(['true', 'false'], {
  required_error: 'PI_SANDBOX must be explicitly set'
  // ❌ NO DEFAULT
})
// ✅ Mainnet: PI_SANDBOX=false دايماً في production
```

---

## 10. Financial Integrity Rules (DB Level)

```sql
DECIMAL(20, 8)  -- ❌ NEVER Float/DOUBLE PRECISION

ALTER TABLE wallets
  ADD CONSTRAINT wallets_balance_non_negative
  CHECK (balance >= 0);  -- ✅ مطبق في production
```

---

## 11. Payment System Operations & Anti-Regression Guide (ADR-009)

> 📘 **Full runbook (source of truth for implementation):** `docs/PAYMENT_SYSTEM.md`
> in `yasira82/tec-app`. This section is the KB summary so anyone — especially
> when building a **new app** or running **tests / hardening audits** — knows the
> rules that keep payments from breaking.

### How a payment works (recap)
Two modes (§1–§9 above): **Mode 1** (app → `/hub?pay=1` → Hub modal) and
**Mode 2** (app standalone in Pi Browser). Both run the same 4-call lifecycle:
`create → Pi.createPayment → approve → complete` (+ `resolve-incomplete` / `cancel`
for recovery). The frontend never touches the payment DB or Pi server API — it
drives the browser SDK and calls its own BFF, which proxies to the gateway →
`tec-payment-service` (the only owner of payment state).

### The contract every BFF route MUST follow (ADR-009)
| Rule | Value | Why |
|------|-------|-----|
| `amount` | **number** (`z.coerce.number()`) | payment-service stores DECIMAL; a string fails. Coerce from string ONCE at the BFF boundary. |
| gateway path | **`/api/payment/*`** (singular) | gateway rewrites `^/api/payment → /payments`; plural/bare paths 404. |
| internal header | **`x-internal-key`** + `INTERNAL_SECRET` | the ONLY header the gateway validates. `x-service-secret` is ignored. |
| contract source | `@yasser172/tec-sdk` `contracts/payment.ts` | one place — never re-declare payment Zod inside an app. |
| gateway calls | one helper w/ token-refresh + `x-internal-key` | expired token must auto-refresh, else resolve/cancel leave payments stuck. |

### What broke before (do not repeat — these came from a "hardening audit")
| Symptom | Root cause | Lesson |
|---------|-----------|--------|
| Hub modal payment fails / flashes | create sent `amount` as **string** | amount is a number at the BFF |
| All apps 403 on payment POST | CSRF double-submit gate added on payment routes; cookie unavailable in Pi Browser (drops `sameSite=None`) | CSRF must accept first-party **Origin**, not cookie-only |
| ecommerce Mode-2 payment **and order creation** 403 (after the middleware was already fixed) | a **duplicate** strict double-submit CSRF check living *inside the BFF routes* (`payment/create`/`approve`/`complete` + `orders`) — on top of the middleware. In Pi Browser the dropped cookie made the route reject the request even though the middleware had passed it | CSRF in **ONE** place only — the middleware. A route must **never** re-validate CSRF (P2 No Rule Duplication). Commerce/Assets had no route check and worked; ecommerce + Hub did, and broke |
| Assets mint recorded 1π not real price | a divergent client → legacy approve hardcoded `amount:1` | one payment client per app |
| `x-service-secret` / `/payments` 404 | a parallel BFF stack | canonical `/api/payment/*` + `x-internal-key` only |
| "Pending Payment Found" never clears | resolve/cancel didn't refresh expired token | auto-refresh; cron reconciles via Pi |
| Analytics Mode-2 payment "Payment Expired" / **approve 502** (create was 201) — Analytics 2026-07-03 | payment-service `getPiApiKey` had **no case** for the new `analytics` source → the approve call used the **default (Hub) Pi API key**; Pi rejects a key that doesn't match the payment's own Pi App ID (`analytics-822d98…`) | an app that pays under its **OWN Pi App ID** must be approved with its **OWN** `PI_API_KEY_<SOURCE>`. Resolution is now data-driven (`PI_API_KEY_<SOURCE>` for any source) and a missing-key fallback is **never silent** — loud `error`, Forbidden Behavior #6 |
| Analytics: admin view vanished + logout dead + "Something went wrong" crash | (a) `role` was snapshotted in the session token and never refreshed; (b) logout relied on an XHR `Set-Cookie` (C-123 LAW 1 — unreliable in Pi Browser); (c) a gateway error **object** `{code,message}` was rendered as a React child (#31) | role is re-read from DB on refresh + read from the token client-side; logout clears cookies client-side then hard-navigates; **coerce any error to string** before rendering |
| System: standalone **login 404** (`C_HUB_URL/api/auth/sso`) **and** the Mode-1 payment button 404s (`C_HUB_URL/hub`) — System 2026-07 | `NEXT_PUBLIC_HUB_URL` was set in Vercel to the literal **placeholder** `C_HUB_URL` (copied from a setup doc), so both `ssoRedirect(HUB_URL,…)` and `redirectToHubPayment` (→ `${HUB_URL}/hub`) navigated to a non-existent host. `NEXT_PUBLIC_*` is **inlined at build time**, so the bad value overrode the code's correct `?? 'https://hub.tecosystem.app'` fallback, and it only takes effect after a **redeploy** | A `NEXT_PUBLIC_*` URL env must be a **real `http(s)` URL or unset** — a placeholder becomes a redirect target. Resolve it defensively: accept the env value **only if** it matches `^https?://`, else use the canonical fallback (a garbage value can never become a redirect target). Now in `tec-template-base` (`src/lib/pi-payment.ts` + `src/app/page.tsx`) → all future apps inherit it. Changing a `NEXT_PUBLIC_*` var requires a **redeploy** (build-time inline) |
| System + Explorer: Mode-2 standalone **"Payment Expired" / approve → Pi 404 `payment_not_found`** (create was 201) — System 2026-07 | `APP_SOURCE` was defined in **TWO** files (`src/lib/pi-payment.ts` **and** `src/app/api/bff/payment/create/route.ts`); the create route was left at the template default `'app'` while the client was set to the real slug, so the payment was recorded as **`source='app'`**. payment-service resolved `PI_API_KEY_APP` (unset) → **default (Hub) key** → Pi rejects a payment that belongs to the app's own Pi App → 404 → approve 502 → "Payment Expired". Railway log signature: `Unknown payment source="app" — using default PI_API_KEY`. The dedicated key (`PI_API_KEY_SYSTEM`) was correct all along; the **source never reached it**. Note: a merge that lands *before* the fix commit + a Vercel "Redeploy" of the **old** build re-runs old code → looks like "the fix did nothing" (verify the deployed commit) | `APP_SOURCE` is now a **single source of truth** — `src/lib/app-source.ts`, imported by BOTH the client helper and the create route, so they can never drift. CI (`payment-policy`) **fails the build** if `app-source.ts` is still `'app'` on a real app (skipped for the template via its package name). Diagnose from the Railway payment-service log: `source="…"` tells you exactly which key will be used |

### Rules for a NEW app (and before any tests / updates)
1. Import payment request/response shapes from `@yasser172/tec-sdk` — never local Zod; `amount` = number.
2. All payment BFF calls use the shared gateway helper (token-refresh + `x-internal-key`).
3. Every buy handler keeps the ADR-007 `isHubNavigation()` guard (Mode 1 vs Mode 2).
4. CSRF middleware accepts double-submit **OR** first-party Origin (`Origin host === Host` / `*.tecosystem.app`).
5. Keep the **CI policy guards** (`.github/workflows/ci.yml`): fail on `x-service-secret` / `SERVICE_SECRET` / `z.string()` for amount, **and on any route-level CSRF check** (`csrfCookie !== csrfHeader` / `CSRF validation failed` / `CSRF token mismatch` under `src/app/api`) — CSRF is middleware-only. Forwarding `x-csrf-token` to a downstream call is fine; *validating* it in a route is forbidden.
6. Never change `/hub?pay=1`, the cookie names, or the gateway path scheme without an ADR (C-76 / ADR-007 / ADR-009).
7. Stuck/orphan payments self-heal hourly via `tec-payment-service` reconciliation (Pi = source of truth; never blind-fail a paid payment).
8. If the app has its **own Pi App ID** (not the Hub's), wire `PI_API_KEY_<SOURCE>` on `tec-payment-service` — `getPiApiKey` resolves `PI_API_KEY_<APP_SOURCE.toUpperCase()>`. Approving under the default (Hub) key fails with a 502 (Analytics 2026-07-03). A missing key for a known source now logs a loud `error`, never a silent fallback.
9. `NEXT_PUBLIC_HUB_URL` / `NEXT_PUBLIC_APP_URL` (and any redirect-target env) must be a **real `https://` URL or unset** — a placeholder like `C_HUB_URL` becomes the login + Mode-1 payment redirect target → 404 (System 2026-07). The template resolves these defensively (env value used only if it matches `^https?://`, else canonical fallback). `NEXT_PUBLIC_*` is **inlined at build time** → after changing it you MUST redeploy (a Testnet-vs-Mainnet Linked-App mismatch is a *separate* payment blocker — see §7 / the FundX lesson).
10. **Set `APP_SOURCE` in exactly ONE place** — `src/lib/app-source.ts` (the client helper + the `payment/create` route both import it; they must never disagree). It must match the `PI_API_KEY_<SOURCE>` you set on `tec-payment-service`. If a payment is recorded as `source='app'` (the template default), Mode-2 approve fails with **Pi 404 `payment_not_found`** (System + Explorer 2026-07). CI blocks a still-`'app'` slug. **Diagnostic:** the Railway payment-service log line `Unknown payment source="…" — using default PI_API_KEY` names the wrong source; a healthy Mode-2 shows `source="<slug>"` then `Calling Pi API: approve … source: <slug>`. And when a "fix" seems to do nothing, confirm the **merge reached `main` AND the deployment rebuilt the new commit** — a Vercel "Redeploy" of an old build re-runs old code.

> **Truth State:** `[Current State]` · **Verification:** `[Code Verified]` (PRs merged June 2026)
> **References:** ADR-009 (C-64) · ADR-007 (C-76) · C-47 · C-71 Financial Integrity · `tec-app/docs/PAYMENT_SYSTEM.md`