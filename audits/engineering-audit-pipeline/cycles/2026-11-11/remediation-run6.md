# Remediation after Run 6 — 14 Nov 2026 (local commits; nothing pushed)

GitHub Actions is still refused for the account, so every change below is a local commit in
its repository, waiting with the rest of the cycle's work. Every fix was checked the same way:
a test red on the code before it and green after, then type-check, lint and the full suite.

| Finding | What changed | Where |
|---|---|---|
| 0035 | The example BFF route copied into the 18 template apps (it was listed as shared and never carried) | 18 apps |
| **0033 (reopened)** | The first sweep and its guard matched only `fetch(\`${X}/api/…\`)`; every call whose URL is built first had no deadline — the one gateway helper of seven apps (their whole BFF), the shared GET helper of three, ten Hub routes, Explorer's reviews. All through `gatewayFetch`; uploads to storage, OKX, AI probes, Upstash and `fetchWithRetry` got their own deadline. The guard now judges every `fetch(` by its arguments | template · 25 repos |
| 0005 | Life and Zone onto the template's shared files; all 20 template apps match | Life · Zone |
| 0044 | Files every app copied by hand are the template's and tracked: `auth/me` (the diagnostic one), `useMe`, ErrorBoundary, the cancel button, the referral loop (with its first test), `payment/create`, three guard tests | template · 20 apps |
| **0045** | (later the same day, on the owner's go-ahead: the Hub's last browser path, `getPaymentStatus()`, removed — the Hub is on tec-sdk ^1.4.0 too) tec-ui ^3 in the three apps pinned to 2.1.0; tec-sdk ^1.4.0. **New:** browser code reached the server SDK (`pi-auth` → `lib/sdk`) in the template and 21 of 25 repos; it broke Ecommerce's build on 1.4.0. Removed; a transitive boundary test guards it. The Hub's instructions corrected | template · 24 repos |
| 0042 | My own Run 5 change had broken a template test (a marker on `package.json` erased by the test's compact rewrite); fixed | template |

## What this run taught (recorded so it is not relearned)

1. **A self-check proves a search finds what it was written for, not what it was not.**
   0033's guard had a self-check — in the one shape the sweep had already fixed. The second
   pass found the gap only because Life's helper was read by hand.
2. **Run the whole suite, not the tests of the change.** Run 5 broke a template test that the
   files it touched did not import.
3. **A version bump is a test of the boundaries.** tec-sdk 1.4.0 changed nothing for the apps
   that kept their boundary, and broke the build of the one that did not — and showed that 21
   repos only did not break because no page happened to import the file.

## Left for the owner

- Whether the Hub adopts `tec-ui` / `tec-auth` (ADR).
- The referral loop in Analytics, Explorer, NBF and Brookfield (product decision).

## Later on 14 Nov — one reading of the Pro status (0044, expand half)

Every screen in 21 apps and the server now read "is this person Pro here?" through one pure,
fail-closed reader, tested against the six shapes commerce really returns, with a guard against
hand-parsing. Two user-visible bugs went with the old readers: **Analytics' and Connection's
settings showed FREE to paying users** (the envelope was never unwrapped), and **Life's home page
borrowed the Hub plan from the cookie** when its own read was loading or failed. The contract half followed the same day: every template app's route now answers the one
shape (the resolver's), from one shared file.

## Recommendations on what is the owner's to decide (not decided here)

| Question | Recommendation | Why |
|---|---|---|
| Should the Hub depend on `tec-auth`? | **No — record it as the decision** | The Hub issues the session; `tec-auth` is the library for apps that consume it. A dependency would point the wrong way |
| Should the Hub adopt `tec-ui`? | **Not in Phase 0** — revisit when a component exists in both | The Hub has its own tokens; adopting means restyling the Hub, a visual change with no defect behind it |
| The referral loop in Analytics and Explorer | **Yes** | Both are TEC apps under C-133's growth loop; it is the shared files plus two lines in the layout |
| The referral loop in NBF and Brookfield | **The owner's call** | They carry their own brand; whether TEC's invite reward belongs there is a product question |


## Later on 14 Nov — the Hub's CSP (0004)

The Hub's `script-src` no longer allows inline scripts wholesale. The middleware makes a fresh
nonce per request and sends the policy (`src/lib/csp.ts`, the one place it is written) with
`'strict-dynamic'`. Next.js stamps its own scripts with the nonce; the layout's boot scripts, the
Pi SDK tag and the sign-in landing page stamp theirs. Checked on a production build in Chromium:
every page is dynamic, every executable script carries the nonce, the pages hydrate, and an
injected `onerror` handler — which the old policy ran — is refused.

`'unsafe-eval'` is the one part left, on purpose. The Pi SDK is served from sdk.minepi.com and
could not be read from here; if it calls eval, refusing it breaks sign-in for everyone. So a
report-only twin refuses eval and reports to `/api/csp-report`. The Hub's own bundle has no
eval. **Owner:** after the deploy, one Pi Browser sign-in and one Mode-2 payment; if the log has no
`csp.violation` line with `eval`, set `CSP_ENFORCE_NO_EVAL=1` on Vercel and redeploy. The same
pattern then goes to the template apps (0018 part 3).

## Later on 14 Nov — request bodies through schemas (0007)

Every service now reads a request body one way: `parseBody` (the template's
`src/middleware/parse-body.ts`, byte-identical wherever it is carried, checked in CI) — the
schema's output, or a 400 that names each field and never its value. It went in at every body
edge that had a gap in kyc, storage, notification, realtime, identity and commerce, each with a
test that fails on the old code. Types were the smaller part of what it caught:

- **Unregistering one device unregistered all of them.** A DELETE with no token ran
  `deleteMany({ token: undefined, user_id })`, and Prisma reads `undefined` as no condition.
- A storage purge sent `keys` that was not a list answered "deleted 0" — a cleanup that did
  nothing and said it was fine.
- `done: "true"` on a reminder **un-ticked** it; a review rating of 1000 went into a product's
  stars; a gift's `days` could reach the service as NaN.
- Two security holes, recorded as **0046** and **0047** (withheld while open, README §7).

Not converted, on purpose: routes that already check every field by hand with a named reason
(analytics' intent observation, identity's internal controllers, commerce's payout). Rewriting a
strict, tested validator in another library adds a diff, not safety.

The Hub half: `file-size.test.ts` — no source file over 600 lines without a recorded reason. Four
are listed (the campaign page first, at 1229), each with its reason and a ceiling it may not grow
past.
