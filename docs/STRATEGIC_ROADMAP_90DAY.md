# TEC — 90-Day Strategic Roadmap (Q3 2026)

> **Version:** v1.0 — June 2026 (Session 12)
> **Authority:** C-77 Strategic Analysis + C-116 Authority Automation Constitution
> **Truth State:** `[Planned State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---

## Executive Summary

The next 90 days transform TEC's Knowledge Base from **Institutional Memory** into **Governed Institutional Runtime**. The strategic thesis: the project's real asset is not the apps, not the AI, not the commerce — it is the governed knowledge that makes 24 sovereign apps coherent. Protecting that asset requires enforcement, not just documentation.

Three parallel tracks run for 13 weeks:

```
Track A: Portal Readiness          (Weeks 1–4)   — unblocks revenue
Track B: Authority Automation       (Weeks 1–9)   — protects the asset
Track C: Runtime Hardening          (Weeks 5–13)  — closes the gap
```

Track A and Track B run in parallel for the first 4 weeks. Track C starts after Portal submission is unblocked.

---

## Strategic Anchors

### Anchor 1: Reliability > Expansion
No new apps until Portal submission + external audit ≥ 9.5. Period.

### Anchor 2: Governance > Velocity
Every PR passes 8 CI checks (3 new in v3.5.0). Velocity drops 10%, drift drops 90%.

### Anchor 3: Enforcement > Documentation
A documented rule without CI enforcement is aspirational. Phase 2 makes 3 rules blocking. Phase 3 makes all 8 blocking.

### Anchor 4: Institutional Memory > Feature Growth
The 96 C-documents are the moat. The AHV engine protects that moat. Apps are downstream of the moat, not upstream.

---

## Track A — Portal Readiness (Weeks 1–4)

**Goal:** Submit to Pi Network Developer Portal by end of Week 4.

| Week | Milestone | Deliverables | Exit Criteria |
|------|-----------|--------------|---------------|
| W1 | P0 fixes | Fix C-57 drift (done in Session 12) · Make `check-truth-framework.sh` blocking (done) · Update C-02 adoption figure to 79% (done) | All P0 audit recommendations closed |
| W2 | Hub hardening | Hub BFF routes use `API_GATEWAY_URL` (server-only) · tec-auth tests ≥ 60% · KYC flow end-to-end verified | NEW-A + NEW-D closed |
| W3 | Ecommerce + Commerce polish | Ecommerce UI upgrade · Commerce schema final review · All 4 apps coverage ≥ 60% | External pre-audit ≥ 8.5 |
| W4 | External audit + submission | External auditor review · Fix findings · Submit to Pi Developer Portal | Submission acknowledged |

**Track A Risk:** Pi Portal timeline slips if external audit findings are material. Mitigation: schedule audit at start of W3, not W4.

---

## Track B — Authority Automation (Weeks 1–9)

**Goal:** Convert C-67 (Source of Truth Matrix) from a document into a runtime contract.

### Phase B1 (Weeks 1–2) — Foundations ✅

| Deliverable | Status | Owner |
|-------------|--------|-------|
| `manifests/dependency-graph.yaml` (CDG) | ✅ Delivered Session 12 | Founder |
| `scripts/ahv_engine.py` v1 (6 violation classes) | ✅ Delivered Session 12 | Founder |
| `scripts/impact_analysis.py` v1 | ✅ Delivered Session 12 — retired 2026-09-24 for `registry-impact-analysis.py` (C-116 §1.3) | Founder |
| `evals/check-c57-index.sh` | ✅ Delivered Session 12 | Founder |
| `evals/check-authority-consistency.sh` | ✅ Delivered Session 12 | Founder |
| `C-116 Authority Automation Constitution` | ✅ Delivered Session 12 | Founder |

### Phase B2 (Weeks 3–5) — Resolve Existing Violations

The AHV engine currently detects **65 errors** (mostly V1_AUTHORITY_INVERSION). These are not bugs — they are real authority inconsistencies in the existing KB. Phase B2 resolves them.

| Violation Class | Count | Strategy |
|-----------------|-------|----------|
| V1_AUTHORITY_INVERSION | ~30 | Either: (a) demote the dependent doc's authority_rank, OR (b) move the reference from `depends_on` to `informs` |
| V2_TRUTH_STATE_INVERSION | ~5 | Demote the dependent's Truth State from `[Current State]` to `[Planned State]` |
| V5_CONSTITUTIONAL_MISSING_TRUTH | ~5 | Add Truth State headers to remaining constitutional docs |
| V6_CYCLE_DETECTED | 0 (expected) | None |

**Exit B2:** `python3 scripts/ahv_engine.py` returns 0 errors.

### Phase B3 (Weeks 6–7) — CI Becomes Fully Blocking

| CI Check | Phase B1 | Phase B2 | Phase B3 |
|----------|----------|----------|----------|
| validate-skills.sh | Blocking | Blocking | Blocking |
| validate-charters.sh | Blocking | Blocking | Blocking |
| validate-structure.sh | Blocking | Blocking | Blocking |
| check-knowledge-gaps.sh | Blocking | Blocking | Blocking |
| check-links.sh | Blocking | Blocking | Blocking |
| **check-truth-framework.sh** | **Blocking on C-00→C-23** (done) | Blocking on C-00→C-23 | **Fully blocking** |
| **check-c57-index.sh** | **Blocking** (done) | Blocking | Blocking |
| **check-authority-consistency.sh** | Informational | Informational | **Fully blocking** |

### Phase B4 (Weeks 8–9) — Developer Experience

- Pre-commit hook: runs AHV + Impact Analysis on every commit
- GitHub Action: SARIF output → PR review UI shows authority violations inline
- `telemetry.md`: log every CI run + violation to `memory/platform-snapshot.md`

**Exit B4:** Authority violations are detected in < 5 minutes; review burden on founder is < 30 min/day.

---

## Track C — Runtime Hardening (Weeks 5–13)

**Goal:** Close the gap between Institutional Thinking (9.8) and Runtime Enforcement (5.5 → 8.0).

### Phase C1 (Weeks 5–7) — Test Coverage

| Repo | Current | Target W7 | Owner |
|------|---------|-----------|-------|
| tec-auth | 95% (46 tests) | 95% (maintain) | Founder |
| tec-ui | 80% (75 tests) | 85% | Founder |
| Hub | 60% | 75% | Founder |
| Commerce | 60% | 75% | Founder |
| Assets | 50% | 70% | Founder |
| Ecommerce | 60% | 75% | Founder |
| Backend services | 60% avg | 75% avg | Founder |

### Phase C2 (Weeks 8–10) — Observability Build-Out

Per C-92 Platform Health Model (5 dimensions × state machine):
- Identity Health endpoint
- Payment Health endpoint (Mode 1 + Mode 2 + ADR-007)
- App Health endpoint (4 live apps)
- Service Health endpoint (12 Railway services)
- Event Bus Health endpoint (Redis Streams)
- Composite PHS (Platform Health Score) endpoint
- Health dashboard UI (Hub)

**Exit C2:** `GET /api/bff/health` returns composite PHS in < 500ms.

### Phase C3 (Weeks 11–13) — Resilience Testing

- Chaos test: kill each Railway service, verify PHS degrades gracefully
- Pi SDK circuit breaker test: simulate Pi API outage, verify CLOSED→OPEN→HALF_OPEN
- Mode 1 + Mode 2 payment retry test: simulate Pi callback failure
- Disaster recovery drill (per C-18): restore from backup, verify RPO/RTO

**Exit C3:** All chaos tests pass; PHS stays ≥ 7/10 during single-service outage.

---

## Cross-Track Dependencies

```
Track A (Portal)
  ↑
  │ depends on
  │
