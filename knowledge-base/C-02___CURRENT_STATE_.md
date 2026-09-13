# C-02 — CURRENT STATE
## Living Document — Updated End of Every Session

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `main`

**Last Updated:** 13 September 2026 (Session 56k — three credentials out of CI; the payout asks the service instead of its database)

---

## SESSION 51 — LIFE COMPLETES ITS CHARTER (3 Sep 2026) ✅

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

---

## SESSION 51.1 — THE DESIGN PASSES, AND THE INTERFACE LIFE WAS BUILT FOR (4 Sep 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** — Tec-Life
> **#48 · #49 · #50**; tec-core-backend **#270 · #271**; fleet radius sweep in tec-app,
> Tec-Connection, Tec-Explorer. Charter: **C-106 §11b**.

Session 51 closed every finding in the audit. This continuation is what came back **from a
phone** afterwards, plus the one capability the whole charter is for. Four defects were
reported in one message, and two of them are lessons the fleet needs, not Life bugs.

### 1. "The curve at the top is still big"

Reported twice. The first fix reduced it; the second found the actual number. The top band
is painted from `--tec-topbar-radius`, and the value was **22px** — a radius that reads as
a card floating in the page rather than a band belonging to it. Now **8px**, and swept in
the same change to the three other repos that had copied the same token file (tec-app,
Connection, Explorer), because a token duplicated across four repos diverges the moment one
of them is corrected alone.

> The fleet has now paid this cost twice — once for the palette (Session 46), once for a
> radius. **A copied token file is a fork with a friendly name.**

### 2. A goal that closed itself — fact versus judgement

Logging progress that reached the target **auto-completed the goal**, server-side. The CEO
said goals should not be automatic, and asked which reading of that was correct rather than
choosing one. The answer, and the reason it generalises:

> Reaching 100π is a **fact** — the app measured it and may assert it.
> "This goal is **done**" is a **judgement**, and C-106 §4 puts self-declared data under
> the user's control. Someone who hits their number and decides the goal was too small is
> not finished, and the server had already decided for them — into a **terminal state**,
> which nothing in Life reopens.

The auto-complete is removed. The screen now says **"Reached"** the moment the number lands
— the fact, stated plainly — with the "Mark done" action beside it. The user closes it.

### 3. The silent Add button — the general one

*"I press Added on skills and it gives me nothing."* Both halves of the stack required a
**2-character** name; a one-letter skill (`R`, `C`, `Go`, and every CJK skill name) was
rejected by a `disabled` attribute on the front and an `if` on the back. Nothing was shown
because nothing failed — the button simply did not fire.

> **A disabled button is the one form of validation a person cannot read.** An error
> message says what is wrong; a greyed-out control says only that the app is not listening,
> and the user's next move is to try the same thing again, then leave.

Fixed at both ends (1 character), and the test that pinned the old rule was **corrected
with its reasoning written in**, not deleted — a test that encodes a wrong rule should
record why the rule changed, or the next session re-adds it.

### 4. Pro and Invite were shouting at the bottom of every page

Two full-width cards, stacked, each with its own heading, price, description and a raw
referral URL printed as body text. They are the last thing on the page in every tab. Both
are now one row each — label, value, action — and the raw URL is gone: nobody types a
referral link they can copy.

### 5. The interface Life exists for (tec-core-backend #271)

C-106 §2: *"without Life, TEC AI has no personal context, Connection has no relationship
baseline, and Ecommerce has no personalization signal."* Every capability built in Session
51 was for a reader that did not exist. `GET /identity/life/context/:username` is that
reader's door — and it is the **first thing in this app that hands one person's data to
something that is not that person**, so it is defined by what it refuses.

| Refusal | Why |
|---|---|
| **Consent gates every category** — nothing granted, nothing served | The gate landed a session before the reader. This is the call it was built for. |
| **A denied category is not an empty one** | The consent map travels with the payload. A reader handed `goals: []` cannot tell "no goals" from "not allowed", and will cache whichever it guessed. |
| **A table is never read for a category that was not granted** | Consent that filters after the read is a permission check with the data already in memory. |
| **Trajectory is a pace, never the entry log** | "Where is this person headed" does not need every step they logged. Serving more than the question needs is how a consented read becomes an export. |
| **ACTIVITY is never served, even when granted** | Life does not own it (§4). It reads it live from Analytics for the user's OWN screen; handing a reader Life's copy of someone else's truth is the copy nobody keeps correct. It is absent from the payload **and** from the audit's served-list, while the grant itself is still reported honestly. |
| **Every read is audited — including one that served nothing** | An attempt is a fact. The row carries the reader, the categories and nothing else: **no content**. The data is already in this database, and copying it into the log creates a second store with different retention and no consent gate. |

The route is **ServiceActor only** (`x-internal-key`, constant-time, fails closed) — C-47's
service-to-service exception, and the one Life route where the subject is a parameter
rather than the session. **824/824** green.

### Honest status

`[Code Verified]`. Nothing here is `[Runtime Verified]`: the Pace panel in particular has
never been seen working, because it needs progress logged **on two different calendar
days** before it will project at all — by design (Session 51 §2). The context API has
**no consumer**; it is a door, and TEC AI is not built.

### Also this session — the platform's own bill, read for the first time

A declined card (`$72.04`, twice) sent us to the billing pages, and what was there is a
finding in its own right. **Full record: C-78 §13b.** In short:

| Cause | Size | Status |
|-------|------|--------|
| **Copilot automatic code review** — fired on every **push**, not every PR | $19.62 in 4 days | ✅ Disabled |
| **Actions overage** — `npm install` runs 4× per CI run, no `cache: 'npm'` | $58.04 in July | ◐ fix identified, not applied |

Three things worth carrying, all of which cost a wrong answer first:

- **The invoice, not the dashboard.** August was assumed to be more AI credits. The PDF
  says it contains **none** — it is 80% Actions. Two different problems behind one symptom.
- **A measurement killed the first fix.** A `concurrency` guard was about to be swept to
  26 repos because the Hub has one. Life's runs average **3.4 min** with **7–15 min**
  between pushes — zero overlap in the last 20 runs. It would have saved nothing. The
  Hub's fix is right for the Hub, whose runs are five times longer.
- **A config file that nothing reads is worse than none.** `tec-app/.github/copilot-code-review.yml`
  said `enabled: false` for months; GitHub does not read that filename, and the reviews ran.

> And the last review before it was switched off found a **real defect** in this session's
> own work — a guard test that passes when the thing it guards is deleted (`indexOf` → -1).
> The tool was not billing for nothing; it was doing useful work at a price this PR volume
> cannot carry. Both are true, and the honest record says so.

**Shipped:** `cache: 'npm'` in **24 repos / 114 jobs**, and a separate fix in
`tec-core-backend` (its `push` trigger listed `claude/**` while `pull_request` covered the
same commit — **every branch commit ran two identical pipelines**). Three repos excluded on
purpose, each for a different measured reason. **27 PRs open.**

**And a NEW-A scare that turned out to be nothing — C-78 §13c.** `src/lib/sdk.ts` (14
repos) hardcodes a Railway host as a fallback, and the import graph appears to carry it
into the browser via `usePiAuth`. A real `next build` says **0 occurrences** in
`.next/static` — webpack drops the unused `pi-auth` exports, so `lib/sdk.ts` never enters a
client chunk. The grep method was validated first against strings known to be there.
Recorded as a **negative finding** so the investigation is not repeated.

> **The session's own lesson, earned four separate times:** an inference about this
> platform was confidently wrong, and each time a measurement taking minutes settled it —
> the concurrency guard that would have saved nothing, the invoice that contained no AI
> credits, the backend that already had the cache, and the URL that never shipped. **Build
> it and grep it. An import graph is not evidence about what ships.**

---

## SESSION 50.1 — THE HUB'S COLOURS WERE NEVER WRITTEN DOWN (3 Sep 2026) ◐

A one-line question — *"did you document the Hub's colour shades in the KB?"* — and the
answer was **no**, with a consequence already shipped.

**What C-83 actually had:** the dark WEALTH tokens, and `#FEA500` mentioned once in
passing inside a note about something else. Nothing on the light palette, the three
theme states, the channel tokens, the gold-family rule, the status-colour contrast, or
the top band. All of it live in the Hub for months, in code, in one repo.

**What that cost, the same week:** porting light mode to Explorer and Connection, the
Hub's values were not available to copy — so they were re-derived. Twice wrong:

| | Hub (authority) | What shipped | Effect |
|---|---|---|---|
| `--tec-gold-dark` (light) | `#E08800` | `#F08C00` | two apps a shade apart on the same button |
| `--tec-gold-light` (light) | `#FFC04D` | `#FFC24D` | " |
| status colours (light) | darkened (`#15803d` …) | **not overridden** | `#22C55E` on white ≈ **2.3:1** — every success line unreadable as text |

The status-colour miss is the serious one: it is a contrast failure, not a shade
disagreement, and the gold-family guard did not cover it because that guard was written
for the gold family.

**Closed:**
- **C-83 §5.5** — the theme contract, written as the AUTHORITY rather than a
  description: three states · the light palette table · *a token is a family, not a
  value* · status colours darken (with the measured ratios) · channels and the four
  shapes of the silent-failure bug · the top band + `.tec-on-band` · the two structural
  hex exemptions.
- Connection + Explorer realigned to the Hub's values, status colours darkened.
- A new guard in both: the light block must override `--tec-green/blue/red/purple` and
  their channels.

> **The lesson, and it is the fleet's oldest one.** A value that lives in one repo and
> nowhere else is not a standard, it is a coincidence — and the next app will re-derive
> it slightly differently. C-02 Session 46 recorded this exact shape (a rule existed,
> one repo followed it, nobody back-adopted it) and it recurred inside two weeks,
> because the fix then was to sweep the repos rather than to write the rule down.

### The follow-up question found a bigger gap

*"…the greys and blacks and off-white too, and the curves on the inner pages"* — and
reading the Hub to answer it turned up that **C-83 §4 declares three background values
the Hub stopped painting.**

| | C-83 §4 says "IMMUTABLE" | Hub actually ships |
|---|---|---|
| Layer 1 | `#050816` blue-black | **`#101014`** neutral charcoal |
| Layer 2 | `#0B1020` | **`#21212a`** |
| Layer 3 | `#111627` | **`#2c2c37`** |
| Layer 4 | *(none — only three layers)* | **`#383844`** |

A doc that declares "no app may override" over values the reference implementation
abandoned is **worse than saying nothing**: an app reading it adopts the wrong ground in
good faith, which is what all 23 of them did.

**Recorded as C-83 §5.6:** the neutral dark ramp and why it is neutral (a blue-black
pushes the Pi amber green); the warm off-white light ramp and why the PAGE is off-white
while the CARD is white; the four-step ink ladder plus `--tec-icon` and the two fill
washes; and the radius scale including `--tec-topbar-radius: 22px`, which sits between
`lg` and `xl` on purpose and applies to the bottom corners only. §4 gets a supersede
banner — kept, not deleted, because 21 apps still run it and the *structure* is still
right; only the numbers moved.

**Deliberately NOT swept.** Each app takes the ramp with its own change, verified on a
device, copying §5.6.1–5.6.3 rather than approximating them — that is the whole lesson
of 50.1, applied the same day it was written. Ramp first, then the band: a band tuned
against `#050816` and dropped onto `#101014` is a different band.

**First adopter, same session.** Connection took the ramp — `#050816 → #101014`,
`#0B1020 → #21212a` for the card — plus the four-step ink ladder and `--tec-icon`. It is
pinned by VALUE in that repo's `theme.test.ts` (verified to fail when the old ground is
put back), because a guard that only checks "a light override exists" would have passed
the re-derived amber above.

### The table, and the style law (C-83 §5.7 + §5.8)

Asked to write down **all** the colours and the style, because it goes into every app.
§5.5–5.6 explained the reasoning; §5.7 is now the lookup table (every token, both themes,
plus radius / spacing / type / shadow / motion / z) and **§5.8 is the component style
law** — eight rules, each written after the opposite shipped, each naming what went wrong:

| | Rule | What it cost |
|---|---|---|
| 5.8.1 | A filled accent is **flat** | 21 buttons in Connection, 10 in Explorer, gradienting `#FEA500 → #E08800` — a dirty patch on every one, in light |
| 5.8.2 | The accent gets **one meaning per surface** | a gold bubble per message drowned the one gold that meant something (you were **named**) |
| 5.8.3 | Icons from the set, **never emoji** | 📎🎤➤ carry their own colour, so no token reached them, and each platform drew them differently |
| 5.8.4 | **One slot** for a mode pair | the primary action sat grey and disabled most of the time, and the input paid for both in width |
| 5.8.5 | Chrome sits on a **surface** | composer + nav on one ground read as a single thick strip |
| 5.8.6 | The band's **proportions** are part of the shape | a 22px corner on a 117px band reads heavier than on an 87px one — same token, different curve |
| 5.8.7 | Three places take hex, and **only** hex | the exemption was one-directional, so a sweep put `var()` into the SSO landing and the share card — no ground, no accent, live |
| 5.8.8 | What a guard must check | by **value** not presence · **derived** not listed · for the **class** not the last bug |

§5.8.8 is the one that generalises: **five forms of a single silent failure shipped in
sequence, each past a guard written for the previous one.**

### Explorer joined the ramp

Same session, same values — flat amber, `#101014` ramp, four-step ladder. Two earlier
Explorer commits (the gold family + darkened status colours) turned out never to have
landed: **PR #36 merged an earlier state of the branch**, so `#22C55E` on white — ~2.3:1
— was still shipping there. Rebased onto current `main` rather than re-derived.

**Adopted: Hub · Connection · Explorer.** Remaining: 21.

**Still open:** the other 21 apps have no light theme at all and are on the old ramp.
When they move, §5.5–§5.8 are what they copy from.

---

## SESSION 50 — THE DEAD BADGE: FIVE VERIFICATION SURFACES THAT COULD NEVER FLIP (2 Sep 2026) ◐

> Truth State: **[Current State]** for what merged · **[Planned State]** for what is in
> review · Verification: **[Runtime Verified]** only where named below, **[Code Verified]**
> everywhere else.
> **Merged:** Tec-Explorer **#31 #32 #34 #35** · tec-core-backend **#261 #262 #263**.
> **In review:** tec-core-backend **#264** · Tec-Zone **#36** · Tec-Explorer **#36** ·
> Tec-Estate **#30** · Tec-Epic **#34** · Tec-Nx **#28**.

### 1. The finding that organises the whole session

A `verified` column, read by the app, **ranked by** in the query, rendered as a badge,
and documented in a comment explaining where it comes from — with **nothing anywhere
writing it**. Found in **five** places, independently:

| Surface | Column | State before |
|---|---|---|
| Explorer | `ExplorerVerification` | Wired to the WRONG EVENT (below) |
| Connection | `ConnectionProfile.verified` | No writer at all |
| Epic | `EpicProject.zone_verified` | No writer at all |
| NBF | `NbfBusiness.zone_verified` | No writer at all |
| Estate | `zoneVerified` (frontend) | No writer, and none possible |

**Why this is worse than a missing feature.** Each of these lists orders trust-first:

```
orderBy: [{ verified: 'desc' }, { featured: 'desc' }, … ]
```

With the earned signal pinned `false` for every row, the ordering collapses onto the
**next** key — `featured`, which is a Pro placement and is **bought**. Every one of these
directories was ranking by the paid signal *because the earned one was empty*. Connection's
own `DirectoryCard` carries a comment warning against exactly that inversion, above code
that had been doing it since the column was created.

> **The rule this session earned:** a column that is READ and RANKED BY but never WRITTEN
> does not fail loudly — it silently promotes whatever key sorts after it. Adding a trust
> field and its writer must be one change, or the field is a lie with a sort order.

### 2. Explorer: the wrong event, not the wrong payload

The consumer listened to `kyc.verified`. Two separate errors, one visible and one not:

- **Constitutionally wrong.** KYC verifies a PERSON — an ID document and a selfie. It
  answers *"who is this?"* and cannot answer *"does this shop exist?"*. **C-120 §3 (WHAT
  ZONE OWNS)** lists `Merchants → Pi-accepting businesses` — word for word what the
  Explorer index holds. Explorer's own CLAUDE.md said KYC. **Two charters disagreed and
  the code followed the wrong one.**
- **Mechanically dead.** `kyc.verified` carries `{ userId, level }` — a UUID — while the
  consumer resolves a Pi username. `ownerOf` returned `undefined` every time, so
  `applyVerification` was never called. No error was logged, the consumer group existed,
  and every health check stayed green.

The zone events carry `piUsername` directly, which is the key `applyVerification` already
used — **the constitutionally correct source turned out to be the simpler one**, with no
identity translation left to get wrong.

### 3. Zone only ever announced half a decision

`reviewDecision` emitted on VERIFY and said nothing on REVOKE. A badge could be granted and
**never withdrawn**: Zone would show `REVOKED` while every consumer that had acted on the
grant kept displaying it. `zone.badge.revoked.v1` closes it.

> A verification that cannot be taken back is worse than one never given, **because it is
> trusted**.

### 4. Which verification vouches for what — the rule, in one place

Zone verifies four kinds of thing, and collapsing them into one boolean is how a badge
starts claiming something nobody reviewed:

| Consumer | Accepts | Because |
|---|---|---|
| Explorer (shops) | `MERCHANT` | A verified BUILDER is not a verified shop |
| Connection (people) | `BUILDER` + `MERCHANT` | Both are facts about the PERSON's own economic identity |
| Epic (projects) | `PROJECT` | |
| NBF (businesses) | `MERCHANT` | |

`PROJECT` and `COMMUNITY` never vouch for a person: **verifying a community does not vouch
for whoever registered it.**

The filtering lives in `ZoneService` (`hasVerifiedIdentity`, `verifiedNamesFor`) and
deliberately **not** in any consumer — deciding it in two places is how two answers start
to disagree.

### 5. Recompute, never toggle

Every consumer asks Zone for the current answer rather than flipping a boolean from
whichever event just arrived. Both reasons are correctness, not taste:

- **A person can hold several verifications.** Revoking a MERCHANT badge must not clear the
  flag while a BUILDER verification stands — a toggle would, and it would look like Zone
  withdrew something it never did.
- **Streams are at-least-once.** A recompute is idempotent by construction; only rows whose
  value actually differs are written, so a redelivery writes nothing.

### 6. Estate: a claim the platform cannot make at all

Estate showed **"🛡️ Zone Verified" / "Verification pending"**, listed **"Unverified"**, and
counted **"✓ Zone"** on its dashboard. All four were permanent, and no code could change
them — **Zone has no property type**. Its four kinds are PROJECT, MERCHANT, BUILDER,
COMMUNITY (C-120 §3). A building is none of them.

So "pending" promised a review that was not queued, could not be requested, and had no
process behind it. The label now reads **"Self-recorded"**, and the counter is removed
rather than left pinned at zero.

> When a badge cannot be backed, the fix is not a better data source — it is **saying what
> is true**. A permanent "pending" is a promise; "self-recorded" is a fact.

### 7. Zone's applicant surface was invisible

The whole verification workflow — submit an entity, attach evidence, watch the status —
was **built and rendering nothing**. `VerificationPanel` opened with `if (!isAuth) return
null` and was handed `usePiAuth().isAuthenticated`, which reads `document.cookie`. Pi
Browser stores `tec_user` so the SERVER can read it and client JS cannot (**C-123 §3**), so
on the only platform this ships to that value is always `false`.

The page already knew: `useMe()` is a server round-trip and the line declaring it carries
the C-123 note. Two call sites were missed.

**The identical bug had shipped in Explorer's "My Business" tab weeks earlier** — same
hook, same `return null`, same platform. It is now pinned by a test in both repos.

`ReviewPanel` is deliberately left NOT gated on the client flag: a genuine ADMIN can be
signed in with `isAuth=false`, and the backend answers 403 for a non-admin, so
authorization stays server-side either way (P6).

### 8. Fabricated verifications in fixture data

`PROJECTS` (Epic), `PORTFOLIO` (Estate) and `OPPORTUNITIES` (NX) carried `verified: true` on
twelve rows between them. A fixture wearing a verification badge is **the platform verifying
itself** — C-120 and C-108 §4 forbid it, C-135 §4 forbids a fabricated directory reaching a
screen.

None are rendered today; every page resolves live data. **That is precisely why it mattered:**
Explorer's seed was dead too, until someone wired it and eight invented businesses appeared
in production carrying six "Verified" badges. A fixture is one import away from being real.

All twelve are `false` now, with a test in each repo pinning it. In Epic **a test was
asserting the violation** (`expect(legend?.zoneVerified).toBe(true)`) — a test that requires
the badge turns the violation into a rule.

### 9. Explorer: trust became a ladder

Every real merchant was labelled **Unverified**, because the only other value required a
review that is not reachable end-to-end. A badge with one attainable value is not a badge —
it is a warning printed on everything, and `live · 0 verified` was permanent.

| | Means | Evidence |
|---|---|---|
| **L1** Self-listed | Nobody stands behind it | No owner (legacy rows only) |
| **L2** Pi account | A real person with a Mainnet wallet listed this | `owner`, written server-side from a verified session token |
| **L3** Verified business | A reviewer checked the business | Zone's verdict |

**L2 is not Explorer verifying anything** (C-108 §4) — it reports a fact already held. It is
**derived, never stored**: no enum change, no migration, and no trust column that can drift
from the facts it summarises.

### 10. Also shipped in Explorer (merged)

| | The decision worth keeping |
|---|---|
| **Arabic search** | Both the stored text and the query fold through ONE normalizer. ة/ه · أإآ→ا · ى/ي · tashkeel · tatweel · Arabic-Indic digits · `ال`. Folding one side only makes matching *worse*. |
| **Removing a listing** | A **redaction, not a delete**: `uniqueHandle` frees the slug when the row goes, so the next merchant with a similar name would inherit the previous business's reviews and moderation reports. Reviews and reports survive — otherwise "delete and re-list" clears a record. |
| **Five listings per owner** | Was one, which refused anyone with two branches. |
| **Light + dark** | The token file carried a `[data-theme='light']` block from day one that **nothing could reach**: 248 `TEC_COLORS` references are hex baked into inline styles, decided at render. Now `var(--tec-*)`, with CHANNEL tokens (`--tec-gold-rgb`) because `var(--tec-gold)22` is invalid CSS that **raises no error**. |
| **Map pin without a permission** | `navigator.geolocation` was the ONLY way to set one, and Pi Browser's host app decides whether it reaches the page. Now: tap the map, or paste coordinates. `٫` (U+066B) is the Arabic **decimal** separator — read as a comma it moves a pin thirty degrees, into the sea, in silence. |

### 11. What the audit cleared

| App | Finding |
|---|---|
| **Life** | No verification concept, and correctly so — a personal record has no entity to verify. Nothing changed. |
| **Commerce · Ecommerce · Assets** | `kycVerified` from the JWT is a **personal gate** ("KYC before you sell"), never a trust badge shown to buyers. Correct as-is. |
| **Nexus · System · Dx · FundX · Vip · Elite · Insure · Titan · Alert · Hub** | No verification claim rendered. Nothing to fix. |

### 12. Guards added, and why each exists

Every rule below fails **silently** when broken, which is why each is pinned rather than
reviewed:

- **Theme (Explorer, 23 tests)** — the alpha-on-a-token guard was rewritten twice because it
  only knew the shapes of bugs already found. Four forms shipped past earlier versions:
  `${C.gold}22`, `${(v ? C.gold : C.subtext)}55`, `C.subtext + '55'`, `rgba(5,8,22,0.92)`.
  *A guard that chases syntax one form at a time finds each bug once.*
- **Trust ladder (Explorer, 30)** · **pin fallback (23)** · **removal (12)**
- **Verification source (backend, 27)** — including that the health sensor moved WITH the
  subscription: left pointing at `kyc.*` it would report a healthy group on a stream
  Explorer no longer touches and miss a dead one on the stream it now reads.
- **Zone visibility (9)** · **fixture honesty (3 repos)**

### 13. Open, and honest about it

- **#264 is not merged.** Until it is, four badges remain unwritable.
- **L3 is unreachable in practice** even after merge: Zone's applicant surface needed
  **#36** to be visible at all, and no merchant has submitted anything. Explorer handles
  this honestly by showing L2 rather than a permanent "Unverified".
- **The Zone↔Epic join is by owner + NAME**, matching the frontend's existing
  `zoneStatusForName`. A stored `zone_handle` would be exact and is deliberately NOT added:
  nothing would write it without a submit-to-Zone flow inside Epic, and **a nullable column
  no code fills is precisely the failure this session was fixing.**
- **Runtime Verified** covers only what was seen on a real device: the Arabic search
  returning a real listing, the light theme, and the map. Everything else is
  **[Code Verified]**.
- **Fleet reality:** the Explorer index holds **one real listing** — the owner's own. The
  subscription-activation gap ran across 19 apps for months before anyone noticed. Both are
  evidence that the fleet has close to zero users, which is a product question and not an
  engineering one.

---

## SESSION 49 — CONNECTION MESSAGING COMPLETED, AND A LESSON ABOUT GUESSING (1 Sep 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** — Tec-Connection
> **#47**–**#52**; tec-core-backend **#242**, **#243**, **#255**–**#259**. All merged and
> deployed. Reactions, the invite link and the actions sheet confirmed working on a real
> device in Pi Browser.

### 1. What shipped — Connection is a messenger now

Ten features across the session, each guarded by the same rule: **a message id is
re-derived against its conversation id, from the database, every time.** Every one of
these is a new way for a message to move, be seen or be changed, and therefore a new
place for one conversation to leak into another.

| Feature | The decision worth keeping |
|---|---|
| Group discovery + join requests | A PUBLIC group's **existence** is discoverable — title, description, member **count**. Never its members or messages. |
| Multiple admins | Admins cannot publish/unpublish or promote/demote. *An admin who can promote installs allies; one who can demote removes the others.* |
| History pagination | Timestamp cursors, not offsets — messages arrive while you scroll, and an offset skips or repeats one every time they do. `take+1` answers "is there more?" without a second query. |
| Reply / quote | A **reference joined at read time**, never a stored snapshot: a snapshot outlives delete-for-everyone, leaving retracted words inside every reply to them. |
| Mentions | A group used to notify **nobody**; the obvious alternative — everybody — is what makes people leave a busy group. It now notifies exactly the people it **names**, filtered against the member list. |
| Per-member mute | `muted_at`, a timestamp not a flag. Muted members are filtered **last**, after the recipient set is built — "was I named?" and "do I want to be interrupted?" are different questions. |
| Unread divider | Drawn from a watermark **frozen** at open. Opening marks the thread read, so a live computation would flash once and vanish. |
| Search in a conversation | Hides everything the transcript hides — and **in the query**, not after. A search that filters afterwards has already pulled the rows out. |
| Reactions · edit · forward · pin | Six fixed emoji (an open column is arbitrary text shown to a whole group); a **15-minute** edit window (unbounded editing lets someone rewrite an argument days later); forwarding copies the text but **never the reply link**. |
| Invite links · announcement groups | The link bypasses the owner's approval queue, so **owner only**, and every issue mints a fresh code — re-issuing *is* revocation. Announcement mode is closed on **both** write paths through one function; two implementations is how forwarding becomes the way around the policy. |

**Honest limits, unchanged:** voice recording does not work in Pi Browser (the webview
refuses the microphone) and push notifications need a native app. Neither is missing
work. The twelve translations are unreviewed by native speakers.

### 2. The deploy incident — and the actual lesson

After the features merged, `tec-identity-service` would not deploy. Five attempts, all
identical:

```
Initialization  ✓   Build ✓   Deploy ✓
Network > Healthcheck  ✗ (04:44)   Healthcheck failure
Diagnosis failed for this deployment.
```

**Three theories were produced before anyone read a log.** In order:

