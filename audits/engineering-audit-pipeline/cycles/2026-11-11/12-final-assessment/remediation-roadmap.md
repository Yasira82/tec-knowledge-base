# Remediation roadmap — cycle 2026-11-11

The order is set by dependency, not by severity alone: nothing below step 1 reaches production
without it. Each line names the finding(s) it closes; a finding closes only when its
acceptance criteria hold on `main` (README §6).

## 1. Unblock — owner

| # | Action | Closes / unblocks |
|---|---|---|
| 1.1 | Restore GitHub Actions (ticket 4956739) | Every push, merge and scheduled guard |
| 1.2 | Create the Railway restore-check cron (`17 4 3 * *`) **before 3 Dec** | 0040 (the half that does not need GitHub) |
| 1.3 | Confirm Railway reads `railway.toml` from each service root (one service, then all) | 0039 |

## 2. Merge, in release-chain order (C-75) — after 1.1

| # | Repository | Contents |
|---|---|---|
| 2.1 | tec-knowledge-base | The cycle's record, the catalog correction, check-drift's consumer check, C-78 latency SLOs |
| 2.2 | tec-template-base | gateway-fetch (0033), coverage in CI (0037), `engines` (0042), the shared lists |
| 2.3 | The 24 apps | Server-side refresh (0029), gateway deadlines (0033), coverage floors (0037), `engines` (0042) |
| 2.4 | Tec-core-backend — **not before 1 Dec** | 0030 · 0031 · 0032 · 0036 · 0038 · 0039 · 0040 · 0041 — payment-service first, with its integration tests |

Merged ≠ deployed: each step is checked on the live service (Vercel's daily build quota).

## 3. Verify on the phone (Pi Browser) — after 2.3

0029 refresh round-trip after 24 h idle; then 0018 parts 2 and 3 (withheld; the owner has the steps).

## 4. Money

| # | Action | Finding |
|---|---|---|
| 4.1 | `count(*)` the price rows, then Float → DECIMAL by expand–contract, never in one migration | 0012 |
| 4.2 | Row count for 0013, then its migration | 0013 |
| 4.3 | Retire the unversioned `payment.completed` once every consumer reads `.v1` on `main` | 0036 step 2 |
| 4.4 | Contract fixtures for the trust, nexus and wallet consumers | 0038 (extension) |
| 4.5 | Re-emit nothing in bulk; at most the ≤ 19 payments of 20 Jun–6 Aug, each checked against its consumer | 0030 follow-up (owner decision, 13 Nov) |

## 5. Security

| # | Action | Finding |
|---|---|---|
| 5.1 | Asymmetric JWT (auth signs, services verify with the public key) | 0008 (HIGH) |
| 5.2 | Nest 11 / Express 5 in the four Express services, then the advisories re-measured | 0002 (HIGH) |
| 5.3 | Release the SDK the apps can adopt; the BFFs call it (with an ADR on where contracts live) | 0019 · 0034 |
| 5.4 | zod 4, fleet-wide, in one coordinated change | 0020 |

## 6. Operations

| # | Action | Finding |
|---|---|---|
| 6.1 | A staging environment; paging on health; `ALERT_WEBHOOK_URL` (deferred by the owner, 13 Nov) | 0006 · 0040 remainder |
| 6.2 | A k6 baseline against staging, against the C-78 latency SLOs | 0043 |

## 7. Ecosystem

| # | Action | Finding |
|---|---|---|
| 7.1 | Copy `docs/examples/bff-route.example.ts` into the apps (the 0035 list without the files) | 0035 follow-up |
| 7.2 | The referral loop into the template; the 11 hand-copied files reconciled and tracked | 0044 |
| 7.3 | One version of `tec-ui` / `tec-sdk` across the fleet; the Hub's adoption decided by ADR | 0045 |
| 7.4 | Life and Zone brought onto the template's shared files | 0005 |
| 7.5 | Coverage measured over all of `src/` in the template apps, then floors re-set | 0037 remainder |

The next cycle starts a new folder and re-measures from `main`.