Track B (Authority) ──┐
  │                   │
  │ unblocks          │ telemetry feeds
  │                   │
Track C (Runtime) ←───┘
```

- **B1 unblocks A**: Truth Framework blocking on core docs is a Portal submission prerequisite.
- **C2 (Observability) enables B4 (DX)**: SARIF output needs CI to know which violations are blocking.
- **C3 (Resilience) feeds B (Authority)**: chaos test results become runtime evidence → C-93 Verification Constitution.

---

## Success Metrics

| Metric | Baseline (Session 12) | Target (Session 14, Wk 13) |
|--------|----------------------|----------------------------|
| Truth Framework adoption | 79% (66/84) | 100% core · 90% overall |
| AHV violations | 65 errors | 0 errors |
| C-57 drift | 0 (post-fix) | 0 (CI-enforced) |
| Test coverage (avg) | ~60% | 75%+ |
| Observability dimensions live | 0 of 5 | 5 of 5 |
| Platform Health Score (PHS) | N/A | Live, ≥ 8/10 |
| External audit score | 9.3 (code-verified) | 9.5+ (Portal-ready) |
| Pi Network Portal status | Not submitted | Submitted + under review |
| Time-to-detect authority conflict | Days | < 5 minutes |
| Founder daily review burden | N/A | < 30 min |

---

## Risk Register (90-Day Horizon)

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-90-1 | Pi Portal timeline slips | M | H | Start external audit W3, not W4 |
| R-90-2 | AHV engine over-engineered | M | M | v1 is naive; resist graph DB |
| R-90-3 | Solo developer burnout | M | H | Track B work is mechanical; pair with Track A creative work |
| R-90-4 | Track B resolves violations by demoting too many docs | L | M | Each demotion requires ADR |
| R-90-5 | Pi Network API change during Track C | L | H | Build PAL (Pi Abstraction Layer) starting W6 |
| R-90-6 | Observability build-out steals test coverage time | M | M | Hard cap: observability gets 50% of W8-10, tests get 50% |

---

## What We Explicitly Defer

The following are **out of scope** for the 90-day window:

1. **TEC AI app** (C-104) — defer to Q4 2026
2. **Explorer app** (C-108) — defer to Q4 2026
3. **FundX app** (C-113) — defer to Q1 2027
4. **Estate app** (C-114) — defer to Q1 2027
5. **PAL (Pi Abstraction Layer)** — start design W6, build in Q4
6. **Nexus strategic decision** (C-77 § 8) — defer to Q4 2026
7. **24-app expansion** — freeze until Portal approved + audit ≥ 9.5

**Why defer?** The strategic value of new apps is downstream of governed infrastructure. Building apps on un-governed infrastructure creates technical debt that compounds. The 90-day window invests in the foundation; Q4 2026 onwards harvests the foundation.

---

## Weekly Cadence

| Day | Activity | Time |
|-----|----------|------|
| Monday | Review AHV violations from previous week's PRs | 30 min |
| Tuesday | Track A: Portal readiness work | 4 hr |
| Wednesday | Track B: Authority automation work | 4 hr |
| Thursday | Track A or C (alternating) | 4 hr |
| Friday | Track C: Runtime hardening + chaos test | 4 hr |
| Saturday | Off | — |
| Sunday | Optional: long-form architecture writing (C-docs) | 2 hr |

**Weekly review:** Sunday evening, 30 min — update C-02 Current State, log session to C-50.

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | June 2026 (Session 12) | Initial 90-day roadmap. 3 tracks × 13 weeks. 10 success metrics. |

---

## Related Documents

```
C-00  — Platform Constitution
C-41  — Engineering Roadmap (Phase 0 → Phase 3)
C-77  — Strategic Analysis & Risk Assessment v5.0
C-80  — Engineering Assessment Report
C-91  — Engineering Roadmap to Scale
C-116 — Authority Automation Constitution  ← NEW
LANGUAGE_POLICY.md                          ← NEW
```
