# Depth Modules — Read-Layer Expansion to 9 Apps (2026-07-18)

> **Truth State:** `[Current State]` (merged to `main`) — the *live* data path is `[Planned State]` until deploy.
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]` — build + lint + unit tests + CI green on every PR.
> **NOT yet `[Runtime Verified]`** — no module has been exercised live through the gateway; see "What is NOT done".
> **Authority:** C-132 (Modules-First / ADR-011) · C-47 P6 (Fail Closed) · NEW-A (server-only gateway URL).
> **Follows:** `audits/WRITE_PATHS_2026-07-18.md` (the write paths) + `audits/DEPTH_MODULES_2026-07-17.md` (the first read modules).

## What happened

Nine more frontend apps got **real DB-backed read layers** in place of their static
front-end samples. Each is a **module inside `tec-identity-service`** (Modules-First,
C-132 — **no new microservice**), with namespaced `<app>_*` tables and **zero
cross-module joins**, so a future extraction stays mechanical. Every app's `/app` +
detail page + BFF now resolves **live-first with a curated sample fallback**, so the
page is never blank whether or not the backend is reachable.

The unifying rules held on all nine:
- **P6 own-scope** — owner is derived from the `tec_user` session by the BFF, **never**
  a client param/body. A no-session caller fails closed (community/catalog only).
- **NEW-A** — the gateway URL is server-only (`API_GATEWAY_URL`); never shipped to the client.
- **Read-only by charter** — System, DX, Insure, Alert expose **no write/custody/certify**
  surface; their service specs assert those methods do **not exist**.
- **Presented, never minted** — verification (Zone/kyc), funding (FundX), scores
  (Analytics), recognition are shown as read-only flags, never derived in these modules.

## The nine read modules

| App | Module (`@Controller`) | Owns (reads) | Charter |
|-----|------------------------|--------------|---------|
| **NX** | `identity/nx` | opportunity board — `search` (kind + verified-first) · `opportunity/:handle` | C-112 / ADR-010 |
| **Elite** | `identity/elite` | recognition read-layer — `recognitions/:owner` (P6) · `recognition/:slug` | C-127 |
| **VIP** | `identity/vip` | tier catalog + `membership/:owner` (current tier, P6) | C-128 |
| **Insure** | `identity/insure` | protection catalog + `risk/:owner` snapshot — **custody hard-gate: no escrow surface** | C-129 |
| **System** | `identity/system` | governance projection — `policies` · `tiers` · `capabilities` · `constitution` (read-only) | C-110 |
| **DX** | `identity/dx` | developer catalog — `catalog` (SDKs+templates+caps+guides) · `guide/:id` | C-115 |
| **Epic** | `identity/epic` | project board — `projects/:owner` (P6) · `project/:slug` | C-125 |
| **Alert** | `identity/alert` | inbox — `feed/:owner?source=` (own TEC ∪ **global** Pi) · `alert/:slug` | C-111 |
| **Titan** | `identity/titan` | enterprise console — `console/:owner` (org+team+modules) · `module/:id` | Titan (draft) |

All mounted under `/identity/*` → covered by the existing gateway route (`/api/identity/*`)
with **no gateway change**. Each seeds a demo dataset on bootstrap (idempotent — only if
empty). `tec-identity-service` unit suite: **104 → 164 passing**.

### identity-service module inventory (post-merge)
`connection · life · zone · explorer · legend · nbf · nx · elite · vip · insure ·
system · dx · epic · alert · titan · identity · health`

## PRs (all merged to `main`, CI green)

| Backend (`tec-core-backend`) | Frontends |
|------------------------------|-----------|
| #142 — NX + Elite + VIP + Insure | tec-nx#12 · tec-elite#12 · tec-vip#12 · tec-insure#12 |
| #143 — System + DX | tec-system#15 · tec-dx#12 |
| #144 — Epic + Alert + Titan | tec-epic#12 · tec-alert#12 · tec-titan#12 |

(An Actions runner-infra outage mid-day failed every job in 1–3 s across all repos —
diagnosed as account-level Actions capacity, not code; it recovered and every PR then
ran green and merged.)

## What is NOT done (the honest gaps)

1. **Runtime unverified — the blocker.** No module has been exercised **live** through
   the gateway. `tec-identity-service` must be **deployed** (Railway `prisma db push`
   creates the ~13 new tables + runs the seeds) before any BFF returns `source:'live'`.
   Until then **every one of the nine frontends serves `source:'sample'`** (the fallback).
   *Next: deploy identity-service → verify one module live (e.g. `GET /api/identity/nx/search`)
   → the rest follow the same proven shape.*
2. **Data is seeded/demo.** These modules replace "static sample in the front-end" with
   "seeded sample in the DB, served live". Real depth next = **write paths / event
   ingestion** for these nine (as already done for NBF create, Zone verification, Legend
   consumer) — none of the nine ingest real data yet.
3. **Producer halves still idle** — Analytics `analytics.business.popularity.v1` and
   KYC `kyc.verified.v1` (Explorer seams) are defined contracts, not yet emitted.

## Why this is still a real step

Before: each app's data lived only as a TypeScript constant in the front-end bundle.
After: each app has a **real service boundary** — a namespaced schema, a seeded store,
public/own-scoped endpoints behind the gateway, and unit tests locking the contract —
that is **extraction-clean** (C-132) and enforces **P6** the moment it is deployed. The
front-end sample is now a *fallback*, not the *source*.
