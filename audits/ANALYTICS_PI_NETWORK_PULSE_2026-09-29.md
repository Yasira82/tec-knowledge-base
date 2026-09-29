# Analytics — Pi Network Pulse, and where the Analytics data lives

**PLACEHOLDER: no `C-NN` assigned.** Numbering is a human decision (`.cursorrules` RULE 6).

**Date:** 2026-09-29

**Truth State:**
- §1 and §3 are `[Current State]`.
- §2 is the design that §3 built.

**Governance State:** `[Governance Approved]`. The owner approved widening C-105's scope on 2026-09-29 (§4).

**Verification:**
- §1 is `[Runtime Verified]`, from the owner's Supabase dashboard on 2026-09-29.
- Code claims are `[Code Verified]`, on `tec-core-backend` main.
- The Pi supply API is `[Assumed]` (§2.2).

---

## 1 · Where the Analytics data lives `[Runtime Verified]`

C-105 and C-20 say "Analytics data in Supabase PostgreSQL". That is correct. It was questioned for one afternoon, and the record below exists so the question does not come up again.

| Fact | Value, 2026-09-29 |
|---|---|
| Service | `tec-analytics-service` on Railway, private (`analytics-service.railway.internal`, C-20) |
| Database | Supabase project **`tec-analytics`**, organization **Tec-Ecosystem**, `eu-west-1`, compute NANO |
| Plan | **Free** |
| Database size | **28 MB of 500 MB** (about 6 %) |
| Egress · log ingestion | about 0 |

### Access

- **Tec-Ecosystem sits under a secondary login.** It is reached through a GitHub account other than the one that owns the repositories. The owner had forgotten it, and it took an afternoon to find.
- **The fix:** on 2026-09-29 the owner invited the main account into Tec-Ecosystem as **Owner**. **Open:** confirm the main account can see `tec-analytics`.
- **No email address or login detail is recorded here.** This repository is public.
- **Why this matters:** losing the only login to a project the platform writes to every day is an outage waiting for a date.

### Pause risk

- **The risk:** Supabase pauses Free projects after a period without activity. The exact window was not checked this session.
- **Why it is low today:** `tec-analytics` is written to daily (`app.arrived.v1`, payments, logins).
- **When it rises:** if traffic stops.

### A different Supabase organization, not Analytics

- A Vercel-managed organization, "yasira82's projects", has **0 projects**.
- Vercel shows its integration `supabase-claret-blanket` with a ⚠ status.
- It is unrelated to Analytics.
- Session 14 removed the same kind of integration from `tec-app` after it failed preview deploys.
- Candidate for removal, by the owner.

---

## 2 · Proposal: a "Pi Network Pulse" card in Analytics

### 2.1 · Why not a full on-chain crawl

A community developer published an on-chain Mainnet migration tracker in r/PiNetwork (2026-09-26). It crawls the Pi chain, identifies reclaimed migrations, and compares them with Pi's announcements. It was a reason to ask whether Analytics should do the same. The answer is **no**:

| Reason | Detail |
|---|---|
| Size | 450 pages of that crawl were about 102 MB. The full history runs to GBs, against a **500 MB** Free database that Analytics already uses for its own data |
| Compute | Continuous crawling, plus a 16-day re-check per migration, is Railway work with no TEC user asking for it |
| Scope | C-105 governs TEC's own activity: payments, orders, users. Chain-wide analysis is a different product |
| Sensitivity | TEC is listed with Pi, and its `.pi` claims are pending. Publishing analysis of Pi's reclaims from inside a Pi-listed app is a risk with no upside |
| It exists | Duplicating a community developer's work competes with the one builder who engaged constructively with TEC's campaign post |

### 2.2 · What instead: a small card

