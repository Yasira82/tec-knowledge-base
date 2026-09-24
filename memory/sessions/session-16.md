# SESSION 16 — HUB LOGIN LOOP IN PI BROWSER (root-caused & fixed) (29 June 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified] + [Runtime Verified]** (Vercel logs + production retest)

**Symptom (production, `hub.tecosystem.app`, Pi Browser only):** "Sign in with Pi"
succeeded on the backend but the Hub never opened — it looped login → `/hub` → `/`
every few seconds. Standalone Chrome was fine.

**Two independent causes (one masked the other):**

1. **Stuck incomplete Pi payment (red herring, now cleared).** An approved +
   on-chain-verified but **not** `developer_completed` U2A payment
   (`BgWyxcJfkmeuBLwcYR2ILwBZV4XT`, `source:ecommerce`) surfaced on every
   `onIncompletePaymentFound`. `resolve-incomplete` returned **409** (terminal
   locally) so it never cleared on Pi → noise in the logs. **Resolved** by calling
   Pi `…/complete` with the txid (cancel is invalid for U2A). Not the real blocker.

2. **THE real blocker — Pi Browser cookie handling.** The frontend decided "am I
   logged in?" by reading `tec_user` from `document.cookie`. Pi Browser (a) **drops
   `sameSite=None` cookies** and (b) can **hide a stored cookie from client JS** even
   while sending it to the server (proof: `/hub` returned **304**, i.e. middleware
   *saw* `tec_access_token`, yet client `getStoredUser()` was null → `usePiAuth`
   `isAuthenticated=false` → `router.replace('/')`).

