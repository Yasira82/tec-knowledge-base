# Nexus — which audience outside TEC? Desk research (2026-10-25)

> Truth State: **[Current State]** for what the sources say; **[Speculation]** for the reading of
> them. Governance State: **[Draft]** — the owner decides the direction. Verification:
> **[Documentation Verified]**, from web sources searched on 2026-10-25. Each source's weight is
> marked. No code was read or written for this file.
> Context: the owner chose Nexus after pausing Life
> (`audits/LIFE_MEMORY_AND_HUMAN_BUILDING_2026-10-23.md` §9). An external review the owner shared
> proposed "Nexus for Pi Developers". This file checks that proposal, and the alternative raised in
> conversation, against evidence. Nexus's charter is C-109; this file proposes, it does not amend it.

## 1. The two candidates

| | A. Nexus for Pi developers | B. Trusted deal, for Pioneers |
|---|---|---|
| Who | Independent Pi app developers | Pioneers who buy and sell with each other (groups, local shops) |
| What | An API that runs a multi-step purchase-and-payment flow for another Pi app, keeping state and retrying safely | Two Pioneers fix terms in Nexus. Both confirm with Pi sign-in, and each sees the other's verification and reputation. They pay each other directly, outside the app. Both mark it done, and Nexus issues a signed proof that feeds reputation |
| Holds money? | No. But it must hold each developer's **Pi server API key** to approve and complete their payments | **No.** Nexus never touches the Pi |

## 2. Claims in the external review, checked

| Claim | Finding |
|---|---|
| "Pi shipped developer updates on 4 Sep 2026, with unified documentation" | **Confirmed.** Pi's own blog shows a Staking Data API, `Pi.shareFile`, one documentation site, and **AI-assisted guidance for integrating authentication and payments** ([minepi.com](https://minepi.com/blog/dev-capabilities-documentation/)) |
| "Open-source workflow tools already exist in the Pi developer community" | **Not found.** No such tool surfaced in the searches. Treat it as unverified |

## 3. Evidence for A — developers

