# ADR proposal — where a service's response contract lives

**Status:** PROPOSED — for the owner. Unnumbered: the owner numbers it (README §7) and, if accepted,
it goes into C-64 beside ADR-009.
**Answers:** TEC-AUDIT-0034 (acceptance: "an ADR records where domain contracts live").
**Truth State:** [Current State] for the facts below, [Planned State] for the decision.
**Verification:** [Code Verified] — every fact was read from the code on 14 Nov 2026.
Last verified: 2026-11-14.

## Context — what the code shows

ADR-009 made `@yasser172/tec-sdk` the one home of the payment **request** contract and forbade
a local payment schema in any app. The code, 14 Nov 2026:

| Fact | Where |
|---|---|
| No app imports a contract from the SDK. Every app imports `TecSdk` in one file (`src/lib/sdk.ts`), and no production path calls a client on it | grep over the template and 25 apps |
| The SDK's **response** schemas describe an API that does not exist: `PaymentSchema` has `paymentId` · `userId` · `amount: number` on `/payments`; payment-service answers `{ success, data: { payment: { id, user_id, amount: "<decimal string>", … } } }` on `/api/payment/*` (ADR-009's own path) | TEC-SDK `src/api/paymentClient.ts` · payment-service `payment.controller.ts`, `schema.prisma` |
| The same for the wallet (`balance: number`; the service sends a DECIMAL) and the subscription (`planId` · `interval`; commerce sends `plan` · `isActive` · `isExpired` · `current_period_end`) | TEC-SDK `walletClient.ts`, `commerceClient.ts` · wallet / commerce services |
| Where an app does check a response, it checks it itself — and the two places that matter most had drifted: the Pro status was read two ways in one app (0044), and the Hub's wallet route answered a **fabricated zero** when it could not read the wallet service (fixed 14 Nov, tec-app a07a0aa1) | |

So Forbidden #5 (an SDK contract that diverges from the backend) is not a risk; it is the state.
Nothing failed because nothing uses those schemas, and nothing would notice a backend change.

## Options

1. **The SDK owns response contracts, written from the services' real answers** — schemas only
   (no HTTP clients); BFFs keep `gatewayFetch` and parse what they read with the SDK's schema.
2. **Each service publishes its own contract package** (`@yasser172/contracts-payment`, …).
3. **Each app checks at its own edge** — today's practice, written down.

## Recommendation — option 1

- It is ADR-009's decision carried to the other half of the exchange, in the package ADR-009 already
  named. One place to change when a service changes; one release to carry it.
- Option 2 is the right shape at a larger scale, and 13 packages to publish and version is not a
  cost this platform should take on in Phase 0.
- Option 3 is how 0044 and the fabricated zero happened.

### What it means

- `tec-sdk/src/contracts/` gains response schemas for **payment, wallet and subscription first**
  (the money and the entitlement), each written from the owning service's code and pinned by a
  test built from that code's real answer — never from what a client wishes it said.
- Amounts are decimal **strings** in a response (ADR-009 · C-71 §3); the schema says so.
- The SDK's HTTP clients (`PaymentClient`, `WalletClient`, `CommerceClient` …) are deprecated in
  the next major and removed in the one after: nothing calls them, and a client for an API that
  does not exist is a trap for the next person who tries it.
- A BFF reads a response field only through the schema, and an unreadable answer is a 502 with
  a log line — never a default value (C-135 §4).
- Policy CI later: a payment, wallet or subscription route that reads `res.json()` without a
  schema fails the build (the same kind of guard as `gateway-fetch`'s deadline test).

### Rollout

`tec-core-backend` unchanged → `tec-sdk@2.x` (contracts; publish needs GitHub Actions back) →
the template (its local payment request schema replaced by the SDK's, as ADR-009 already requires)
→ template-sync to the apps → the Hub's wallet route switches its local schema for the SDK's.

## Not decided here

Whether non-financial domains (Life, Connection, Zone …) follow. The recommendation is yes, one
domain at a time and only where a BFF reads fields; it is the owner's call.
