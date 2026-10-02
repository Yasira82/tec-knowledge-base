# Hub grid → apps: payments, the visit count, and Android's Back (2026-10-02)

**PLACEHOLDER: no `C-NN` assigned.** Numbering is a human decision (`.cursorrules` RULE 6).

**Date:** 2026-10-02

**Truth State:** `[Current State]`.

**Governance State:** `[Governance Approved]`. The owner approved opening grid apps standalone on 2026-10-02 (`audits/HUB_GRID_VISITS_NOT_COUNTED_2026-09-29.md` §4).

**Verification:**
- Each cause is `[Runtime Verified]`: Vercel and Railway logs and phone screenshots from the owner, 2026-10-02.
- Each fix is `[Code Verified]` on `tec-app` main (#266 → #270) and `Tec-Ecommerce` main (#72).
- The end state is `[Runtime Verified]`. On the owner's phone, after #270:
  1. A grid app opens signed in.
  2. A purchase inside it completes.
  3. Android's Back returns to `hub.tecosystem.app/hub`, signed in.

The rules this left behind are in **C-123 §13**.

---

## 1 · The report

> "If I pay in the Hub first, then paying from an app fails. If I pay in the app first, both work."

The failing payment ended on the Hub's payment modal with `Pi auth (TIMEOUT): TIMEOUT`.

---

## 2 · Causes, in the order they were found

### 2.1 · The payment: the Hub inside an app's Pi session (C-123 §9)

**The Mode 1 trace.** The Mainnet "Show details" trace (tec-app #265) of the failing Mode 1 hop from Ecommerce read:

```
0.0s  from ecommerce.tecosystem.app
0.0s  SDK ready — warming the Pi session
1.7s  tap: joining the warm-up already in flight
89.5s tap: auth FAILED TIMEOUT / TIMEOUT
```

- **Pi never answered** the Hub's `Pi.authenticate`. There was no error and no rejection; only our 90-second budget ran out.
- Pi Browser's address bar read `…ommerce.tecosystem.app` while the Hub's modal was on screen. The tab belonged to the app, and the Hub was a guest in the app's Pi session.
- This is C-123 §9: the reverse foreign session.

**The other order.** "App first" worked because the app was opened standalone and paid **Mode 2**, inside itself. It never sent the payment to the Hub.

**Server logs agree.** Two Hub `payment/create` calls, at 09:04:55 and 09:06:58, were never completed.

### 2.2 · The visit count: grid visits counted for the Hub

- The grid opened apps through the Hub's SSO, so the app saw the Hub as referrer.
- It then marked the tab Hub-owned (ADR-007), skipped the Pi SDK and never signed the visitor in with Pi.
- So Pi credited the **Hub** for every grid visit, and never the app (`audits/HUB_GRID_VISITS_NOT_COUNTED_2026-09-29.md`).

### 2.3 · Same tab: Pi stays with the Hub (tec-app #268, reverted)

Opening the app in the **same** tab, so that Back would return to the Hub, made things worse.

| Ecommerce visit | How it was opened | `payment/create` | What happened next |
|---|---|---|---|
| 15:29, 15:30, 15:33, 15:38 | Hub grid, same tab | 201 | **no approve**, then "Payment timed out" |
| 15:31 | standalone (`/`) | 201 | approve → complete → order ✅ |

- **The Pi session belongs to the tab's first app.** A tab that started on the Hub stays the Hub's at Pi, even on another domain. Its address bar kept reading `hub.tecosystem.app/hub` while Ecommerce was on screen.
- **Only a NEW tab gives the app its own Pi session.**

### 2.4 · Back: Pi Browser returns to the Hub app's ROOT

- **What Back did.** Android's Back from the app's tab did not land on `/hub`. It landed on **`hub.tecosystem.app`**, the root `/`, which is the Hub app's own URL. The owner's two screenshots showed it.
- **The visitor was signed in there.** The page showed the signed-in variant: the small gold "Sign in with Pi" link to `/hub`, not the Pi button.
- **Why it did not go on to `/hub`.** `/` forwards a signed-in visitor only to a **remembered** destination (`takeReturn`). The campaign always left one; the grid never did.
- **Two attempts that missed.** #267 and #269 reacted only on `/hub`, so they never fired.

### 2.5 · Stock: paid, then the order was refused

- **What happened.** The Cap showed OUT OF STOCK in Commerce, and Ecommerce still took 12π for it.
- **Why.** commerce-service checks stock only when the **order** is created, which happens after Pi has moved the money. The buy screen also ignored the order call's answer.

### 2.6 · commerce-service

**`OrderStatus` mismatch.** The production `OrderStatus` enum has no `PROCESSING` value. Ecommerce sent order lines as `{productId, qty}` (fixed in #354).

**Event dropped after restart.** The ioredis client ran with `enableOfflineQueue: false` and was created lazily. As a result, the first `order.paid.v1` after every restart was dropped:

```
Stream isn't writeable and enableOfflineQueue options is false
```

---

## 3 · Fixes

| PR | What it does |
|---|---|
| tec-core-backend #354 | Ecommerce orders accept `productId`/`qty`. Seller sales filter on the statuses production has. A first subscription read survives a P2002 race |
| tec-core-backend #355 | `enableOfflineQueue: true` with `maxRetriesPerRequest: 3`. The first `order.paid.v1` after a restart is no longer lost |
| tec-app #265 | A failed Hub payment can show its timed steps on Mainnet ("Show details") |
| tec-app #266 | The grid opens each app on its own domain: a signed handoff (`/api/auth/sso-links`), `rel="noopener noreferrer"`, new tab. Also adds the `Pi.init: fresh / ALREADY` trace line |
| tec-app #267 | `usePiAuth({ silentOnLoad })`. HubContinue ("Continue with Pi") on `/hub` instead of leaving for `/` |
| tec-app #268 | Same tab. **Reverted by #269** (§2.3) |
| tec-app #269 | New tab again. In Pi Browser, identified by user agent, a session-less `/hub` shows HubContinue. A desktop keeps the redirect to `/` |
| tec-app #270 | **The Back fix.** A grid tap calls `rememberReturn('/hub')`. Back → `/` → signed in → `/hub` |
| Tec-Ecommerce #72 | `payment/create` asks commerce-service before any π moves: ACTIVE, in stock, priced at the amount paid. Otherwise 409 `OUT_OF_STOCK` / `PRODUCT_UNAVAILABLE` / `PRICE_CHANGED`, or 503 `CHECK_FAILED` (P6). Sold-out cards show "Out of stock" |

**Ecommerce #72 also closes a second hole.** A client could have paid 1π for a 580π product. The amount check now refuses it.

---

## 4 · Wallets (owner, 2026-10-02)

**No TEC app has a Mainnet app wallet.**
- The only one is the Hub's A2U wallet, which is still under Pi review (C-02 row 6).
- The first draft of the grid audit said each app had one. That was `[Assumed]` and wrong.

**Mode 2 payments land in the owner's own Pi wallet.** Five 12π Ecommerce payments appear there as "Payment Received" (`[Runtime Verified]`).

**So the grid change needed no new wallet and no Pi approval.**

---

## 5 · Still open

**The apps' Mode 1 fallback.** In a standalone tab, the app owns the Pi session. If an app falls back to Mode 1 there (Pi not ready, or a `__tec_hub_entry` left in the tab), it sends the buyer into §2.1. **Remedy, if seen:** the app shows a retry message instead of bouncing to the Hub.

**The last unit.** Ecommerce #72 is a pre-check, not a reservation. Two buyers can still race for the last unit, and commerce-service's order-time check stays the final word. **The full fix:** reserve the unit before payment (`/commerce/orders/reserve` exists).

---

## Related Documents

- `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` §9, §12, §13: the session laws this applies
- `C-76___ADR-007.md`: Pi foreign session
- `C-12_Dual_Mode_Payment.md`: Mode 1 / Mode 2
- `audits/HUB_GRID_VISITS_NOT_COUNTED_2026-09-29.md`: the proposal and the owner's decision
