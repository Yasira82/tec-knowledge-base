# Executive report — Engineering Audit Pipeline, cycle 2026-11-11

> Six runs, 11–13 Nov 2026, over **30 repositories**: the Hub, 23 more apps, the template, the
> backend's 20 services, three shared packages, the knowledge base. Truth State:
> [Current State] for what is on `main`; [Planned State] for the fixes committed locally.

## The verdict in one paragraph

TEC is **well built where it is written down and checked by a tool**, and **fragile wherever it
is not**. The money core held up under the hardest look this cycle gave it: amounts are DECIMAL,
the wallet cannot go negative, every payment status change is now conditional on the state
machine, and the one CRITICAL (an order paid by any payment id) was fixed with no sign of abuse.
The weaknesses are of one kind: **a rule that lives in a comment, a dashboard, a copy or a
config file that nothing runs** — a coverage floor no CI measured, a restore check that passed
when unconfigured, deploy safety in a dashboard, eleven files copied by hand into eighteen apps,
every scheduled guard on one provider that stopped with one unpaid bill. **Not ready for outside
customers' money yet; close** — see `production-readiness.md`.

## The numbers

| | |
|---|---|
| Findings | **45** — 1 CRITICAL · 5 HIGH · 20 MEDIUM · 16 LOW · 3 INFO |
| Closed on `main` | 3 (the CRITICAL; one fixed; one raised in error) |
| Fixed and tested, **not yet on `main`** | **23** — local commits; GitHub Actions has been refused for the account since 12 Nov, and the owner decided nothing is pushed until it is back |
| Fixed in part | 4 (0018 · 0037 · 0040 · 0043) |
| Open | 15 — and 0012 / 0013 corrected back to open in this run |
| Tests run | **13,823**, all passing (backend 4,264 · apps 9,559) — on `main` + the local commits |
| Critical capabilities traced screen → database | 13: 8 verified · 1 broken on main (session refresh, fixed locally) · 2 partial · 1 not verifiable here · FundX/Insure money flows not built by decision |

## What changed because of this cycle (local, awaiting merge)

- **Payments:** the hourly reconciliation now emits the event that delivers a purchase (0030,
  HIGH; production read: no payment lost since 6 Aug); recovery can no longer cancel a payment
  that completed meanwhile (0031); approve/complete are race-safe (0032).
- **Sessions:** every app renews its session on the server (0029) — the precondition for the
  24-hour token ADR-001 asks for.
- **Integration:** every BFF call to the gateway has a deadline (0033, 435 calls); notifications,
  live updates and analytics stop missing payments finished by recovery (0036);
  `payment.completed.v1` has one contract checked by producer and consumers (0038).
- **Operations:** the restore check fails when it cannot check and can run on Railway (0040);
  every service declares its healthcheck in code (0039); coverage floors run in every app's CI,
  the Hub's included — it could not measure at all (0037).

## Decisions the owner holds

1. **GitHub Actions** (ticket 4956739) — every push, merge and scheduled guard waits on it.
2. **Railway:** create the restore-check cron before 3 Dec; confirm `railway.toml` is read.
3. **`ALERT_WEBHOOK_URL`** — deferred (risk accepted, 13 Nov): a failed backup alerts nobody.
4. **ADR:** where domain contracts live — SDK or app (0034); whether the Hub adopts `tec-auth` /
   `tec-ui` (0045).
5. **Re-emitting old completion events:** not in bulk (decided with the production read, 13 Nov).

The order of work is `remediation-roadmap.md`; the scores, `engineering-scorecard.md`.
