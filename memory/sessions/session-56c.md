# SESSION 56c — Phase 0.2 shipped, and took login down on the way

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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
