# Marketplace Seller-Payout Gap — 2026-08-19

**Scope:** the two peer-to-peer sale paths in the platform —
`tec-asset-service` (NFT marketplace) and `tec-commerce-service` (product orders).
**Question:** when a buyer pays real Pi for another user's listing, does the **seller**
actually receive the proceeds?
**Verification:** `[Code Verified]` — read from `marketplace.service.ts::buyListing` and
`order.service.ts::createOrder` in `tec-core-backend` `main`. Prompted by a live question
while listing the first real NFTs (`TEC Genesis` collection) on `assets.tecosystem.app`.

---

## Headline

**A sale transfers ownership but never credits the seller's wallet.** On both paths the
buyer's Pi is a U2A payment that settles into the **app developer** Pi wallet (the TEC
owner), and the backend then transfers the asset / records the order attributed to
`seller_id` — but there is **no payout step** that moves the sale proceeds to the seller.

- **Not a problem today:** the only seller on either marketplace is the platform owner
  (`@yas55eR82`), who is *also* the app developer — so the Pi lands in the same wallet.
  The owner is paid for everything they sell, by construction.
- **A hard blocker before third-party sellers:** the moment a *different* user lists an
  NFT or a product and it sells, the Pi goes to the app developer, **not** to that seller.
  The seller would hand over the asset and receive nothing.

Severity: **HIGH for a multi-seller marketplace, N/A for the current single-seller state.**
This is a *known, documented gap* — deliberately deferred, not a silent omission.

---

## Evidence (code)

### Assets — `tec-asset-service/src/modules/marketplace/marketplace.service.ts::buyListing`
Inside one `$transaction`:
1. `asset.update` → `ownerId = buyerId` (ownership transfer)
2. `assetHistory.create` (audit)
3. `assetListing.update` → `status = SOLD`, `buyerId`, `paymentId`, `soldAt`

There is **no** `wallet.credit(sellerId, price)` and no call into `tec-payment-service` /
`tec-wallet-service` to settle the seller. Payment reuse is blocked (`paymentId` unique),
ownership moves, money does not.

### Commerce — `tec-commerce-service/src/modules/order/order.service.ts::createOrder`
Records order items with `seller_id`, emits the C-107 "buyer trusts seller" trust event,
and exposes `getSellerSalesSummary` (revenue **reporting**). No wallet credit / settlement
to the seller exists either — the sales summary is analytics, not a payout.

### Where the Pi actually goes
Both buy flows use `createU2APayment` (Pi SDK U2A) client-side. A U2A payment settles to
the registered Pi **app** (the developer). With seller == app owner, that is the owner's
wallet. With seller != app owner, the proceeds still land with the app owner — the gap.

---

## Why defer (not fix now)

A correct payout is a **financial settlement feature**, not a small patch. It must respect
the Kernel Spec:
- **Invariant #8** — `tec-payment-service` is the only Pi custodian; a payout must move Pi
  *through* payment-service, never by an ad-hoc wallet write in asset/commerce.
- **Invariant #1 / #4** — non-negative balances + full audit trail on every credit.
- **P6** — fail closed; a failed payout must not leave the asset transferred but unpaid
  (saga / compensating action, C-109), i.e. ownership transfer and seller credit are one
  atomic outcome or neither.
- Platform + legal questions: marketplace fee/commission split, refunds/disputes, KYC on
  payees. These are real product decisions, not implementation details.

Building this speculatively — before any third-party seller exists and before those
decisions are made — would be premature. The honest position is to **record the gap and
gate third-party selling on closing it.**

---

## Decision

1. **Current state is safe.** Single-seller (owner) marketplace pays correctly. The
   `TEC Genesis` NFT listings and the Commerce storefront can go live as-is for the
   Pioneer campaign — the owner receives the Pi for anything sold.
2. **Gate:** do **NOT** open NFT/product listing to third-party sellers until a
   payment-service-mediated seller-settlement path exists (payout + fee split + refund
   path + audit), designed as an ADR (touches payment-service, wallet, Invariant #8).
3. **Tracked here** as the source of record; to be lifted into an ADR when multi-seller is
   scheduled. Not a code change in this document — a recorded gap + a build gate.

---

## Related

- C-47 Kernel Spec — Invariants #1/#4/#8, P6
- C-71 Financial Integrity Spec
- C-109 Nexus — saga / compensating actions for financial workflows
- C-113 FundX / C-129 Insure — the same "payment-service is the only custodian" hard-gate
