# Session 56r — anyone could take an Assets listing for free, and approve never compared the amounts (24 Sep 2026)

> Truth State: **[Current State]** once the PRs below are merged and deployed; until then
> **[Planned State]** · Verification: **[Code Verified]** (tests below), not yet runtime.
> PRs: tec-core-backend **#334** · Tec-Assets **#59** · tec-knowledge-base (this record).

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

## 5. Left open

- Tec-Assets `assets/transfer` calls `/api/assets/:id/transfer`, which asset-service does not have.
- Hub / Estate registrations have no event-driven repair path (receipts cover `source: assets` only),
  and Estate Mode 1 does not resume the registration after the Hub returns.
- Payments before the #334 deploy are not replayed (the group starts at `$`) — paid-but-undelivered
  Assets purchases from before, notably every paid domain→NFT mint (the BFF answered 400), are
  reconciled by hand against payment-service.
- Tec-Assets `npm run lint` fails on main (ESLint 9, no `eslint.config.js`); CI runs it with
  `continue-on-error`.
