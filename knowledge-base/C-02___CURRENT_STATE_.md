# C-02 — CURRENT STATE
## Where the platform stands now — read this first, then the last session record

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `main`

**Last Updated:** 24 September 2026 (Session 56q — the weekly KB ↔ code drift job; C-02 split into current state + `memory/sessions/`)

> **This file holds only what is true now, and it is edited in place.** Until 2026-09-24 every
> session appended its narrative here; the file reached 5,929 lines and could no longer
> answer "where do we stand?" (audit F12). Every narrative now lives in its own file under
> [`memory/sessions/`](../memory/sessions/README.md) — "C-02 Session 46" means
> `memory/sessions/session-46.md`. Keep this file under 150 lines (a gate checks it).

---

## 1. The platform right now

Each line names its source. Where the code can confirm a fact, `scripts/check-drift.py`
checks it every Monday (`drift.yml`); last run 2026-09-24: **34 pass · 0 fail · 0 skip**.

| Area | State | Source |
|---|---|---|
| Apps | **24 live on Pi Mainnet** — 21 `live-verified`, 3 `live-readonly-gated` (FundX pools · Insure escrow · Brookfield investment stay read-only until legal + payment-service custody + SYSTEM) | `architecture/app-fleet.yaml` |
| Users | Real Pi payments work in every app, but there are **effectively no external paying users yet** — the next question is what gets the first one | Session 56n |
| Backend | 12 Railway services: gateway `:3000` + services `:5001`–`:5011`. **Public = gateway + realtime only**; the other nine are `*.railway.internal` (ADR-005) | C-20 |
| Packages | tec-ui **3.0.0** · tec-auth **1.2.0** · tec-sdk **1.4.0** · tec-shared **1.1.0** | C-14 |
| Session | Cookies `Secure; SameSite=None; Partitioned`, set only on a 200. A session = token **and** `tec_user`; refresh renews both | C-123 §2 · C-13 §1/§4 |
| Events | 15 live · 1 planned (`fundx.investment.closed.v1`) | `manifests/events-catalog.yaml` |
| SLOs | Auth / payments / gateway 99.9 % · PAL 99.95 % · Hub 99.5 % | C-78 §2 + `manifests/slo-definitions.yaml` |
| Violations | All P0/P1/P2 closed | C-40 |
| KB gates | `bash scripts/preflight.sh` = what CI runs (24 steps) | `CLAUDE.md` |
| Repos · env vars | Every repo with its dependencies, every variable the code reads — generated from the code | C-11 · C-44 |

---

## 2. Open now

Replace rows as they close — do not strike them through and keep them.

