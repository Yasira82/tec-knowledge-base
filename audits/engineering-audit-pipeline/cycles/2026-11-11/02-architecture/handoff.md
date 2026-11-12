# P1 → Run 2 (P2 · P3) handoff · cycle 2026-11-11

## Start here

1. `registry/master-findings.json` — 17 findings, 15 open. Reference these IDs; do not re-open
   them as new ones.
2. `registry/phase-dependencies.json` — which finding each later phase must take up.

## For P2 (code quality)

- TEC-AUDIT-0007: list the services that validate by hand and the source files over 600 lines.
- TEC-AUDIT-0011: the PAL bypass is also a duplication problem (three copies per app).
- Run type-check and lint per repository and record the actual output; a repository that
  cannot be built is BLOCKED for that check, not PASSED.

## For P3 (security)

- TEC-AUDIT-0002: run `npm audit --omit=dev` on every lock file; record counts per severity.
- TEC-AUDIT-0004: review CSP in every app, not only the Hub.
- TEC-AUDIT-0008: map who verifies tokens and with which key.
- TEC-AUDIT-0014 and TEC-AUDIT-0015 are fixed on the backend branch; P3 reviews the other
  limiters and guards the same way (key only from a verified identity; compare bytes).
- Not covered by P1's searches: ActorContext on sensitive operations; authorization on every
  gateway route the apps do not call (direct gateway access); secrets in repository history.

## Decided after Run 1 (see `00-control/remediation-run1.md`)

- TEC-AUDIT-0016: one rule, in C-71 §3 (ADR-009 stands).
- TEC-AUDIT-0012 / 0013: database changes, done in P4 with a production row count first.
