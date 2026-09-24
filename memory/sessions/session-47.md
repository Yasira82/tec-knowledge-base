# SESSION 47 — WHAT SUCCEEDS SILENTLY (28 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for every number
> below — they come from queries run against the production `payment-db`, not from reading
> code. The fixes are **[Code Verified]**: tec-core-backend **#232** and **#233** merged;
> **#234** open (diagnostic + audible fallback + recovery audit trail).

Four separate defects were found this session. They are not related by subsystem — one is a
missing event, one is an identity fallback, one is a test, one is an audit gap. They are
related by **shape**:

```
Every one of them was a system reporting success while doing nothing.
```

That is the finding worth keeping. It is the same shape as Session 46's deploy job, which
exited 0 for months without ever deploying a service.

### 1. A payment could complete and no one would be told

`resolveIncompletePayment` — the handler every app calls at
`/api/bff/payment/resolve-incomplete` when a Pi Browser payment gets stuck — marked payments
`completed` with a bare `prisma.payment.update()` and emitted **nothing**.

`piCompletePayment` *can* emit, but only `if (eventData)`, and the recovery call site passed
three arguments. The condition failed silently. The second branch never called it at all.

`payment.completed.v1` has three live consumers, and one of them is
**`commerce-subscription` — the thing that actually grants PRO/ENTERPRISE**. So a payment
recovered this way left the row saying `completed`, the Pi genuinely moved, and the buyer
got nothing. Session 26's "paid and got nothing", alive on the one path that only ever runs
**after** a payment has already gone wrong.

> **Why 100% payment success could not surface it.** The normal path is covered twice —
> outbox row *and* a post-commit publish. The broken path only executes when a payment
> failed first. A fleet reporting every payment successful is exactly the condition under
> which this stays invisible. **Success everywhere was the reason it was hidden, not
> evidence it was harmless.**

Fixed in **#233**: both branches go through one helper that writes the status change and the
outbox row in the *same transaction* (ADR-004). Chosen deliberately over a direct publish —
the outbox insert is a write to the same database, not an external call, so it adds no new
way for a completion to fail.

### 2. The test was green with the bug in place

A `resolveIncompletePayment` CASE B test already existed. It asserted that `res.json` had
been called. It passed before the fix and after it.

**Every new test in #233 was run against the pre-fix controller first** — 3 failed, then
passed on the fix. That step is now the standard for this repo:

```
A test that passes on the broken code is not a test. It is a comment that runs.
```

### 3. 31% of completed payments belong to a principal that does not exist

Reading the affected rows showed `user_id = 'gateway'` — not a UUID. One line:

```typescript
const userId = (req.headers['x-user-id'] as string) || 'gateway';
```

Fail-OPEN. When the payer's identity is unknown it **invents one** rather than refusing, and
it had never said so. **248 of 798 completed payments** carry it. A subscription paid that
way activates PRO for "gateway" — the human gets nothing — and the audit trail names an
actor that is not a person (Invariant **#3** identity resolves to ONE principal, Invariant
**#4** audit trail).

Gateway **#210** (15 Aug) had already fixed the source, and production confirms it:

| window | `gateway` payments |
|--------|--------------------|
| before 15 Aug | **240** |
| on 15 Aug (deploy day, last at 17:11:47) | **8** |
| the 13 days since | **0** |

**#234** does not remove the fallback — genuine cron/webhook/reconciliation calls have no
user by design, and deleting it would 401 legitimate traffic. It makes it **audible**: every
occurrence now names the route that produced it, and whether an `Authorization` header was
present (which separates "token forwarded but failed verification" from "no token sent").

### 4. The recovery path kept no audit trail at all — which is why (1) was hard to diagnose

`resolveIncompletePayment` wrote **no audit log on any branch**. Forbidden Behavior **#10**
is *"ad-hoc system recovery without audit trail"* — a description of this handler.

The cost was immediate and concrete: the one affected payment had two audit rows
(`PAYMENT_INITIATED`, `PAYMENT_APPROVED`) and none for its completion, so the diagnosis had
to lean on the outbox table instead, and **the payer could not be identified from our own
records**. The second defect erased the evidence for the first.

Fixed in **#234**: all four outcomes audit, using the *same* event types as the normal paths
(`PAYMENT_CONFIRMED` / `PAYMENT_CANCELLED`, not `PAYMENT_RECONCILED`) so "was this payment
ever confirmed?" has one answer whichever path got it there. Route goes in metadata.

### What production actually said — and why the first number was wrong

```
month     completed   missing payment.completed.v1
2026-03      47              47   100%  ─┐
2026-04     119             119   100%   │  before the outbox was wired AT ALL
2026-05     209             209   100%   │  (saveOutboxEvent was dead code — issue #72)
2026-06     191             150          ─┘
2026-07     156               3   ← the only real suspects
2026-08      76               1   ←
```

529 rows lacked an event. **They were not 529 victims.** Before the outbox existed the normal
path emitted straight to Redis, so a missing outbox row proves nothing about delivery. Only
the date split separates the two eras.

> This is why the diagnostic script leads with **date ranges and signal overlap**, not a
> headline count. A single number here would have been alarming and wrong. Of the 4 genuine
> suspects, three are ordinary purchases and **one** was a real subscription
> (`merchant_pro_monthly`, 10π, 6 Aug).

**Blast radius: zero real users.** All 798 payments across only 8 distinct principals — the
platform has no external paying customers yet. Every affected payment is team testing. Both
bugs were real, both are fixed, and both were caught before a stranger's money was involved.
That is the best available outcome, not a reason the work was unnecessary — it is the
cheapest these guards will ever be.

### Also this session — the audit issues, verified rather than repeated

Six open audit issues were checked **against current code** instead of trusted from their
text. Four were already fixed and are closed with evidence (**#71** terminal-state guard,
**#73** all four Dockerfiles on `migrate deploy`, **#81** realtime-service 14/14 green,
plus its `.dockerignore`/`package-lock` companions). Two were real and are fixed in **#232**:

- **#78** — `config/env.ts` validated `ALLOWED_ORIGINS` while `main.ts` read `CORS_ORIGIN`.
  The larger finding: **the module was imported by nothing**, so its Zod `parse` had never
  once executed — the gateway ran with no env validation at all. Wired up with `safeParse`,
  not `parse`: making it throw would turn a dormant check into an outage on the platform's
  single entry point the first time a var is missing on Railway. Fatal should be a decision,
  not a side effect of adding an import.
- **#79** — Swagger declared `userId` **required** in `CreatePaymentRequest`, publishing the
  exact field C-47-B exists to reject as the documented contract (Forbidden Behavior #5).
  The Wallet block was worse: it documented routes that do not exist.

**#72 stays open, correctly.** An earlier pass in this session called it fixed by counting
`saveOutboxEvent` call sites; that was wrong — coverage of the six transitions is the
question, and the four that matter most were missing. `cancelPayment` / `failPayment` remain,
and **no service consumes payment failure events**, so that half is an audit-trail gap rather
than a revenue one. Recorded on the issue with a per-handler table.

### Rules adopted

1. **Run every new test against the broken code first.** If it does not fail, it does not test.
2. **A diagnostic reports its signals separately.** Collapsing them into one verdict is how a
   pre-outbox artifact becomes "529 victims".
3. **Never remove a fail-open fallback blind — make it audible first.** Then remove it once
   the logs say who depends on it.
4. **A test is only as good as the seam it watches.** The first version of the audit tests
   asserted on `prisma.paymentAuditLog.create` while the suite mocks `../utils/audit`; they
   failed for a reason unrelated to the code.
