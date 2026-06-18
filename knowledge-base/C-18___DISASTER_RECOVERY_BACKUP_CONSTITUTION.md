# C-18 — DISASTER RECOVERY & BACKUP CONSTITUTION

**Version:** 1.0.0

**Truth State:** `[Planned State]`

**Governance State:** `[Draft]`

**Verification:** `[Documentation Verified]`

**Domain:** Operations | Engineering

**Related Documents:** C-00, C-16 (Database Rules), C-20 (Backend Services Map), C-43 (CI/CD), C-62 (SLO Definitions), C-71 (Financial Integrity), C-73 (Incident Response), C-74 (Scalability), C-78 (Operations), C-57 (Master Index)

---

## Purpose

This document defines how TEC backs up, restores, and recovers from partial or total loss of a
service, database, or region. For a platform that holds **wallets, ledgers, and payment state**,
the inability to restore data is an existential risk. C-73 (Incident Response) tells engineers
*how to react* during an incident; this constitution defines *what must already be in place* —
backup cadence, recovery objectives (RPO/RTO), restore drills, and failover order — so recovery
is possible at all.

## Scope

**Covered:** backup policy per data tier, RPO/RTO targets, restore procedures & drills,
service recovery ordering, failover, and continuity ownership.

**NOT covered:** live incident triage steps (C-73), rollback rules for a bad deploy (C-73 §8),
horizontal scaling/capacity (C-74), or SLO measurement mechanics (C-62).

---

## 1. Recovery Objectives (RPO / RTO)

- **RPO (Recovery Point Objective):** maximum acceptable data loss, measured in time.
- **RTO (Recovery Time Objective):** maximum acceptable time to restore service.

| Tier | Data / Service | RPO | RTO | Rationale |
|------|----------------|-----|-----|-----------|
| **T0 — Financial** | Wallet, Ledger, Payment DBs | **0 (no loss tolerated)** | ≤ 1h | Money correctness is non-negotiable (C-71) |
| **T1 — Identity/Auth** | Identity, Auth, KYC | ≤ 5 min | ≤ 2h | Blocks all logins/payments if down |
| **T2 — Core platform** | Gateway, Commerce, Notify, Realtime | ≤ 15 min | ≤ 4h | Degraded UX, recoverable |
| **T3 — Derived** | Analytics, projections, caches | Rebuildable | Best-effort | Reconstructable from source events (C-56) |

**Invariant:** T0 financial data has **RPO = 0** — it must be recoverable to the last committed
transaction. This drives the backup strategy in §2.

## 2. Backup Policy

| Data tier | Method | Frequency | Encryption | Geo |
|-----------|--------|-----------|------------|-----|
| T0 Financial | Continuous WAL/PITR + daily full snapshot | Continuous + daily | At rest (C-17 C4) | Multi-region copy |
| T1 Identity/KYC | PITR + daily snapshot | Continuous + daily | At rest (C-17 C4) | Multi-region copy |
| T2 Core | Daily snapshot | Daily | At rest | Off-host |
| T3 Derived | None (rebuild) | — | — | — |

**Rules:**
- Every backup is **encrypted at rest** and inherits the data class of its source (C-17).
- Backups are stored **off-host** from the primary (a Railway service loss must not lose its backup).
- Backup success/failure emits a monitored signal (C-45 Observability); a silent backup failure is a P1.
- **A backup that has never been test-restored does not count as a backup.**

## 3. Restore Procedure (per database)

```
1. Declare recovery scope (which service/DB, target point-in-time)
2. Provision clean target (do NOT overwrite the damaged primary until captured for forensics)
3. Restore latest full snapshot → replay WAL/PITR to target timestamp
4. Run integrity checks: row counts, ledger sum reconciliation (C-71 §11)
5. Re-point service via config; verify health endpoint + smoke test
6. Reconcile events that occurred during outage (C-56 Redis Streams replay)
7. Record restore in incident log (C-73 §11 postmortem)
```

**Financial restore rule:** after any T0 restore, a **full ledger reconciliation (C-71 §11)** MUST
pass before the wallet/payment service is returned to write traffic. Fail closed otherwise.

## 4. Service Recovery Ordering

Bring services back in dependency order to avoid cascading failures:

```
1. Datastores (per-service DBs, Redis)         ← foundation
2. Auth + Identity (:5001/:5004)               ← nothing works without identity
3. Wallet + Payment (:5002/:5003)              ← financial core (after reconciliation)
4. Gateway (:3000)                             ← entry point
5. Commerce/Asset/Notify/Realtime/Analytics    ← feature services
6. Apps (Hub → Commerce → Assets → Ecommerce)  ← frontends last
```

(Ports per C-20 Backend Services Map.)

## 5. Failover & Continuity

- **Regional copy:** T0/T1 backups are replicated to a second region so a single-region outage is survivable.
- **Degraded mode:** if a non-financial service (T2/T3) is down, the platform stays up in
  reduced-feature mode rather than failing globally (graceful degradation, C-74).
- **Continuity ownership:** the on-call owner (C-78) declares DR scope; financial reconciliation
  sign-off is required before T0 services resume writes.

## 6. DR Drills

- **Cadence:** restore drills are run on a recurring schedule (at minimum before each major release, C-75).
- **Scope:** at least one T0 financial restore + one full service-ordering drill per cycle.
- **Evidence:** each drill records measured RPO/RTO vs. target and any gap → tracked in C-40/C-49.
- A drill that does not meet its RTO/RPO target opens a P1 remediation item.

---

## Implementation Status

| Item | Status | Notes |
|------|--------|-------|
| Immutable financial ledger (recoverable source of truth) | ✅ Done | C-71 §10 |
| Reconciliation procedure defined | ✅ Done | C-71 §11 |
| Managed Postgres PITR per service | ⚠️ Partial | Verify enabled for all T0/T1 DBs (Railway) |
| Off-host + multi-region backup copies | ❌ Not Started | Needs infra config + verification |
| Scheduled restore drills + RPO/RTO evidence | ❌ Not Started | No drill record exists yet |
| Backup success/failure monitoring | ❌ Not Started | Wire into C-45 observability |

## Constraints & Invariants

- **I1:** T0 financial data has RPO = 0 (recoverable to last committed transaction).
- **I2:** A never-restored backup is not a valid backup (drills mandatory).
- **I3:** Backups are encrypted and stored off-host from the primary.
- **I4:** No T0 service resumes writes after restore until ledger reconciliation passes (Fail Closed).
- **I5:** Recovery follows the documented dependency order (§4).

## Open Questions

- [ ] Confirm PITR is enabled on every T0/T1 managed database today. (owner: Operations)
- [ ] Which second region for cross-region backup copies? (owner: Architecture)
- [ ] Target drill cadence — per release vs. monthly? (owner: Governance)

## Change Log

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | 2026-06-17 | Initial draft — RPO/RTO, backup policy, restore, drills | Cloud Agent Engineering |

## Cross-References

- **Upstream:** C-00 (Constitution), C-47 (Kernel constraints), C-64 (ADR system)
- **Downstream:** C-57 (master index — registered)
- **Related:** C-71 (financial reconciliation), C-73 (incident execution), C-74 (scalability), C-78 (operations), C-62 (SLO)
