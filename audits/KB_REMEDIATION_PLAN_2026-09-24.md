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
| 1 | Rewrite C-13 §1–§2; C-15 & C-51 cookie blocks → cite C-123 §2/§3/§9 | F2, F3 | S | ◐ in PR |
| 2 | Correct C-14 versions, C-20 ports + private hosts, C-40 NEW-M, C-41 + `memory/` phase | F4, F5, F10, F11 | S | ◐ in PR |
| 3 | C-56 → pointer to `events-catalog.yaml`; C-62 → pointer to the SLO manifest (one set of numbers) | F8, F9 | S | ◐ in PR |
| 4 | Regenerate `dependency-graph.yaml`; regen + diff in preflight and CI | F13 | S | ◐ in PR |
| 5 | Fix F17 references; delete the duplicate impact script; stop committing the integrity report | F17, F20 | S | ◐ in PR |
| 6 | README / CLAUDE.md: counts replaced by "run preflight"; CLAUDE.md → navigation only | F16 | M | ☐ |
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

## Log

| Date | Step | PR | Result |
|---|---|---|---|
| 2026-09-24 | 1–5 | tec-knowledge-base #153 | opened |
