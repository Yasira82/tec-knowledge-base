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

### 2.7 · Pro in every template app: the tap waited on a handshake Pi never answered

**The symptom.** After #269, every template app opened from the grid hung at Pro, then showed "Payment timed out". The payment record was created, but Pi never reached approve (NX at 16:47 and 17:10).

**The owner's two tests:**
1. The same app opened from **Pi's own app list** paid. This held for every app.
2. Opened from the **Hub grid**, it failed. This also held for every app.

**The cause.**
- The template's `PiWarmup` authenticates on load, with no tap.
- `createU2APayment` **joined** that warm-up instead of authenticating itself.
- In a tab opened through a signed handoff, Pi Browser never answers the warm-up, so the tap waited until the 90 s timeout.
- Ecommerce authenticates afresh at the tap, which is why it paid from the grid.

**The fix.** tec-template-base #45, plus the same patch in all 18 template apps:
- The SSO landing records `__tec_handoff_entry`.
- `ensureAuth({ fresh })` starts the tap's own handshake in such a tab.
- A generation guard keeps a late warm-up from undoing the result.

**Verified.** `[Runtime Verified]` on NX (Tec-Nx #39), on the owner's phone, 2026-10-02. The other 17 PRs are open.

**Found in the same logs.** Connection's nightly `purge-stories` cron POSTed with `Content-Type: application/json` and **no body**. identity-service refused it every night at 03:37 UTC, so the sweep had **never run**. Fixed in Tec-Connection #88 (`body: '{}'`).

### 2.8 · One app's Pro turned on every app's Pro, and the Hub's

**The report.** After buying NX Pro (8π), the owner found the Hub's plan on PRO and every app's Pro card already active, though only NX had been paid for.

**The cause.**
- commerce-service had ONE `Subscription` per user, the Hub's plan.
- Its `payment.completed.v1` consumer mapped every app Pro payment (`item_id` `*_pro_monthly`, ≥ 5π) onto that one plan.
- Every app read the same `GET /commerce/subscriptions/status`.
- So one app's Pro was everybody's Pro. It was designed that way, and it was wrong for what the owner sells.

**The decision (owner, 2026-10-02).** `[Governance Approved]`
- Each app's Pro card is that app's own subscription, with its own cancel button.
- The Hub's plan "has nothing to do with the apps". It is a separate benefit for the user.

**The implementation.**
- **tec-core-backend #356.** A new `AppSubscription` (one row per user per app, `@@unique([user_id, app])`).
  - The consumer sends a payment that names an app to that app's row: Mode 2 `metadata.source`, Mode 1 `metadata.app_source`. A payment with no app (the Hub's own) still goes to the Hub plan.
  - `GET …/status?app=<slug>` and `PATCH …/cancel?app=<slug>` read and cancel one app.
  - Not live → `plan: 'FREE'`, because the apps' resolvers treat any paid plan name as Pro.
  - Buying again while live adds 30 days to the end.
  - Cancel ends that app's Pro **immediately**. The Hub plan and other apps are untouched.
- **Legacy.** A Pro bought before the split (Hub plan `current_period_start` before `APP_PRO_CUTOFF`, default 2026-10-03) is honoured in every app until it ends, with `legacy: true`. People paid for what it was then; nothing renews it across apps. The owner's NX Pro of 2 Oct is such a Pro, so it shows in every app until about 1 Nov.
- **The apps.** Template #45 and 17 apps: Alert, Analytics, Connection, DX, Elite, Epic, Estate, Explorer, FundX, Insure, Legend, Life, Nexus, NX, Titan, VIP, Zone.
  - Every status read sends `?app=<APP_SOURCE>`.
  - `POST /api/bff/subscription/cancel` is added.
  - `CancelProButton` is added. It is hidden on Testnet and for a legacy Pro.
  - System has no Pro read. Ecommerce, Commerce and Assets have no Pro.
- **NBF and Brookfield were missed.** They were not attached to the session that rolled out both fixes, so after the merge they had neither (owner, 2026-10-02: "apps are missing"). Tec-Nbf #28 and Tec-Brookfield #24 bring both fixes. Their `pi-session` is newer than the fleet's, so the handshake fix was applied by hand.
- **Lesson.** A fleet rollout starts from `architecture/app-fleet.yaml` (24 apps), not from the repos a session happens to have attached.

