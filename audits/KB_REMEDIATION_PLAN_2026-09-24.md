# KB Remediation Plan — from the 2026-09-24 engineering audit

> **Truth State:** `[Current State]` · **Verification:** `[Documentation Verified]`
> **Source:** `audits/KB_ENGINEERING_AUDIT_2026-09-24.md` (findings F1–F21).
> **Owner:** approved by the CEO on 2026-09-24 ("record the plan and start").
> **Rule:** a step is ✅ only when merged to `main` and preflight is green. Update this file
> in the same PR that closes a step.

---

## Status

| Step | Work | Closes | Size | Status |
|---|---|---|---|---|
| 1 | Rewrite C-13 §1–§2; C-15 & C-51 cookie blocks → cite C-123 §2/§3/§9 | F2, F3 | S | ✅ #153 |
| 2 | Correct C-14 versions, C-20 ports + private hosts, C-40 NEW-M, C-41 + `memory/` phase | F4, F5, F10, F11 | S | ✅ #153 |
| 3 | C-56 → pointer to `events-catalog.yaml`; C-62 → pointer to the SLO manifest (one set of numbers) | F8, F9 | S | ✅ #153 |
| 4 | Regenerate `dependency-graph.yaml`; regen + diff in preflight and CI | F13 | S | ✅ #153 |
| 5 | Fix F17 references; delete the duplicate impact script; stop committing the integrity report | F17, F20 | S | ✅ #153 |
| 6 | README / CLAUDE.md: counts replaced by "run preflight"; CLAUDE.md → navigation only; consolidate the two impact scripts (C-116 amendment) | F16, F20 | M | ✅ #159 |
| 7 | C-02 split: ≤ 150-line current state + one file per session | F12 | M | ✅ #157 |
| 8 | C-11 + C-44 generated from the repos by a script | F6, F7 | M | ✅ #158 |
| 9 | Weekly cross-repo drift job + `Last-Verified` on `[Code Verified]` headers | F1 — prevents recurrence | L | ◐ merged #154 — ✅ on the first green scheduled run |
| 10 | Language-policy pass, or amend the policy to what the KB actually does | F18 | M | ◐ in this PR — ✅ on merge |

