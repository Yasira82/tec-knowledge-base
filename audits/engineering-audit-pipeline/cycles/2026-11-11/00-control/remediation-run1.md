# Remediation after Run 1 — cycle 2026-11-11 (12 Nov 2026)

> Truth State: [Current State] for what is pushed; **[Planned State]** for what waits on a merge.
> Verification: [Code Verified] — each fix has a test or a check that was **shown failing on
> the old code** before it was trusted. Remediation is a separate step from the run (README §4);
> the run's findings were not edited, only given a `remediation` field.

The owner's instruction: fix Run 1 and document it before Run 2 starts, and do what is right
in engineering terms. Two constraints shaped *where* each fix sits: no backend PR before
1 Dec (GitHub Actions minutes; a pushed branch with no PR runs no CI), and as few new PRs as
possible (the app PRs from 11 Nov are still open, so fixes ride on them).

## Fixed

| Finding | Fix | Proof | Where |
|---|---|---|---|
| 0009 C-11 / C-44 stale | Regenerated from every `origin/main` | `check-drift.py`: 36 pass · 0 fail | KB #228 |
| 0010 nested `k6/` | Moved to the root; `load-test.yml` follows | the workflow names `k6/gateway-load-test.js` | backend branch `cf6074d3` |
| 0011 PAL bypass | `pi-auth.ts` and `pi-payment.ts` call `PiRuntime`; `pal-boundary.test.ts` fails on any direct `window.Pi.authenticate/createPayment`; template-sync shares the file and the test and marks `PiRuntime.createPayment(` in `pi-payment.ts` | the test is red on the old code, green on the new; tsc + vitest + lint per app | template #56 · the 20 template-app PRs |
| 0014 key length in characters | `Buffer.byteLength` in all **18** copies — the search found 5, the fix searched for the pattern instead of the variable name | `internal-key-bytes.spec.ts` red before, green after; tsc + jest in auth, payment (462), gateway (106), wallet (99), analytics (176), connection (410) | backend branch `cf6074d3` |
| 0015 rate-limit key | Key from the verified identity only | new case in `security.test.ts` red before, green after | backend branch `cf6074d3` |
| 0016 amount type | One rule in C-71 §3: DECIMAL(20,8) in the database; a decimal string wherever an amount leaves a service; a number only in a payment request, because ADR-009 ranks above the spec. The backend CLAUDE.md quotes it | — | KB #228 · backend branch `d05426fb` |

## Corrected — the auditor's own error

**0017 was wrong.** It said C-20 misses eight services. C-20 lists all 20; its table names them
`life`, `ai`, … and the search looked for `tec-life`. The finding is closed as `INVALID`, kept
in the register (an ID is never reused or deleted), and the lesson recorded.

What *was* real under it: `check-drift.py` checks only the services in a hand-typed list, so
a new service would pass every check unseen. It now fails on any service in code the list
does not name. Its first version passed by finding nothing (a git pathspec glob matched no
file); it was trusted only after removing `trust` from the list made it fail.

## Not fixed now — and why that is the right call

| Finding | Why not now | When |
|---|---|---|
| 0012 marketplace `price` Float | Measured first: prices are stored, never computed, and every comparison already runs in integer 1e-8 units (`covers()`), so nobody is charged wrongly today. The fix is a column-type migration (refused without `MIGRATE_ALLOW_DESTRUCTIVE`) **and** a contract change for the Assets app (a Decimal arrives as a string in JSON). That is an expand–contract migration across two repositories, not a patch | P4, Run 3 |
| 0013 unused wallet `Account` table | Dropping a table needs its production row count first | P4, Run 3 |
| 0011 in the Hub, Commerce, Assets, Ecommerce | Not made from the template; each has its own Pi layer. Fixing them is four more PRs and belongs with the cross-repository phase | P10, Run 6 |
| 0004 · 0007 · 0008 | Measured or designed in Run 2 (P2 / P3) or the rotation plan | Run 2 / after 1 Dec |
| 0002 · 0005 | Done in open PRs — wait on the merge | merge |
| 0006 | Account-level settings (paging, backup alert, two variables) | owner |

## What the owner does

1. Merge **KB #228** and **template #56**, then the 20 app PRs (after Vercel's daily limit resets).
2. On or after **1 Dec**: open the backend PR from `claude/tec-knowledge-base-review-6wzngc`
   (three commits: the key comparison, the rate-limit key, `k6/`, the CLAUDE.md rule).
3. After the merges: re-run `tools/architecture_checks.py` — P1-C04 should show no string
   length check and P1-C16 only the `layout.tsx` init lines in the template apps. That run is
   the evidence that moves each finding from `FIXED_PENDING_MERGE` to `CLOSED`.
