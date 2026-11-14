# Audit scope — cycle 2026-11-11

## In scope

Every repository in `repository-inventory.json` — **30**, read at `origin/main`:

| Group | Count | Repositories |
|---|---|---|
| Apps (fleet) | 24 | Tec-App (Hub) · Tec-Commerce · Tec-Assets · Tec-Ecommerce · Tec-Life · Tec-Zone · Tec-Connection · Tec-Analytics- · Tec-Explorer · Tec-system · Tec-Nexus · Tec-Estate · Tec-Alert · Tec-Dx · Tec-Nx · Tec-Titan · Tec-Vip · Tec-Elite · Tec-Insure · Tec-Epic · Tec-Legend · Tec-Fundx · tec-nbf · tec-brookfield |
| Platform | 5 | Tec-core-backend · TEC-SDK · tec-auth · Tec-ui · tec-template-base |
| Knowledge base | 1 | tec-knowledge-base (the baseline; audited for drift against code, not as code) |

Inside Tec-core-backend: 20 deployable services, `tec-backup-job`, the `shared` library and
`tec-service-template`.

## Measured size (origin/main, `tools/inventory.py`)

4,457 code files · 1,365 test files · 477,188 lines (TypeScript, JavaScript, Python;
generated output, lock files and `.d.ts` excluded). Largest: Tec-core-backend 124,534 lines /
907 files; Tec-App 92,019 / 542.

## Out of scope for this cycle

- **Open pull requests.** 22 PRs from 11 Nov (template #56, Tec-App #325, 20 app PRs) are
  pending, not the state of the code. Where one would close a finding, the finding says so.
- **Runtime state** (Vercel, Railway, databases) until P8; nothing in Runs 1–4 calls production.
- **Secrets.** No value is read or printed. Environment variables are named, never shown.

## Method

Read-only: `git show` / `git grep` / `git cat-file` on `origin/main` after `git fetch`. No
working tree, no build, no install in Run 1. The two tools are in `../../tools/` and print to
stdout; their outputs are committed here so a later cycle can diff them.
