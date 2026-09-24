# SESSION 40 — HOTFIX: Pro read as FREE (subscription-unwrap) — every Pro gate was broken (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (found from a live prod screenshot:
> a real Pro user saw the Life "Goal Insights" gate LOCKED while "🌱 You're on Life Pro" showed above it;
> NX post had no ⭐ Featured despite "★ You're on Pro").

### The bug
`commerce GET /subscriptions/status` returns **`{ data: { subscription: { plan, isActive, isExpired,
current_period_end } } }`**. The new `resolveProStatus` helper (added Sessions 38–39, replicated in 4 apps)
only unwrapped **`.data`** and then read `s.plan` — which is `undefined` (it's `s.subscription.plan`) —
so it **always parsed FREE**. Result: **every Pro-gated feature failed for actual subscribers** — Life/Epic
insights locked, NX/Epic/Connection featured never lit, Connection followers list withheld. The existing
per-app `*Pro` badge parsed `.subscription` correctly (hence "You're on Pro" showed while the gate didn't) —
that contradiction on screen is what exposed it.

### The fix (one line × 4 apps)
`resolveProStatus` now unwraps **`root.subscription ?? root`** (flat shape still tolerated). Root cause of the
miss: **the BFF gate tests mocked the FLAT shape** (`{ data: { plan } }`), not the real nested one — so they
passed against a wrong contract. All four test suites were corrected to the **real `{ data: { subscription } }`
shape**, so this can't regress. Life 21/21 · Connection 26/26 · Epic 30/30 · NX 31/31.

### Lesson (recorded)
A BFF unit test is only as good as the response shape it mocks. When gating on another service's contract,
**mock that service's real envelope** (here `{ data: { subscription } }`) — a hand-written flat mock will
green-light a parser that fails in prod. PRs: tec-life **#22** · tec-connection **#28** · tec-epic **#22** · tec-nx **#18**.