- **The payment pitfalls are real and documented.**
  - An unfinished payment blocks the next one.
  - `/approve` and `/complete` must come from the app's server.
  - Goods must never be delivered before `/complete`.
  - Sources: [SDK reference](https://github.com/pi-apps/pi-platform-docs/blob/master/SDK_reference.md) · [payments.md](https://github.com/pi-apps/pi-platform-docs/blob/master/payments.md) · [community guide](https://pi-apps.github.io/community-developer-guide/docs/importantTopics/paymentFlow/piPaymentFlow/).
  - Pi's own tutorial author describes ending up with submitted-but-uncompleted payments ([minepi.com](https://minepi.com/blog/build-blockchain-app/)).
- **No public complaint threads were found.** Searches for developers stuck at approve or complete returned docs, not complaints.
- **Pi is closing the gap itself.** The 4 Sep AI-assisted guidance targets exactly this integration, and official libraries exist: [pi-python](https://github.com/pi-apps/pi-python) · [pi-php](https://github.com/pi-apps/pi-php).
- **The market is unmeasured.** Pi reports 300+ Mainnet apps, with no usage, paying users or transaction value per app ([crypto.news](https://crypto.news/pi-network-says-it-has-300-mainnet-apps-how-many-are-being-used/)). Pi's first ecosystem summit is 17–19 Nov 2026 and may say more.
- **The trust cost is structural.** Running another app's payment flow means holding its server key. One breach of TEC would then be a breach of every customer. This comes days after the Railway environment-variable incident (`audits/RAILWAY_SECRET_ROTATION_2026-10-22.md`). The alternative, a library each developer runs, is no longer a service.
- **TEC's real asset here** is `tec-payment-service`: outbox, incomplete-payment resolution, one key per app. It already serves 24 apps. If A were pursued, its honest name is "a reliable Pi payment layer", not "workflows".

## 4. Evidence for B — Pioneers

- **The pain is large, recent and documented.**
  - In late December 2025, a social-engineering wave drained **more than 4.4 million Pi** through wallet payment requests, and Pi suspended the feature ([Yahoo Finance](https://finance.yahoo.com/news/pi-network-halts-payment-requests-052821339.html) · [Yellow](https://yellow.com/news/pi-network-suspends-payment-requests-after-44-million-tokens-drained-through-scam) · [CoinLaw](https://coinlaw.io/pi-network-scam-payment-requests-disabled/)).
  - A May 2026 report says the Request feature was removed from the wallet. That is one outlet, so unconfirmed ([Hokanews](https://www.hokanews.com/2026/05/pi-wallet-update-removes-request.html)).
  - Pi's position: not a protocol flaw, a trust problem.
- **Trust between Pioneers is informal.** Guides tell buyers to check a counterparty's standing and reviews before paying. These are low-quality sources ([source](https://grandavehousing.calpoly.edu/news/pi-network-p2p-your-guide)).
- **Existing players:**
  - **Map of Pi**: local business discovery with reviews; 1.8M users and 45k reviews, from secondary reporting ([TechTimes](https://www.techtimes.com/articles/309877/20250403/pi-networks-pifest-2025-proves-crypto-can-power-real-world-transactions.htm)). It overlaps TEC Explorer.
  - **GlobalPiMarket** claims escrow; promotional and unverified.
  - **No deal-level trust tool** (terms, both-sides confirmation, a signed proof) surfaced.
- **What TEC already has for B:**
  - Nexus's signed intent proof (`intent.proof.ts`);
  - Zone verification;
  - Legend reputation;
  - Connection's graph;
  - Alert, for scam warnings.
- **No custody, so none of the legal and custody gates of Insure or FundX applies.**
- **Risks:**
  - **Cold start.** Zone and Legend hold almost no records, so on day one the "reputation" shown is mostly empty. The proof and the both-sides confirmation must carry the value alone at first.
  - **Map of Pi already owns reviews.** B must not become another review site.
  - **Pay-outside-the-app.** The deal is recorded, not enforced. Nexus must say so plainly, never imply protection it does not give.

## 5. Reading

| | A — developers | B — Pioneers |
|---|---|---|
| Pain documented | In docs; no complaints found; Pi addressing it | **Yes, large and recent (4.4M Pi)** |
| Competition | Pi's own guidance and official libraries | Reviews exist (Map of Pi); deal-level trust not found |
| Fits TEC's assets | payment-service, not the Nexus engine | **Nexus proof + Zone + Legend + Alert** |
| Biggest risk | Holding other apps' keys | Cold-start reputation; recorded, not enforced |
| Money held | No, but keys are held | **No** |

The evidence favours **B**. Under Phase 0, the next step is still to **test demand before building**, not
to build. The cheapest test:
- one plain post in the Pi community describing the trusted-deal flow, with a mock of its two screens;
- a count of who says they would use it, and for what kind of deal.

Then a design page for the owner's review, before any code.

## 6. Decisions for the owner

1. A, B, or neither?
2. If B: the demand test first (a post plus a mock), or straight to a design page?
3. Is Nexus's current engine (checkout saga) still to be verified end to end on the phone? Recommended:
   yes. B reuses the intent proof, which has never run in production.

## 7. What the owner decided (same day)

- **Decision 1:** B. The owner asked for "professional and creative". A concept page, the Nexus
  Handshake, was approved.
- **Decision 2:** neither of the two options offered. The owner chose to **build first**
  («ابدأ في ب»), so the demand test above is still owed.
- **What was built:** tec-core-backend #469, Tec-Nexus #49 and #50. The deal is recorded, the
  buyer pays the seller directly, and payment is confirmed only from public Horizon. Nexus holds
  no Pi.
- **Status:** live up to creating a deal. The payment step has not run on the live network; it
  needs a second Pi account. Record: `memory/sessions/session-56z.md`.
