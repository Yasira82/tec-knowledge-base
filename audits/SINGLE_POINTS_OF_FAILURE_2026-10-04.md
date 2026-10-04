# Single Points of Failure — if one node disappeared, what would disappear with it?

**Date:** 2026-10-04 · **Session:** 56s
**Truth State:** [Current State] for the findings · [Planned State] for the actions
**Governance State:** [Draft] — the owner decides each action
**Verification:** [Documentation Verified] (C-02 · C-18 · C-20 · C-44) · [Code Verified] where a row says so
**Last verified against code:** 2026-10-04 (tec-core-backend `main` 6ccb3f3)

> The question comes from the owner's Continuity Network drafts (Foundation Draft, Sept 2026,
> not in this repository): *"If this node disappeared, what would disappear with it?"* It was
> asked of TEC itself before any of that project is built. This document holds **no secrets,
> no account names beyond the public GitHub/npm owners, and no addresses**. Where a fact lives
> only inside an account (a setting, a replica count, a backup switch) it is marked
> **owner to check**, not guessed.

---

## 1. The answer in one line

**The largest single point of failure in TEC is one person.** The owner is the only admin, the
only holder of every account, the only wallet that revenue lands in, and the only one who can
pay a Pioneer. The technical single points (§3) are real but each is recoverable *by that
person*; the human one (§2) is the one with no recovery path written anywhere.

## 2. People and accounts — the human node

| # | Node | What disappears with it | Evidence | Recoverable today? |
|---|---|---|---|---|
| H1 | **The owner's sign-in email** (the recovery address of the accounts below) | Every account that resets through it: GitHub, Railway, Vercel, npm, Supabase, the domain registrar | Pattern — each account below is recovered by email | Only if that email's own 2FA + recovery codes exist off the phone — **owner to check** |
| H2 | **GitHub owner `yasira82`** | All 28 repositories, CI, branch protection, every merge | Repo scope of this platform | Only through H1 |
| H3 | **npm scope `@yasser172`** | Publishing tec-ui / tec-auth / tec-sdk / tec-shared — every app's shared code | C-14; C-02 row 3: tokens expire **25 Nov 2026**, and the last expiry already broke publishing (`E404`) | Partly — Trusted Publishing (row 3) removes the token, not the account |
| H4 | **Railway project** | All 12 backend services, their databases, Redis and **every secret value** (`PI_API_KEY_*`, `JWT_SECRET`, `INTERNAL_SECRET`, the future A2U seed) | C-20; C-44 | Only through H1. The secret values exist nowhere else — correctly — so losing the account is losing them |
| H5 | **Vercel account** | All 24 app front-ends and their env vars | C-44; C-02 row 7 (one daily build quota for the fleet) | Only through H1 |
| H6 | **Pi Developer Portal account** | 24 app registrations, every `PI_API_KEY_*`, domain verification, the pending `.pi` claims | C-01 §4; C-02 rows 2, 13 | Pi's own recovery — **owner to check** that the Pi account itself has a backed-up passphrase |
| H7 | **The domain `tecosystem.app`** | Every app URL, Pi's domain verification for all 24, SSO cookies (`*.tecosystem.app`) | C-01 §4; C-123 | Registrar renewal + lock — **owner to check** auto-renew is on |
| H8 | **The owner's personal Pi wallet** | **All Mode-2 revenue lands in it** — no TEC app has a Mainnet app wallet; campaign payouts are sent from it by hand | C-02 row 15 ("into the owner's wallet"); row 6 (A2U wallet under Pi review, `Mark sent` by hand) | Its passphrase, held offline by the owner. **Never in this KB, never in a chat, never on Railway** |
| H9 | **The only admin** | Payout queue (`Mark sent`), campaign rounds, the Founding gift Re-grant, every admin-only screen | `PLATFORM_ADMIN_USERNAMES` (identity) · `ADMIN_PI_USERNAMES` (auth) — C-44 [Code Verified] | A second admin is one env value — **owner decides** whether there is anyone to trust with it |
| H10 | **The owner's phone** | Every merge, every approval, every Portal action (merges are done from the phone) | Session practice | Only as good as H1 + H6 recovery |

**What already works in TEC's favour:** the *knowledge* is not concentrated. This repository,
`CLAUDE.md` in every repo, and `memory/sessions/` are exactly the Continuity draft's
"Preserve → Transfer" step — someone with the accounts could run the platform from them. The
gap is not knowledge; it is **access**.

## 3. Technical single points

