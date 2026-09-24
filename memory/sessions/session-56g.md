# SESSION 56g — Phase 3: the runtimes start talking, and one of them starts listening to people

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Three steps closed. They look unrelated and are the same move three times: a fact that
already existed inside one runtime was made available to the runtime whose job it is.

| # | Step | Shipped |
|---|---|---|
| 3.1 | Nexus workflow history + the templates surfaced in the app | Tec-Nexus **#33** — and the app's THIRD copy of the workflow definitions deleted |
| 3.2 | Analytics computes the finding → Alert classifies it | tec-core-backend **#314** · KB **#143**. **Deployed**: the sweep is scheduled and the `identity-alert` consumer is live on `analytics.finding.raised.v1` |
| 3.3 | TEC AI compiles an intent object, and does nothing with it | tec-core-backend **#315** (sink) · tec-app **#236** (compiler) |

### 3.2 — the split that keeps one inbox one inbox

Analytics emits a FINDING with **no severity and no recommended action**: what was
measured, what was expected, over what window. Alert decides severity, category and
wording. The moment a producer grades its own findings, the platform has two runtimes
answering the same question on two scales — the C-96 dual-poller (NEW-K) in a new
costume. A unit test pins the absence of a `severity` key on the producer side.

The detector's interesting rules are its **refusals**: fewer than three baseline days is
an anecdote, and a baseline at or below 3 means you cannot drop from nothing. A detector
that fires readily produces a stream nobody reads, and the first real finding then
arrives in a feed already full of noise — which is the same as not having raised it.

### 3.3 — the instrument, and why `null` is the point of it

IIC 4.3 needs a **closed** objective set, because a free-text goal cannot be compared
between versions and drift on the goal is the one thing that must never go unmeasured.
The only honest way to design that set is from asks people actually made — so TEC AI now
compiles every user turn into the intent object it *would* hand to a gate, and **nothing
reads it**. No routing change, no prompt change, no visible product difference.

> **The unmatched rows are the deliverable.** When nothing in the closed set matches, the
> observation carries `objective: null` and a capped excerpt of the ask. That row says
> the vocabulary is incomplete AND what it is missing. A compiler that always found
> something to return would report a complete set on day one and be wrong in a way nobody
> could see — the same failure shape as a detector that always fires.

Three decisions worth keeping:

- **The vocabulary lives in ONE place** (the Hub's compiler). `tec-analytics-service`
  holds no copy and validates *shape and bounds* only. A server-side allowlist would have
  been a second definition of the same rule (P2) **and** would have rejected exactly the
  rows that prove the set incomplete.
- **Research is not activity.** `ai.intent.observed` is an inference about what somebody
  ASKED, not something they DID, so `getRecentEvents` excludes it at the single read every
  activity surface goes through. Listing it in Life's timeline would tell a user they did
  something they did not do.
- **Constraints come from the user, never from the compiler.** A budget is recorded only
  when stated, with the span it came from. An inferred budget is a number the platform
  made up about somebody's money.

**One deliberate deviation from the plan.** It said *"on every Recommendation"*. Filtering
to replies that carried a nav marker would sample only the objectives the system prompt
already knows how to route — precisely the wrong sample for finding the ones that are
missing. The trigger is every user turn: the ask is the intent, the reply is the
platform's answer to it.

The emit is fire-and-forget and every failure path is swallowed, which is the one place in
that codebase where a silent catch is correct: a research instrument that can fail a chat
is a bad trade at any price.

### Status

- 3.1 · 3.2 merged and **deployed**. 3.3 merged-pending — no schema change in either half,
  so **no `db push`** is required; analytics-service + the Hub redeploy and it runs.
- 3.3 becomes useful in about a month. Until then it produces rows and no conclusions, and
  reading it early would be the mistake it exists to prevent.
- Still open from earlier phases: the `/api/ready` fleet rollout (1.3), and no Nexus run
  has been driven end to end in production (2.1 execution).
