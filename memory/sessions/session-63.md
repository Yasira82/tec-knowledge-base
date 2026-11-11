# Session 63 — an engineering review of the whole platform, and its findings fixed the same day (11 Nov 2026)

> Truth State: **[Current State]** for what is merged; **[Planned State]** for the open PRs, marked as such.
> Verification: **[Code Verified]** — tests and tsc on every PR. **[Runtime Verified]** where it says
> so: production queries, Railway deploy logs and the owner's phone, from the owner's screenshots.
> Same branch as sessions 57–62 (`claude/tec-knowledge-base-review-6wzngc`). Follows
> [session 62](session-62.md); the review itself is `audits/ENGINEERING_REVIEW_2026-11-11.md`.

## The review

The owner asked for a precise engineering review of the whole project, with real scores and the
strengths and weaknesses. Result: **6.8 / 10** — a strong base, one critical financial hole, and a
surface wider than its users. Scores, findings and strengths: the audit file above.

**The report was kept out of this repository until its financial hole was closed and deployed.**
This repository is public; a description of an open hole in it is an instruction manual.

## Fixed

| PR | What |
|---|---|
| tec-core-backend #503 | **An order is PAID only for a verified payment** — `createOrder` had accepted any `payment_id` (finding 1). The guard matches `/internal/` on the decoded path in all 16 copies (finding 3). backup-job can dump one schema of a database (`BACKUP_SCOPE_<SERVER>`) — for Supabase, which had no backup. A flaky test (two `new Date()` a millisecond apart on CI) froze its clock |
| tec-core-backend #504 | **Nest 11 / Fastify 5** in the 15 Fastify services and the template: 0 critical advisories (a critical `@fastify/middie` and 5–8 high in each before). storage dropped `fastify-multipart` (never imported). The guard file also accepts a bodiless request labelled JSON (below). 3,434 tests across the 16 suites |
| tec-app #324 | The Hub's CSP `connect-src` names its hosts (it allowed any host, under a comment saying it did not); Next 15.5.29 |
| Commerce #94 · Ecommerce #86 | Next 15.5.29; Ecommerce's root `middleware.ts`, which Next never ran, removed |
| 16 template apps · Assets #86 · Life #110 · Zone #72 · template #55 | Session 62's once-a-day Pi sign-in and the bottom-bar fix, plus Next 15.5.29 and two template fixes the apps never got (the Hub-URL guard; `product_id` on the Mode-1 redirect) |
| NBF #32 · Brookfield #28 *[Planned State — open]* | The same, for the two apps that were outside the session until 11 Nov and missed all of it |

All merged PRs were on `main` the same day; Vercel built the apps one at a time (production queue).

### Finding 1 — checked for abuse before the fix went out **[Runtime Verified]**

Read-only SQL in production: 71 orders carried a `payment_id`; each had a completed payment, and each
amount equalled its order total — no sign the hole was used. Payer and buyer ids differ on the
May–October orders (the services keyed users differently then); the November orders match, and both
services key on the JWT `sub` now — so the new "the payer is the buyer" rule does not refuse a real
purchase. A real 5π purchase after the deploy became `PAID`.

### What the Fastify 5 upgrade would have broken

Fastify 5 answers 400 to `Content-Type: application/json` with no body; Fastify 4 did not. Every app's
BFF helper sends that header on every call, DELETE included — Explorer's "remove review" would have
failed the moment #504 deployed. Found by running the search service's tests on the new version. The
fix sits in the shared guard file every service registers (`acceptEmptyJsonBody`), so no service can
miss it; a real body still goes through Fastify's parser.

## Money and accounts

- **GitHub Actions:** the free 2,000 minutes for the private backend were nearly spent (1,802 used,
  reset 1 Dec). Decision: **no backend push until 1 December**; public repos run CI free. A $0
  Actions budget recommended to the owner.
- **Railway's AI Agent** had spent $5.03 on its own; its hard limit and alert are now $0.
- **Vercel:** Elite's duplicate project deleted by the owner (`tec-elite-bvzb` is the live one).
  `nbf` and `tec-brookfield` are TEC's (repos Tec-Nbf · Tec-Brookfield); `atlas-research` is not TEC.

## Left open (in this order)

1. Merge NBF #32 and Brookfield #28; a phone check after Vercel deploys: three apps opened directly
   sign in with Pi once that day; the bottom bar clears Android's buttons; remove an Explorer review;
   one purchase. Then Round 3.
2. The owner: `BACKUP_DB_SUPABASE` (session pooler, port 5432) and `BACKUP_SCOPE_SUPABASE=postgres:public`
   in backup-job; a $0 GitHub Actions budget.
3. **After 1 Dec (backend):** the four Express services to Nest 11 / Express 5, as their own step;
   payment's `@stellar/stellar-sdk` major with money-flow tests; zod 4; Docker builds in CI only when a
   Dockerfile or `main` changes.
4. From the review: a way to carry template fixes to the apps automatically; the shared packages'
   versions aligned across apps; staging; a backup alert channel and uptime paging; `script-src`
   without `unsafe-inline`/`unsafe-eval`; input validation in seven services; coverage floors in
   notification and realtime; asymmetric JWT.
5. **The owner's decision:** freeze or merge the marginal apps.
