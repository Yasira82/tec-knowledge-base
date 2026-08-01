# Event-Consumer Idempotency Audit — 2026-08-01

**Scope:** every Redis-Streams consumer across the 12 `tec-core-backend` services.
**Question:** at-least-once delivery (C-70) means *consumers MUST be idempotent* — which
handlers are, which aren't, and where is the real risk?
**Verification:** `[Code Verified]` — read from `*.consumer.ts` + the handler services in
`tec-core-backend` `main`. Prompted by the `user.created` C-70 migration (#162), which
surfaced that some observability consumers weren't idempotent.

---

## Headline

**No double-processing risk exists on any financial or value-chain path.** Every consumer
that moves money, transitions order/payment state, or writes reputation is idempotent by an
explicit mechanism (processed-event table, state guard, `eventId`/slug dedupe, or upsert).
The only gaps are LOW-severity and non-financial (observability/notification), and the
platform's real exposure there is *at-most-once loss on crash*, **not** duplication.

---

## Consumer map (code-verified)

| Consumer (service / module) | Event(s) | Idempotency mechanism | Reprocesses pending? | Verdict |
|---|---|---|---|---|
| wallet `wallet.service` | `payment.completed` | **`ProcessedEvent` table** (`event_key = payment:${paymentId}`, in-tx) | — | ✅ money-safe |
| commerce `order.consumer` | `payment.completed` | **state guard** — `findFirst({status:PENDING})`; a redelivery finds the order already PAID → no-op | yes (`processPending`) | ✅ money-safe |
| identity `user-created` | `user.created(.v1)` | `findOrCreateUser` (idempotent by username) + dual-read | no | ✅ |
| identity `connection/order-paid` | `order.paid.v1` | `recordOrderPaid` **dedupes by `eventId`** | no | ✅ |
| identity `explorer` | `kyc.*`, `analytics.business.popularity.v1` | **upsert / update** (last-write-wins) | no | ✅ |
| identity `legend` | `zone.badge.issued.v1`, `epic.project.completed.v1`, … | **dedupe by slug derived from `eventId`** (falls back to `messageId`) | no | ✅ |
| identity `legend/scores-updated` | `legend.scores.updated.v1` | **`legendProfile.upsert`** (overwrite) | no | ✅ |
| analytics `analytics.consumer` | `user.created(.v1)` | **`eventId` dedupe** (Phase 2, #162) | no | ✅ |
| analytics `analytics.consumer` | `payment.completed`, `kyc.verified`, dimension events | **none** — `trackEvent` appends + `updateDailyMetric` increments | no | ⚠️ see §Findings |
| notification `notification.consumer` | `payment.completed`, `kyc.*` | **none** — `create()` a notification | no | ⚠️ see §Findings |
| notification `notification.consumer` | `user.created(.v1)` | **`eventId` dedupe** (Phase 2, #162) | no | ✅ |
| realtime `redis.consumer` | `payment.completed`, `user.created(.v1)` | user.created deduped; payment.completed = socket emit (transient) | no | ⚠️ low |

---

## Findings

### F-1 — Observability/notification consumers are not idempotent for `payment.completed` / `kyc.*` (LOW)
`analytics`, `notification`, and `realtime` handle these with non-idempotent side-effects
(append a metric row / `++` a counter / create a notification / emit a socket event) and do
**not** dedupe. **However**, none of them reprocess their pending list — they read `'>'`
(new only), never `'0'` / `XAUTOCLAIM` — so on redelivery they don't fire twice. In practice
there is **no duplication**; the actual (mild) exposure is the opposite: **at-most-once loss**
— a message read but not `XACK`-ed before a crash stays PENDING and is never retried.
- **Severity: LOW.** These domains are eventual-consistency by constitution (C-47 §6:
  Analytics/Notifications tolerate lag); a lost welcome-notification or a slightly-off metric
  on a rare crash is acceptable. No money, no reputation.
- **Recommendation (not urgent):** if these are ever made to reclaim pending (`XAUTOCLAIM`)
  for at-least-once, pair it with `eventId` dedupe (the `claimEvent` helper already added in
  #162) to stay exactly-once.

### F-2 — Several events lack a C-70 `eventId` (GOVERNANCE)
`payment.completed`, `kyc.verified`, `kyc.rejected`, and some value-chain events (`order.paid.v1`,
`zone.badge.issued.v1`, `epic.project.completed.v1`, `connection.milestone.v1`) ship **without**
an `eventId`, though C-70 (and CLAUDE.md's Event model) list it as REQUIRED. The financial
consumers work around this with natural keys (`paymentId`, order state), and legend falls back
to `messageId` — so nothing is broken, but it's an inconsistency and it blocks `eventId`-based
dedupe for F-1.
- **Staged fix (source-ready, needs a coordinated release):** `@yasser172/tec-shared`
  `publishEvent()` now **auto-injects an `eventId`** when the caller omits one (never overwrites
  a caller-set id — preserves the dual-emit shared-id contract). This is a **published npm
  package** (`^1.1.0`), so it takes effect only after tec-shared is rebuilt/republished and the
  consuming services bump the dependency (release chain: shared → services). Additive +
  backward-compatible. Raw-`xadd` emitters that bypass the shared helper (e.g. kyc.service) need
  the field added at the call site in the same release.

---

## What was NOT changed (and why)
No live financial service was modified. The money paths are already idempotent; changing
`tec-payment-service` or force-publishing `@yasser172/tec-shared` for a governance nicety
on a live Mainnet platform is unwarranted risk (production-mindset). F-2's fix is staged in
source for the next coordinated tec-shared release; F-1 is recorded as a low-severity
reliability follow-up.

---

## Related
- **C-70** Event Governance Spec (`domain.action.version`, at-least-once → idempotent, `eventId` required)
- **C-71** Financial Integrity Spec · **C-47** Kernel Spec (§6 consistency model; Invariant #8)
- `manifests/events-catalog.yaml` — the code-sourced event registry
- tec-core-backend **#162 / #163** — the `user.created` C-70 rename that prompted this audit
