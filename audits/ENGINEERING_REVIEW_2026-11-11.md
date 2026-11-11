# Engineering review of the whole platform — 11 November 2026

> Truth State: **[Current State]** — written the same day the findings were fixed.
> Verification: **[Code Verified]** for every finding (read in the code, several reproduced);
> **[Runtime Verified]** where it says so. Session record: `memory/sessions/session-63.md`.
>
> The review was given to the owner in the chat first and **kept out of this public repository
> until its one open financial hole was closed and deployed** (finding 1). This file was written
> after that.

## Scope

All 28 repositories in the session: tec-core-backend (20 services, ~64k lines), the Hub (~47k
lines), the five Round 3 apps, tec-template-base and the 18 apps cloned from it, the three
shared packages (tec-sdk · tec-auth · tec-ui), CI, operations, and this knowledge base.

## Scores

**Overall: 6.8 / 10.** The engineering base is strong, well above what one person usually
keeps; the weak points were one financial hole and a surface far wider than its users.

| Area | Score | In one line |
|---|---|---|
| Backend | 7 | Sound design, ~2,900 tests; the order hole, uneven input validation, Nest 10 / Fastify 4 |
| Security | 6.5 | The basics are excellent; one financial hole, a critical Next advisory, a wide CSP |
| Hub | 7.5 | Clean and tested, every route guarded; 18 files over 600 lines |
| Round 3 apps (5) | 7 | The most mature after the Hub |
| Template + its 18 apps | 6 | Working, mostly previews; template fixes had not reached them |
| Shared packages | 6 | Untouched since September; apps on different versions |
| Tests + CI | 7.5 | Wide coverage and real gates; low coverage floors in a few services |
| Operations | 6 | A backup with a real restore check; no staging, no alerts, Supabase not backed up |
| Documentation (this KB) | 8.5 | The strongest part of the project |
| Product breadth vs. resources | 5 | 24 apps for few users; maintenance has become the work |

## Findings and where they stand

| # | Severity | Finding | Status |
|---|---|---|---|
| 1 | **Critical (financial)** | `tec-commerce-service` `createOrder` marked an order **PAID** for **any** `payment_id` in the body, with no check that the payment existed, had completed or covered the total — and recorded what each seller was owed in the payout desk. The gateway forwards the route to any signed-in user (C-47 Invariant #2, Forbidden #2) | **Closed** — tec-core-backend #503. An order is PAID only when payment-service confirms the payment: completed, made by this buyer, covering the total to the last 1e-8, and not made for another order; Pi's id comes from payment-service, not from the body. 10 new tests |
| 2 | High | Next.js 15.5.12 / 15.5.19 had critical advisories (request smuggling in rewrites, a Server Actions DoS); Fastify 4 (end of life) and Nest 10 carried a critical `@fastify/middie` advisory and 5–8 high in every Fastify service | **Closed for the apps** — Next 15.5.29 pinned in the 24 apps and the template (NBF #32 and Brookfield #28 still open). **Closed for 15 services** — Nest 11 / Fastify 5 (#504), 0 critical. **Open:** the four Express services (gateway · auth · wallet · realtime), payment's `@stellar/stellar-sdk` major, zod 4 |
| 3 | Medium | Every Fastify service's internal-key guard tested the **raw** URL for `/internal/`; Fastify decodes before routing, so `/%69nternal/…` reached an internal route as a user call (reproduced: 200 from the internal handler). Not reachable from outside — the gateway decodes and refuses | **Closed** — #503: decoded, any case, undecodable counts as internal; all 16 copies; CI checks the copies |
| 4 | Medium | The Hub's CSP `connect-src` was `'self' https: wss:` — any host — under a comment saying the wildcard was gone | **Closed** — tec-app #324: named hosts only, pinned by `csp-connect-src.test.ts`. **Open:** `script-src` still has `'unsafe-inline' 'unsafe-eval'` (the Pi SDK path needs work first) |
| 5 | Medium | Template fixes never reached the apps cloned from it (the Hub-URL guard, `product_id` for Mode 1) | **Closed for now** — copied into 18 apps; NBF and Brookfield, outside the session until 11 Nov, missed the day's changes and got them in their own PRs. **Mechanism built** — tec-template-base #56 (`template-sync`): one list of what every app must carry, checked on every fleet app after each template merge and every Monday, one issue listing what has not arrived. Its first run found NBF and Brookfield weeks behind (the sign-in door) — fixed in #32 · #28 |
| 6 | Medium | Operations: no staging; no alert when a backup fails; **Supabase (analytics) had no backup at all**; nothing pages anyone when a service is down | **Supabase:** backup-job can dump it (`BACKUP_SCOPE_<SERVER>=db:schema`, #503) — waits on two variables in backup-job. **Open:** staging, a backup alert channel, uptime paging |
| 7 | Low | Seven services validate input by hand (no zod / class-validator); coverage floors near 35 % in notification and realtime; a dead root `middleware.ts` in Ecommerce; 18 Hub files over 600 lines | **Ecommerce closed** (#86 — Next runs `src/middleware.ts`). The rest open |
| 8 | Architectural | One HS256 `JWT_SECRET` shared by 20 services and 24 apps — a leak anywhere forges anyone; one Redis is the whole event bus | Open — asymmetric signing is the last step of the rotation plan |

### Was finding 1 exploited? — no sign of it **[Runtime Verified, 11 Nov]**

Read-only queries in production, before the fix deployed: **71 orders carried a `payment_id`;
every one had a completed payment in payment-service, and every amount equalled the order
total.** Payer and buyer ids differ on the May–October orders because the two services keyed
users differently then (Pi username vs. account id); the three November orders match, and both
services key on the JWT `sub` today. After the deploy a real 5π purchase became `PAID`.

### A regression the upgrade would have caused, and did not

Fastify 5 answers **400** to a request that says `Content-Type: application/json` with no body
(`FST_ERR_CTP_EMPTY_JSON_BODY`). Every app's BFF helper sends that header on every call,
DELETE included — removing an Explorer review would have broken the day #504 deployed. The
shared guard file now drops the header from a bodiless request before parsing, as Fastify 4
did; a real body still goes through Fastify's parser (`empty-json-body.spec.ts`).

## Strengths (as found)

- **Code hygiene:** TypeScript strict everywhere; `any` almost absent; no `@ts-ignore`; no token in localStorage.
- **Fail closed (P6) is real:** identity always from the session, never the body, and CI blocks the other way; `timingSafeEqual` comparisons; every container runs as a non-root user.
- **Payments are built right:** outbox, a state machine, idempotency, a circuit breaker, DECIMAL(20,8). Subscriptions and Assets already verified their payment — which is why finding 1 sat in one place only.
- **Databases:** migrations that refuse a destructive change without explicit consent; every production database compared with its schema before it changed.
- **Backups:** nightly, encrypted, and **the restore is actually tested**, row counts compared.
- **Tests:** ~2,900 in the backend before #504 (3,434 across the 16 Fastify suites after it); 1,000+ test files in the apps.
- **Secrets:** rotated after the breach; Railway's three platform secrets now live in one place (Shared Variables).
- **This KB:** every decision with its reason, and gates that stop it from contradicting the code.

## The strategic weakness

The project is **wider than one person can keep**: 28 repositories, 24 apps, 20 services. Most
of the 18 template apps are previews with sample data, but each needs every security update,
template fix, secret change and review — on 11 Nov alone, 24 Vercel projects were changed by
hand. Every maintenance hour spent on a marginal app is an hour not spent on the apps people use.
**Freezing or merging the marginal apps is the owner's decision**, and the largest one this
review leaves open.
