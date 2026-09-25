# Session 56r — anyone could take an Assets listing for free, and approve never compared the amounts (24 Sep 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** on a phone, 24–25 Sep
> (§4b · §4g). PRs: tec-core-backend #334–#342 · Tec-Assets #59–#62 · tec-app #257 ·
> Tec-Estate #39–#40 · tec-template-base #41 · tec-knowledge-base (this record).

## 1. What was asked, and what was found

The request was C-02 §2 item 4: "Assets: no repair path for a paid purchase". Reading the
code before writing any turned up something worse than a missing repair path.

| # | Finding | Severity |
|---|---|---|
| 1 | `POST /assets/marketplace/:id/buy` took `buyerId` + `paymentId` from the body and checked only that the id had not been used. It never checked that the payment **existed**. The gateway proxies it for any valid JWT → an invented UUID transferred someone's asset | P0 — theft of a seller's property |
| 2 | `POST /assets/:id/mint-as-nft` and the NFT path of `/assets/provision` had the same flaw; Tec-Assets' `nft/register` even **invented a UUID** when the payment id was not one | Free NFTs |
| 3 | payment-service **approve never compared Pi's amount with the recorded amount**. The record's amount is what the client sent to `/create`; the wallet's is a separate call. Every consumer prices against the record (commerce's plan floor too) | P0, platform-wide |
| 4 | Tec-Assets `assets/mint-as-nft` BFF read `assetId`/`userId`; the app sends `asset_id` and no user → **every paid domain mint answered 400** | Paid, never delivered |
| 5 | Tec-Assets `createHandler` wrapped a returned `Response` in `Response.json()` → `{}` with 200. **Ten routes** lost every status and body; `domains/check` answered `{}`, so **every domain showed as "taken"** | Registration blocked |
| 6 | The repair path the 56m record asked for: none existed; a comment promised "the webhook will catch it" | Paid, nothing delivered |

Correction to the 56m record: all three purchase kinds ARE repairable from the event — the
NFT's name and image travel inside the payment's own `product_id` (`nft:<base64>`).

## 2. What was built

**tec-core-backend #334**
- `PaymentReceipt` (table `asset_payment_receipts`, additive), written **only** from
  `payment.completed.v1`: payer, amount and product are the payment's own.
- `PurchaseConsumer` (group `asset-purchases`) records the receipt and delivers the purchase
  — this is the repair path. `PurchaseService` is the single place a paid action happens,
  for the event and the browser alike: payer check, price/fee covered (1e-8 units), Test-Pi
  grants nothing, a listing sold by conditional update (of two payers exactly one wins), a
  refusal after money moved recorded once with its reason and logged `REFUND NEEDED`.
- `buy` / `mint-as-nft` (same URLs) + new `POST /assets/purchases/:paymentId/claim`:
  202 pending until the receipt exists · 403 someone else's payment or `x-user-id` ≠ body ·
  409 other product or refused.
- payment-service approve reads the payment from Pi first; if Pi's amount does not cover
  the record → 422 `AMOUNT_MISMATCH`, record `created → failed`, audit row, and Pi is never
  told "approved" — nothing moves.
- `asset-purchases` added to the stream-health map and `verify-runtime.mjs`.
- Tests: asset-service 81/81 (29 new) · payment-service 221/221 (4 new).

**Tec-Assets #59** — `nft/register` claims instead of provisioning (no invented ids);
`mint-as-nft` reads `asset_id` and the session user; `createHandler` passes a `Response`
through; `readFollowUp` makes 202 "delivering shortly" and 409 a refund, not "already done".
186/186 (12 new).

## 3. Deploy — what actually happened (24 Sep, evening)

- #334 merged → asset-service deployed with the new routes and `Purchase Consumer started`
  (`REDIS_URL` set), but with **no `db:push` in its logs** — the start-command change had
  not been applied (Railway stages a settings edit until you Deploy it).
- Applied, redeployed: `db push` → `The database is already in sync` — the table exists —
  **but repeating every ~2 s with no Nest line between**: a crash loop, with
  `--skip-generate` present and `/app` owned by `appuser`. Restoring `node dist/main`
  ended it (deploy `2e3ede48`: one `Purchase Consumer started`, no loop).
