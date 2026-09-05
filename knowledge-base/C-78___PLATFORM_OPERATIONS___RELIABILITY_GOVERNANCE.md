# C-78 — PLATFORM OPERATIONS & RELIABILITY GOVERNANCE

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


## TEC Ecosystem — Unified Operations Constitution

> Status: ACTIVE
> Authority: Platform Governance Layer
> Scope: Reliability, incidents, ownership, operations, degradation
> Merges: C-78 (Reliability) + C-79 (Operations) + C-80 (Incidents) + C-81 (Ownership)
> Review: Monthly

---

# 1. OPERATIONAL PRINCIPLES

```txt
Reliability > Expansion
Rollback > Hotfix
Evidence > Assumptions
Systems > Blame
Governance > Heroics
```

---

# 2. SERVICE LEVEL TARGETS

| Runtime  | SLO    | MTTR Target |
|----------|--------|-------------|
| Auth     | 99.9%  | < 15 min    |
| Payments | 99.9%  | < 15 min    |
| Gateway  | 99.9%  | < 30 min    |
| PAL      | 99.95% | < 15 min    |
| Hub      | 99.5%  | < 60 min    |

**Error Budget Rule:** Budget exhausted → feature freeze → reliability-only work.

> **Machine-readable contract:** these targets are formalized in
> `manifests/slo-definitions.yaml` (validated by `evals/check-slo-definitions.sh`).
> A breach emits an `slo_breach` runtime-evidence record
> (`manifests/runtime-evidence-schema.yaml`) bound back to this doc, consumable by
> the Verification Engine (C-93) at VAM tier V-5. Ops wires Prometheus alerts from
> the manifest.

---

# 3. RUNTIME OWNERSHIP

| Runtime     | Owner (current) | Blast Radius    | Tier |
|-------------|----------------|-----------------|------|
| tec-auth    | Yasser         | Platform-wide   | 0    |
| tec-payment | Yasser         | Economic-wide   | 0    |
| PAL         | Yasser         | Platform-wide   | 0    |
| Gateway     | Yasser         | Federation-wide | 0    |
| Hub SSO     | Yasser         | Identity-wide   | 1    |
| Commerce    | Yasser         | Commerce only   | 3    |
| Assets      | Yasser         | Assets only     | 3    |
| Ecommerce   | Yasser         | Ecommerce only  | 3    |

**Tier Classification:**
- **Tier 0:** Platform Critical — outage = everything down
- **Tier 1:** Economic Critical — outage = payments/auth affected
- **Tier 2:** Shared Runtime — event bus, observability
- **Tier 3:** Domain Runtime — single app affected

**Solo Developer Reality:** All ownership = Yasser. When team grows → distribute by tier.

---

# 4. INCIDENT SEVERITY

| Severity | Description | Acknowledge | Mitigate | Example |
|----------|-------------|-------------|----------|--------|
| P0 | Economic integrity | 5 min | 15 min | Payment corruption, double-spend |
| P1 | Platform instability | 15 min | 60 min | Auth outage, Gateway down |
| P2 | Federated degradation | 1 hour | 1 day | Single runtime degraded |
| P3 | Isolated issue | 1 day | Sprint | UI bug, non-critical service |

---

# 5. INCIDENT RESPONSE

### Philosophy
```txt
Rollback first → Investigate second → Patch third
```

### P0/P1 Procedure
```txt
1. DETECT   — alert/user report/monitoring
2. CONTAIN  — disable affected runtime (kill switch / Mode 1 force)
3. MITIGATE — rollback deployment
4. RECOVER  — verify health checks + error rates
5. VERIFY   — economic integrity check
6. DOCUMENT — postmortem within 72 hours
```

### Containment Options
| Action | When |
|--------|------|
| Force Mode 1 | Pi SDK instability |
| Read-only mode | Auth instability |
| Disable automation | Event storm |
| Queue approvals | Payment latency |
| Logs-only | Observability outage |

---

# 6. POSTMORTEM (P0/P1 only)

**Required within 72 hours. Blameless.**

```txt
## Incident Summary
What happened?

## Timeline
Chronological events with timestamps

## Root Cause
Technical + process + governance causes

## Detection
How detected? Why not sooner?

## Recovery
What worked? What failed?

## Action Items
□ Corrective actions (fix the issue)
□ Preventive actions (prevent recurrence)
□ New tests / alerts / controls
```

