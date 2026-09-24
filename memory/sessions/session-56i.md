# SESSION 56i — the gate: the intent layer stops recording and starts refusing

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

`tec-core-backend #316` grows to **4.1 + 4.2 + 4.4**. The gate is pure, deterministic, and
**ships inert** — no run cites an intent today, and a run that cites none passes through
untouched.

### Why "no intent → allow" is not fail-open

Spec §6 property 3: this layer can only ever **narrow**. It narrows what a HUMAN
authorized; where nobody authorized anything through it, there is nothing to narrow and
C-47 governs as it always has. Denying those runs would be the intent layer **adding** a
restriction the constitution does not have — the opposite of its job, and it would stop
every workflow in production on the day it shipped.

The fail-closed rule lives one step in: a run that **does** cite an intent, and cannot
produce it — unreadable, not CONFIRMED, revoked, superseded, lapsed — is refused. That is
genuine doubt, and doubt denies (P6).

### Two placement decisions, and both are the whole value

**The gate runs BEFORE the payment halt**, not beside the dispatcher.

> Halting for payment is itself an act: it puts a request for real Pi in front of a
> person. Asking somebody to pay under a mandate that has lapsed or been revoked is not a
> neutral pause. Moving the call one branch later fails **exactly one test and nothing
> else** — which is what a placement test is for.

**Expiry is checked per step, not once at start.** A run authorized at 10:00 by an intent
lapsing at 12:00 must stop mid-saga at 12:01. Checking only at `startRun` would make the
expiry a formality that the longest runs always outlive — and a long run is precisely what
an expiry is for.

A denial changes **nothing**: no FAILED marker, no rollback. Nobody was asked to do
anything, so there is no partial state to undo — the same reasoning as the
no-callable-target refusal.

### Three absences, each pinned by a test

| Not checked | Why |
|---|---|
| Amount ceilings | No step declares a Pi amount — the figure is set in the Hub's payment modal and arrives on `payment.completed.v1`. The check could never fire. |
| Exclusions | The gate sees a service name and a payment flag, never the product. Whether a listing is an auction is commerce's fact about commerce's data. |
| The delta | §5's Δ compares a *proposed* intent against the root; nothing proposes one yet. `/intent/:id/check` serves it for when an agent does. |

> **A gate whose surface suggests it checks budgets is worse than one that says it
> doesn't** — it answers "is spending limited?" with a yes nobody earned. The same failure
> family as a detector that fires on noise, and as a step that reached DONE having called
> nothing.

An empty `authority.services` authorizes **nothing** rather than everything: the
permissive reading is the one an absent-minded intent would accidentally choose.

### A runbook correction this session earned the hard way

`tec-core-backend/CLAUDE.md` says a schema change needs a Custom Start Command of
`npm run db:push && node dist/main`. That is right for **nine** of the ten services with a
schema — and **wrong for `tec-identity-service`**, the one Phase 4 keeps touching. Its
Dockerfile CMD is already `node scripts/migrate.cjs && node dist/main.js`, a wrapper with
a deadline and a Postgres `lock_timeout`, written after a 2026-09-01 deploy hung on a
migration lock and failed the healthcheck **with no error message**.

Setting the start command there **overrides that CMD** and reinstates the unbounded push.
Which is what happened: `Network › Healthcheck ✗ (04:41)`, same shape, same silence.
Production was untouched only because the wrapper's non-zero exit leaves the previous
version serving — the failure mode it was designed for.

> **For identity-service: leave the start command empty and let the image migrate itself.**

### Status

- 1180/1180 green (81 new across 4.1·4.2·4.4), typecheck + lint + build + policy-check
  clean — **all run locally**, because Actions is blocked by a declined account payment
  (13-09, $29.00) rather than by anything in the diff.
- **Next: 3.4 (`dx doctor`) or the `/api/ready` fleet rollout** — 21 of the 22 apps lack
  `/api/ready`. 4.3 stays parked until 3.3 has collected a month of real asks.
