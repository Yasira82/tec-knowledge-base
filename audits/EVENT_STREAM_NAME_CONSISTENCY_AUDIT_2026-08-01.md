# Event Stream-Name Consistency Audit — 2026-08-01

**Scope:** every Redis-Streams **producer** vs **consumer** stream name across the 12
`tec-core-backend` services. **Question:** does every consumer listen on a stream that a
producer actually emits (and vice-versa)?
**Verification:** `[Code Verified]` — read from `xadd` / `publishEvent` / outbox writers +
`xreadgroup` / consumer `STREAM(S)` constants in `main`, cross-checked against production
Railway deploy logs (2026-08-01). Prompted by a version mismatch spotted in those logs.

---

## Producer ⟷ Consumer map

| Event stream | Producer (code) | Consumers | Status |
|---|---|---|---|
| `user.created.v1` | auth `xadd` | identity · analytics · realtime · notification | ✅ (Phase 3 — legacy `user.created` retired) |
| `payment.completed` | payment **direct** emit (`EVENTS.PAYMENT_COMPLETED`) | wallet · commerce · analytics · notification · realtime | ✅ |
| `payment.completed.v1` | payment **outbox** (`payment.controller` → outbox row) | legend | ✅ — but **dual-stream**, see F-2 |
| `payment.approved.v1` | payment outbox | — (no consumer) | ℹ️ producer-only (harmless) |
| `order.paid.v1` | commerce `order-events` | connection · analytics | ✅ |
| `kyc.verified` | kyc `emitEvent` | analytics · notification · **explorer** | 🔴→✅ **F-1 fixed** (Explorer was on `.v1`) |
| `kyc.rejected` | kyc `emitEvent` | notification · **explorer** | 🔴→✅ **F-1 fixed** |
| `zone.badge.issued.v1` | identity/zone emitter | legend · analytics | ✅ |
| `epic.project.completed.v1` | identity/epic emitter | legend · analytics | ✅ |
| `connection.milestone.v1` | identity/connection emitter | legend · analytics | ✅ |
| `legend.scores.updated.v1` | analytics scoring batch | legend-scores | ✅ |
| `analytics.business.popularity.v1` | analytics scoring batch | explorer | ✅ |
| `fundx.investment.closed.v1` | — (gated, not built) | legend | ℹ️ consumer-only (planned; FundX pools hard-gated) |

---

## Findings

### F-1 — 🔴 Explorer listened on `kyc.verified.v1` / `kyc.rejected.v1` — streams with NO producer  (**FIXED**)
`tec-kyc-service` emits the **unversioned** `kyc.verified` / `kyc.rejected`
(`kyc.service.emitEvent('kyc.verified', …)`), and analytics + notification correctly
consume those. But `explorer.consumer` declared `KYC_VERIFIED = 'kyc.verified.v1'` /
`'kyc.rejected.v1'` — versioned names **nothing produces**. Effect: Explorer's KYC →
"Verified Business" badge sync **never fired in production** (silent — the consumer group
just sat idle on an empty stream). Surfaced by the Railway log line
`[ExplorerConsumer] Started … streams[1]: kyc.verified.v1 streams[2]: kyc.rejected.v1`.
- **Fix (this audit):** Explorer now consumes `kyc.verified` / `kyc.rejected` — matches the
  producer and the two working consumers. tsc clean; 193 identity tests pass.

### F-2 — ⚠️ `payment.completed` is emitted under TWO stream names (dual-emission)
Every payment emits **both** `payment.completed` (the direct `EVENTS.PAYMENT_COMPLETED`
XADD) **and** `payment.completed.v1` (an outbox row, ADR-004). Most consumers read the
unversioned stream; **Legend** reads `payment.completed.v1`. It works today (both fire —
confirmed in logs), and there is no double-processing (each consumer reads exactly one of
the two). **Risk:** it's fragile — deleting either emit silently breaks a whole set of
consumers.
- **Recommendation (not now):** converge on `payment.completed.v1` as canonical and migrate
  the unversioned readers (wallet/commerce/analytics/notification/realtime) via the same
  expand→migrate→contract pattern used for `user.created`. High blast radius (touches the
  money path) → a deliberate coordinated change, **not** a drive-by. Documented, deferred.

### F-3 — ℹ️ one-sided streams (expected, not bugs)
- `payment.approved.v1` — producer only (outbox), no consumer yet. Fine.
- `fundx.investment.closed.v1` — consumer only (Legend), no producer (FundX pools are
  hard-gated, C-113). Fine — Legend simply never receives it yet.

---

## Result
Every other producer↔consumer pair **matches**. The one live breakage (F-1, Explorer KYC)
is fixed; F-2 is a documented consistency risk on the (working) payment path; F-3 is
expected. Companion to the event-consumer idempotency audit (2026-08-01).

## Related
- **C-70** Event Governance Spec · **C-108** Explorer (KYC "Verified Business" sync) · **C-126** Legend
- `manifests/events-catalog.yaml` · tec-core-backend (Explorer KYC fix PR)
