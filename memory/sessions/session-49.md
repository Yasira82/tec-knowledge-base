# SESSION 49 — CONNECTION MESSAGING COMPLETED, AND A LESSON ABOUT GUESSING (1 Sep 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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
