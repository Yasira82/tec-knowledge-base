# Session 56p — "Not signed in", an uncounted app, and a sign-in that waited on Pi

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** across the fleet;
> **[Runtime Verified]** where a phone or a log says so below. Law recorded: **C-123 §9**
> (+ §5 rows), mirror note in **C-76**.

Three symptoms from one phone, each traced from evidence rather than guessed: the Pi
username showing on one visit and "Not signed in" on the next; `insure.pi` stuck at
**0/5** arrivals with nine pioneers opening it; and "Sign in with Pi" hanging until a
red "check your internet" message.

### 1. The name — three causes, fixed in order of evidence

| # | Cause | Fix | Where |
|---|---|---|---|
| a | The page guard admitted `tec_access_token` alone; `/api/auth/me` needs `tec_user` too. A half session got past the door with no name and no way to sign in. | Guard requires **both** (same rule as `/me`); `/me` names the missing half (`no_token` · `no_user` · `bad_user`). | Zone #51 **merged**; 19 apps + template in their open PRs |
| b | `/api/auth/refresh` renewed the token for 24h and **never** `tec_user` — a day after sign-in, the name cookie lapsed while the token lived on. | Refresh re-issues `tec_user` + `tec_csrf` with the token (copied, never invented — a lapsed cookie stays lapsed). | Insure #35 **merged**; the other 23 in open PRs (Zone #52) |
| c | Still intermittent from the Quest after (a)+(b), while a hand-opened check said the session was whole. | Settings shows **the word `/me` answered with** beside "Not signed in" — diagnosis, not a fix. | Insure #36 **merged**; Zone #52 + 18 more in open PRs |

After (a)–(c) Insure showed `@yas55eR82 · Pro · Connected to Pi` from the Quest
**[Runtime Verified]**; whether (c) ever fires again is the open question it exists to answer.

### 2. `insure.pi` 0/5 — a missing env var, hidden by a reporter that forgot failures

- The arrival route answered `200 { recorded: false }` by design, and `ArrivalReport`
  marked itself done on **any** 200 — so every refusal was treated as success and never retried.
  Now done only on `recorded === true`; the route returns `reason: gateway_<status>` and logs it.
- New read-only `GET /api/bff/pioneer/arrived` (booleans only: `configured`, `token`,
  `user`, `tokenValid`; records nothing). On Insure it read **`configured: false`** — a
  Vercel env var was missing. The owner added it; the check then read all `true`
  **[Runtime Verified]**. No request had ever reached Railway, which is why nothing showed there.

### 3. CI was not running — Actions minutes, not code

Every private repo's jobs "failed" in 2–3s with `runner_id: 0` and no log; only the one
public repo (Brookfield) ran. Before the owner made the app repos public, their **full
git history** was scanned: no `.env`, no real key, no DB password in any of the 23 apps
or in `tec-auth` / `TEC-SDK` / `Tec-ui` / `tec-knowledge-base` / `Tec-core-backend`.
**One real finding, in the Hub:** `/api/admin/clear-payment` — a "TEMP one-off" from
2026-06-29 with the Hub's Pi key as a string literal, answering an unauthenticated GET
(read any Hub payment, ask Pi to complete one). Removed in tec-app **#252 (merged)**, with
a test that fails the build on a hardcoded Pi key. The owner confirmed that key had
**already been rotated** — the literal was dead, the route was not.

After the switch, all **22 open PRs ran green** (CI, E2E, CodeQL). Still private:
`Tec-core-backend` (recommended), `tec-knowledge-base`, `TEC-SDK`, and `Tec-FundX` (its
CI will not run until it is made public or minutes are available).

### 4. The sign-in stall — Pi's bridge, not the network, not our server

Vercel + Railway, 10:53 on 2026-09-24: `sso 307 → me 401` (stalled here) → `pi-login 200`
answered by `tec-auth-service` **in the same second** → `/hub`. When it stalls there is no
`pi-login` at all: the wait is inside `Pi.authenticate`. The Quest strips the referrer so
each app runs its own `Pi.init()`; afterwards the Hub is inside **an app's** Pi context —
the mirror of ADR-007 — and the bridge never replies. Written up as **C-123 §9**.

tec-app **#253** (open): the button names its step (*Waiting for Pi…* / *Signing in…*);
*Try again* appears after 15s beside Pi's full 45s; the timeout says Pi did not respond,
not "check your internet"; `success:false` no longer freezes "Connecting…"; and
`/api/auth/sso` keeps the app as `returnTo` so sign-in finishes the trip. Because **C-76
already rejects `reload()`** for payment ownership, the retry is remembered — if Pi is
silent again, the screen says to close Pi Browser completely.

### 5. Open after this session

| # | Item | Note |
|---|------|------|
| 1 | **Does a reload reset Pi's auth context?** | First phone test of #253 answers it — record in C-123 §9 and C-76. |
| 2 | The reason word in Settings | If it appears, its value names the next fix; if it never does, (a)+(b) were the whole story. |
| 3 | Merge the fleet PRs | Guard + refresh + arrival + reason word, in one PR per app — all green. |
| 4 | `Tec-FundX` still private | Its CI cannot run until public or minutes are available. |
| 5 | `Tec-Assets` has no ESLint config | `npm run lint` exits before checking anything — pre-existing. |