---

# 7. PRODUCTION ENTRY REQUIREMENTS

Before any service enters production:

```txt
□ /health endpoint exists
□ Structured logs (request_id, trace_id)
□ Tests ≥ 60% coverage
□ Runbook documented
□ Rollback tested
□ SLO defined
□ Security review complete
□ Ownership assigned
```

---

# 8. RELEASE GATES

Before every push:

```txt
□ Type-check = 0 errors
□ Lint = 0 errors
□ Tests pass (or documented skip)
□ git status clean
□ git fetch + rebase
□ CI green before reporting "done"
```

After payment/auth changes:

```txt
□ Mode 1 test (Hub redirect)
□ Mode 2 test (direct payment)
□ Hub → App navigation test
□ Direct entry test
□ Rollback verification
```

---

# 9. DEPENDENCY RISK

| Dependency | Risk | Mitigation |
|------------|------|------------|
| Pi SDK | Platform-wide | PAL (post-Portal) |
| Pi Browser | Undocumented behavior | ADR documentation |
| Railway | Deployment | Multi-region (future) |
| Vercel | Frontend | Static fallback |
| Redis | Event bus | Circuit breaker |

**Rule:** External dependency instability must never compromise economic integrity.

---

# 10. OBSERVABILITY ROADMAP

| Phase | What | Status |
|-------|------|--------|
| 1 | Structured logs + /health | ✅ Done |
| 2 | Metrics (Prometheus) | ⚠️ Partial |
| 3 | Distributed tracing | ❌ Not started |
| 4 | Correlation (request→payment→wallet) | ❌ Future |
| 5 | Runtime intelligence | ❌ Post-Scale |

**Current:** Phase 1 complete, Phase 2 partial. Enough for Portal.

---

# 11. OPERATIONAL KPIS

```txt
MTTR         — Mean Time To Recovery
MTTD         — Mean Time To Detection
Deploy Rate  — Successful deploys / total
Rollback %   — Rollbacks / total deploys
Incident Freq — P0/P1 per month (target: 0)
```

---

# 12. EXPANSION FREEZE CONDITIONS

Expansion automatically freezes if:

```txt
□ P0 unresolved
□ P1 backlog > 3
□ Error budget exhausted
□ Platform reliability below SLO
□ Governance review failed
```

**Current:** No expansion until Portal submitted (C-77 Section 9).

---

# 13. ANTI-PATTERNS (PRODUCTION-LEARNED)

```txt
❌ Push → break → fix cycles
❌ Runtime rewrites during stabilization
❌ Shared-runtime mutation without governance
❌ Direct Pi assumptions without evidence
❌ Reporting success before CI passes
❌ Major dependency upgrades without review (Dependabot!)
❌ Restructuring working code to "improve" it
❌ Changing auth flow without testing Hub + Direct
❌ Never looking at the bill (see §13b — CI was the largest line for months)
❌ Copying one repo's CI fix to the fleet without re-measuring that repo's numbers
```

---

# 13b. PLATFORM RUNNING COST — MEASURED, NOT ESTIMATED (Sep 2026)

> **Truth State:** `[Current State]` · **Verification:** `[Runtime Verified]` — read from
> GitHub invoices, the metered-usage API and the Actions run/job API on 4 Sep 2026.

A declined card started this. What it uncovered is that **the platform's own CI and
tooling were the largest line on the bill, and nobody had ever looked.**

```txt
Apr 28   $4.00     ← GitHub Pro only
May 28   $4.00
Jun 28   $36.47
Jul      $36.74
Aug 28   $72.04    ← declined twice; unpaid
Sep 1-4  $36.35    ← four days, tracking ABOVE August
```

## 13b.1 Two separate causes, found in this order

| # | Cause | Evidence | Size |
|---|-------|----------|------|
| 1 | **Copilot automatic code review** | `AI usage` shows ONE model consuming: `Code Review model`. 1,497 included credits exhausted + **1,961.62 additional** × $0.01 | **$19.62 in 4 days** |
| 2 | **GitHub Actions overage** | Invoice `INV152812343`: `GitHub Actions Usage, Jul 01–31` | **$58.04 in one month** |

