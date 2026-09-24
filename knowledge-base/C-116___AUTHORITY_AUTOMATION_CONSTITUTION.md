# C-116 — AUTHORITY AUTOMATION CONSTITUTION

> **Version:** v1.1 — §1.3 amended 2026-09-24 (one impact engine)
> **Truth State:** `[Planned State]`
> **Governance State:** `[Draft]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Recommended]`
> **Commitment Level:** `[Exploratory]`

---

## Purpose

Define how TEC transforms its authority model from a *documented hierarchy* into an *enforced runtime*. Without this constitution, the Authority Hierarchy declared in C-67 is aspirational — it relies on human discipline to resolve conflicts. With this constitution, authority violations are detected automatically by CI before they ship.

**C-67 defines:** *which document wins* when two documents disagree.
**C-116 defines:** *how that resolution is enforced automatically*.

---

## Constitutional Question

How does TEC guarantee that its authority hierarchy is actually obeyed, rather than merely declared?

---

## Core Constitutional Principle

```
Documented Authority  ≠  Enforced Authority

Documented Authority is a claim.
Enforced Authority is a contract.

The gap between them is institutional risk.
```

### Iron Rules

```
1. Every cross-document reference MUST be machine-resolvable
2. Every authority claim MUST be verifiable from a manifest
3. Every drift MUST fail CI before it ships
4. Every enforcement rule MUST itself be governed
```

---

## Constitutional Rules

```
Authority without Detection       = Aspiration
Detection without Enforcement     = Theatre
Enforcement without Governance    = Tyranny
Governance without Automation     = Inconsistency
Manifest without Engine           = Dead Documentation
Engine without Manifest           = Untestable Logic
```

---

## 1. Constitutional Assets

This constitution creates three governed assets:

### 1.1 Constitutional Dependency Graph (CDG)

**Asset:** `manifests/dependency-graph.yaml`

A machine-readable manifest of every C-document and ADR, declaring:
- `id`, `title`, `filename`
- `tier` (1–11, per C-57 grouping)
- `authority_rank` (0–100, per C-67 hierarchy)
- `truth_state`, `governance_state`, `verification_state`, `authority_scope`
- `depends_on` — references this document inherits authority from
- `informs` — references this document pushes authority to
- `adr_refs` — ADRs cited in this document

**Owner:** Platform Governance. Updates require a PR with `governance` label.

### 1.2 Authority Hierarchy Validation (AHV) Engine

**Asset:** `scripts/ahv_engine.py`

A Python program that reads the CDG manifest and enforces six violation classes:

| Code | Severity | Rule |
|------|----------|------|
| V1_AUTHORITY_INVERSION | error | Low-authority doc cannot depend on lower-authority doc |
| V2_TRUTH_STATE_INVERSION | error | `[Current State]` doc cannot depend on `[Planned]`/`[Future Vision]` doc |
| V3_ORPHAN_REF | warning | `informs` target must exist |
| V3_BROKEN_BIDI | info | `informs` should be acknowledged in target's `depends_on` |
| V4_MISSING_GOVERNANCE_STATE | warning | Truth State without Governance State (or vice versa) |
| V5_CONSTITUTIONAL_MISSING_TRUTH | error | `authority_rank ≥ 85` MUST declare Truth State |
| V6_CYCLE_DETECTED | error | `depends_on` graph must be acyclic |

**Output formats:** `text` (human), `json` (machine), `sarif` (GitHub Code Scanning).

### 1.3 Impact Analysis Engine

**Asset:** `scripts/registry-impact-analysis.py`

Reads the asset registry (`architecture/asset-registry.yaml`, generated per C-117) and
computes the blast radius of a document change:
- Direct dependents (must review immediately)
- Transitive dependents (review if change is non-trivial)
- Affected ADRs
- Affected App Charters (C-100 → C-115, C-124 → C-131)
- Suggested review order (ranked by tier)

**Usage:** Before editing any C-document, run `registry-impact-analysis.py C-XX` to see who
will be affected.

> **Amendment v1.1 (2026-09-24, KB remediation step 6, audit F20).** This section named
> `scripts/impact_analysis.py`, which read the CDG manifest. A second engine,
> `registry-impact-analysis.py`, was added with C-117 and read the registry the CDG is
> generated from (C-118). Two engines for one question: checked on C-12, C-47 and C-123 they
> returned identical dependents, and the CDG's only extra relation, `informs`, is empty for
> all 116 documents. The registry engine is kept because it reads the source rather than a
> derivative, and because README, CONTRIBUTING, C-117 and the integrity report already point
> at it. `impact_analysis.py` is deleted.

---

## 2. Mandatory Truth State

The following documents MUST declare a Truth State header. CI fails the build if missing.

| Document | Why mandatory |
|----------|---------------|
| C-00 → C-02 | Constitutional layer — defines what is true |
| C-10 → C-19 | Architecture + Rules — defines what exists |
| C-20 → C-23 | Backend + Apps + SDK — defines what is built |
| C-47 | Kernel Spec — defines forbidden behaviors |
| C-64 | ADR registry — defines architectural decisions |
| C-67 | Source of Truth Matrix — defines authority hierarchy |
| C-93 → C-99 | Institutional Operating Loop — defines verification chain |