**Order.** #356 deploys first, then the app PRs. An app merged before #356 sends a `?app=` the old service ignores, so it shows the Hub plan as before, and nothing breaks.

**The schema step that was wrong.**
- **What happened.** #356 first asked for a Railway pre-deploy `npm run db:push`. The owner added it, and Railway refused the deploy. Besides `app_subscriptions`, `db push` wanted to add unique constraints on `orders.payment_id` and `orders.pi_payment_id` that production has never had, and it stopped for `--accept-data-loss`. The refusal was right; the live deploy kept serving.
- **Why the step was wrong.** commerce-service applies its schema with `prisma migrate deploy` in `docker-entrypoint.sh` at every start. The table now ships as migration `20261002000000_add_app_subscriptions`. No pre-deploy step is needed, and the `db:push` step must be removed.
- **Root cause.** tec-core-backend's CLAUDE.md said "a deploy never touches the database", but that is true only for auth and asset. Seven services run `migrate deploy` at start. CLAUDE.md now says which service applies its schema how.
- **Rule.** Never `db push` a migrate-deploy service, and never pass `--accept-data-loss` to get past the refusal. `[Code Verified]` on Postgres 16: the pre-#356 schema with earlier migrations marked applied → `migrate deploy` applies only the new one.


### 2.9 · 3 October: the pre-split Pro, the Hub plan page, and one handshake on load

**NX showed Pro with no Cancel.**
- **What happened.** The owner's NX Pro (2 Oct) predates the split, so it sat on the Hub plan. #356 honoured it in every app as `legacy`, and the apps hide Cancel for a legacy Pro.
- **The owner's ruling.** "I want a Cancel button, like the other apps."
- **The fix, tec-core-backend #357.** On the first read from any app, a pre-split Hub-plan Pro is **moved to the app it was bought in**:
  - The app comes from the payment's own metadata (`source` / `app_source`). Commerce asks payment-service by id (`POST /payments/internal/verify {ref}`).
  - That app gets its own Pro with the remaining days. Other apps read FREE.
  - The Hub plan is closed (`CANCELLED`, with a `SubscriptionHistory` row saying why).
  - A payment that names no app stays the Hub's.
  - If the origin cannot be told, nothing moves; this needs `PAYMENT_SERVICE_URL` on commerce-service.
  - `[Code Verified]` on Postgres 16 with the built service.

**The Hub plan page showed "Pro" after a cancel.**
- **What happened.** Commerce keeps `plan: PRO` with `status: CANCELLED`. `/hub/subscription`, `/hub/profile` and `/dashboard/subscription` read `plan` alone, so they showed "Pro · Expires …". The Cancel button reads the status, so it vanished.
- **Nothing was granted.** The server gate (`plan.server.ts`) already required `ACTIVE`.
- **The fix, tec-app #271.** Adds `effectivePlan(sub)`: only a live `ACTIVE` subscription is its plan.
- **Rule.** A screen that names a plan reads `effectivePlan`, never `sub.plan`.

**What the Hub plan grants today.**
- **Assets.** FREE allows 5 assets; PRO (10π) and ENTERPRISE (50π) are unlimited. This is enforced server-side at `/api/assets` and `/api/assets/provision`.
- **Everything else.** Every other row in the plan table is "Soon" and is not built.
- **Duration.** A plan lasts 30 days with no auto-renewal. It reads FREE once cancelled or lapsed.