**The first guess was wrong, and the invoice corrected it.** The August bill was assumed
to be more of the same AI credits; it contains **none** — it is 80% Actions. Two problems
with different shapes were sitting behind one symptom.

## 13b.2 Copilot code review — every PUSH, not every PR

`copilot-pull-request-reviewer[bot]` reviewed the same PR **twice**: once per pushed
commit. A PR with three commits is three full reviews of the whole diff.

- Setting: `Settings → Copilot → Copilot code review → **Automatic Copilot code review**`.
  It was unset ("Select an option"), so the default applied — **an unset control is still
  a decision, and it was making one nobody had chosen.**
- A `.github/copilot-code-review.yml` carrying `enabled: false` existed in `tec-app` and
  **GitHub does not read that filename**. Reviews ran anyway for months. A config file
  that nothing consumes is worse than none: it answers the question "is this off?" wrongly.
- **Now Disabled.** Manual review requests remain available and cost nothing unless used.

> Worth recording without defensiveness: the last review before it was disabled found a
> **real defect** — a guard test using `indexOf(a) < indexOf(b)`, which passes when `a` has
> been deleted (`-1` is less than every index). The tool was not wasting money on nothing.
> It was doing useful work at a price this platform's PR volume cannot carry.

## 13b.3 Actions — the cost is `npm install`, run four times per run

Measured on one real `Tec-Life` CI run (5 jobs, billed per job, rounded up):

```txt
Payment policy     1 min
Test               6 min    ← install 5:00,  test      4s
Lint               4 min    ← install 3:34,  lint      4s
Typecheck          2 min    ← install 1:38,  typecheck 7s
Build              3 min    ← install 1:39,  build    46s
─────────────────────────
TOTAL            ~16 min    of which ~12 min is npm install
                            and ~1 min is the actual work
```

**Each job checks out and installs from scratch, and `actions/setup-node` is configured
without `cache: 'npm'`.** Four parallel jobs means four full installs. July's ~10,255
minutes against a 3,000-minute allowance is that multiplied across 26 repositories.

### A hypothesis that measurement killed

The first proposed fix was a `concurrency` + `cancel-in-progress` guard — the Hub already
has one, and its own comment cites *"~15-min runs per commit"*. Applied to the fleet it
would have saved **nothing**:

```txt
Tec-Life: average run 3.4 min (most 2.2)
          gap between consecutive pushes 7–15 min
          → ZERO overlapping runs in the last 20
```

A run finishes long before the next push starts. **The Hub's fix is correct for the Hub
and pointless everywhere else, because the Hub's runs are five times longer.** Copying a
solution across the fleet without re-measuring the problem is the same drift this document
warns about in §13 — it just wears the shape of a best practice.

### The actual fix, ranked by risk

| Fix | 16 min → | Risk |
|-----|----------|------|
| `cache: 'npm'` on `setup-node` | ~6 min | none — one line per job, no check names change |
| Merge the 4 jobs into 1 (install once) | ~6 min | loses the separate check names branch protection may reference |
| Both | ~3 min | as above |

Projected: the cache alone takes July's ~10,255 min to roughly 4,000 → overage **$58 → ~$8**.
Both together land under the 3,000-minute allowance → **$0**. `tec-core-backend` has a
different shape (13 services) and **must be measured separately, not assumed**.

## 13b.4 Standing rules

```txt
✅ Read the INVOICE before naming a cause — the metered dashboard groups, the invoice itemises
✅ Measure the waste before shipping the fix — run/job timings are one API call away
✅ A cost control with "Stop usage" is a budget; a deleted budget is an unbounded one
✅ An unset toggle is a decision made by a default — set it explicitly
❌ Never copy one repo's CI fix to the fleet without re-measuring that repo's numbers
❌ Never trust a config file to disable a feature unless the vendor documents that filename
```

**Budget posture:** `All AI Credit SKUs` had a $5 budget with `Stop usage: Yes`; it was
deleted, and $19.62 accrued unbounded. Re-establish it. `Git LFS` sits at a $0 budget with
`Stop usage: Yes` — harmless today (LFS unused) and a hard block the day something needs it.

---

