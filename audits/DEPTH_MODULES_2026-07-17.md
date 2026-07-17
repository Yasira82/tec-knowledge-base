# Depth Modules — Backend Runtime Layer (2026-07-17)

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Runtime Verified]`
> **Authority:** C-132 (Modules-First / ADR-011) — this is the record of it applied.

## What happened

Four app charters moved from **doc/frontend-only** to **live DB-backed modules**
inside `tec-identity-service` — the first sustained application of C-132
(Modules-First + Design-for-Extraction). No new microservice was created; each is a
module with namespaced `<domain>_*` tables and **zero cross-module joins** (R-2), so
extraction stays mechanical.

| Module | Gateway route | Tables | Seed | Constitutional note |
|--------|---------------|--------|------|---------------------|
| **Zone** (C-120) | `identity/zone/*` | `zone_entities` · `zone_evidence` | 8 verified apps + council | evidence append-only (§7); "Verified" ≠ "Trusted" |
| **Explorer** (C-108) | `identity/explorer/*` | `explorer_businesses` | 8 businesses | **first extraction candidate → `search-service`**; built with the clean seam |
| **Legend** (C-126) | `identity/legend/*` | `legend_profiles` · `legend_achievements` · `legend_badges` | 1 PUBLIC demo (`pioneer`) | records OUTCOMES not claims — **no create endpoint**; achievements append-only; scores served from Analytics |
| **NBF** (C-124) | `identity/nbf/*` | `nbf_businesses` | 1 demo (`pistore`) | presents Zone verification (never mints); graduation-to-Titan trigger |

All four: NestJS module + service (seed-on-init, idempotent) + `@Controller('identity/<m>')`
public reads + spec tests. Full identity-service suite: **69 passing**. Frontends
wired BFF → gateway with **live-with-sample-fallback** (identity from the session
cookie, never a param — P6). Every PR merged green; DB tables created via
`prisma db push` (or equivalent SQL) and seeds verified in production.

## identity-service module map (7 domain modules)

```
tec-identity-service
├── identity   (profiles · kyc · users · roles · sessions)
├── life        → life_goals · life_preferences            (live + real user data)
├── connection  → connection_follows · _collections + order-paid consumer (live + real user data)
├── zone        → zone_entities · zone_evidence            (live + seeded)
├── explorer    → explorer_businesses                       (live + seeded)
├── legend      → legend_profiles/achievements/badges       (live + seeded)
└── nbf         → nbf_businesses                             (live + seeded)
```

7 domain modules in one service — the Modules-First target (C-132 §7.1: service
count stays **11**, not 24). Life + Connection are the most mature (real production
data; Connection consumes `order.paid` into trust signals).

## Ops record (done)

- `prisma db push` (or the equivalent `CREATE TABLE`/`CREATE TYPE` SQL via the
  Railway Data console) run on `db-identity` for zone/explorer/legend/nbf tables.
- `tec-identity-service` redeployed → `onModuleInit` seeded zone, explorer, legend,
  nbf. Verified in the Railway Data tab.

## Next candidates (same pattern, when asked)

- **Connection trust-signals slice** — extend the existing `order-paid` consumer.
- **Elite** (C-127) — recognition over Legend evidence (read layer).
- **Epic** (C-125) — a projects table (the next likely Bucket-C → Bucket-B promotion).

Financial modules (FundX / Insure / Brookfield) stay **state-only** — custody is
payment-service (R-4 / Invariant #8), gated on legal + SYSTEM.

## Related

- C-132 — Service Extraction & Modular Architecture Policy (ADR-011) · §7 mapping updated to match this.
- C-108 Explorer · C-120 Zone · C-124 NBF · C-126 Legend · C-106 Life · C-107 Connection.
