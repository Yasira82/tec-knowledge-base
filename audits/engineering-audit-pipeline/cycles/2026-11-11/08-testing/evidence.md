# P7 evidence — cycle 2026-11-11 · Run 4

```bash
# backend: per service — npm ci (if not installed), prisma generate, npm test; node_modules removed after
#   → backend-test-run.txt
# apps: npx vitest run per repository (Run 3 remediation, every suite) — counts in report.md
# coverage, template only, without touching package files:
npm i --no-save @vitest/coverage-v8@<installed vitest> && npx vitest run --coverage
# floors and CI:
grep -E "(lines|statements|branches|functions): *[0-9]+" vitest.config.*      # 25 app repos: 21 declare
grep -lE "test:coverage|--coverage" .github/workflows/*.yml                    # 1 app repo: Tec-Life
```

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0078 | 0037 | each app's `vitest.config.ts` · `.github/workflows/ci.yml` | thresholds declared; CI `run: npm test` |
| EV-0079 | 0037 | tec-template-base `package.json` | `test:coverage` exists; `@vitest/coverage-v8` not a dependency |
| EV-0080 | 0038 | commerce `order.consumer.ts:5-11` | its own comment: never registered, listened on the wrong stream |
| EV-0081 | 0038 | connection `erasure-db.spec.ts:12` · identity `deletion-ledger-db.spec.ts:15` | skip without `TEST_DATABASE_URL`; CI's job already has a Postgres (`ci.yml:243`) |
