# SESSION 56e — Phase 2.1: Nexus stops coordinating on paper

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

The platform's largest gap is closed. Nexus had a persisted saga engine with state,
history, compensation and a payment halt — and it **called nothing**. `advance()` marked
a step `DONE` having contacted no service. Every run succeeded. Three merged increments
(tec-core-backend **#310 · #311 · #312**) turned it into an engine that performs.

### The rule, and why it had to come first

> **A step cannot reach `DONE` unless the work actually happened.**

The engine now dispatches a step to its owning service and **refuses** any step with no
callable target — leaving the run untouched, because a refusal is not a failure: nobody
was asked to do anything, so there is nothing to roll back. #310 shipped that refusal
*before* any endpoint existed, which meant the platform spent one increment being
honestly unable to run a workflow rather than dishonestly appearing to.

`NexusDispatcher` is the one place a step becomes a call: host from env (NEW-A),
`x-internal-key` authenticating the **service** and `x-actor-*` carrying the **original
human** (C-109 P1-1, so the audit trail ends at a person), bounded timeout, typed outcome,
and it **never throws** — a dispatcher that threw would make rollback depend on a catch.
It **fails closed**: an unset service URL, a missing `INTERNAL_SECRET`, or a timeout is a
failed dispatch, never an assumed success. A timeout resolves to *did not happen* on
purpose — the step's idempotency key is what makes the retry safe, so "probably fine"
buys nothing and hides real breaks.

### Rollback is where it bites hardest

`COMPENSATED` means *no partial state is left*. Claiming it without having undone anything
is **worse than FAILED**: FAILED sends a human to look, COMPENSATED tells them not to
bother. So a compensation that cannot be dispatched leaves its step `FAILED` and ends the
run `FAILED`, naming exactly what was left behind — and rollback continues through the
remaining steps, because undoing three of four things beats undoing none.

### It was never "four endpoints"

The catalog named four missing endpoints. Adding them alone would have changed nothing:
a run carried **no parameters** (which products? which listing?) and no step could see
what an earlier step produced (which order?).

> **You cannot reserve inventory for an order that does not exist**, and step 2 cannot
> confirm the order step 0 opened if step 0's result is discarded. The gap was an engine
> capability wearing an endpoint's clothes — and only building it showed that.

So #312 added `NexusRun.input`, `NexusStep.output` and `CallDef.capture` (a **pick**, not
the whole body: a saga carries ids, not a copy of another service's entity — P2). Two of
the four "missing" endpoints then turned out to exist already: `POST /commerce/orders/checkout`
confirms, and `POST /assets/marketplace/:id/buy` settles.

### Two corrections the build forced

1. **Both sagas ended with a second payment step.** U2A create → approve → complete is
   ONE user action; payment-service's outbox owns the rest. "Complete the payment"
   modelled a payment nobody would ever be asked to make — the run would have halted at
   `AWAITING_PAYMENT` forever. Removed; a test pins one payment step per template.
2. **"Cancel the payment" as a compensation is forbidden, not unimplemented.** `completed`
   is terminal (Invariant #7); leaving it is Forbidden Behavior #9. The reversal is an
   **A2U refund** — a new payment owned by payment-service. The payment step therefore
   declares its compensation with no callable, and a run that fails after the money moved
   ends **FAILED**, naming the payment that stands. A person decides what happens next.
   Reporting a clean rollback there would be a lie about money.

### What the new endpoints are, and what they are not

| Service | Added | Note |
|---|---|---|
| commerce | `POST /orders/reserve` · `POST /orders/release` | **Doors, not second implementations** — each calls the same service method the app path calls, so the reservation rule stays defined once (P2). Internal-key only: they take a buyer id in the BODY, and such a route reachable from a browser is an order-as-anyone endpoint. `release` goes through `cancelOrder`, so a saga still cannot release an order that was already PAID. |
| commerce | `GET /subscriptions/renewable` | Answers **409**, not 200-with-a-flag: a dispatcher decides from the status code, so a check that always returned 200 would be a step that always passed. *A guard that cannot refuse is not a guard.* |
| asset | `POST /marketplace/:id/lock` · `/unlock` | `AssetStatus.LOCKED` has been in the schema since the start and **nothing ever set it**. Locked **by listing, never by asset id** — the ACTIVE listing is the seller's consent; an asset-id endpoint would let any caller freeze someone else's property. Lock is idempotent; unlock is forgiving, because a compensation that throws over already-undone work turns a clean rollback into a FAILED run. |

### Honest status

- `[Code Verified]`, **not** `[Runtime Verified]`. Nothing has run against live services.
- **One schema push is outstanding** on `tec-identity-service`, covering all three
  columns (`user_id` · `input` · `output`). They are nullable and additive, so the order
  is: **push, then deploy** (Session 56c is why that sentence exists).

  > Written first as *"two schema pushes"* — once per merged PR. That is wrong in a way
  > that changes what an operator does: `prisma db push` syncs the WHOLE schema, so one
  > push after the last merge covers every column added before it. Counting pushes by
  > PRs counts the wrong thing.
- Ops: the four services need each other's `*_SERVICE_URL` + a shared `INTERNAL_SECRET`,
  or every dispatch fails closed with `…_SERVICE_URL is not set` — which is the correct
  failure, and a visible one.

### Phase status

- **1.1 ✅ · 1.2 ✅ · 1.3 ✅** (`/api/ready` in `tec-template-base` #33 — fleet rollout open)
- **2.1 ✅** (#310 · #311 · #312) — the bottleneck named in C-109 is closed
- Next: **3.x** — Nexus workflow history + templates in the app, Analytics → Alert.
- Open, unchanged: Mainnet App Wallet under review · `PI_A2U_FEE` unset · the
  `wallet_address` re-consent is still uncollected.
