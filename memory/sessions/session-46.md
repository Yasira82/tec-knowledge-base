# SESSION 46 — ONE PLATFORM ON SCREEN (28 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-ui **v3.0.0**
> published; Hub #185 · #186, the 20 app palette PRs, NBF/Brookfield, the 19 app
> Dependabot-policy PRs and backend **#213** are all **merged**. The Hub UI work was
> **[Runtime Verified]** by the CEO in the Pi Browser, screenshot by screenshot; the
> backend merges are **[Runtime Verified]** by a green CI (30/30) on `main`.
> Token authority: **C-83** (updated this session).

The platform was one product in the architecture and three products on a phone. This
session was almost entirely about the gap between those two facts.

### 1. The fleet was painting THREE different golds

| Group | `@yasser172/tec-ui` | Gold on screen |
|-------|---------------------|----------------|
| 18 apps | `^1.1.0` | `#d4af37` (legacy) |
| 3 apps | pinned `2.1.0` | `#FBBF24` (amber-400) |
| Life | `^2.3.0` | `#FBBF24` |
| Hub | — (own tokens) | `#FBB44A` (Pi amber) |

**Root cause: a semver caret trap.** `^1.1.0` can never resolve to a 2.x, so 18 apps had
been silently frozen out of the EVL palette since v2.0.0 shipped — `npm update` was doing
exactly what it was told, forever. Nothing was broken, nothing warned, and the fleet drifted
apart for months.

**tec-ui v3.0.0** moves WEALTH to `#FBB44A`, sampled from the Pi app's own splash mark, so
a TEC app beside Pi Browser chrome reads as the same product. Values only — no export
renamed or removed (C-83).

> #### The finding that changed the fix
> **Bumping the package alone makes an app WORSE, and we proved it before shipping.**
> Rendering Zone on `^3.0.0` with its local tokens untouched produced a page carrying
> **`#050816` and `#020205` at once**. An app paints from *two* sources: `TEC_COLORS.*` in
> inline styles and `var(--tec-*)` in its own `tec-design-tokens.css`. The package bump and
> the app's local sweep are **one change**. Every app PR carries both.

**Deliberately NOT swept:** `tec-assets` (104 hardcoded hexes), `tec-commerce` (149),
`tec-ecommerce` (202). These barely consume `TEC_COLORS` — moving them is a re-skin, not an
upgrade, and it is a separate decision, not a silent one.

### 2. Fifteen apps introduced themselves as "TEC App"

The SSO landing (`src/app/api/auth/sso-callback/route.ts`) still carried the
`tec-template-base` placeholder **`🔷 TEC App`**. A user tapping *TEC Zone* in the Hub grid
was greeted by a sign-in screen for a product called "TEC App" — on the single screen where
trust is established. Now each app names itself, in **caps** (`TEC ZONE`), matching how the
brand appears in the Hub grid, the Portal listing, and the icon wordmark.

> That page is **plain HTML served before any stylesheet**, so it cannot read a CSS
> variable. Its colours are hex literals **by necessity**, not by oversight — the same
> reason `next/og` (Satori) resolves no custom properties. Do not "fix" them into `var()`.

### 3. Hub navigation — the golden band, and a hidden button

CEO-reported, in this order: the gold topbar band was too loud on the Hub home; the
username chip looked like a hidden button because nothing said it opened anything;
`Settings` was the wrong word for what the page does; the wallet card ate the fold.

- gold band → **inner pages only**; Hub home carries `var(--tec-bg)`
- username chip → a real **account menu** (`HubAccountMenu`), opened by a **3-bar** glyph,
  not a chevron — the CEO rejected the chevron explicitly
- `Settings` → **Profile**, with its own icon
- bottom nav → **5 tabs**; Profile + Dashboard moved behind the avatar
- wallet card compacted, with a **24h market** delta modelled on Binance/OKX — labelled
  *market*, **never** "PNL" or profit: the platform does not compute the user's P&L, and a
  fiat delta on a held balance is not one.

Also this session: a traced-monogram `TecMark` component, and the 1024/512/192 + maskable
app icons in `public/brand/`.

### 4. One Dependabot policy, and 112 PRs that could never merge

19 repos still ran the original config — no `ignore`, and a group covering only
`devDependencies`. On a platform pinning **Next 15 / React 18 / @sentry/nextjs v8**, that
manufactures unmergeable work: the standing `dev-dependencies` PR bumped `typescript` to
`^7.0.2` and `eslint-config-next` to `16.3.1`.

> **Next 15 does not recognise TypeScript 7 as a TypeScript install at all** — it reports
> "It looks like you're trying to use TypeScript but do not have the required package(s)
> installed", so Typecheck and the build fail before reading a line of source. **No tsconfig
> change reaches it.** `eslint-config-next`'s major tracks the Next major, so 16 on Next 15
> is a mismatch by construction.

