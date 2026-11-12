# P3 — Security & Privacy · cycle 2026-11-11 · Run 2

**Status: PASSED_WITH_FINDINGS** · one check BLOCKED (live response headers) ·
[Code Verified] at `origin/main`, 12 Nov 2026; one item [Runtime Verified] (the Hub's Next version)

## What was checked, and what it found

| Check | Method | Result |
|---|---|---|
| Credentials in history | `tools/secret_scan.py`: 11 rules over **every commit of all 30 repositories** (full history fetched first — the clones were shallow, and a shallow scan is not a history scan). Each rule shown to match a fake credential before the result was trusted | **Clean.** One match in ~7,000 commits: a Firebase web key, public by design → **0026** (INFO) |
| `.env` files ever committed | `git log --all --diff-filter=A` | Two in Tec-App (Feb, Apr 2026), both deleted; they held public settings only (app id, sandbox flag, URLs) — no secret |
| Known vulnerabilities | `tools/dependency_audit.py`: `npm audit --omit=dev` on all 46 lock files on main, from the ref (nothing installed) | Fixable-in-range highs in every app → **0019**; zod 3 everywhere → **0020**; a stale Hub lock → **0021**; an unused backend root package → **0022**; a test-only critical → **0023**. Backend Express services: still TEC-AUDIT-0002 |
| JWT verification | every `jwtVerify` / `jwt.verify` / `jwtService.verify` on main (135) | **Compliant.** 128 pin `algorithms` at the call; the 7 that do not inherit `verifyOptions: { algorithms: ['HS256'] }` from their module (auth, commerce, identity, realtime) |
| Session cookies | cookie options in every BFF | `SameSite=None; Secure; Partitioned` as C-123 requires; no `lax` on a session cookie. `tec_access_token` is script-readable **by decision** (ADR-001) |
| ADR-001's compensating controls | the ADR's own list (CSP, HTTPS, 24 h TTL) against code and config | **Not all in place → 0018 (HIGH, withheld)** |
| CSP | every app's `next.config` / middleware | Consistent shape fleet-wide; detail under 0018 and the Hub's 0004 |
| Raw HTML injection | `dangerouslySetInnerHTML` | Only constant SVG paths (Icon components) and the Hub's static JSON-LD — no user data reaches it |
| Gateway exemptions | `PUBLIC_ROUTES` and what each reaches | Nothing open today; wider than needed → **0024** |
| Debug surfaces | routes named debug/test in production | Assets `/api/debug` → **0025** |
| Instruction files vs ADRs | CLAUDE.md cookie statements | Contradict ADR-001 → **0027** |
| Live response headers (HSTS, CSP as served) | `curl` against production | **BLOCKED**: this environment's proxy answers 403 for every external host. P8 reads them from Vercel |

## Summary

**10 findings: 1 HIGH (withheld) · 2 MEDIUM · 5 LOW · 1 INFO**, plus 0007 measured. No credential
has ever been committed; JWT handling is uniform and pinned. The weakness is not a hole in one
place but a gap between a documented decision (ADR-001) and the controls it relies on.
