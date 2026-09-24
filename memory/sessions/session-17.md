# SESSION 17 — ECOSYSTEM STATE SNAPSHOT (5 July 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (repos) + **[Runtime Verified]** where noted.
> This block is the authoritative current-state header. The Session 15/16 blocks below remain
> as historical record; where an older row disagrees with this snapshot, **this snapshot wins**.

### Knowledge Base
| Field | Value |
|-------|-------|
| Version | **v3.9.0** (supersedes the v3.6.2 stamp in the history rows below) |
| Docs | **104** C-docs · registry **100% coverage** |
| CI gates | **13** (10 structural + Runtime-Governance: portal-readiness · runtime-evidence · slo-definitions) |
| Newest law | **C-123** Pi Browser Session & Cookie Spec (TIER 11 — Runtime Operational Law) |

### Apps — live vs built vs scaffold (source of truth for IDs = C-01 §4)
| App | State | Pi App ID | Notes |
|-----|-------|-----------|-------|
| Hub (tec-app) | 🟢 **live** | `tec-app-923b947851f9dfe1` | cookieless session architecture (C-123) Runtime Verified |
| Commerce | 🟢 **live** | `commerce-app-68aa99081fc1897a` | |
| Ecommerce | 🟢 **live** | `ecommerce-app-71ca4d3e462eaf54` | |
| Assets | 🟢 **live** | `assets-app-af2fb490e7b03db7` | |
| Analytics | 🟢 **live** | `analytics-822d9810de66bc84` | registered 3 Jul; Merchant Pro payment (Mode 1+2) Runtime Verified |
| **Life** | 🟡 **built (Phase 0), not yet deployed** | `life-app-c468e9eb5bf115fa` | from template; Goals/Preferences + Activity slices; charter C-106 |
| **Connection** | 🟡 **built end-to-end, not yet deployed** | (Portal pending) | Follow + Trust **[Runtime Verified 4 Jul]** + Presence + Notifications + Collaboration + Connection Pro; charter C-107 §13 |
| **Zone** | ⚪ **V0 scaffold** | (Portal pending) | `tec-zone` from template; `PI_API_KEY_ZONE` wired in payment-service; frontend pending; charter C-120 §5 |

> **5 apps live on Mainnet** (was 4). Life + Connection are built but await deploy + Pi Portal
> registration. Zone is a Portal-ready scaffold. The 24-app rollout registry
> (`manifests/app-rollout-registry.yaml`) is the tracker; C-01 §4 is authoritative for registered IDs.

### Backend — payment-service per-app Pi keys
`PI_KEY_SOURCES` now covers `ecommerce · commerce · assets · analytics · life · connection · zone`
(`env.ts`). A payment made under an app's own Pi App ID is approved with `PI_API_KEY_<SOURCE>`;
missing key for a listed source = **loud error** (the Analytics approve→502 lesson, C-12 §11).

### Connection architecture decision-of-record (C-107 §13)
Two-layer: durable relationship graph (follow / trust / collections / notifications) in
**tec-identity-service** → extract to a dedicated `tec-connection-service` at ~5k–10k users;
live presence layer on **tec-realtime-service**. Trust edges are formed from **`order.paid.v1`**
(two-party buyer↔seller), never `payment.completed.v1` (single-party U2A). Buyer/identity is
always derived from the session (JWT), never the request body (P6).