| # | Node | Blast radius | Evidence | Mitigation in place | Gap |
|---|---|---|---|---|---|
| T1 | **tec-api-gateway** | Every app's backend calls — "Backend Offline" on all 24 | ADR-005 (all traffic enters here); NEW-W incident | NEW-W: isolated `/health`, load shedding, hard upstream timeout | Replica count — **owner to check** on Railway |
| T2 | **tec-identity-service** | **24 controllers** in one process: Life, Connection (+5 sub-areas), Explorer, Zone, Nexus, System, Alert, NX, DX, Titan, Epic, Legend, Elite, VIP, NBF, Insure, campaign, pioneer, feedback, intent — about 17 apps' data | [Code Verified] `@Controller('identity/…')` list on `main` | `scripts/migrate.cjs` at start | A crash-loop here takes ~17 apps down at once — the 2026-09-13 auth crash-loop (platform-wide login down) is the same shape. **Not a reason to split in Phase 0** (no new services); a reason to be deliberate about its deploys |
| T3 | **One Redis = the event bus** | Every cross-service event (payments → orders, findings → Alert, arrivals → Analytics), idempotency keys, rate state | Redis Streams cross services, so producers and consumers must share one instance; `REDIS_URL` on 11 of 12 services (C-44) | At-least-once + idempotent consumers (C-70) | Whether Redis persists to disk (AOF/RDB) — **owner to check**; without it a restart loses un-acked events |
| T4 | **Shared secrets across the fleet** | `JWT_SECRET` (all 23 apps + auth), `SSO_SECRET` (all 23), `INTERNAL_SECRET` (all 12 services + 23 apps) | C-44 [Code Verified] | HS256 `verify()` only; gateway refuses `/internal/` without the key (C-02 §1) | A leak from **any one** of 23 Vercel projects mints sessions for all of them. **No rotation runbook exists** (searched C-17, C-78) |
| T5 | **Backups** | Wallet, ledger, payment, identity data | C-18 (Draft): PITR "⚠️ Partial — verify", off-host copies "❌ Not Started", restore drills "❌ Not Started" | — | C-18 I2: *a backup never test-restored is not a backup.* Today none has been |
| T6 | **Backend CI** | Every backend merge goes untested | C-02 row 10 — private repo out of Actions minutes since 2026-09-23 | Railway "Wait for CI" kept OFF | Billing, owner-side |
| T7 | **Pi Network** | Sign-in and every payment | External | PAL + circuit breaker (R1) | None possible beyond PAL — accepted |
| T8 | **Analytics database** | Pulse, findings, dashboards (T3, rebuildable per C-18) | C-20: Free Supabase project | Derived data | Free-tier limits — low impact by design |

## 4. Actions, in order

None of these is a feature and none needs a deploy unless stated. The owner does §4.1; the
rest can be done in sessions.

### 4.1 Owner only — this week, no code

1. **Recovery codes, offline.** For the email (H1) first, then GitHub, Railway, Vercel, npm,
   the registrar: 2FA on, recovery codes printed or written and kept **off the phone**.
2. **Pi passphrases (H6, H8).** Confirm the Pi account and the receiving wallet each have a
   passphrase backup held offline. This KB will never hold them; the point is that *someone*
   holds them besides one phone.
3. **Domain (H7).** Auto-renew on, registrar lock on.
4. **Three Railway checks (T1, T3, T5)** — read, change nothing: gateway replica count; Redis
   persistence; whether Postgres backups are enabled per database. Tell a session the answers
   and it records them here.
5. **A break-glass note (H9, H10).** Decide whether one trusted person should be able to reach
   the accounts if the owner cannot — and if so, where that sealed instruction lives (outside
   any repository). If the answer is "no one", record that it is a decision, not an oversight.

### 4.2 Sessions — documentation and small changes

6. **Secret-rotation runbook (T4)** — the order to rotate `JWT_SECRET` / `SSO_SECRET` /
   `INTERNAL_SECRET` across Railway + 23 Vercel projects without logging everyone out twice;
   written before it is needed, because during a leak is the wrong time to work it out.
7. **One test restore (T5)** — restore one T1 database to a scratch Railway database and record
   the measured RTO. That single drill moves C-18 from Draft towards Current.
8. **npm Trusted Publishing (H3)** — already C-02 row 3; due before 25 Nov 2026.
9. **identity-service deploy discipline (T2)** — its deploys go out alone, never bundled with
   another service's, and are watched until `/ready` answers.

### 4.3 Later, by decision

10. **TEC's own A2U app wallet (H8)** — already under Pi review (C-02 row 6). When it lands,
    revenue and payouts stop depending on a personal wallet.
11. **A second admin (H9)** — only when there is someone to trust with it.

## 5. Found in passing

- C-18 §4 gives identity `:5004` and auth/identity as `:5001/:5004`; C-20 (the port authority)
  has identity at `:5005` and asset at `:5004`. Not fixed here — noted for the next C-18 edit.

## Related Documents

- `knowledge-base/C-18___DISASTER_RECOVERY_BACKUP_CONSTITUTION.md` — backup policy (Draft); T5
- `knowledge-base/C-20_Backend_Services.md` — services and ports; T1–T3
- `knowledge-base/C-44_Environment_Variables.md` — which secret lives where; T4, H9
- `knowledge-base/C-02___CURRENT_STATE_.md` — rows 3, 6, 7, 10, 15
- `knowledge-base/C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md` — operations
- `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` — same session