**Public Pi numbers.** Read on a schedule, cached, never crawled.
- **Source: Pi's Horizon API.** Already used by `tec-payment-service` to verify transactions: `src/services/pi-tx.ts` points at `api.mainnet.minepi.com` `[Code Verified]`.
- **Source: a Pi Mainnet supply endpoint** (migrated and locked mining rewards). **`[Assumed]`**: the community dashboard cites a "Pi mainnet supply API", but this session could not reach any `minepi.com` host (egress policy). **Verify it exists, what it returns, and its terms before any code.**
- **Storage:** one small cached row, or memory, not a table that grows.

**TEC's own Pi volume** (payments across the 24 apps). This comes from Analytics' own log and is already in C-105's scope.

**Placement:**
- The public network numbers can be shown to every signed-in user.
- TEC-internal aggregates stay **operator-only**. The owner asked on 2026-09-28 that platform findings show only to admins (#176).

**Presentation rules:**
- **Numbers, not interpretation.** Each figure carries its source and the time it was read.
- **Fail closed.** An unreachable source shows "unavailable", never a zero. A zero is a claim, and "unavailable" is the truth (C-135 §4).

---

## 3 · Build status

| # | Step | Status |
|---|---|---|
| 1 | Verify a supply endpoint | ☐ **Not found.** No source this session names its URL, and this environment cannot reach `minepi.com`. The owner may ask the community developer which endpoint the tracker's "Mainnet Metrics" panel uses. Until then there is no supply figure, by design |
| 2 | Service | ✅ tec-core-backend **#352**. Not a new endpoint: `GET /analytics/pulse` (the existing public Pulse, C-122 §5.2) now carries `network`. `pi-network.ts` reads `/ledgers?order=desc&limit=200` from `PI_HORIZON_URL` (default `api.mainnet.minepi.com`, the host `tec-payment-service` already uses). It is cached 10 min (1 min after a failure) with a 5 s timeout, and writes nothing |
| 3 | Frontend | ✅ Tec-Analytics- **#55**. A "Pi Network · live from the Pi blockchain" card on `/pulse`, showing the latest ledger and when it closed, plus transactions and operations over the window, with source and read time |
| 4 | Records | ✅ C-105 §4 carries the scope line. **Open:** C-44 (generated) picks up the new `PI_HORIZON_URL` read by analytics-service on its next regeneration |

**Deliberately left out:**
- `total_coins`. On Pi it may be the whole genesis supply, not what circulates, and shown as "supply" it would be wrong.
- Any supply or migration figure (step 1).

**Runtime status, 2026-09-29 18:40 (GMT+3), `[Runtime Verified]`:**
- Both PRs are merged and the frontend is live.
- The card reads "Pi Network data is unavailable right now". The BFF response carries **no `network` field**, because the service deploy of #352 was stuck at "Publishing image" during a Railway incident ("API degradation causing slow or stuck deployments"). The running service was still #351.
- **Next check:** once #352 is ACTIVE, `GET analytics.tecosystem.app/api/bff/analytics/pulse` must end in `"network":{"available":true,…}`.
  - `"reason":"unreachable"` means Railway cannot reach Pi's Horizon.
  - `"reason":"unexpected_response"` means Pi's ledger shape differs from Stellar Horizon's, and the parser needs adjusting.
  - Either way, the card says "unavailable", never zeros.

---

## 4 · Decisions (owner, 2026-09-29)

1. **Scope: decided, yes.** Analytics presents public Pi Network numbers, presented and not interpreted. Recorded in C-105 §4.
2. **Placement: public**, on the existing public Pulse, next to TEC's de-identified aggregates. TEC-internal platform findings stay operator-only.
3. **Cleanup: open.** Should the unused Vercel Supabase integration `supabase-claret-blanket` be removed?

---

## Related Documents

- `C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md`: Analytics' scope; data in Supabase
- `C-20_Backend_Services.md`: the service map (analytics on 5011, private)
- `C-135`: an empty or unavailable result is shown as such, never fabricated
- `memory/sessions/session-14.md`: the Vercel Supabase integration removed from `tec-app`
