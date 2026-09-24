# SESSION 37 — NX: OPPORTUNITY POSTING + NX PRO = FEATURED (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Seventh app deepened — the "make Pro real + serve the Pi community" campaign continues (Epic → NX).

### What it is
NX (the Pi Opportunity Exchange, ADR-010) already had a **public** searchable board — but
seed-only (read-only). The two gaps closed:
- **Community value → real two-sided service:** **posting**. Any signed-in Pi user posts a
  job / grant / gig / partnership; the whole community discovers it on the public board.
  Posts start **unverified** (Zone/kyc verifies later — NX presents, never mints, ADR-010).
- **Real Pro → NX Pro = ⭐ Featured:** a Pro poster's opportunities get featured placement.
  Search ranks `verified → featured → title` — featured lifts **within** the verified tier
  (pay for reach, never verification). Synced from the live subscription by the BFF (P5).

### Backend / frontend (needs db push)
- `NxOpportunity.owner` (nullable, P6) + `featured` (+ `featured_until`, `@@index`);
  `createOpportunity` + `listOwn` + `setFeaturedForOwner`; `POST /identity/nx/opportunity`,
  `GET /identity/nx/mine/:owner`, `PATCH /identity/nx/featured`. 12/12 nx tests.
- Post form + "your posts" + ⭐ badges; `/api/bff/nx/opportunities` (POST) + `/api/bff/nx/mine`
  (own + featured reconcile). 31/31 frontend tests.

### The scorecard (7 apps: real Pro + a Pi-community surface)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| Epic | ⭐ Featured project | public `/discover` project directory |
| **NX** | **⭐ Featured opportunity** | **public opportunity board + community posting** |

### Process note (recorded)
`tec-core-backend` uses ONE session branch, so the Epic (#201) and NX backend changes are
**both on that branch** (independent modules — Epic + NX). PR #201 covers both. Frontends are
separate repos/PRs (tec-epic #20 · tec-nx #17). Next candidates: **Connection · Alert · DX**.

### PR ledger
tec-core-backend **#201** (Epic + NX backend, 36/36) · tec-epic **#20** (27/27) · tec-nx
**#17** (31/31). Ops: `db push` on `tec-identity-service`. All local gates green.
