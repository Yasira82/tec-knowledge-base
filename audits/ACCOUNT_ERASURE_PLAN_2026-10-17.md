# Account erasure across services — plan (2026-10-17)

> Truth State: **[Planned State]** — code in tec-core-backend #437 + tec-app #319 (open) · Governance State: **[Draft]** — decisions below taken by the
> owner on 2026-10-17 ("the technically right one" for both questions) · Verification:
> **[Code Verified]** for §1, read from `tec-core-backend` main at `76a566a`.
> Closes C-02 §2 row 26 when shipped.

## 1. What is true today

- **Nothing deletes an account.** No route, no screen. Every privacy page (Hub, Life, Connection,
  the template's) lists *Erasure* as a right and says to write to `privacy@tec.pi` — so erasure is a
  request an operator carries out by hand.
- **Until 12 Oct the hand-carried erasure was one row.** Deleting a `users` row in identity's
  database cascaded (`onDelete: Cascade`) to Life, TEC AI conversations, Connection's follows and
  Feedback. Those tables now live in their own services and databases (Session 56w); a delete in
  identity reaches none of them. `tec-ai-service`'s conversations module says so in its header.
- **One service can already erase its own part:** Life's `DELETE /identity/life/data` (C-106 §5) —
  own-scope, one transaction, keeps an audit row with counts and no content.
- **Media lives in storage-service.** `POST /storage/internal/purge-objects` deletes `chat/` and
  `stories/` keys (service-only, bounded); `avatars/` is deliberately not internally deletable.

## 2. Decisions

| # | Decision | Why |
|---|---|---|
| D1 | **The operator starts an erasure**, from a Hub admin page, on a request received at `privacy@tec.pi` — not a self-serve button | It is what every privacy page already promises; a self-serve delete is a new feature in Phase 0 and needs its own confirmation design (Pi re-auth, a cooling-off period) |
| D2 | **Life · TEC AI · Connection first**, then one service at a time on the same contract | The three the lost cascade used to reach, and the most personal data on the platform. One contract, so the next service is a route, not a design |
| D3 | **Identity orchestrates** (it owns the person, C-68): resolve the account, ask each service for a **dry run**, show it, then **apply** on the operator's typed confirmation | Fail closed (P6): every service the erasure must reach is a configured, named participant; a missing URL or a failed call is a visible "not done", never a silent skip |
| D4 | **A command over HTTP, not an event** | An event is a fact (C-70). "Erase this person" is a command that may be refused; and an event bus cannot say which consumer has *not* acted. The operator needs a per-service answer now |
| D5 | **Idempotent and re-runnable** | A partial failure is fixed by pressing again; a service with nothing left answers zero |
| D6 | **What stays:** payment, order, wallet/ledger and KYC records (Invariant #4 — every financial action has an audit trail; C-71); every service's audit rows (counts, never content); identity's `users` row (payments and orders reference its id). **This is erasure of personal data, not of financial history** | C-106 §5 already draws this line for Life ("keeping payment records") |
| D7 | Every apply writes an audit row **in each service** (counts) and one in identity naming the operator and the request reference | C-47 Forbidden #10 — no recovery or deletion without a trail |

## 3. The contract

Each participating service adds one service-only route:

```
POST /identity/internal/erasure        (under /internal/ — the gateway refuses it to non-key callers;
                                        isServiceCaller on top, C17)
body: { userId: string, username: string, apply: boolean, by: string, ref: string }
200:  { service, applied, counts: { <table>: n, … }, mediaKeys?: string[] }
```

- `apply: false` counts and writes nothing. `apply: true` deletes in one transaction.
- `mediaKeys` (Connection only): `chat/` and `stories/` objects freed by the delete; identity
  passes them to storage's `internal/purge-objects`.

Identity adds the operator's two routes (ADMIN from the verified token, never a body field):

```
GET  /identity/admin/erasure/preview?username=…            → per-service dry runs
POST /identity/admin/erasure  { username, confirm, ref }   → confirm must equal username
```

Participants come from env: `LIFE_SERVICE_URL`, `AI_SERVICE_URL`, `CONNECTION_SERVICE_URL`,
`STORAGE_SERVICE_URL` on identity. Unset = that participant reports `not_configured` and the
erasure is **not complete**.

## 4. What each service removes (v1)

| Service | Removed | Kept |
|---|---|---|
| Life | goals (+ progress), skills, preferences, budgets, consents, the Redis intent window — the existing `purgeLifeData` | `life_audit_logs` |
| TEC AI | `ai_conversations` | `ai_audit_logs` |
| Connection | profile · follows both ways · blocks both ways · notifications to or by them · stories they posted (+ views) and their views · reactions · hides · group memberships and join requests · collections they own (+ items, members) and their items/memberships in others' · reports they filed · trust edges they are part of (a projection of orders; the orders stay in commerce). **Messages they sent become tombstones** (body and media cleared, `deleted_at` set) — the same "delete for everyone" the app offers, so the other person's thread keeps its shape. A group they own passes to its oldest remaining member, or is deleted if they were the last — the existing `leave` rule | `connection_audit_logs`; reports **about** them (moderation record) |
| Identity (local) | Alert watches and notifications addressed to them; Insure protection records and risk profile | `users` row, roles, KYC status row, `identity_audit_logs` |

Not in v1, named so it is not forgotten: Connection profile **avatars** (`avatars/` is not
internally deletable by design — needs its own decision), and every other service that keys on the
person (commerce referrals, notifications, Explorer reviews, Legend profile, Pioneer quests, …).

## 5. Order

1. Backend PR: the three participant routes + identity's orchestrator + tests (backend first).
2. Owner: set the four URLs on identity-service.
3. Hub PR: `/hub/admin/erasure` — type the name, read the dry run per service, type it again, apply.
4. First run on a test account the owner creates for it; read every service's count before and after.