| # | Item | Why it is open | From |
|---|---|---|---|
| 1 | **Re-deploy 8 apps + the Hub** (Estate · FundX · Nx · Titan · Vip · Insure · Brookfield · NBF; Hub #256) | Vercel Hobby build quota ran out on 24 Sep; merged ≠ deployed | 56q |
| 2 | **Phone checks**: Hub keeps the name a day after sign-in (#256)? "Try again" recovers a silent Pi (#253)? | Only a device can answer; record in C-123 §9 | 56p · 56q |
| 3 | **Campaign payout evidence** — the queue shows no proof of qualification; record it AT CLAIM TIME (additive nullable column). Also `CAMPAIGN_APPS` → all 24 | Will not scale to 50 claims | 56o |
| 4 | **Assets: no repair path for a paid purchase** — pay, then a separate browser call records it; if that call is lost the π is gone and nothing repairs it | Financial integrity (Invariant #4) | 56m |
| 5 | **npm Trusted Publishing** before tokens expire **25 Nov 2026** | Last expiry broke publishing with `E404` | 46 |
| 6 | **Node 20 → 22** on the backend before **Jan 2027** (AWS SDK v3 drops Node 20) | Pinned in Dockerfiles, workflows and Railway | 56m |
| 7 | VIP benefits not implemented in any owning app (fees, support SLA, dashboards) | Must exist before VIP is marketed | 56n |
| 8 | A2U payout wallet from Pi | When it arrives, set the seed — no code change | 56o |
| 9 | Elite has two Vercel projects on one repo; previews build on every `claude/*` push | Each doubles deploy cost against the daily quota | 56q |
| 10 | Assets / Commerce / Ecommerce still on the pre-3.0 palette (104 / 149 / 202 hard-coded hexes) | A re-skin, deliberately not a sweep | 46 |
| 11 | KB backlog after the remediation plan: 24 `[Code Verified]` docs without a `Last verified` date; 669 Arabic lines inside code blocks of English docs (a ratchet — may only go down) | `audits/KB_REMEDIATION_PLAN_2026-09-24.md` | 56q |

---

## 3. The last three sessions

- **[56q](../memory/sessions/session-56q.md) — 24 Sep.** The KB now checks itself against the
  code every week. Its first run found `resolve-incomplete` setting the token without
  `Partitioned` in 22 repos, 20 unmerged name-fix PRs, and the Hub's refresh never renewing
  `tec_user` (#256) — the likeliest cause of the name vanishing on Hub pages.
- **[56p](../memory/sessions/session-56p.md) — 24 Sep.** "Not signed in" traced through three
  causes (guard, refresh, reason word); arrivals made countable; the Hub's sign-in stall is
  Pi's silent bridge (C-123 §9, #253).
- **[56o](../memory/sessions/session-56o.md) — 19 Sep.** The campaign paid a real pioneer and
  the chain agreed.

Older: [`memory/sessions/README.md`](../memory/sessions/README.md).

---
## 4. PI APP IDENTITY

> **Canonical identity:** C-01 §4. This table mirrors the complete fleet and is
> cross-checked by `evals/check-portal-readiness.sh`.

| App | Pi App ID | Domain | PI_SANDBOX |
|-----|-----------|--------|------------|
| Hub | `tec-app-923b947851f9dfe1` | `https://hub.tecosystem.app` | false |
| Commerce | `commerce-app-68aa99081fc1897a` | `https://commerce.tecosystem.app` | false |
| Assets | `assets-app-af2fb490e7b03db7` | `https://assets.tecosystem.app` | false |
| Ecommerce | `ecommerce-app-71ca4d3e462eaf54` | `https://ecommerce.tecosystem.app` | false |
| Analytics | `analytics-822d9810de66bc84` | `https://analytics.tecosystem.app` | false |
| Life | `life-app-c468e9eb5bf115fa` | `https://life.tecosystem.app` | false |
| Connection | `connection-aa9fba4f11664096` | `https://connection.tecosystem.app` | false |
| Zone | `zone-xwc6` | `https://zone.tecosystem.app` | false |
| Nexus | `nexus-3x2v` | `https://nexus.tecosystem.app` | false |
| Explorer | `explorer-kxfp` | `https://explorer.tecosystem.app` | false |
| System | `system-qbz2` | `https://system.tecosystem.app` | false |
| Alert | `alert-3ag1` | `https://alert.tecosystem.app` | false |
| NX | `nx-cahj` | `https://nx.tecosystem.app` | false |
| DX | `dx-hqma` | `https://dx.tecosystem.app` | false |
| Titan | `titan-e1ta` | `https://titan.tecosystem.app` | false |
| Epic | `epic-4muf` | `https://epic.tecosystem.app` | false |
| Legend | `legend-43xr` | `https://legend.tecosystem.app` | false |
| Elite | `elite-cfwh` | `https://elite.tecosystem.app` | false |
| VIP | `vip-vzge` | `https://vip.tecosystem.app` | false |
| NBF | `nbf-zutt` | `https://nbf.tecosystem.app` | false |
| FundX | `fundx-55a3cb7bc6cf09fd` | `https://fundx.tecosystem.app` | false |
| Estate | `estate-f4d67b390ff45ed6` | `https://estate.tecosystem.app` | false |
| Insure | `insure-ayh6` | `https://insure.tecosystem.app` | false |
| Brookfield | `brookfield-ftq4` | `https://brookfield.tecosystem.app` | false |

---

## 5. UPDATE PROTOCOL

```
At the end of every session:
☐ Write memory/sessions/session-<id>.md — the narrative, as long as it needs
☐ Add its row at the top of memory/sessions/README.md
☐ Here: edit §1 and §2 IN PLACE (replace, never append); rotate §3 to the last three
☐ Update "Last Updated"
☐ bash scripts/preflight.sh — it fails if this file passes 150 lines
```