**Fix (Hub repo, merged to `main` via #56 + #58):**

| Change | File(s) | Why |
|--------|---------|-----|
| `sameSite` `none` → **`lax`** on session cookies | `api/auth/{pi-login,refresh,sso-callback,logout-from-sso}`, `middleware.ts` | Pi Browser keeps `lax`; first-party Hub cookies sent on the top-level nav to `/hub`. SSO unaffected (token rides the URL, not a cross-domain cookie). |
| New **`GET /api/auth/me`** | `api/auth/me/route.ts` | Server resolves the session from the request cookie (always readable server-side) → returns the user; fail-closed 401. |
| `usePiAuth` server fallback + `authSettledRef` | `lib-client/hooks/usePiAuth.ts` | When the client cookie read returns null, ask `/api/auth/me`; stay `isLoading` until it resolves so `/hub` shows a skeleton instead of bouncing. Ref stops a late `/api/auth/me` clobbering a succeeded login. |
| Tests aligned (`sameSite='lax'`, async `usePiAuth`) + race-guard test | `__tests__/auth/refresh-cookie.test.ts`, `__tests__/usePiAuth.test.ts` | CI green on `main`. |

**Deployment lesson:** production `hub.tecosystem.app` builds from **`main`**, not the
`claude/*` working branch — fixes on the branch had no effect until merged. Confirm the
target branch before "it didn't work" investigations.

**RESOLVED — wallet/assets/notifications blank after login = expired access token, no
client refresh.** Truth State: **[Runtime Verified]** (temp `/api/admin/auth-debug`).

The first hypothesis (JWT_SECRET mismatch) was **WRONG** — `JWT_SECRET` is correct.
A temporary diagnostic endpoint proved it: `verify: FAIL`, `verifyError:
**ERR_JWT_EXPIRED**`, `exp - iat = 3600` → **the access token lives ~1 hour**
(auth-service `JWT_EXPIRES_IN`). Once it expires, every authenticated BFF call hit
`createHandler.extractContext` → `jwtVerify` → `ERR_JWT_EXPIRED` → 401 `UNAUTHORIZED`,
and `useHubData` used a plain `fetch` with **no refresh**, so the dashboard data went
blank (`balance` stuck at `—`). The wallet route's own `TOKEN_EXPIRED`→refresh path never
ran because `extractContext` rejects the expired token *first*.

**Full root cause (proven via auth-debug, `backendRefresh` field):** TWO things compound:
1. **Access token lives ~1h** (`JWT_EXPIRES_IN=3600` in tec-auth-service) → expires fast.
2. **Refresh tokens are single-use (rotation)** — backend returns `401 "Refresh token
   already used"` on any reuse. In Pi Browser the rotated `tec_refresh_token` set via the
   refresh **XHR response** does not reliably persist, so the next refresh resends the
   already-consumed token → 401 → dead session (expired access + used refresh).

**Regression I caused + reverted:** `#60` switched `useHubData` to `fetchWithAuth`, whose
`refreshAccessToken` calls `logout()` on refresh failure. With refresh 401ing, that became
a **logout→re-SSO thrash loop** in production. **#62 reverted** `useHubData` to plain
`fetch` (a 401 now just blanks the value, no session thrash).

**Fixes:**
- *Immediate:* fresh logout→login issues a clean token pair → wallet loads.
- *Durable (ops, recommended):* raise `JWT_EXPIRES_IN` in tec-auth-service (Railway) from
  `3600` to e.g. `604800` (7d, matching the refresh token) so the access token outlives a
  normal session and the fragile Pi-Browser refresh-rotation is rarely exercised.
- *Engineering fix (SHIPPED — tec-app #63):* **server-side refresh in `createHandler`.**
  Every `/api/bff/*` route now recognizes `ERR_JWT_EXPIRED` as recoverable: it refreshes at
  the gateway (**single-flight per refresh-token value** — the Hub's parallel BFF calls
  would otherwise burn the single-use token), verifies the new token, completes the request
  with it, and sets the rotated cookies (`tec_access_token` 24h lax, `tec_refresh_token` 7d
  httpOnly lax) on EVERY response path. Cookie rotation rides a normal same-origin response
  — the path Pi Browser persists reliably — instead of a client-XHR Set-Cookie. No refresh
  possible → 401 TOKEN_EXPIRED, fail closed, **never logout()**. The hourly hub/wallet
  death self-heals without any browser-side refresh logic. **Lesson:**
  `auth-debug.backendRefresh` surfaces the backend's real refusal reason — use it, don't
  guess; and token rotation must complete server-side when the client is Pi Browser.
- *Login-establishment fix (SHIPPED — tec-app #64):* the loop kept returning because
  `pi-login` set session cookies on an **XHR response**, which Pi Browser drops
  non-deterministically. Login now finishes on a **top-level navigation**: `pi-login`
  mints a one-time SSO-style token (jti, 5m) → `PiPaymentButton` navigates to
  `/api/auth/sso-callback?token=…&redirect=/hub` → cookies (incl. `tec_refresh_token`,
  new) are set on the navigation response — the same mechanism that already worked for
  Assets/Commerce SSO. Also: client `refreshAccessToken` no longer `logout()`s on failure
  (that was the `refresh 401 → logout 200` production loop), and `/api/auth/sso` forwards
  rotated refresh cookies instead of burning the single-use token.
  **RULE (Pi Browser cookie law):** session cookies may ONLY be established/rotated on
  top-level navigation responses or same-origin BFF responses — never rely on XHR
  Set-Cookie from a fetch() the client discards.
- *Final gap + fix (SHIPPED — tec-app #65):* runtime logs proved Pi Browser ALSO drops
  `Set-Cookie` on **3xx redirect responses** (`sso-callback 307` carried the cookies →
  `/hub` arrived cookie-less → middleware bounce → loop). `sso-callback` now returns a
  **200 HTML landing page**: cookies ride the 200; its script **verifies the session via
  `/api/auth/me` BEFORE navigating**, falls back to `document.cookie` for the non-httpOnly
  cookies and re-verifies; hard failure lands on `/?login=failed`. Navigation into the app
  happens only after server-confirmed session → loop structurally impossible.
  **Pi Browser cookie law (amended):** cookies persist reliably ONLY on **plain 200
  responses** — not XHR, not 3xx redirects.
- *CORRECTION + final fix (SHIPPED — tec-app #66):* the #65 landing page's double
  `/api/auth/me` check 401'd with ZERO cookies arriving (even `document.cookie` writes
  ignored) → the app was running in an **embedded Pi Browser context with third-party
  cookie semantics**, where `lax` cookies are never stored/sent and ONLY
  `sameSite=none + secure` works. The `lax` migration (#56) — based on a misleading
  in-code comment ("Pi Browser drops None") — was the regression that broke the
  previously-working login. #66 restores **`none+secure` everywhere** (middleware,
  pi-login, refresh, sso-callback + JS fallback, logout-from-sso, BFF refresh) while
  keeping all structural fixes (#63 server-side refresh, #64 no destructive logout +
  rotated-cookie forwarding, #65 server-verified 200 HTML landing).
  **FINAL COOKIE LAW: `sameSite=none + secure`, established/rotated only on 200
  responses, entry to protected pages only after server-verified session. Never
  downgrade to `lax`.**
- *Re-login fix (SHIPPED — tec-app #67):* first login worked but re-login after logout
  failed → embedded contexts under Chrome's 3P-cookie phaseout block even `none` unless
  **`Partitioned` (CHIPS)**; also logout's clearing cookies had mismatched attributes
  (silently failed to delete). All session cookies now `none+secure+Partitioned`; deletion
  attributes match creation; landing page gained a delayed retry + `[landing-report]`
  diagnostics.
- *Cookie-dependence eliminated (SHIPPED — tec-app #69, C-123 §7):* even after #67,
  identical code worked in the morning and failed at night — Pi Browser contexts
  (top-level vs embedded) keep **separate cookie jars**, so cookie behavior is
  non-deterministic by construction. Final architecture: in-memory session
  (`tec-session.ts`) + `Authorization: Bearer` on BFF calls (createHandler verifies
  header OR cookie, same JWT_SECRET) + **silent Pi re-auth** chain in `usePiAuth`
  (memory → cookie → /api/auth/me → one silent Pi auth per load) + `/hub` shell always
  renders (middleware no longer cookie-checks it; landing proceeds INTO the app on
  cookie refusal). Cookies = accelerator, never a requirement. ADR-001 + P6 intact.
  CI lock: "/hub renders cookieless" test. **Runtime Verified in production.**
- *Hub LIVE NOW (SHIPPED — tec-app #68):* Analytics flipped `coming_soon → live` in the
  domain registry (`analytics.tecosystem.app/app`); LIVE NOW now lists ALL live apps —
  Ecommerce + Analytics + Assets + Commerce (visibility ≠ authorization; KYC/role gating
  stays in each app/service, P6). External tiles enter via `/api/auth/sso?target=…`.
- *Analytics app hardened (SHIPPED — tec-analytics #4):* C-123 propagated (200 landing +
  verified entry + jti guard + none/secure/Partitioned + matching-attribute logout + new
  `/api/auth/me` + previously-MISSING `/api/auth/logout`), NEW-A cleanup (hardcoded
  Railway URL removed from client bundle; `.env.example` server-first). SSO Hub→Analytics
  **Runtime Verified** (sso-callback 200 → me 200 → /app 200). 29/29 tests.
- ✅ **SESSION 16 CLOSED — Runtime Verified end-to-end:** login ✓ · logout → re-login ✓ ·
  wallet (2,084 π rendered) ✓ · Hub→Analytics SSO ✓ · hub opens in every Pi Browser
  context (cookieless architecture) ✓.
- **OPEN (ops — user):** Analytics Vercel env (`API_GATEWAY_URL`/`SSO_SECRET`/`JWT_SECRET`
  → fixes the events 503) · Analytics Pi Portal registration (App ID TBD) · admin role SQL
  (`UPDATE users SET role='admin' WHERE pi_username='yas55eR82';` + re-login) · optional
  `JWT_EXPIRES_IN` raise · delete temp diagnostics (`/api/admin/auth-debug`,
  `/api/auth/landing-report`) once stable.
- ✅ **C-123 propagation COMPLETE (July 2026):** ecommerce #48 · assets #36 · commerce #46 ·
  **template-base #16** (future apps born compliant) — see C-123 §6 propagation table.
- ✅ **§7 hardening (tec-app #70):** silent re-auth on BFF 401 (single-flight + cooldown) —
  the 1h in-memory expiry self-heals mid-session.
  **The entire incident is codified as `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md`
  (TIER 11 — Runtime Operational Law): the 3 cookie laws, the LOCKED cookie contract,
  verified-entry login architecture, server-side refresh, diagnostic playbook, and the
  PR-by-PR incident ledger. Any future change to cookies/login/refresh MUST cite C-123.**
