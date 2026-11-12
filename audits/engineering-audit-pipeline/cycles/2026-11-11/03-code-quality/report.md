# P2 — Code Quality & Static Analysis · cycle 2026-11-11 · Run 2

**Status: PASSED_WITH_FINDINGS** · type-check and lint on `main` **BLOCKED** (below) ·
[Code Verified] at `origin/main`, 12 Nov 2026

`tools/code_quality.py` counts, on every repository's `main`, excluding tests, config and
migrations. Output: `code-quality.json`.

## The numbers

| | Apps (24) | Template | Backend (20 services) | Packages (SDK · auth · ui) |
|---|---|---|---|---|
| Source files / lines | 2,274 / 221,024 | 88 / 6,517 | 562 / 73,086 | 48 / 3,335 |
| `any` | 2–7 per app (Ecommerce 17) | 2 | 68 | 0 |
| `@ts-ignore` / `@ts-nocheck` | **0** | 0 | **0** | 0 |
| Files over 600 lines | Hub 18 (split pending in Tec-App #325), Connection 3, Explorer 1 | 0 | 12 | 0 |
| `console.log` in source | ~5 per app | — | 158 — **151 in CLI/ops scripts**, 7 in CLI entry points | 13 (SDK) |
| "Silent" catch blocks | 22–86 per repository | 28 | 18 | 1 |

**Reading the silent-catch count honestly.** It is a shape, not a verdict. Classified in the
template (the source of most app copies): every one guards a best-effort step — storage that
throws in a private window, an inline boot script, "try the next audience" while verifying a
token. None hides the outcome of a payment, a sign-in or a balance. In the Hub, two hide a
financial *display*: a failed history load reads as "no transactions" → **0028**.

**Validation (TEC-AUDIT-0007, now measured):** seven services use no schema library —
analytics, commerce, identity, kyc, notification, realtime, storage. The other thirteen use zod
or class-validator.

## Blocked check

**Type-check and lint on `main`**: the pipeline's runner for them is GitHub Actions, and
Actions has refused every job since 12 Nov (an account billing hold — the owner's ticket is
open). Measured instead, and recorded as such, not as a pass on `main`:

- the 20 template apps and the template, on their PR heads (`main` + this cycle's changes):
  `tsc` 0 errors, `next lint` 0 errors, vitest green — 12 Nov;
- six backend services on the backend branch (`main` + Run 1 fixes): `tsc` 0 errors, jest
  green — auth, payment, gateway, wallet, analytics, connection.

The rest (Hub, Commerce, Assets, Ecommerce, 14 backend services on `main`) is unmeasured
until CI runs.

## Findings

| ID | Severity | Title |
|---|---|---|
| TEC-AUDIT-0028 | LOW | A failed wallet-history load shows an empty list |
| TEC-AUDIT-0007 | LOW | (carried) seven services validate by hand — now named |
