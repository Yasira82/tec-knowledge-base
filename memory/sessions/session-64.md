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
  MEDIUM); marketplace prices in Pi are Float (0012, MEDIUM); C-11 and C-44 stale (0009,
  MEDIUM); the baseline disagrees with itself on the type of an amount (0016); three LOW.
  0015 was first withheld, then found unreachable and published; 0017 was the auditor's error.

**17 findings: 1 CRITICAL · 2 HIGH · 7 MEDIUM · 5 LOW · 2 INFO.**

## Remediation, 12 Nov (owner: "fix Run 1 and document it before Run 2; do it right")

`cycles/2026-11-11/00-control/remediation-run1.md` is the record. In short:

- **Fixed:** 0009 (C-11/C-44 regenerated), 0016 (one amount rule in C-71 §3; ADR-009 stands),
  0011 (PiRuntime in the template and the 20 template apps, a boundary test, template-sync
  markers), 0010 · 0014 · 0015 (backend branch, pushed with no PR — no CI minutes before 1 Dec).
  Each fix was trusted only after its test failed on the old code.
- **0014 was larger than the search said:** 5 hits, 18 copies. The fix searched for the
  pattern, not the variable name.
- **0017 closed as INVALID** — C-20 names services by short name. The real gap under it,
  check-drift's hand-typed service list, is fixed; its first version passed by finding nothing.
- **Deferred with reasons:** 0012 / 0013 to P4 (a two-repository migration; a row count first);
  0011 in the four non-template apps to P10.

## Run 2 — P2 + P3 (12 Nov), done while GitHub Actions was refused

GitHub stopped running Actions for the whole account on 12 Nov: an unpaid September invoice
(Actions and Copilot overage), the card declined three times. The owner has a ticket open and
cannot pay; nothing is pushed until it is resolved. Run 2 ran locally and is committed locally.

- **P3:** no credential in ~7,000 commits of all 30 repositories (the clones were shallow; full
  history fetched first, and every rule proved on a fake credential). JWT verification pinned to
  HS256 everywhere (135 calls). Dependencies: fixable highs in every app, the SDK pinning a
  flagged axios (0019); zod 3 (0020); a stale Hub lock (0021 — production runs 15.5.29, read from
  the Vercel build log); an unused backend root package (0022). One HIGH withheld (0018).
- **P2:** no `@ts-ignore` anywhere; the silent-catch count is mostly by design, classified; the
  Hub shows "no transactions" when the history fails to load (0028); seven services named for 0007.
  Type-check and lint on `main` BLOCKED with Actions.

**28 findings: 1 CRITICAL (closed) · 3 HIGH · 9 MEDIUM · 12 LOW · 3 INFO.**

## Run 2 remediation (12 Nov) — local commits, not pushed

`cycles/2026-11-11/00-control/remediation-run2.md`. connect-src named in all 24 apps (0018 part 1);
the stale Hub lock, the unused backend root package and Assets' debug route removed; the gateway's
catalogue public for reads only and Swagger off in production; the Hub's wallet says when its history
failed. **Deliberately not done:** shortening the access token to 24 h — template apps hold no refresh
token (new 0029), so it would sign everyone out daily and multiply Pi sign-ins.

## TEC-AUDIT-0029 fixed (12 Nov, local)

No app but the Hub could renew a session: the template sent the access token where the refresh
token belongs, Commerce and Assets sent none in the header. All 23 now refresh on the server in
middleware, as C-123 §4 describes and the Hub already did; each keeps its own host-only refresh
token. Shortening the token to 24 h now waits only on one phone check in Pi Browser.

## Lessons

- **A search that finds nothing is not evidence of compliance until it is shown to be able to
  find something.** P1-C18 first searched for a payment path and returned nothing; the base
  URL is built from a constant. It now searches for the host, and passes.
- **Check what a fix touches before making it.** The 24-hour token was on the plan; reading the
  refresh path first showed it would have signed every Pioneer out daily.
- **Search for the shape of a defect, not for the names in the first copy found.** P1-C04
  found 5 of 18 copies; the tool now searches the shape.

## Left open

0. GitHub Actions back (owner's ticket 4956739); then push Run 2 and re-run every PR's checks.
1. Merge KB #228, template #56, the 20 app PRs; the backend PR on or after 1 Dec.
2. After the merges, re-run `tools/architecture_checks.py` to close the fixed findings.
3. Run 3 — P4 + P5 (start from `04-security/handoff.md`).
