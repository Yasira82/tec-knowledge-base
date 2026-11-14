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
| **0045** | tec-ui ^3 in the three apps pinned to 2.1.0; tec-sdk ^1.4.0. **New:** browser code reached the server SDK (`pi-auth` → `lib/sdk`) in the template and 21 of 25 repos; it broke Ecommerce's build on 1.4.0. Removed; a transitive boundary test guards it. The Hub's instructions corrected | template · 24 repos |
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

- The Hub: `getPaymentStatus()` reaches the server SDK from the browser (no production caller;
  cannot work there). Remove it, or a server route that checks the caller owns the payment.
  Until then the Hub stays on tec-sdk 1.2.2.
- Whether the Hub adopts `tec-ui` / `tec-auth` (ADR).
- The referral loop in Analytics, Explorer, NBF and Brookfield (product decision).
- One subscription contract: every app's Pro card reading `lib/subscription/pro-status.ts`
  (today each parses commerce's answer by hand) — its own piece of work.
