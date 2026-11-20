# Remediation after Run 2 — cycle 2026-11-11 (12 Nov 2026)

> Truth State: **[Planned State]** for everything below — each fix is committed in its
> repository but **not pushed**: GitHub Actions is refused for the whole account (billing hold,
> owner's ticket open), and the owner asked that nothing be pushed until it is resolved.
> Verification: [Code Verified] — each fix's test was shown failing on the old code, then
> passing; type-check, lint and the full suite ran locally for every repository touched.

The owner's rule from Run 1 holds: fix the run and document it before the next one, and do
what is right — which here included **not** doing one of the planned fixes (below).

## Fixed (local commits)

| Finding | Fix | Proof |
|---|---|---|
| 0018 part 1 | `connect-src` names its hosts in the template and **all 23 other apps** (the Hub had it since #324). Each app's browser code was scanned for external hosts first; only Commerce and Ecommerce needed one more (CoinGecko, called from a drawer) | `csp-connect-src.test.ts` red on the old value, green on the new, shared through template-sync with a `next.config.js` marker; tsc, lint and the full suite per app |
| 0021 | The Hub's stale `tec-frontend/package-lock.json` deleted; CI cache keys hash the root lock | a clean worktree without the file: install inside `tec-frontend` resolves Next 15.5.29 from the root lock and creates no new lock |
| 0022 | The backend's unused root `package.json` and lock removed | every workflow installs in a service folder; `scripts/` imports only built-ins |
| 0024 | Gateway: the catalogue is public for reads only; Swagger off in production unless `API_DOCS_PUBLIC=1`; `/metrics` exemption gone | 5 new tests red before, green after; gateway 115/115. Every app write to products already sends a token and the internal key |
| 0025 | Assets `/api/debug` removed | nothing called it; Assets 303/303 |
| 0027 | Three instruction files state ADR-001 instead of "HttpOnly" | — |
| 0028 | The Hub's wallet says "Could not load your transactions" (with Retry) and reports it, instead of "No transactions yet" | `wallet-history-failure.test.tsx` red before, green after; Hub 177 files green. Its second half (`useAppPayments`) was already right — the finding over-counted it |

## Not done — and why that is the right call

**0018 part 2 — shortening the access token from 7 days to ADR-001's 24 h.** Checked before
doing it, and it would have signed everyone out daily: template apps never receive a refresh
token (**new finding 0029**), and they refresh only after a 401, when it is too late. Daily
sign-outs mean daily Pi sign-ins — the load that made Pi Browser stop opening the wallet on
10 Nov. The order is: a working refresh (0029) → phone check in Pi Browser → then the shorter
lifetime.

**0018 part 3 — dropping `'unsafe-inline'` / `'unsafe-eval'`.** Cannot be verified here: it
needs Pi Browser on a phone (the Pi SDK bootstrap is inline). Done together with the Hub's 0004.

**0019 · 0020 · 0023** need package releases or majors (a TEC-SDK publish, zod 4, happy-dom 21)
— scheduled, with CI.

## Then: TEC-AUDIT-0029 fixed (owner: "fix the refresh first")

The refresh was broken in **all 23 apps but the Hub**, not only the template ones: the template's
route sent the access token where auth-service expects the refresh token, and Commerce and Assets
sent the refresh token in the body, which auth-service never reads. Now every app does what the
Hub does (C-123 §4):

- `lib/session-refresh.ts` (shared) + one step in `middleware.ts`: before a BFF call or
  `/api/auth/me`, an access token that has expired, or will within 2 minutes, is renewed at the
  gateway with the refresh token — on the server, once per token (single-flight); the route runs
  with the new token; the rotated cookies, with `tec_user` and `tec_csrf`, ride the same
  response. A page navigation never refreshes (a redirect would drop the cookies — LAW 2). A
  failure leaves the request as it came; a refresh token the backend rejects is dropped.
- `sso-callback` keeps the app's **own** refresh token (its pi-login already signed it in) —
  HttpOnly, host-only. A Hub hand-off carries none: the Hub's single-use token stays the Hub's,
  so no two holders ever share one. Ecommerce's refresh cookie moved off the shared domain for
  the same reason.
- `pi-auth.ts` no longer logs out when a refresh fails (C-123 §4 forbids it); logout clears the
  refresh token with its creation attributes.

Proof: 18 new shared test cases (3 red on the old code); every app's full suite, tsc and lint
green. **Next, before shortening the token (0018 part 2):** sign in to one app in Pi Browser,
let a short-lived access token expire, keep using the app — it must stay signed in.

## Noticed along the way

- **A flaky test in Tec-Analytics-:** one run failed 1 of 189, the next two passed. Not
  identified yet; handed to P7.

## What the owner does

1. Nothing until GitHub Actions is restored (ticket 4956739).
2. Then: push and merge in this order — KB #228; template #56; the app PRs; the backend branch
   (a PR on or after 1 Dec). Re-run `tools/architecture_checks.py` and the P3 tools on `main`
   to move each finding from `FIXED_LOCAL` to `CLOSED`.
