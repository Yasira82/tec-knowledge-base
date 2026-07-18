# Write Paths — Depth Modules Go Interactive (2026-07-18)

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Runtime Verified]`
> **Authority:** C-132 (Modules-First / ADR-011) applied · C-47 P6 (Fail Closed) enforced.
> **Precedes:** `audits/DEPTH_MODULES_2026-07-17.md` (the read-layer modules this builds on).

## What happened

The depth modules in `tec-identity-service` (Zone · Explorer · Legend · NBF — see the
2026-07-17 handoff) moved from **read-only** to **write-enabled**: six write paths
shipped end-to-end, each merged green. No new microservice was created — every write
lives in its existing module (Modules-First, C-132), still with namespaced tables and
zero cross-module joins so extraction stays mechanical.

The unifying rule: **every write derives the actor from the verified session, never
the request body (C-47 P6)**. Backend controllers verify the JWT (HS256) and read the
Pi username from the token; BFF routes forward the session `tec_access_token` as
`Authorization: Bearer` + `x-internal-key`. The gateway URL stays server-only (NEW-A).
CSRF stays in middleware only (C-12 §11) — never re-checked in a route handler.

## The six write paths

| # | Path | Layer | Constitutional guarantee | PR(s) |
|---|------|-------|--------------------------|-------|
| 1 | **Legend** event consumer (C-126) | backend | Records OUTCOMES from Redis Streams (`payment.completed.v1` etc.) — a user can never author an achievement; append-only; idempotent (P2002 = no-op) | #135 |
| 2 | **NBF** business create + publish (C-124) | backend + UI | Owner establishes (`DRAFT`) + launches (`→ ACTIVE`); one-per-owner; `VERIFIED` is Zone's, `GRADUATED` is the Titan trigger — neither user-reachable | #136 · nbf#4 |
| 3 | **Zone** verification workflow (C-120 §7) | backend + UI | Submit request (starts `PENDING` — **no self-verify**) → append-only evidence → **ADMIN** reviewer decision (`VERIFIED`/`REVOKED`) with **separation of duties** (a reviewer may not decide their own submission). "Zone Verified" is earned, never bought | #137 · zone#15 |
| 4 | **Explorer** business self-listing (C-108) | backend + UI | Owner self-lists + edits; always indexed **UNVERIFIED** (verification is KYC's to mint, never self-set); one-per-owner; ranking stays Analytics' | #138 · explorer#14 |

(#135 has no user UI — it is event-driven; the others are full backend + frontend.)

## Patterns established this session

- **Secure write auth (P6).** Backend: `resolveOwner(auth)` verifies the JWT and reads
  `pi_username`. Where a privileged decision is needed (Zone review), the controller
  loads the user's roles via `IdentityService` and requires the `ADMIN` role. Owner /
  reviewer identity is **always** the token, never a body field. A test in every
  module asserts the outgoing body carries no `owner`.
- **State machines + terminal finality.** NBF `DRAFT→ACTIVE`; Zone `PENDING→VERIFIED|REVOKED`.
  Terminal states are final; the constitutionally-reserved transitions (Zone/KYC
  verification, Titan graduation) are unreachable from the user path.
- **Append-only evidence.** Zone evidence + Legend achievements are create-only —
  never updated or deleted (C-120 §7 / C-126).
- **Frontend panels.** Each UI adds one signed-in-only panel to `/app` (NBF form,
  Zone `VerificationPanel`, Explorer `ListingPanel`) wired BFF → gateway, inline
  styles (Pi-Browser safe), CSRF from the double-submit cookie via `buildHeaders`.

## Explorer architecture note (agreed this session)

Explorer stays a **module inside identity-service** (Bucket B), not its own service —
consuming **Identity** for source-of-truth listing data and **Analytics** for ranking
/ intelligence (popularity · trend · recommendations), which it **never computes
itself**. It remains the platform's first designated extraction candidate → a future
`search-service`; the self-listing write path was built on the clean seam so that
extraction stays mechanical (C-132 §6).

## DB changes (expand-only)

Two nullable columns were added for owner-scoping (non-destructive; seeded/system
rows have no owner). Applied on deploy via `prisma db push`; the manual SQL is
idempotent-safe:

```sql
-- zone_entities (verification submissions)
ALTER TABLE "zone_entities" ADD COLUMN IF NOT EXISTS "owner" TEXT;
CREATE INDEX IF NOT EXISTS "zone_entities_owner_idx" ON "zone_entities"("owner");

-- explorer_businesses (self-listings)
ALTER TABLE "explorer_businesses" ADD COLUMN IF NOT EXISTS "owner" TEXT;
CREATE INDEX IF NOT EXISTS "explorer_businesses_owner_idx" ON "explorer_businesses"("owner");
```

`nbf_businesses` and the Legend tables needed no schema change. Full
`tec-identity-service` suite after this session: **96 passing**.

## Verification

- Every PR merged with all CI gates green (Policy Check / Lint & Test / Docker Build /
  Deploy / CodeQL on backend; Payment policy / Lint / Typecheck / Test / Build /
  Playwright E2E / CodeQL on each frontend).
- Production DB confirmed via Railway console: `zone_entities` + `zone_evidence`
  seeded; `explorer_businesses` seeded (8 rows); `owner` columns present.

## Follow-up — the three next steps, now DONE (later 2026-07-18)

All three "what's next" items shipped, same session, each merged green:

| Step | What shipped | Layer | PR(s) |
|------|--------------|-------|-------|
| **Zone review UI** | `GET /identity/zone/review/queue` (ADMIN-gated, FIFO, evidence included) + `ReviewPanel` in `/app` (admin-only; relies on the backend `403` to stay hidden — no client-side role signal) | backend + UI | #139 · zone#17 |
| **Explorer → Analytics ranking** | denormalized `popularity` column + `search()` orders trust-first then popularity + `ExplorerConsumer` on `analytics.business.popularity.v1` → `applyPopularity` | backend | #140 |
| **KYC → Explorer verification** | `applyVerification(owner, verified)` + the Explorer consumer made **multi-stream** — added `kyc.verified.v1` / `kyc.rejected.v1` → flips `verification` | backend | #141 |

Zone's verification loop is now complete end-to-end: **submit → append evidence →
human (ADMIN) review**. Explorer's two discovery signals are wired as **consume seams**
(the Legend-consumer pattern): Explorer ranks WITH popularity and PRESENTS the verified
badge — it computes/mints neither. `tec-identity-service` suite after this follow-up:
**104 passing**.

### Architecture held

- **Identity = source data · Analytics = ranking · KYC = verification.** Explorer only
  consumes. Both new seams are standalone (ioredis only, no cross-module dependency),
  so the module stays extraction-clean for the future `search-service` (C-132 §6).
- `explorer_businesses` gained a `popularity` column (expand-only, db push). KYC sync
  needed **no schema change** (reuses the existing `verification` column).

### Remaining — the PRODUCER halves (separate service builds)

These consume seams are live and idle until their producers exist. Both are defined
event contracts (like the Legend consumer's streams), not missing wiring:

- **Analytics** must compute per-business popularity and emit `analytics.business.popularity.v1`.
- **tec-kyc-service** must emit `kyc.verified.v1` / `kyc.rejected.v1` carrying the Pi username.

Until then, `popularity` stays `0` (ranking unchanged) and `verification` stays as the
self-listing set it — and the moment a producer emits, Explorer reflects it with no
further change.
