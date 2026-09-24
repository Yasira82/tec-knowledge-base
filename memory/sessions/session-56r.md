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

## 3. Deploy order (ops — not done by this session)

1. tec-asset-service: start command `npm run db:push && node dist/main` → redeploy → **restore**
   `node dist/main`.
2. Set `REDIS_URL` on tec-asset-service (the shared Redis). Without it the consumer does not
   start and the endpoints stay at 202.
3. Deploy asset-service + payment-service, then Tec-Assets.

## 4. Left open

- `POST /assets/provision` is still unverified for its other callers: Hub domain
  registration + NFT mint, Assets `domains/add`, Estate `property`. Closing it needs
  receipts for sources `hub` and `estate`.
- Marketplace `list` / `cancel` / `price` take `sellerId` from the body; the gateway's
  `x-user-id` should be enforced there too.
- Payments before the deploy are not replayed (the group starts at `$`) — paid-but-undelivered
  Assets purchases from before are reconciled by hand against payment-service.
- Tec-Assets `npm run lint` fails on main (ESLint 9, no `eslint.config.js`); CI runs it with
  `continue-on-error`.
