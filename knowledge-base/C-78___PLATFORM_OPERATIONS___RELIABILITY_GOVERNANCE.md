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
