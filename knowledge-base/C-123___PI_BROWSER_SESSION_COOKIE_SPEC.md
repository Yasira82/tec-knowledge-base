# C-123 — PI BROWSER SESSION & COOKIE SPEC

## TEC Ecosystem — Session Reliability Law (Hub + all apps)

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Runtime Verified]`
> **Authority Scope:** `[Platform]`

---

## PREAMBLE

This document is the **hard-won law** of how browser sessions actually behave in
Pi Browser, extracted from the July 2026 Hub login outage (a multi-day production
incident, root-caused step by step from Vercel runtime logs — every law below is
**Runtime Verified**, not theory).

It exists so that **no future session, contributor, or AI agent re-learns these
laws by breaking production again.** The in-code comment that claimed
*"Pi Browser drops sameSite=None cookies"* was folklore; acting on it caused the
outage. Everything here supersedes in-code commentary.

---

## §1 — THE THREE COOKIE LAWS (Runtime Verified, July 2026)

```
LAW 1 — XHR Set-Cookie is unreliable.
        Cookies set on a fetch()/XHR response are dropped non-deterministically.
        A login that stores its session via an XHR response WILL eventually fail.

LAW 2 — 3xx Set-Cookie is dropped.
        Cookies attached to a redirect response (301/302/307/308) are discarded.
        Proven signature: sso-callback 307 carried cookies → the very next
        request (/hub) arrived cookie-less → middleware bounce → login loop.

LAW 3 — Embedded contexts enforce the third-party cookie phaseout.
        Pi Browser can load an app in an embedded/webview context where:
          · sameSite=lax cookies are neither stored nor sent — AT ALL
          · document.cookie writes are silently ignored
          · sameSite=none WITHOUT Partitioned is ALSO blocked (Chrome 3P phaseout)
        The ONLY cookie that survives every context:
          Secure; SameSite=None; Partitioned   (CHIPS)
```

**Corollary (the reliable path):** session cookies may be established or rotated
**only on plain HTTP 200 responses** — a top-level HTML page (login landing) or a
same-origin BFF JSON response. Never XHR-only, never on a redirect.

---

## §2 — CANONICAL SESSION COOKIE CONTRACT (LOCKED)

| Cookie | httpOnly | Attributes (ALL mandatory) | TTL |
|--------|----------|---------------------------|-----|
| `tec_access_token` | false | `Secure; SameSite=None; Partitioned; Path=/` | 24h |
| `tec_refresh_token` | **true** | `Secure; SameSite=None; Partitioned; Path=/` | 7d |
| `tec_user` | false | `Secure; SameSite=None; Partitioned; Path=/` | 24h |
| `tec_csrf` | false | `Secure; SameSite=None; Partitioned; Path=/` | 24h |

Rules:
1. **Never downgrade to `lax`.** The lax migration (tec-app #56) was the regression
   that broke a working login (LAW 3). CI/tests now assert `none`.
2. **Deletion must match creation.** A clearing cookie (`maxAge:0`) with different
   attributes (missing `Secure/None/Partitioned`) targets a **different cookie jar**
   and silently fails to delete — this broke re-login after logout until fixed.
3. `tec_refresh_token` is server-only (httpOnly) — consumed exclusively by the BFF
   server-side refresh (§4).

---

## §3 — LOGIN FLOW ARCHITECTURE (Hub self-login)

```
[Pi Browser]
  1. Pi.authenticate()                       (via PiRuntime / PAL)
  2. POST /api/auth/pi-login  ──────────────► gateway /api/v1/auth/pi-login
       ↳ response: user + one-time ssoToken   (SSO_SECRET, HS256, jti, exp 5m,
                                               carries accessToken+refreshToken+user)
       ↳ cookies are ALSO set here (belt) — but NEVER relied upon (LAW 1)
  3. TOP-LEVEL NAVIGATION →
       GET /api/auth/sso-callback?token=…&redirect=/hub
  4. Callback verifies (issuer tec.pi, audience allowlist, jti replay-guard)
       → returns **200 HTML landing page** ("Signing you in…")
       → cookies ride the 200 response (LAW 2 corollary)
  5. Landing script — VERIFIED ENTRY:
       a. GET /api/auth/me  → ok? → location.replace(redirect)
       b. retry once after 350ms (cookie-commit race)
       c. document.cookie fallback for non-httpOnly cookies → re-check
       d. still failing → POST /api/auth/landing-report (diagnostic → logs)
                        → location.replace('/?login=failed')
