# Session 56j — CI economics: one deploy path, one concurrency rule (29 repos)

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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

**To restore the gate: Railway → the SERVICE → Settings → `Source` → Wait for CI = ON.**
That gates the deploy that actually happens instead of adding one that races it. It means
nothing while Actions is disabled, so it belongs with the billing fix — not before it.

> **Corrected 2026-09-17, on the CEO's screen.** This line read `Settings → Deploy` from
> the day it was written, and it is not there. The toggle sits under **Source**, directly
> below "Branch connected to production". The owner went looking in the project's own
> Settings first — which has no such toggle at all, only Environments / Shared Variables /
> Tokens / Danger — then in the service's Deploy section, and found it in neither.
>
> Two levels of "Settings" exist in Railway and the note named neither: the PROJECT's and
> the SERVICE's. **A path written from memory reads exactly like a path someone verified**,
> and this one was carried verbatim into `ci.yml` and a PR body before anyone stood in
> front of the screen. Both are corrected.

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
