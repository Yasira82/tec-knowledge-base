# C-13 — AUTH & SSO ARCHITECTURE
## Pi Login → JWT → Cookies → Cross-App SSO

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`
> Last verified against code: 2026-09-24 (tec-app `main`, Tec-Zone `main`, tec-auth 1.2.0).
> **Law:** the cookie attributes and the login/landing mechanics are governed by **C-123**
> (Runtime Verified). Where this document and C-123 differ, C-123 wins.

---

## 1. AUTH FLOW (Hub self-login)

```
Pi Browser
  1. Pi.authenticate(['username','payments'], onIncomplete)      (via PiRuntime / PAL)
       └─ may never answer when Pi's app context belongs to another app — C-123 §9
  2. POST /api/auth/pi-login (BFF) ──► gateway ──► auth-service: verify via Pi /v2/me
       ↳ response: user + ONE-TIME ssoToken
       ↳ cookies are also set here, but NEVER relied upon (C-123 LAW 1: XHR Set-Cookie)
  3. TOP-LEVEL navigation → GET /api/auth/sso-callback?token=…&redirect=…
  4. sso-callback verifies (issuer tec.pi, audience allowlist, jti replay-guard)
       → returns a 200 HTML landing page — the session cookies ride THIS response
         (C-123 LAW 2: cookies on a 3xx are dropped)
  5. Landing script: GET /api/auth/me → 200 → location.replace(redirect)
```

The session is four cookies (C-123 §2 — LOCKED):

| Cookie | httpOnly | TTL |
|---|---|---|
| `tec_access_token` | false | 24h |
| `tec_refresh_token` | **true** | 7d |
| `tec_user` | false | 24h |
| `tec_csrf` | false | 24h |

All four: `Secure; SameSite=None; Partitioned; Path=/` — never `lax` (C-123 LAW 3).
A refresh re-issues `tec_access_token` **together with** `tec_user` and `tec_csrf`
(values copied, never invented) — renewing the token alone produced a half session a day
after sign-in (fixed fleet-wide 2026-09-24).

---

## 2. SSO FLOW (Cross-App)

```
User on <app>.tecosystem.app without a whole session (token AND tec_user — §4)
  │
  ▼
middleware → the app's landing → ssoRedirect → hub.tecosystem.app/api/auth/sso
                                                 ?target=https://<app>.tecosystem.app/app
  │
  ├─ Hub HAS a session:
  │    SignJWT({ accessToken, user }) HS256, aud = the target's allowed origin, jti, exp 5m
  │    → 307 to <app>/api/auth/sso-callback?token=…&redirect=<path>
  │    → 200 HTML landing (cookies on the 200) → /api/auth/me → the app
  │
  └─ Hub has NO session in this context (Pi Browser contexts have separate jars — C-123 §7):
       → 307 to hub.tecosystem.app/?returnTo=<target>
         (only when target is an allowed app ORIGIN — isAllowedAppUrl, never a prefix)
       → "Sign in with Pi" → pi-login → back through /api/auth/sso?target=<returnTo>
         (re-validated there) → the app the user was going to   [tec-app #253]
```

Invalid or non-allowlisted `target` → `400 invalid_target` with the rejected value named.

---

## 3. COOKIE SCOPE

```
COOKIE_DOMAIN = .tecosystem.app   (env, per deployment)

cookieDomainFor(host, configured):
  host is COOKIE_DOMAIN or a subdomain of it → Domain=.tecosystem.app
  otherwise (e.g. a *.vercel.app preview)     → host-only (no Domain attribute)
```

A `Domain` the host is not under is rejected silently by the browser, which is why the
fallback is host-only rather than "always set it". All apps share `JWT_SECRET` and
`JWT_REFRESH_SECRET` with the auth service; SSO is needed only when the app's own
cookies are absent.

---

## 4. PAGE GUARD — a session is BOTH cookies

`middleware.ts` admits a protected page only with **`tec_access_token` AND `tec_user`**
— the same definition `/api/auth/me` uses. A half session (either one missing) goes to
the landing / SSO, never into the page. `/api/auth/me` answers `401` with a `reason`:
`no_token` · `no_user` · `bad_user` (never token data); Settings shows that word when it
says "Not signed in".

---

## 5. JWT VERIFICATION

```typescript
// Backend and BFF
jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256']  // ✅ ALWAYS specify algorithms
});

// ❌ NEVER
jwt.decode(token)  // Policy CI blocks this
```

---

## 6. @yasser172/tec-auth PACKAGE (v1.2.0)

Exports the client helpers every app uses — `usePiAuth`, `ssoRedirect` / `buildSsoUrl`,
`loginWithPi`, `refreshAccessToken`, `fetchWithAuth`, `logout` — and a
`createAuthMiddleware` under `@yasser172/tec-auth/middleware`.

**No app currently uses `createAuthMiddleware`.** Each app carries its own `middleware.ts`
from `tec-template-base` (page guard §4 + CSRF §7). Change the guard there, per app, or
move the fleet onto the package in one coordinated change — not half of each.

---

## 7. CSRF PROTECTION — middleware only

```
A state-changing request (POST/PUT/PATCH/DELETE) on a CSRF-protected path is trusted when:
  1. double-submit: tec_csrf cookie === x-csrf-token header (timing-safe), OR
  2. first-party:   Origin host === Host, or Origin host ends with .tecosystem.app
Otherwise → 403.
```

- Enforced in **`middleware.ts` and nowhere else** (C-12 §11). A route handler must never
  compare cookie to header itself — that 403'd legitimate Mode-2 payments in Pi Browser.
- Payment routes are **not** exempt; the first-party rule is what lets them through.

---

## 10. REDIS BLACKLIST

```typescript
blacklist.set(oldRefreshToken, 'used', { EX: 7 * 24 * 60 * 60 });

// Startup guard
if (!process.env.REDIS_URL && process.env.NODE_ENV === 'production') {
  throw new Error('REDIS_URL required for token rotation');
}
```