```

**Invariant: no navigation into a protected page until the server has confirmed
the session.** A login loop is structurally impossible — failure is an explicit
`login=failed`, never a bounce.

`GET /api/auth/me` = server-side session resolver (reads request cookies — always
server-readable; fail closed 401). Client auth state (`usePiAuth`) tries the
client cookie first, falls back to `/api/auth/me`, and a late response can never
clobber an established login (`authSettledRef`).

---

## §4 — TOKEN LIFECYCLE (server-side refresh)

Backend reality: access token lives **~1h** (`JWT_EXPIRES_IN=3600`); refresh
tokens are **single-use** (rotation — reuse → `401 "Refresh token already used"`).

```
Any /api/bff/* request (createHandler):
  jwtVerify(access)
    ├─ valid            → proceed
    ├─ ERR_JWT_EXPIRED  → refresh at gateway  ← SINGLE-FLIGHT per refresh-token
    │                     (parallel BFF calls must not each burn the
    │                      single-use token)
    │                   → verify new token → run handler with it
    │                   → set rotated cookies on THIS response
    │                     (EVERY response path — success AND error)
    └─ invalid          → 401 UNAUTHORIZED (fail closed)
```

Forbidden (each one caused a production incident):
- ❌ Client-side `logout()` on refresh failure → logout→re-SSO **thrash loop**.
  Refresh failure degrades QUIET (blank value), never destroys the session.
- ❌ Internal server fetch to `/api/auth/refresh` that **drops** the rotated
  `Set-Cookie` → burns the single-use token → dead session. Any internal refresh
  must forward the rotated cookies to the browser (see `/api/auth/sso`).
- ❌ Relying on browser-side refresh at all — LAW 1 makes it non-durable.

---

## §5 — DIAGNOSTIC PLAYBOOK (use these, don't guess)

| Signal | Where | Meaning |
|--------|-------|---------|
| `GET /api/auth/me` → 200/401 | browser | Is the session server-visible? THE ground truth |
| `pi-login 200 → sso-callback 200 → me 401 ×2 → /` | Vercel logs | Cookies rejected by the browser context (LAW 3 — check attributes) |
| `pi-login 200 → sso-callback 307 → /hub 307 → /` | Vercel logs | Cookies died on the redirect (LAW 2 — callback must be 200 HTML) |
| `refresh 401 → logout 200` repeating | Vercel logs | Destructive client logout on refresh failure (§4 forbidden) |
| `401 "Refresh token already used"` | backend refresh | Single-use token burned — find who consumed rotation without forwarding it |
| `ERR_JWT_EXPIRED` vs `ERR_JWS_SIGNATURE_VERIFICATION_FAILED` | jwtVerify error code | Expiry (normal, self-heals) vs JWT_SECRET mismatch (env) — do NOT confuse them |
| `[landing-report]` warn line | Vercel logs | Landing page failed: shows document.cookie names + whether the server received any cookies |

Temp diagnostic endpoints (delete when stable, recreate from this spec when
needed): `/api/admin/auth-debug` (token claims + verify + backend refresh probe),
`/api/auth/landing-report` (landing failure sink).

---

## §6 — INCIDENT LEDGER (July 2026 — institutional memory)

| PR (tec-app) | What it did | Verdict |
|----|-------------|---------|
| #56 | sameSite none→lax + `/api/auth/me` + usePiAuth fallback | `/api/auth/me` ✅ kept · lax ❌ **was the regression** |
| #58 | test alignment + `authSettledRef` race guard | ✅ kept |
| #60 | client fetchWithAuth on wallet | ❌ caused logout thrash → reverted in #62 |
| #63 | **server-side refresh in createHandler (single-flight)** | ✅ core fix |
| #64 | login via top-level navigation + no destructive logout + rotated-cookie forwarding in /api/auth/sso | ✅ core fix |
| #65 | **200 HTML landing + server-verified entry** (exposed LAW 2) | ✅ core fix |
| #66 | restore sameSite=none everywhere (corrected #56) | ✅ core fix |
| #67 | **+ Partitioned (CHIPS)** + matching deletion attributes + landing diagnostics | ✅ final fix — login, re-login and wallet Runtime Verified |

Separate but related: the initial "login does nothing" was a **stuck incomplete
U2A payment** surfacing on every authenticate — resolved by **completing** it on
Pi with its txid (U2A payments cannot be cancelled). See C-02 Session 16.

---

## §7 — ANTI-REGRESSION GATES

1. `refresh-cookie.test.ts` asserts `sameSite === 'none'` — a lax PR fails CI.
2. sso-callback contract test asserts **200 HTML + cookies + verify script**.
3. `usePiAuth` tests assert server-fallback + no-logout-on-refresh-failure.
4. Rule for reviewers: any PR touching cookie attributes, the login flow, or
   refresh logic MUST cite this spec and explain which LAW it preserves.

---

## Related Documents

- `C-02___CURRENT_STATE_.md` — Session 16 (full incident narrative)
- `C-12_Dual_Mode_Payment.md` — payment-side Pi Browser constraints (CSRF §11)
- `C-47` Kernel Spec — P6 Fail Closed (why /api/auth/me 401s by default)
- `C-76___ADR-007.md` — Pi foreign session (payment counterpart of these laws)
- `C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md` — incident process