- Cause not identified; npm's banner shows the command ran under a shell. The documented
  method therefore changed to a **pre-deploy step** (tec-core-backend #335).

## 4. The second half — `provision` and the owner routes (tec-core-backend #336)

- `POST /assets/provision` never looked the payment up — a domain, NFT or property could be
  registered with an invented id. Worse, Tec-Assets registers domains through the Hub's
  `/pay` page, which takes its **price from the URL**: `price=0.01` bought a 5π domain, and
  the approve check from #334 could not see it (record and Pi payment both said 0.01).
- Now provision asks payment-service (`/payments/internal/verify`, which gained `ref` = our
  id or Pi's): completed · same user · not Test-Pi · made FOR this kind of asset
  (`domain-reg-*`, `nft-mint-*`, `estate_listing_fee`) · covers the fee (domain 5/3/2/1π by
  length, NFT 2π, property 3π). The stored transactionId is payment-service's id — one
  payment, one asset. Unverifiable → 503, never a free asset. No caller had to change.
- Marketplace `list` / `price` / `cancel` and asset `delete` took the owner from the body;
  they now require the gateway-verified `x-user-id` to be that owner.
- Ops before deploy: `PAYMENT_SERVICE_URL` on asset-service.

## 4b. Verified on the phone (24 Sep, evening)

- **NFT "Ey" (2π)** — delivered from its payment receipt (#334 + Tec-Assets #59).
- **Property "Test Villa" (3π, Estate Mode 2)** — registered only after payment-service
  confirmed the payment (#336; `PAYMENT_SERVICE_URL` set on asset-service).
- **Listing it for 50π** succeeded — proving the owner check lets the real owner act — and
  exposed that the marketplace would sell a **property for Pi**, which C-114 §4/§6 forbids.
  Closed in tec-core-backend **#337** (one list, `common/tradable.ts`: refused at listing,
  hidden from browsing, never reserved by a saga, a paid purchase of one is a recorded
  refund) + Tec-Assets **#60** (no "List for Sale" on a property). The test listing is to
  be cancelled by its owner.
- Estate registration opened FROM the Hub (Mode 1) loses the form on the return trip, so
  the property is not registered — a pre-existing gap, found while writing the test steps.

## 4c. Properties leave Assets; "why not an NFT?" becomes ADR-014

- Tec-Assets **#61**: `REAL_ESTATE` left out of the Assets list — the record stays in
  asset-service and in Estate; nothing was deleted. In Assets it was a 0π card with a
  Transfer button to a missing route and a "Delete NFT" that would erase Estate's record.
- Nine code comments cited "C-114 §12" for storing a property as an asset; §12 is the
  Integration Map and never said it. The decision is now written in C-114 → Deployment
  Status → Property records (KB #165), and the comments point there (backend #338, Estate #39).
- The owner asked why a property is not minted as an NFT. **C-64 ADR-014 (PROPOSED)**: never
  a tradable token (a sale of the property for Pi by another name, no legal title, and the
  record is unverified); a non-transferable, Zone-verified **Property Certificate** may come
  later, hard-gated on Zone verification + legal review + the Phase 0 exit. **Accepted by the
  CEO the same day**, with one fix: the ADR had the certificate shown by Legend in one clause
  and by Estate in another — now one owner per concern (record: asset-service · verification:
  Zone · with the property: Estate · as an achievement, from an event: Legend).

## 4d. Checking the leftovers before fixing them — one was wrong

Asked "are you sure we haven't done Assets?", each leftover was checked against git history:
- **Undelivered domain→NFT mints — real, narrower than recorded.** The button sent
  `assetId` + `userId` from 3 May (it worked); from **30 May** (`78a1916`, `8ab0fc6`) it sent
  `asset_id` and the BFF answered 400, until **24 Sep** (#59). Not "every" mint — that window.
  A read-only report now lists them (backend #339: payment-service
  `GET /payments/internal/completed` + asset-service `dist/scripts/reconcile-purchases.js`).
- **Transfer — real.** `/api/assets/:id/transfer` never existed in asset-service; the button
  failed every time (no Pi involved). Removed rather than built — a new, sensitive feature
  (Tec-Assets #62).
- **"No domain-registration entry point" — not a gap.** `AddDomainModal` was unmounted on
  30 Apr, the day it was added (`9e10817`): a decision. Its leftover code was deleted (#62).

Pushes now go without force: the branch is rebuilt on its remote copy with `main` merged in.
Tec-Assets' and tec-knowledge-base's rulesets still report "bypassed" for a plain fast-forward
push to a `claude/*` branch (tec-core-backend's does not) — rulesets that cover every branch,
not only `main`.

## 4e. Reconciliation run on production (25 Sep) — no customer money owed

`node dist/scripts/reconcile-purchases.js --from 2026-05-30 --to 2026-09-25` (backend #339 →
#340 → #341), read-only: **131** completed Assets payments — **91** delivered, **5** not
delivered (uploaded NFTs at 2π: "55", "Ere", "Yt", "Ugv", "Ffv"; 10π), **35** with no product
id at all (1π each, 30 May – 14 Jun).

The owner confirmed every payment was their own testing (two accounts, `cbc4bb46-…` and
`87a95116-…`): the 35 were test domains converted to NFTs, most then deleted. **No user is
owed a delivery or a refund; closed with no action.**

One payment (3 Jul, "Ere") was recorded as `user=gateway` — the phantom-user class the
gateway's internal-key branch now prevents (it injects `x-user-id` from the verified token).
Evidence that the fix post-dates 3 Jul; nothing to repair.

C-02 §2 item 4 now carries the next real Assets-side gap: Estate Mode 1 loses the
registration on the return trip.

## 4f. Fixing Estate's Mode 1 found a fleet-wide one: Hub-bought Pro never activated

Reading how Estate hands a payment to the Hub: `redirectToHubPayment` sends the product as
**`item`** — tec-template-base's code, cloned into **17 apps** (Alert, DX, Elite, Epic,
Estate, Explorer, FundX, Insure, Legend, Nexus, NX, Titan, VIP, Zone, System, Brookfield,
NBF); only Life, Analytics and Connection send `product_id`. The Hub's `useExternalPayment`
read **`product_id` only**, so every Mode-1 payment from those apps was created with an
empty product, and commerce's SubscriptionConsumer (plan from `<slug>_pro_monthly`) activated
nothing. **A Pro bought from the Hub — the path of anyone who opens an app from the Hub —
was paid for and never activated.** The owner is the only user so far (their own tests);
no reconciliation.

- tec-app **#257**: the Hub reads `product_id || item` — one fix covers all 17 deployed apps.
- tec-template-base **#41**: the template sends `product_id` (and `item`), so new apps are right.
- Then Estate itself — the property travels in the payment's product id and asset-service
  records it from the event: tec-core-backend **#342**, Tec-Estate **#40**. Estate stops
  provisioning; it claims. EstatePro no longer treats a property payment's return as its own.

Lesson for C-12's anti-regression list: a Mode-1 contract field that the app side and the
Hub side name differently fails silently — the payment succeeds, only its meaning is lost.

## 4g. Verified on the phone (25 Sep, morning)

All five PRs squash-merged; each branch's files are identical to `main`. Production on Vercel:
Hub `4981a46` (#257, 07:11Z) and Estate `6f6cea3` (#40, 07:17Z); tec-core-backend #342 on
Railway.

- **Estate opened FROM the Hub (Mode 1)**: registered the property "Test t". The Hub modal took
  the payment, and asset-service recorded the property from `payment.completed.v1`. The form
  no longer has to survive the round trip.
- **Zone Pro bought through the Hub**: shows "Zone Pro active". The Hub now reads `item`, so
  the payment carries `zone_pro_monthly` and commerce's SubscriptionConsumer activates it.
  This is the path that failed silently in the 17 template apps.

C-02 §2 item 4 is closed.

**Production caught up with `main` (25 Sep, ~07:35Z).** Vercel showed seven apps serving a
build one PR behind `main`. Nx, Titan, Vip, Insure, Brookfield and NBF lacked the
`resolve-incomplete` `Partitioned` fix. FundX lacked #32. Each was deployed to production from
its exact `main` SHA through the Vercel API. The other 15 apps, the Hub and Estate already
matched `main`, so every app in the fleet now serves its `main` (C-02 §2 item 1 closed).

**A stale open item, found while starting the next one.** C-02 listed "campaign payout evidence:
record it at claim time" as open since 56o. The evidence shipped on **19 Sep**: tec-core-backend
#327 added `CampaignClaim.qualified` (`{at, required, done[{app, at}]}`, written in `claim()`),
and the Hub payout queue shows it (#241, `Qualification`). The item was recorded as open in the
same session that closed it, and was carried into C-02 on 24 Sep without re-checking. What is
left is only `CAMPAIGN_APPS` 8 → 24, and that is the owner's decision. Code Verified, not
Runtime Verified: the production column was not inspected from here.

## 4h. "The name is missing when I open an app from the Quest or the campaign"

The `reason` field added in 56p answered on the phone: `no_token`. The page guard had admitted
`/app` in the same visit. The Quest and the campaign open apps standalone on purpose (§9), the
warm-up already ran `Pi.authenticate`, and the 20 template apps had no `pi-login` to turn that
into a session. Only the Hub, Assets, Commerce and Ecommerce did.

Fix: the app signs itself in with the Hub's own flow (C-123 §10). Template #42 came first,
then Explorer #51 and FundX #33 as the phone test. Both are verified: FundX signed in on the
first try from both pages, and Explorer from the Quest on the fourth. The other 18 apps
followed with the same patch. Brookfield and NBF needed a hand merge, keeping their Pi error
record alongside the new token.

## 4i. The self sign-in was not the fix — and neither was the bridge

The second phone test read the new diagnostics: `no_token · pi_waiting · got:none` and
`hub_session`; `/api/auth/pi-login` never appeared in the logs. The `auth.me_refused` lines
(`cookieCount 0/1`, `same-origin`) looked like two cookie stores, because `/app` had been served
in the same visit and the guard "only serves it with a session". A session bridge was built on
that (Connection #81 · DX #37 · Alert #38, template #43) and merged. On the phone the bridge
answered **307**: its navigation carried no session either.

That broke the premise, and a build showed why: Tec-Dx's `middleware-manifest.json` is empty. The
template and its 20 apps keep `middleware.ts` at the root beside `src/app`, where Next.js never
loads it — so there is no page guard and **no CSRF enforcement** in production (C-123 §11). The
"Not signed in" visits simply have no session. The bridge rollout to the other 17 apps was
prepared locally and **not pushed**; it should not be. Moving the middleware is the owner's
decision, because it switches the guard and CSRF on for the first time.

The owner chose "what is right engineering-wise". #82/#38/#39 moved the middleware and sent a
session-less page into the Hub's SSO; on the phone the apps stopped opening (307, never back — §9).
Rolled back on Vercel within minutes (the three projects now need a manual promote). #83/#39/#40
keep the move, drop the guard. Lesson recorded as a rule in C-123 §11: no automatic off-origin
redirect on a page load in Pi Browser.

With the apps stable again (#83/#39/#40 merged, promoted), the actual question: why the Hub grid
shows the name and the Quest does not. The grid goes through the Hub's handoff; the Quest links
straight to the app (on purpose, §9). tec-app #258 has the Hub sign each Quest/campaign link while
the visitor is still on the Hub (`POST /api/auth/sso-links`, reusing `/api/auth/sso` in process), so
the app opens on its own domain, standalone, already signed in (C-123 §12).

## 5. Left open

- Hub `/pay` page registrations (domains, NFTs) have no event-driven repair path; the page is
  reached by nothing in the UI since 30 Apr.
- Tec-Assets `npm run lint` fails on main (ESLint 9, no `eslint.config.js`); CI runs it with
  `continue-on-error`.
