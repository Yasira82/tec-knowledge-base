# Incident: refreshed sessions expired after ten minutes (2026-10-16)

Post-mortem in the C-78 §6 shape. Truth State: [Current State] · Verification: [Runtime Verified]
(owner's production checks, 2026-10-16) · Fix: tec-core-backend **#429**.

## Incident Summary

Members entering **Assets** and **Connection** from the Hub saw empty screens: no NFTs, no
messages, "Unauthorized" under the follow box, "Sign in with Pi" on the invite card, while the
header still showed their username. It cleared after re-entering from the Hub or signing out
and in, then came back. Other apps looked healthy.

**Cause:** `tec-auth-service` `refreshToken()` passed `JWT_EXPIRES_IN` /
`JWT_REFRESH_EXPIRES_IN` to the token library as the raw environment **string**. Railway holds
them as bare numbers (`604800`), and the library reads a numeric string as **milliseconds**:
604800 ms ≈ 10 minutes. Login converted the value first (a local `parseExpiry`), so a fresh
sign-in lived 7 days — but **every refreshed access token and refresh token lived ten
minutes**, and once the refresh token itself had expired nothing could renew the session.

## Timeline (2026-10-16, GMT+3)

| Time | Event |
|---|---|
| ~00:25 | Owner reports Assets / Connection empty until re-entry. Same-day backend moves (Pioneer, Campaign, Feedback) were under suspicion — they were not the cause. |
| 00:26–00:28 | Vercel logs: in the same second, some `/api/bff/*` calls 200 and others 401; Assets' 401s made **no outgoing request** (rejected inside the app's own BFF). |
| ~01:03 | Hub logs: no `refresh failed`. The "Hub hands over a stale token" theory was dropped. |
| 09:1x | Assets diagnostic `GET /api/bff/pioneer/arrived` → `token: true, tokenValid: false`. |
| 09:3x | Diagnostic extended (Tec-Assets #79) to say **why**: `tokenProblem: "expired"`, `lifetimeMinutes: 10`, `expiredMinutesAgo: 50`. |
| 09:52 | Owner shows `JWT_EXPIRES_IN = 604800` on tec-auth-service — the setting was right; the defect was in the code reading it. |
| ~09:55 | Root cause found; test reproduces it (604 s instead of 604800 s). |
| 10:02 | tec-core-backend **#429** merged and deployed. Owner confirms both apps stay working. |

## Root Cause

- **Technical:** two signing paths in one service read the same setting two ways. Login used
  `parseExpiry` (bare number → seconds); `refreshToken()` used the string as-is (→ ms).
- **Why only Assets and Connection showed it:** both verify the token in their own BFF on every
  call (Assets' `createHandler` with `jwtVerify`; Connection's service) and do not renew it on a
  401. Apps that forward without verifying, or that refresh on 401, hid the expiry.
- **Why it looked new:** a session only hits the defect after its first refresh, and lives ten
  minutes from then on. Re-entering from the Hub (a new hand-off) or a fresh sign-in
  "fixed" it for a while, which made it look like a recent regression from the day's deploys.

## Detection

By the owner, not by a sensor. Nothing measured token lifetime or a token's validity at the app.
The step that broke the investigation open was a read-only diagnostic that said **why** a token
was refused (expired vs signature) and **how long it lived** — after a day of plausible theories
(the Hub's 6-second refresh budget, Vercel instances with different secrets, the arrival route).

## Recovery

- **Worked:** the diagnostic's `lifetimeMinutes` field; a test that signs real tokens through
  refresh and asserts `exp − iat` (failed 604 vs 604800 before the fix).
- **Did not work:** reasoning from request timings alone; suspecting the day's deploys because
  the symptom appeared the same day.

## Action Items

- ✅ **Corrective** — #429: one module-level `parseExpiry` used by login and refresh.
- ✅ **New test** — `tec-auth-service/src/__tests__/token-lifetime.spec.ts` pins lifetimes for
  bare seconds, unit strings and the defaults, with real signed tokens.
- ✅ **New control** — Tec-Assets #79: `GET /api/bff/pioneer/arrived` reports `tokenProblem`,
  `lifetimeMinutes`, `expiredMinutesAgo` (labels and minutes only — never a value or a claim).
- ◐ **Preventive** — the same diagnostic in the template (`tec-template-base`) and all 22 other
  apps, so the next session problem is one link away in any app. Pushed to each app's open PR
  (2026-10-16); tests + type-check green in every app. Done when merged.
- ◐ **Preventive** — renewing on a 401 is not possible for a Hub-entered session: it carries no
  refresh token, and `Pi.authenticate` is refused in the Hub's foreign session (ADR-007). So
  instead: a 401 from the app's own `/api/bff/*` shows a "session expired" notice with one
  button that reopens the app through the Hub (Tec-Assets #80, Tec-Connection #95). Done when merged.
- ◐ **Detection** — tec-auth-service logs `Token lifetimes: access Xs, refresh Ys` at boot,
  measured from real signed tokens, and logs an ERROR when access < 1 hour or refresh <
  access (tec-core-backend #430). A unit mix-up like this one is visible in the first deploy log.
- □ **Alert** — a synthetic check that signs in, refreshes once, and asserts the refreshed
  token's lifetime equals `JWT_EXPIRES_IN`.

## Found on the way (separate fixes, same day)

- Hub wallet card's payments request always 400'd: `searchParams.get()` returns `null`, zod
  `.default()` fills only `undefined` (tec-app #317). The list then moved to the wallet page
  (tec-app #318, owner's call).
- Two C17 holes — the gateway adds `x-internal-key` to every proxied request, so a key alone
  never proves a service called: Feedback triage readable by any signed-in user (#426), and
  `pioneer/arrived` creditable by a person for an app never opened (#427).
