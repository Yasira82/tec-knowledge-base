# C-02 — CURRENT STATE
## Where the platform stands now — read this first, then the last session record

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `main`

**Last Updated:** 29 September 2026 (Session 56s — Portal listing pass; the gateway's `/internal/` door closed; invented "verified" data purged; campaign round 2 live; Pi sign-in on a visit in Commerce · Ecommerce · Assets)

> **This file holds only what is true now, and it is edited in place.** Until 2026-09-24 every
> session appended its narrative here; the file reached 5,929 lines and could no longer
> answer "where do we stand?" (audit F12). Every narrative now lives in its own file under
> [`memory/sessions/`](../memory/sessions/README.md) — "C-02 Session 46" means
> `memory/sessions/session-46.md`. Keep this file under 150 lines (a gate checks it).

---

## 1. The platform right now

Each line names its source. Where the code can confirm a fact, `scripts/check-drift.py`
checks it every Monday (`drift.yml`); last run 2026-09-25: **36 pass · 0 fail · 0 skip**.

| Area | State | Source |
|---|---|---|
| Apps | **24 live on Pi Mainnet** — 21 `live-verified`, 3 `live-readonly-gated` (FundX pools · Insure escrow · Brookfield investment stay read-only until legal + payment-service custody + SYSTEM) | `architecture/app-fleet.yaml` |
| Users | Real Pi payments work in every app, but there are **effectively no external paying users yet** — the next question is what gets the first one | Session 56n |
| Backend | 12 Railway services: gateway `:3000` + services `:5001`–`:5011`. **Public = gateway + realtime only**; the other nine are `*.railway.internal` (ADR-005) | C-20 |
| Caller identity | The gateway adds `x-internal-key` to every forwarded request, so the key alone never proves a service. It refuses `/internal/` paths to callers without the key and marks every request `x-tec-caller` = service · user · anonymous; payment, wallet and identity check it too | tec-core-backend #345 · Session 56s |
| Packages | tec-ui **3.0.0** · tec-auth **1.2.0** · tec-sdk **1.4.0** · tec-shared **1.1.0** | C-14 |
| Session | Cookies `Secure; SameSite=None; Partitioned`, set only on a 200. A session = token **and** `tec_user`; refresh renews both | C-123 §2 · C-13 §1/§4 |
| Events | 16 live · 1 planned (`fundx.investment.closed.v1`). Newest: `app.arrived.v1` — an app's arrival report, once per user/app/day, counted by Analytics as an active user only (#351) | `manifests/events-catalog.yaml` |
| SLOs | Auth / payments / gateway 99.9 % · PAL 99.95 % · Hub 99.5 % | C-78 §2 + `manifests/slo-definitions.yaml` |
| Violations | All P0/P1/P2 closed — C17 (any signed-in user could reach A2U payout, add-funds and 10 owner-scoped modules) found and closed 2026-09-27, live-verified. 2026-09-28: Analytics treated an INVALID Bearer as its internal caller, so a fake `tec_access_token` cookie on the Analytics BFF returned every platform aggregate — closed (tec-core-backend #351) | C-40 · Session 56s |
| KB gates | `bash scripts/preflight.sh` = what CI runs (24 steps) | `CLAUDE.md` |
| Repos · env vars | Every repo with its dependencies, every variable the code reads — generated from the code | C-11 · C-44 |

---

## 2. Open now

Replace rows as they close — do not strike them through and keep them.

| # | Item | Why it is open | From |
|---|---|---|---|
| 1 | **Watch for a CSRF 403** on any app's POST (payment, save, follow): the middleware runs for the first time in the 20 template apps (C-123 §11). A 403 on a legitimate same-origin POST means Pi Browser sent no `Origin` and no `tec_csrf` — report the route | New enforcement in production since 2026-09-26 | 56r |
| 2 | **Campaign round 2 is on all 24 apps** — `CAMPAIGN_APPS` = the full roster and `CAMPAIGN_VISITS_FROM=2026-09-28T00:00:00Z` on `tec-identity-service` (set by the owner 2026-09-28), so round-1 visits do not carry anyone to the claim form; a new-round mission tap restamps a visit from an earlier round (tec-core-backend #349 — before it, those missions could never tick). `CAMPAIGN_REQUIRE_ARRIVAL` is unset: a tap counts. Announced on r/PiNetwork 2026-09-28 (flair Pi Apps, Brand Affiliate; link tagged `utm_source=reddit&utm_campaign=pi-reward-r2`; organic, not promoted); seat #1 disclosed there as the owner's own test payout. Round-1 claims keep what they were asked for (`qualified`, #327). Watch the drop-off against the 8-app round: a longer ask converts worse. Rewards go by `Mark sent` until row 6 lands. The page names the **Mainnet** address, not Testnet (tec-app #263, from a Reddit comment). **Result so far (29 Sep, owner's Domains screen): 9 `.pi` claims pending** — life · tec · connection · explorer · legend · elite · dx · commerce · analytics (commerce opened hours after #73). On Pi's approval add each to `PI_CLAIMED_APPS` on identity-service (today `tec`) so coverage stops counting it as work. **The rest show ≥5/5 on coverage yet Pi says "Requirements Not Met"** — Assets and Explorer have identical Portal setups, so it is not the checklist: coverage counts a page load (`ArrivalReport` fires on mount, before and without `Pi.authenticate`), Pi counts KYC'd Pioneers who signed in with Pi *in that app*. Tell participants to allow the Pi sign-in prompt in every app; gating the report on a successful sign-in (24 app repos) is offered, not started. **Commerce · Ecommerce · Assets never signed a visitor in with Pi** (only at payment, or on one page) — they now do on every standalone visit (Tec-Commerce #73 · Tec-Ecommerce #70 · Tec-Assets #66, 29 Sep); their count at Pi starts from there. **A visit opened from the Hub grid never counts at Pi** (Hub-owned session, ADR-007) — participants should open apps from the campaign page (row 15) | Running — the owner reads the numbers | 56o · 56r · 56s |
| 3 | **npm Trusted Publishing** before tokens expire **25 Nov 2026** | Last expiry broke publishing with `E404` | 46 |
| 4 | **Node 20 → 22** on the backend before **Jan 2027** (AWS SDK v3 drops Node 20) | Pinned in Dockerfiles, workflows and Railway | 56m |
| 5 | VIP benefits not implemented in any owning app (fees, support SLA, dashboards) | Must exist before VIP is marketed | 56n |
| 6 | **TEC's own A2U app wallet** is under Pi review (2026-09-28). `PI_A2U_WALLET_SEED` is **unset** on payment-service (the payout screen says so, 2026-09-28), so `Send now` cannot send; until the wallet lands, campaign rewards go out by hand — send from any wallet to the claim's address, paste the hash into `Mark sent` (chain-verified, Runtime Verified 56o). **Do not use `Send now` with another Pi app's wallet:** A2U pays a `uid`, a `uid` is per Pi app, and claimants' uids are the Hub's — Pi answers `user_not_found` and the claimant is told to sign in again, which cannot help. On approval: connect it as the Hub's Outgoing Wallet, switch `PI_A2U_WALLET_SEED` and the default `PI_API_KEY` **together** (same Pi app) only after `GET /payments/internal/a2u/incomplete` is empty; fund it first; check `a2u/limits`, then one small payout | Pi's review | 56o · 56s |
| 7 | Elite has two Vercel projects on one repo; previews build on every `claude/*` push | Each doubles deploy cost against the daily quota | 56q |
| 8 | Assets / Commerce / Ecommerce still on the pre-3.0 palette (104 / 149 / 202 hard-coded hexes) | A re-skin, deliberately not a sweep | 46 |
| 10 | **Backend CI has not run since 2026-09-23** — the private `Tec-core-backend` ran out of Actions minutes (job never gets a runner). Nothing merged there is CI-tested; Railway "Wait for CI" must stay OFF until it is green | Owner: Billing → Actions budget, or the monthly reset | 56s |
| 11 | **Payout wallet history before 2026-09-24** — the only way to rule out C17 abuse earlier than Railway's log retention | Owner: Pi Block Explorer / wallet | 56s |
| 12 | **Agent-Ready Commerce / Pi-wide discovery** — the owner's proposal, assessed: most of the integrity layer is already built (Intent · Delta · Gate · Proof, #316 · #325); missing are the rules-first compiler (4.3) and a capability surface. On Pi an agent cannot pay (the wallet signs every U2A) and TEC cannot execute inside another Pi app. Recommended: one measured Commerce path inside TEC before anything Pi-wide | Owner decides: build §6, ADR for "Nexus discovery", or Pi Flash first — `audits/AGENT_READY_COMMERCE_ASSESSMENT_2026-09-29.md` | 56s |
| 14 | **Analytics: Pi Network on the public Pulse** — decided and built: `/pulse` shows Pi's latest ledger + transactions/operations from Horizon (tec-core-backend #352 · Tec-Analytics- #55, merged 29 Sep; C-105 §4). Pi's Mainnet supply figures followed (tec-core-backend #353 · Tec-Analytics- #56). **Live and Runtime Verified 29 Sep 19:01** (ledger 28,964,676 · 736 transactions / 1,645 operations over 200 ledgers ≈ 17 min). The DB is the Free Supabase `tec-analytics`, 28 / 500 MB. **3 Oct:** a payment-health finding — the share of STARTED payments that complete, hourly, against its 7-day normal — reaches the Alert inbox (tec-core-backend #363; it sees the approve-502 outage the daily count cannot), and Commerce's Sales tab opens on the seller's own numbers (Tec-Commerce #75) | Owner: set `PAYMENT_SERVICE_URL` on `tec-analytics-service` (same value as commerce-service) — until then the sweep logs a WARN and watches nothing — `audits/ANALYTICS_PI_NETWORK_PULSE_2026-09-29.md` | 56s |
| 15 | **Hub grid → apps standalone: done, phone-verified 2026-10-02** — new tab + signed handoff + `rememberReturn('/hub')` (tec-app #266 · #269 · #270): the app signs in with Pi (the visit is the app's), pays Mode 2 (into the owner's wallet — no TEC app has a Mainnet app wallet), and Android's Back lands on `/hub` signed in. Same tab was tried and reverted: Pi stays with the tab's first app (C-123 §13). Ecommerce no longer takes π for an out-of-stock product (#72). Pro in template apps opened from the grid hung (the tap joined a warm-up Pi never answers there) — fixed by tec-template-base #45 + 18 app PRs (merged, verified on NX) + NBF #28 · Brookfield #24 (missed in the first rollout, open). Connection's story sweep had never run (empty JSON body) — Tec-Connection #88. **Per-app Pro (owner decision):** an app's Pro is that app's own, with a cancel; the Hub plan is separate (tec-core-backend #356 first — a migration, applied by `migrate deploy` at start, NO `db:push` — then the app PRs); a Pro bought before the split moves to the app it was bought in, with its Cancel (#357); a cancelled Hub plan reads Free (tec-app #271); the Founding gift covers the Hub + every app (#358 — press Re-grant once after deploy). The last unit is now HELD before payment, atomically, with the hold settled by the payment's own event (tec-core-backend #361 · Tec-Ecommerce #73 · tec-app #274 — backend first). **Open:** an app's own Mode-1 fallback in a standalone tab walks into C-123 §9 | Watch for a grid purchase that ends on the Hub's modal, and for `REFUND OWED` in commerce-service's logs (a payment after its hold expired, unit sold — refund by hand) — `audits/HUB_GRID_PAYMENTS_AND_BACK_2026-10-02.md` | 56s |
| 13 | Portal listings: submit; Arabic where it applies; Hub Mainnet app wallet; Testnet side of 22 apps; retake the screenshots the fixes changed | `audits/PORTAL_LISTING_BACKLOG_2026-09-26.md` | 56s |
| 16 | **Round 3 = a Product Discovery Experiment, not an Evidence Engine build** (owner, 2026-10-04). An outside spec calls a 19-stage "Round 3 Evidence Engine" SEALED through 5.4 — **none of it exists in any repo** (searched all 28, every branch). Order: interview (the 2026-08-16 interview-first decision, still active) → campaign funnel instrumentation (one append-only table) → Round 3 MVP (one mission: Choose → Discover → Report, reward after verification) → the Engine only when real data needs it. "Afraid of a hacker" is a hypothesis; a Trust Preview, if built, is an A/B variable. **The interview was dropped by the owner ("they will not reply — I am not looking back").** The funnel is built instead, and asks everyone who stops, in one tap: tec-core-backend #366 (`CampaignEvent`, `/identity/campaign/funnel`) · tec-app #275 (stop-reason card, admin funnel). The Engine's target spec is stored, with three adjustments for this platform. **MVP shape (owner, 4 Oct):** the mission is 1–3 apps, the Pioneer's pick, rewarded per accepted app; one optional one-tap question with the report — "If your phone were lost today, would your Pi be safe?" (yes / no / not sure; nothing typed, aggregate only) — which decides C-106 §10a Personal Continuity | **MVP built** (tec-core-backend #373 → tec-app #277), off until `CAMPAIGN_MODE=pick`. Merge #373, deploy identity, merge #277; open the round with the env in the decision doc §4a, then read the 1/2/3 split and the continuity counts — `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` · `audits/EVIDENCE_ENGINE_TARGET_SPEC_v1.0_2026-10-04.md` | 56s |
| 17 | **Single points of failure (2026-10-04).** The largest is one person: the only admin, the holder of every account, the wallet all Mode-2 revenue lands in, the only one who can pay a Pioneer. Technical: identity-service carries 24 controllers (~17 apps); one Redis is the event bus; `JWT_SECRET` / `SSO_SECRET` / `INTERNAL_SECRET` are shared fleet-wide with no rotation runbook; no backup has ever been test-restored (C-18) | Owner: §4.1 — recovery codes offline, Pi passphrases backed up, domain auto-renew, three read-only Railway checks, a break-glass decision — `audits/SINGLE_POINTS_OF_FAILURE_2026-10-04.md` | 56s |
| 18 | **TECO is TEC's decision product; its rules are now TEC law (owner, 2026-10-04).** Name and domain: TEC. TECO stays [Future Vision] — TEC finishes first. Adopted: C-47 §10 **E1** unknown is never positive (or neutral) evidence · **E2** status before score · **E3** hard constraints exclude before scoring, plus the five evidence statuses. Not adopted: the 69-repository map. First enforcement: Insure no longer shows a missing risk band as MODERATE | Merge Tec-Insure #43 — `audits/TECO_DECISION_CORE_ASSESSMENT_2026-10-04.md` | 56s |
| 19 | **Pi Community Expansion Map (owner, 2026-10-04): the apps must serve the Pi community, not only each other.** Phase 0: F1 A2U wallet · F2 seller payouts (no app can pay a Pioneer seller today; checked in code) · F3 count an arrival after a Pi sign-in, the way Pi counts for domains · F4 SPOF actions. Phase 1: Round 3 on the C-135 launch set only — Round 2 ran on all 24 against C-135's own decision. Phase 2: one slice at a time — Explorer share pages · DX guides · Pulse card · marketplace (after F2) · Zone · Alert · Life §10a | Tracker tec-knowledge-base #191 (15 issues) — `audits/PI_COMMUNITY_EXPANSION_MAP_2026-10-04.md` | 56s |
| 9 | KB backlog after the remediation plan: 24 `[Code Verified]` docs without a `Last verified` date; 669 Arabic lines inside code blocks of English docs (a ratchet — may only go down) | `audits/KB_REMEDIATION_PLAN_2026-09-24.md` | 56q |

---

## 3. The last three sessions

- **[56s](../memory/sessions/session-56s.md) — 26–28 Sep.** A Pi Portal listing pass for all 24
  apps found 19 issues. The gravest: the gateway's own internal key made every service's
  `/internal/` route — A2U payout, wallet add-funds — and 10 owner-scoped modules reachable by any
  signed-in user (C17, closed and live-verified). Invented "verified" fixtures purged from
  production; self-granted reputation closed; backend CI found starved of Actions minutes.
- **[56r](../memory/sessions/session-56r.md) — 24–25 Sep.** Assets delivered paid actions on any
  payment id, and approve never compared Pi's amount with the recorded one — both fixed and live.
  Every Hub-bought Pro was paid and never activated (`product_id` vs `item`) — fixed, verified.
- **[56q](../memory/sessions/session-56q.md) — 24 Sep.** The KB now checks itself against the
  code every week; its first run found three bugs (#256 among them).

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
