# Pi on-chain Subscriptions — what they are, how they meet our rules, and a plan

**Date:** 2026-11-27
**Truth State:** [Planned State] — nothing here is built
**Governance State:** [Draft] — the ADR in §5 waits for the owner's decision and number
**Verification:** [Documentation Verified] for §1 (Pi's own docs, read 2026-11-27) · [Code Verified] for §2 (Tec-Life and tec-core-backend `main`, 2026-11-27)

> The owner saw a new **Subscriptions** section in the Developer Portal (TEC-APP, Testnet):
> «Register Subscription Service» — merchant wallet, name, price in Test-Pi per period, billing
> cadence, free-trial days. It is **Testnet only**. Owner, same day: read the docs, check how our
> Testnet works, write a plan; Mainnet must not be affected.

---

## 1. What Pi's Subscriptions are (Pi's docs)

Sources: `developers.minepi.com/docs/subscriptions/Overview` · `…/Implementation` · `…/AdditionalMethods`.
The GitHub `pi-apps/pi-platform-docs` has no subscriptions page, and the Platform API (REST) has
no subscription endpoint — it is a **smart contract**, called through the SDKs.

| | What the docs say |
|---|---|
| **Status** | «Subscription payments are currently available only on Pi Testnet, on the first version of the Subscription contract (v1).» **v1 is replaced before Mainnet: a new contract address, services registered again, subscribers subscribe again.** |
| **Register** | In the Developer Portal: it links the service to the app's **connected wallet** (the merchant). `registerService` from the SDK does *not* link it to the app. Fields: name, price per period, period, trial (0–90 days), approve periods, `is_active`. No documented way to edit or delete a service. |
| **Subscribe** (browser) | `Pi.SmartContract.Subscription.subscribe(subscriber, serviceId, autoRenew, periods, options?)` — `options.mode` `"simulate"` or `"submit"`; confirm with `Pi.SmartContract.pollTransaction(hash)`. Needs `Pi.authenticate` with the **`payments`** scope. No callbacks. |
| **The subscriber's wallet** | `Pi.authenticate` does **not** return it. The docs: ask the person to enter it, and link it on the backend after checking the subscribe transaction. |
| **Approval** | The subscriber pre-approves `price × periods` (`periodsFor(service)`: 5 monthly, 25 weekly); each renewal uses one period. An approval lasts just under 180 days. |
| **Renewal** | **Not automatic.** «The contract charges a subscriber only when the merchant calls `process`.» `process` is **signed by the merchant wallet's secret** (server SDK: Node `pi-backend` `SmartContract.Subscription.process(merchantSecret, serviceId, offset, limit)`); the merchant pays its fee (≈0.01–0.02 Test-Pi). A renewal can be collected only for one period after it is due. |
| **Failure** | A failed charge (no funds, approval used up) **turns auto-renew off**; access lasts to the end of the paid period. |
| **Cancel** | `cancel(subscriber, subscriptionId)` — no refund; access lasts to the end of the period. |
| **Trial** | Only on a person's first subscription to a service; with a trial and auto-renew, nothing is paid until it ends. |
| **Notifications** | **None.** No webhook for subscribe, renewal, failure or cancel; state is read from the contract (`isSubscriptionActive`, `getSubscription`: `auto_renew`, `service_end_ts`, `next_charge_ts`). |

## 2. How our Testnet works today (code)

- **The host decides the network**, not an env var — one build serves both apps
  (`Tec-Life/src/lib/pi-network.ts`, `isTestnetHost`): `*.vercel.app` and `*-test.tecosystem.app`
  are Testnet; anything else is Mainnet. `NEXT_PUBLIC_PI_SANDBOX` cannot answer it (one build), and
  Pi's `sandbox` is a third thing, not Testnet (`src/app/layout.tsx`).
- **The server sets it**: `payment/create` writes `metadata.testnet` from its own `Host` and
  overwrites the body's (P6); payment-service picks the Testnet app's key from it (`getPiApiKey`).
- **Testnet buys nothing real**: commerce refuses Pro from a Testnet payment
  (`subscription.consumer.ts`); `/api/bff/subscription` answers FREE on a Testnet host; `/testnet-payout`
  is 404 on Mainnet.

So the guard this plan needs already exists as a pattern: **anything new is Testnet-host-only,
decided server-side, and fails closed.**

## 3. Where it meets our rules

| Rule | Conflict | Needs |
|---|---|---|
| **No wallet seed back in Railway** (owner, 30 Oct; C-02 item 29) | `process` needs the merchant wallet's **secret** on a server | Testnet: a dedicated, worthless Testnet wallet, its own clearly named variable. **Mainnet: an owner decision** — an isolated signer outside Railway, or another way to collect renewals |
| **Payment is owned by tec-payment-service** (C-47 · C-68 · ADR-009) | the subscriber pays the app's wallet on-chain, not through payment-service | an ADR (§5): payment-service owns the on-chain subscription record — verifies, records, audits; apps ask it |
| **Every financial action has an audit trail** (C-47 invariant 4 · C-71) | no webhooks; renewals happen only when we call `process` | every `process` run and every verified subscribe/cancel recorded by payment-service |
| **Never trust the client** (P6) | the page holds the transaction hash and the wallet address | payment-service reads the contract itself; the page's word is only a pointer |
| **Testnet grants nothing real** | — | kept: a Testnet subscription records, never grants Pro |

## 4. The plan

**Phase 0 — owner decisions (before any code)**
1. The merchant secret: Testnet as in §3; Mainnet deferred to its own decision.
2. The ADR in §5, with a number the owner assigns.

**Phase 1 — Testnet, Life only (learning and readiness)**
1. Register the service in the Portal on **Life's Testnet app** (a service belongs to the app whose
   connected wallet registered it — not TEC-APP). Name e.g. «Life Pro (Test)», 1 Test-Pi, monthly, no trial.
