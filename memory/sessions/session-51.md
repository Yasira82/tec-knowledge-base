# SESSION 51 — LIFE COMPLETES ITS CHARTER (3 Sep 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-core-backend
> **#267 · #268 · #269**; Tec-Life **#44 · #46 · #47**. Charter: **C-106 §11b**.
> Audit: `audits/LIFE_AUDIT_2026-09-03.md` — **every finding closed, the same day it
> was written.**

The session began with *"I want to redevelop Zone and Life from scratch"* and the answer
was to **read the code first**. The audit that came out of that reading is the session:
Life was **live, correct in what it does, and doing about a third of what its charter
says it owns** — the smallest module in `tec-identity-service` (168 lines of service,
against Explorer's 1,560) carrying the largest charter.

### 1. Three of six owned capabilities had no code at all

C-106 §4 names six. Goals, preferences and the activity timeline existed. **Skills,
trajectory and intent signals did not** — and those three are the ones that make a
personal context *usable by another runtime*. Goals and preferences are what a person
**says**; the other three are what makes it worth reading. All three shipped this session.

| # | Capability | Shipped as |
|---|------------|-----------|
| 4 | Skills inventory | `LifeSkill` + a LADDER (LEARNING→EXPERT), `source` on every row. **Self-declared half only** — inferring a skill means reading activity Analytics owns and applying a rule about what it implies, which is Life computing something it does not own (§4). The `ACTIVITY_INFERRED` column exists so an inferred row has an honest place to land. |
| 5 | Personal trajectory | `LifeGoalProgress` (append-only) → pace per week, active days, per-goal ETAs |
| 6 | Intent signals | Redis, 30-minute TTL, recorded from Life's OWN writes |

### 2. A direction cannot be read from a cumulative number

`LifeGoal.progress` said `40`. It could not say whether that took a week or a year, which
is the entire question a trajectory answers. So progress now also writes an **append-only
entry**, in the same transaction as the goal's new total — the total became a *projection
of* that log rather than a parallel truth, and a half-written pair would leave two numbers
that disagree with nothing to say which is right.

The entry records what was **credited**, not what was asked for: the last 5π toward a 100π
goal sitting at 97π credits 3π, and a log that kept the 5 would count π that never landed.

**The interesting part is when it refuses.** `projectable` is false unless there are ≥ 2
entries on ≥ 2 different calendar days.

> A projection from too little data is not a small error. It is a confident sentence
> **with a date in it**, and the date is the part a person acts on.

Three sub-decisions that each fix a wrong answer: elapsed time is measured from the FIRST
entry (not the window start — otherwise someone three days in is averaged over thirty days
of silence they were never here for, reading 70π/week as 16); days are CALENDAR days (ten
entries in one sitting are one day of effort); and the ETA **rounds** rather than ceilings
— 140π over "14 days" is 14 days plus milliseconds, so 20π at that pace is `2.0000004` and
a bare `ceil` reports **3**, a phantom extra day on every round number.

### 3. The identity anchor did not split a user — it SHARED one

C-106 P0-2 anchors Life on the permanent Pi identity. Three controllers resolved a token
carrying no Pi claims as:

```
piUserId = decoded.sub      ← a value that DIFFERS per person
username = 'unknown'        ← the SAME literal for everyone
```

`findOrCreateUser` looks up by `pi_user_id` first and by `username` second. The first such
caller created a row named `unknown`; every later one missed step 1, **matched it on step
2**, and was handed that person's identity — their goals, their follow graph, their
profile. **Invariant #3: identity always resolves to ONE principal.**

> A placeholder key satisfies that sentence and violates what it means.

Both fallbacks removed (a missing claim is a 401 — P6), plus a guard inside
`findOrCreateUser` rejecting blank and placeholder usernames before the database is
touched, so a fourth caller cannot reintroduce it.

**And the reachability was overstated the first time.** The CEO corrected it: sign-in is
"Sign in with Pi" only, so a Pi-less account cannot reach these routes at all. The defect
was **latent, not exploited**. The correction is recorded next to the finding in the audit
rather than folded silently into it — an audit that quietly rewrites itself stops being a
record of what was true.

### 4. Both privacy P0s closed — and the gate came BEFORE the reader

Life's own home screen tells every user their data is *"private, and never used without
your consent."* There was **no consent model in the schema**, and "delete" meant one goal
at a time. The sentence held only because nothing consumes Life data yet — a
**circumstance, not a guarantee**.

- **Consent** (§11 P0-1) — `LifeConsent`, category-level and timestamped, over GOALS ·
  SKILLS · PREFERENCES · ACTIVITY · TRAJECTORY · INTENT. Asked per category because
  "may TEC AI read my goals" and "may it read my activity" are different questions, and
  one switch forces the stricter answer onto both.
- **Right to delete** (§5) — one transaction over goals (with their progress log), skills,
  preferences, the consent grants **and the Redis intent window**. The `User` row and every
  payment record stay: Life does not own them and may not remove them. The route is
  `/data`, not `/` — this is "delete my Life data", not "delete my account".

**Absence is a NO.** There is no consent row until someone grants something. The
tidier-looking alternative — writing `granted: false` rows at signup — **fails open** the
first time a category is added without a backfill. That is not hypothetical: `INTENT` was
added to the enum later **in the same session**, and needed no migration and no backfill,
because a category nobody has a row for is denied for everybody.

### 5. The intent TTL is a privacy guarantee, not a cache

The one capability the charter names an implementation for ("Redis with TTL"), and the
detail turns out to be the whole design.

> Everything else Life owns is durable on purpose — a goal written last year is still
> yours. What someone is doing **right now** is the most sensitive thing in the app and
> the least useful an hour later, so it lives in a store that forgets by itself. Postgres
> keeps it "until something deletes it", and that is not a privacy property.

There is deliberately **no durable copy**: losing Redis loses the signals, which is the
correct failure when the alternative is a permanent record of every move. Signals are
facts Life already knows — recorded from its own writes, server-side. There is no "report
my intent" endpoint, because a client-fed signal is a client-controlled claim about a
person with nothing to verify it against, and the kind is a closed set so a future caller
cannot write free text about someone into the one store nobody reviews.

**Nothing reads Life data across the boundary yet.** The switches decide what will be
allowed when something does, and the Privacy screen says exactly that instead of implying
a protection already being exercised. Building the gate before the reader is the entire
point of a P0 named "privacy architecture first".

### 6. The UI was showing its own navigation twice

From a phone: *"the interface is ugly, and then it's the same thing — the buttons at the
bottom."* It was, and the reason was structural. Home was four cards — Goals · Skills ·
Activity · Preferences — the same four destinations the tab bar already carried, in the
same order, under the same grey rounded rectangle. **Tapping a card and tapping its tab
did the identical thing.** And every tab repeated its own band heading ten pixels below
itself, in a different colour.

Home now shows **state**: a snapshot strip, the goal closest to done with the one action
worth having there, and the last three events. The band is the heading. A home screen
earns its place by showing state, not routes.

### 7. Two bugs the new tests caught in their own code

- `Number(null)` is **0**, not `NaN` — so reading `window_days` straight into a clamp
  turned "no window given" into the **smallest** window: a seven-day pace presented under
  the thirty-day label. Not a rounding error; a different number wearing the same name.
- A bar rendered with `width: NaN%` is **dropped silently** by the browser — it looks like
  a missing feature and logs nothing. `goalPercent` clamps instead.

### Honest status

`[Code Verified]` — merged and tested (**813** identity-service tests, **87** in Life),
not `[Runtime Verified]`. Skills was seen working on a real device; Pace, Privacy and the
intent window need `prisma db push` (`life_goal_progress`, `life_consents`) and a look on
a phone.

**The next step is now unblocked rather than begun:** the outbound personal-context API
(§4 Interface Points, TEC AI). The gate it must pass through exists.
