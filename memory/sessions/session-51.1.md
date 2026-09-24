# SESSION 51.1 — THE DESIGN PASSES, AND THE INTERFACE LIFE WAS BUILT FOR (4 Sep 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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
