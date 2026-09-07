# Pi Testnet gate — what actually broke, and the recipe for the fleet

**Date:** 2026-09-06 · **Scope:** `tec-payment-service` · every app frontend · Pi Developer Portal
**Companion to:** `audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` (the plan). **This is the outcome.**

**Truth State:** [Current State] · **Verification:** [Runtime Verified] (Connection Mode 2) · **Governance:** [Draft]

> Read this before touching another app's testnet path. Four separate defects sat between
> "the plan is right" and "a Test-Pi payment completes". Not one of them was visible in the
> plan, in a code review, or in any log until the exact moment it was hit. Connection paid
> for all four; the other 22 apps should not have to.

---

## 1 · What is proven

| | Mainnet | Testnet |
|---|---|---|
| **Mode 2** — pay inside the app | ✅ working (verified after the change) | ✅ **working** |
| **Mode 1** — pay via the Hub modal | ✅ working | ❌ hangs — **by design**, see §4 |

**Checklist step 10 needs Mode 2 only.** Mode 1 on testnet is not a blocker for any domain.

---

## 2 · The four defects, in the order they surfaced

Each one hid the next. That is the important part: fixing one did not reveal progress, it
revealed the following wall. Anyone repeating this on another app will meet them in the same
order unless the fixes ship together.

### D1 — the login returned to the OTHER host

```ts
const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? 'https://<app>.tecosystem.app';
ssoRedirect(HUB_URL, `${APP_URL}${target()}`);
```

A visitor signing in on `tec-<app>.vercel.app` handed the Hub the **Mainnet** origin as their
return address. The Hub authenticated correctly and returned them to the other host, where the
session then lived. The Testnet host stayed `Unauthorized` — **with nothing in any log**,
because nothing failed.

**Fix:** `window.location.origin`. The Hub validates the target against its own
`ALLOWED_TARGETS`, so nothing is weakened.

> `FollowCta` in the same repo had used `location.origin` all along. **Two call sites in one
> app disagreed and the wrong one was the login.**

### D2 — the session cookie carried a Domain the host was not under

```ts
domain: process.env.COOKIE_DOMAIN ?? process.env.NEXT_PUBLIC_SSO_DOMAIN ?? undefined
```

A cookie's `Domain` must be the request host **or a parent of it**. `.tecosystem.app` is not a
parent of `tec-<app>.vercel.app`, so the browser **rejected every `Set-Cookie`** — silently.
`vercel.app` is on the Public Suffix List, so no wildcard cookie could be set there anyway.

**Fix:** `cookieDomainFor(host, configured)` — the configured domain only where it genuinely
covers the host, host-only otherwise. **On the Mainnet host this is a no-op.** The
`document.cookie` fallback also lacked `Partitioned` (C-123 LAW 3), and the Testnet host is
precisely where that fallback is what carries the session.

> Host-only is not a downgrade. The alternative is not a broader cookie — it is **no cookie**.

### D3 — `sandbox: true` silenced the Pi bridge

The plan said "`*.vercel.app` → Testnet", and that was read as "so set `sandbox: true` there".
It is not the same switch. The result:

```
Pi auth failed: Messaging promise with id 1 timed out after 120000ms.
```

The SDK's **first** message to Pi Browser was never answered. Same host, same build, that one
flag `false` → the wallet opened.

**Three different axes, and they had been collapsed into one:**

| | decides |
|---|---|
| **the HOST** | which Pi **app** the visitor is in |
| **the app's API KEY** | which **network** Pi processes the payment on |
| **`sandbox`** | that the SDK talks to Pi's **Sandbox environment** — a third thing |

A paired Testnet app in Pi Browser is a **normal app on its own domain**. It is not the sandbox.

**Fix:** default `sandbox: false` everywhere; `?pi_sandbox=1` on the Testnet host only.

### D4 — approve was posted to a blockchain node

With the Testnet key finally wired (`apiKeyLength: 64`), the call went out and returned:

```
url: https://api.testnet.minepi.com/v2/payments/…   status: 404
body: { "type": "https://stellar.org/horizon-errors/not_found", ... }
```

A **Horizon** error. The Platform API answers in its own shape
(`{"error":"payment_not_found","error_message":…}`) — visible in the same service's Mainnet
logs. `api.testnet.minepi.com` is Horizon for Pi Testnet, and approve was being posted to a node
that has never heard of a payment id.

**The repo already knew this.** `pi-tx.ts` and `pi-a2u.ts` both resolve
`api.(mainnet|testnet).minepi.com` as `PI_HORIZON_URL` and both keep the Platform base at
`api.minepi.com`. A third file contradicted two that were already right.

**Fix:** the Platform host does not vary by network. The **key** does.

---

## 3 · The recipe for one app

Six changes. They must ship together — each one only exposes the next.

