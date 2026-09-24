# SESSION 36 — EPIC: PUBLIC DISCOVERY + EPIC PRO = FEATURED (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Resumes the "deepen the rest" campaign — apply the proven pattern (real Pro service + external Pi-community value) to the remaining apps, starting with **Epic** (it already has a real project backend: create → Zone-verify → Legend).

### What it is (the Explorer pattern on Epic)
- **Community value (outside TEC):** a **public `/discover`** page — the whole Pi community
  browses **launched** Pi projects ("what's being built on Pi?"), **no login**. Trust-first:
  Zone-verified rank first; ⭐ Featured within the tier; category filter.
- **Real Pro:** **Epic Pro = Featured placement** in that public directory — visibility only,
  ranked **below** `zone_verified` (pay for reach, never verification). Synced from the
  owner's live subscription by the BFF (P5); lapsed Pro clears it.

### Boundary correction (found while wiring)
Epic Pro's copy previously claimed *"priority Zone verification"* — **constitutionally wrong**
(Epic can't sell Zone's review queue; only Zone Pro does that, C-120 §7). Corrected to
**Featured placement**, which Epic genuinely owns and which ranks below verification.

### Backend / frontend (needs db push)
- `EpicProject.featured` (+ `featured_until`, `@@index`); `listPublic()` (launched-only,
  trust-first) + `GET /identity/epic/discover` (public); `setFeaturedForOwner()` + `PATCH
  /identity/epic/featured` (owner-scoped). 24/24 epic tests.
- Public `/discover` page + `/api/bff/epic/discover` (public, no token) + featured sync in
  the "my projects" BFF + ⭐ badge on the board. 27/27 frontend tests.

### The "Pro is real + serves Pi" scorecard (apps done)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| **Epic** | **⭐ Featured project** | **public `/discover` project directory** |

### Next (recorded)
Same pattern for the remaining apps — candidates: **NX** (public opportunity board + featured
posting), **Connection** (public trust profiles), **Alert** (public Pi-community feed), **DX**
(public builder catalog). Each: real Pro benefit + a public/community surface, within the boundary.

### PR ledger
tec-core-backend **#201** (listPublic + featured, 24/24) · tec-epic **#20** (public discovery
+ Pro sync, 27/27). Ops: `db push` on `tec-identity-service`. All local gates green.