2. Life, **Testnet host only** (`isTestnetHost`, page and BFF): «Subscribe (test)» — `Pi.authenticate`
   with `payments`, the person enters their wallet address, `subscribe` in `simulate` then `submit`,
   `pollTransaction`, the hash to the BFF.
3. payment-service: reads the subscription from the contract, records it, links the wallet to the
   person — idempotent, audited. Testnet: grants nothing.
4. Renewal: a job (hourly) calls `process` with the Testnet merchant secret — idempotent, every run
   recorded; Testnet only.
5. Cancel and auto-renew off from Life's Settings.
6. Tests: on a Mainnet host the page shows nothing new and the BFF refuses it; Pro and today's
   payments unchanged; the contract read is trusted, never the page.

**Phase 2 — Mainnet, when Pi ships the next contract**
Register again on the new contract, apply the Phase 0 decisions, one app first.

**Priority:** Phase 1 is for learning and readiness; it is **not** for the Pi Next hackathon
(5 Jan 2027) — v1 changes before Mainnet. Real users first: the coach, PiNet, the demo video.

## 5. ADR — draft (number to be assigned by the owner)

**Title:** On-chain subscriptions are owned by tec-payment-service
**Status:** [Draft]
**Context:** §1, §3.
**Decision (proposed):**
- tec-payment-service is the only service that verifies a subscribe/cancel on the contract, records
  the subscription, links a subscriber wallet to a TEC user, and runs `process`. Apps and commerce
  ask it; none reads or trusts the page.
- Testnet first, behind the host guard; Testnet subscriptions never grant anything real.
- The merchant secret never enters Railway on Mainnet without a separate, recorded owner decision.
- Entitlement (Pro) stays commerce's (C-47 · ADR-012), fed by payment-service's verified record.
**Consequences:** a scheduled job and a wallet-link table in payment-service; one more payment path
to audit; re-registration when Pi replaces v1.
**Open:** where the Mainnet merchant secret lives; whether a manual wallet-address step is acceptable
for users, or to wait for Pi to expose the address.
