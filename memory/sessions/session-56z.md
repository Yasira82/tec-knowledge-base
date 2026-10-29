# Session 56z — Nexus outside TEC: the Handshake, a deal between two Pioneers (25 Oct 2026)

> Truth State: **[Current State]**. The Handshake is merged and deployed: tec-core-backend #469,
> Tec-Nexus #49 and #50.
> Verification:
> - **[Code Verified]**: tests, tsc, lint and build on each PR.
> - **[Runtime Verified]** only up to creating a deal:
>   - the owner's Railway deploy log shows `tec-nexus-service` Active, with the eight handshake routes mapped;
>   - the owner's phone shows the home card and the `/deal` form.
>   - **Not yet verified on the live network:** agree, payment found on the chain, received, proof.
>
> Same branch as 56s–56y (`claude/tec-knowledge-base-review-6wzngc`).
> Direction research: `audits/NEXUS_DIRECTION_RESEARCH_2026-10-25.md`.

## What happened

- **Life was paused** («يا ااجل الشغل في Life دلؤتي وتبدأ اي تطبيق تاني»). The owner chose Nexus.
- The owner's first question was whether Nexus should simply be "workflows". The second was how it
  serves the Pi community outside TEC.
- **An external review** proposed "Nexus for Pi developers", an API that runs another app's payment
  flow. Desk research (`audits/NEXUS_DIRECTION_RESEARCH_2026-10-25.md`) compared it with a
  Pioneer-facing alternative:
  - **A (developers)** would need TEC to hold every customer app's Pi server key. Pi's own
    September guidance already targets that integration.
  - **B (Pioneers)** answers a documented pain: more than 4.4M Pi drained through payment-request
    scams in December 2025. It holds no money.
  - The evidence favoured B.
- **«Nexus خارج tec عاوز احترافية وابداع»** led to a concept page, the "Nexus Handshake". The owner
  approved it.
- **«ابدأ في ب»:** build the first small version now. The research doc had recommended a demand
  test (a post plus a mock) before building. The owner chose to build first; that test is still
  owed.

## What was built

- **The flow:**
  1. The seller opens a deal: what it is, the price in π, optional terms and timing, and the wallet
     to be paid into.
  2. The seller sends the link. The buyer signs in with Pi and agrees, giving the wallet they will
     pay from.
  3. The buyer pays the seller **directly from Pi Wallet**.
  4. Either party asks Nexus to check the chain. Nexus reads public Horizon and looks for that
     buyer wallet → that seller wallet, the exact amount, after the agreement. Only then is the deal
     PAID.
  5. The buyer confirms receipt, or records a dispute. Completion writes a SHA-256 proof over a
     fixed field order.
- **States:** OPEN → AGREED → PAID → COMPLETED. DISPUTED can still go to COMPLETED. CANCELLED is
  only possible before payment. COMPLETED and CANCELLED are terminal.
- **What it never does:**
  - hold, move or return Pi (C-109 §6);
  - mark a deal paid on anyone's word;
  - let one chain payment close two deals (unique tx hash);
  - let the seller be the buyer.
- **Who acts** is the session (P6). The BFF never forwards an `owner` or `userId` from the body, and
  only five named steps are forwarded.
- **Each person's record** is shown as counts (completed, open disputes, since when), never a score.
  An empty record is stated plainly. A "before you pay" box says Nexus cannot get Pi back.
- **#50 (from the owner's phone):** the create button was disabled with no reason given, and the
  grey "25" example read as a typed price, so the form looked broken. The button now names the
  first missing field.

## Corrections owed to the record

- **#49's first CI run failed the typecheck** (`calls[0]` under `noUncheckedIndexedAccess`). The
  session had reported "all checks pass" after a typecheck run before the test file existed.
  Lesson: run the repo's own `npm run typecheck` after the last file, not before.

## Left open

- **The end-to-end test** (agree → pay → check → received → proof) needs a second Pi account. The
  owner has none.
  - Testnet does not remove that need: the seller cannot agree to their own deal, by design.
  - Pointing production at testnet Horizon would break real deals.
  - Next step: a friend with Pi, a 0.1π deal, paid back afterwards.
- **The demand test** from the research doc (§5).
- **C-109 (Nexus charter) does not describe the Handshake.** Whether to amend it, or record it as an
  ADR, is a human's decision. This session did not touch the charter.
- **Later, only after the end-to-end test:**
  - completed handshakes counted in Legend;
  - Zone badges on the record;
  - a share button.
- **Still unverified from before:** the older checkout-saga engine, end to end.
