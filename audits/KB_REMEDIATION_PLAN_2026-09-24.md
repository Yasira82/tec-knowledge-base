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
| 1 | Rewrite C-13 §1–§2; C-15 & C-51 cookie blocks → cite C-123 §2/§3/§9 | F2, F3 | S | ◐ done in #153 — ✅ on merge |
| 2 | Correct C-14 versions, C-20 ports + private hosts, C-40 NEW-M, C-41 + `memory/` phase | F4, F5, F10, F11 | S | ◐ done in #153 — ✅ on merge |
| 3 | C-56 → pointer to `events-catalog.yaml`; C-62 → pointer to the SLO manifest (one set of numbers) | F8, F9 | S | ◐ done in #153 — ✅ on merge |
| 4 | Regenerate `dependency-graph.yaml`; regen + diff in preflight and CI | F13 | S | ◐ done in #153 — ✅ on merge |
| 5 | Fix F17 references; delete the duplicate impact script; stop committing the integrity report | F17, F20 | S | ◐ done in #153 — ✅ on merge |
| 6 | README / CLAUDE.md: counts replaced by "run preflight"; CLAUDE.md → navigation only; consolidate the two impact scripts (C-116 amendment) | F16, F20 | M | ☐ |
| 7 | C-02 split: ≤ 150-line current state + one file per session | F12 | M | ☐ |
| 8 | C-11 + C-44 generated from the repos by a script | F6, F7 | M | ☐ |
| 9 | Weekly cross-repo drift job + `Last-Verified` on `[Code Verified]` headers | F1 — prevents recurrence | L | ☐ |
| 10 | Language-policy pass, or amend the policy to what the KB actually does | F18 | M | ☐ |

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
| 2026-09-24 | 2 | tec-core-backend `CLAUDE.md` 4000-series port table: fixed in that repo, separately | Outside this repo; tracked under the log below |

## Log

| Date | Step | PR | Result |
|---|---|---|---|
| 2026-09-24 | 1–5 | tec-knowledge-base #153 | all five done; preflight **22/22** (new graph gate). Audit F8, F9, F17, F20 corrected in place where remediation showed the finding was imprecise |
