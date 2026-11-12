# Session 64 — the Engineering Audit Pipeline becomes the review process; Run 1 (P0–P1) of cycle 2026-11-11 (11 Nov 2026)

> Truth State: **[Current State]**. Verification: **[Code Verified]** — every claim read from
> each repository's `origin/main` on 11 Nov 2026. Same branch as sessions 57–63. Follows
> [session 63](session-63.md).

## What the owner asked

To turn the one-pass engineering review into a sequential, evidence-driven pipeline (twelve
phases P0–P11, gates A–G, one finding ID for the whole history, six runs per cycle), make it
the official review process for the TEC repositories, and keep each run dated and versioned.
Audit only: no fix, commit or deploy to the audited code during a run.

## Done

| Where | What |
|---|---|
| `audits/engineering-audit-pipeline/README.md` | The process: phases, cadence, outputs, statuses, gates, finding format, and the rules this public repository adds (an open security finding is `withheld`; no secret values; no C-NN; `main` only; verified vs assumed) |
| `…/tools/inventory.py` | P0: every repository's size, role, workflows, dependencies; every backend service's framework, port, schema, migrations — read from `origin/main` only |
| `…/tools/architecture_checks.py` | P1: 13 canonical rules as searches; a hit is a candidate, classified by hand |
| `…/cycles/2026-11-11/` | **Run 1** of the first cycle: `00-control/` (status, scope, baseline, inventory), `01-discovery/` and `02-architecture/` (report · findings · evidence · handoff), `registry/` |

## Run 1 result

**P0 PASSED_WITH_FINDINGS · P1 PASSED_WITH_FINDINGS · Gates A and B met.**

- 30 repositories (24 apps, 5 platform, the KB), 4,457 code files, 1,365 test files, 477,188 lines.
- The 8 findings of the 11 Nov review carried into the register as TEC-AUDIT-0001…0008 (two closed).
- **8 of 13 architecture rules compliant**: no decoded JWT, no token in web storage, no
  wildcard CORS, CSRF only in middleware, the Pi Platform API only in auth and payment, no
  database in the gateway, no internal URL in the browser, one inter-service header.
- New: the sign-in and payment code calls `window.Pi` around the PAL in every app (0011,
  MEDIUM); marketplace prices in Pi are Float (0012, MEDIUM); C-11 and C-44 stale and C-20
  missing eight services (0009 · 0017, MEDIUM); four LOW; one LOW withheld (0015, told to the
  owner directly); the baseline disagrees with itself on the type of an amount (0016).

**17 findings: 1 CRITICAL (closed) · 2 HIGH · 8 MEDIUM (1 closed) · 6 LOW.**

## Lessons

- **A search that finds nothing is not evidence of compliance until it is shown to be able to
  find something.** P1-C18 first searched for a payment path and returned nothing; the base
  URL is built from a constant. It now searches for the host, and passes.
- `check-drift.py` passes only what C-20 lists; a service missing from C-20 is invisible to it.

## Left open

1. Run 2 — P2 + P3 (start from `02-architecture/handoff.md`).
2. Owner decisions: one rule for a Pi amount's type (0016); drop the unused wallet `Account` model (0013).
3. Regenerate C-11 / C-44 after the open app PRs merge (0009).
