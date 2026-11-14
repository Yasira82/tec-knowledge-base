# P0 evidence — cycle 2026-11-11 · Run 1

Every command read `origin/main` after `git fetch origin main` in each clone (11 Nov 2026).

## Commands

```bash
# the inventory (output committed as 00-control/repository-inventory.json)
python3 audits/engineering-audit-pipeline/tools/inventory.py --repos-dir <clones> --ref origin/main

# KB facts against code
python3 scripts/check-drift.py --repos-dir <clones> --ref origin/main
#   → exit 1 · 34 pass · 2 fail · 0 skip
#   ❌ C-11___REPOSITORY_MAP.md: stale — app versions (Next 15.5.29, tec-ui ^3.0.0 ranges)
#   ❌ C-44_Environment_Variables.md: stale — LIFE_CONVERSATION_KEY, LIFE_DELETION_LEDGER,
#      LIFE_EVAL_BASELINE, LIFE_EVAL_DELAY_MS, LIFE_EVAL_JUDGE_MODEL (names only)

# C-20 coverage
grep -c tec-<name> knowledge-base/C-20_Backend_Services.md
#   business 0 · life 0 · nexus 0 · platform 0 · search 0 · trust 0 · backup 0 · ai 1 · connection 1

# the template-sync mechanism on main?
git -C tec-template-base cat-file -e origin/main:template-sync.json   # → absent

# the nested load-test folder
git -C Tec-core-backend ls-tree -d --name-only origin/main tec-core-backend/   # → tec-core-backend/k6
```

## Evidence index

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0001…EV-0010 | 0001…0008 | `audits/ENGINEERING_REVIEW_2026-11-11.md:39-46` | The baseline review's rows, carried as they stand |
| EV-0003 | 0002 | `00-control/repository-inventory.json` | tec-nbf and tec-brookfield: `next` 15.5.12 |
| EV-0007 | 0005 | tec-template-base `origin/main` | no `template-sync.json` |
| EV-0011 | 0009 | `scripts/check-drift.py` | 2 fail |
| EV-0012, EV-0013 | 0010 | Tec-core-backend `tec-core-backend/k6/` · `.github/workflows/load-test.yml:7-14` | load tests in a nested folder |
| EV-0033, EV-0034 | 0017 | inventory `services[]` · C-20 grep | 23 entries; 8 with no C-20 entry |

## Tool limits (recorded, not hidden)

- `inventory.py` reads the default port from `src/main.ts`. tec-payment-service starts from
  `src/server.ts`, so its `default_port` is `null` in the inventory; C-20 and the backend
  CLAUDE.md say it requires `PORT`. P5/P8 confirm it from Railway.
- Line counts include comments and blank lines; they are a size measure for comparing cycles,
  not a quality measure.
- Dependency versions are the ranges in `package.json`, not the installed versions. P3 runs
  `npm audit` on the lock files.