1. *The migration is hanging on a lock held by the previous container.* Plausible —
   the schema push runs inside the start command, before the server listens, so a stuck
   migration is a total outage rather than a failed migration. A bounded, loud wrapper
   shipped (#258). **The deploy failed again, identically.**
2. *Then it is not the migration.* `prisma migrate diff` was run against the schema and
   the SQL came back **purely additive** — no dropped column, nothing destructive, no
   reason for `db push` to refuse. **This reasoning was correct and the conclusion was
   wrong.**
3. Only then was the deploy log opened. One line settled it:

```
⚠️ There might be data loss when applying the changes:
  • A unique constraint covering the columns `[invite_code]` on the table
    `connection_conversations` will be added.
Error: Use the --accept-data-loss flag to ignore the data loss warnings
```

`prisma db push` refuses to add a **UNIQUE constraint** without that flag. The container
exited immediately, Railway restarted it under `always`, and it looped every two seconds
until the healthcheck window ran out — which is precisely why it *looked* like a hang
from the outside, and why the timeout added in #258 never fired.

> **The generated SQL was additive. Prisma's refusal is a SEPARATE, coarser check that
> does not read that SQL at all** — it does not distinguish "this might fail" from "this
> will delete a column". Reasoning about the artifact the tool produces is not the same
> as observing what the tool does.

### 3. The fix, and why not just pass the flag

`--accept-data-loss` as a permanent setting fixes one deploy and leaves a loaded gun in
the start command: the next schema change that drops a column does so **silently, in
production**. So the flag is now **earned, per deploy** (#259):

- read the SQL `db push` is about to run, from the live database;
- scan it for `DROP TABLE` · `DROP COLUMN` · `TRUNCATE` · `DELETE FROM` · a column type
  change · a rename;
- **none** → pass the flag · **any** → withhold it and print every offending statement,
  so that change is applied deliberately rather than as a side effect of a deploy.

`CREATE UNIQUE INDEX` is deliberately **not** on that list, and that is the whole point:
adding one can **fail** on existing duplicates, but **failing is not losing**. A statement
that either succeeds or aborts destroys nothing.

An **unreadable diff is not additive** — "I could not tell" must never resolve to "go
ahead" against production (P6).

### 4. The lesson, stated plainly

This platform already recorded it once, in Session 46 §6: *"Three plausible theories are
worth less than one piece of evidence."* It was written after a one-character bug — a
trailing space in a Railway service name — cost a session of guessing.

**It was not applied here.** Two rounds of inference, one shipped fix against a cause
that turned out to be wrong, and roughly two hours, against a log line that was there
the entire time and took ten seconds to open.

> **The rule, restated so it survives:** when a deploy fails, the deploy log is the FIRST
> thing to read, not the last. Not the code. Not the generated SQL. Not the plausible
> story about locks. A theory that fits the symptom is not evidence — and this time the
> theory even produced a *correct* intermediate finding (the SQL really is additive) on
> the way to the wrong conclusion. **Being right about a detail is not being right.**

Nothing from #258 is wasted — a bounded, self-describing migration is correct regardless
of what caused this one. But it was shipped as a *fix* when it was only ever a *hardening*,
and saying so is the difference between a hardening and a false claim of resolution.

### 5. Ops note recorded

Every GitHub deploy for `identity-service` sat at **PENDING / "Needs approval"** through
the incident, and `railway up` from the CLI was used to work around it — which means what
ran may not have been `main`. A deploy that requires approval and a CLI that bypasses it
is a pair that will mislead the next diagnosis too. Approve the GitHub deploy.

---

## SESSION 48 — THE ISSUE QUEUE REACHES ZERO (28 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-core-backend
> **#235**, **#236**; tec-knowledge-base **#127**; Tec-ui **#23**, tec-auth **#15**,
> TEC-SDK **#13**. All merged. `tec-core-backend` now has **0 open issues** (6 at the
> start of Session 47).

Continues Session 47 and confirms its thesis rather than restating it: **four more
defects, none of which the issue that led to them actually described.** Every one was
found by reading the code before implementing the fix that had been asked for.

### 1. A completed payment could be overwritten as `failed` (#72, closed)

Issue #72's remaining rows asked for outbox events on `cancelPayment` / `failPayment`.
Checked first, and **did not do it**: no service consumes payment failure events —
they appear in neither `manifests/events-catalog.yaml` nor the stream-health `EXPECTED`
map, so emitting them would create streams with zero readers, growing forever, invisible
to the Session 25 consumer-liveness sensor. The audit-trail requirement those rows exist
for (Invariant #4) was already met by the existing `PAYMENT_CANCELLED` / `PAYMENT_FAILED`
audit rows.

What was actually wrong is a data-integrity bug. Both handlers did **check-then-act**:

```
T1  failPayment reads status 'approved'
T2  completePayment moves it to 'completed'
T3  isTransitionAllowed('approved','failed') → true    (from the STALE read)
T4  update where { id } → overwrites 'completed' with 'failed'
```

Real Pi moved; the row says it failed. **Invariant #7** and **Forbidden Behavior #9**.

> **A `$transaction` does not close this.** `cancelPayment` already had its read and write
> inside one. Under READ COMMITTED both readers still see `approved` and both pass the
> guard. Only putting the status **in the WHERE** makes the check and the write one
> atomic decision. `count === 0` → 409, the truthful answer, instead of a corrupted row
> and a 200.

Scoped to cancel/fail deliberately: `approve` and `complete` share the shape, but a racing
double-complete converges on the same state — only cancel/fail can *destroy* a completed
payment.

### 2. Two live Pi clients, two circuit breakers, one upstream (#80, closed)

The issue asked which of `payment.service.ts` and `pi-api.ts` was the live path. **Both
were**: the first serves the controllers, the second serves reconciliation. Two copies,
each with its own `circuitFailures`, guarding the same Pi API — so when Pi is down the
user path trips and correctly sheds load while **the reconciliation cron, counter still
at 0, keeps hammering it**.

They had also drifted: the diagnostic logging added during the Analytics approve→502
investigation lived only in `pi-api.ts`, so the *reconciliation* path had better
diagnostics than the *payment* path. And each declared its own `PiApiError` class, while
the controller does `piErr instanceof PiApiError` — working today only because throw and
catch happen to share a file.

Two more found by **writing the test rather than reading the code**:

- **`piGetPayment` never consulted the breaker at all** — its own inline fetch, so with
  the circuit wide open a read still went to the network, and its failures never counted
  toward opening it. Worst where least visible: it is the *first* call reconciliation
  makes on every payment it sweeps.
- **`(global as any).__redisPublisher` is set by nothing.** Only two reads and the comment
  in `redis-publisher.ts` saying it replaced them. Both copies always fell through to
  `createPublisher()`, opening Redis connections `closePublisher()` never closes.

> **Kept deliberately:** the `p.catch(() => {})` guard from the copy being deleted. It
> prevents a non-awaited call from raising an `unhandledRejection`, which Node terminates
> the process on. Every call site awaits today, so it guards nothing — **which is exactly
> why it was easy to drop while consolidating.** A defence that is not needed *yet* is not
> a defence that is not needed. Session 46's deploy-name bug was load-bearing the same way.

### 3. `--provenance` on a private repo — a trap armed for the next release

`tec-auth`'s publish workflow requested `id-token: write` and passed `--provenance`. npm
provenance supports only **public** source repos and rejects private ones with 422.
`Tec-ui` and `TEC-SDK` **carry that exact comment in their own workflows** — they hit it
and learned. tec-auth never back-adopted it, and has not published since 16 July, so the
422 was never reached.

> **Fourth instance of one pattern in two sessions:** the tec-ui semver trap, the
> Dependabot policy, the typed publisher singleton, and now this. *The fix exists, one
> place follows it, nobody back-adopts.* This is now the platform's most reliably
> recurring failure mode, and it is a process defect, not a technical one.

**npm token decision (owner's call, recorded):** `2026-11-25` is the **longest npm will
issue**, so rotation is not a deferral of the problem — it *is* the problem's shape.
Quarterly rotation was chosen over Trusted Publishing; the npm settings page confirms
Trusted Publisher **is** available and clarified the earlier confusion — the *package* is
public while the *source repo* is private, and provenance checks the repo. Revisit after
the campaign. The remaining OIDC argument is only that no publish secret would exist to
leak.

The August lapse cost an hour **not because it was detected late** — CI goes red in a
minute and npm emails on success — but because `E404` on a **scoped** package means *not
authenticated*, not *no such package*. That sentence now prints in the publish failure
annotation. An earlier version of the fix added a weekly `npm whoami` cron; **dropped**,
because it polled for something already visible.

### 4. A documented rule with no enforcement (#127)

Three cursor[bot] PRs from 17 July were checked before closing. **#84's work was on
`main`. #81 and #83's was not** — 23 documents still declared `Verification:
[Unverified]`, a token `.cursorrules` RULE 2 does not define, carried into
`asset-registry.yaml` as `verification_state: unverified`, with all 18 gates green for six
weeks. `check-truth-framework.sh` asked whether the fields were *present*, never what they
*said*. And `build-asset-registry.py` maps `'unverified': 'unverified'` explicitly, so the
parser **blessed** it on the way in.

Fixed, plus **4 the PRs missed**: C-48/50/55/77 carried `Governance State: [Documentation
Verified]` — a *Verification* token in the *Governance* field. Set to `Governance
Approved`, which is what 13 of the 14 neighbours in that range declare (read from the
repo, not from the PR's claim that those headers were fine). `evals/check-header-tokens.sh`
now fails the build on an undefined token.

> Written in Python after the bash attempt reported **16 violations across 6 correct
> documents** — several declare all three fields on one line, and the checker validated
> every token on it against each field's set. Caught by running it. **A gate that cries
> wolf gets ignored, and an ignored gate is worth no more than the missing one it
> replaced.**

### The fleet palette: code verified end-to-end, screen still unverified

Checked **both halves**, because the first alone proves nothing:

| | 21 apps |
|---|---|
| `package.json` declares `^3.0.0` | ✅ |
| **`package-lock.json` resolves `3.0.0`** | ✅ |

The second is the one that matters: a lockfile still pinning 1.x would make `npm ci`
install the old palette regardless of the caret — **the semver trap one level down**, and
silent. It is not the case anywhere.

Still open: whether the deploy ran. Merged ≠ built ≠ on screen, and only Life, Zone and
Epic have been seen on a real device. `scripts/verify-palette.mjs` answers it in one
command from any networked machine.

### Also recorded

- **`@yasser172/tec-shared`** — a fourth published package (v1.1.0, last published 18
  April), **no dependents across 31 repos**, holding a live automation token reissued
  27 August. A publish credential for the `@yasser172` scope, for a package nothing
  consumes and nobody watches. Recommended for revocation; credentials are the owner's.
- The Hub carries **no** `@yasser172/tec-ui` dependency — it paints from its own tokens.
  Expected, and worth stating so a future audit does not read it as a gap.

### Rules adopted

1. **Read the issue, then read the code, then decide.** #72 and #80 both asked for
   something that would have been wrong to do, and the right fix was adjacent to it.
2. **Do not emit an event no one consumes.** It creates a stream that only grows, and the
   liveness sensor cannot see it.
3. **A guard that currently guards nothing is the easiest thing to delete during a
   refactor, and the most expensive.**
4. **Check the lockfile, not just the manifest.** A caret in `package.json` is an
   intention; the lockfile is what gets installed.

---

## SESSION 47 — WHAT SUCCEEDS SILENTLY (28 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for every number
> below — they come from queries run against the production `payment-db`, not from reading
> code. The fixes are **[Code Verified]**: tec-core-backend **#232** and **#233** merged;
> **#234** open (diagnostic + audible fallback + recovery audit trail).

Four separate defects were found this session. They are not related by subsystem — one is a
missing event, one is an identity fallback, one is a test, one is an audit gap. They are
related by **shape**:

```
Every one of them was a system reporting success while doing nothing.
```

That is the finding worth keeping. It is the same shape as Session 46's deploy job, which
exited 0 for months without ever deploying a service.

### 1. A payment could complete and no one would be told

`resolveIncompletePayment` — the handler every app calls at
`/api/bff/payment/resolve-incomplete` when a Pi Browser payment gets stuck — marked payments
`completed` with a bare `prisma.payment.update()` and emitted **nothing**.

`piCompletePayment` *can* emit, but only `if (eventData)`, and the recovery call site passed
three arguments. The condition failed silently. The second branch never called it at all.

`payment.completed.v1` has three live consumers, and one of them is
**`commerce-subscription` — the thing that actually grants PRO/ENTERPRISE**. So a payment
recovered this way left the row saying `completed`, the Pi genuinely moved, and the buyer
got nothing. Session 26's "paid and got nothing", alive on the one path that only ever runs
**after** a payment has already gone wrong.

> **Why 100% payment success could not surface it.** The normal path is covered twice —
> outbox row *and* a post-commit publish. The broken path only executes when a payment
> failed first. A fleet reporting every payment successful is exactly the condition under
> which this stays invisible. **Success everywhere was the reason it was hidden, not
> evidence it was harmless.**

Fixed in **#233**: both branches go through one helper that writes the status change and the
outbox row in the *same transaction* (ADR-004). Chosen deliberately over a direct publish —
the outbox insert is a write to the same database, not an external call, so it adds no new
way for a completion to fail.

### 2. The test was green with the bug in place

A `resolveIncompletePayment` CASE B test already existed. It asserted that `res.json` had
been called. It passed before the fix and after it.

**Every new test in #233 was run against the pre-fix controller first** — 3 failed, then
passed on the fix. That step is now the standard for this repo:

```
A test that passes on the broken code is not a test. It is a comment that runs.
```

### 3. 31% of completed payments belong to a principal that does not exist

Reading the affected rows showed `user_id = 'gateway'` — not a UUID. One line:

```typescript
const userId = (req.headers['x-user-id'] as string) || 'gateway';
```

Fail-OPEN. When the payer's identity is unknown it **invents one** rather than refusing, and
it had never said so. **248 of 798 completed payments** carry it. A subscription paid that
way activates PRO for "gateway" — the human gets nothing — and the audit trail names an
actor that is not a person (Invariant **#3** identity resolves to ONE principal, Invariant
**#4** audit trail).

Gateway **#210** (15 Aug) had already fixed the source, and production confirms it:

| window | `gateway` payments |
|--------|--------------------|
| before 15 Aug | **240** |
| on 15 Aug (deploy day, last at 17:11:47) | **8** |
| the 13 days since | **0** |

**#234** does not remove the fallback — genuine cron/webhook/reconciliation calls have no
user by design, and deleting it would 401 legitimate traffic. It makes it **audible**: every
occurrence now names the route that produced it, and whether an `Authorization` header was
present (which separates "token forwarded but failed verification" from "no token sent").

### 4. The recovery path kept no audit trail at all — which is why (1) was hard to diagnose

`resolveIncompletePayment` wrote **no audit log on any branch**. Forbidden Behavior **#10**
is *"ad-hoc system recovery without audit trail"* — a description of this handler.

The cost was immediate and concrete: the one affected payment had two audit rows
(`PAYMENT_INITIATED`, `PAYMENT_APPROVED`) and none for its completion, so the diagnosis had
to lean on the outbox table instead, and **the payer could not be identified from our own
records**. The second defect erased the evidence for the first.

Fixed in **#234**: all four outcomes audit, using the *same* event types as the normal paths
(`PAYMENT_CONFIRMED` / `PAYMENT_CANCELLED`, not `PAYMENT_RECONCILED`) so "was this payment
ever confirmed?" has one answer whichever path got it there. Route goes in metadata.

### What production actually said — and why the first number was wrong

```
month     completed   missing payment.completed.v1
2026-03      47              47   100%  ─┐
2026-04     119             119   100%   │  before the outbox was wired AT ALL
2026-05     209             209   100%   │  (saveOutboxEvent was dead code — issue #72)
2026-06     191             150          ─┘
2026-07     156               3   ← the only real suspects
2026-08      76               1   ←
```

529 rows lacked an event. **They were not 529 victims.** Before the outbox existed the normal
path emitted straight to Redis, so a missing outbox row proves nothing about delivery. Only
the date split separates the two eras.

> This is why the diagnostic script leads with **date ranges and signal overlap**, not a
> headline count. A single number here would have been alarming and wrong. Of the 4 genuine
> suspects, three are ordinary purchases and **one** was a real subscription
> (`merchant_pro_monthly`, 10π, 6 Aug).

**Blast radius: zero real users.** All 798 payments across only 8 distinct principals — the
platform has no external paying customers yet. Every affected payment is team testing. Both
bugs were real, both are fixed, and both were caught before a stranger's money was involved.
That is the best available outcome, not a reason the work was unnecessary — it is the
cheapest these guards will ever be.

### Also this session — the audit issues, verified rather than repeated

Six open audit issues were checked **against current code** instead of trusted from their
text. Four were already fixed and are closed with evidence (**#71** terminal-state guard,
**#73** all four Dockerfiles on `migrate deploy`, **#81** realtime-service 14/14 green,
plus its `.dockerignore`/`package-lock` companions). Two were real and are fixed in **#232**:

- **#78** — `config/env.ts` validated `ALLOWED_ORIGINS` while `main.ts` read `CORS_ORIGIN`.
  The larger finding: **the module was imported by nothing**, so its Zod `parse` had never
  once executed — the gateway ran with no env validation at all. Wired up with `safeParse`,
  not `parse`: making it throw would turn a dormant check into an outage on the platform's
  single entry point the first time a var is missing on Railway. Fatal should be a decision,
  not a side effect of adding an import.
- **#79** — Swagger declared `userId` **required** in `CreatePaymentRequest`, publishing the
  exact field C-47-B exists to reject as the documented contract (Forbidden Behavior #5).
  The Wallet block was worse: it documented routes that do not exist.

**#72 stays open, correctly.** An earlier pass in this session called it fixed by counting
`saveOutboxEvent` call sites; that was wrong — coverage of the six transitions is the
question, and the four that matter most were missing. `cancelPayment` / `failPayment` remain,
and **no service consumes payment failure events**, so that half is an audit-trail gap rather
than a revenue one. Recorded on the issue with a per-handler table.

### Rules adopted

1. **Run every new test against the broken code first.** If it does not fail, it does not test.
2. **A diagnostic reports its signals separately.** Collapsing them into one verdict is how a
   pre-outbox artifact becomes "529 victims".
3. **Never remove a fail-open fallback blind — make it audible first.** Then remove it once
   the logs say who depends on it.
4. **A test is only as good as the seam it watches.** The first version of the audit tests
   asserted on `prisma.paymentAuditLog.create` while the suite mocks `../utils/audit`; they
   failed for a reason unrelated to the code.

---

## SESSION 46 — ONE PLATFORM ON SCREEN (28 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-ui **v3.0.0**
> published; Hub #185 · #186, the 20 app palette PRs, NBF/Brookfield, the 19 app
> Dependabot-policy PRs and backend **#213** are all **merged**. The Hub UI work was
> **[Runtime Verified]** by the CEO in the Pi Browser, screenshot by screenshot; the
> backend merges are **[Runtime Verified]** by a green CI (30/30) on `main`.
> Token authority: **C-83** (updated this session).

The platform was one product in the architecture and three products on a phone. This
session was almost entirely about the gap between those two facts.

### 1. The fleet was painting THREE different golds

| Group | `@yasser172/tec-ui` | Gold on screen |
|-------|---------------------|----------------|
| 18 apps | `^1.1.0` | `#d4af37` (legacy) |
| 3 apps | pinned `2.1.0` | `#FBBF24` (amber-400) |
| Life | `^2.3.0` | `#FBBF24` |
| Hub | — (own tokens) | `#FBB44A` (Pi amber) |

**Root cause: a semver caret trap.** `^1.1.0` can never resolve to a 2.x, so 18 apps had
been silently frozen out of the EVL palette since v2.0.0 shipped — `npm update` was doing
exactly what it was told, forever. Nothing was broken, nothing warned, and the fleet drifted
apart for months.

**tec-ui v3.0.0** moves WEALTH to `#FBB44A`, sampled from the Pi app's own splash mark, so
a TEC app beside Pi Browser chrome reads as the same product. Values only — no export
renamed or removed (C-83).

> #### The finding that changed the fix
> **Bumping the package alone makes an app WORSE, and we proved it before shipping.**
> Rendering Zone on `^3.0.0` with its local tokens untouched produced a page carrying
> **`#050816` and `#020205` at once**. An app paints from *two* sources: `TEC_COLORS.*` in
> inline styles and `var(--tec-*)` in its own `tec-design-tokens.css`. The package bump and
> the app's local sweep are **one change**. Every app PR carries both.

**Deliberately NOT swept:** `tec-assets` (104 hardcoded hexes), `tec-commerce` (149),
`tec-ecommerce` (202). These barely consume `TEC_COLORS` — moving them is a re-skin, not an
upgrade, and it is a separate decision, not a silent one.

### 2. Fifteen apps introduced themselves as "TEC App"

The SSO landing (`src/app/api/auth/sso-callback/route.ts`) still carried the
`tec-template-base` placeholder **`🔷 TEC App`**. A user tapping *TEC Zone* in the Hub grid
was greeted by a sign-in screen for a product called "TEC App" — on the single screen where
trust is established. Now each app names itself, in **caps** (`TEC ZONE`), matching how the
brand appears in the Hub grid, the Portal listing, and the icon wordmark.

> That page is **plain HTML served before any stylesheet**, so it cannot read a CSS
> variable. Its colours are hex literals **by necessity**, not by oversight — the same
> reason `next/og` (Satori) resolves no custom properties. Do not "fix" them into `var()`.

### 3. Hub navigation — the golden band, and a hidden button

CEO-reported, in this order: the gold topbar band was too loud on the Hub home; the
username chip looked like a hidden button because nothing said it opened anything;
`Settings` was the wrong word for what the page does; the wallet card ate the fold.

- gold band → **inner pages only**; Hub home carries `var(--tec-bg)`
- username chip → a real **account menu** (`HubAccountMenu`), opened by a **3-bar** glyph,
  not a chevron — the CEO rejected the chevron explicitly
- `Settings` → **Profile**, with its own icon
- bottom nav → **5 tabs**; Profile + Dashboard moved behind the avatar
- wallet card compacted, with a **24h market** delta modelled on Binance/OKX — labelled
  *market*, **never** "PNL" or profit: the platform does not compute the user's P&L, and a
  fiat delta on a held balance is not one.

Also this session: a traced-monogram `TecMark` component, and the 1024/512/192 + maskable
app icons in `public/brand/`.

### 4. One Dependabot policy, and 112 PRs that could never merge

19 repos still ran the original config — no `ignore`, and a group covering only
`devDependencies`. On a platform pinning **Next 15 / React 18 / @sentry/nextjs v8**, that
manufactures unmergeable work: the standing `dev-dependencies` PR bumped `typescript` to
`^7.0.2` and `eslint-config-next` to `16.3.1`.

> **Next 15 does not recognise TypeScript 7 as a TypeScript install at all** — it reports
> "It looks like you're trying to use TypeScript but do not have the required package(s)
> installed", so Typecheck and the build fail before reading a line of source. **No tsconfig
> change reaches it.** `eslint-config-next`'s major tracks the Next major, so 16 on Next 15
> is a mismatch by construction.

Dependabot rebuilt that PR after **every** merge, so a permanent red check followed each
repo around — which is how a CI signal teaches people to ignore it.

`tec-template-base` had already solved this and every app cloned from it since (NBF,
Brookfield) shipped the fix; the fleet simply never back-adopted it. Copied verbatim to all
19 + the Hub: **ignore ALL majors**, one grouped **minor+patch** PR, `github-actions`
grouped the same way. **112 stale Dependabot PRs closed** across the 18 domain apps —
nothing is lost, the legitimate minors return as one grouped PR.

**Left open on purpose:** `tec-core-backend` (16 real per-service patch bumps, different
repo, no policy change applied), `tec-assets` #46 / `tec-commerce` #54 (repos excluded
above), and NBF/Brookfield/template-base — whose open PRs are exactly what the new policy
*wants*.

### 5. The process defect behind all of it

Three times this session the CEO asked *"why is there no open PR?"* Work was pushed to the
branch and left there, because the standing instruction is "do not open a PR unless asked".
In a workflow where the CEO's job **is** to merge, a pushed branch with no PR is invisible
work. **Rule adopted: pushing to the development branch and opening its PR are one step.**

### 6. The backend got the policy too — and it needed a different one (#213)

`tec-core-backend` was the one repo the app policy could **not** simply be copied into, and
reading it first is why. The `ignore`-majors half was **already correct** in all 13 service
blocks — which is exactly why this repo never produced the TypeScript 7 PRs the app fleet
was drowning in. Three real gaps sat underneath that:

| Gap | Detail |
|-----|--------|
| **No grouping** | One PR per package per service → 16 open PRs in a routine month: the same swarm the apps had just escaped, arriving one patch at a time. |
| **The root app was invisible** | `/package.json` is a real Nest app (NestJS 10 · Prisma 5 · helmet · ioredis · bcrypt) and **no block named `/`**. It had never received an update of any kind, security included. |
| **No `github-actions` block at all** | Every action across 7 workflows unwatched: `actions/setup-node` on **v4** while the fleet had moved to v6; `checkout@v4` receiving no security updates. |

Two differences from the app policy, chosen rather than inherited:
- **Grouping stops AT the service boundary.** Each service owns its `package.json` and
  deploys independently on Railway, so a PR spanning two services would let one red check
  block eleven unrelated deploys. **Thirteen grouped PRs is the correct shape here, not one.**
- **Majors stay ignored for npm but NOT for actions.** Nothing here pins an action major,
  and every workflow already pins `node-version: '20'` on `ubuntu-latest`, so a
  runner-action major cannot change the Node the build runs on.

Monthly is kept (the fleet is weekly): this repo is the head of the release chain, so churn
here is the most expensive churn on the platform.

**Outcome, verified:** #213 merged, then 14 of the 16 standing dependency PRs merged —
**CI 30/30 green on `main`**, no deploy broken. The policy proved itself immediately:
Dependabot's next runs opened **#214** and **#215** as *grouped* PRs (one per service, 3
updates in one), not one per package.

**Two did not merge, for a reason worth keeping:** #175 (`class-validator`, auth-service)
and #184 (`@aws-sdk/client-s3`, storage-service) hit lockfile conflicts because an earlier
merge touched the *same service*. That is the grouping argument demonstrated live —
per-package PRs against a shared lockfile conflict with each other by construction.
**#175 also deserves a look rather than a merge:** `0.14 → 0.15` on a `0.x` package is
breaking under semver, and it sits on the auth path.

### Honest status
- `[Runtime Verified]`: the Hub nav/wallet/icon work, on a phone, by the CEO; the backend
  merges, by a green CI on `main`.
- `[Code Verified]` only: the palette on the 20 apps + NBF/Brookfield — each passes
  typecheck/lint/tests/build, but only Life, Zone and Epic were seen on a real device.
- **The palette PRs must deploy together.** A staggered Vercel deploy puts two palettes on
  screen across the fleet at once — the exact failure this session existed to end.

### 7. Three defects the Dependabot work uncovered in the backend deploy path

Merging the grouped PRs meant watching real CI runs on `main` for the first time in
a while. That is the only reason any of this became visible — none of it was caused by
a dependency bump, and none of it would have surfaced from reading the code.

#### (a) The deploy step had never deployed a single service

It derived the Railway name by stripping **both** the repo's `tec-` prefix and the
`-service` suffix:

```
tec-auth-service  →  auth-service  →  auth
```

Railway keeps the suffix (`auth-service`, `kyc-service`, `storage-service`, …), so every
lookup missed. `api-gateway` has no suffix and was the only name that came out right —
which is why nobody noticed. **And the miss was swallowed:** `not found` logged a
`::warning::` and `exit 0`, so the job reported SUCCESS while doing nothing. Eleven
services had been shipping a green Deploy check that did no work; they are live only
because Railway deploys from the repo itself.

#### (b) A push to ANY development branch deployed to PRODUCTION

`on.push.branches` includes `'claude/**'`, and the deploy job was guarded on
`github.event_name == 'push'` with **no branch check** — no pull request, no review.

> **The bug in (a) was acting as the access control.** Every branch deploy asked for the
> wrong name, got "not found", and exited 0. Fixing the name removed that accidental
> safety net — and the deploy job in the fix's own PR ran for **45 seconds against
> production** instead of skipping. That is how it was caught.
>
> Nothing harmful shipped (the branch's `src/` was identical to `main`), but this is the
> sharpest lesson of the session: **a defect can be load-bearing.** Repairing one without
> looking at what it was silently preventing is how a fix becomes an incident.

Guard is now explicit: `github.ref == 'refs/heads/main'`. `docker-build` deliberately
still runs on branches — building an image is how a PR proves it builds, and it pushes
nothing.

#### (c) The auth-service image could not build without the network

`bcrypt` is a native module. On musl it downloads a prebuilt binary from GitHub release
assets and falls back to compiling from source — but the alpine image has no Python or
toolchain, so the fallback cannot run. A single `ECONNRESET` on that download killed the
build. The platform's **identity authority** had a build that any network blip could
break. The toolchain is now a virtual package removed in the same layer.

#### The resolution — and it was one invisible character

Fixing the name turned the silent `exit 0` into a real red run: `identity-service`
**not found**, while four sibling services deployed. Rather than guess between the
plausible causes (token scope · wrong project · stale config), the failure branch was made
to print what the token can actually see. Three services carried a **trailing space** in
their Railway name — `identity-service `, `commerce-service `, `notification-service ` —
and the correlation was exact: the four without it deployed, the one with it failed.

Renamed in the Railway dashboard (an owner action, no code change) → **`Deploy
(tec-identity-service)` went green.** That is the first time this pipeline has ever
deployed a `-service`; every previous green was the swallowed `exit 0`.

> **When a fix produces a red run, the red run is the deliverable.** The instinct is to
> explain it away. Printing what the tool actually sees cost four lines and settled it in
> one run — three plausible theories are worth less than one piece of evidence.

Also hardened: `--service $VAR` was unquoted, so a name containing whitespace could never
be addressed at all — the shell silently dropped it. Quoted now, so the rename cannot be
undone later by a shell detail.

**Shipped:** tec-core-backend **#226** (name + Dockerfile), **#227** (the branch guard),
**#229** (self-diagnosing failure), **#231** (quoting).
#226 squash-merged only its first commit, so the guard had to follow separately — worth
remembering, because for a while `main` had the name fix *without* the guard, which is the
most dangerous of the three combinations.

**Also verified, not assumed:** `class-validator 0.14 → 0.15` (a breaking bump under semver
on a `0.x`, sitting on the auth path) was installed locally and exercised before merging —
typecheck clean, 47/47 tests, and a purpose-written probe confirming the auth DTOs still
**reject** empty / non-string / oversized / malformed input. A validation library that
fails *open* is a P6 violation, and that is not something a passing test suite proves on
its own.

### Open after Session 46 (nothing here is blocked — all are decisions)

| # | Item | Why it is still open |
|---|------|----------------------|
| 1 | **Assets · Commerce · Ecommerce re-skin** | 104 / 149 / 202 hardcoded hexes. These barely consume `TEC_COLORS`, so this is a re-skin, not a version bump — real design work, and a decision, not a sweep. Until then **3 of 26 repos stay on the old palette**, and that is a known, deliberate gap, not drift. |
| 2 | **npm Trusted Publishing** | Tokens now expire **25 Nov 2026**. The Aug 26 expiry caused a publish `E404` — on a scoped package, `E404` on `PUT` means *auth failure*, not "not found", which is why it read as a missing package. Trusted Publishing removes this whole class of failure; worth doing before the next expiry rather than after it. |
| 3 | Backend grouped PRs | ✅ **CLOSED.** 7 of 12 merged directly; the 5 stale ones could not be rebased from here, so their updates were applied against current `main` instead (**#228** — 339 tests green across identity · realtime · kyc · storage · api-gateway) and Dependabot auto-closed all five. One bump deliberately NOT taken: #217 would have **downgraded** identity's `@typescript-eslint/parser` `^8.65.0 → ^8.59.1` (its branch predates #183) — every dep resolved as `max(main, PR)`, never copied. |
| 4 | **Fleet deploy of the palette** | Merged ≠ deployed. Until every app is redeployed on Vercel, the fleet is mid-flight between two palettes. |
| 5 | **Runtime-verify the palette beyond 3 apps** | Only Life, Zone and Epic were seen on a real device. The other 20 are `[Code Verified]` and nothing more. |

---

## SESSION 45 — TEC AI: the assistant stops being a second front door (21 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (tec-app #165 ·
> #166 · #167 · #168 merged; **#169 open**). The CEO runtime-verified #165–#168 in the Pi
> Browser on both surfaces. Constitutional detail: **C-104 §5.4–5.6**.

Session 44 made the assistant *answer*. This one made it a product: it renders what the
model actually emits, keeps its conversations, and has a menu that belongs to it.

| PR | What it closed |
|----|----------------|
| **#165** | Session state runtime-verified + hardened: "new chat" **archives** instead of deleting; stop keeps the partial; retry resends verbatim |
| **#166** | Markdown **tables** + mobile bubble width. A table now scrolls inside its bubble; before, `minWidth: 100%` + `word-break: break-all` shredded cells into `hub.tec / osyste / m.app` — a fix of mine that caused the thing it was meant to fix |
| **#167** | The intermittent **white strip** at the bottom of the page: `body` was painted, `html` was not, so overscroll exposed the UA's white canvas. `html { background: var(--black); color-scheme: dark }` |
| **#168** | The **shared assistant menu** — archived chats · starter questions · reply settings · support — replacing the `/ai` panel of Hub links |
| **#169** | The menu's own rough edges: a fourth tab clipped off-screen, an open menu fighting the chat on a phone, and `/ai` carrying a private Support panel the drawer did not have |

### The constitutional part (C-104 §5.6)

The `/ai` page had a "SERVICES" panel: **TEC Hub · Pay with Pi · My Dashboard · Digital
Assets** — direct routes into the platform, offered from a page the user had **not signed
in from**. The assistant had quietly become an alternative entrance beside *sign in with
Pi*, which C-47 names as the single entry point. It was **replaced, not relocated**.

The assistant still points at an app — through a **nav chip inside a reply**, where the
destination answers a question the user asked. A recommendation is earned by context; a
private menu of app links is a bypass.

The guard test asserts the **rule**, not the symptom: it walks every tab and checks the
scheme/host of every `href` — only `wa.me` / `t.me` / `mailto:` / `tel:` pass, and a
**relative** href fails. The first version asserted "no `<a>` at all" and had to be
rewritten the moment support gained legitimate outbound links.

### The drift, a fourth time

The drawer had no welcome (#164), then no menu (#168), then no support (#169) — each
found by the CEO on a phone, not by us. The structural answer is now written as law in
C-104 §5.6: **one component, both surfaces**; a capability on one AI surface and not the
other is a defect, not a roadmap item.

### Honest status
- `[Runtime Verified]`: streaming · markdown incl. tables · `dir="auto"` on real Arabic
  replies · archives · settings · the theme fix — all confirmed on both surfaces.
- `[Code Verified]` only: **#169** (open at time of writing) and `/api/ai/health`, which
  has still never been run against production keys.
- **Unchanged and still owed:** `ANTHROPIC_API_KEY` is unset, and the Claude branch still
  hardcodes a single 2024 model id with **no** candidate-list fallback — the exact defect
  §5.2 was written about. It must be fixed BEFORE that key is ever added.

---

## SESSION 44 — TEC AI: the outage was self-inflicted, and the assistant got its UX (21 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (tec-app #162 · #163
> merged; #164 open). Runtime-verified in the Pi Browser by the CEO for the streaming,
> markdown, and provider fixes — the session-state work is merged-but-not-yet-runtime-checked.
> Constitutional detail lives in **C-104 §5.1–5.5**; this is the session record.

### What the user reported, and what it actually was

The assistant was "working, then cutting out, slow, and printing `**` everywhere". Four
separate causes hid behind that one description — and **one of them was ours**.

| Symptom | Real cause |
|---------|-----------|
| Answers stop mid-sentence | The client parsed each network chunk on its own with NO carry-over buffer, so a `data:` frame split across two chunks failed `JSON.parse` and was swallowed by a bare `catch`. Routine on mobile. Also `max_tokens: 1024`, which a normal answer exceeds. |
| "It shows nothing then the whole answer appears" | The stream was already incremental; the drawer accumulated it into a local string and called `setMessages` ONCE at the end. The UI was hiding the typing. |
| `**bold**` printed as asterisks | The bubble rendered the reply as a plain string. |
| **"all providers failed"** | **A regression we introduced — see below.** |

### 🔴 The regression: the candidate list dropped the model that worked

A PR titled *"use current provider models — Groq + Gemini retired the old ones"* had
researched and pinned `gemini-3.6-flash` + `llama-3.1-8b-instant`. A later PR generalised
those pins into candidate **lists** so a retired id could not take the assistant down —
but filled the lists from recollection, and `gemini-3.6-flash` **was not in them at all**,
replaced by four **older** ids. On a free tier the older models are the crowded ones, so
users got *"This model is currently experiencing high demand"*.

**The change whose entire purpose was surviving model rotation is what removed the working
model.** The user caught it: *"the models that were there before you changed them were
free, working 100%, and fast."* They were right; the git history confirmed it.

Two corrections were owed and made: the earlier claim that "the free tier is the cause"
was **wrong** — the free tier was fine, we were pointing at the wrong models.

**Law now in CI** (`models-pinned.test.ts`, C-104 §5.2): a model id production has served
on may not be removed or demoted. *Recognition is not evidence; production traffic is.*

### The blind spot that made it hard to diagnose

Production logged `groq 400:` **with no reason**. A `Response` body is single-use: the
reason was read to classify the failure and read AGAIN to build the log line, and the
second read returned an empty string. The one thing needed to diagnose the outage was the
one thing the code destroyed. Now read once, carried, and the failing **model is named**.

Also fixed: overload (`429`/`503`) was treated as fatal, so Gemini gave up after ONE model
with three healthy candidates unused. And `NOT_CONFIGURED` vs `BUSY` were both HTTP 503,
so a **busy** assistant told the user it was **switched off** — the route now sends an
explicit `code`; the server classifies, the client words it.

### New: `GET /api/ai/health`

Auth-gated probe of every configured provider/model, reporting which answer and why the
others do not, plus the env var to pin a winner. Built because this outage class hit
**three times** and each time the only way to find a working model was to ship a guess and
wait for a user to hit the failure.

### Two surfaces, one implementation (the recurring lesson)

TEC AI is reachable from `/ai` (Hub landing) **and** the `/hub` drawer — two independent
components on the same route. The SSE truncation bug lived in **both** for months; the
`[[go:nx]]` marker leaked on the drawer alone because only the page called the parser.
Shared modules are now listed in C-104 §5.1 and a third surface must import them.

> **The Dashboard has no TEC AI entry point at all** — noted, deliberately out of scope.

### Assistant UX (tec-app #164, open)

Conversation **persistence** (`sessionStorage`, not `localStorage` — C-104 §5.4 records
why), **stop** (keeps the partial answer — stopping is a decision, not a failure),
**retry** (an error bubble was a dead end), **new chat**, copy-reply, an auto-growing
textarea (the drawer's field was single-line — a long question could not be written),
`dir="auto"` everywhere (mixed Arabic+Latin rendered reversed), a real greeting in the
drawer, and `role="log"` + `aria-live` on both transcripts.

**One more silent bug found while reviewing:** the `/ai` welcome was seeded in an effect
keyed on `[user, locale]` that replaced the whole message array — changing language, or
the session resolving late on the C-123 Pi Browser path, **wiped the conversation**.

### Honest status
- `[Runtime Verified]`: streaming · markdown · nav chips · the restored Gemini model.
- `[Code Verified]` only: session state, stop/retry, a11y (#164 merged but not yet
  exercised in prod), and `/api/ai/health` (never yet run against production keys).
- **`ANTHROPIC_API_KEY` is unset** — the chain is **two** providers deep, not three, and
  both were down at the same moment. The Claude branch also still hardcodes a single
  2024 model id with **no** candidate-list fallback: the same defect this session fixed
  for Groq and Gemini, left in place because that key is not set. It must be fixed
  BEFORE that key is ever added.

---

## SESSION 43 — Fleet-wide UX pass: unified app-shell + Arabic/RTL + real Pi username + Pro parity (16 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (all PRs merged to `main`).
> A consistency pass across the whole app fleet so every TEC app looks + behaves like one product,
> and — the campaign-critical part — is **fully bilingual (EN + AR) with RTL** for the Pi community.

### What shipped (per app, merged to main)
- **Unified mobile app-shell** — a local `BottomNav` (4 tabs) with **local vector icons** (lucide-style
  SVG, NOT emoji), glass backdrop (`rgba(5,8,22,0.92)` + blur), active scale + gold underline, light
  haptic. Local `Icon.tsx` per app so we do **NOT** bump `@yasser172/tec-ui` to 2.x (a coordinated EVL
  palette break). The long single page is split into tabs (Home/primary · content · Pro · Settings).
- **Rich `SettingsView`** — sectioned Profile / Appearance / About, an **EN/AR language toggle**, and
  logout. Invite card included only where the app has the referral loop (omitted for NBF · Brookfield ·
  Explorer, which have none).
- **Real Pi username (`useMe`)** — new `src/lib-client/hooks/useMe.ts` resolves the login name via the
  server `GET /api/auth/me`. Pi Browser hides the `tec_user` cookie from client JS (**C-123 §3**), so
  reading it client-side returned null → Settings showed "TEC Member" / "Not signed in" for signed-in
  users. Now resolved server-side; fails closed to null (P6).
- **Arabic (EN/AR) + RTL** — `applyDir()` added to each app's `src/lib/i18n/index.tsx` (sets
  `document.documentElement.dir = rtl` / `lang`), driven by the toggle + persisted (`tec_locale`). Each
  app gained a fully-translated `<app>` i18n section in `en.ts` / `ar.ts`. On several apps `LocaleProvider`
  was defined but **never wired into the layout** — now wrapped.
- **Pro entitlement parity with Life** — every app's `<App>Pro.tsx` active card shows **★ You're on Pro**
  + the `daysRemaining` renewal reminder ("Expires in N days", amber nudge in the last 7 days; Pi U2A is
  one-time, no auto-renewal), matching the Life reference (Session 27). NBF + Brookfield had **missed** the
  Session-27 fleet propagation (not deployed then) — added here, so the fleet is now 100% consistent.
- **Removed internal (C-NN) doc citations from user-facing copy** — knowledge-base references (e.g.
  "Boundary (C-124)", "Simulated (C-131)") are internal, not for end users; stripped from visible text
  across the apps touched this session (code comments keep their C-NN refs — those are not user-facing).

### Fleet coverage
- **This continuation (final 8):** Legend · Elite · Alert · System · Ecommerce · Nexus · **NBF** · **Brookfield**.
- **Earlier in the session (13):** Life · Connection · Analytics · Zone · VIP · Explorer · Estate · Titan ·
  DX · NX · FundX · Insure · Epic. → the whole fleet now carries the unified shell + Arabic.
- **Ecommerce is the exception by design:** it is the mature marketplace with its **own** top nav
  (ShopHeader: Shop/Orders/Sell/Cart) + hamburger drawer + cart — a bottom nav would duplicate it. So it
  got `useMe` (real username) + an **EN/AR toggle inside its existing drawer** + RTL, and **zero** payment-flow
  change (ADR-007 `isHubNavigation()` guard, `handleBuy`, cart, BFF routes all untouched — R2 preserved).

### Notes / honest status
- **NBF + Brookfield branch repair:** both feature branches had drifted onto an **unrelated history**
  (no common ancestor with `main`) — that surfaced as GitHub "conflicts". Fixed by **rebuilding the branch
  on top of current `main`** with the exact same tree (verified byte-identical), giving each PR a clean,
  conflict-free diff. Then merged.
- **[Code Verified], not yet [Runtime Verified]** — the changes are merged to `main`; each app still needs
  its Vercel redeploy + an eyes-on check inside Pi Browser (real username, Arabic RTL, Pro card) to promote
  to Runtime Verified. No prod telemetry fabricated.
- **No backend / payment / KB-structure change** — pure frontend UX + i18n. Registry, C-doc headers, and all
  KB CI gates are unaffected (no C-doc header lines touched). Campaign proof sheet (`marketing/whats-live.md`)
  reconciled to note the fleet is now bilingual (see marketing update this session).

---

## SESSION 42 — Value-chain apps audit (Titan · Legend · Elite · VIP): Legend Pro fixed (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PR open). Audited the four
> reputation/experience apps for the Pro-detection bug + a genuine Pro service. Result: one real bug (Legend),
> three clean-but-badge-only.

### Findings (verified in code)
- **Legend** — 🔴 **had the bug.** Legend Pro = **SHOWCASE** (the embeddable reputation-badge gate); the
  showcase sync read `.data.plan` not `.data.subscription.plan` → always FREE → the badge stayed locked for
  real Pro users. **Fixed** (tec-legend #20, 30/30) + a profile-BFF test locking it against the real nested
  shape. **Legend was the LAST app carrying the subscription-unwrap bug — the fleet is now 100% clean (7 apps
  fixed: Life · Connection · Epic · NX · Explorer · Zone · Legend).**
- **Titan · Elite · VIP** — ✅ **no bug** (no server-side `resolveProStatus` — their Pro is a subscription/
  badge with nothing gated). And **no genuine additive own-data Pro to build now**, by design:
  - **Elite** — recognition is **criteria-based, computed by Analytics** (C-127); Elite's own data (the user's
    recognitions) is populated by the value chain and empty for most — an "insight" would duplicate Analytics.
  - **VIP** — VIP **grants eligibility; the owning apps enforce value** (C-128 P5). VIP holds no own metric to
    aggregate — its tiers/benefits are the read layer over Hub PRO/ENTERPRISE.
  - **Titan** — a V0 enterprise **console**; real multi-tenant org data is Phase 1+ (needs a mature platform).
  Forcing an insight on any of the three would be sample-data theatre — deliberately not done.

### Campaign close-out (honest final state)
**Real Pro service live:** Life · Connection · Epic · NX · Analytics · Legend · Explorer · Zone · Estate · Alert.
**Held on principle (documented):** FundX · Insure (P0 financial hard-gate) · Nexus (engine V1+) · DX (API keys) ·
Titan/Elite/VIP (data computed elsewhere / V0). Every app with genuine own-data now has a working Pro; nothing faked.

### PR ledger
tec-legend **#20** (showcase Pro fix). No backend/DB change.

---

## SESSION 41 — Explorer + Zone Pro-gate fixes (already built) + Estate Portfolio Insights (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Extending the campaign to
> the apps the user named. Key finding: **Explorer and Zone were already fully built** — their Pro was
> just blocked by the same subscription-unwrap bug (Session 40). Fixed. Estate got a real new insight.

### Explorer + Zone — were already complete; carried the fleet Pro bug
Both apps shipped the genuine pattern in earlier sessions and were **silently broken** by the same
`resolveProStatus` bug (read `.data.plan`, not `.data.subscription.plan` → always FREE):
- **Explorer (C-108)** — "List your business" (self-listing) + ⭐ **Featured** (Explorer Pro) + public
  discovery. The featured sync never fired for real Pro users. **Fixed** (tec-explorer #21, 41/41).
- **Zone (C-120)** — verification requests + review queue + public verified registry + append-only
  evidence. **Zone Pro = queue PRIORITY** (§7 — speeds the queue, never the verdict) — never applied.
  **Fixed** (tec-zone #26, 35/35). Each got a test locking the Pro path against the REAL nested shape.

### Estate — new genuine Pro service (Portfolio Insights)
Estate was functionally built (register a property → stored as an **asset** in asset-service; own
portfolio view) but its Pro was **badge-only**. Added **Portfolio Insights** (Estate Pro): an aggregate
of the caller's OWN properties — total · by type · by ownership · occupancy (leased/listed) · Zone-verified.
**CRITICAL (C-114 §5): counts + lifecycle status ONLY — NEVER a summed valuation** (valuation is
indicative, Analytics-owned). Own-data, gated behind live Pro (P5). tec-estate #19 (33/33).

### Alert — new genuine own-data feature (Watchlist) ✅
Alert was a **read-only inbox** (seeded feed + community). Added a **Watchlist**: the user's OWN
self-created reminders ("watch this") — self-declared own-data (P6), distinct from the delivered
`AlertNotification`. **Additive** (removes nothing free). **Alert Pro = unlimited; FREE capped at 3**
(enforced at the BFF from the live subscription, P5). Backend `AlertWatch` (owner-scoped list/create/
done/delete) + BFF (free-cap gate) + Watchlist UI. tec-alert #17 (frontend) + backend on the branch.
Ops: `prisma db push` (`alert_watches`). 12/12 backend · 29/29 frontend.

### Honest ruling on the rest of the named apps (verified in code, NOT force-fit)
- **Nexus** — workflow engine is **V1+ gated by design** (C-109); no real feature without it.
- **DX** — real value = **API keys** (gated); the catalog is not own-data.
- **FundX · Insure** — **P0 financial hard-gate** (C-113 §11 pools · C-129 escrow = payment-service only,
  Invariant #8). **Refused on principle** — building anything touching pools/escrow risks multi-user loss.

### Fleet Pro-bug status
The subscription-unwrap bug (Session 40) has now been fixed in **6 apps**: Life · Connection · Epic · NX
(Session 40) + **Explorer · Zone** (this session). Every app that gates on Pro now detects it correctly.

### PR ledger
tec-explorer **#21** · tec-zone **#26** · tec-estate **#19** (all read existing data — no DB change) ·
tec-alert **#17** + AlertWatch backend on the core-backend branch (**needs `db push`: `alert_watches`**).
All local suites + typecheck green.

---

## SESSION 40 — HOTFIX: Pro read as FREE (subscription-unwrap) — every Pro gate was broken (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (found from a live prod screenshot:
> a real Pro user saw the Life "Goal Insights" gate LOCKED while "🌱 You're on Life Pro" showed above it;
> NX post had no ⭐ Featured despite "★ You're on Pro").

### The bug
`commerce GET /subscriptions/status` returns **`{ data: { subscription: { plan, isActive, isExpired,
current_period_end } } }`**. The new `resolveProStatus` helper (added Sessions 38–39, replicated in 4 apps)
only unwrapped **`.data`** and then read `s.plan` — which is `undefined` (it's `s.subscription.plan`) —
so it **always parsed FREE**. Result: **every Pro-gated feature failed for actual subscribers** — Life/Epic
insights locked, NX/Epic/Connection featured never lit, Connection followers list withheld. The existing
per-app `*Pro` badge parsed `.subscription` correctly (hence "You're on Pro" showed while the gate didn't) —
that contradiction on screen is what exposed it.

### The fix (one line × 4 apps)
`resolveProStatus` now unwraps **`root.subscription ?? root`** (flat shape still tolerated). Root cause of the
miss: **the BFF gate tests mocked the FLAT shape** (`{ data: { plan } }`), not the real nested one — so they
passed against a wrong contract. All four test suites were corrected to the **real `{ data: { subscription } }`
shape**, so this can't regress. Life 21/21 · Connection 26/26 · Epic 30/30 · NX 31/31.

### Lesson (recorded)
A BFF unit test is only as good as the response shape it mocks. When gating on another service's contract,
**mock that service's real envelope** (here `{ data: { subscription } }`) — a hand-written flat mock will
green-light a parser that fails in prod. PRs: tec-life **#22** · tec-connection **#28** · tec-epic **#22** · tec-nx **#18**.

---

## SESSION 39 — PRO = STANDALONE VALUE (not just reach): Connection + Epic insights (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). A quality pass on the
> campaign: turn the "⭐ Featured" (reach-only) Pros into services with **standalone value** — value
> that works with **zero population** because it surfaces the user's OWN data.

### The principle (recorded)
"Featured placement" is constitutionally clean (pay for reach, never trust) but its value is **latent**
until a population exists — a featured card in an empty directory is worth nothing. A stronger Pro
surfaces **the user's own data** (like LinkedIn "who viewed your profile"): valuable on day one, no
population needed, and **additive** (a new Pro-only capability — never removing a free one).

### Shipped (3 apps upgraded)
| App | New standalone Pro service | Own-data source |
|-----|----------------------------|-----------------|
| **Connection** | **📈 Network Insights** — who follows you + `mutual` flag + one-tap follow-back | your follow graph |
| **Epic** | **📊 Portfolio Insights** — completion rate · milestone progress · Zone-verified · Legend outcomes · funding | your projects |
| **Life** | **📊 Goal Insights** — completion rate · funding progress toward π targets · goals reached (deeper than the free strip) | your goals |

All gate the aggregate/list **server-side behind live Pro** (P5); the count/teaser is non-sensitive.
Connection `listFollowers` (mutual from own following set) · Epic `portfolioInsights` · Life `goalInsights`.
Tests (backend): connection 22/22 · epic 26/26 · life 15/15 — (frontend): connection 26/26 · epic 30/30 · life 21/21.
**Life is already `[Runtime Verified]`** → this upgrade reaches real users fastest (additive to unlimited goals).

### Honest ruling on the other 3 "Featured" apps (NOT forced)
Applying the same pattern to NX / Explorer / Zone would be **fake or harmful**, so it was **not** done:
- **NX** — its real value (applicants, views) needs **traffic**, not own-data. The only own-data Pro
  would be a **posting cap** (free-capped) — that **removes** a free capability (user-hostile). Kept
  Featured; a richer Pro (applicant insights) waits for traffic. **Honest defer.**
- **Explorer** — sample-only, **not deployed** yet (no real listing index). A "listing analytics" Pro
  is premature. **Defer until the index is real.**
- **Zone** — a data-insight Pro would **violate its charter** (C-120 §4: Zone records evidence;
  **Analytics** computes/judges). Zone Pro stays **priority review** — the constitutionally correct model.

### PR ledger
tec-core-backend **#202** (Connection directory + followers · Epic insights · Life goal insights) ·
tec-connection **#27** · tec-epic **#21** · tec-life **#21**. Ops: `db push` on `tec-identity-service`
(Life goal-insights needs no new table — reads existing `life_goals`). All local gates green.

---

## SESSION 38 — CONNECTION: DISCOVER DIRECTORY + CONNECTION PRO = FEATURED (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Eighth app deepened — the "make Pro real + serve the Pi community" campaign continues (NX → Connection).

### What it is
Connection's graph was **username-only** — you could follow a handle only if you already
knew it — and **Connection Pro enforced nothing** (it promised "unlimited collections",
which everyone already had). Two gaps closed with the proven pattern:
- **Community value → opt-in public discovery:** a **Discover directory** (`/app`) to find +
  follow people, plus a **public `/u/[username]` profile** reachable **outside a TEC session**
  (share `connection.tecosystem.app/u/<handle>` anywhere). Publishing is **opt-in**
  (sovereignty, C-107); verification is **presented** from Zone/kyc, never minted.
- **Real Pro → two genuine benefits (not just reach):**
  - **Network Insights** — the caller's OWN follower list + a `mutual` flag ("do I follow
    back?") + one-tap follow-back. Like "who viewed your profile" — **standalone value with
    zero population** (it's your own graph). The LIST is gated server-side behind live Pro
    (P5); the count is a non-sensitive teaser for non-Pro.
  - **⭐ Featured** directory card, ranked `verified → featured → recent` (reach only, within
    the verified tier — never trust). Both synced from the live subscription by the BFF (P5).
  - The Pro copy was rewritten from the empty "unlimited collections" claim to these.

### Backend / frontend (needs db push)
- `ConnectionProfile` (opt-in listing; `published` default false; `verified` presented;
  `featured` = Pro, `@@index`); `listDirectory` / `getPublicProfile` / `getMyProfile` /
  `upsertMyProfile` / `setDirectoryFeatured`. Controller: `GET discover` + `GET profile/:username`
  **public**; `profile/me` (GET/PUT) + `directory/featured` (PATCH) session-scoped. 20/20 connection tests.
- Discover section + "your public profile" editor + `/u/[username]` public page; BFF
  `/discover` + `/profile/[username]` (public) + `/profile/me` (own + featured reconcile). 23/23 frontend tests.

### The scorecard (8 apps: real Pro + a Pi-community surface)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| Epic | ⭐ Featured project | public `/discover` project directory |
| NX | ⭐ Featured opportunity | public opportunity board + community posting |
| **Connection** | **📈 Network Insights (who follows you) + ⭐ Featured** | **public Discover directory + `/u/[handle]` profile** |

### PR ledger
tec-core-backend **#202** (ConnectionProfile + directory + followers endpoints, 22/22) ·
tec-connection **#27** (26/26). Ops: `db push` on `tec-identity-service` (`connection_profiles`).
All local gates green.
Next candidates: **Alert · DX**.

---

## SESSION 37 — NX: OPPORTUNITY POSTING + NX PRO = FEATURED (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Seventh app deepened — the "make Pro real + serve the Pi community" campaign continues (Epic → NX).

### What it is
NX (the Pi Opportunity Exchange, ADR-010) already had a **public** searchable board — but
seed-only (read-only). The two gaps closed:
- **Community value → real two-sided service:** **posting**. Any signed-in Pi user posts a
  job / grant / gig / partnership; the whole community discovers it on the public board.
  Posts start **unverified** (Zone/kyc verifies later — NX presents, never mints, ADR-010).
- **Real Pro → NX Pro = ⭐ Featured:** a Pro poster's opportunities get featured placement.
  Search ranks `verified → featured → title` — featured lifts **within** the verified tier
  (pay for reach, never verification). Synced from the live subscription by the BFF (P5).

### Backend / frontend (needs db push)
- `NxOpportunity.owner` (nullable, P6) + `featured` (+ `featured_until`, `@@index`);
  `createOpportunity` + `listOwn` + `setFeaturedForOwner`; `POST /identity/nx/opportunity`,
  `GET /identity/nx/mine/:owner`, `PATCH /identity/nx/featured`. 12/12 nx tests.
- Post form + "your posts" + ⭐ badges; `/api/bff/nx/opportunities` (POST) + `/api/bff/nx/mine`
  (own + featured reconcile). 31/31 frontend tests.

### The scorecard (7 apps: real Pro + a Pi-community surface)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| Epic | ⭐ Featured project | public `/discover` project directory |
| **NX** | **⭐ Featured opportunity** | **public opportunity board + community posting** |

### Process note (recorded)
`tec-core-backend` uses ONE session branch, so the Epic (#201) and NX backend changes are
**both on that branch** (independent modules — Epic + NX). PR #201 covers both. Frontends are
separate repos/PRs (tec-epic #20 · tec-nx #17). Next candidates: **Connection · Alert · DX**.

### PR ledger
tec-core-backend **#201** (Epic + NX backend, 36/36) · tec-epic **#20** (27/27) · tec-nx
**#17** (31/31). Ops: `db push` on `tec-identity-service`. All local gates green.

---

## SESSION 36 — EPIC: PUBLIC DISCOVERY + EPIC PRO = FEATURED (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Resumes the "deepen the rest" campaign — apply the proven pattern (real Pro service + external Pi-community value) to the remaining apps, starting with **Epic** (it already has a real project backend: create → Zone-verify → Legend).

### What it is (the Explorer pattern on Epic)
- **Community value (outside TEC):** a **public `/discover`** page — the whole Pi community
  browses **launched** Pi projects ("what's being built on Pi?"), **no login**. Trust-first:
  Zone-verified rank first; ⭐ Featured within the tier; category filter.
- **Real Pro:** **Epic Pro = Featured placement** in that public directory — visibility only,
  ranked **below** `zone_verified` (pay for reach, never verification). Synced from the
  owner's live subscription by the BFF (P5); lapsed Pro clears it.

### Boundary correction (found while wiring)
Epic Pro's copy previously claimed *"priority Zone verification"* — **constitutionally wrong**
(Epic can't sell Zone's review queue; only Zone Pro does that, C-120 §7). Corrected to
**Featured placement**, which Epic genuinely owns and which ranks below verification.

### Backend / frontend (needs db push)
- `EpicProject.featured` (+ `featured_until`, `@@index`); `listPublic()` (launched-only,
  trust-first) + `GET /identity/epic/discover` (public); `setFeaturedForOwner()` + `PATCH
  /identity/epic/featured` (owner-scoped). 24/24 epic tests.
- Public `/discover` page + `/api/bff/epic/discover` (public, no token) + featured sync in
  the "my projects" BFF + ⭐ badge on the board. 27/27 frontend tests.

### The "Pro is real + serves Pi" scorecard (apps done)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| **Epic** | **⭐ Featured project** | **public `/discover` project directory** |

### Next (recorded)
Same pattern for the remaining apps — candidates: **NX** (public opportunity board + featured
posting), **Connection** (public trust profiles), **Alert** (public Pi-community feed), **DX**
(public builder catalog). Each: real Pro benefit + a public/community surface, within the boundary.

### PR ledger
tec-core-backend **#201** (listPublic + featured, 24/24) · tec-epic **#20** (public discovery
+ Pro sync, 27/27). Ops: `db push` on `tec-identity-service`. All local gates green.

---

## SESSION 35 — ANALYTICS PROD REVIEW FIXES (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (found from live prod screenshots) + **[Code Verified]** (fix PR open). Two fixes + one operational finding from reviewing the deployed Analytics dashboard.

### Fix 1 — admins were locked out of the new community features
The dashboard branched `admin ? PlatformSections : MerchantIntelligence…`, so an **admin
never saw** Merchant Intelligence / peer comparison (found: logged-in-as-admin screenshots
showed only the platform view). But those are **own-scope** (an admin is a merchant too) —
now they render for **everyone**; only the platform aggregates stay admin-only (C-122 §5
SOVEREIGN). An admin sees both from one login.

### Fix 2 — misleading flat charts → honest empty state
The platform `BarChart` drew a row of equal 2px bars (screenshots) that read as *broken*.
Now: all-zero → an honest "No daily totals for this period yet"; nonzero bars get a visible
6px floor (small days don't vanish next to an outlier); NaN coerced. No fabricated data.

### The root cause + Fix 3 (backend — charts now read the event log)
The flat charts surfaced a real gap: **the platform charts read the `dailyMetric` aggregate,
which lags the live event counts.** Prod showed **Overview = 716 payments** (from
`analyticsEvent.count`) while the daily chart's `dailyMetric` totals were **~0** — the
`updateDailyMetric` path (on the `payment.completed` consumer) under-populates in prod
(historic days never aggregated). **Fixed at the source:** `getPaymentAnalytics` +
`getUserAnalytics` now build their daily series from the **event log** (bounded scan), the
same source as Overview + Merchant Intelligence — so the charts match reality regardless of
the aggregate. `getPaymentAnalytics`: `total_payments`/`total_volume` from
`payment.completed(.v1)` (amount coerced from the Decimal→string payload).
`getUserAnalytics`: `new_users`/`kyc_verified`/`active_users` (distinct/day) from one scan.
Same response shape → frontend unchanged. Eventual-consistency + admin-only + bounded → an
acceptable event scan (tec-core-backend #200, 74/74).
> The `dailyMetric` backfill is now an **optional** ops nicety, not a blocker — the dashboard
> no longer depends on it.

### PR ledger
tec-analytics **#30** (admin MI visibility + honest BarChart, 41/41) · tec-core-backend
**#200** (platform charts read the event log, 74/74). No schema change.

---

## SESSION 34 — PEER COMPARISON SEGMENTATION (by app source) (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Extends Session 33's peer comparison with the category dimension — the honest, owned version of "category/region."

### What it is
The peer comparison (Session 33) gains a **segment toggle**: compare against **All** active
merchants, or just those on **your own app source** (e.g. Commerce). Each segment is
k-anonymized independently.

### The honest boundary call (category = app source; region = deferred)
"Category/region segmentation" was the recorded next step. Reading the data decided *which*
is honestly buildable:
- **Category → app SOURCE** (`payload.metadata.source`) — this is the **only category
  dimension Analytics genuinely OWNS**: it already lives in Analytics' own event payload
  (the `payment.completed.v1` event carries the payment's `metadata`, incl. `source`). So
  "vs other merchants on Commerce" is real, owned, no cross-service read.
- **Region / geography → DEFERRED (with reason)** — a merchant's location is **business-profile
  data Analytics does NOT own** (it belongs to Explorer / identity). Segmenting by region would
  need a governed cross-service signal (a bigger data model) — recorded, not faked.

### The design (per-segment k-anonymity)
- Backend `getCategoryComparison(userId, segment?)` **auto-detects** the caller's dominant
  source (bounded own read) → returns it as `ownSegment` so the UI can offer the toggle. When
  a segment is chosen, the cohort is restricted via a **JSON-path filter**
  (`payload.metadata.source == segment`), and the **same k-anonymity floor** applies **per
  segment** (a too-small segment cohort → suppressed, fail safe). Still counts (never π), still
  no per-user row leaves.
- Frontend: an "All / <your source>" toggle on the PeerComparison panel; the BFF forwards a
  **whitelisted** segment slug (a malformed value is dropped before it reaches the JSON filter).

### Honest gaps / follow-ups (still recorded)
- **Region segmentation** — needs a category/geo signal on the merchant profile (Explorer/
  identity) surfaced via a governed cross-service read; deferred.
- **Differential-privacy noise** — the k-anonymity floor remains the v1 guard.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (…+ segment, 74/74) · tec-analytics **#29** (…+ segment toggle, 41/41).
All local gates green (build · lint · tests · tsc).

---

## SESSION 33 — DE-IDENTIFIED PEER COMPARISON (you vs the field) (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Third step of "Analytics serves the broader Pi community" — the recorded next step from Sessions 31–32.

### What it is
Inside Merchant Intelligence: **"how am I doing vs other active Pi merchants?"** The caller's
OWN metric (transactions, last 30d) next to a **de-identified cohort baseline** — cohort mean,
median, and the caller's **percentile** ("top X%" / "ahead of Y%"), over all active merchants.

### The privacy design (this is the whole point)
A comparison against "the average" is the classic place a naive analytics feature leaks. The
guards:
- **Distribution only** — the backend `groupBy`s per-merchant counts but uses ONLY the sorted
  distribution; **no `user_id` and no other merchant's value ever leaves the method**.
- **k-anonymity, fail-safe** — if the active-merchant cohort is below the floor (**5**), the
  **entire comparison is suppressed** (`available:false`) — never a mean/median over too few
  peers. The UI then says, honestly, "not enough active merchants to compare privately yet."
- **What leaves:** the caller's own count, the cohort mean/median (aggregates over ≥K), the
  percentile, and the cohort size (already public via the Pulse).
- **Counts, never money** — transactions per merchant, never π volume (C-105 — activity, not value).

Constitutional basis: C-105 §6 (own-scope for the caller) + C-122 §5.2 (de-identified aggregate
for the cohort). Both allowed; the cohort side is k-anonymized.

### Backend / frontend (no schema change)
- `getCategoryComparison(userId)` + `GET /analytics/me/comparison` (own-scope, fail-closed).
  6 backend tests incl. **suppression below floor** + **no-user_id-leak** + percentile.
- `/api/bff/analytics/me/comparison` (own-scope forward) + a `PeerComparison` panel inside the
  Merchant Intelligence block (renders nothing when unavailable; honest small-cohort message).

### The three community surfaces now (Sessions 31–33)
| Surface | Scope | Who sees it |
|---------|-------|-------------|
| **Merchant Intelligence** | own-scope (§5.1) | any signed-in Pi merchant |
| **Peer comparison** | own + de-identified cohort (§5.2) | any signed-in merchant (when a cohort exists) |
| **Pi Economy Pulse** | de-identified aggregate (§5.2) | the whole Pi community (public, no login) |

### Honest gaps / follow-ups (recorded)
- **Category/region segmentation** — "vs other Pi *cafés* near you" needs a category signal on
  the merchant profile + a per-segment cohort ≥K (a bigger data model); the current comparison
  is platform-wide-cohort. Recorded as the next step.
- **Differential-privacy noise** — the k-anonymity floor is the v1 guard; adding small noise to
  the mean is a future hardening against differential attacks as the platform grows.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (MI + Pulse + comparison, 70/70) · tec-analytics **#29** (all three
frontends, 40/40). All local gates green (build · lint · tests · tsc).

---

## SESSION 32 — PI ECONOMY PULSE (Analytics' first PUBLIC surface) (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Second step of "Analytics serves the broader Pi community" (after Merchant Intelligence): a public board anyone can see, even logged out.

### What it is
A **public** `/pulse` page (no login) — **"is the Pi economy active?"** — showing platform-wide
**activity signals**: total transactions, 7-day count, week-over-week growth, active-merchant
count, and a 14-day daily-activity sparkline. This is the community-facing complement to
Merchant Intelligence (own-scope): Pulse is the *aggregate*, public view.

### The constitutional basis (C-122 §5.2 AGGREGATE disclosure) + the guards
Analytics may disclose de-identified AGGREGATE data publicly (§5.2). This is that — with
hard guards so it can never identify anyone:
- **Aggregate counts ONLY** — no per-user / per-merchant row ever leaves the service
  (the distinct-merchant query returns a COUNT; rows never leave the method).
- **k-anonymity floor** — an active-merchant cohort below **5** is suppressed to `null`
  (UI shows `—`), so a tiny early platform can't identify individuals.
- **Activity, NOT money-as-truth, NOT price** — no π volume, no market/price chart (the
  Session 31 decision holds). Analytics never presents a figure as financial truth (C-105).
  The page carries an explicit disclaimer ("de-identified aggregate signals · not investment
  information").
- **Served via a public BFF** that adds the internal key server-side; the backend `authorize()`
  still requires a valid actor (internal/user) and it is **never** platform-sovereign data.

### Backend / frontend (no schema change)
- `getEconomyPulse()` — built from the already-aggregated `dailyMetric` table + a distinct-
  merchant COUNT. `GET /analytics/pulse` (public-via-BFF). 6 backend tests (de-id shape / no
  user_id leak / k-anonymity / WoW).
- `/api/bff/analytics/pulse` (public, no token) + a themed public `/pulse` page (inline
  Pi-Browser-safe charts). 2 frontend tests.

### Honest gaps / follow-ups (recorded)
- **De-identified category comparison** ("you vs the average Pi café") — still the deliberate
  NEXT step; needs a cohort-safe AGGREGATE join (min cohort size), not faked.
- Pulse is only as populated as `dailyMetric` — if the daily-metric updater lags, it shows
  fewer days (honest, no fabrication).
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (Merchant Intelligence + `getEconomyPulse`, 64/64) · tec-analytics
**#29** (MI dashboard + public `/pulse`, 38/38). All local gates green (build · lint · tests · tsc).

---

## SESSION 31 — MERCHANT INTELLIGENCE (Analytics → the broader Pi community) (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Answers the strategic question "how does Analytics serve Pi merchants OUTSIDE TEC?" — the first step: give any Pi merchant real insight into their own business.

### The strategic frame (a deliberate NO to price charts)
The user asked whether Analytics could serve the wider Pi community — e.g. "analyze a coin
price chart." **Recorded decision: NO to market/price charts** (for now). A price/market
chart is (1) **not our data** — market price is owned by external exchanges, not
payment-service; presenting it as truth breaks C-105; (2) **legal risk** — a price chart
with any trend/buy signal reads as financial advice (same reason FundX/Insure/Estate are
hard-gated); (3) accuracy liability. If ever built, it must be an *external, clearly-labelled
indicative source* with **no buy/sell signal** — a separate governed decision, not a feature.

**The right first step (shipped): Merchant Intelligence** — Analytics' CORE value ("understand
your own activity") surfaced for **any Pi merchant**, from OUR real data, fully within the
constitution.

### What it is (C-105 §6 own-scope — same truth, real insight)
A dashboard computed **only from the caller's own event log**:
- **When you're busiest** — UTC peak hour + a 24-bucket hour-of-day histogram.
- **The trend** — week-over-week change (▲/▼ %).
- **Daily activity** — a zero-gap-filled sparkline.
- **Activity mix** — top event types as % bars.

Never cross-merchant, never financial truth (the owning services own the money). No new
disclosure surface — own-scope + fail-closed, same rule as `me/overview` / `me/activity`.

### Freemium (draws the community in, then Pro depth)
FREE merchants get the full intelligence on a **14-day** window (real value → a reason to
show up); **Merchant Pro** widens it to **90 days** + the CSV export (Session 30) — *same
trusted numbers, more depth*. Window chosen server-side from the live subscription (P5 —
Analytics never stores billing).

### Backend (no schema change — all derived from the existing event log)
- `getMerchantIntelligence(userId, sinceDays)` — own-scope, bounded compute (scans ≤5000 own
  events; honest `sampled` flag), UTC-deterministic hour histogram, WoW math, zero-gap daily
  series, top activity. `peakHour = null` on no activity (honest empty state).
- `me/intelligence` — own-scope, fail-closed (401), `days` clamped ≤365.

### Honest gaps / follow-ups (recorded)
- **De-identified category comparison** ("you vs the average Pi café") is a deliberate NEXT
  step — it needs an AGGREGATE disclosure (C-122 §5.2) with real de-identification, not faked.
- **Pi Economy Pulse** (a public, de-identified "is the Pi economy active?" board) — proposed.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (getMerchantIntelligence + me/intelligence, 58/58) · tec-analytics
**#29** (Merchant Intelligence dashboard, 36/36). All local gates green (build · lint · tests · tsc).

---

## SESSION 30 — ANALYTICS PRO = 90-DAY ACTIVITY HISTORY + CSV EXPORT (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy + a real Analytics Pro payment. Fourth app in the "make Pro real" line (Explorer · Zone · Legend · **Analytics**).

### The benefit — deeper/longer own data + export
Session 28 recorded Analytics Pro as the next "still just a supporter badge." Now it delivers
a **concrete service**: a deeper/longer **own-scope activity history** you can **export as
CSV**. FREE sees the live on-screen "Recent events" preview; **Pro exports the full 90-day
history (≤500 rows)** — for the merchant's own records, spreadsheets, or accounting.

### The constitutional line held (C-105 — same truth, more depth)
The numbers are **identical computed truth** — Pro unlocks **DEPTH + export**, never
different data. No new disclosure surface: `me/activity` was already **own-scope +
fail-closed** (C-105 §6 / C-122 §5.1). This only changes *how much* of the caller's OWN data
returns (rows + window) and adds a CSV download. Analytics still never presents aggregates as
financial truth (owning service is the source of truth).

### The gate (fail-closed, own-scope, P5)
- **Export is Pro-gated at the BFF** (`/api/bff/analytics/me/export`): no live subscription →
  **403**. Analytics never stores billing (P5) — `resolveProStatus` reads it **live** from
  commerce (`/api/commerce/subscriptions/status`). Downgrade → export 403s again.
- Strict own-scope: the BFF forwards only the session Bearer; identity is derived server-side
  by the analytics service (never a param). RFC-4180 CSV escaping + `attachment` disposition.

### Backend (analytics-service, no schema change)
- `getRecentEvents(limit, userId, sinceDays?)` gains an optional `created_at ≥ now − sinceDays`
  window — **backward-compatible** (no `sinceDays` → identical query as before). Only the DEPTH
  knob; still the caller's OWN events only.
- `me/activity` accepts `days` (clamped ≤365) + raises the limit cap **25→500** (the export data
  source). No `db push` — the window is a query filter, not a column.

### The Pro model now (5 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |
| **Legend** | 🔖 Embeddable reputation badge — your earned reputation, on any site |
| **Analytics** | 📁 90-day activity history + CSV export |

### Honest gaps / follow-ups (recorded)
- The remaining apps' Pro is still the supporter badge — each a follow-up with its own
  charter-sound benefit (the important five now deliver real value).
- `[Code Verified]` — `[Runtime Verified]` needs the Vercel redeploy + a real Pro payment.
- Backend `me/activity` allows depth (500/365d) to any authed caller of their OWN data; the
  *product* gate (export) is the BFF's 403. No leak — it is always the caller's own data.

### PR ledger
tec-core-backend **#198** (me/activity `days` window + 500 cap, 50/50) · tec-analytics **#28**
(Pro-only CSV export + ProHistory, 33/33). All local gates green (build · lint · tests · tsc).

---

## SESSION 29 — LEGEND PRO = EMBEDDABLE REPUTATION BADGE (8 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after `tec-identity-service` `db push` + Vercel redeploy + a real Legend Pro payment. Continues Session 28's "make Pro real" — third app after Explorer + Zone.

### The benefit — reputation that travels the Pi economy
Session 28 flagged Legend Pro as still "just a supporter badge." Now it delivers a
**concrete, shareable service**: a public **embeddable reputation badge** — a live SVG a
member drops on their own website / Pi store / marketplace listing
(`<img src="https://legend.tecosystem.app/badge/<handle>.svg">`) that always reflects their
current earned reputation. This is Legend's outward reach into the whole Pi ecosystem (like
Zone's `/badge` — reputation, not verification).

### The constitutional line held (C-126 — earned, never bought)
Legend's rule is that reputation comes from source-app outcome events + Analytics-computed
scores — a user can never author it. This change respects that **completely**: a single
`showcase` flag gates **only the marketing surface** (the badge). It never touches an
achievement record, never changes a score, never mints verification. **You pay to
DISTRIBUTE a reputation you already earned, not to buy one.** Same shape as Explorer
(featured = visibility, below trust) and Zone (priority = queue, never verdict).

### The gate (fail-safe, leaks no score)
The `/badge/<handle>.svg` endpoint renders the overall score (or the earned achievement
count while Analytics scores are still pending) **only** for a `PUBLIC` profile with
`showcase` on (a live-Pro entitlement). Every other case — not Pro, not public, not found,
backend unreachable — degrades to a neutral "Pi reputation" wordmark that **leaks no
score**. Public, no-auth, edge-cached (`s-maxage=300`).

### Sync pattern (identical to Explorer/Zone — P5)
- Backend: `LegendProfile.showcase` (one boolean) + `setShowcase(owner,on)` + `PATCH
  /api/identity/legend/own/:owner/showcase` (owner-scoped, P6; never creates a profile —
  reputation is earned, not toggled). **22/22 backend tests.**
- Frontend: the profile BFF reads the caller's **live** subscription from commerce
  (`/api/commerce/subscriptions/status`) and reconciles `showcase` to match — Legend never
  stores billing truth (P5, commerce-owned). Lapsed Pro → badge falls back on next visit.
- UI: a Pro-only `ShowcaseCard` (live badge preview + copy-embed HTML/Markdown snippets;
  nudges Public when needed; honest upsell when not Pro). **29/29 frontend tests · +5 badge-gate tests.**

### The Pro model now (4 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |
| **Legend** | 🔖 Embeddable reputation badge — your earned reputation, on any site |

### Honest gaps / follow-ups (recorded)
- **Analytics Pro** (and the rest) still give only the supporter badge — Analytics next
  (proposed: deeper/longer merchant data + export). A follow-up per app.
- **`showcase` lapse:** reconciled on the owner's next profile load via the BFF (same as
  Explorer/Zone `featured`/`priority`); a background sweep cron is the shared follow-up.
- `[Code Verified]` — `[Runtime Verified]` needs `tec-identity-service` `prisma db push`
  (one boolean column, expand-only/non-destructive) + Vercel redeploy + a real Pro payment.

### PR ledger
tec-core-backend **#197** (LegendProfile.showcase + PATCH endpoint, 22/22) · tec-legend
**#19** (embeddable badge + sync + ShowcaseCard, 29/29). All local gates green (build · lint · tests · tsc).

---

## SESSION 28 — "DOES PRO GIVE REAL VALUE?" → 2 apps now do (7 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (merged/queued) — each becomes `[Runtime Verified]` after its Railway `db push` + Vercel redeploy + a real Pro payment.

### The honest finding (audited the code, not the copy)
The user asked the sharp question: *does the Pro subscription actually give a real service, or just a badge?* Reading the code, the honest answer was **mostly a badge**:
- **Life** — the only app with a real gated benefit (unlimited goals vs FREE's 3).
- **Explorer** — the copy claimed "premium visibility" but the ranking had **no Pro signal** — Pro changed nothing.
- **~18 other apps** — "★ You're on Pro — thanks for supporting TEC": a supporter badge, no gated feature.

This is a real pre-campaign risk (people pay, get nothing → churn + reputation damage). Recorded as the honest state; the fix is to give each Pro a **concrete, charter-sound benefit** — started with two.

### 1. Explorer Pro = FEATURED placement (C-108 §7) — a real discovery boost
- `ExplorerBusiness` gains `featured` + `featured_until`. Search ranks **featured-first WITHIN the trust tier**: `verification → featured → popularity → pi_accepted → name`.
- **Featured sits BELOW verification on purpose** — you can pay for *visibility*, never for *trust*. A KYC-verified free business always outranks an unverified Pro one. (Same principle as Zone: "speeds the queue, never the verdict.")
- The listings BFF re-syncs `featured` from the owner's **live** Pro subscription (commerce-owned, P5 — Explorer never stores subscription truth); lapsed Pro clears on the next owner visit. `⭐ Featured` tags on the listing + search results; honest pitch copy.
- PRs: tec-core-backend **#195** (22/22 tests) · tec-explorer **#20**.

### 2. Zone Pro = PRIORITY review (C-120 §7) — the charter's own sanctioned benefit
- The charter says exactly one thing Zone Pro may sell: *"speeds the review queue, never the verdict."* Implemented: `ZoneEntity.priority`; `listPending` orders **priority-first, then FIFO**; `submitRequest` accepts `priority`, set by the BFF from the caller's live subscription.
- **Queue speed ONLY** — the entity still starts PENDING and a **human still decides**. A spoofed priority buys queue order, never verification (low-stakes by design). Reviewer sees a `⭐ Priority (Pro)` tag.
- PRs: tec-core-backend **#196** (20/20 tests) · tec-zone **#25**.

### The Pro model now (3 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |

### Honest gaps / follow-ups (recorded)
- **Legend Pro · Analytics Pro** (and the rest) still give only the supporter badge — each needs its own concrete benefit (proposed: Legend = embeddable reputation badge; Analytics = deeper/longer merchant data + export). A follow-up per app, not a one-liner.
- **`featured`/`priority` lapse:** cleared on the owner's next visit via the BFF re-sync; a background sweep cron for owners who don't return is a follow-up — consistent with the existing "no server-side downgrade job yet" stance (Session 26).
- Both features are **`[Code Verified]`** — `[Runtime Verified]` needs each service's `prisma db push` (adds the columns, expand-only/non-destructive) + a Vercel redeploy + a real Pro payment.

### PR ledger
tec-core-backend **#195** (Explorer featured), **#196** (Zone priority) · tec-explorer **#20** · tec-zone **#25**. All local gates green (build · lint · tests · tsc).

---

## SESSION 27 — REPUTATION CHAIN RUNTIME-VERIFIED (real user) + ZONE → PI ECOSYSTEM (7 Aug 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for the Epic → Legend chain (a real user completed an Epic project in prod → the achievement is recorded in Legend, and `epic.project.completed.v1` is visible in the Analytics event log) · **[Code Verified]** (merged) for the new surfaces below (each needs its Vercel/Railway redeploy to be Runtime Verified).

### Headline — the reputation value chain is now proven with REAL DATA
Sessions 20–21 wired the chain in code; **this session it fired for a real user end-to-end in production.** A pioneer (`yas55eR82`) created an Epic project ("Atlas"), completed it, and: (1) `epic.project.completed.v1` shows in the **Analytics Recent-events** feed (Aug 7), (2) Legend recorded a **verified achievement** ("Completed an Epic project") on their live profile. The `create → earn` edge is **[Runtime Verified]** with genuine user activity, not a seed.

### What shipped (deepening 3 chain apps into real, usable services)

**Epic (Creation) — from read-only preview → a real create+track surface (C-125)**
- **Create a project** — a signed-in pioneer actually makes a project (DRAFT/unverified/unfunded, unique slug, owner = session identity — P6). `EpicService.createProject` + `POST /identity/epic/project`; a `CreateProject` form on the board. Backend #190 · frontend tec-epic #17/#18.
- **Milestones** — the owner adds milestones + checks them off on `/project/[id]` (owner-only, server-side gated, terminal-safe, bounded). `addMilestone`/`setMilestoneDone` + `POST/PATCH …/milestone`. Backend #191 · frontend #18.
- **Epic → Zone verification request (C-121 create → verify)** — the owner asks Zone to verify their project; the BFF forwards the JWT to Zone's own gateway API (a clean service-API seam, C-132 — **no backend change**). Zone starts it PENDING; on VERIFY it emits `zone.badge.issued.v1` → Legend. frontend tec-epic #19.
- The always-visible fix: `CreateProject` no longer gated on the client-side `usePiAuth` flag (unreliable in Pi Browser — C-123); the BFF fails closed server-side (401). #18.

**Zone (Verification) — now serves the WHOLE Pi ecosystem, not just TEC (C-120)**
- **Public Trust Check** — a verified-first search over the live registry (backend `ZoneService.search` + `GET /identity/zone/lookup`; frontend `TrustCheck` on `/app`). Anyone (no TEC login) can ask "is X Zone Verified?". Backend #190 · frontend tec-zone #22.
- **Embeddable "Zone Verified" badge** — `GET /badge/<handle>.svg` renders the **live** verdict (verified · pending · revoked · not verified); a `ShareBadge` panel on `/verify/<handle>` (verified only) gives copy-link + copy-embed-HTML. A verified Pi project embeds it on its **own** site → every badge links back to the evidence → Zone spreads across Pi as the shared trust layer. Constitutionally sound: only an already-verified entity can broadcast (earned, never bought — C-120 §7). No backend. frontend tec-zone #24.
- **Review panel fix** — the reviewer queue was gated on the client `isAuth` flag (C-123) so a real ADMIN never saw it; now always loads, server decides. tec-zone #23.

**Legend (Reputation) — own & share your reputation (C-126)**
- **Own-view (bug fix)** — a real user could never see their own profile (only a `publicOnly` endpoint existed, profiles default PRIVATE). `GET /identity/legend/own/:owner` (includes PRIVATE; `{profile:null}` when none earned) + three honest home states (live · empty · sign-in). Backend #193.
- **Visibility control** — PUBLIC/CONNECTIONS/PRIVATE (the one user-controlled setting, C-126) via `setVisibility` + `PATCH …/visibility`; never creates a profile. Backend #193 · frontend tec-legend #17.
- **Shareable public CV** — `/u/<handle>` renders a PUBLIC profile ("Pi Professional CV"); a private/missing one is not discoverable. frontend #17.
- **0-score UX** — a real profile with achievements but no computed scores read as "empty 0"; now it leads with the achievement count + explains scores are Analytics-computed/pending. frontend tec-legend #18.

**Analytics (Intelligence) — scores become timely (ADR-013)**
- Legend scoring batch **24h → hourly** (`SCORING_INTERVAL_MS`) + `POST /api/analytics/scoring/run` (SOVEREIGN — internal/admin, C-122 §5) for an on-demand recompute. The pipeline was already wired (`epic.project.completed.v1`/`zone.badge.issued.v1` → `AnalyticsEvent` → `computeScores` → `legend.scores.updated.v1`); this makes a freshly-earned score appear within the hour, not the next day. Backend #194 (47/47 tests).

**Identity — admin bootstrap (the missing key, C-47/C-110)**
- There was **no path to ADMIN** (`findOrCreateUser` grants only USER), so Zone's review queue 403'd for everyone and verifications stuck PENDING. Added an env bootstrap: a Pi username in **`PLATFORM_ADMIN_USERNAMES`** is granted ADMIN on login (idempotent; only-write-if-missing; re-loads roles). The **only** path to ADMIN — no self-serve (P6). Backend #192. Runtime-verified: the operator became ADMIN and the Zone review queue rendered "Atlas".

### Honest gaps / notes
- **Separation of duties works as designed (not a bug):** a reviewer may not decide their **own** submission (C-120 §7), so the operator can't self-verify "Atlas". A real verification needs a different submitter — correct, and the whole point of Zone.
- **Scores → non-zero** requires the Analytics redeploy + one batch tick (or the on-demand endpoint). The `creator` dimension maps `epic.project.completed.v1`; the events are already in the log.
- **Strategic note (recorded):** the reputation apps (Epic/Zone/Legend/Elite/VIP) are chain-linked and mostly serve TEC-internal activity. "Packaging independence" (separate domains/logins) ≠ "value independence" (serving non-TEC Pi users). The apps with genuine outward value are **Zone** (public trust check + badge), **Legend** (public `/u` CV), **Explorer** (Pi-merchant discovery), and **Commerce/Ecommerce**. Direction agreed: make those few genuinely independent; treat the rest as the C-132 modules they already are, surfaced through Hub.

### PR ledger
Backend `tec-core-backend`: **#190** (Epic create + Zone Trust Check search), **#191** (Epic milestones), **#192** (admin bootstrap), **#193** (Legend own-view + visibility), **#194** (Analytics hourly scoring + recompute). Frontend: **tec-epic #17/#18/#19** · **tec-zone #22/#23/#24** · **tec-legend #17/#18**. All merged.

---

## SESSION 26 — SUBSCRIPTION ACTIVATION + PRO ENTITLEMENT (fleet-wide) (7 Aug 2026) ✅

> Truth State: **[Code Verified]** (merged to `main`) platform-wide · **[Runtime Verified]** for **Life only** (a real 5π Life Pro payment → ★ PRO shown live in prod after redeploy). The other 18 Pro apps are `[Code Verified]`, pending each app's Vercel redeploy + one real payment. Verification: **[Code Verified]** + **[Runtime Verified]** (Life).

### The gap (why a paying user got nothing)
Every app's in-app **"Pro" button** took a real Pi U2A payment but activated **no
subscription** — commerce-service had **no consumer** linking a completed payment to a
subscription. The old `OrderConsumer` is registered in **no module** (dead code). Only
the Hub's `/hub/subscription` flow ever activated a plan. So across ~19 Pro apps, a paid
user received **no entitlement**. This was the single largest pre-campaign risk (people
pay, get nothing).

### The fix — one backend consumer, both modes, whole fleet (tec-core-backend #188)
New **registered** `SubscriptionConsumer` (commerce-service) consumes
**`payment.completed.v1`** (which already carries the payment's metadata, Session 25) and,
when the payment is a Pro/Enterprise buy, activates the plan via
`SubscriptionService.subscribe` — the **same path the Hub uses** (no parallel system, P2).
- Detection (`planFromPaymentMetadata`): PRO/ENTERPRISE from a `<slug>_pro_monthly`
  **`item_id`** (Mode 2) / **`product_id`** (Mode 1 via Hub), or explicit `metadata.plan`.
- **Idempotent** (upsert by user; an "already subscribed" redelivery is a no-op —
  at-least-once delivery); a genuine failure rethrows so the message retries.
- **No payment-service change** — `payment.completed.v1` already carries `metadata`.
- New consumer group **`commerce-subscription`** added to the consumer-liveness sensor
  (`stream-health.service.ts`) + `verify-runtime.mjs` EXPECTED for `payment.completed.v1`.
- 8 unit tests (detection both modes + none + idempotency + rethrow). `Subscription` stays
  a commerce-owned Canonical Entity (C-47); no Pi is moved here (payment already completed).

### The hidden second half — the read path (`/me` never carried the plan)
`tec-auth-service` `getMe` selects **no** subscription field and its login response
**hardcodes `subscriptionPlan: null`**, so `usePiAuth().user.subscriptionPlan` was always
empty — the badge could never show even after activation. Since Subscription is
commerce-owned and `/me` is a hot path, apps now read the plan **directly from commerce**:
new BFF **`GET /api/bff/subscription`** → gateway `/api/commerce/subscriptions/status`
(session-scoped, P6, read-only). Fixed in tec-life first, then rolled to every Pro app.

### Display + expiry (19 apps, all merged)
Each Pro component shows **"★ You're on Pro"** (Life also: a header ★ PRO badge + the
concrete **unlimited-goals** benefit, FREE capped at 3 active goals) while the subscription
is **live** — gated on `isActive` + not `isExpired` (with a `current_period_end` fallback).
Because Pi U2A has **no auto-renewal**, Pro is a **30-day pass** and the badge/benefit
**end when the month lapses**. Apps: **Life · Zone · Nexus · Vip · Connection · Estate ·
Explorer · Nx · Alert · Analytics · Dx · FundX · Insure · Elite · Epic · Legend · Titan ·
NBF · Brookfield** (Life deepened; the other 18 via the identical patch, canary-built clean
on Zone + Vip).

### Runtime-verified on Life (first end-to-end proof)
A real **5π Life Pro payment** → after commerce + Life redeploy, the **★ PRO** badge +
unlimited-goals unlocked live, and the code correctly ends it after 30 days. Full loop
proven: **activate → read → show → expire.**

### Also this session (adjacent, merged)
- **Nexus run-resume fixed** (tec-nexus #18): a live workflow-payment flow was silently
  broken — Mode-1 sent no `return_url` (dumped the user on the Hub) + no restore/poll on
  return. Now returns to `/workflow/[id]` and resumes. Sensor extended to watch
  `identity-nexus` (tec-core-backend #186).
- **Life deepened** (tec-core-backend #187 + tec-life #17/#18/#19/#20): goals gained
  `target_amount` + `progress` + auto-complete → a real π **goal tracker** (Life moved from
  preview to advertise-ready).

### Honest gaps / follow-ups (recorded, not hidden)
- **[Runtime Verified] = Life only.** The other 18 apps are merged `[Code Verified]`; each
  needs its Vercel redeploy + one real payment. A user's **earlier (pre-consumer) payment
  does NOT back-activate** — only new payments after the consumer deploy.
- **No auto-renewal** — Pi U2A is one-time; Pro is a 30-day pass. A renewal *reminder* flow
  is a follow-up (Pi cannot auto-charge).
- **No server-side downgrade job** — expiry is enforced in the read (client) + backend
  `SubscriptionService.hasAccess()`. A commerce cron to flip expired → FREE server-side (so
  every consumer agrees without re-checking the date) is a follow-up.
- **System excluded — correctly.** `system_supporter` is a voluntary 1π contribution that
  grants nothing (C-110); there is no Pro to show. A persistent "Supporter ✓" ack would
  need payment-tracking (separate follow-up).
- **Price-vs-plan mismatch (hardening):** `PLANS.PRO.price = 10π` but some Pro surfaces
  charge less (Life 5π); the consumer activates PRO regardless of amount (`verifyPiPayment`
  is skipped when no `piPaymentId`). Follow-up: assert `amount == plan price` at activation.

### PR ledger
Backend: tec-core-backend **#186** (sensor→nexus), **#187** (Life goal tracker), **#188**
(SubscriptionConsumer). Frontend: tec-life **#17/#18/#19/#20**; **19** Pro-entitlement PRs
across the fleet (Zone #21 · Nexus #19 · Vip #16 · Connection #26 · Estate #18 · Explorer
#19 · Nx #16 · Alert #16 · Analytics #27 · Dx #16 · FundX #15 · Insure #16 · Elite #16 ·
Epic #16 · Legend #16 · Titan #16 · NBF #6 · Brookfield #4) — all merged.

---

## SESSION 21 — VALUE CHAIN RUNTIME-LIVE + LEGEND → ELITE (31 July 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for the consumers (Redis live in prod) · **[Code Verified]** for the new Legend → Elite engine (tec-core-backend #159).

**Runtime-verified:** `REDIS_URL` is set on `tec-identity-service` (Railway) and all four
event consumers boot in production — Deploy Logs show `✅ Legend Consumer started` +
`[LegendConsumer] Started — listening…` on the 5 outcome streams (payment/epic/zone/
fundx/connection) + Explorer + OrderPaid + UserCreated. The value chain now **fires for
real**, not just as merged code.

**Legend → Elite wired (the last chain edge):** `EliteService.evaluateOwner` grants
**criteria-based** Elite recognition from Legend evidence — the Analytics-computed
`score_*` (relayed, never recomputed) + real verified-achievement / Zone-verified counts.
The Legend consumer triggers it after each recorded outcome (fail-safe). **Earned, not
sold:** no grant endpoint; **GOLD/PLATINUM → CANDIDATE for a human PANEL** (never
auto-active); a dropped criterion **EXPIRES** an automated grant; a PANEL decision is
never downgraded. Elite reads Legend via a **service API** (`getStatsForOwner`) — the
R-2-clean seam (C-132 §7.5), not a raw table read. 191 tests pass.

**Full reputation chain now end-to-end:** Epic/Zone → Legend → **Elite** → VIP.

**PRs:** tec-core-backend **#159** (Legend → Elite criteria engine) · tec-knowledge-base
(this doc reconciliation). Frontend needs no change — Elite `/app` surfaces granted
recognitions via the existing read layer; VIP already lifts the tier live.

**Next (P2, C-127):** richer multi-signal Elite scoring as Analytics matures (the V1
engine grants on one metric per program).

---

## SESSION 20 — VALUE CHAIN WIRED + STATUS RECONCILIATION (31 July 2026) ✅

> Truth State: **[Current State]** for the edges below · Verification: **[Code Verified]** (merged to `main`) — the chain is **NOT** yet `[Runtime Verified]` (needs `REDIS_URL` on `tec-identity-service` + the Legend consumer running).

**Shipped (merged):** the user-layer **reputation value chain** — the first live,
event-driven forward-flow (C-121 Rule 3). Wired in `tec-identity-service` + app frontends:

| Edge | Signal (C-70) | Direction |
|------|---------------|-----------|
| Epic → Legend | `epic.project.completed.v1` | create → earn |
| Zone → Legend | `zone.badge.issued.v1` | verify → earn |
| Elite → VIP | live tier check | recognition → experience |
| → Legend | `legend.consumer.ts` ingests both, idempotent by `eventId` | — |

Producer: `src/events/stream-emitter.ts` (fail-safe no-op without `REDIS_URL`). The
**Legend → Elite** edge was deferred here — now **wired in Session 21 (above)**.

**Docs reconciled (KB v3.12.0):** added `## Implementation Status` to C-120/121/125/126/127/128
(the chain) and `## Deployment Status` to the 14 app charters that still read
`[Future Vision]` (C-106/107/108/109/110/111/112/113/114/115/124/129/130/131) — each
cites `architecture/app-fleet.yaml` (all 24 live: 21 `live-verified` + 3
`live-readonly-gated`) and records `[Runtime Verified]` for the deployed app + live
payment, keeping the full runtime `[Future Vision]`. Charter headers unchanged; all 13
KB gates pass.

**PRs:** tec-core-backend #158 (value-chain backend + tests) · tec-knowledge-base #100
(doc reconciliation) · plus the 6 app PRs (Epic/Zone/Legend/Elite/VIP/Titan) merged.

**Follow-up (ops):** set `REDIS_URL` on `tec-identity-service` + run the Legend consumer
→ promotes the chain to `[Runtime Verified]`. Next code step: Analytics criteria engine
→ the missing Legend → Elite edge.

---

## SESSION 19 — REFERRAL PROGRAM "Invite & Earn" (25 July 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (deployed — Hub on Vercel + commerce-service migration on Railway).
> Decision of record: **ADR-012 (C-64)** · Growth doc: **C-133 §5.1**.

**Shipped:** the referral / invite viral loop on top of the Founding-Pioneer funnel.
A user invites a friend; when that friend takes their **first paid subscription**,
**both** get a free **30-day PRO month**.

- **Reward = gift subscription, never raw Pi** (ADR-012). A Pi cashback is capital
  movement — only payment-service custodies Pi (Invariant #8) — so it's **hard-gated**
  (legal + custody + SYSTEM) like FundX/Insure and NOT built. The gift month moves no Pi.
- **Reward on the referee's first paid subscription** (outcome, not signup) → anti-sybil.
  Atomic `PENDING→REWARDED`, at-most-once per referee.
- **Owner = `tec-commerce-service`** (the reward *is* a subscription extension → atomic,
  no cross-service call). Identity from the verified JWT, never the body (P6).
- **Entry points:** animated **Invite & Earn** carousel slide · **🎁 Invite** Hub tool ·
  any **`?ref=` invite link** captured on any page pre-login, applied on first auth.

**PRs (merged):** tec-core-backend #156 (referral module + migration) · tec-app #129
(referral page + BFF) · tec-app #130 (carousel slide + global `?ref` capture).

---

## SESSION 18 — ALL 24 APPS LIVE ON MAINNET (16 July 2026) ✅

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (deployed + real Pi).
> This is the authoritative current-state header; older snapshots below are historical record.

### 🎉 Milestone: the full ecosystem is live
All **24 apps** are **registered + deployed + live on Mainnet with real Pi**. Every app has a
Pi App ID (canonical list = **C-01 §4**), is on Vercel, is enabled in Hub SSO, and its
**Pro/subscription** payment surface processes **real Pi** (Portal "Process a Transaction" passed).

```
24 LIVE: Hub · Commerce · Assets · Ecommerce · Analytics · Life · Connection ·
         Zone · Nexus · Explorer · System · Alert · NX · DX · Titan · Epic ·
         Legend · Elite · VIP · NBF · Estate · FundX · Insure · Brookfield
```

### ⚠️ "Live" = subscriptions real; high-risk financial mechanics still hard-gated
The **Pro/subscription** flows are real Pi. But by charter, these mechanics stay **read-only /
simulated** until legal + payment-service custody (Invariant #8) + SYSTEM governance:
- **FundX** pools (C-113) · **Insure** escrow (C-129) · **Brookfield** investment/REITs (C-131).
- Do NOT treat escrow/pool/REIT custody as live.

### Knowledge Base
| Field | Value |
|-------|-------|
| Version | **v3.10.0** (+ C-131 Brookfield) |
| Docs | **112** C-docs · registry **100% coverage** |
| Newest | **C-124→C-131** user-layer app charters (NBF · Epic · Legend · Elite · VIP · Insure · Titan · Brookfield) |
| Fleet SoT | `architecture/app-fleet.yaml` (all 24 live + App IDs) · C-01 §4 canonical |

### Next phase
Depth, not breadth: the apps are live but **read-only** (sample data). Turning any into a real
product needs its **backend service** (`<app>-service` in tec-core-backend) + a real feature +
real Pi flow — one at a time, gated by dependencies + (for financial apps) legal.

---

## SESSION 17 — ECOSYSTEM STATE SNAPSHOT (5 July 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified]** (repos) + **[Runtime Verified]** where noted.
> This block is the authoritative current-state header. The Session 15/16 blocks below remain
> as historical record; where an older row disagrees with this snapshot, **this snapshot wins**.

### Knowledge Base
| Field | Value |
|-------|-------|
| Version | **v3.9.0** (supersedes the v3.6.2 stamp in the history rows below) |
| Docs | **104** C-docs · registry **100% coverage** |
| CI gates | **13** (10 structural + Runtime-Governance: portal-readiness · runtime-evidence · slo-definitions) |
| Newest law | **C-123** Pi Browser Session & Cookie Spec (TIER 11 — Runtime Operational Law) |

### Apps — live vs built vs scaffold (source of truth for IDs = C-01 §4)
| App | State | Pi App ID | Notes |
|-----|-------|-----------|-------|
| Hub (tec-app) | 🟢 **live** | `tec-app-923b947851f9dfe1` | cookieless session architecture (C-123) Runtime Verified |
| Commerce | 🟢 **live** | `commerce-app-68aa99081fc1897a` | |
| Ecommerce | 🟢 **live** | `ecommerce-app-71ca4d3e462eaf54` | |
| Assets | 🟢 **live** | `assets-app-af2fb490e7b03db7` | |
| Analytics | 🟢 **live** | `analytics-822d9810de66bc84` | registered 3 Jul; Merchant Pro payment (Mode 1+2) Runtime Verified |
| **Life** | 🟡 **built (Phase 0), not yet deployed** | `life-app-c468e9eb5bf115fa` | from template; Goals/Preferences + Activity slices; charter C-106 |
| **Connection** | 🟡 **built end-to-end, not yet deployed** | (Portal pending) | Follow + Trust **[Runtime Verified 4 Jul]** + Presence + Notifications + Collaboration + Connection Pro; charter C-107 §13 |
| **Zone** | ⚪ **V0 scaffold** | (Portal pending) | `tec-zone` from template; `PI_API_KEY_ZONE` wired in payment-service; frontend pending; charter C-120 §5 |

> **5 apps live on Mainnet** (was 4). Life + Connection are built but await deploy + Pi Portal
> registration. Zone is a Portal-ready scaffold. The 24-app rollout registry
> (`manifests/app-rollout-registry.yaml`) is the tracker; C-01 §4 is authoritative for registered IDs.

### Backend — payment-service per-app Pi keys
`PI_KEY_SOURCES` now covers `ecommerce · commerce · assets · analytics · life · connection · zone`
(`env.ts`). A payment made under an app's own Pi App ID is approved with `PI_API_KEY_<SOURCE>`;
missing key for a listed source = **loud error** (the Analytics approve→502 lesson, C-12 §11).

### Connection architecture decision-of-record (C-107 §13)
Two-layer: durable relationship graph (follow / trust / collections / notifications) in
**tec-identity-service** → extract to a dedicated `tec-connection-service` at ~5k–10k users;
live presence layer on **tec-realtime-service**. Trust edges are formed from **`order.paid.v1`**
(two-party buyer↔seller), never `payment.completed.v1` (single-party U2A). Buyer/identity is
always derived from the session (JWT), never the request body (P6).

---

## SESSION 16 — HUB LOGIN LOOP IN PI BROWSER (root-caused & fixed) (29 June 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified] + [Runtime Verified]** (Vercel logs + production retest)

**Symptom (production, `hub.tecosystem.app`, Pi Browser only):** "Sign in with Pi"
succeeded on the backend but the Hub never opened — it looped login → `/hub` → `/`
every few seconds. Standalone Chrome was fine.

**Two independent causes (one masked the other):**

1. **Stuck incomplete Pi payment (red herring, now cleared).** An approved +
   on-chain-verified but **not** `developer_completed` U2A payment
   (`BgWyxcJfkmeuBLwcYR2ILwBZV4XT`, `source:ecommerce`) surfaced on every
   `onIncompletePaymentFound`. `resolve-incomplete` returned **409** (terminal
   locally) so it never cleared on Pi → noise in the logs. **Resolved** by calling
   Pi `…/complete` with the txid (cancel is invalid for U2A). Not the real blocker.

2. **THE real blocker — Pi Browser cookie handling.** The frontend decided "am I
   logged in?" by reading `tec_user` from `document.cookie`. Pi Browser (a) **drops
   `sameSite=None` cookies** and (b) can **hide a stored cookie from client JS** even
   while sending it to the server (proof: `/hub` returned **304**, i.e. middleware
   *saw* `tec_access_token`, yet client `getStoredUser()` was null → `usePiAuth`
   `isAuthenticated=false` → `router.replace('/')`).

**Fix (Hub repo, merged to `main` via #56 + #58):**

| Change | File(s) | Why |
|--------|---------|-----|
| `sameSite` `none` → **`lax`** on session cookies | `api/auth/{pi-login,refresh,sso-callback,logout-from-sso}`, `middleware.ts` | Pi Browser keeps `lax`; first-party Hub cookies sent on the top-level nav to `/hub`. SSO unaffected (token rides the URL, not a cross-domain cookie). |
| New **`GET /api/auth/me`** | `api/auth/me/route.ts` | Server resolves the session from the request cookie (always readable server-side) → returns the user; fail-closed 401. |
| `usePiAuth` server fallback + `authSettledRef` | `lib-client/hooks/usePiAuth.ts` | When the client cookie read returns null, ask `/api/auth/me`; stay `isLoading` until it resolves so `/hub` shows a skeleton instead of bouncing. Ref stops a late `/api/auth/me` clobbering a succeeded login. |
| Tests aligned (`sameSite='lax'`, async `usePiAuth`) + race-guard test | `__tests__/auth/refresh-cookie.test.ts`, `__tests__/usePiAuth.test.ts` | CI green on `main`. |

**Deployment lesson:** production `hub.tecosystem.app` builds from **`main`**, not the
`claude/*` working branch — fixes on the branch had no effect until merged. Confirm the
target branch before "it didn't work" investigations.

**RESOLVED — wallet/assets/notifications blank after login = expired access token, no
client refresh.** Truth State: **[Runtime Verified]** (temp `/api/admin/auth-debug`).

The first hypothesis (JWT_SECRET mismatch) was **WRONG** — `JWT_SECRET` is correct.
A temporary diagnostic endpoint proved it: `verify: FAIL`, `verifyError:
**ERR_JWT_EXPIRED**`, `exp - iat = 3600` → **the access token lives ~1 hour**
(auth-service `JWT_EXPIRES_IN`). Once it expires, every authenticated BFF call hit
`createHandler.extractContext` → `jwtVerify` → `ERR_JWT_EXPIRED` → 401 `UNAUTHORIZED`,
and `useHubData` used a plain `fetch` with **no refresh**, so the dashboard data went
blank (`balance` stuck at `—`). The wallet route's own `TOKEN_EXPIRED`→refresh path never
ran because `extractContext` rejects the expired token *first*.

**Full root cause (proven via auth-debug, `backendRefresh` field):** TWO things compound:
1. **Access token lives ~1h** (`JWT_EXPIRES_IN=3600` in tec-auth-service) → expires fast.
2. **Refresh tokens are single-use (rotation)** — backend returns `401 "Refresh token
   already used"` on any reuse. In Pi Browser the rotated `tec_refresh_token` set via the
   refresh **XHR response** does not reliably persist, so the next refresh resends the
   already-consumed token → 401 → dead session (expired access + used refresh).

**Regression I caused + reverted:** `#60` switched `useHubData` to `fetchWithAuth`, whose
`refreshAccessToken` calls `logout()` on refresh failure. With refresh 401ing, that became
a **logout→re-SSO thrash loop** in production. **#62 reverted** `useHubData` to plain
`fetch` (a 401 now just blanks the value, no session thrash).

**Fixes:**
- *Immediate:* fresh logout→login issues a clean token pair → wallet loads.
- *Durable (ops, recommended):* raise `JWT_EXPIRES_IN` in tec-auth-service (Railway) from
  `3600` to e.g. `604800` (7d, matching the refresh token) so the access token outlives a
  normal session and the fragile Pi-Browser refresh-rotation is rarely exercised.
- *Engineering fix (SHIPPED — tec-app #63):* **server-side refresh in `createHandler`.**
  Every `/api/bff/*` route now recognizes `ERR_JWT_EXPIRED` as recoverable: it refreshes at
  the gateway (**single-flight per refresh-token value** — the Hub's parallel BFF calls
  would otherwise burn the single-use token), verifies the new token, completes the request
  with it, and sets the rotated cookies (`tec_access_token` 24h lax, `tec_refresh_token` 7d
  httpOnly lax) on EVERY response path. Cookie rotation rides a normal same-origin response
  — the path Pi Browser persists reliably — instead of a client-XHR Set-Cookie. No refresh
  possible → 401 TOKEN_EXPIRED, fail closed, **never logout()**. The hourly hub/wallet
  death self-heals without any browser-side refresh logic. **Lesson:**
  `auth-debug.backendRefresh` surfaces the backend's real refusal reason — use it, don't
  guess; and token rotation must complete server-side when the client is Pi Browser.
- *Login-establishment fix (SHIPPED — tec-app #64):* the loop kept returning because
  `pi-login` set session cookies on an **XHR response**, which Pi Browser drops
  non-deterministically. Login now finishes on a **top-level navigation**: `pi-login`
  mints a one-time SSO-style token (jti, 5m) → `PiPaymentButton` navigates to
  `/api/auth/sso-callback?token=…&redirect=/hub` → cookies (incl. `tec_refresh_token`,
  new) are set on the navigation response — the same mechanism that already worked for
  Assets/Commerce SSO. Also: client `refreshAccessToken` no longer `logout()`s on failure
  (that was the `refresh 401 → logout 200` production loop), and `/api/auth/sso` forwards
  rotated refresh cookies instead of burning the single-use token.
  **RULE (Pi Browser cookie law):** session cookies may ONLY be established/rotated on
  top-level navigation responses or same-origin BFF responses — never rely on XHR
  Set-Cookie from a fetch() the client discards.
- *Final gap + fix (SHIPPED — tec-app #65):* runtime logs proved Pi Browser ALSO drops
  `Set-Cookie` on **3xx redirect responses** (`sso-callback 307` carried the cookies →
  `/hub` arrived cookie-less → middleware bounce → loop). `sso-callback` now returns a
  **200 HTML landing page**: cookies ride the 200; its script **verifies the session via
  `/api/auth/me` BEFORE navigating**, falls back to `document.cookie` for the non-httpOnly
  cookies and re-verifies; hard failure lands on `/?login=failed`. Navigation into the app
  happens only after server-confirmed session → loop structurally impossible.
  **Pi Browser cookie law (amended):** cookies persist reliably ONLY on **plain 200
  responses** — not XHR, not 3xx redirects.
- *CORRECTION + final fix (SHIPPED — tec-app #66):* the #65 landing page's double
  `/api/auth/me` check 401'd with ZERO cookies arriving (even `document.cookie` writes
  ignored) → the app was running in an **embedded Pi Browser context with third-party
  cookie semantics**, where `lax` cookies are never stored/sent and ONLY
  `sameSite=none + secure` works. The `lax` migration (#56) — based on a misleading
  in-code comment ("Pi Browser drops None") — was the regression that broke the
  previously-working login. #66 restores **`none+secure` everywhere** (middleware,
  pi-login, refresh, sso-callback + JS fallback, logout-from-sso, BFF refresh) while
  keeping all structural fixes (#63 server-side refresh, #64 no destructive logout +
  rotated-cookie forwarding, #65 server-verified 200 HTML landing).
  **FINAL COOKIE LAW: `sameSite=none + secure`, established/rotated only on 200
  responses, entry to protected pages only after server-verified session. Never
  downgrade to `lax`.**
- *Re-login fix (SHIPPED — tec-app #67):* first login worked but re-login after logout
  failed → embedded contexts under Chrome's 3P-cookie phaseout block even `none` unless
  **`Partitioned` (CHIPS)**; also logout's clearing cookies had mismatched attributes
  (silently failed to delete). All session cookies now `none+secure+Partitioned`; deletion
  attributes match creation; landing page gained a delayed retry + `[landing-report]`
  diagnostics.
- *Cookie-dependence eliminated (SHIPPED — tec-app #69, C-123 §7):* even after #67,
  identical code worked in the morning and failed at night — Pi Browser contexts
  (top-level vs embedded) keep **separate cookie jars**, so cookie behavior is
  non-deterministic by construction. Final architecture: in-memory session
  (`tec-session.ts`) + `Authorization: Bearer` on BFF calls (createHandler verifies
  header OR cookie, same JWT_SECRET) + **silent Pi re-auth** chain in `usePiAuth`
  (memory → cookie → /api/auth/me → one silent Pi auth per load) + `/hub` shell always
  renders (middleware no longer cookie-checks it; landing proceeds INTO the app on
  cookie refusal). Cookies = accelerator, never a requirement. ADR-001 + P6 intact.
  CI lock: "/hub renders cookieless" test. **Runtime Verified in production.**
- *Hub LIVE NOW (SHIPPED — tec-app #68):* Analytics flipped `coming_soon → live` in the
  domain registry (`analytics.tecosystem.app/app`); LIVE NOW now lists ALL live apps —
  Ecommerce + Analytics + Assets + Commerce (visibility ≠ authorization; KYC/role gating
  stays in each app/service, P6). External tiles enter via `/api/auth/sso?target=…`.
- *Analytics app hardened (SHIPPED — tec-analytics #4):* C-123 propagated (200 landing +
  verified entry + jti guard + none/secure/Partitioned + matching-attribute logout + new
  `/api/auth/me` + previously-MISSING `/api/auth/logout`), NEW-A cleanup (hardcoded
  Railway URL removed from client bundle; `.env.example` server-first). SSO Hub→Analytics
  **Runtime Verified** (sso-callback 200 → me 200 → /app 200). 29/29 tests.
- ✅ **SESSION 16 CLOSED — Runtime Verified end-to-end:** login ✓ · logout → re-login ✓ ·
  wallet (2,084 π rendered) ✓ · Hub→Analytics SSO ✓ · hub opens in every Pi Browser
  context (cookieless architecture) ✓.
- **OPEN (ops — user):** Analytics Vercel env (`API_GATEWAY_URL`/`SSO_SECRET`/`JWT_SECRET`
  → fixes the events 503) · Analytics Pi Portal registration (App ID TBD) · admin role SQL
  (`UPDATE users SET role='admin' WHERE pi_username='yas55eR82';` + re-login) · optional
  `JWT_EXPIRES_IN` raise · delete temp diagnostics (`/api/admin/auth-debug`,
  `/api/auth/landing-report`) once stable.
- ✅ **C-123 propagation COMPLETE (July 2026):** ecommerce #48 · assets #36 · commerce #46 ·
  **template-base #16** (future apps born compliant) — see C-123 §6 propagation table.
- ✅ **§7 hardening (tec-app #70):** silent re-auth on BFF 401 (single-flight + cooldown) —
  the 1h in-memory expiry self-heals mid-session.
  **The entire incident is codified as `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md`
  (TIER 11 — Runtime Operational Law): the 3 cookie laws, the LOCKED cookie contract,
  verified-entry login architecture, server-side refresh, diagnostic playbook, and the
  PR-by-PR incident ledger. Any future change to cookies/login/refresh MUST cite C-123.**

---

## SCORE

| المصدر | Score |
|--------|-------|
| Self | ~8.5/10 |
| External (قبل Session 4 fixes) | 7.1/10 avg (Ecom 5.5 / Hub 6.5 / Commerce 7.0 / Assets 7.5) |
| External (Session 3 audit) | 7.65/10 |
| External (متوقع بعد الـ fixes) | **~8.5–9.0/10** |
| Architectural Review (Session 8) | **9.1/10 overall** (Knowledge Architecture: 9.5+/10) |
| Engineering Assessment (Session 9) | KB reconciliation: C-57 ✅ + C-40 ✅ + C-41 ✅ + C-93→C-99 Institutional Loop |
| **Code Verified Inspection (Session 9)** | **9.3/10 overall** — Architecture 8.7 / Security 8.9 / Gateway **8.6** / Runtime Visibility **7.8** / Observability **8.2** / KB 9.1 / Constitutional Governance **9.8** |
| **ADR-008 — Runtime Observability Architecture** | **✅** — ACCEPTED · June 2026 · ADR-008a/b/c/d: Health Runtime + Redis + Evidence Endpoint + Timeout |
| **P1 Fixes Applied (Session 10)** | **✅** — NEW-K/L/N/O all VERIFIED · C-81 Implementation Guide applied · PRI 8.22 → 8.8+/10 |
| **Port Conflict Resolved** | **✅** — Canonical: Gateway `:3000` / Services `:5001–5011` (C-20 Code Verified) — README + memory updated |
| **Truth State Rollout** | **✅** — Added to C-00, C-10, C-12, C-20, C-64 (5 core docs) |
| **Skills README** | **✅** — Updated 13→16 (added charter-advisor, mcp-orchestrator, observability) |
| **v3.5.0 — Authority Automation** | **✅** — 28→66 docs (33%→79% adoption) · C-116 AHV Constitution · CDG manifest + AHV engine v1 + Impact Analysis · LANGUAGE_POLICY + 90-Day Roadmap |
| **v3.6.0 — Registry Integrity** | **✅** — Registry auto-generated (96/96 coverage) · R-SEMANTIC-001 catches drift · C-117 Registry Integrity Constitution · check-registry-integrity.sh v2.0 · 28 rules across 7 categories |
| **Registry Semantic Accuracy** | **✅** — Fixed v1.0 mislabeling (C-93/94/95 institutional_role now matches file H1) |
| **Coverage 19%→100%** | **✅** — All 96 C-docs now registered (was 18/96) |
| **CI Gates** | **9 total** — 5 original + 3 from v3.5.0 + check-registry-integrity.sh (BLOCKING) |
| **v3.6.1 — VAM Restoration** | **✅** — VAM restored from v3.5.0 + check-vam-compliance.sh BLOCKING CI gate added |
| **v3.6.2 — DAG-Guaranteed + C-118** | **✅** — 0 cycles · 0 inversions · 0 errors across all 10 CI gates · C-118 Dependency Propagation Constitution · propagate-dependency.py + regenerate-cdg.py |
| **CI Gates** | **10 total** (was 9) — added check-vam-compliance.sh |
| **Knowledge Base Version** | **v3.9.0** (current — see Session 17 snapshot) — 104 docs · 100% registry coverage · 13 CI gates pass · 0 violations. *(v3.6.2 was the Session 12.2 milestone.)* |
| **Session 13 — ADR-007 Foreign Session Fix** | **✅** — `__TEC_PI_FOREIGN_SESSION` defense-in-depth added to ALL 5 Ecommerce payment files (pi-payment.ts + page.tsx + product/[id] + store/[id] + CartDrawer) — Hub redirect on foreign session |
| **Tec-App (Hub) Test Coverage** | **95.5%** — 2026 tests passing |
| **Session 14 — Payment Unification (ADR-009)** | **✅** — root-caused & fixed the post-audit payment breakage across all repos (see block below) |
| الهدف | **9.5/10** |

---

## SESSION 15 — ANALYTICS APP (build-next) (27 June 2026) ✅

First app built from the 24-app rollout registry (`build-next` track). The standalone
`tec-analytics` repo (`analytics.tecosystem.app`) was a pristine `tec-template-base`
clone; turned it into a real, compliant Analytics app on branch `claude/tec-repos-review-ht2n8s`.

| Phase | Work | Detail |
|-------|------|--------|
| **0 — customize** | template → tec-analytics | name · domain `analytics.tecosystem.app` · APP_SOURCE `analytics` · SSO audiences · legal pages · Analytics-specific CLAUDE.md/README (data-ownership C-105 §4, merchant-isolation §6, eventual-consistency) |
| **1 — dashboard MVP** | platform intelligence UI | BFF `/api/bff/analytics/{overview,payments,users,events}` → `tec-analytics-service` via gateway (Bearer + `x-internal-key`, fail-closed); `/app` dashboard (overview cards + 30d payment volume + inline bar chart + recent events) with loading/error/retry (C-96); typed client hooks |
| **2 — parity** | Drift Detection CI gate | ADR-009 · C-12 §11 · ADR-007 — parity with the 4 live apps |

**Backend contract verified (code):** `tec-analytics-service` exposes `GET /analytics/{overview,payments,users,events}`, auth via Bearer **OR** `x-internal-key`; gateway rewrites `^/api/analytics → /analytics`.

**Honest gap (documented in C-105 §11a):** `tec-analytics-service` aggregates are **platform-level** — `DailyMetric` keyed by date only, no `merchantId`. Merchant isolation (C-105 §6) needs a **service-side** schema/aggregation change first; not faked client-side. Dashboard is platform/admin-only until then.

**Verified:** typecheck 0 · 24/24 tests (+6) · build clean · lint 0 errors · Drift + payment-policy gates 0 violations. KB: C-105 §11a implementation-status added (charter stays `[Planned]` — pre-deploy); validate-charters / truth-framework / links / structure / c57-index all green.

**Constitutional (C-122 — NEW):** elevated Analytics to its Tier-1 runtime identity, mirroring the Zone precedent (Zone has C-120 runtime charter; Analytics had only the C-105 app charter). **C-122 Analytics Constitutional Runtime Charter** = Intelligence Runtime / **Reality Infrastructure** ("what is happening?"), the **Reality↔Trust duality** with Zone, the **§5 disclosure boundary** (aggregate-everything / expose-only own|de-identified|sovereign — P6), **engine-vs-surface** ownership (Analytics owns the engine, each app owns its surface — preserves C-119 Rule 1), and **operational(raw) vs institutional(Zone-verified)** input layers. C-105 reconciled → product/BI-surface charter that defers to C-122. Registry rebuilt (102→103, 100% coverage, tier-1); C-57 TIER 10 → C-119→C-122. Truth State `[Future Vision]` (vision, not runtime).

**NEXT for Analytics:** deploy (Vercel) + register Pi App ID (Portal) → then flip rollout-registry `to-build → live` + C-105 → `[Current]`; service-side merchant scoping for §6.

---

## SESSION 14 — PAYMENT UNIFICATION (20 June 2026) ✅

Root cause of the platform-wide payment failures: a hardening audit added a **divergent BFF stack** + a **CSRF gate on payment routes** that broke every app. Fixed end-to-end:

| Fix | Detail | Repo / PR |
|-----|--------|-----------|
| **ADR-009 Unified Payment Contract** | one contract in `@yasser172/tec-sdk` `contracts/payment.ts` — `amount: number`, `/api/payment/*`, `x-internal-key` | TEC-SDK #8 ✅ merged · C-64 ADR-009 |
| **Hub amount=number** | Mode-1 create sent `String(amount)` → backend wants number | Tec-App #37 ✅ merged |
| **CSRF Origin fallback** | the audit's cookie-only double-submit 403'd every payment in Pi Browser (drops `sameSite=None`). Middleware now accepts double-submit **OR** first-party Origin | all 4 apps ✅ merged |
| **Assets mint unified** | mint used a divergent client → legacy approve hardcoded `amount:1` (DB ≠ charge). Now canonical client | Tec-Assets #22/#24 ✅ merged |
| **Token-refresh on resolve/cancel** | expired token left payments stuck (`TOKEN_EXPIRED`). `gatewayPost()` refreshes once | Tec-App #37 ✅ merged |
| **Reconciliation = Pi source-of-truth** | cron no longer blind-fails; asks Pi → complete/cancel/skip. Auto-clears stuck payments hourly + `/api/admin/reconcile` on-demand | tec-core-backend #83 ✅ merged |
| **CI policy guard** | every app's CI fails on `x-service-secret` / `SERVICE_SECRET` / `z.string()` amount | all 4 apps ✅ |
| **tec-ui test fix** | added `@testing-library/dom` (v16 peer) — 3 test files were failing | tec-ui ✅ |
| **Payment runbook** | `tec-app/docs/PAYMENT_SYSTEM.md` + C-12 §11 — how payments work + anti-regression guide | Tec-App + KB #20 |

### Session 14.3 — Route-level CSRF hotfix + permanent guard (21 June 2026) ✅
A second, deeper instance of the CSRF bug surfaced: even after the **middleware** was fixed (double-submit OR Origin), some **BFF routes still did their OWN strict double-submit CSRF check** — a duplicate that 403'd legit Mode-2 payments in Pi Browser (dropped `sameSite=None` cookie). Hub→app (Mode 1) worked (routes not called); standalone (Mode 2) failed.

| Fix | Detail | Repo / PR |
|-----|--------|-----------|
| **ecommerce payment + orders CSRF removed** | `payment/create`/`approve`/`complete` **and** `orders` had the duplicate check → standalone payment **and order creation** 403'd. Removed; middleware is sole CSRF authority | Tec-Ecommerce #38→#39 ✅ merged (payment-verified) |
| **Hub payment/create CSRF removed** | lenient variant (Hub kept working) but same anti-pattern → removed for consistency | Tec-App #40 ✅ merged |
| **Permanent CI guard** | every app's payment-policy CI now **fails on any route-level CSRF check** (`csrfCookie !== csrfHeader` / `CSRF validation failed` / `CSRF token mismatch` under `src/app/api`) — can't regress | all 4 apps (tec-app #41 · ecommerce #40 · assets #27 · commerce #36) |
| **Lesson documented** | C-12 §11 anti-regression table + rules updated (CSRF = middleware-only, P2) | KB |

> **Root lesson (P2):** CSRF must be enforced in exactly ONE layer — the middleware. A route may *forward* `x-csrf-token` downstream, but must **never validate** it. Commerce/Assets had no route check and never broke.

### Session 14.4 — Template completeness + package CI parity (21 June 2026) ✅
Made `tec-template-base` a Portal-ready golden reference and fixed the shared CSRF bug at the package level.

| Work | Detail | Repo / PR |
|------|--------|-----------|
| **Template completed** | full skeleton: payment BFF (create/approve/complete/resolve-incomplete, ADR-009, no route CSRF) · SSO callback (open-redirect-safe) + refresh · `pi-payment.ts` (ADR-007 dual-mode + isHubNavigation + redirectToHubPayment) · `/privacy` + `/terms` · design tokens · example `/app` buy page · payment tests · `.gitignore` · `eslint.config.mjs` · CI payment+CSRF policy · full CLAUDE.md + new-app checklist | tec-template-base #3 ✅ |
| **tec-auth CSRF fix** | `createAuthMiddleware` did pure double-submit → 403 in Pi Browser. Now double-submit **OR** first-party Origin (`trustedOriginSuffix`, default `.tecosystem.app`) + exported `isTrustedCsrf()`. +13 tests, 95%/93.5%/100%. v1.0.0→1.1.0 | tec-auth #5 ✅ |
| **tec-auth CI** | was 1 misnamed job → real `ci.yml` (typecheck/test/build) + `codeql.yml` + real publish-on-release; coverage gate 60→80 | tec-auth #5 ✅ |
| **tec-ui CI** | added `codeql.yml` (only gap) + coverage regression floor (72/62/68/75) | tec-ui #13 ✅ |
| **tec-sdk** | audited — already complete (ci test+build+coverage · codeql · real version-checked publish). No change | — |

> **Lesson:** the template relied on the package middleware that carried the production CSRF bug — a new app would have shipped broken. Template is now self-contained + correct, and the package is fixed too (defence in depth). KB: 10/10 gates green; registry 99/99 (100%).

### Session 14.8 — Production incident + Hub reliability fixes (25 June 2026) ✅
Live Hub testing surfaced a cluster of bugs. Two distinct things were happening: (1) a **transient** Railway infra incident (declared; 23/24 online — recovered), and (2) a **recurring** gateway defect (**NEW-U**) that kept re-triggering the "Backend Offline" banner *after* the infra recovered. All seven bugs below are real and now fixed; runtime evidence: `runtime-evidence/ev-2026-06-22-010.yaml` (infra incident + the BFF-contract bugs) and `runtime-evidence/ev-2026-06-25-011.yaml` (NEW-U gateway saturation, runtime-verified from HTTP logs).

| ID | Symptom | Root cause | Fix | PR |
|----|---------|-----------|-----|-----|
| **NEW-P** | Hub wallet → "Something went wrong" (full ErrorBoundary) | `/api/bff/wallet/balance` returns `balance` as a **string** (ADR-009 string-in-API); page called `balance.toFixed()` → throw in render | coerce to number at the `useWallet` boundary (balance + fallback tx + realtime) | tec-app #45 |
| **NEW-Q** | False "Backend Offline" banner during latency blips | double 5s timeout (client+BFF) + **no failure threshold** (1 fail → offline) | client→BFF 12s · BFF→gateway 10s · `failureThreshold=2` (consecutive) — kept honest, not blind (C-96) | tec-app #46 |
| **NEW-R** | `/api/notification/unread-count` + `/read` → 404 (repeated) | BFF called endpoints the service doesn't expose | use base `GET /api/notification` (returns unreadCount) + `:id/read` / `read-all` | tec-app #46 |
| **NEW-S** | `PATCH /notifications/:id/read` → 400 | `Content-Type: application/json` sent with **empty body** → Fastify rejects (self-inflicted by NEW-R) | drop Content-Type on bodyless PATCH | tec-app #47 |
| **NEW-T** | `/api/bff/realtime` → **500** spam (~119 err/30min in Vercel logs) + WS reconnect loops | route **threw** when `REALTIME_URL` unset; realtime is OPTIONAL | return `{enabled:false,url:null}` 200; hooks skip cleanly when url null (C-96: no phantom failures for an off feature) | tec-app #48 |
| **Gateway timeout** | one slow upstream hangs requests 30s → cascade | gateway `proxyTimeout` default **30s** (KB NEW-L claimed 10s — drift) | default **30s → 15s** (fail-fast; still configurable via `PROXY_TIMEOUT`) | tec-core-backend #87 |
| **NEW-U** | recurring **`/health → 499`** bursts + **"Backend Offline"** banner | proxy opened a **fresh TCP+TLS connection per request**; a page-load fan-out of ~15-20 concurrent calls → ~20 simultaneous **TLS handshakes** → CPU 0→**1.5 vCPU** → single-thread event-loop saturates → even sync `/health` starves → 499 (NOT OOM; memory ~100MB) | shared **keepAlive** http/https Agent → reuse warm TCP+TLS; `maxSockets` (env `PROXY_MAX_SOCKETS`, default 64) bounds the burst | tec-core-backend #88 |

> ⚠️ **SUPERSEDED by §14.11 (26 Jun):** this attributed the recurring freeze to **NEW-U** (keep-alive / TLS-handshake storm). **That was wrong** — the freeze recurred after NEW-U deployed. The true root cause is **NEW-V** (the gateway's Redis dependency on the request path; see §14.11 + `ev-2026-06-26-012`). NEW-U remains a valid perf improvement, just not the fix. *(Original text kept below for the audit trail.)*
>
> ~~**Root-cause correction (runtime-verified):** the **recurring** Backend-Offline banner was the gateway connection-pool defect **NEW-U**, proven from Railway HTTP Logs (02:12:04 `/health` 200/4ms → 02:12:13 `/health` 499/4s) + the CPU→1.5 vCPU spike. Evidence: `ev-2026-06-25-011`. The June Railway incident (`ev-2026-06-22-010`) was a separate transient outage.~~

**Ops fix (no code):** the Vercel **Supabase integration** (preview-branch provisioning) was attached to the **tec-app** project but only **Analytics** uses Supabase — it failed provisioning and red-X'd Hub preview deploys. Disconnected from tec-app (Hub uses Railway `DATABASE_URL`; verified zero Supabase usage in code). Check the other 3 apps too.

> **Lesson:** the BFF↔service contract bugs (NEW-P/Q/R/S/T) are **string vs number · wrong paths · Content-Type/body · timeout alignment · optional-feature-as-500** — Drift-Detection candidates. **NEW-U is a different class: a runtime/resource defect** (per-request TLS handshakes) invisible to any static gate — only the HTTP-log + CPU evidence revealed it. This is exactly why the Runtime Governance Layer (C-96 evidence) exists: a static-only platform would never have caught it.

### Session 14.13 — "Backend Offline" durable fix: event-loop resilience (NEW-W) (26 June 2026) ✅
The recurring "Backend Offline" returned **again** after NEW-V. Root cause finally pinned by reading the gateway code end-to-end (not screenshots): **event-loop saturation on the single-threaded gateway.** The repeated signal across every incident — the trivial, dependency-free `/health` going from 2ms → 9s/499 while CPU hits 1.5 vCPU — can only mean a blocked event loop. **It is NOT Redis** (the gateway creates no Redis client at all — `createClient` is never called) and **NOT tec-sdk.**

| Prior attempt | Verdict |
|---------------|---------|
| NEW-U (keep-alive) | trigger-only — freeze recurred |
| NEW-V (in-memory rate-limit) | **claim "true root cause" was WRONG** — recurred; no Redis client exists. Kept as correct hardening. |

**NEW-W (tec-core-backend #93) — durable fix, 4 structural changes:** (1) `/health`+`/ready` registered as the FIRST routes, isolated from cache/JWT/rate-limit/proxy → liveness never fails under load (kills the FALSE offline); (2) per-request proxy logging OFF by default + prod log levels exclude `debug` → removes synchronous stdout backpressure that blocks the loop under the polling flood; (3) hard `proxyReq.setTimeout(...).destroy()` → slow upstream (pi-login hung 24s vs 15s) can't hold connections; (4) event-loop-lag **load shedding** → fast 503 above `MAX_EVENT_LOOP_LAG_MS` instead of snowballing. **Amplifier fix (tec-app #53):** `/api/bff/realtime` request storm from unstable React callback deps in `useWalletRealtime`/`useRealtimeNotifications` (effect re-ran every render) → callbacks moved to refs.

**Evidence:** `runtime-evidence/ev-2026-06-26-013.yaml` (supersedes ev-012, which is flagged `superseded_by` + kept unaltered for an honest audit trail). **Lesson:** diagnosing from symptom screenshots without the gateway **Deploy Logs** produced two confident wrong calls; the durable fix targets the *architectural fragility* so the platform degrades gracefully (503 + live `/health`) regardless of which trigger fires — verifiable post-deploy on Railway.

### Session 14.12 — Economic OS Model integrated (C-119→C-121, TIER 10) (26 June 2026) ✅
Integrated three new constitutional vision-layer docs into the KB as **TIER 10 — Economic Operating System Model**.

| Doc | Role | Truth State |
|-----|------|-------------|
| **C-119** | Economic Operating System Model — TEC = 3-tier economic OS (Tier 1 Constitutional Runtimes: Hub/Zone/Analytics/System · Tier 2 User Runtimes · Tier 3 Economic Products) | `[Future Vision]` / `[Draft]` |
| **C-120** | Zone Constitutional Runtime Charter — Zone = Verification Runtime ("What can be trusted?"), `zone.pi` strategic asset, V1→V4 | `[Future Vision]` / `[Draft]` |
| **C-121** | Institutional Knowledge Pipeline — sequential chain Hub → Life → Connection → Zone → Analytics → Nexus → TEC AI | `[Future Vision]` / `[Draft]` |

**Integration engineering:**
- `scripts/build-asset-registry.py` — added range `119–121 → tier-1-institutional-intelligence` (without this the docs would default to `tier-2-experimental` — wrong for constitutional docs). Registry rebuilt: **102 assets, 100% coverage, 0 errors**.
- **C-30 partial supersession:** C-119 supersedes only C-30's *build sequence*; the app catalogue stays valid. Documented as a banner in C-30 (not a deletion).
- Normalized headers to schema: C-120 `[Future Vision — V1 Planned]` → `[Future Vision]`; all three `[Unverified]` → `[Assumed]`. Added a **Related Documents** footer to C-120.
- C-57 master index: added TIER 10 table + ranges + counter (C-00 → C-121).
- **All 13 KB CI gates pass** (registry-integrity, truth-framework, c57-index, authority-consistency, VAM, runtime-evidence, SLO, links, structure, portal-readiness, knowledge-gaps — 0 errors).

### Session 14.11 — TRUE root cause of "Backend Offline" + polish finish (26 June 2026) ✅
The recurring gateway freeze **kept recurring after NEW-U (keep-alive) shipped** — so keep-alive was **NOT** the root cause (correcting §14.8). Decisive evidence (Railway Deploy Logs): a flood of `ERROR Error: The client is offline` on every Redis blip, **plus the rate-limit-EXEMPT `/health` itself 499'ing** — only possible if the **event loop is saturated**, not if the limiter were merely blocking.

| ID | True cause | Fix | PR |
|----|-----------|-----|-----|
| **NEW-V** | gateway used **Redis on the request path** (rate-limit-redis). A Redis drop (Railway idle / restart) flooded "client is offline" rejections → event-loop saturation (CPU→1.5 vCPU) → every handler incl. `/health` 499s → "Backend Offline". The single entry point's liveness was tied to Redis. | **in-memory rate limiting** (MemoryStore) — zero Redis on the gateway hot path; a Redis outage can no longer freeze it | tec-core-backend #90 (partial: disableOfflineQueue+passOnStoreError — insufficient) → **#91** (complete) |

> **Correction to §14.8 / ev-2026-06-25-011:** those credited **NEW-U (keep-alive / TLS-handshake storm)** as the cause of the *recurring* Backend-Offline. Production proved otherwise — it recurred. NEW-U is a real perf win but **not** the freeze fix. The freeze fix is **NEW-V** (Redis-independence). Evidence: `runtime-evidence/ev-2026-06-26-012.yaml`. **Lesson:** when a fix "looks right" but the symptom recurs, the diagnosis was incomplete — keep `/health` (exempt path) as the canary; its freezing pointed at event-loop saturation, not the request handler.

**UI polish finish:** EVL **domain-tinted app tiles** (`lib/hub/appAccent.ts` — each Live-Now tile tinted by its EVL domain, keeps the brand emoji) — the "middle path" that supersedes §14.10's "app-launcher icons rejected" note (tinting ≠ mono-icon conversion). tec-app #52. **Data finding:** the `Dfgh`/`test` categories are **dynamically derived from products** (`page.tsx` `new Set(products.map(p=>p.category))`) → pure data cleanup (delete test products), not a code fix.

### Session 14.10 — Professional UI polish, platform-wide (26 June 2026) ✅
Live-screenshot-driven polish pass after EVL adoption. Fixed real UI defects + introduced a shared professional UI layer; verified live (deploy pipeline confirmed working — the "colors didn't change" was the subtle `#d4af37→#FBBF24` shift + browser cache, not a deploy failure).

| Work | Detail | Repo / PR |
|------|--------|-----------|
| **Shared UI primitives** | `Icon` (lucide-style inline SVG set, 18 glyphs, Pi-Browser-safe, currentColor) + `CountUp` (rAF easeOutCubic + thousands separator + prefers-reduced-motion) added to `@yasser172/tec-ui` **v2.1.0** (additive minor) | tec-ui #15 |
| **Hub flagship** | header overflow fix (`ECOSYSTEMAM`) · emoji chrome → Icon (nav/bell/AI-FAB) · balance + Pi-price `CountUp` · dual-tone EVL glow | tec-app #50/#51 |
| **Assets** | bottom-nav emoji → Icon (gem/cart/receipt/chart) · Portfolio Value `CountUp` (respects hideBalance) · tec-ui→2.1.0 | tec-assets #34 |
| **Commerce** | overview + bottom-nav + tab-pills + empty-state emoji → Icon · tec-ui→2.1.0 (chrome now 100% emoji-free) | tec-commerce #43/#44 |
| **Ecommerce** | ShopHeader nav + cart emoji → Icon · tec-ui→2.1.0 · **also fixed a real bug**: product cards showed the raw seller **UUID** as store name → clean "TEC Store" fallback | tec-ecommerce #46/#47 |

> **Decision (app-launcher icons):** the 24 ecosystem app tiles use *branded personality* emoji (VIP 👑, Titan ⚔️, Epic 🔥…). Mechanical conversion to mono line-icons was **rejected** — for branded launcher tiles it strips identity and isn't more professional. Correct path = **custom per-app icons/logos** (deferred design task), not a code sweep.
>
> **Remaining (deferred):** custom app-tile art · category-chip icons + purge of test categories (`Dfgh`/`test` — data cleanup, not code) · optional depth/motion on secondary cards · ESLint 10 flat-config migration (Dependabot, post-Portal).

### Session 14.9 — EVL adopted as live identity (26 June 2026) ✅
Governance decision: the **Economic Visual Language (C-83) color system** is now the live platform identity (was the legacy `#d4af37` gold set). Implemented in `@yasser172/tec-ui` **v2.0.0** — the color-token half of C-83 moves `[Planned] → [Current/Code-Verified]`.

| Work | Detail | Repo |
|------|--------|------|
| **tec-ui v2.0.0** | `TEC_COLORS`: gold `#d4af37→#FBBF24` · bg `#020205→#050816` · surface `#0d0d14→#0B1020` · +`surface2` + semantic `purple/green/cyan/red/blue` (C-83 §4–§5); state colors aligned; PaymentModal/StatusBadge de-hardcoded. Major bump (R5 coordinated breaking). 75 tests · typecheck 0 · build clean | tec-ui (v1.2.1→2.0.0) |
| **Skills synced** | `design/tec-design-system` + `design/ui-patterns` updated to the v2.0.0 tokens (code = SoT) | tec-knowledge-base |
| **C-83 reconciled** | color tokens marked adopted; shapes/motion/ESL/CSS-vars remain `[Planned]` | tec-knowledge-base |

> **Remaining (deferred, coordinated):** the 4 consumer apps re-skin by bumping `@yasser172/tec-ui` to `^2.0.0` — **no compile break** (only token values changed, no exports removed). Per R5, do the simultaneous app deploy **after Pi Portal submission** to avoid changing the identity mid-submission.

### Session 14.7 — Runtime Governance in-repo half complete (22 June 2026) ✅
Closes the doc↔runtime loop with two more KB gates (now **13** total).

| Work | Detail |
|------|--------|
| **Runtime Evidence schema** | `manifests/runtime-evidence-schema.yaml` + `evals/check-runtime-evidence.sh` (12th gate). Every evidence record (metric/health_snapshot/incident/slo_breach) is attributable to a `source` + `binds_to` a real C-doc → C-93 at VAM V-5. Behavior↔claim half. |
| **SLO Definitions** | `manifests/slo-definitions.yaml` + `evals/check-slo-definitions.sh` (13th gate). C-78 §2 targets made machine-readable; cross-checks every `slo_breach` references a defined SLO. Engineering's half of the Observability handoff. |
| **Template v2** | `tec-template-base`: health endpoint · PAL (PiRuntime + circuit breaker) · structured logger · Sentry-ready reportError · feature flags · coverage gate. Every new app is production-ready by default. |
| **24-app rollout registry** | `manifests/app-rollout-registry.yaml`: the 24 auction domains → 4 live + 20 to-build, with per-app checklist (repo→deploy→portal→smoke→5 users). 11 of 20 have KB blueprints; 9 need product definition. |

> **In-repo Runtime Governance is DONE.** Remaining is ops-only: Pi Portal submission + Observability stack (Prometheus/alerts → emit `slo_breach` into `runtime-evidence/`).
>
> **24-app scale (Core Team gate):** 4 live; 20 to build from Template v2. Per-app: repo→deploy→Pi Portal→≥5 users. Repo creation + deploy + Portal + users are ops/marketing (deferred). See `manifests/app-rollout-registry.yaml`.

### Session 14.6 — Runtime Governance Layer begins (21 June 2026) ✅
First in-repo work on the unanimous #1 gap (doc ↔ runtime). Authority: `audits/EXECUTION_PLAN_2026-06-21.md` (NEXT).

| Work | Detail | Repo / PR |
|------|--------|-----------|
| Truth reconciliation (Batch 1) | C-77 + C-91 stale figures (`~7.0–7.5`/`7.25` → ~9.2, P1=0); C-90 Security `[Draft]` → `[Governance Approved]` (registry now reads it); C-84/85/96 scope-boundary note; v9 `deliverables/` imported | KB |
| Commerce domain finalized | `commerce.tecosystem.app` confirmed in Pi Portal — aligned across C-01/C-02/C-101/C-92/C-10 | KB |
| **Portal Readiness Engine** | `evals/check-portal-readiness.sh` — **11th CI gate**. Auto pre-submission audit: App ID/domain consistency (C-01↔C-02↔RUNBOOK), no placeholders, PI_SANDBOX=false, Privacy/Terms, no open ENG/OPS items | KB |
| **C-96 dual-poller fix (NEW-K)** | `PlatformHealthContext` = single health poller; `BackendOfflineBanner` + `BackendStatus` now consumers; fixed BackendStatus's wrong-path bug. C-96 updated: NEW-K RESOLVED | tec-app + KB |
| **Drift Detection gate** | CI gate "Drift Detection — KB claims vs code" in **all 4 apps**: ADR-009 (amount:number) · C-12 §11 (CSRF middleware-only) · C-76/ADR-007 (every Mode-2 buy handler guarded with `isHubNavigation()`). Hub also: C-96 single-poller. Negative-tested | tec-app · ecommerce · assets · commerce |

> Runtime Governance progress: Portal-Readiness ✅ · dual-poller ✅ · Drift Detection ✅ (4 apps).
> Remaining NEXT: Runtime Evidence schema (item 8) → then Observability stack (infra/ops).

### Session 14.5 — P2 deferred-quality + P3 security (21 June 2026) ✅
P0 + P1 were already closed (Portal-ready). This batch cleared the deferred backlog.

**P2 — deferred quality (DONE):**
| Item | Detail | Repo / PR |
|------|--------|-----------|
| Sentry drift | Assets `@sentry/nextjs` v10 → v8 (APIs used are stable both) — typecheck 0 · 133 tests · build OK | tec-assets |
| vite plugin → devDeps | `@vitejs/plugin-react(-oxc)` moved out of prod deps | ecommerce · assets · commerce |
| realtime-service tests | 0 → **9 tests** (HealthController + RealtimeGateway: auth, disconnect, emit) | tec-core-backend |

**P3 — security / strategic (partial — the safe code part DONE):**
| Item | Status |
|------|--------|
| npm-audit triage + non-breaking fixes | ✅ `next` 15.5.12 → 15.5.19 (+ ws/form-data/engine.io) — **high 6 → 2** per app · all 4 apps |
| Lesson | broad `npm audit fix` reshuffled vite/rolldown → broke Hub vitest JSX parsing → use **package-scoped bumps** (next-only), not broad fix. Hub redone next-only (2009/2009 green) |
| npm-audit → blocking | ⏸️ NOT yet — residual high=2 (`@sentry`+`rollup` need v10 vs platform v8) + critical=1 (`happy-dom`, **test-only devDep**). Stays advisory |
| Publish tec-auth v1.1.0 + bump consumers | ⏸️ ops-gated (needs NPM_TOKEN + Release; publish workflow ready) |
| Migrate apps → package middleware (DRY) | ⏸️ deferred until v1.1.0 published (else apps pull old buggy 1.0.0 → re-break payments) |
| Observability SLOs → dashboards (C-78) | ⏸️ infra/ops |

> **P3 forward sequence:** merge PRs → cut a tec-auth Release (fires publish.yml) → bump the 4 apps + template to `@yasser172/tec-auth@^1.1.0` → optionally migrate inline middleware → package middleware.

**Project-wide tests (Session 14):** SDK 174 · Hub 2009 · Assets 133 · Commerce 209 · Ecommerce 75 · payment-service 143 · tec-auth 46 · tec-ui 75 · realtime 9 · KB 10/10 gates — **all green**.

**Operational requirement to clear stuck payments:** `PI_API_KEY` (Hub/tec-app key) + per-app keys set on `tec-payment-service` Railway → resolve/cancel/reconcile work automatically (login auto-resolve + hourly cron + on-demand).

### Re-Audit reconciliation (the 2026-06-19 audit was stale — verified against code)

| Prior finding | Verified status (Session 14) |
|---|---|
| P0-2 terminal-state bypass | ✅ CLOSED — guard at resolve (409) + `isTransitionAllowed` in approve/complete/cancel/fail |
| P0-3 CSRF on payment routes | ✅ CLOSED — middleware: double-submit OR first-party Origin (all 4 apps) |
| P0-4 tec-sdk Railway URL | ✅ CLOSED — `http-client.ts` env-var only + throw, zero railway URL |
| P0-5 tec-sdk `x-internal-key` | ✅ CLOSED — sent by `http-client.ts` |
| P1 auth-service CORS Railway URL | ✅ CLOSED — none in source |
| P1 `NEXT_PUBLIC_REALTIME_URL` client leak | ✅ CLOSED — not in client bundle |
| P1 tec-ui SSR window guards / failing tests | ✅ CLOSED — guards added + `@testing-library/dom` |
| NEW-M service-registry | ✅ CLOSED — `tec-api-gateway/src/config/service-registry.ts` |
| **P0-1 Outbox (ADR-004)** | ✅ **CLOSED** — `saveOutboxEvent()` wired atomically into approve/complete (PR #84 merged) — **payment verified working in production** after deploy |

**New External Audit (Session 14):** `audits/EXTERNAL_AUDIT_2026-06-20_Session14.md` — **~9.0/10** (was ~6.5–7.0). All P0 closed (Outbox now live + payment-verified). Remaining = small P1/P2 hygiene batch → Portal.

---

## DONE ✅ (تراكمي)

| Item | التفاصيل |
|------|----------|
| P1 violations | كلها closed (NEW-A → NEW-J) |
| **NEW-B** | **INTERNAL_SECRET set على Railway — 4 services ✅** |
| Security audit (10 items) | PRs #22 Ecommerce + #65 Backend + #19 Commerce + #21 Hub |
| Mode 1 + Mode 2 + ADR-007 | كل 4 apps ✅ |
| CORS | 5 domains في Gateway + Auth + Payment ✅ |
| Hub sub-pages | KYC + Subscription + Notifications + Profile ✅ |
| tec-ui v1.2.1 | PaymentModal + createU2APayment() + 75 tests 80% ✅ |
| Consumer apps on v1.2.1 | Ecommerce + Commerce + Assets ✅ |
| Tests coverage ≥ 60% | كل repos — tec-auth 95% (46 tests), tec-ui 80% (75 tests) ✅ |
| Commerce schema fix | PR #20 merged |
| Ecommerce 503 fix | PR #25 merged |
| NEW-C | ADR-006 في C-64 — CSRF exclusion موثق ✅ |
| NEW-E | tec-ui 75 tests 80% coverage ✅ |
| NEW-F | Pi App ID: `ecommerce-app-71ca4d3e462eaf54` + `ecommerce.tecosystem.app` — C-01 + CLAUDE.md ✅ |
| NEW-G | Dual-Mode في ADR-002 (C-64) + C-12 ✅ |
| Audit Fix — Commerce | Railway URL removed, x-internal-key + Zod + ADR-007 — PR #22 merged ✅ |
| Audit Fix — Assets | Railway URL removed, x-internal-key + Zod + 503 guard — main c411fe9 ✅ |
| **Pi App IDs — كل 4 apps** | Ecommerce + Commerce + Assets + Hub — موثقة في C-01 ✅ |
| **CLAUDE.md session start → main** | كل repos — branch محدّث لـ main ✅ |
| **Comprehensive Audit fixes — Ecommerce** | **✅ ON MAIN** — pushed directly, PR #27 closed. CI ✅ (5d44c501) |
| **Comprehensive Audit fixes — Hub** | **✅ ON MAIN** — pushed directly, PR #24 closed. CI ✅ (275d6fd0) |
| Comprehensive Audit fixes — Commerce | pushed to main |
| Comprehensive Audit fixes — Assets | pushed to main |
| Hub — JWT decode forbidden fix | pushed to main (SHA: 687247d) |
| **Hub CI green** | **✅ CONFIRMED** — 2026 tests passing (commit 275d6fd0) |
| **Ecommerce CI fixes** | **✅** — test files aligned to resolve-based pattern (commit 33d2d141) |
| **Ecommerce payment fix** | **✅** — x-internal-key sent only when INTERNAL_SECRET SET (commit 5d44c501) |
| **Knowledge Base v3.1.0** | **✅ Phase 1+2+3+4** — Skills + MCP + Commands + CI + C-02 updated |
| **C-92 Platform Health Model** | **✅** — 5 dimensions × state machine × PHS composite score × dashboard spec × manual checklist |
| **Engineering Assessment (Session 9)** | **✅** — C-95 (Assessment) + C-57 reconciled (31 fixes) + C-40/C-41 synced + governance renamed |
| **C-93 Institutional Verification Constitution** | **✅** — v1.2 [Future Vision][Draft] — Tier-1 Constitutional Layer |
| **C-94 Governed Capability Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-95 Institutional Knowledge Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-96 Platform Runtime Constitution** | **✅** — v1.1 [Current State][Draft] — Health/Observability/Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-97 Context Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-98 Institutional Construction Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-2 Asset |
| **C-99 Institutional Governance Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 — closes Institutional Operating Loop |
| **C-96 Platform Runtime Constitution** | **✅** — v1.1 [Current State][Draft] — Health/Observability/Availability/Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-79 Institutional Memory Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-2 Asset (moved from C-96) |
| **Code Verified Inspection (Session 9)** | **✅** — NEW-K/L/M documented — Tec-App + tec-api-gateway — 9.3/10 |
| **P1 Fixes Applied (Session 10)** | **✅** — NEW-K/L/N/O VERIFIED — C-81 implementation guide applied — PRI 8.22 → 8.8+ |
| **ADR-007 Foreign Session Fix (Session 13)** | **✅** — `__TEC_PI_FOREIGN_SESSION` check in all 5 Ecommerce payment handlers — defense-in-depth for PiSdkLoader foreign session (piReady=true but Pi.authenticate fails) |
| **Ecommerce Buy Button Fix (Session 13)** | **✅** — Removed `disabled={!piReady}` from ProductCard — buttons always clickable, handleBuy does the redirect logic |
| **Knowledge Base v3.6.2 (Session 13)** | **✅** — 48 new files · 17 new C-docs (C-17/18/19 + C-79/80/81 + C-93→C-99 + C-116→C-118) · evals/ + scripts/ + architecture/ + manifests/ · Governance Charter v1.2 |

---

## KNOWLEDGE BASE UPGRADE (Session 6 — v3.1.0) ✅

### Phase 1 — Foundation
| الملف | الوظيفة |
|------|----------|
| `.claude-plugin/plugin.json` | Plugin marketplace manifest |
| `skills/platform/knowledge-orchestrator` | Meta-skill: تحميل C-docs تلقائياً + توجيه كل task |
| `skills/platform/platform-architect` | C-47 guardian: تحقق من كل قرار معماري |
| `skills/platform/payment-expert` | ADR-007 + C-76 + Mode 1/2 decision tree |
| `skills/platform/security-reviewer` | P6 Fail Closed + 10 Forbidden behaviors checklist |
| `skills/engineering/bff-patterns` | BFF route template كامل |
| `skills/engineering/tec-testing` | Vitest + Pi mock + coverage targets |
| `evals/validate-skills.sh` | CI quality gate للـ skills |
| `templates/new-skill, new-adr, new-c-document` | Scaffolds |
| `.github/workflows/knowledge-ci.yml` | CI pipeline |

### Phase 2 — Marketing + Design + Agents
| المجال | Skills |
|-------|--------|
| Marketing | pi-growth, content-strategy, product-launch, community-marketing, seo-aeo |
| Design | tec-design-system, ui-patterns |
| Agents | cmo-advisor, growth-advisor, design-system-advisor |

### Phase 3 — MCP + Commands + Observability
| الملف | الوظيفة |
|------|----------|
| `.mcp.json` | GitHub + Vercel + Railway + Supabase connectors |
| `commands/check-ci` | CI status لكل 8 repos |
| `commands/check-deployments` | Vercel deployments + runtime logs |
| `commands/check-violations` | P1 violations audit |
| `commands/platform-health` | Full health check (CI + Vercel + Railway + payments) |
| `commands/knowledge-sync` | مزامنة C-02 مع الكود |
| `commands/new-adr, new-skill` | Scaffolding commands |
| `skills/platform/mcp-orchestrator` | كيفية استخدام MCP في context الـ TEC |
| `skills/platform/observability` | SLOs + incident response + circuit breaker |

### إجمالي Knowledge Base v3.1.0
```
Skills:   11 skills (4 platform + 2 engineering + 5 marketing + 2 design)
Agents:    3 agents (cmo-advisor + growth-advisor + design-system-advisor)
Commands:  7 commands
Templates: 3 scaffolds (skill, ADR, C-document)
CI:        1 workflow (knowledge-ci.yml)
MCP:       4 connectors (GitHub, Vercel, Railway, Supabase)
```

---

## KNOWLEDGE BASE UPGRADE (Session 7 — v3.2.0) ✅

### App Institutional Charters — C-100→C-115

16 مستند جديد تم إنشاؤهم كـ Economic Infrastructure Design Partnership:

| Charter | App | System Role |
|---------|-----|-------------|
| C-100 | Hub | System of Access (Current State) |
| C-101 | Commerce | System of Production — Reference Impl (Current State) |
| C-102 | Assets | Digital Asset Infrastructure (Current State) |
| C-103 | Ecommerce | Consumer Marketplace (Current State) |
| C-104 | TEC AI | System of Reasoning (Planned) |
| C-105 | Analytics | System of Intelligence (Planned) |
| C-106→C-115 | Life, Connection, Explorer, Nexus, SYSTEM, ALERT, NX, FundX, Estate, DX | Future Vision |

كل charter يشمل:
- Mission + Authority Boundary
- Technical Architecture + Security Model
- Engineering Updates Required (P0/P1/P2)
- Integration Map (cross-charter dependencies)

### CI Fix
- `evals/validate-skills.sh` — fixed bash `((PASS++))` → `PASS=$((PASS+1))`
- Root cause: `set -e` + arithmetic 0 = false → premature exit after first valid file

### v3.2.0 Additions
- `skills/platform/charter-advisor/SKILL.md` — guide to load Charter before any app modification
- `evals/validate-charters.sh` — CI validator for all 16 charters (16/16 pass)
- `memory/platform-snapshot.md` — fast-load session-start reference
- `.claude-plugin/plugin.json` — fixed version 3.1.0→3.2.0, fixed filenames, added 3 skills
- `.github/workflows/knowledge-ci.yml` — added validate-charters job
- `templates/new-charter/CHARTER_TEMPLATE.md` — scaffold for new institutional charters

### C-57 Updated → v3.2.0
- Added TIER 7 (C-87→C-91: Governance + Execution)
- Added TIER 8 (C-100→C-115: App Institutional Charters)
- Updated Quick Lookup with charter references
- Constitutional Hierarchy extended to C-115

---

## KNOWLEDGE BASE (Session 11) ✅

### Engineering Hardening + Enterprise Contents

| التغيير | التفاصيل |
|---------|----------|
| **CI/eval hardening** | إصلاح عيب `check-knowledge-gaps.sh` + تشديد المُحقِّقات + سكربتات جديدة (`validate-structure`, `check-links`, `check-truth-framework`) |
| **Repo standards** | إضافة `LICENSE` (MIT) + `.gitignore` + `SECURITY.md` + `CONTRIBUTING.md` + `CODEOWNERS` |
| **Orphan resolved** | `47___TEC_Kernel_Spec...` → `knowledge-base/archive/` (C-47 هو الـ canonical) |
| **C-17 — Data Privacy, Retention & Compliance** | جديد [Planned][Draft] — تصنيف بيانات + دورة حياة PII/KYC + احتفاظ + حقوق المستخدم |
| **C-18 — Disaster Recovery & Backup** | جديد [Planned][Draft] — RPO/RTO + سياسة نسخ احتياطي + restore drills + ترتيب التعافي |
| **C-19 — Fraud, Abuse & AML / Sanctions** | جديد [Planned][Draft] — ضوابط الإساءة الاقتصادية + حدود KYC + AML/SAR + فحص العقوبات |

---

## KNOWLEDGE BASE (Session 9) ✅

### Institutional Operating Loop Constitutions (C-93→C-99) + C-80 Assessment

**Tier-1 Constitutional Layer — Institutional Operating Loop:**

| التغيير | التفاصيل |
|---------|----------|
| **C-93 — Institutional Verification Constitution** | v1.2 [Speculation][Draft] — Reality → Evidence → Institutional State → Authority |
| **C-94 — Governed Capability Constitution** | v1.0 [Speculation][Draft] — Knowledge → Executable Capability |
| **C-95 — Institutional Knowledge Constitution** | v1.0 [Speculation][Draft] — Institutional State → Knowledge |
| **C-96 — Platform Runtime Constitution** | v1.1 [Current State][Draft] — Health · Observability · Availability · Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-97 — Context Constitution** | v1.0 [Speculation][Draft] — Capability → Applicable Action (applicability bridge) |
| **C-98 — Institutional Construction Constitution** | v1.0 [Speculation][Draft] — Tier-2: DX Runtime + SDKs + Governed Assembly |
| **C-99 — Institutional Governance Constitution** | v1.0 [Speculation][Draft] — Authority → Governance → Enforcement — closes the loop |
| **C-80 — Engineering Assessment Report** | تقرير مراجعة هندسية شامل (نُقل من C-95) |
| **C-57 — RECONCILED** | تم تصحيح 31+ وصف مغلوط في TIER 2→6B ليطابق الملفات الفعلية |
| **C-40 — SYNCED** | إغلاق NEW-C/E/F/G كـ VERIFIED + Ecommerce PR #25 closed |
| **C-41 — UPDATED** | tec-ui v1.2.1 ✅ + Phase 1 P2 violations ✅ + External Audit ← NEXT |
| **governance/ file** | إعادة تسمية إلى `TEC_GOVERNANCE_CHARTER_v1.2.md` لتطابق المحتوى |
| **README.md** | Skills count 15→16 + KB count 91→93 + C-93 في Quick Navigation |

### Gap Findings Summary (→ C-93 for full detail)

```
Critical (P0) — تم إصلاحه:
✅ C-57 index: 31 وصف مغلوط → تم التصحيح
✅ C-40 stale: 4 violations مفتوحة بعد إغلاقها → تم التزامن
✅ C-41 stale: tec-ui blocker بعد نشره → تم التحديث
✅ governance filename مش مطابق للـ content version → تم التصحيح

Remaining (P1) — مطلوب في Session القادمة:
⚠️ Port conflict: C-10/C-20 (port 3000/5001) vs README/charters (4000/4001)
✅ Commerce domain: محسوم نهائيًا (21 Jun) — `commerce.tecosystem.app` (المسجّل في Pi Developer Portal) · متطابق عبر C-01/C-02/C-101/C-92/C-10
✅ Truth Framework adoption: 100% on registry (96/96 docs registered via auto-generation) — C-00→C-23 تحتاج Truth State headers
✅ Orphan file: 47___TEC_Kernel_Spec_v1_1.1__ → تمت أرشفته في knowledge-base/archive/ (C-47 هو الـ canonical)
```

---

## KNOWLEDGE BASE (Session 8) ✅

### C-92 Platform Health Model

Closes the Observability gap identified in architectural review (9.1/10 → target 9.5/10):

| Section | Content |
|---------|--------|
| Health Philosophy | Health ≠ Uptime. Health = economic function delivered correctly |
| 5 Dimensions | Identity × Payment × App × Service × Event Bus |
| State Machine | GREEN → DEGRADED → CRITICAL → DOWN (formal transitions) |
| PHS Formula | Composite score: Identity 30% + Payment 30% + Service 20% + App 15% + Events 5% |
| Propagation Rules | Identity cascade + Gateway cascade + Payment independence |
| Health Gates | Deployment gate (PHS < 80 = block) + Release chain gate |
| Dashboard Spec | 5 panels with signal layouts — Phase 1 implementation target |
| Phase 0 Checklist | Manual health verification before every deployment |

### C-57 Updated
- C-92 added to TIER 7 (now C-87→C-92)
- Count updated: 91 → 92 documents
- Quick Lookup: added "Check platform health → C-92"
- Content Ranges: C-87→C-92

---

## VERIFIED ✅ (Session 10 — 17 June 2026)

| Item | الحالة |
|------|--------|
| **NEW-K** | **✅ VERIFIED** — `PlatformHealthContext.tsx` — Single Poller + context — يغني عن polling مزدوج |
| **NEW-N** | **✅ VERIFIED** — Redis: 5 event listeners (connect/ready/error/reconnecting/end) — Observable Runtime |
| **NEW-O** | **✅ VERIFIED** — `GET /api/health/details` (x-internal-key) — gateway + redis + uptime + memory + services |
| **NEW-L** | **✅ VERIFIED** — Gateway timeout: 30000 → 10000 — تنسيق: Frontend 5s / Gateway 10s / Upstream 8s |
| **C-81 Implementation Guide** | **✅ CREATED** — كود كامل لـ 4 fixes — مطبّق على Tec-App + Tec-core-backend |

## PENDING ⚠️

| Item | الإجراء |
|------|----------|
| **NEW-M** | **✅ DONE** — `tec-api-gateway/src/config/service-registry.ts` موجود (Code Verified Session 14) |
| **P0-1 Outbox (ADR-004)** | ✅ DONE — wired atomically في approve/complete (PR #84) + **مُتحقَّق: دفعة حقيقية نجحت في الأبس بعد الـ deploy** |
| **P0-4 tec-sdk Railway URL** | 🟡 تأكيد — fallback URL في http-client.ts |
| External Re-Audit | بعد P0 backlog — المتوقع 9.0–9.5/10 |
| Port Conflict | C-10/C-20 (5001) vs README/Charters (4001) — يحتاج قرار موحّد |
| Commerce Domain | ✅ محسوم نهائيًا (21 Jun) — `commerce.tecosystem.app` (المسجّل في Pi Developer Portal) — متطابق عبر C-01/C-02/C-101/C-92/C-10 |
| Truth Framework | ✅ Tier الأساسي (C-00→C-23) مكتمل Truth+Governance State — الباقي قيد التبنّي التدريجي |

---

## NEXT 🔴 (Portal path)

```
1. ✅ Payment Unification (ADR-009) — DONE Session 14
2. ✅ P0-1 Outbox (ADR-004) — DONE (PR #84 merged + payment-verified in prod)
3. ✅ P0-2..P0-5 — all verified CLOSED (see reconciliation table)
4. ✅ P1/P2 hygiene batch (Session 14.1) — DONE:
     · .dockerignore على كل 12 service (4 ناقصة + تنظيف EOF/done) ✅
     · INTERNAL_SECRET startup guard unconditional — wallet كان آخر gap ✅
     · npm audit advisory (non-blocking) في CI لكل 4 apps ✅
     · Assets Zod "v4 drift" = stale — Assets أصلاً على zod ^3.23.8 (3.25.76) ✅
     · متبقي مؤجّل (مش hygiene): Sentry major drift (Assets v10 vs v8) → change متحقَّق منه لوحده · REALTIME_URL = ops env
4b. ✅ Re-audit fix (Session 14.1): payment-service bootstrap INTERNAL_SECRET guard
     made unconditional (PR #85) — last NODE_ENV-gated guard on the platform
5. ✅ Code-Verified Re-Audit (Session 14.1) → ~9.0–9.2 — كل البنود grep-verified
     (مراجعة ذاتية موثّقة بالكود — مش external مستقل؛ الخيار: self-review موثّق + Portal)
6. ✅ Session 14.4 — template completeness + package CI parity (tec-auth/tec-ui/tec-sdk)
7. ✅ P1 ops/env — ALL CONFIRMED (21 Jun 2026): PI_SANDBOX=false · REALTIME_URL ·
     Portal domains/IDs · Privacy/Terms URLs · real Mode-1+Mode-2 payment per app
8. 🟢 Portal Submission → Pi Network  ← CLEARED — submit per app (PORTAL_SUBMISSION_RUNBOOK)
```

### Portal-readiness checklist (Phase-0 gate) — ✅ ALL CLOSED
```
ENGINEERING (code) — ✅ all closed/verified:
  □✅ Payment Mode 1 (Hub) + Mode 2 (standalone) — both working, prod-verified
  □✅ Outbox event durability (ADR-004) + reconciliation (Pi source-of-truth)
  □✅ Security invariants: no jwt.decode · no localStorage tokens · no CORS *
       · INTERNAL_SECRET unconditional (12/12) · x-internal-key on gateway calls
  □✅ CSRF robust (double-submit OR first-party Origin) across SSO + Pi Browser
  □✅ .dockerignore 12/12 · DECIMAL(20,8) + balance>=0 · non-root Docker

OPS / ENV (Railway/Vercel/Pi Portal) — ✅ CONFIRMED 21 Jun 2026:
  □✅ INTERNAL_SECRET set on ALL 12 Railway services
  □✅ PI_SANDBOX=false verified in production (each Pi-paying app)
  □✅ REALTIME_URL set on Hub
  □✅ Pi Developer Portal: domains + App IDs registered & match production
  □✅ Privacy Policy + Terms URLs live on each app domain
  □✅ Real Mode-1 + Mode-2 payment verified per app

DEFERRED (non-blocking for Portal):
  □ Sentry major align (Assets v10 vs v8) — build-verified change
  □ tec-realtime-service tests · move vite/vitest to devDeps
```

---

## PI APP IDENTITY

> **Canonical identity:** C-01 §4. This table mirrors the complete fleet and is
> cross-checked by `evals/check-portal-readiness.sh`.

| App | Pi App ID | Domain | PI_SANDBOX |
|-----|-----------|--------|------------|
| Hub | `tec-app-923b947851f9dfe1` | `https://hub.tecosystem.app` | false |
| Commerce | `commerce-app-68aa99081fc1897a` | `https://commerce.tecosystem.app` | false |
| Assets | `assets-app-af2fb490e7b03db7` | `https://assets.tecosystem.app` | false |
| Ecommerce | `ecommerce-app-71ca4d3e462eaf54` | `https://ecommerce.tecosystem.app` | false |
| Analytics | `analytics-822d9810de66bc84` | `https://analytics.tecosystem.app` | false |
| Life | `life-app-c468e9eb5bf115fa` | `https://life.tecosystem.app` | false |
| Connection | `connection-aa9fba4f11664096` | `https://connection.tecosystem.app` | false |
| Zone | `zone-xwc6` | `https://zone.tecosystem.app` | false |
| Nexus | `nexus-3x2v` | `https://nexus.tecosystem.app` | false |
| Explorer | `explorer-kxfp` | `https://explorer.tecosystem.app` | false |
| System | `system-qbz2` | `https://system.tecosystem.app` | false |
| Alert | `alert-3ag1` | `https://alert.tecosystem.app` | false |
| NX | `nx-cahj` | `https://nx.tecosystem.app` | false |
| DX | `dx-hqma` | `https://dx.tecosystem.app` | false |
| Titan | `titan-e1ta` | `https://titan.tecosystem.app` | false |
| Epic | `epic-4muf` | `https://epic.tecosystem.app` | false |
| Legend | `legend-43xr` | `https://legend.tecosystem.app` | false |
| Elite | `elite-cfwh` | `https://elite.tecosystem.app` | false |
| VIP | `vip-vzge` | `https://vip.tecosystem.app` | false |
| NBF | `nbf-zutt` | `https://nbf.tecosystem.app` | false |
| FundX | `fundx-55a3cb7bc6cf09fd` | `https://fundx.tecosystem.app` | false |
| Estate | `estate-f4d67b390ff45ed6` | `https://estate.tecosystem.app` | false |
| Insure | `insure-ayh6` | `https://insure.tecosystem.app` | false |
| Brookfield | `brookfield-ftq4` | `https://brookfield.tecosystem.app` | false |

---

## PLATFORM STATE

```
12 Railway services:   Active — INTERNAL_SECRET set ✅
24 apps (Vercel):     all registered + deployed + Mainnet subscriptions live
4 npm packages:       tec-auth + tec-ui (v1.2.1) + tec-sdk + tec-shared
PI_SANDBOX:           false (Mainnet)
tec-auth coverage:    95% (46 tests)
tec-ui coverage:      80% (75 tests)
Hub coverage:         95.5% (2026 tests) ✅
Hub CI:               ✅ GREEN — 2026 tests passing (commit 275d6fd0)
Ecommerce CI:         ✅ GREEN — ADR-007 foreign session fix (commit a586c1ca)
All repos coverage:   ≥ 60% ✅
All 24 apps:          Pro/subscription Mode 1 + Mode 2 real-Pi surfaces ✅
All P1 violations:    ✅ ZERO
All P2 violations:    ✅ ZERO
All Pi App IDs:       ✅ all 24 apps registered; canonical list = C-01 §4
All audit fixes:      ✅ ON MAIN — Hub + Ecommerce + Commerce + Assets
Last audit score:     7.65/10 (Session 3) → Architectural Review 9.1/10 (Session 8)
Architectural Review: Knowledge Architecture 9.5+/10 | Platform Engineering 9.0–9.2/10
CLAUDE.md:            ✅ session start → main في كل repos
Knowledge Base:       ✅ v3.10.0 — 112 C-docs + 16 skills + 16 charters + 13 CI gates
Pending PRs:          NONE — all fixes on main ✅
Latest audit:         ✅ Session 14 (2026-06-20) → ~9.0/10 (was ~6.5–7.0) — all P0 closed (Outbox live + payment-verified)
NEXT:                 deepen real product functionality one gated app at a time
```

---

## SESSION 52 — the Pioneer campaign has a commercial objective, and it was not written down

**The finding, and it reframes the campaign:** Pi will not accept a `.pi` domain claim
until the connected app has **"at least 5 unique KYC'd approved Pioneers engage with the
app"**. Twenty-four `.pi` domains were **won at auction and paid for** (vip.pi 2.8K π ·
nexus.pi and explorer.pi 1.4K π each · commerce.pi 999 π · estate.pi 750 π …), and
**`tec.pi` is the only claim accepted** — every other app returns *"Requirements Not Met"*.

So the Founding badge and the PRO gift are **incentives**, not the objective. The
objective is 5 verified pioneers × 24 apps, before the domains lapse. Recorded in full as
**C-134 §20** (it also closes §19 Open Question 2, from outside).

> This was rediscovered from a phone screenshot, not from the KB — the exact failure mode
> C-95 exists to prevent. The campaign had been engineered for two sessions without its
> own purpose written anywhere.

**Shipped this session (all merged unless noted):**

| # | What | Where |
|---|------|-------|
| 1 | **The Quest was forgeable.** `app` was any string ≤40 chars, so 24 POSTs of `'a'..'x'` earned a permanent Founding number in seconds. Closed by a campaign-owned roster; `QUEST_TARGET` is now its length, not a literal. | tec-core-backend #274 · tec-app #192 |
| 2 | **Audited campaign reset** (admin token + confirmation phrase, audits before it deletes) — Founding numbers are non-recyclable by design, so test runs permanently consume advertised places. Also removed a seeded demo pioneer that the public counter was serving as real. | tec-core-backend #274 |
| 3 | **Founding gift = 6 months PRO, not Pi.** PRO is unsellable, which collapses the incentive to farm the badge, and it reuses the referral grant rule rather than adding a second one. ⚠️ **The reason originally recorded here — "payment-service speaks only the U2A half; there is no A2U path, so Pi cannot be paid out at all" — is NO LONGER TRUE** (see the correction below). The decision still stands on its own merits; the justification does not. | tec-core-backend **#275 — open** |
| 4 | **Per-app coverage** (`GET /identity/pioneer/coverage`, admin) — which apps are still short of 5 verified pioneers, and by how many. | tec-core-backend **#275 — open** |
| 5 | **Feedback inbox** — a form in `/hub/profile` and an admin reader at `/hub/admin/feedback`; the table had no reader before. Runtime-verified, including a message from a real external user. | tec-core-backend #273 · tec-app #191 |

**Three comments in `pioneer.service.ts` claimed a KYC gate the code never had.** The code
was right and the sentences were wrong. There is deliberately **no KYC gate**: Pi has
already verified the account, and asking a first-time visitor for documents to earn a badge
reads as a scam.

**Honest limits, recorded rather than smoothed over:**
- `coverage` counts **TEC's** KYC register; Pi checks its own, which this platform cannot
  read. Below the threshold is reliable; at or above it is **not** a confirmation from Pi.
- Pi counts *engagement*; the Quest records an *open*. Closing that gap is the highest-value
  unbuilt work (C-134 §20.6) — a completed Pi **Mainnet** payment is the strongest available
  proxy for Pi KYC and is currently unused.
- **5 Founding places are already consumed by test runs**, and 2 of the 10 pioneers came
  from a real Reddit link — so a reset is not obviously free. Decide before launch.

---

## SESSION 53 — the Testnet gate is closed on all 24 apps, and it exposed a guard one consumer wide

Pi Portal checklist **step 10** (one U2A Test-Pi payment on each app's paired Testnet
app) is **complete across the fleet**. Full engineering record:
`audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md`.

### What closed
The five apps left open at the last write-up now carry the port:

| App | How |
|---|---|
| Assets · Commerce · Ecommerce | hand-written — older than the template, each needed a genuinely different edit |
| NBF · Brookfield | attached to the session, then ported from the reference app unchanged |

### The three things worth carrying forward

**A host is read off the deployment or it is not known.** Vercel appends a suffix when
a project name is taken, and the suffixes are arbitrary: `tec-zone-mu`,
`tec-elite-bvzb` — and `commerce-app`, with no `tec-` prefix at all. The Hub's
`ALLOWED_TARGETS` had been written from the naming pattern. It must never become a
wildcard: `/api/auth/sso` hands the target a signed token carrying the user's access
token, and anyone can deploy on `*.vercel.app`.

**A branch that is nearly unreachable in production is not a tested branch.** Commerce
and Ecommerce sent an unauthenticated visitor to the Hub with **no `target=` at all** —
a one-way trip. The shared `.tecosystem.app` cookie means that branch is almost never
taken on Mainnet; on a host-only `*.vercel.app` host it is taken *every* time. Both had
shipped for months. Ecommerce had the constant redeclared in **eight** files, and in
Commerce two copies of the same rule had already drifted apart inside one repo.

**Overwriting is not removing.** `metadata.testnet` decides which Pi network the π
settles on and whether commerce grants PRO — so it must be derived from the request
host and a client-sent value **stripped**, not spread over. The host-derived value is
*absent* on Mainnet (present only when true, deliberately), so an overwrite there
overwrites nothing and the caller's claim survives.

### Recorded, not fixed — the next change

Fleet audit of every payment-create route: 22 apps + the template derive the marker and
strip the client claim; Assets and Commerce accept no client metadata at all. **The Hub
is the only app with neither** — `grep -ri testnet tec-frontend/src/` returns zero — and
its `metadata` is `.passthrough()`. Its sandbox default is also **inverted** against the
fleet (`!== 'false'` → defaults **true**).

Worse, one level down: **`tec-wallet-service` credits a real balance on
`payment.completed` with no `testnet` check.** All eight consumers of that event were
read; exactly one has the guard. A Test-Pi payment is refused a PRO subscription and
credited to a real wallet in the same breath. The `.v1` outbox payload carries
`metadata`, so the guard is implementable — the open decision is the legacy
direct-publish path, which carries none.

**Order for the next session: wallet-service first — it is the one that moves money.**

### …and then the CEO asked the question that found two more

> *"But no app works on the Testnet from the Hub."*

Not a bug report — an observation about the system nobody had stated, because every app's own
Mode-2 payment worked and Portal step 10 only ever needed Mode 2. It found two things.

**1. `HUB_URL` — the fourth build-time constant.** Mode 1 hands the payment to the Hub, which
creates *and approves* it, so the **Hub's own host** picks the key. Every app sent every
visitor to `NEXT_PUBLIC_HUB_URL` — one of the Hub's two hosts, baked at build time. A Testnet
visitor got a Mainnet approval and a Test-Pi wallet could not pay it. `APP_URL` · `sandbox` ·
`HUB_URL`: the same shape, a fourth time. Swept across 24 repos (33 files), matching **only**
the Mode-1 payment redirect so login — which works — was out of range by construction.

**2. The guard was on a route nothing calls.** The network marker and client-claim strip had
gone into `/api/bff/payment/create`, the ADR-009-shaped sibling that **no production code
calls**. Every real Hub payment posts to `/api/payment/create`, which forwarded the body
verbatim.

> **A guard's coverage is a fact about call sites, not about file names.** `grep` for the
> callers before believing a guard is in place.

Both closed. Full record: `audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md` §13 — and §4, which
had deferred this, is left standing rather than edited away: its reasoning was right for the
gate it was scoped against, and a record that quietly rewrites its own earlier judgement
teaches nothing.

---

## SESSION 54 — the Testnet gate was closed; then someone actually used it

Session 53 proved each app could take **one** Test-Pi payment. This session was what
happened when the owner used the Testnet the way a person does — pay in the Hub, walk
into an app, pay there — and it did not work. Full engineering record:
`audits/PI_TESTNET_PAYMENT_LATENCY_2026-09-11.md`.

### Where the fleet actually stands

| Repo | Merged | Testnet payment |
|---|---|---|
| `tec-app` (Hub) | **#209 → #226** (18) | works, both modes |
| `tec-system` | **#29 → #34** (6) | works, both modes — the reference app |
| `tec-core-backend` | **#293** | reconciliation reads Testnet payments with the Testnet key |
| **the other 21 apps** | **none merged** | **still broken on Testnet, both modes** |

> The last row is the headline. Each of those 21 carries 2–4 commits on
> `claude/tec-knowledge-base-review-6wzngc` with an **open PR**. Until they merge, only
> the Hub and System can take a Testnet payment at all. Mainnet is unaffected throughout.

### The five defects, in the order each exposed the next

1. **ADR-007 was blind to the Testnet Hub.** The guard tested a substring of the
   *Mainnet* Hub only, so every hop from `tec-app-frontend.vercel.app` read as
   standalone: the app ran `Pi.init()` inside a Hub-owned session and sat in
   `Pi.authenticate` forever. **No error is raised — the bridge simply never replies.**
   Now `HUB_HOSTS` + hostname matching (the substring form also matched
   `hub.tecosystem.app.attacker.com`, and that fails **open**).
2. **The Mode-1 chain on the Hub was a straight line** — navigate → auth settles →
   create → modal mounts → *then* warm the Pi session. Four serial steps before the
   handshake began; it now runs beside them.
3. **Two concurrent `Pi.authenticate` calls, produced by the guard against them.**
   `withAuthGate` serialized the two call sites and a login is adopted, not repeated —
   then the *tap* threw away a healthy 1.2-second-old handshake to start a fresh one,
   because it had been written to avoid inheriting a stalled warm-up. It now joins.
4. **Cancel returned to the Hub, and `return_url` was an open redirect** carrying
   `payment_id` + `txid` to any origin named. Now allowlisted against the SSO list
   (extracted so the two consumers cannot drift), matched on **origin**, not prefix.
5. **`/pi-test` paid under a key source that exists nowhere**, so it reported a failure
   production would never have. *A diagnostic that tests a different path from the one
   it is diagnosing sends you hunting the wrong bug.*

### What is still slow — and the decision NOT to fix it

Pay in the Hub, then in an app: the **first** payment after arriving takes tens of
seconds. The reverse order is instant. The trace shows our side is clean — one
handshake, at 0.0s, joined by the tap — so **the wait is inside `Pi.authenticate`**
itself, a Pi app-context switch, paid **once**. **Testnet only; Mainnet is instant.**

The structural cause is the shape of the environment, not the code:

```
Mainnet   hub.tecosystem.app          <->  <app>.tecosystem.app    ONE domain
Testnet   tec-app-frontend.vercel.app <->  tec-<app>.vercel.app    TWO unrelated sites
```

`vercel.app` is on the **public suffix list** — separate cookie jars, separate
partitions, nothing shared. A `-test.tecosystem.app` pairing would give Testnet
Mainnet's shape; **the code is written and open in a PR on all 25 repos, and the
domains are deliberately NOT being created**: it is not a diagnosed cause, the pain is
confined to a test environment, and the cost is ~48 manual Vercel + Pi Portal steps that
can break Testnet payments which currently work. Merging the code is additive and free,
so the option stays open. **Revisit only if it is seen on Mainnet.**

### The recurring shape — sixth instance

A **build-time constant answering a question only the request can answer**:
`APP_URL` · `sandbox` · `HUB_URL` · `appId` · the Hub's app-grid routes · ADR-007's hub
referrer. One build, two hosts. And three axes that keep being conflated: the **host**
picks the Pi *app*, the app's **key** picks the *network*, **`sandbox`** points at Pi's
*Sandbox environment* — a third thing.

### Process

- **A merged PR cannot carry new work.** A commit landed on a branch whose PR had
  already merged and was invisible. Pushing and opening the PR are **one step**.
- **A fleet sweep must check what it overwrites.** A stash-and-switch dropped an
  unmerged commit in two repos; found by auditing all 25 for the expected content, and
  restored. Prove each branch holds only merged history *before* a force-push.

## CORRECTION — A2U EXISTS. Two recorded reasons for not building it are stale.

Found while reviewing "the A2U plan" on request. There is no plan to review: **the
payout path is built, merged and wired.** Two documents say otherwise, and one of them
was used as the justification for a product decision.

### 1. C-02 said there is no A2U path. There is.

| | |
|---|---|
| `tec-payment-service/src/services/pi-a2u.ts` | create → **sign + submit on Stellar** → complete |
| `controllers/a2u.controller.ts` | `POST /payment/internal/a2u` · `GET /payment/internal/a2u/limits` |
| `routes/payment.routes.ts` | both mounted behind `validateInternalKey` |
| `__tests__/pi-a2u.test.ts` | covered |
| Consumer | the Pioneer campaign — self-withdrawal, payout queue, **and a chain lookup before a payout is recorded as paid** |

It is not a sketch. The bounds are written as reasons, not decoration:

1. **One dedicated wallet** (`PI_A2U_WALLET_SEED`) holding only what payouts need — explicitly *not* the wallet that holds the platform's Pi.
2. **A hard per-payment ceiling** (`PI_A2U_MAX_PI`, default 10 π), enforced **inside the code that signs** — not by the caller, because the caller is the thing that might be wrong.
3. **Idempotent by the caller's own key**, so a retry that already sent cannot pay twice.
4. **Never silent**, and the `txid` is returned even when `complete` fails — the chain is the truth, and a failed bookkeeping call must never look like a failed payment.

> **This is a custody change, not a feature.** To sign an outgoing transfer the service
> must hold the app wallet's PRIVATE SEED. Every other flow in that service moves Pi a
> user authorised, holding no key that can spend. A2U is the first time the platform
> holds one (C-71 · Invariant #8).

### 2. The Portal audit's "why it has not simply been done" is stale

`audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` §3 records the blocker as
`tec-payment-service` choosing the Pi network **globally** from `PI_SANDBOX`, so a
Testnet payment could not be approved without taking every live payment down.

**That was fixed** — the network is now chosen **per payment**, from the target that also
picks the key (tec-core-backend #290 · #291). The constraint that paragraph describes no
longer exists.

### 3. What IS still blocking — and it is not code

Pi grants a **Mainnet App Wallet** only after **5 A2U payouts to 5 distinct Pi accounts**
from the paired **Testnet** app's wallet. A2U pays by `uid`, and a `uid` for an app only
exists once that account has **authenticated with that app**. So it needs **four other
people** to open the Testnet app. No amount of engineering removes that.

### Why this correction matters more than the two lines

The stale sentence was not inert — it was **used**. The Founding gift was made PRO
instead of Pi *because* "Pi cannot be paid out at all". The decision still stands on its
own merits (PRO is unsellable, so it cannot be farmed), but it was taken for a reason
that was already false. That is precisely the failure C-95 exists to prevent: a document
that lags the code does not sit quietly, it gets built on.

## SESSION 55 — the Commerce tile pointed off the platform, and the comment said it was verified

Full engineering record: `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md`.

Session 54 left 21 apps unmerged. They merged, and **every app then worked from the
Testnet Hub except Commerce**, which returned a blank `500` — while opening fine when
typed directly.

### The cause was one line in the Hub

```
TESTNET_ORIGINS in the Hub grid — Testnet hosts only, never the Portal domain:
  commerce: 'https://commerce-app.vercel.app'       WRONG — a different Vercel account
  commerce: 'https://tec-commerce-app.vercel.app'   the Testnet host the project serves
```

> Commerce's **Portal / Mainnet** domain is unchanged and remains
> `commerce.tecosystem.app`. The host above is the Testnet pairing only.

The Commerce project's **Domains** page names the second. The first is somebody else's
deployment — alive enough to serve a favicon, and `500` for every function. The Testnet
grid had been handing every visitor to it. (tec-app **#231**)

**The security half is worse than the routing half.** That host was also in
`ALLOWED_APP_ORIGINS`. `/api/auth/sso` signs a token carrying the user's **access token**
and redirects to the target — so that line was standing permission to hand a foreign
origin a live session. Removed.

> An allowlist entry is not a hint about where an app might live.

### Three wrong diagnoses first, and why the third one matters

Broken deployment → expired token + an unbounded refresh hop → `crypto.randomUUID()` as a
Node-version global. The third explained **every** observation at once and was still
wrong, because a theory that explains everything about the wrong subject explains nothing
about the right one.

What ended it was a **negative** result: the Commerce project's Vercel logs showed
`Error 0 · Warning 0 · Fatal 0`, error rate `0%`. A healthy project cannot be the source
of a 500 someone is looking at. Then the Domains page named the host in one line.

### The lesson worth keeping — a comment that had already been believed

The wrong value was **documented as verified**. The file header cited it as proof that
hosts cannot be guessed: *"NOT invented, and not derived from a name … `commerce-app` has
no `tec-` prefix at all"*. The example offered as evidence **against** guessing was a
guess, and because it read as already-checked it survived every round intact — it is what
a reader consults **instead of** the source.

The fix is not a better guess but a **named source**: the only authority for a value in
that file is now the Vercel project's **Domains** page — explicitly not the app's
`ALLOWED_AUDIENCES` (the old rule, and an allowlist never answers "is this host ours?"),
not the project name, and not the comment.

**Third occurrence of this shape** — Zone (`tec-zone.vercel.app` → a stranger's pink
shop), Elite (caught pre-release), Commerce. Now guarded by a `NOT_OURS` list asserted
absent from both the Testnet maps and the SSO allowlist.

### Two fail-open defects found on the way — same shape, unrelated cause

Both were **a component answering "fine" while doing nothing**:

- **Reconciliation resolved nothing, on schedule.** `404 payment_not_found` was treated
  as "Pi unreachable" and retried hourly forever — 10 stale rows, 10 reads, 10 x 404,
  `reconciledCount: 0` — while the comment above it said a 404 cancels the payment. It is
  now final, with its reason in the audit log (Invariant #4), under three required facts
  so a 404 from *our* bug still retries. Sound **only** because `targetOf` carries the
  network: a Testnet payment read with the Mainnet key answers the same thing.
  (tec-core-backend **#295**)
- **A gateway routing NOTHING reported `status: "ok"`.** A stray Railway service ran a
  second gateway with no service URLs → zero routes, healthy `/health`. *"All 0
  microservice routes mapped"* reads like a status line. And **the isolation that
  protects the real gateway (NEW-W) is what hid this one** — liveness is deliberately
  decoupled from the pipeline, so a gateway serving nothing is indistinguishable from the
  working one by the only signal anyone checks. `/health` still returns 200 but now
  carries `routes` + `unroutedServices` and reports `degraded`; `/ready` says **no** at
  zero routes. (tec-core-backend **#296**)

### The login handoff could hang

`sso -> /api/auth/refresh -> gateway -> auth-service`, and **not one hop had a timeout**.
An unbounded fetch waits until the platform kills the invocation — and a killed function
never reaches its `catch`, so the route changed last session to *say why it failed* could
not say anything. Bounded now, degrading to the un-refreshed token rather than failing.
(tec-app **#230**)

> **Naming an error is worthless if the handler is the thing being killed.**

### Recorded honestly: the `crypto` fix was NOT the cause

Commerce's `sso-callback` used the bare `crypto` global (Node 19+) while its `pi-login`
imported it. Real latent defect, fixed on every **route handler** — `middleware.ts`
deliberately keeps the global, because Edge has Web Crypto and no `node:crypto`. But it
did **not** produce the 500, and this entry says so rather than letting a merged fix
imply a resolved cause (C-95). (Tec-Commerce **#65**)

### Also this session

Two stray Railway services deleted — `pacific-adaptation` (built the repo root, which is
unbuildable; failed from day one, never served a request) and `Tec-core-backend` (the
zero-route gateway above). Neither is a folder in the repo and neither needs to be: a
Railway service is `(repo) + (root directory) + (env vars) + a label`.

The **`-test.tecosystem.app` pairing was cancelled by the owner** — the fleet stays on
the `*.vercel.app` pairing, with the public-suffix consequences as recorded in Session 54.

### TEC AI — the assistant's picture of the user travelled through the browser

Asked what was left with no payment path, the answer was **TEC AI** — and C-104 §7
already settles that: FREE/PRO/API, monetized through the **Hub PRO subscription**,
not a payment of its own. Nothing missing there. What IS missing is the gate itself
(`requiresPro: false`; `/ai` treats FREE and PRO identically).

Scoping that gate found a defect underneath it that has nothing to do with money.

**`/api/bff/ai/context`** resolves the caller's real state from the gateway — Life
goals, focus, Analytics activity, KYC — server-side from the session identity, exactly
as C-106 sovereignty requires. It then returned that object to the **browser**, and the
browser posted it back to `/api/ai/chat`:

```
const userContext = body.userContext;   // taken whole, unvalidated
const systemPrompt = buildSystemPrompt(userContext);
```

Every platform **claim** about the user made a round trip through the one place that
cannot be trusted. Editing one fetch body was enough to tell the assistant you were
KYC-verified, or to hand it goals you do not have.

**Nothing executes on these** — the AI guides, it never acts (C-104 §4) — so no money
moves. It answers the user from premises the platform never asserted, **in the
platform's voice**. That is the damage, and it is enough: the whole value of the
assistant is that its picture of you is real.

**Fixed** (tec-app **#232**) with a token the server signs — three properties, each
load-bearing:

| Property | Without it |
|---|---|
| **Signed** (HS256 / `JWT_SECRET`) | the browser rewrites any field |
| **Subject-bound** (`sub` checked against the independently verified session) | a lifted token is a portable identity claim |
| **Short-lived** (15 min) | a user pins a stale KYC or an old goal list |

A **token rather than a second fetch**: `/api/ai/chat` runs on the **Edge** runtime
while context assembly is a Node BFF fanning out to three gateway endpoints —
re-resolving there would put that fan-out on *every message*. Same primitive the SSO
handoff already uses.

> **The boundary is CLAIMS vs PREFERENCES, not server vs client.** Reply language and
> length stay in the body: they are the user's own choice from the assistant's settings
> menu, assert nothing about them, and signing them would mean a round trip every time
> someone toggles "short answers". Stated that way, the next field added lands on the
> correct side on its own.

No fallback to the body when verification fails — failing closed costs a less personal
answer; falling open puts unchecked statements in the prompt (P6).

**Two things the fix surfaced:**
- **Two call sites, not one** — the Hub drawer hook and the `/ai` page each had their
  own copy of the body. Fixing only the drawer would have left the page open, and the
  page was worse: it also sent a `username` read from client state.
- **That username was never real anywhere.** The drawer's test mocked a BFF field the
  BFF never returned, so the greeting was personalized *in the test* and generic in
  production. It is now a signed claim from the `tec_user` cookie — so the feature both
  works and is trustworthy. *A test can be the only place a feature exists.*

**Deliberately NOT done — the FREE/PRO gate (C-104 §7).** It is a product decision (what
the FREE limits are), and it is a trade: the personal-context injection IS the
"advanced planning" the table sells, so gating it makes the FREE assistant noticeably
worse. #232 is what makes the gate *possible* — with claims verified server-side, a
`plan` field in the signed context is enforceable; without it any gate is bypassable by
editing one fetch body (C-110 §5 P0-1: gating is server-side, never client-trusted).

### A2U — the Mainnet App Wallet gate, and it is ONE app not twenty-four

The Pi Portal gates the Mainnet App Wallet on: *"The paired Testnet app needs App to
User transactions to 5 unique wallets."* Full record: `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md` §11.

**A2U could not make those payouts.** `sendA2uPayment` took `source?: string`, which
`targetOf` widens to `{ source, testnet: false }` — so every payout resolved the
Mainnet key, Horizon, passphrase and wallet, whatever it was for. Same shape as
`APP_URL` / `sandbox` / `HUB_URL` / reconciliation's `targetOf` before it, except
**here it decides which chain gets signed**. Fixed: all four now come from ONE flag on
the payout (tec-core-backend **#297**, merged).

**The wallet rule, stated in the file:** `PI_A2U_WALLET_SEED_TESTNET` has **no
fallback** to the Mainnet seed. A missing *key* makes Pi reject a request; a missing
*seed* that fell back would load the wallet holding real Pi and sign with it. The
passphrase mismatch would reject it — so no money moves — but that would be an
accident of the chain, not a property of the code.

> The wallet that can spend real Pi is never reached by a payout that did not ask for it.

**Scope — answered from the code, not assumed.** The fear was that all 24 apps would
need this. They do not:

1. it is the **OUTGOING** wallet — the Mainnet TEC-APP reads `Connected Outgoing
   Wallet: None` while all 24 apps take real Pi today. **Receiving needs no wallet.**
2. A2U has **exactly one caller** in the whole backend — the campaign
   (`memo: 'TEC Pi Reward Campaign'`), sending no `source`, so it is the Hub's app.
3. every other reward is deliberately not Pi — the referral reward carries the comment
   *"A referral reward is a GIFT SUBSCRIPTION month — never raw Pi"*; the Founding-100
   gift is six months of PRO.

This agrees with platform law rather than convenience: **C-47 Invariant #8** and
**C-132** make `payment-service` the only Pi custodian, so 24 app wallets would be a
violation of the design, not an achievement inside it. **One round, for the Hub.**

**Honest caveat:** Pi's A2U *is* per-app (a `uid` is app-scoped), so an app that ever
pays its own users needs its own wallet and its own five-payout round. Only FundX,
Insure and Brookfield could reach that, and all three are hard-gated on **legal
review** — not on a wallet. If those gates open, C-132 routes distribution through
payment-service anyway.

**State:** #297 merged · `PI_API_KEY_HUB_TESTNET` + `PI_A2U_WALLET_SEED_TESTNET` set on
`tec-payment-service`. **Remaining, and it is not an engineering task:** five *distinct*
Pi accounts must authenticate with the paired **Testnet** app — a `uid` for an app
exists only once that account has signed into that app, so it needs four other people.

### Open after this session

`order.paid.v1` is still emitted fire-and-forget with no retry (`Stream isn't writeable`,
seen 05:16 — one Redis blip loses it permanently) · `commerce-app.vercel.app` is still in
Commerce's own `ALLOWED_AUDIENCES` (inert, but a foreign origin listed as acceptable) ·
the repo-root `package.json` in `tec-core-backend` is unused by every CI step and
unbuildable, and is what made Railway believe the root was deployable.

---

## SESSION 56 — the first time the platform tried to pay anybody, four things were wrong

Full engineering record: `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md`.

Session 55 left one thing outstanding, and it was not an engineering task: five distinct
Pi accounts had to sign into the paired **Testnet** Hub so the app would have five `uid`s
to pay. Five people did. Then the payouts ran — and **every one of the five attempts
failed, for a different reason each round.**

### The gate is closed

```
FAARSS876  ·  mord886  ·  gzer0023  ·  YAs5er2030  ·  magy888
5 unique wallet(s) paid, of 5 the Portal wants.
```

Counted off **Horizon**, not off successful API calls — the Portal counts *wallets*, and
five payouts to one person count once. Mainnet App Wallet applied for the same night, as
an Individual; `Connected Outgoing Wallet: None` until Pi answers.

### The four defects, each found only by trying

| # | Defect | Why nothing caught it |
|---|--------|-----------------------|
| 1 | `Pi.authenticate` asked for `['username','payments']`. **`wallet_address` was never requested**, so Pi refuses every create with `401 missing_scope` before anything is signed. | Permission is negotiated at runtime with a third party. No test, lint or review asks "does this request the permission it needs?" |
| 2 | Pi allows **one open server payment per APP**, not per user. One payout left hanging blocked every other payout the platform could make. | A single-recipient test never produces a second recipient to be blocked. |
| 3 | The transaction fee came from Stellar's `BASE_FEE` constant (100 stroops). **Pi is not Stellar** → `tx_insufficient_fee`. | Only visible in Horizon's `extras.result_codes`, which the error handling was discarding — see 4. |
| 4 | Failures threw away their own reasons: Pi's `error_message` and Horizon's `result_codes` never reached the log or the caller. | A generic message is not a failing test. It reviews fine. |

> **The one worth carrying past this session is #1.** The Hub's home screen advertises a
> reward campaign — *"visit a few apps, claim real Pi"* — paid through this exact path.
> **It could never have paid a single person, on Mainnet either.** A feature can be
> shipped, visible, advertised, and structurally incapable of working, and nothing says
> so until the first real attempt. Three of the four defects would have waited for the
> first real reward on Mainnet to announce themselves.

### And one error of mine

I read a payment identifier off a screenshot and transcribed a `0` as an `O`. Pi answered
`payment not found`, and I built an architectural theory on it — *"app payments live in a
different namespace"* — which cost two rounds and two PRs. What ended it was making the
tooling print **Pi's own raw response, unreshaped**: the correct identifier was in it. The
audit records this as §7 rather than quietly dropping it, because the fix is structural —
`resume` should take the identifier from Pi's list, not from a person's eyes.

### The tooling is a button, because the CEO works from a phone

`workflow_dispatch` in `tec-core-backend`, with four guards, because it moves money:
owner-only · an explicit `step` (`preflight`/`list`/`dry-run`/`incomplete` send nothing) ·
`confirm: SEND` typed in capitals · and `usernames` as an explicit allowlist that **fails**
when a named person has no uid rather than quietly paying four. Two boundaries held:
`pi_uid` is read by auth's own script (Forbidden Behavior #3), and the payout goes over
HTTP to the running service — never by importing `sendA2uPayment` into a script, which
would be a second unreviewed way to move Pi.

**Merged:** tec-app **#233** · tec-core-backend **#298 · #299 · #300 · #301 · #302 ·
#303 · #304 · #305**. **Open:** tec-core-backend **#306** · tec-app **#234**.

### The follow-up, same day — and the check that could not be built

Both remaining code items were taken immediately. **tec-core-backend #306 · tec-app #234**
(open at time of writing). Audit §13.

**`resume` reads the id from Pi's own listing.** The step that produced the transcription
error no longer exists. The design decision worth keeping: the extractor returns `null`
for a shape it does not recognise and `[]` only for a shape it does — collapsing those two
would let an unfamiliar answer read as *"nothing is open"*, the exact state a blocked queue
must never be mistaken for.

**The planned claim-time scope check was abandoned, on evidence.** Reading the code first
showed that **nothing records what Pi granted** — auth keeps `uid` and `username` from
`/v2/me` and no column holds a scope. Gating on a field whose presence had not been
verified would have been the §7 mistake again, in a place where it decides whether a
person gets paid.

Reading further found something certain, and worse:

> A payout refused by Pi threw a sentence at whichever admin tapped the button, and then
> it was gone. Nothing on the row, nothing on the claimant's screen — a seat that never
> moved, under the words *"a person sends the Pi by hand, so this is not instant."*

True, and for everyone who signed in before 13 Sep, misleading: the wait has no end unless
they act. **Forbidden Behavior #6 — silent failure in a financial flow — in a form that had
passed review.** Now Pi's own reason is written onto the claim, translated into one
instruction the person can act on (and **null** for anything they cannot — a failure notice
with no action just makes someone think they did something wrong), shown only from a note
the service wrote so an admin's rejection wording can never reach the person it is about,
and the Hub renders it above the reassurance rather than under it.

> **The generalisable half:** the check that was planned could not be built on evidence,
> and the check that could be built was better — it fires on Pi's **actual refusal**
> instead of on a prediction of one, so it needs no assumption about a field nobody has
> seen.

Also moved earlier: `claim()` refuses someone with no Pi identity on record. Pi pays a uid,
so that claim could never be addressed — caught at payout time it cost a person a seat and
a silent wait.

### Open after this session

- **Mainnet App Wallet under review** — nothing to do but wait for Pi.
- **The `wallet_address` re-consent is still uncollected.** The platform now *asks* for it
  (above), but a consent is a fact about people, not about code. Until each user signs in
  again the campaign cannot pay them, and Pi cannot widen a consent already given.
- **`PI_A2U_FEE` is unset**, so every payout costs one extra Horizon round trip to ask
  the network its fee. Correct, and only worth revisiting at volume.

---

## SESSION 56b — the four runtimes: what they actually are, and the order to build them

> **▶ THE ACTIVE PLAN LIVES IN `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md`.**
> It carries a STATUS table that is updated in the same PR as the work. Read it before
> starting anything in DX · Analytics · Nexus · TEC AI · NEXUS IIC.
> **Next action: merge tec-core-backend #306 · tec-app #234 · KB #137.**

A strategy round proposed a new primitive — **NEXUS IIC, an Intent Integrity Compiler** —
plus platform-layer upgrades to DX, Analytics, Nexus and TEC AI, and a SoloHost
distribution channel. Five documents came out of reading the **code** against those
proposals rather than the charters.

| Document | What it settles |
|---|---|
| `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` | The specification: Intent Object, delta, lineage, gate, proof |
| `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` | What the five runtimes actually are, and the bottleneck |
| `audits/FOUR_RUNTIMES_ENGINEERING_REPORT_2026-09-13.md` | Registry drift · the generator argument · Alert's boundary |
| `audits/SOLOHOST_TEC_AI_DX_ENGINEERING_REPORT_2026-09-13.md` | The verified SoloHost contract and what it forbids |
| `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md` | **The plan + live status** |

### The five findings that decide everything else

**1. The right-hand half of the proposed pipeline is already built.**
`tec-identity-service/src/modules/nexus/` is a persisted saga engine — ordered steps,
compensation in reverse, an honest halt at every U2A payment, an idempotent resume from
`payment.completed.v1`. And the proposal's central claim — *the LLM proposes, it never
authorizes* — is **C-47, enforced by a CI job.** Most teams pitching an agent-trust layer
are proposing to build that. **So: NEXUS IIC is Nexus V2 (C-109 §10 Phase 2), not a 25th
app** — roughly 60% built, and the missing 40% is the part that is actually novel.

**2. …but Nexus does not call any service yet.** `NexusStep.service` is *"the owning
service that WOULD execute it."* **There is no external side effect for an execution gate
to gate.** A gate built now would pass every test because nothing on the other side can
fail — which is exactly how the A2U payout path shipped unable to pay anyone. **This is
the bottleneck, and it is chartered work, not new scope.**

**3. Three of the five are not runtimes.** DX and SYSTEM are **read-only seeded catalogs**
and say so in their own source (*"API-key issuance … NOT modeled here"* · *"there is NO
write method here, by design"*). TEC AI is advisory (*"Nothing executes on these"*). So
**SYSTEM cannot answer an authority question at runtime** and must stay off the gate's
decision path; Analytics is eventually consistent and must inform the intent at compile
time, never inside the gate.

**4. The capability registry exists TWICE and has already drifted.** `dx.service.ts` and
`system.service.ts` each hand-maintain the same five ids, two models, two enums,
descriptions that already differ, nothing syncing them — **P2, live on `main`.** Enriching
the DX copy would give the drifting duplicate the fields an agent would *act* on.

**5. A SoloHost package can hold no TEC secret.** Verified against
`github.com/pi-node/solohost`: the image is **public** and answers land in a **plaintext
`.env` on the user's machine**. The `hidden` field type hides a value from the installer
UI, **not from the user**. So the SoloHost edition is a different product —
**bring-your-own-key / local model, no Hub session** — which costs TEC nothing per user
and matches where Pi is going (OpenClaw, MCP, local AI).

### Two corrections to the strategy, worth keeping

- **The App Builder solves the wrong problem.** All 24 apps were cloned from
  `tec-template-base`; they diverged because fixes could not **travel** (Session 46: 18
  apps frozen on `^1.1.0`, 112 unmergeable PRs, 15 placeholder app names), not because
  they started differently. A generator improves day 1 and worsens day 400 — generated
  code is a fork at birth. **Build `dx doctor` (conformance) instead: it works on the 24
  apps that already exist.** The rule: **generate what is thrown away, template what is
  lived in** — which is also why a SoloHost *package* generator is fine.
- **Truth State: the observation was right, the conclusion inverts.** DX and SYSTEM
  carrying `[Future Vision]` is **correct** — the deployed part is a slice, not the claim.
  Nexus is the one mis-stated, in the opposite direction. Fix with per-doc
  `Implementation Status` (the v3.12.0 pattern), not by unifying upward.

### The order, in one line each

```
PHASE 0  truth       merge · re-consent reaches Mainnet users · 3 status sections
PHASE 1  one source  capability registry → manifest + gate · /api/ready
PHASE 2  bottleneck  Nexus steps CALL their services          ◄── everything waits
PHASE 3  the four    Nexus history · Analytics→Alert · AI intents · DX console
PHASE 4  invention   4.1/4.2 are pure — startable TODAY, zero risk
PHASE 5  SoloHost    BYO-key · secret-leak gate · one package
```

> **Phase 0 is the answer to "how does the project get strong."** The rest make it
> capable; Phase 0 makes it honest, it is the cheaper of the two, and it is the only one
> where being late costs something today.

**Shaped by one constraint, stated as a design input rather than an apology:** one person
builds this, with an AI, merging from a phone. Small serial PRs, one verification each —
never four parallel workstreams.

---

## SESSION 56c — Phase 0.2 shipped, and took login down on the way

> **Incident: self-inflicted, ~20 minutes, login down platform-wide.** Merged:
> tec-core-backend **#307** · tec-app **#235**. Prevention: tec-core-backend **#308**.
> Plan status: `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md`.

**Phase 0.2 is done.** The platform can now tell a person that Pi cannot reach them until
they sign in again — `User.pi_scopes` records what a sign-in asked Pi for, `getMe` derives
`needs_payout_reconsent`, and `/hub/campaign` shows one button that signs out. Three
decisions in it are worth keeping:

- **Unknown answers *yes*.** Every account predates the column, so at first everyone is
  asked. A reminder shown to someone who already re-consented costs one tap; one withheld
  from someone who needs it costs them their reward and explains nothing.
- **Absent does not overwrite.** A cached bundle sends no scopes; writing an empty list
  there would turn a re-consented account back into one we nag.
- **It authorizes nothing.** The list is a client claim, so the worst a false one achieves
  is suppressing a reminder to its own author. That is why recording it is acceptable
  where Life's intent store *refused* a client-fed signal (C-106 §4): there the claim was
  **about** a person and read by another app.

### Then the deploy took login down, and every layer of it was ours

```
09:01   #307 deployed. Service healthy. Column does NOT exist — a deploy never
        touches the database, and nothing said so.
09:20:37  db push succeeds:  "Your database is now in sync … Done in 294ms"
09:20:37  EACCES: permission denied, unlink '/app/prisma/client/index.js'
09:20:38 → 09:21:38   restart, restart, restart … roughly every two seconds
09:21   hub.tecosystem.app → "Failed to save authentication data"
```

Three failures stacked, and **none of them was a surprise from outside**:

1. **The deploy pipeline never touches the database.** Every Dockerfile runs
   `prisma generate` at *build* time and `node dist/main` at run time — no push, no
   migrate. So code that reads a new column ships, starts cleanly, and fails on the first
   query that touches it. **Booting proves nothing.** #307's PR body said "needs
   `prisma db push`", which is not a mechanism.
2. **The escape hatch I gave was itself broken.** `npx prisma db push && node dist/main`
   cannot work in this image: `db push` runs `generate` after itself, generate writes
   `/app/prisma/client` — created by **root** at build while the container runs as
   **`appuser`** — it fails `EACCES`, `&&` short-circuits, the app never starts.
3. **The fix and the trap were the same command.** The push had already succeeded in
   294ms. Everything after that was one missing flag.

> **And the log was printing the answer the whole time:**
> `Running generate... (Use --skip-generate to skip the generators)`
>
> This is the second time this platform has been saved by reading what the tool actually
> says rather than theorising about it (Session 46 §6, the trailing space in a Railway
> service name). The difference is that here nobody read it for twenty minutes.

### What changed, and what deliberately did not

`npm run db:push` → `prisma db push --skip-generate`, in **all 10 services that have a
schema** — not only the one that broke. The flag now lives in the repo instead of in
someone's memory, because **the failure mode was a person recalling a flag while
production was down.** `tec-core-backend/CLAUDE.md` gained the runbook, including the
put-it-back step and the ordering rule:

> **Push the schema first, then deploy the code that reads it. The reverse is an outage,
> not a warning.**

**Not done, on purpose:** no `chown /app/prisma appuser` — it would make the plain command
work *and* let the runtime user rewrite its own client, a real widening to spare one flag.
No auto-push on boot — a schema push running unattended on every deploy turns a bad schema
commit into a silent production alteration, which is the wrong trade on a financial
platform. The manual step is deliberate; #308 makes it **safe**, not automatic.

### The lesson, and it is a repeat

C-02 Session 46 §5 already says *"repairing a bug without asking what it was silently
preventing is how a fix becomes an incident."* This is the same family and a sharper
member of it:

> **A fix that needs an unautomated step is not finished — it is a trap with a due date.**
> #307 was correct, tested, reviewed, and merged. It still took the platform down, because
> the step that completed it existed only in a PR description and in my instructions, and
> the instruction was wrong in a way the repo could have made impossible.

Also recorded, because it nearly went worse: **#307 alone broke only NEW users** (the
`create` path always wrote the column, the `update` path only when scopes were sent). Once
the Hub deployed #235 it would send scopes on every login, so the `update` path would carry
the column too and **every** login would fail. The exact overlap window is unknown from
here — but merge order and deploy order are not the same thing, and this plan now treats
them separately.

### Phase 0 status

- **0.1 merge** ✅ · **0.2 re-consent reaches users** ✅ (#307 · #235 merged + deployed;
  `db push` run) · **0.3 `Implementation Status` on C-109 · C-115 · C-110** ☐ next
- Open, unchanged: Mainnet App Wallet under review · `PI_A2U_FEE` unset · **the
  re-consent itself is still uncollected** — the platform now asks, and a consent is a
  fact about people rather than about code.

## SESSION 56d — Phase 1.1 + 1.2: the capability registry stops being two things

Phase 1 step 1.1 shipped as **tec-core-backend #309** and step 1.2 lands here. Together
they close a P2 violation that was live on `main`, and they close it at both ends: the
runtime stops *reading* the duplicate, and CI stops a *third* one from being written.

### What was actually wrong

Two registries held the same five capabilities. **SYSTEM** had `SystemCapability` with
the enum `SystemGovernanceStatus` — the C-94 authority, as C-110 §5 says it should be.
**DX** had `DxCapability` with its own enum `DxCapStatus`, hand-typed beside it. Two
tables, two enums, nothing syncing them, and they had **already diverged**: `analytics-query`
read `DESIGNED` in SYSTEM and `CERTIFIED` in DX.

> A stale description is a bad doc. A stale `status` is a builder told an **uncertified**
> capability is certified — and which answer they got depended on which copy they happened
> to open. C-115 §4 says DX distributes and never certifies; the second table was that rule
> broken in storage.

**#309** made `DxService.listCapabilities()` ask `SystemService` at read time, through the
**service API** — the R-2-clean seam (C-132 §7.5), the same shape already adopted for
VIP → Elite and Elite → Legend, not a cross-module table read. DX keeps only what is
genuinely its own (`use`, `rank`). A capability SYSTEM does not govern comes back
`status: null, governed: false` — **listed, never dropped, never given a DX-local
default**, because presenting an uncertified capability as certified is the one outcome
this must not have (P6).

### 1.2 — the gate, and the single rule it enforces

`manifests/capability-registry.yaml` + `evals/check-capability-registry.sh` — the **20th
KB gate**, built on the pattern already proven on 12 events (C-70 ↔ events-catalog).

`meta.status_authority` names the one place `owner` and `governance_status` may come from.
Every entry repeats it in `status_source`, and the gate fails when any entry names a
different one — or carries a bare `status` field, which is what the DX copy was called.
A declared consumer must assert `stores_status: false`. The remaining checks are the
ordinary ones: required fields, unique `cap_id`, `binds_to` resolving to a real C-doc,
`governance_status` inside the C-94 lifecycle, deterministic ranks.

**The gate was proved to fail before it was trusted** — five deliberate breakages, each
caught: a second `status_source`, a re-introduced bare `status`, a consumer storing its
own copy, a status off the lifecycle, a dangling `binds_to`. *(A test file that cannot
fail is worse than no file — the same lesson this session already learned in jest.)*

Preflight: **21/21**. The new gate needed no edit to `scripts/preflight.sh` — it parses
the gate list out of the workflow, so adding the CI job was enough. That is the design
working as intended, one session after it was written.

### Honest status

- `[Code Verified]`, not `[Runtime Verified]`: #309 is merged but the fix reaches users
  only when `tec-identity-service` redeploys. **No schema change** — so no `db push`, and
  none of Session 56c applies here.
- **The dead columns are still there.** `DxCapability.owner` / `.status` (+ `DxCapStatus`)
  are still written by the DX seed and read by nothing. Expand-contract says stop reading
  first, drop later; the contract half is recorded in the manifest under
  `deprecated_copies` and remains an open follow-up.

### Phase 1 status

- **1.1 collapse the duplicate registry** ✅ (#309) · **1.2 manifest + CI gate** ✅ (this PR)
- **1.3 `/api/ready` separate from `/api/health`** ☐ next — template first, then the fleet.
  Health stays fail-safe and never 500s (NEW-W); ready is allowed, and required, to fail.
- Open, unchanged: Mainnet App Wallet under review · `PI_A2U_FEE` unset · the
  `wallet_address` re-consent is still uncollected.

## SESSION 56e — Phase 2.1: Nexus stops coordinating on paper

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

## SESSION 56f — deployed, and the 404 that only the other service's log could show

Phase 2.1 went from merged to **running in production**, and the last step between those
two was a bug no test in this repo could have caught.

### The deploy, verified rather than assumed

| Step | Evidence |
|---|---|
| Schema | `information_schema` query in `db-identity` returned **3 rows** — `nexus_runs.input` · `nexus_runs.user_id` · `nexus_steps.output` |
| identity-service | ACTIVE on the #313 commit; all consumers booted, including `Nexus Consumer (payment-completed → run resume)` |
| commerce-service | ACTIVE; `/commerce/orders/reserve` · `/release` · `/subscriptions/renewable` all mapped |
| asset-service | ACTIVE; `/api/assets/marketplace/:id/lock` · `/unlock` · `/buy` all mapped |

Each line is a thing that was **looked at**, not inferred from a merge.

### The bug: every asset step was a 404 (tec-core-backend #313)

`tec-asset-service` calls `setGlobalPrefix('api')`. The asset steps built
`/assets/marketplace/:id/lock`; the service mounts `/api/assets/marketplace/:id/lock`.
Every dispatch in `asset-transfer-saga` would have 404'd → step FAILED → saga rollback.
Visible rather than silent — the dispatcher fails closed — but wrong on every run.

**Why it was missed, and this is the part that generalises.** Nothing else in the
platform calls asset-service *directly*: the gateway reaches it through a `pathRewrite`,
and **that rewrite is where the prefix was already written down**. Nexus is the first
direct caller, so there was no precedent to copy. Commerce was right by luck rather than
care — it sets no prefix at all.

> **A unit test with a mocked `fetch` cannot tell you where a service mounts.** The suite
> was green and the code was wrong, because the only source of that fact is the *other
> service*. It was found by reading the callee's boot log — the same move that found the
> trailing space in a Railway name (Session 46 §6) and the `--skip-generate` hint
> (Session 56c). Three times now, the answer was printed by the tool and not read.

**The fix moves the prefix off the step and onto the service** (`asset: { prefix: '/api' }`).
Repeat a prefix per step and the next asset step is one omission away from the same 404;
declare it once and that step cannot get it wrong. `baseUrlOf` also tolerates an env value
that already carries the prefix — `/api/api/assets` is the same 404 wearing a hat.

### A second lesson, about error responses

GitHub returned `500`/`502` on six consecutive attempts to open the KB pull request. I
reported that it could not be opened and asked for it to be opened by hand. **It had
already been created on the first attempt** (#142) — the write succeeded and the response
failed.

> **A 5xx on a write means UNKNOWN, not FAILED.** The same discipline this platform
> applies to a dispatch timeout — *"ambiguity resolves to did-not-happen, because the
> idempotency key makes the retry safe"* — has a mirror image: when the retry is **not**
> idempotent, check whether the thing exists before saying it does not. Reporting a
> failure that did not happen is the same error as reporting a success that did not.

### Status

- **2.1 is now `[Runtime Verified]` for deployment, not yet for execution.** The services
  are live and reachable on the right paths; no run has been driven end to end. That last
  step is a real `checkout-saga` or `subscription-renewal` against production.
- `/api/ready` fleet rollout (1.3) still open across the 20+ apps.

## SESSION 56g — Phase 3: the runtimes start talking, and one of them starts listening to people

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

## SESSION 56h — Phase 4 begins: what a human authorized, and a delta that only narrows

`tec-core-backend #316` — IIC **4.1 + 4.2** in `tec-identity-service`. A module beside the
engine it extends, not a new service (C-132; no T1–T4 trigger exists).

> ⚠️ **SCHEMA PUSH REQUIRED.** `npm run db:push && node dist/main` as the Railway start
> command on `tec-identity-service`, redeploy, then put it back. Two additions: the
> `intents` table + `IntentStatus`, and `nexus_runs.intent_id`. Push BEFORE deploying the
> code that reads them — the reverse is an outage, not a warning (Session 56c).

### 4.2 — one asymmetry does all the work

```
Narrowing is always allowed.  Widening never is.
```

An agent may spend less, exclude more, trust a narrower set or finish sooner without
asking. It may not spend more, reach a service it was not given, remove a human
checkpoint, or buy itself time. Every widening is CRITICAL, and CRITICAL means a new
human signature — not an agent's assertion that it is fine.

**The comparand is the human-signed ROOT, and there is no variant that takes a
predecessor.** No single step widens a budget from 250 to 400; five steps widen it by 30
each and every one looks reasonable beside the step before it. A test walks that exact
path.

**Where the thinking actually went: being honest about what cannot be compared.**

| Case | Verdict, and why |
|---|---|
| A hard constraint whose value is a **string** | CRITICAL. There is no ordering on strings, so `zone_verified → any_seller` cannot be shown to be a tightening. A trust LADDER would let this be ordered — invented silently, it would be a ranking nobody signed. |
| The **operator** changed | CRITICAL. A different relation is not a narrowing. |
| `hard` re-classed to `soft` at the same value | CRITICAL. The subtlest widening in the spec: nothing moved, and the limit stopped being a limit. A diff comparing values alone reports "no change". |
| A ceiling set to `null` | CRITICAL. `null` means unlimited — the largest widening there is, and the one an off-by-one would let through because no number in the file ever showed it. |

A delta that only knew how to compare numbers would have passed every one of those.

### 4.1 — a DRAFT authorizes nothing

Only `confirm()` — an explicit act by the owner — makes an intent citable. A revision is
a NEW ROW under the same `root_id`, never an edit, which is what keeps the signed root
reachable at version 6. Someone else's intent is NOT FOUND rather than forbidden: telling
a caller an id exists but is not theirs answers a question they had no right to ask.

`NexusRun.intent_id` is nullable and additive — every run today has none and behaves
exactly as before. **But a nullable foreign key with no rule is a comment in a table**, so
`startRun` asks `IntentService` (a service API — the R-2-clean seam, C-132 §7.5) whether
the cited intent is the caller's own, CONFIRMED and unexpired, and creates nothing if not.

This **records**; it does not gate. `/check` returns a verdict rather than enforcing one —
enforcement is 4.4, in front of the dispatcher, and two places answering "may this
proceed" is the duplication the last several sessions were spent removing.

### The bug the tests caught

`fingerprintOf()` was hashing **preferences**. TypeScript's structural typing accepts a
wider object for a `BindingFields` parameter, so passing the whole normalized intent
compiled cleanly and quietly included `preferences` and `temporal`.

> Every legitimate re-ranking would have moved the fingerprint — making the one signal
> that detects real drift fire constantly. **A signal that fires constantly is one nobody
> reads**, which is the same failure as the detector in 3.2 that fires on noise. §4.2 says
> preferences are excluded; the function now PICKS its five fields instead of trusting its
> parameter type.

### Status

- 1154/1154 green (55 new), typecheck + build clean. `[Code Verified]`; it becomes
  `[Runtime Verified]` after the schema push and a deploy.
- **Next: 4.4** — `intent.gate.ts`. Everything it needs now exists: 2.1 made the
  dispatcher real, 4.1 gave a run an intent to cite, 4.2 produces the verdict. It is the
  first step where this layer stops recording and starts refusing.

## SESSION 56i — the gate: the intent layer stops recording and starts refusing

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

## Session 56j — CI economics: one deploy path, one concurrency rule (29 repos)

GitHub Actions stopped running some time after **13:20 on 2026-09-13** — a **$29.00 payment
declined that day**, with the Actions budget standing at **$56.95 of $65**. Both halves
matter: fixing the card alone would not settle it, because the cap closes it again within
days. So the session's work was chosen to be the kind that *makes the bill smaller* rather
than the kind that waits for it — and none of it needs CI to verify, because none of it
ships product code.

> **Two diagnoses corrected here, both stated more confidently than the evidence allowed.**
>
> **(a)** An earlier theory blamed a Cursor integration. That was a **timing correlation,
> not a cause**; the Billing page settled it.
>
> **(b)** This block first said Actions was "disabled account-wide". The run history says
> otherwise: `tec-core-backend` `ci.yml` **#1009 (12:50, pull_request) and #1010 (13:20,
> push→main) both SUCCEEDED**, as did `knowledge-ci` #493 at 13:01 — the same day, after
> the decline. **Nothing has run since 13:20.** "Blocked account-wide" and "stopped
> mid-afternoon" lead to the same decisions here, but they are not the same fact, and a
> current-state doc that rounds one to the other is the thing this file exists to prevent.

### The `startup_failure` runs are NOT this, and NOT the workflow edits

Every push after 13:20 produced a run with an **empty name**, `path: "BuildFailed"`, and
conclusion `startup_failure`. It is tempting to read that as "the edited workflow is
broken". The workflow IDs say it is neither:

| Repo | The repo's own workflow IDs | The ID that fails |
|------|------------------------------|-------------------|
| tec-core-backend | `267506050–058` · `269818770` · `356608251` | **`357122187`** — in no listing, and already at `run_number 15` |
| Tec-Zone | `307100294` (ci) · `307100296` (e2e) | **`357260488`** |

Two facts settle it: the failing workflow is **not one of the repo's files** (all of them
are listed, `state: active`, with their own IDs), and in tec-core-backend it had **already
failed ten times before any workflow was edited today** — it is the "(Unnamed workflow) /
Startup failure" the CEO screenshotted this morning, hours earlier. A per-repo ID created
2026-09-13 that appears in no listing is GitHub-side (an agent/dynamic workflow), not ours.

> **The trap this avoids is the mirror of Session 46 §5's.** There, a fix produced a red
> run and the instinct was to explain it away. Here, a red run appeared *beside* a change
> and the instinct is to assume the change caused it. Both instincts are answered the same
> way: read the identifiers the tool prints. The workflow ID is four characters of evidence
> and it is worth more than the coincidence in timing.

**What remains genuinely unverified:** no run has *executed* any edited workflow, so GitHub's
workflow parser (stricter than YAML) has not accepted them. The `concurrency` expression is
the exception — it is the one `knowledge-ci.yml` has carried through **492 successful runs**.

### 1. Railway owns deploy — the racing second path is gone (tec-core-backend)

Every service has Railway's GitHub integration connected (Source Repo · Root Directory ·
Watch Paths `/tec-<service>/**` · production branch `main`) — **confirmed by the owner for
all services**. `ci.yml` *also* ran `railway up` on the same commit: **two independent
writers to one production service, racing.** Not redundancy that adds safety; a race that
doubles build spend on both sides and makes "which build won" unanswerable from the logs.

**The job's one advantage was an illusion, and this is the transferable part.** It was
gated on `docker-build` — but **"Wait for CI" is OFF on every service**, so Railway shipped
the commit regardless of whether the pipeline was red, or (as now) whether it ran at all.

> **A gate standing beside an ungated path is not a gate.** Keeping it was false comfort,
> and false comfort is worse than a known gap, because nobody goes looking for it. Same
> family as the `exit 0` deploy that reported success for four months (Session 46 §5a) and
> the `|| true` job below.

Removed with it: **`RAILWAY_TOKEN` / `RAILWAY_PROJECT_ID`** — a production-write credential
— out of a workflow that runs on every push (no workflow references either secret now;
they can be revoked), and `permissions.id-token: write`, which existed only for that job.
`push: [main]` **stays**: it is the status Railway reads once Wait-for-CI is ON, and the
only run that tests the *merged* tree rather than the PR head.

**To restore the gate: Railway → each service → Settings → Deploy → Wait for CI = ON.**
That gates the deploy that actually happens instead of adding one that races it. It means
nothing while Actions is disabled, so it belongs with the billing fix — not before it.

### 2. `concurrency` — the same rule, in the same spelling, in 29 repos

A second push to a PR branch used to leave the first pipeline running to completion beside
it: five CI jobs, a CodeQL analysis, and a Playwright install-build-and-run, all answering
a question about a commit nobody would look at again.

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

`main` is **excluded on purpose** — a run there is the post-merge record and the status a
deploy gate reads.

> **The rule already existed in this platform, twice, spelled two different ways.**
> `tec-knowledge-base/knowledge-ci.yml` had the form above. `tec-app/ci.yml` had
> `cancel-in-progress: true`, which also cancels `main` runs. **Every other repo had
> neither** — and the root cause is one line long: **`tec-template-base` did not have it**,
> so all 23 apps cloned from it were born without it.

**This is the third instance of the identical failure** (C-02 Session 46: the `^1.1.0`
caret trap froze 18 apps out of the palette; the Dependabot policy solved in the template
and never back-adopted). The pattern is now explicit enough to name:

> **A rule that lives in one repo and not in the template is a rule the fleet does not
> have.** Propagating it to the repos that exist fixes today; writing it into
> `tec-template-base` is the only step that stops the next app from needing the sweep.
> Both were done — the CLAUDE.md rule is the more important half.

### 3. Two jobs that could not fail, and one that duplicated another

| Removed | Why |
|---|---|
| CodeQL `push: [main]` (28 repos) | The `pull_request` run analysed that exact code; merging re-analysed it minutes later for the same answer. The weekly `schedule` run still covers the default branch, so the Security-tab baseline — what ages and closes alerts — keeps refreshing, **weekly rather than per-merge**. PR coverage unchanged, main coverage coarser: written into the file, not left to be discovered. |
| `weekly-scan.yml` schedule → `workflow_dispatch` only | Every Sunday: install + audit + lint + build + test across the full service matrix **against code that had not changed since the last run** — a duplicate of `ci.yml`. Its one unique step (`npm audit --audit-level=high`, unguarded) is covered by Dependabot across all 15 configured ecosystems, natively, at **zero Actions cost**. The capability is kept on demand; only the recurrence is removed. |
| `dependency-update.yml` **deleted** | `npm outdated \|\| true` and `npm audit \|\| true` — **the job could not fail under any circumstance.** A green tick every Monday, gating nothing. **A check that cannot fail is not a check**; it is a check-shaped thing that teaches people the signal is noise. |

Tag-triggered workflows (`release.yml`, `publish.yml`) deliberately get **no**
`concurrency`: a release or an npm publish must never be cancellable mid-flight.

### 4. A settings reading that closed an open question — and corrected a runbook line

The identity-service Settings screen showed Custom Start Command `npm start` and
Pre-deploy Command `npm run migrate`. **Both are Railway's grey placeholder text, not set
values**, and the proof is one grep: **no `package.json` in tec-core-backend defines a
`migrate` script**, so a Pre-deploy actually set to `npm run migrate` would fail every
deploy with `Missing script: migrate` — and deploys succeed. (`npm start` resolves to
`node scripts/migrate.cjs && node dist/main.js`, byte-identical to the Dockerfile CMD, so
even if set it would be harmless.)

> Session 56i's rule stands and is now **verified rather than asserted**: for
> `tec-identity-service`, leave the start command empty and let the image migrate itself.
> A placeholder is not a value — and a screenshot cannot tell you which it is. The
> repository can.

### Status

- **29 PRs**: 28 fleet PRs (`chore(ci): stop paying for runs nobody reads`) + the backend's
  two `chore(ci)` commits riding on #316, which is also the IIC 4.1/4.2/4.4 PR.
- **Verification without CI**: every touched workflow re-parsed with `yaml.safe_load` after
  editing **and again after each branch was repositioned onto `main`** — 0 failures across
  every workflow in every repo; every `ci`/`e2e`/`codeql` file carries the canonical
  expression; no `codeql.yml` retains a `push` trigger. Applied by a fail-closed script
  that skips and reports any file not matching the expected shape rather than guessing.
- **Ops, when billing is fixed:** revoke `RAILWAY_TOKEN` + `RAILWAY_PROJECT_ID` (now unused),
  and decide on **Wait for CI = ON** per service.


## Session 56k — Three credentials out of CI, and a uniqueness assumption that would have paid the wrong person

Follow-on from 56j. That session removed `RAILWAY_TOKEN` as a side effect of
deleting a racing deploy job; this one went looking on purpose and found two more
things in the same shape.

### What was in GitHub Secrets, and what is left

| Secret | Was | Now |
|--------|-----|-----|
| `RAILWAY_TOKEN` · `RAILWAY_PROJECT_ID` | production-write, on every push (56j) | **deleted** |
| **`AUTH_DATABASE_URL`** | a connection string to the **identity authority's database**, injected into a GitHub Actions runner | **deleted** (#317 → #318) |
| `API_GATEWAY_URL` · `INTERNAL_SECRET` · `NPM_TOKEN` | in use | kept — each verified to have exactly one consumer |

**Three credentials left CI in one day, two of them production access.** The audit
that found them was four greps: for each secret, which workflow actually references
it. A secret nothing references is pure attack surface; a secret ONE workflow
references tells you where to look.

### The Testnet A2U payout read auth-service's database from a runner

`list-pi-uids.mjs` resolved usernames → Pi uids with `prisma.user.findMany` over
`AUTH_DATABASE_URL`. Read-only, and still two violations: reading that table from
outside the service is **Forbidden Behavior #1**, and auth owns Identity
(**Invariant #8**), so the lookup was in the wrong place.

Replaced by `GET /api/auth/uids-by-usernames` behind `x-internal-key`. **No new
secret** — the gateway accepts a matching internal key in place of a user JWT
(`jwt-auth.ts`, `timingSafeEqual`), which is the sanctioned service-to-service
path, so the two secrets the payout already held were enough.

### It is not a relocation of the query. It is a better one.

| | the DB script | the endpoint |
|---|---|---|
| Read scope | **every** row with a uid, filtered in memory | only the names asked, capped at 50 — **cannot become a dump** |
| A name on two accounts | — | **every** matching row |
| A row with no `pi_uid` | returned | omitted |
| Cost of one query | `npm ci` + `prisma generate` | Node built-ins, no install |

> **THE FINDING, and it was hiding in the schema:**
>
> ```prisma
> pi_uid       String?  @unique
> pi_username  String?            ← no @unique
> ```
>
> **A Pi username can belong to two accounts.** `findFirst` — the natural shape
> for "resolve a name to a uid", and what any reasonable person writes — would
> have picked one **by row order** and paid a person the operator never looked at.
> Silently. With real Pi.
>
> The payout script already had a `duplicate` marker for exactly this, and it only
> works if both rows reach it. The endpoint returns all of them and a test pins it,
> with the reason written next to the code so nobody "simplifies" it later.

### The distinction the database could not make

A DB query that returns nothing and a network that never answered look identical
to a caller — an empty list. On a run about to pay people, those are opposite
facts. The resolver separates them:

```
a named person with no account  → exit 1, "NOT FOUND: ghost … has not signed in yet"
wrong INTERNAL_SECRET           → exit 1, "that is a KEY mismatch, not a missing user"
gateway unreachable             → exit 1, "this says nothing about whether these accounts exist"
```

Same family as C-135 §4 (Explorer returns `source:'unavailable'` rather than a
fixture) and the Session 46 `exit 0` deploy: **an absence must never be reported
as a finding.**

### Order, and why it was three PRs and not one

`expand → migrate → contract`, the sequence used for the `user.created.v1` rename
(Sessions 23–24):

| | PR | Gate before the next step |
|---|---|---|
| expand | **#317** — endpoint added, nothing calls it | merged **and deployed** — proven by auth-service's boot log: `Mapped {/uids-by-usernames, GET}` |
| migrate | **#318** — the payout calls it; the DB step is gone | verified on `main` itself (not the branch) that no step still consumes the secret |
| contract | — | `AUTH_DATABASE_URL` deleted from repository secrets |

**#317 was split out of #316 onto its own branch, deliberately.** #316 migrates
`identity-service`'s schema and is waiting for an attended window; the auth change
had no such constraint. Bundled, one merge would have deployed the schema migration
AND the platform's login authority together — and left no way to tell which caused
a problem.

> **A deploy that does NOT happen can be the correct outcome.** #318 touched only
> the workflow and a payment-service script, so auth-service did not redeploy —
> its Watch Path (`/tec-auth-service/**`) saw nothing. Reading that as "the merge
> failed" would have been the wrong conclusion; it is the Watch Paths working.

### Honest status

- `[Runtime Verified]` for the endpoint (it is answering in production).
- `[Code Verified]` for the payout switch: the resolver was exercised against a
  **stub** gateway, not prod. It becomes Runtime Verified the next time a real
  `step: list` is run.
- auth 77/77 · payment 295/295 · both typecheck clean · mutation-tested (dropping
  the uid filter fails exactly one test; removing the cap fails exactly one other).
  All local — Actions has not run since 13:20 on 2026-09-13.


### The sweep continued across the fleet — and Tec-App was the only real exposure

Having found one, the same question was asked of every repo: **for each stored
secret, which workflow actually references it?** Workflows are readable from the
repo; the stored list is a Settings page, so this was CEO-screenshot + local grep.

| Repo | Stored | Verdict |
|------|--------|---------|
| **`Tec-App`** | 6 | 🔴 **`INTERNAL_SECRET`** · `AUTH_SERVICE_URL` · `PAYMENT_SERVICE_URL` + 3 public — **CI referenced exactly one of the six**. All deleted. |
| `tec-core-backend` | 4 → 3 | `AUTH_DATABASE_URL` deleted (above); the rest each verified to have one consumer |
| `Tec-Assets` | 2 | `NEXT_PUBLIC_API_GATEWAY_URL` dead in BOTH workflow and source → deleted |
| `Tec-Commerce` · `Tec-Ecommerce` | **0** | Correct as-is — every reference has a written fallback |

**`INTERNAL_SECRET` in the Hub's CI was the find.** The platform generates ONE value
for the gateway and every service (`CLAUDE.md`: *"generate once, same value for ALL 4
services"*), and the gateway accepts it **in place of a user JWT** — verified this same
session in `jwt-auth.ts`. A copy in a frontend repo's CI is a copy of the key to the
entire backend. It had sat there five months, referenced by nothing.

> **A correction to something claimed earlier in this session.** `Tec-Ecommerce`'s
> `ci.yml` *references* `secrets.INTERNAL_SECRET`, which was read as "the one frontend
> repo where the master key is used in CI". Its secret store is **empty** — the workflow
> has always fallen through to `'ci-test-secret-minimum-32-chars!!'`, which is the
> correct shape for a build. **A reference is not a possession.**

**The pattern:** every one of these dates to repo creation ~5 months ago — added
"just in case" before anyone asked what CI needed. The runtime consumer is **Vercel**,
a separate store. Deleting from GitHub cannot affect a running app, and saying so was
what made the deletions safe to do from a phone.

### NEW-A: a false alarm, settled by a build rather than a grep

The sweep surfaced `NEXT_PUBLIC_API_GATEWAY_URL` read by source in **17 repos**, and a
hardcoded Railway host committed in **32 source files**:

```ts
// src/lib/sdk.ts — in tec-template-base, therefore in every app cloned from it
const gatewayUrl = process.env.NEXT_PUBLIC_API_GATEWAY_URL
  ?? 'https://api-gateway-production-6a68.up.railway.app';
```

`NEXT_PUBLIC_*` is inlined into the browser bundle at build time, so this read as
**NEW-A reopened across 17 apps live on Mainnet** — a finding recorded as ✅ CLOSED.
It was raised as exactly that, and then checked instead of reported:

```
Tec-Explorer (has the literal, reads the var in 3 files)
  grep -rl "railway.app" .next/static/   →  0
  grep -rl "railway.app" .next/server/   →  0
  grep -rl "tec-sdk"     .next/*         →  0
```

**`src/lib/sdk.ts` is dead code** — imported only by `lib-client/pi/pi-auth.ts`, and
that chain reaches no bundle, so tree-shaking removes it entirely. **NEW-A is genuinely
still closed.**

> **The lesson, and it generalises past this file:** a `grep` over SOURCE proves the
> line exists. It does not prove the line ships. **Only the build knows** — and the
> check cost one command against an artifact that was already on disk.
>
> This is the mirror of the same session's other trap (reading a red run beside a
> change as caused by it). Both are answered the same way: measure the thing you are
> actually claiming, not the thing that is easy to measure.

**What remains is real but small:** dead code carrying a production hostname is not a
leak today; it is a loaded gun. The moment a client component imports `sdk`, the host
ships. It also crosses the Two-SDK boundary inside one file (`@yasser172/tec-sdk` is
server-only by its own rules, beside browser auth helpers). **Delete it from the
template and the 17 apps** — not urgent, but unjustified.

### npm token expiry — not mandatory, and the workaround is to remove the token

Session 46 left "npm Trusted Publishing" open with a deadline: `NPM_TOKEN` in
`Tec-ui` · `TEC-SDK` · `tec-auth` expires **25 Nov 2026**. The question asked was
whether that expiry can simply be made longer. It can be removed instead.

**The objection that had to be checked first** is written in the repos' own
`publish.yml`:

> *npm provenance is intentionally NOT used — this source repo is PRIVATE, and npm
> provenance only supports PUBLIC source repos (422 "Unsupported source repository
> visibility: private").*

That comment is correct, and it is about **provenance**. **Trusted Publishing is a
different mechanism and is available for private and public packages alike** — so the
constraint that blocks one does not block the other. Confirmed against npm's docs
rather than assumed, because if the restriction had been shared the whole plan was void.

**The gap is one line per repo:** Trusted Publishing needs npm CLI ≥ 11.5.1 and Node
≥ 22.14.0; all three `publish.yml` pin `node-version: '20'`. `permissions: id-token:
write` is already present in all three.

**Order matters — npmjs.com FIRST:**

```
1. npmjs.com → each package → Trusted Publisher → GitHub Actions + repo + publish.yml
2. PR: node-version 20 → 22, drop NODE_AUTH_TOKEN / NPM_TOKEN from the workflow
3. after one successful publish → delete NPM_TOKEN from the three repos
```

Doing 2 before 1 fails the publish with 401. And from the record: when the token last
lapsed (26 Aug) the failure was **`E404`** — on a scoped package, `E404` on `PUT` means
**auth failure**, not "package not found". If that appears again, it is the token.


## UPDATE PROTOCOL

```
آخر كل session — قبل الإغلاق:
☐ أضف لـ DONE كل حاجة اتخلصت
☐ احذف من PENDING كل حاجة اتحلت
☐ حدّث NEXT بالأولوية الجديدة
☐ حدّث Last Updated
```
