# SESSION 42 — Value-chain apps audit (Titan · Legend · Elite · VIP): Legend Pro fixed (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PR open). Audited the four
> reputation/experience apps for the Pro-detection bug + a genuine Pro service. Result: one real bug (Legend),
> three clean-but-badge-only.

### Findings (verified in code)
- **Legend** — 🔴 **had the bug.** Legend Pro = **SHOWCASE** (the embeddable reputation-badge gate); the
  showcase sync read `.data.plan` not `.data.subscription.plan` → always FREE → the badge stayed locked for
  real Pro users. **Fixed** (tec-legend #20, 30/30) + a profile-BFF test locking it against the real nested
  shape. **Legend was the LAST app carrying the subscription-unwrap bug — the fleet is now 100% clean (7 apps
  fixed: Life · Connection · Epic · NX · Explorer · Zone · Legend).**
- **Titan · Elite · VIP** — ✅ **no bug** (no server-side `resolveProStatus` — their Pro is a subscription/
  badge with nothing gated). And **no genuine additive own-data Pro to build now**, by design:
  - **Elite** — recognition is **criteria-based, computed by Analytics** (C-127); Elite's own data (the user's
    recognitions) is populated by the value chain and empty for most — an "insight" would duplicate Analytics.
  - **VIP** — VIP **grants eligibility; the owning apps enforce value** (C-128 P5). VIP holds no own metric to
    aggregate — its tiers/benefits are the read layer over Hub PRO/ENTERPRISE.
  - **Titan** — a V0 enterprise **console**; real multi-tenant org data is Phase 1+ (needs a mature platform).
  Forcing an insight on any of the three would be sample-data theatre — deliberately not done.

### Campaign close-out (honest final state)
**Real Pro service live:** Life · Connection · Epic · NX · Analytics · Legend · Explorer · Zone · Estate · Alert.
**Held on principle (documented):** FundX · Insure (P0 financial hard-gate) · Nexus (engine V1+) · DX (API keys) ·
Titan/Elite/VIP (data computed elsewhere / V0). Every app with genuine own-data now has a working Pro; nothing faked.

### PR ledger
tec-legend **#20** (showcase Pro fix). No backend/DB change.
