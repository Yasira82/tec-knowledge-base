# SESSION 48 — THE ISSUE QUEUE REACHES ZERO (28 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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
