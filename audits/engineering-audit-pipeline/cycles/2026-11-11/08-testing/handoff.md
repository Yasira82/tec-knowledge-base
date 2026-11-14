# P7 → handoff · cycle 2026-11-11 · Run 4

- **Remediation:** 0037 — add `@vitest/coverage-v8` and run `test:coverage` in CI (template first,
  then template-sync), each app measured first; 0038 — give the two real-database tests the CI
  Postgres, and add a contract fixture per event (producer writes it, consumers parse it).
- **P8:** run the e2e suites against a deployed preview; read the served headers.
- **On `main`:** re-run every suite once CI is back — this run was on main + the local commits.
