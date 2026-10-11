# Session 56v — signed in, and shown "Sign in with Pi": a cookie encoded twice (10–11 Oct 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for the symptom and the
> diagnosis (the owner's phone: `/api/auth/me` answered `authenticated:true` for `mans809` while
> `/` showed the sign-in; auth-service logs showed every sign-in); **[Code Verified]** for every PR —
> a test that failed before the fix and passes after, tsc, lint, the full suite. Same branch as
> 56s–56u (`claude/tec-knowledge-base-review-6wzngc`).

## 1. The symptom (10 Oct)

The owner: "only my account opens; any other account doesn't" — on Testnet (`tec-connection`,
`tec-commerce-app`, `tec-ecommerce`, `tec-life`, `tec-zone-mu`) **and** Mainnet
(`explorer.tecosystem.app`). Apps nobody had touched (Connection, Zone) too, so it was not the
cookie-domain work of 56u §4f.

What ruled things out:

- **auth-service** `piLogin` was fine: the logs showed `Pi login: mans809 (new: false)`,
  `magy888`, `manso83`, `FAARSS876`… every account signed in.
- **The session existed**: `/api/auth/me` on the owner's phone, signed in as `mans809`, answered
  `authenticated:true`. `/app` opened. Only `/` kept the sign-in button.

## 2. The cause — `tec_user` encoded twice

Every app's SSO landing (`/api/auth/sso-callback`) did:

```ts
const userValue = encodeURIComponent(JSON.stringify(user));
res.cookies.set('tec_user', userValue, cookieOpts);   // Next encodes the value AGAIN
```

The browser held `%257B%2522id…`. `getStoredUser()` (`@yasser172/tec-auth`) reads
`document.cookie`, decodes **once**, parses JSON — and failed, so `usePiAuth()` said signed out.
The server never noticed: `/api/auth/me` reads through Next (one decode) and then tries a second.
So every screen gated on `/me` worked, and every screen gated on `usePiAuth()` (Connection's
landing and its redirect into the app, a name in a header) showed the person as signed out.

**Why only the owner:** his browser still held an older copy written by the landing's
`document.cookie` fallback, which encodes once. A new account only ever got the server's copy.

**Not affected:** Pi's visit count. `PiWarmup` runs `Pi.authenticate` in the app on every
standalone page load, and the arrival report (`/api/bff/pioneer/arrived`) checks the session on
the server — both worked throughout (C-123 §3, F3).

## 3. The fixes

| Round | What | PRs |
|---|---|---|
| 1 — the writer | `sso-callback` sets `tec_user` as raw JSON (encoded once by `cookies.set`). Test `sso-user-cookie.test.ts`: the Set-Cookie must parse with ONE decode. Ecommerce's in-app `pi-login` had the same bug. Assets and Commerce already wrote raw JSON — test only | Alert #51 · Analytics #64 · Assets #77 · Commerce #89 · Connection #93 · Dx #50 · Ecommerce #81 · Elite #44 · Epic #52 · Estate #48 · Explorer #60 · FundX #41 · Insure #46 · Legend #47 · Life #81 · Nexus #46 · Nx #44 · Titan #43 · VIP #43 · Zone #64 · System #49 · template-base #50 · **NBF #30 · Brookfield #26** (missed at first — not attached to the session) |
| 2 — the old cookie | **Connection's landing** asks `/api/auth/me` before keeping a member on the sign-in button (the owner: Connection still failed after round 1 was deployed). **`refresh`** re-issued `tec_user` exactly as found, renewing the double-encoded copy daily — it now re-issues it as JSON. **`refresh` and `logout`** used `COOKIE_DOMAIN` as-is: on `*.vercel.app` a `Domain=.tecosystem.app` cookie is dropped silently, so the renewal never landed and logout never cleared — now `cookieDomainFor` (C-123 §2 rule 2). Test `session-cookies-renewal.test.ts` | Connection #94 (landing + refresh/logout) · Alert #52 · Analytics #65 · Assets #78 · Commerce #90 · Dx #51 · Ecommerce #82 · Elite #45 · Epic #53 · Estate #49 · Explorer #61 · FundX #42 · Insure #47 · Legend #48 · Life #82 · Nexus #47 · Nx #45 · Titan #44 · VIP #44 · Zone #65 · System #50 · template-base #51 · NBF #30 · Brookfield #26 (same PRs as round 1) |

C-123 LAW 2 is kept throughout: cookies are set only on 200 responses. Round 1 is merged in 22
repos (11 Oct); NBF #30 and Brookfield #26 are open and carry both rounds. (Connection and Dx previews failed on Vercel at the moment 22 repos were
pushed at once; both built locally, and main deployed — the build quota, not the code).

## 4. Lessons

- **Next's `cookies.set` encodes the value.** Hand it the raw string. Pinned by
  `sso-user-cookie.test.ts` in every app and the template.
- **Fixing a writer does not fix what browsers already hold** — and a route that renews a cookie
  as-found (`refresh`) keeps a bad one alive forever. Heal on renewal.
- **A rule that lives in some routes is a rule the fleet does not have.** `cookieDomainFor` was in
  every `sso-callback` but in 4 of 24 `refresh` routes.
- **Check the attached repos against `architecture/app-fleet.yaml`, not against the session's
  list** — NBF and Brookfield were missed because they were not attached.
- **Never push with the output silenced.** Two "pushed" branches had been rejected; found only by
  the stop hook.

## 5. Open

- The owner: merge NBF #30 · Brookfield #26 and round 2 (the 11 Oct PRs above), then test a non-owner account on Connection's
  `/`, Testnet and Mainnet. A browser that still holds the old cookie heals on its next sign-in
  or refresh.
- `@yasser172/tec-auth` `getStoredUser()` decodes once — correct for cookies written right; no
  package change made.
