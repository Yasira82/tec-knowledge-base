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
| Sign-in button waits, then `AUTH_TIMEOUT` — and **no `POST /api/auth/pi-login` in Vercel at all** | phone + Vercel logs | The wait is inside `Pi.authenticate`, not the network and not our server. Pi's bridge is silent — see **§9**. |
| `/api/auth/sso 307 → / → /api/auth/me 401 → pi-login → /hub` | Vercel logs | An app sent the visitor to the Hub from a context with no Hub cookies (§7). Before tec-app #253 the destination was dropped on that bounce, so sign-in landed on `/hub`, not the app. |

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
| #67 | **+ Partitioned (CHIPS)** + matching deletion attributes + landing diagnostics | ✅ login, re-login and wallet Runtime Verified — but still cookie-DEPENDENT |
| #69 | **cookie-independent session (§7)** — in-memory token + Authorization-header BFF + silent Pi re-auth + always-rendering /hub | ✅ **structural end-state** — Runtime Verified in production (the owner's "all good" on the phone) |

Separate but related: the initial "login does nothing" was a **stuck incomplete
U2A payment** surfacing on every authenticate — resolved by **completing** it on
Pi with its txid (U2A payments cannot be cancelled). See C-02 Session 16.

**Propagation — COMPLETE (July 2026), C-123 is now platform-wide:**

| Repo | PR | Notes |
|------|----|-------|
| tec-analytics | #4 | first propagation — pattern validated (SSO Runtime Verified) |
| tec-ecommerce | #48 | + audience allowlist (was issuer-only verification) |
| tec-assets | #36 | jti guard kept; tests updated to 200-landing contract |
| tec-commerce | #46 | jti guard kept; tests updated to 200-landing contract |
| tec-template-base | #16 | **golden template — future apps inherit the law, not the bug** |

Each: 200 HTML landing + verified entry (`/api/auth/me` gate) + jti replay guard +
`none/secure/Partitioned` on all session cookies + new `/api/auth/me` + new
`/api/auth/logout` with creation-matching deletion attributes. Zero payment files
touched. All repos: typecheck clean + full test suites green.

