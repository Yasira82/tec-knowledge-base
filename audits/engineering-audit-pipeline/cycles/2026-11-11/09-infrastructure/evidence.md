# 09-infrastructure evidence — cycle 2026-11-11 · Run 5

All reads `git show origin/main:<path>` / `git grep … origin/main`; nothing deployed was touched.

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0082 | 0039 | `tec-api-gateway/railway.toml` | the only Railway config in the repo |
| EV-0083 | 0039 | `CLAUDE.md (backend) schema section` | "The service MUST have a Healthcheck Path" — set by hand |
| EV-0084 | 0039 | `every service src` | /health and /ready exist in all 20 |
| EV-0085 | 0040 | `.github/workflows/*.yml (schedule)` | 31 cron jobs, all Actions |
| EV-0086 | 0040 | `Tec-core-backend/.github/workflows/restore-check.yml (Configured? step)` | ::notice:: and success when unconfigured |
| EV-0087 | 0040 | `runtime-evidence/ev-2026-10-12-025.yaml` | the check was real when configured |
| EV-0088 | 0042 | `package.json (25 repos)` | no engines; no .nvmrc |