Dependabot rebuilt that PR after **every** merge, so a permanent red check followed each
repo around — which is how a CI signal teaches people to ignore it.

`tec-template-base` had already solved this and every app cloned from it since (NBF,
Brookfield) shipped the fix; the fleet simply never back-adopted it. Copied verbatim to all
19 + the Hub: **ignore ALL majors**, one grouped **minor+patch** PR, `github-actions`
grouped the same way. **112 stale Dependabot PRs closed** across the 18 domain apps —
nothing is lost, the legitimate minors return as one grouped PR.

**Left open on purpose:** `tec-core-backend` (16 real per-service patch bumps, different
repo, no policy change applied), `tec-assets` #46 / `tec-commerce` #54 (repos excluded
above), and NBF/Brookfield/template-base — whose open PRs are exactly what the new policy
*wants*.

### 5. The process defect behind all of it

Three times this session the CEO asked *"why is there no open PR?"* Work was pushed to the
branch and left there, because the standing instruction is "do not open a PR unless asked".
In a workflow where the CEO's job **is** to merge, a pushed branch with no PR is invisible
work. **Rule adopted: pushing to the development branch and opening its PR are one step.**

### 6. The backend got the policy too — and it needed a different one (#213)

`tec-core-backend` was the one repo the app policy could **not** simply be copied into, and
reading it first is why. The `ignore`-majors half was **already correct** in all 13 service
blocks — which is exactly why this repo never produced the TypeScript 7 PRs the app fleet
was drowning in. Three real gaps sat underneath that:

| Gap | Detail |
|-----|--------|
| **No grouping** | One PR per package per service → 16 open PRs in a routine month: the same swarm the apps had just escaped, arriving one patch at a time. |
| **The root app was invisible** | `/package.json` is a real Nest app (NestJS 10 · Prisma 5 · helmet · ioredis · bcrypt) and **no block named `/`**. It had never received an update of any kind, security included. |
| **No `github-actions` block at all** | Every action across 7 workflows unwatched: `actions/setup-node` on **v4** while the fleet had moved to v6; `checkout@v4` receiving no security updates. |

Two differences from the app policy, chosen rather than inherited:
- **Grouping stops AT the service boundary.** Each service owns its `package.json` and
  deploys independently on Railway, so a PR spanning two services would let one red check
  block eleven unrelated deploys. **Thirteen grouped PRs is the correct shape here, not one.**
- **Majors stay ignored for npm but NOT for actions.** Nothing here pins an action major,
  and every workflow already pins `node-version: '20'` on `ubuntu-latest`, so a
  runner-action major cannot change the Node the build runs on.

Monthly is kept (the fleet is weekly): this repo is the head of the release chain, so churn
here is the most expensive churn on the platform.

**Outcome, verified:** #213 merged, then 14 of the 16 standing dependency PRs merged —
**CI 30/30 green on `main`**, no deploy broken. The policy proved itself immediately:
Dependabot's next runs opened **#214** and **#215** as *grouped* PRs (one per service, 3
updates in one), not one per package.

**Two did not merge, for a reason worth keeping:** #175 (`class-validator`, auth-service)
and #184 (`@aws-sdk/client-s3`, storage-service) hit lockfile conflicts because an earlier
merge touched the *same service*. That is the grouping argument demonstrated live —
per-package PRs against a shared lockfile conflict with each other by construction.
**#175 also deserves a look rather than a merge:** `0.14 → 0.15` on a `0.x` package is
breaking under semver, and it sits on the auth path.

### Honest status
- `[Runtime Verified]`: the Hub nav/wallet/icon work, on a phone, by the CEO; the backend
  merges, by a green CI on `main`.
- `[Code Verified]` only: the palette on the 20 apps + NBF/Brookfield — each passes
  typecheck/lint/tests/build, but only Life, Zone and Epic were seen on a real device.
- **The palette PRs must deploy together.** A staggered Vercel deploy puts two palettes on
  screen across the fleet at once — the exact failure this session existed to end.

### 7. Three defects the Dependabot work uncovered in the backend deploy path

Merging the grouped PRs meant watching real CI runs on `main` for the first time in
a while. That is the only reason any of this became visible — none of it was caused by
a dependency bump, and none of it would have surfaced from reading the code.

#### (a) The deploy step had never deployed a single service

It derived the Railway name by stripping **both** the repo's `tec-` prefix and the
`-service` suffix:

```
tec-auth-service  →  auth-service  →  auth
```

Railway keeps the suffix (`auth-service`, `kyc-service`, `storage-service`, …), so every
lookup missed. `api-gateway` has no suffix and was the only name that came out right —
which is why nobody noticed. **And the miss was swallowed:** `not found` logged a
`::warning::` and `exit 0`, so the job reported SUCCESS while doing nothing. Eleven
services had been shipping a green Deploy check that did no work; they are live only
because Railway deploys from the repo itself.