**§7 hardening (tec-app #70):** `bffFetch` — on a BFF 401 in Pi Browser, ONE
silent re-auth (single-flight, 30s cooldown) then a single retry. The 1h
in-memory-token expiry in cookie-refusing contexts now self-heals mid-session
instead of waiting for a reload. Auth storms impossible; failure degrades quiet.

**Side effect discovered (July 2026) — the landing page broke ADR-007's
referrer signal.** The 200 HTML landing navigates onward with
`location.replace()`, so the app page's `document.referrer` became the app's
own sso-callback URL instead of `hub.tecosystem.app`. Every
`isHubNavigation()` guard (C-12 §3 / C-76) then returned **false** for
Hub-entered users → apps ran `Pi.init()` / auto `Pi.authenticate()` on their
own domain **inside a Hub-owned Pi Browser session** → the Hub PaymentModal
(Mode 1) failed with *"Pi Network SDK was not initialized"* while Mode 2
(standalone) kept working. Fix (all 4 apps + template): the landing script
persists `sessionStorage.__tec_hub_entry = '1'` when **its own** referrer is
hub (identical semantics to the old 3xx chain, per-tab lifetime = Pi Browser
session ownership); `isHubNavigation()` = flag OR referrer; the Pi init layer
skips `Pi.init()` entirely on hub entry and sets `__TEC_PI_FOREIGN_SESSION`.
Hub side: `pi-session` fallback-init sandbox polarity corrected
(`=== 'true'`, was `!== 'false'` → sandbox on Mainnet when unset) and the
`/hub?pay=1` create step now waits for auth resolution (never two concurrent
`Pi.authenticate()` calls) and resolves identity via §7 (memory → cookie).
**LESSON: any change to the hub→app navigation chain MUST re-verify the
ADR-007 hub-entry signal — cookies and payments share the same chain.**

---

## §7 — COOKIE-INDEPENDENT SESSION (the structural end-state — tec-app #69)

The three laws improve cookie *odds*; they cannot remove cookie *dependence*.
Runtime proof: identical #67 code logged in successfully in the morning and
failed at night — Pi Browser opens the app in different contexts (top-level tab
vs embedded webview) with **separate, differently-restricted cookie jars**.
Therefore: **opening the app must not depend on the browser persisting anything.**

```
SESSION RESOLUTION CHAIN (client, usePiAuth):
  1. in-memory session (tec-session.ts)          ← survives client-side nav
  2. tec_user cookie                              ← accelerator when jar allows
  3. GET /api/auth/me                             ← server-visible cookie check
  4. SILENT Pi re-auth (once/page-load, single-flight)
       → pi-login → token+user held IN MEMORY    ← always works in Pi Browser

TRANSPORT: BFF calls send `Authorization: Bearer <memory token>`;
  createHandler verifies header OR cookie with the same JWT_SECRET path.
ENTRY: /hub shell always renders (middleware does NOT cookie-check it);
  the landing page proceeds INTO the app on cookie refusal — the bounce to
  the login page WAS the visible "hub won't open".
STORAGE: memory only — ADR-001 (no localStorage/sessionStorage) intact.
SECURITY: unchanged — every BFF route fail-closes without a valid token (P6);
  page visibility is not authorization.
```

Result: the app opens in EVERY Pi Browser context. Cookies, when the context
accepts them (§1–§2 rules), skip step 4 — an accelerator, never a requirement.

---

## §8 — ANTI-REGRESSION GATES

1. `refresh-cookie.test.ts` asserts `sameSite === 'none'` — a lax PR fails CI.
2. sso-callback contract test asserts **200 HTML + cookies + verify script**.
3. `usePiAuth` tests assert server-fallback + no-logout-on-refresh-failure.
4. Rule for reviewers: any PR touching cookie attributes, the login flow, or
   refresh logic MUST cite this spec and explain which LAW it preserves.
5. Any PR touching the sso-callback landing or the hub→app navigation chain
   MUST keep the `__tec_hub_entry` sessionStorage signal intact (C-12 §3) —
   the referrer alone is NOT a reliable hub-entry signal anymore.

---

## §9 — THE HUB INSIDE AN APP'S PI CONTEXT (the reverse foreign session)

> Truth State: **[Current State]** · Verification: the log evidence is **[Runtime Verified]**
> (Vercel + Railway, 2026-09-24); the causal chain is **[Assumed]** — consistent with
> C-02 and C-76, not yet confirmed on a device. Mitigation: tec-app **#253** (open).

ADR-007 (C-76) protects an **app** from calling Pi inside a session the **Hub** owns.
Nothing protected the **Hub** from the mirror case, and the Founding 100 Quest now
produces it on purpose:

```
Quest link  → rel="noreferrer"  → the app sees a standalone visit
            → the app loads pi-sdk.js and runs its OWN Pi.init()     (so Pi counts the visit
                                                                       toward the .pi claim)
            → Pi Browser's app context now belongs to THAT app
back to Hub → "Sign in with Pi" → Pi.authenticate()  → the bridge never replies
            → 45s → AUTH_TIMEOUT ("check your internet" until #253 — the network was fine)
close Pi Browser, reopen → fresh context → sign-in works in a second
```

**Observed (2026-09-24):** the owner, signed in 40 seconds earlier, opened an app from
the Quest; the app bounced to `/api/auth/sso`; the Hub had no cookies in that context
(§7) → `me 401` → the sign-in page. `pi-login` was answered by `tec-auth-service` in the
**same second** it arrived — the server was never the wait.

**What recovers it — and what is NOT established.** Re-running `Pi.init()` is already
rejected (C-76: "already initialized" persists). **A page reload is also listed there
as rejected for payment ownership** ("Pi Browser preserves session across reloads"),
and what recovered sign-in on the phone was **closing Pi Browser entirely**. Whether a
reload is enough for *authentication* is therefore unknown. tec-app #253 does not
assume it:

1. The button names the step — *Waiting for Pi…* / *Signing in…* — so a stall is
   attributable at a glance (the server half has never been the slow one).
2. After **15s** of Pi silence, *Try again* appears **beside** the wait (Pi keeps its
   full 45s — a first sign-in shows Pi's permission screen, and reading it is not a hang).
3. *Try again* reloads, and is remembered for 5 minutes. If Pi is silent **again**, the
   screen stops offering it and says: *close Pi Browser completely, then open the Hub
   again.*
4. `/api/auth/sso` carries the app as `returnTo` on the no-session bounce, so the
   sign-in finishes the trip the visitor started.

**The first phone test closes the open question:** after touring Quest apps, sign in
to the Hub and press *Try again* at 15s. Signs in → a reload suffices; the "close Pi
Browser" message → only a full restart does. Record the answer here and in C-76.

**Rule:** any code that calls `Pi.authenticate` on the Hub MUST show which step it is
waiting on and MUST offer a recovery before its own timeout. A silent bridge is not an
error, so nothing else will ever surface it.

---

## Related Documents

- `C-02___CURRENT_STATE_.md` — Session 16 (full incident narrative)
- `C-12_Dual_Mode_Payment.md` — payment-side Pi Browser constraints (CSRF §11)
- `C-47` Kernel Spec — P6 Fail Closed (why /api/auth/me 401s by default)
- `C-76___ADR-007.md` — Pi foreign session (payment counterpart of these laws; §9 is its mirror)
- `C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md` — incident process