**One Pi handshake on load (Tec-Commerce #74, Tec-Assets #67).**
- **The problem.** Commerce's `usePiAuth` called `window.Pi.authenticate` on load. That ran at the same moment as `PiVisitSignIn`, with no Hub-session check, and Pi Browser answers neither of two concurrent calls.
- **The fix.** It was removed. Assets' copy was already deduplicated and was removed for parity. The payment still authenticates at the tap.

**Assets lint had never run.**
- **The problem.** ESLint 9 needs a flat config file and Assets had none. CI's Lint step was `continue-on-error`, so it stayed green.
- **The fix, Tec-Assets #67.** Adds Commerce's flat config, turns `no-img-element` off (as Ecommerce does), and makes the CI Lint step blocking.

**A FREE user minted a 66th asset.**
- **The problem.** The asset cap was checked only on the Hub's `/api/assets(/provision)`. An NFT minted in Assets goes upload → payment → claim, and the Hub-modal path posts to `/api/payment/create`. Neither passed the check.
- **The fix.** Both `payment/create` routes (Tec-Assets #68, tec-app #272) refuse a new asset (`nft:`) over the cap with 402 `UPGRADE_REQUIRED` **before any π moves**. Assets' upload screen asks `/api/bff/assets/quota` first, so it can say why. `domain-nft:` re-mints an owned asset and is not checked.
- **Marketplace purchases are not capped, by decision.** Buying a listed asset still adds one to the buyer's count. Owner, 2026-10-03: not now — revisit when the user base grows. `[Governance Approved]`

**"Upgrade to Pro" stopped at "Payment setup failed" in Pi Browser.**
- **The problem.** The Hub's `createU2APayment` created its payment record only when page JS could read `tec_user`, which Pi Browser hides (C-123 §3). Its calls also sent `Bearer null`.
- **The fix, tec-app #273.** The record is always created, and the server resolves the user from the cookie. Calls send the in-memory token or no header. `/api/payment/create` treats `Bearer null` as absent.
- **The same PR.** `useSubscriptionPlan().plan` is now the plan in force; the stored name is `storedPlan`. The sidebar, the dashboard Plan card and both profile pages had shown PRO after a cancel.

**A paid NFT appeared only after reopening the app.**
- **The problem.** Delivery comes from the payment's own event, a moment after Pi says "paid", so the follow-up answers 202. Every screen refreshed once on that 202.
- **The fix, Tec-Assets #69.** `followUntilSettled` re-sends while the answer is 202 (the claim is idempotent per payment), then refreshes. It covers NFT upload, domain→NFT, Marketplace buy and the Mode-1 return.

**Verified on the owner's phone, 2026-10-03.** `[Runtime Verified]`
1. "Upgrade to Pro" opens Pi's payment. After paying, the plan page and the dashboard read Pro, with Cancel.
2. A new NFT shows in the list right after payment, with no reopen.
3. On FREE at the cap, a new NFT is refused before any payment.

**The Founding 100 gift covers the Hub and every app.**
- **Decision (owner, 2026-10-03).** The six months of PRO cover the Hub **and** every app's Pro, for every Pioneer. `[Governance Approved]`
- **The problem.** The gift wrote only the Hub plan. After the split, Pioneers gifted before 3 Oct had Pro everywhere, because the pre-split rule honoured it. Pioneers gifted later had it in the Hub only.
- **The fix, tec-core-backend #358.**
  - `grantEntitlement({ allApps })` also writes one app-subscription row keyed `'*'`, which covers every app, including future ones. Apps read it after their own Pro and before the pre-split rule. It is marked `gift: true` and `legacy: true`, so it has no Cancel in an app.
  - A gift already granted gets the every-app half dated from the original grant. The admin **Re-grant** therefore brings earlier Pioneers level without adding time.
  - A referral month stays on the Hub plan only.
  - `[Code Verified]` on Postgres 16.
- **Ops.** After deploy, press **Re-grant** once on the Hub's admin Pioneers page.
- **Outcome.** `[Runtime Verified]`
  - The first Re-grant gave the 5 Pioneers with a stored id their every-app half. It still reported 3 "unresolvable": hamsa2010, mans809 and wilsonjemmy.
  - The owner's queries found all three in both databases (identity `pi_user_id` = auth `pi_uid`). The lookup had simply never reached a route: identity asked `${AUTH_SERVICE_URL}/auth/user-by-username`, but auth serves at the root, and the gateway rewrites `/api/auth` to ''. Every run had logged "0 resolved by lookup".
  - Fixed by tec-core-backend #360. #359, which made the name match case-insensitive, is correct but was not the cause.
  - Final Re-grant: 8 checked, 6 already held, 3 by lookup, **2 recovered**, 0 unresolvable. Every Founding Pioneer now has the Hub plus every-app gift.
- **Rule.** A service calling auth-service uses the root path (`/user-by-username`, `/users-by-ids`), never `/auth/…`.

---

### 2.10 · 3 October: the last unit is held before payment

**The race.**
- Ecommerce #72 asked commerce "is it in stock?" before payment.
- Two buyers could both hear "yes" for the last unit, and both would pay.
- commerce then decremented stock with a read-then-write, so the second order was refused after its money had already moved.

**The fix: a hold.**
- Stock is taken with one conditional `UPDATE … WHERE stock >= qty`, so exactly one buyer wins.
- On Postgres 16, 10 concurrent holds on stock 1 gave 1 success and 9 `Insufficient stock`, and stock ended at 0.

| Step | Where |
|---|---|
| Hold the units: a PENDING order, before Pi opens. The payment carries `metadata.order_id` (the server's own; a client's is dropped) | commerce `POST /commerce/orders/hold` · Ecommerce `payment/create` and, for Mode 1, `/api/bff/orders/hold` |
| The hold turns PAID | `payment.completed.v1` (`OrderConsumer`), or the buyer's confirm. The confirm is checked with payment-service first: completed, this buyer, this order, the full amount |
| Release | Pi Cancel (`PATCH …/cancel`), or the sweep after `ORDER_HOLD_TTL_MIN` (default 30). Each hold is released once only |
| A payment lands after its hold was released | A new order if the units are still free. Otherwise `REFUND_OWED` goes on the timeline and is logged as an error |
| Mode 1 | The Hub copies `?order_id=` (UUIDs only) into the payment metadata. Before this, a Hub-paid Ecommerce purchase created no order at all |

**Also found.**
- The old `order.consumer.ts` was never registered, and it listened on `payment.completed`, a stream nothing writes to.
- `POST /commerce/orders/checkout` marked an order PAID on a client-supplied `payment_id` alone. The Hub's `/dashboard/orders/checkout` page called it before Pi ever opened. It now verifies the payment, so that page's unpaid orders are refused.

**PRs.**
- tec-core-backend #361
- Tec-Ecommerce #73
- tec-app #274

**Deploy order.**
1. Deploy the backend first.
2. Then merge #73 and #274 in either order.
3. Until the backend is deployed, Ecommerce falls back to today's flow.

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
| tec-template-base #45 + 18 apps (Tec-Nx #39 verified) + NBF #28 · Brookfield #24 | A tap in a handoff-opened tab starts its own Pi handshake instead of joining the load-time warm-up (§2.7) |
| Tec-Connection #88 | The nightly story sweep sends a JSON body. It had never run (§2.7) |
| tec-core-backend #356 | Per-app Pro: `AppSubscription`, `status?app=` / `cancel?app=`, legacy honoured until it ends (§2.8) |
| tec-core-backend #357 | A pre-split Pro moves to the app it was bought in, with its Cancel; the Hub plan is closed (§2.9) |
| tec-app #271 | A cancelled or lapsed Pro shows as Free: `effectivePlan` (§2.9) |
| Tec-Commerce #74 · Tec-Assets #67 | `usePiAuth` starts no Pi handshake on load; Assets gets an ESLint config and a blocking CI lint step (§2.9) |
| Tec-Assets #68 · tec-app #272 | A new asset over the FREE cap is refused before any π moves, in both payment paths (§2.9) |
| tec-app #273 | "Upgrade to Pro" works in Pi Browser; the plan hook returns the plan in force (§2.9) |
| Tec-Assets #69 | A paid NFT / mint / purchase is on screen once delivered — no reopen (§2.9) |
| tec-core-backend #358 | The Founding gift covers the Hub and every app's Pro, for every Pioneer; Re-grant backfills (§2.9) |
| tec-core-backend #359 · #360 | Auth name lookup case-insensitive (#359); the re-grant's auth path fixed — it had never reached a route (#360). 2 lost gifts recovered (§2.9) |
| template #45 + 17 app PRs (Tec-Nx #40, Alert #46, Analytics #59, Connection #89, DX #45, Elite #40, Epic #48; stacked on the open #2.7 PRs elsewhere) | Each app reads and cancels its own Pro (§2.8) |
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

**The last unit.** Closed in §2.10: the unit is held before payment (tec-core-backend #361, Tec-Ecommerce #73, tec-app #274). **Watch for:** a `REFUND OWED` error in commerce-service's logs. It means a payment landed after its hold expired and the unit had sold, so that buyer is owed a refund by hand.

---

## Related Documents

- `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` §9, §12, §13: the session laws this applies
- `C-76___ADR-007.md`: Pi foreign session
- `C-12_Dual_Mode_Payment.md`: Mode 1 / Mode 2
- `audits/HUB_GRID_VISITS_NOT_COUNTED_2026-09-29.md`: the proposal and the owner's decision