#### (b) A push to ANY development branch deployed to PRODUCTION

`on.push.branches` includes `'claude/**'`, and the deploy job was guarded on
`github.event_name == 'push'` with **no branch check** — no pull request, no review.

> **The bug in (a) was acting as the access control.** Every branch deploy asked for the
> wrong name, got "not found", and exited 0. Fixing the name removed that accidental
> safety net — and the deploy job in the fix's own PR ran for **45 seconds against
> production** instead of skipping. That is how it was caught.
>
> Nothing harmful shipped (the branch's `src/` was identical to `main`), but this is the
> sharpest lesson of the session: **a defect can be load-bearing.** Repairing one without
> looking at what it was silently preventing is how a fix becomes an incident.

Guard is now explicit: `github.ref == 'refs/heads/main'`. `docker-build` deliberately
still runs on branches — building an image is how a PR proves it builds, and it pushes
nothing.

#### (c) The auth-service image could not build without the network

`bcrypt` is a native module. On musl it downloads a prebuilt binary from GitHub release
assets and falls back to compiling from source — but the alpine image has no Python or
toolchain, so the fallback cannot run. A single `ECONNRESET` on that download killed the
build. The platform's **identity authority** had a build that any network blip could
break. The toolchain is now a virtual package removed in the same layer.

#### The resolution — and it was one invisible character

Fixing the name turned the silent `exit 0` into a real red run: `identity-service`
**not found**, while four sibling services deployed. Rather than guess between the
plausible causes (token scope · wrong project · stale config), the failure branch was made
to print what the token can actually see. Three services carried a **trailing space** in
their Railway name — `identity-service `, `commerce-service `, `notification-service ` —
and the correlation was exact: the four without it deployed, the one with it failed.

Renamed in the Railway dashboard (an owner action, no code change) → **`Deploy
(tec-identity-service)` went green.** That is the first time this pipeline has ever
deployed a `-service`; every previous green was the swallowed `exit 0`.

> **When a fix produces a red run, the red run is the deliverable.** The instinct is to
> explain it away. Printing what the tool actually sees cost four lines and settled it in
> one run — three plausible theories are worth less than one piece of evidence.

Also hardened: `--service $VAR` was unquoted, so a name containing whitespace could never
be addressed at all — the shell silently dropped it. Quoted now, so the rename cannot be
undone later by a shell detail.

**Shipped:** tec-core-backend **#226** (name + Dockerfile), **#227** (the branch guard),
**#229** (self-diagnosing failure), **#231** (quoting).
#226 squash-merged only its first commit, so the guard had to follow separately — worth
remembering, because for a while `main` had the name fix *without* the guard, which is the
most dangerous of the three combinations.

**Also verified, not assumed:** `class-validator 0.14 → 0.15` (a breaking bump under semver
on a `0.x`, sitting on the auth path) was installed locally and exercised before merging —
typecheck clean, 47/47 tests, and a purpose-written probe confirming the auth DTOs still
**reject** empty / non-string / oversized / malformed input. A validation library that
fails *open* is a P6 violation, and that is not something a passing test suite proves on
its own.

### Open after Session 46 (nothing here is blocked — all are decisions)

| # | Item | Why it is still open |
|---|------|----------------------|
| 1 | **Assets · Commerce · Ecommerce re-skin** | 104 / 149 / 202 hardcoded hexes. These barely consume `TEC_COLORS`, so this is a re-skin, not a version bump — real design work, and a decision, not a sweep. Until then **3 of 26 repos stay on the old palette**, and that is a known, deliberate gap, not drift. |
| 2 | **npm Trusted Publishing** | Tokens now expire **25 Nov 2026**. The Aug 26 expiry caused a publish `E404` — on a scoped package, `E404` on `PUT` means *auth failure*, not "not found", which is why it read as a missing package. Trusted Publishing removes this whole class of failure; worth doing before the next expiry rather than after it. |
| 3 | Backend grouped PRs | ✅ **CLOSED.** 7 of 12 merged directly; the 5 stale ones could not be rebased from here, so their updates were applied against current `main` instead (**#228** — 339 tests green across identity · realtime · kyc · storage · api-gateway) and Dependabot auto-closed all five. One bump deliberately NOT taken: #217 would have **downgraded** identity's `@typescript-eslint/parser` `^8.65.0 → ^8.59.1` (its branch predates #183) — every dep resolved as `max(main, PR)`, never copied. |
| 4 | **Fleet deploy of the palette** | Merged ≠ deployed. Until every app is redeployed on Vercel, the fleet is mid-flight between two palettes. |
| 5 | **Runtime-verify the palette beyond 3 apps** | Only Life, Zone and Epic were seen on a real device. The other 20 are `[Code Verified]` and nothing more. |
