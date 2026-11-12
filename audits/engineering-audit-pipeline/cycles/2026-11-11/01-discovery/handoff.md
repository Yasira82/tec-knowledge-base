# P0 → P1 handoff · cycle 2026-11-11

- **Scope is fixed:** the 30 repositories in `00-control/audit-scope.md`. Read `origin/main` only.
- **Baseline:** `00-control/baseline-references.md`. C-11 and C-44 are stale (TEC-AUDIT-0009):
  where P1 needs a version or a variable, read the code, not those two documents.
- **Services C-20 does not describe** (TEC-AUDIT-0017): business · life · nexus · platform ·
  search · trust · ai · connection · backup-job. For them, check P1 rules against their code
  and their app charters (C-106 Life, C-107 Connection, C-109 Nexus …).
- **Pending changes:** 22 open PRs from 11 Nov. Do not count them as fixes.
- **For later phases:** the three npm packages (TEC-SDK, Tec-ui, tec-auth) last changed in
  September — P10 compares published versions with the ranges the apps consume.
