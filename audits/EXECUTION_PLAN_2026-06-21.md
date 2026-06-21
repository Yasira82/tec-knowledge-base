# TEC Platform — Execution Plan

> **Date:** 2026-06-21 · **Truth State:** `[Planned State]` · **Governance State:** `[Governance Approved]`
> **Derived from:** `audits/UNIFIED_ENGINEERING_REPORT_2026-06-21.md` (§6 roadmap + §7 backlog)
> **Purpose:** the concrete, sequenced "what we do next" — with owner split (engineering vs ops).

Legend: 🧑‍💻 = engineering (executable in-repo) · 🛠️ = ops/infra (platform operator) · ✅ done · ▶️ next

---

## NOW — Submit + cheap high-value cleanup

### 🛠️ Ops — Pi Portal submission (no engineering blocker remains)
```
□ Run the smoke test (deliverables/SMOKE_TEST_VIDEO_SCRIPT) on each app
□ Submit all 4 apps: Hub · Ecommerce · Commerce · Assets
  (Assets App ID resolved: assets-app-af2fb490e7b03db7)
```

### 🧑‍💻 Batch 1 — Truth Reconciliation (~1 hr · one clean KB PR) ▶️
```
1. Fix C-77 + C-91 stale figures (7.0-7.5 / 7.25 → 9.0-9.2, P1=0)  → stops AHV truth-inversions
2. Reconcile v9 zip → repo:
     - Assets Pi App ID  → assets-app-af2fb490e7b03db7 (PORTAL runbook + C-01)
     - Commerce domain   → commerce.tecosystem.app (C-01, C-101)
     - import deliverables/ (PHASE_B2 PRD · Template v2 · smoke-test · doc-fix patch)
3. C-90 Security & Trust Model: [Draft] → [Governance Approved]
4. Scope-boundary note for the C-84 / C-85 / C-96 overlap
```

---

## NEXT — Runtime Governance Layer (the #1 gap, unanimous across all reviews)

### 🧑‍💻 Build in-repo (no infra required)
```
5. ✅ Portal Readiness Engine — evals/check-portal-readiness.sh (11th CI gate, v3.7.0).
                              Asserts App ID/domain consistency (C-01↔C-02↔RUNBOOK),
                              no placeholders, PI_SANDBOX=false, Privacy/Terms present,
                              no open ENG/OPS checklist items, no stale Commerce domain.
6. Drift Detection gate     — CI asserting C-doc claims vs live code  ▶️ NEXT
                              (start: route-level CSRF, ADR-009 contract, amount:number)
7. C-96 dual-poller fix     — unify health polling (BackendOfflineBanner + BackendStatus)
8. Runtime Evidence schema  — manifest/contract for metrics+incidents → KB
```

### 🛠️ Ops — Observability stack
```
□ Prometheus + SLOs + alerts + health dashboard
  (engineering provides the SLO definitions + evidence schema; ops stands up the stack)
□ Wire the 5 PHS (Platform Health) dimensions → composite endpoint
```

---

## LATER — Hardening → Expansion

### 🧑‍💻 Engineering
```
9.  Template v2 (deliverables/TEMPLATE_V2_DESIGN): health endpoint · Pino · Sentry
    pre-config · PAL stub · feature-flag hook · coverage gate
10. Publish tec-auth v1.1.0 → bump 4 apps + template to ^1.1.0 → migrate apps'
    inline middleware → package middleware (DRY) [AFTER publish, never before]
11. Promote npm-audit advisory → blocking (after residual majors handled)
12. Chaos + DR testing · incident automation · realtime-service coverage
13. Build-Next apps on Template v2: DX · AI · Analytics · SYSTEM
```

### Gate before 24-app scale
```
□ Independent external security audit ≥ 9.5 (real third-party — not self-review)
  before mainnet-scale of Future-Vision apps (Explorer · Nexus · FundX · Estate · …)
```

---

## Optimal sequence

```
Submit (ops)  ‖  Batch 1 (eng — now)
        ↓
Runtime Governance: Portal-Readiness + Drift engines + dual-poller (eng)
        ↓
Observability stack (ops infra)  +  Template v2 (eng)
        ↓
tec-auth v1.1.0 publish + middleware migration (eng)
        ↓
Expansion — Build-Next apps (eng)
```

---

## App maturity tracks (expansion reference)

| Track | Apps |
|-------|------|
| Production-Ready | Hub · Commerce · Assets · Ecommerce |
| Build-Next | AI · Analytics · DX · SYSTEM |
| Future Vision (post external-audit ≥ 9.5) | Life · Connection · Explorer · Nexus · ALERT · NX · FundX · Estate |

---

## Recommended first move
**Batch 1** — cheapest, highest-value, and it stops the stale-figure / AHV truth-inversions. One clean KB PR. Then proceed to the Runtime Governance engines (Portal Readiness + Drift Detection) which directly attack the unanimous #1 gap.