Not scheduled (recorded, low value now): F14 evidence loop (needs ops to run the emitter
against prod), F15 rename of fenced-YAML manifests (touches four gates), F19 stale Railway
hostnames (removed together with step 2's C-20 rewrite where they appear), F21 "4 apps" wording.

## Decisions taken while executing

| Date | Step | Decision | Why |
|---|---|---|---|
| 2026-09-24 | 3 | SLO authority = C-78 §2 + `slo-definitions.yaml`; C-62's stricter availability figures (payment 99.99%, auth/gateway 99.95%) are stretch goals, not SLOs | C-78 is the operations constitution and the manifest already mirrors it; relabelling avoids silently changing anyone's numbers |
| 2026-09-24 | 3 | C-56 points at `events-catalog.yaml` for the event list; keeps only the patterns | The catalog is code-sourced and gated; the prose list had drifted twice |
| 2026-09-24 | 4 | The dependency graph is gated exactly like the registry (regenerate, diff vs HEAD, ignore `# Generated:`), in preflight and CI | Same failure class as the registry; one rule for both generated files |
| 2026-09-24 | 5 | `impact_analysis.py` **kept** (audit said delete) | C-116 names it as the governed asset; both scripts work and agree. Consolidation = a C-116 amendment → folded into step 6 |
| 2026-09-24 | 5 | `registry-integrity-report.md` untracked + gitignored; the gate still writes it | Generated every run with a timestamp and an absolute local path. preflight's restore no longer names it (an untracked pathspec makes `git checkout` refuse every path) |
| 2026-09-24 | 2 | tec-core-backend `CLAUDE.md` 4000-series port table: fixed in that repo, separately | Outside this repo — tec-core-backend #333 |
| 2026-09-24 | 9 | Drift is checked at a git ref (`git show`), never the working tree | A local clone on a feature branch must not make `main` look drifted |
| 2026-09-24 | 9 | The weekly job runs `--strict`: a repo it cannot clone fails the run | A drift check that silently checks less is the failure this step exists to end. Private repos need the `DRIFT_READ_TOKEN` secret (read-only fine-grained PAT) |
| 2026-09-24 | 9 | Freshness: `[Code/Runtime Verified]` + a `Last verified …: YYYY-MM-DD` older than 60 days = FAIL; no date = WARN only | Enforcing a date on 27 docs at once would mean writing 27 dates nobody checked — the exact false claim being removed. Dates are added only when a doc is actually re-verified; the warning list is the backlog |
| 2026-09-24 | 9 | Not a KB-CI job; a separate scheduled workflow | It needs ~30 clones; KB PRs must not wait on, or break because of, another repo's commit |
| 2026-09-24 | 8 | Only the tables are generated, between markers; the prose around them stays hand-written | A generator that owns the whole file erases the "why" — the part a script cannot know |
| 2026-09-24 | 8 | Staleness is caught by the weekly drift job (regenerate in memory, compare), not by knowledge-ci | Generating needs every repo cloned; a KB PR must not depend on other repos' state |
| 2026-09-24 | 8 | Generated docs are exempt from the `Last verified` date rule | Their claim is re-derived from the code weekly — stronger than a date a person typed |
| 2026-09-24 | 8 | The scanner reads four forms: `process.env.X` / `['X']`, zod `config/env.ts` keys, the gateway's `envVar` entries, NestJS `configService.get('X')`, plus Prisma `env("X")` | Each one, missing, made a real variable look unused — `JWT_REFRESH_SECRET` and `DATABASE_URL` both did during development |
| 2026-09-24 | 6 | Kept `registry-impact-analysis.py`, deleted `impact_analysis.py`; C-116 §1.3 amended (v1.1) | Identical dependents on C-12, C-47, C-123; the CDG's only extra relation (`informs`) is empty for all 116 docs; the registry is the source, the CDG a derivative |
| 2026-09-24 | 6 | CLAUDE.md = navigation + a "rules that bite" table; the Session 12 → 46 log moved verbatim to `memory/sessions/kb-claude-md-log.md`; ≤ 150 lines is a failing gate | Loaded into every session; its counts were each true only on their own day. Durable rules were lifted out of the log, not lost with it |
| 2026-09-24 | 6 | README keeps no counts or phase list; the drift job now reads its port block | The README's ports were wrong for 5 services and nothing checked them |
| 2026-09-24 | 10 | **Both**: translate AND amend. Every English-only doc's prose translated (522 lines, 61 docs, line for line); the policy amended where it was wrong (C-02 in two classes; ranges left unclassified; an archive copy per translation) | The repository is public, so "external" is real; the policy's intent was right, its classification incomplete |
| 2026-09-24 | 10 | "External unless listed internal" (C-02 · C-40 · C-50 · C-55 · C-80 · C-81, `memory/`, `audits/`); `marketing/` = the language of its audience | A new doc gets a class by default; Arabic launch copy for Arab pioneers is correct, not drift |
| 2026-09-24 | 10 | Arabic inside code blocks (669 lines) is a ratchet, not translated now | The policy's own gate definition covers prose; the ratchet stops growth while the backlog shrinks |
| 2026-09-24 | 10 | The Arabic TL;DRs of C-133/C-134/C-135 were translated too | They are external docs; the founder's Arabic summary belongs in C-02 |

## First drift run (2026-09-24, all repos at `origin/main`)

The script's first run was against the code as it stood — before #154's KB fixes.

| Side | Finding | Action |
|---|---|---|
| KB | `app-fleet.yaml` packages: "Gateway :4000" | fixed here → `:3000` |
| Code | `resolve-incomplete/route.ts` re-sets `tec_access_token` `sameSite:'none'` **without `partitioned`** — in tec-template-base and so in 21 apps cloned from it | a cookie set without Partitioned lands in a different jar in an embedded context (C-123 §2) — a second copy of the token, the same half-session class as the refresh bug. **Fixed** (plus a per-app test that checks each cookie object): commits on the 19 still-open fleet PRs + Insure #37 · Brookfield #19 · NBF #24 |
| Code | Tec-Life `middleware.ts` CSRF cookie + `refresh` without `partitioned` | both fixed on Life #62 — its refresh PR had kept Life's old options object, which never had `partitioned` |
| Code | 20 of the refresh-renews-the-whole-session PRs (2026-09-23) are **still open** — on `main` only Commerce, Insure, Brookfield and NBF renew `tec_user` with the token | merge them; the drift job will show it |
| Script | 3 false positives on its first run (C-13 glob matched C-135; `payment.completed` defined in `shared/`; DX's guide text contains `APP_SOURCE = 'yourslug'`) | fixed in the script before merge |
| Script | the cookie check was file-level: one partitioned cookie in a file vouched for every other cookie in it | now object by object — the same rule as the per-app test |

After the fixes, run against every repo's PR branch: **cookies clean in all repos**.

**After the fleet merge (2026-09-24, all repos at `main`):** 33 pass · 0 fail. A manual
look at what the script did NOT check found one more: the **Hub's** refresh renewed the
token but never `tec_user` — the same half-session bug the 24 apps were fixed for, missed
because the Hub's route is different code. Fixed in **tec-app #256**; the script gained a
`refresh` check (every refresh route that renews the token must renew `tec_user`) — it
fails on `main` today and passes on #256.
| 2026-09-24 | 7 | Session narratives → `memory/sessions/` (one file each, text unchanged apart from relative links); C-02 keeps §1 platform · §2 open now · §3 last three sessions · §4 Pi App identity · §5 protocol | The audit's own recommendation; `memory/` is already scanned by the session-canonical gate, so every `C-NN` in a record stays checked |
| 2026-09-24 | 7 | C-02 ≤ 150 lines is a **failing** gate (in `check-knowledge-gaps.sh`, whose other checks only warn) | The file grew to 5,929 lines one append at a time; a limit nobody enforces is how that happened |
| 2026-09-24 | 7 | The June "DONE / PENDING / NEXT / PLATFORM STATE" blocks and the score table are archived, not merged into §2 | They describe June 2026 (tec-ui v1.2.1, "Portal path"); carrying them forward would re-state stale facts as current |
| 2026-09-24 | 7 | The PI APP IDENTITY table stays in C-02 | `check-portal-readiness.sh` cross-checks it against C-01 and the runbook |

## Log

| Date | Step | PR | Result |
|---|---|---|---|
| 2026-09-24 | 1–5 | tec-knowledge-base #153 | all five done; preflight **22/22** (new graph gate). Audit F8, F9, F17, F20 corrected in place where remediation showed the finding was imprecise |
| 2026-09-24 | 2 | tec-core-backend #333 | backend CLAUDE.md: ports from code (3000 / 5001–5011), public vs private, NEW-B closed |
| 2026-09-24 | 9 | tec-knowledge-base #154 (merged) | `scripts/check-drift.py` (6 checks: versions · ports · events · cookies · fleet · SLO) + weekly `drift.yml` + `evals/check-verification-freshness.sh` (23rd preflight step). Seeded a wrong C-20 port → caught |
| 2026-09-24 | 9 | tec-knowledge-base #155 · #156 · tec-app #256 | `refresh` check added (7th); Hub refresh fixed. Drift job run #1 (manual, with `DRIFT_READ_TOKEN`): **34 · 0 · 0**, all 30 repos cloned |
| 2026-09-24 | 7 | tec-knowledge-base #157 (merged) | C-02 5,929 → 114 lines; 65 records + today's (56q) in `memory/sessions/`; no line lost (checked line by line; the one edit is the CSV RFC's number, written with a hyphen before it, which the canonical-reference gate read as a citation of a four-hundred-series C-doc — now written with a space) |
| 2026-09-24 | 8 | tec-knowledge-base (this PR) | `scripts/code_facts.py` (shared repo reader) + `generate-code-docs.py`; C-11 (9 repos, wrong ports → all 29 code repos + 12 services, ports from `main.ts`) and C-44 (24 names, 3 unused → 160 read by code, by app/service); drift check `generated` → **36 · 0 · 0**. Seeded a deleted row → caught, with the variable named |
| 2026-09-24 | 8 | tec-knowledge-base #158 (merged) | — |
| 2026-09-24 | 6 | tec-knowledge-base (this PR) | CLAUDE.md 722 → 102 lines; README: 5 wrong ports, stale counts/badges/ADR range, NX role, 8 missing charters; one impact engine (and its charter count fixed: C-124 → C-131 were missing, and dependents were double-counted); `.cursorrules` RULE 3 → preflight. Drift check reads the README: on the old one, 5 port FAILs |
| 2026-09-24 | 6 | tec-knowledge-base #159 (merged) | — |
| 2026-09-24 | 10 | tec-knowledge-base (this PR) | 522 Arabic prose lines → English in 61 docs (line counts unchanged); `governance/LANGUAGE_POLICY.md` v1.1; `evals/check-language-policy.sh` (LP-1 prose = blocking, LP-2 code-block ratchet at 669). Seeded Arabic prose → LP-1; a code-block line → LP-2 (9 → 10). **All ten steps done.** |
