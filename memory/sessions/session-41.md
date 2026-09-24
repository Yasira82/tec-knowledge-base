# SESSION 41 — Explorer + Zone Pro-gate fixes (already built) + Estate Portfolio Insights (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Extending the campaign to
> the apps the user named. Key finding: **Explorer and Zone were already fully built** — their Pro was
> just blocked by the same subscription-unwrap bug (Session 40). Fixed. Estate got a real new insight.

### Explorer + Zone — were already complete; carried the fleet Pro bug
Both apps shipped the genuine pattern in earlier sessions and were **silently broken** by the same
`resolveProStatus` bug (read `.data.plan`, not `.data.subscription.plan` → always FREE):
- **Explorer (C-108)** — "List your business" (self-listing) + ⭐ **Featured** (Explorer Pro) + public
  discovery. The featured sync never fired for real Pro users. **Fixed** (tec-explorer #21, 41/41).
- **Zone (C-120)** — verification requests + review queue + public verified registry + append-only
  evidence. **Zone Pro = queue PRIORITY** (§7 — speeds the queue, never the verdict) — never applied.
  **Fixed** (tec-zone #26, 35/35). Each got a test locking the Pro path against the REAL nested shape.

### Estate — new genuine Pro service (Portfolio Insights)
Estate was functionally built (register a property → stored as an **asset** in asset-service; own
portfolio view) but its Pro was **badge-only**. Added **Portfolio Insights** (Estate Pro): an aggregate
of the caller's OWN properties — total · by type · by ownership · occupancy (leased/listed) · Zone-verified.
**CRITICAL (C-114 §5): counts + lifecycle status ONLY — NEVER a summed valuation** (valuation is
indicative, Analytics-owned). Own-data, gated behind live Pro (P5). tec-estate #19 (33/33).

### Alert — new genuine own-data feature (Watchlist) ✅
Alert was a **read-only inbox** (seeded feed + community). Added a **Watchlist**: the user's OWN
self-created reminders ("watch this") — self-declared own-data (P6), distinct from the delivered
`AlertNotification`. **Additive** (removes nothing free). **Alert Pro = unlimited; FREE capped at 3**
(enforced at the BFF from the live subscription, P5). Backend `AlertWatch` (owner-scoped list/create/
done/delete) + BFF (free-cap gate) + Watchlist UI. tec-alert #17 (frontend) + backend on the branch.
Ops: `prisma db push` (`alert_watches`). 12/12 backend · 29/29 frontend.

### Honest ruling on the rest of the named apps (verified in code, NOT force-fit)
- **Nexus** — workflow engine is **V1+ gated by design** (C-109); no real feature without it.
- **DX** — real value = **API keys** (gated); the catalog is not own-data.
- **FundX · Insure** — **P0 financial hard-gate** (C-113 §11 pools · C-129 escrow = payment-service only,
  Invariant #8). **Refused on principle** — building anything touching pools/escrow risks multi-user loss.

### Fleet Pro-bug status
The subscription-unwrap bug (Session 40) has now been fixed in **6 apps**: Life · Connection · Epic · NX
(Session 40) + **Explorer · Zone** (this session). Every app that gates on Pro now detects it correctly.

### PR ledger
tec-explorer **#21** · tec-zone **#26** · tec-estate **#19** (all read existing data — no DB change) ·
tec-alert **#17** + AlertWatch backend on the core-backend branch (**needs `db push`: `alert_watches`**).
All local suites + typecheck green.