| # | File | Change |
|---|---|---|
| 1 | `src/lib/pi-network.ts` *(new)* | `isTestnetHost` (anchored to the end of the host) + `networkMetadata` — present **only** when true |
| 2 | `src/app/api/bff/payment/create/route.ts` | drop the client's `testnet` **before** the spread; add `...networkMetadata(req.headers.get('host'))` |
| 3 | `src/lib/cookie-domain.ts` *(new)* + `sso-callback` | `cookieDomainFor(req.nextUrl.hostname, …)`; add `partitioned` to the `document.cookie` fallback |
| 4 | `src/app/layout.tsx` | `sandbox` from the host, **default false**, `?pi_sandbox=1` override confined to the Testnet host |
| 5 | `src/app/page.tsx` (login) | SSO return address → `window.location.origin` |
| 6 | `src/lib/pi-payment.ts` | Hub `return_url` → `location.origin`; `onError` must not read `.message` off a non-Error |

Backend, once for the fleet:

| | |
|---|---|
| `getPiApiKey` | `PI_API_KEY_<SLUG>_TESTNET`, **no fallback** to the Mainnet key — a fallback turns a missing env var into a 502 that names nothing |
| `getPiBaseUrlFor` | network-**independent**; a test refuses any `api.(testnet\|mainnet).minepi.com` from it |
| `SubscriptionConsumer` | refuses to activate a paid plan from a payment marked `testnet` — Test-Pi clears any amount floor, so the floor cannot catch it |

Ops, per app: **`PI_API_KEY_<SLUG>_TESTNET`** on `tec-payment-service`, then redeploy.
**That is the pacing item** — 24 keys created by hand in the Portal.

---

## 4 · Mode 1 on testnet is a boundary, not a bug

```ts
const HUB_URL = process.env.NEXT_PUBLIC_HUB_URL ?? 'https://hub.tecosystem.app';
```

Mode 1 hands the payment to the **Hub** — a *different Pi app*, on a *Mainnet host*, approved
with the Hub's Mainnet key. A Test-Pi wallet cannot pay it, so it hangs.

Making it work needs the Hub to take changes 1–5 **and** `redirectToHubPayment` to send a
Testnet visitor to the Hub's Testnet host. That is **the same build-time-constant bug a third
time** (`APP_URL`, `sandbox`, now `HUB_URL`).

**Deliberately not done.** It is not on the Portal checklist and blocks no domain.

---

## 5 · What the instrumentation was worth

The Pro card gained a stage line — `⚙ approving · sandbox=false` — shown only on the Testnet
host or with `?debug=1`, plus a seconds counter.

Honestly: **it did not find D3.** The app's own existing error text did (`Pi auth failed:
Messaging promise…`). What it changed is that the answer now arrives **by default rather than
by luck** — "Confirm in Pi…" covered both `Pi.authenticate` and `Pi.createPayment`, and neither
tells any server anything until the SDK calls back. Without a clock, a stall and a slow network
look identical.

---

## 6 · Rules that generalise beyond Pi

1. **One build cannot hold a per-host fact.** `NEXT_PUBLIC_*` is baked once; two hosts served by
   one deployment need the value read at request time. This bit three separate constants.
2. **A silently rejected cookie leaves no trace anywhere.** When "logged in but unauthorized"
   has no error on either side, suspect the cookie attributes before the auth logic.
3. **Read the files that already solved it.** D4 was contradicting two correct files in the same
   service.
4. **A fallback that hides which input was missing is worse than a hard failure** — the reason
   the Mainnet key is not used when the Testnet one is absent.
5. **Fix them together or you learn one per round trip.** Each defect masked the next, and each
   round trip is a human with a phone.

---

## 7 · Stated as unverified

| | |
|---|---|
| Is `api.minepi.com` correct for a **Testnet app's** Platform calls? | **Strongly indicated, not confirmed by Pi.** The Horizon error body proves the old host was wrong; `pi-a2u.ts`/`pi-tx.ts` show the intended split. Confirmed when a testnet approve returns 200. |
| Does `sandbox: false` on the Testnet host hold generally? | **One clean A/B, one trial.** Same host, same build, only the flag differed. |
| The 22 remaining apps | **`[Code Verified]` only.** Each still needs its Testnet key, a redeploy, and its own step 10. |
| Mainnet regression | Reasoned from the code paths **and** confirmed by one live Mainnet payment after the change. Every app's Mainnet path is unchanged by construction: `testnet` is absent, not `false`, and every consumer tests `=== true`. |

---

## Related

`audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` (the plan) ·
`C-12_Dual_Mode_Payment.md` §11 (per-app Pi key · approve→502) ·
`C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` (LAW 3 — `none+secure+Partitioned`) ·
`C-76___ADR-007.md` (dual-mode payment)