**CI rule:** `evals/check-truth-framework.sh` exits 1 if any of the above lacks Truth State + Governance State.

---

## 3. Drift Prevention

### 3.1 C-57 Index Drift

The C-57 Master Contents Index is the navigation gateway. Descriptions MUST match actual file titles.

**CI rule:** `evals/check-c57-index.sh` exits 1 if any C-57 description does not overlap with the corresponding file's first H1 heading.

**Recovery:** Run `python3 scripts/06_fix_c57.py` to auto-correct descriptions from file headers.

### 3.2 Manifest Drift

The CDG manifest MUST stay in sync with the actual files. Any new C-document MUST be added to `manifests/dependency-graph.yaml` in the same PR that introduces the file.

**CI rule:** `evals/check-authority-consistency.sh` exits 1 if the AHV engine finds violations, OR if any C-file referenced in the manifest does not exist on disk.

---

## 4. Runtime Enforcement Model

```
Developer authors change
  ↓
PR opened
  ↓
CI runs:
  1. validate-skills.sh         (frontmatter, size)
  2. validate-charters.sh       (charter structure)
  3. validate-structure.sh      (dirs + plugin.json)
  4. check-knowledge-gaps.sh    (required core docs exist)
  5. check-links.sh             (relative Markdown links resolve)
  6. check-truth-framework.sh   (BLOCKING on core docs)        ← NEW v3.5.0
  7. check-c57-index.sh         (BLOCKING on drift)            ← NEW v3.5.0
  8. check-authority-consistency.sh (BLOCKING on AHV violations) ← NEW v3.5.0
  ↓
All pass → mergeable
Any fail → blocked until fixed
```

---

## 5. Governance Hooks

### 5.1 Manifest Amendments

Changes to `manifests/dependency-graph.yaml` that affect:
- `authority_rank` of any document → require `governance` label + 1 reviewer
- `depends_on` of any constitutional document (rank ≥ 85) → require `governance` label + ADR amendment
- Truth State of C-00, C-47, C-67, C-93–C-99 → require formal Governance Charter amendment

### 5.2 Engine Updates

Changes to `scripts/ahv_engine.py` or `scripts/registry-impact-analysis.py` that:
- Add a new violation class → require ADR + governance approval
- Change severity of an existing violation → require ADR
- Remove a violation class → require formal deprecation ADR

---

## 6. Adoption Plan

| Phase | When | Scope | Exit Criteria |
|-------|------|-------|---------------|
| Phase 1 | Session 11 (now) | CDG manifest + AHV v1 + Impact Analysis v1 + 3 CI scripts | All scripts run; violations catalogued; non-blocking |
| Phase 2 | Sessions 12–14 | Resolve V1, V2, V5 violations (65 errors expected at Phase 1) | AHV runs clean on C-00→C-23 + constitutional docs |
| Phase 3 | Session 15+ | CI becomes fully blocking | Any new drift fails CI; cannot merge without resolution |
| Phase 4 | Post-Portal | SARIF integration with GitHub Code Scanning | Violations appear in PR review UI |

---

## 7. Relationship to Other Constitutions

```
C-00  Platform Constitution
  ↓ (defines highest authority)
C-67  Source of Truth Matrix
  ↓ (defines hierarchy)
C-116 Authority Automation Constitution  ← THIS DOCUMENT
  ↓ (enforces hierarchy via CI)
C-93  Institutional Verification Constitution
  ↓ (defines how reality becomes verified)
C-94  Governed Capability Constitution
  ↓ (defines how knowledge becomes capability)
```

C-116 is the **enforcement layer** for C-67. Without C-116, C-67 is a document. With C-116, C-67 is a runtime contract.

---

## 8. Success Metrics

| Metric | Phase 1 baseline | Phase 3 target |
|--------|-----------------|----------------|
| Truth Framework adoption | 79% (66/84) | 100% on core docs; ≥ 90% overall |
| AHV violations | 65 errors + 364 infos | 0 errors; infos < 100 |
| C-57 drift | 0 (after Session 11 fix) | 0 (maintained by CI) |
| Manifest sync | Manual | Automatic via pre-commit hook |
| Time-to-detect authority conflict | Days (manual review) | < 5 minutes (CI) |

---

## 9. Open Questions

1. **Should `informs` be strictly bidirectional?** Currently V3_BROKEN_BIDI is `info` severity. Should it become `warning` in Phase 2?
2. **Should ADRs have their own CDG entries?** Currently they are listed under `adrs:` separately. Merging them into `documents:` would simplify the engine.
3. **Should the AHV engine also check Truth State transitions?** (e.g., forbid `[Current State]` → `[Planned State]` without an ADR.)

These questions are deferred to Phase 2 review.

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | June 2026 (Session 11) | Initial constitution. CDG + AHV + Impact Analysis + 3 CI scripts. |

---

## Related Documents

```
C-00  — Platform Constitution (Authority Base)
C-67  — Source of Truth Matrix (Hierarchy Definition)
C-80  — Engineering Assessment Report (Gap Analysis)
C-93  — Institutional Verification Constitution
C-94  — Governed Capability Constitution
C-95  — Institutional Knowledge Constitution
C-99  — Institutional Governance Constitution (closes the loop)
```

---

*C-116 v1.0 — June 2026 · Authority: CEO + Platform Governance Layer · Truth State: [Planned State]*
