---
name: check-ci
description: Check CI status for all TEC repos on GitHub Actions
---

Check the latest GitHub Actions CI status for all TEC repositories.

## Steps

1. Use the GitHub MCP to check the latest workflow runs for these repos:
   - `yasira82/tec-app` (branch: main)
   - `yasira82/tec-ecommerce` (branch: main)
   - `yasira82/tec-assets` (branch: main)
   - `yasira82/tec-commerce` (branch: main)
   - `yasira82/tec-core-backend` (branch: main)
   - `yasira82/tec-auth` (branch: main)
   - `yasira82/tec-sdk` (branch: main)
   - `yasira82/tec-ui` (branch: main)

2. For each repo, report:
   - Latest CI run: ✅ success / ❌ failure / ⏳ in_progress
   - Failed job name (if any)
   - Commit SHA and message

3. If any CI is failing:
   - Fetch the failed job logs
   - Identify root cause
   - Suggest fix referencing the appropriate TEC skill

4. Output a summary table:

```
| Repo              | CI Status | Last Commit | Notes |
|-------------------|-----------|-------------|-------|
| tec-app           | ✅ pass   | abc1234     |       |
| tec-ecommerce     | ❌ fail   | def5678     | test: pi-payment |
```

## Related Skills
- `tec-testing` — fix failing tests
- `payment-expert` — if payment tests fail
- `security-reviewer` — if policy CI fails