# 13c. NEW-A RE-CHECKED — THE GATEWAY URL DOES **NOT** REACH THE BROWSER (Sep 2026)

> **Truth State:** `[Current State]` · **Verification:** `[Runtime Verified]` — a real
> `next build` of `Tec-Explorer`, grepped, with the grep method validated first.
> **Verdict: not a violation.** Recorded so nobody re-opens this investigation.

Reading a CI file during the §13b work turned up what looked like a live **NEW-A** breach,
and the inference was wrong. The record is here because *the wrong answer was reasonable*,
so someone will reach it again.

## What it looked like

`src/lib/sdk.ts` — present in **14 repos** — carries a hardcoded fallback:

```ts
const gatewayUrl =
  process.env.NEXT_PUBLIC_API_GATEWAY_URL ??
  'https://api-gateway-production-6a68.up.railway.app';
```

and the import graph appears to put it in the browser:

```
usePiAuth.ts  (a hook — client)
  → lib-client/pi/pi-auth.ts        ← lib-client/ IS the client side, by our own convention
    → lib/sdk.ts                    ← NEXT_PUBLIC_* is inlined at BUILD time
```

Thirteen apps import `usePiAuth` in real `.tsx` components. On paper: an internal Railway
host shipped to every user's browser, in the app fleet, against a violation recorded as
**CLOSED**.

## What the build actually says

```
grep -rl "api-gateway-production-6a68" .next/static   →  0 files
grep -rl "api-gateway-production-6a68" .next/server   →  0 files
```

**And the method was validated before the result was trusted** — the same grep over the
same directory finds `tecosystem` (3 files), `hub.tecosystem` (3), `Explorer` (15). The
bundle is readable and the string genuinely is not in it.

**Why:** webpack drops the unused exports of `pi-auth`. The functions that touch `sdk`
(`resolveIncomplete`, `clearAuthToken`) are never imported by anything; the components
import only `loginWithPi`, `getStoredUser` and `logout`. So `lib/sdk.ts` never enters a
client chunk, and the literal is never inlined. (The six `railway` hits elsewhere under
`.next` are manifests and server-files — build metadata, not served.)

## What remains true, and is smaller

- **It is one refactor from becoming real.** Import any `sdk`-touching function from
  `pi-auth` tomorrow and the URL ships — silently, with no error and no failing test.
- The literal is still checked in: `src/lib/sdk.ts` in 14 repos, plus **21 CI workflow
  files** carrying it as a `secrets.… || '<railway host>'` fallback.

**Proportionate fix, when someone chooses to do it:** delete the fallback and let a missing
`API_GATEWAY_URL` fail loudly (P6). A silent default pointing at a production host is the
part that makes the hazard invisible. Not swept as part of §13b — the severity does not
justify a fleet-wide change, and see the rule below.

## 13c.1 The rule this pair of sections earns

Four times in one session an inference about this platform was confidently wrong, and each
time a measurement that took minutes settled it:

| Inference | Measurement |
|-----------|-------------|
| A `concurrency` guard will cut CI cost fleet-wide | Runs average 3.4 min, gaps 7–15 min — **zero** overlapping runs in the last 20 |
| The unpaid August invoice is more AI credits | The PDF contains **none** — 80% Actions |
| `tec-core-backend` needs the same npm cache | It already caches per service, and runs one job not four |
| The gateway URL ships to the browser | **0 occurrences** in `.next/static`, with the grep method validated |

```txt
✅ Build it and grep it — a bundle question is answered by a bundle, never by an import graph
✅ Validate the measurement before trusting its result (grep for something you KNOW is there)
✅ Record a NEGATIVE finding — an investigation that concluded "no" is a result worth keeping
❌ Never let a plausible import chain stand in for evidence about what ships
```

---

# 14. FUTURE: TEAM OPERATIONS MODEL

When team grows beyond solo:

```txt
Platform Team    → owns Tier 0/1 runtimes
Domain Teams     → own Tier 3 apps
SRE Function     → owns observability + incidents
Governance       → owns ADRs + contracts + reviews
```

**Not needed now. Designed for future.**

---

# FINAL STATEMENT

```txt
Operational confidence is a platform capability.
Reliability is governance.
A platform is mature when it can be operated
predictably under pressure.
```
