# P6 — Functional & Business Logic · cycle 2026-11-11 · Run 4

**Status: PASSED_WITH_FINDINGS** · [Code Verified] at `origin/main`, 13 Nov 2026, with the
runtime facts the KB already holds marked [Runtime Verified] and dated.

> **Context that sets every severity below** (C-02 item 23, Runtime Verified 10 Oct): no outside
> customer has paid real π yet — every Mainnet payment so far is the owner's own testing. A flow
> that is broken today has hurt no customer; it will hurt the first ones.

## Critical capabilities, traced from the screen to the database

| # | Capability | Path traced | Status | Basis |
|---|---|---|---|---|
| 1 | Sign-in from the Hub (SSO) | Hub `/api/auth/sso` → app `sso-callback` (200 landing, C-123) → cookies | **VERIFIED** | Runtime Verified 10–11 Oct (C-02 item 25) |
| 2 | An app signs itself in (standalone, Pi Browser) | `pi-login` → auth-service → one-time token → own `sso-callback` | **VERIFIED** | phone-verified 2 Oct (C-02 item 15) |
| 3 | A session renews itself in an app | refresh token → `/api/v1/auth/refresh` → rotated cookies | **BROKEN** on main in 23 apps → TEC-AUDIT-0029 (fixed locally; needs a phone check) | code trace, Run 2 |
| 4 | Pay in an app — Mode 2 (U2A) | `createPaymentRecord` → payment `create` → Pi approve (amount checked) → complete → outbox `payment.completed.v1` | **VERIFIED** | owner's Mainnet payments (C-02 items 15, 23) |
| 5 | Pay through the Hub — Mode 1 | `/hub?pay=1&…` → Hub modal → same payment path | **VERIFIED** | per-app charters' "Mode 1 verified" |
| 6 | A Pro purchase becomes a subscription | `.v1` → `commerce-subscription`: plan from `item_id`/`product_id` `<slug>_pro_monthly`, floor price checked, Test-Pi refused | **VERIFIED** (code) — 19 apps send the id the consumer reads; the 5 that do not sell no Pro | code trace |
| 7 | An order is paid by its payment (Ecommerce / Commerce) | `.v1` → `OrderConsumer` → `confirmPaid` (buyer, amount, idempotent); unpaid holds released by `HoldSweeper` | **VERIFIED** (code) — TEC-AUDIT-0001 closed | code trace |
| 8 | An asset purchase is delivered | `.v1` → `asset-purchases` (receipt is the only proof accepted) | **VERIFIED** (code) | code trace |
| 9 | The wallet shows balance and history | Hub `/api/bff/wallet/*` → gateway → wallet-service; credit from `.v1` | **VERIFIED**; history failure showed "no transactions" → 0028 (fixed locally) | NEW-L closed; Run 2 |
| 10 | A payment left incomplete is finished | app `resolve-incomplete` → Pi state → complete/cancel; hourly reconciliation | **PARTIALLY_IMPLEMENTED** on main → 0030 · 0031 · 0032 (fixed locally) | Run 3 + the production read (no victim since 6 Aug) |
| 11 | The user is told a payment completed (notification, live update, analytics) | the **unversioned** `payment.completed` stream | **PARTIALLY_IMPLEMENTED → TEC-AUDIT-0036** | code trace |
| 12 | Nexus Handshake — the buyer pays the seller | Nexus deal → Pi Wallet → `.v1` → `nexus.consumer` | **NOT_VERIFIABLE** here — C-02 item 30: "its payment step is not verified yet"; needs a real payment | C-02 |
| 13 | Account merge · account erasure | `/hub/admin/account-merge` · `/hub/admin/erasure` across services | **VERIFIED** | Runtime Verified 10 Oct, 17 Oct (C-02 items 24, 26) |
| — | FundX pools · Insure escrow | — | **NOT_IMPLEMENTED by decision** — hard-gated (legal + KYC/custody + SYSTEM); the read-only surfaces are what ships | C-113 · C-129 |

## TEC-AUDIT-0036 in one paragraph

A completed payment is announced on **two** streams. `payment.completed.v1` is written by the
outbox in the same transaction as the status (durable, retried). The unversioned
`payment.completed` is a direct publish **after** the response, best-effort: it is skipped when
the Redis publisher is not ready — and the log line says "outbox worker will retry", which is not
true for that stream — and the recovery endpoint and the hourly reconciliation never send it.
Wallet and commerce already moved to `.v1`; **notification, realtime and analytics still read
only the unversioned one**. So a payment finished by recovery, or completed while the publisher
was down, credits the wallet and delivers the purchase but sends no notification, no live update
and no analytics count. The events catalog still lists wallet and commerce as its consumers, and
the weekly drift check does not compare consumers, so it did not notice.
