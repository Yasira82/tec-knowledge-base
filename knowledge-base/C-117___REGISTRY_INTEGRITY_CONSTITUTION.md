# C-117 — REGISTRY INTEGRITY CONSTITUTION

> **Version:** v1.0
> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Approved]`

---

## Purpose

Establish the Asset Registry as a governed constitutional asset, with auto-generation, semantic validation, and coverage enforcement. This constitution closes the gap exposed in v3.4.0 (audit report) and v3.5.0 (Authority Automation): the registry is the bridge between human-readable documentation and machine-enforceable authority.

**C-67 defines:** *which document wins* when conflicts arise.
**C-116 defines:** *how authority is validated* (AHV engine + CDG manifest).
**C-117 defines:** *how the registry itself is generated, validated, and kept in sync with the files it describes.*

---

## Constitutional Question

How does TEC guarantee that its asset registry accurately describes the actual files in the knowledge base, rather than drifting into a parallel fiction?

---

## Core Constitutional Principle

```
A registry that drifts from its files is worse than no registry.
No registry is honest absence.
A drifting registry is institutional lying.

Auto-generation eliminates drift.
Semantic validation detects residual drift.
Coverage enforcement guarantees completeness.
```

### Iron Rules

```
1. The registry MUST be auto-generated from file headers
2. Semantic accuracy MUST be enforced (R-SEMANTIC-001)
3. Coverage MUST be 100% (R-COVERAGE-001)
4. Any drift MUST fail CI before it ships
5. Manual edits to the registry are FORBIDDEN
```

---

## Constitutional Assets

This constitution governs three assets:

### 1. Asset Registry (auto-generated)

**Path:** `architecture/asset-registry.yaml`

A machine-readable manifest of every C-document, declaring:
- `id`, `type`, `tier`, `institutional_role`
- `path` — relative path to source file
- `constitutional.truth_state`, `governance_state`, `verification_state`, `authority_scope`
- `owner`, `authoritative_for`
- `depends_on`, `supersedes`, `superseded_by`
- `last_verified`, `next_review`

**Generator:** `scripts/build-asset-registry.py`

**Coverage requirement:** 100% of C-docs in `knowledge-base/` MUST have an entry. v1.0 covered 18/96 (19%); v2.0 requires 96/96 (100%).

### 2. Registry Integrity Rules

**Path:** `architecture/registry-integrity-rules.yaml`

Defines 28 rules across 7 categories:
- **Schema Rules (R-SCHEMA-001 to 007):** structural field validation
- **Semantic Rules (R-SEMANTIC-001 to 002):** institutional_role vs file H1 overlap; authoritative_for claims vs file content
- **Structural Rules (R-STRUCT-001 to 006):** graph integrity (cycles, orphans, tier isolation, supersession symmetry)
- **Governance Rules (R-GOV-001 to 010):** constitutional consistency (owner, authority, tier-truth compatibility)
- **Lifecycle Rules (R-LIFE-001 to 003):** truth_state transition validation
- **Audit Rules (R-AUDIT-001 to 003):** last_verified + next_review enforcement
- **Coverage Rules (R-COVERAGE-001 to 002):** 100% coverage, no orphan entries

### 3. Registry Integrity Engine

**Path:** `evals/check-registry-integrity.sh`

A bash + Python validator that reads the registry + rules and produces:
- `architecture/registry-integrity-report.md` (human-readable)
- `architecture/registry-integrity-report.json` (machine-readable, optional)
- Console summary with coverage %, errors, warnings

**Exit codes:** 0 = clean, 1 = violations found (CI blocks)

---

## Tier System (v2.0)

The 4-tier system replaces the ad-hoc authority_rank of CDG v1.0:

| Tier | Truth States Allowed | Authority Scope | Examples |
|------|---------------------|-----------------|----------|
| `tier-0-foundational` | current-state only | constitutional | C-00, C-47, C-64, C-67 |
| `tier-1-constitutional-runtime` | current, future, planned | platform, constitutional, domain, app, service | C-02, C-10, C-12, C-76, C-100-C-115 |
| `tier-1-institutional-intelligence` | current, future, planned, speculation | platform, constitutional, app | C-83, C-93, C-94, C-95 |
| `tier-2-experimental` | speculation, future, idea only | experimental only | C-86, C-94-v1, C-95-v1 |

Per R-GOV-008, truth_state MUST be compatible with tier. Per R-GOV-009/010, authority_scope MUST be compatible with tier.

---

## Semantic Integrity (NEW in v2.0)

### The v1.0 Failure

The v1.0 registry (manual) had 3 of 18 entries (17%) with `institutional_role` that did NOT match the actual file:
- C-93 labeled "Privacy, Legal & Regulatory Compliance" but file is "Institutional Verification Constitution"
- C-94 labeled "Disaster Recovery & Business Continuity" but file is "Governed Capability Constitution"
- C-95 labeled "Platform Metrics & Reality Dashboard" but file is "Institutional Knowledge Constitution"

The v1.0 integrity engine reported "✅ CLEAN" because it validated the registry against itself — not against the files.

### The v2.0 Fix

**R-SEMANTIC-001** (severity: error): the `institutional_role` field MUST share at least 2 significant words with the actual file's first H1 heading. Stop words excluded.

**R-SEMANTIC-002** (severity: warning): every value in `authoritative_for` SHOULD appear (case-insensitive) in the first 100 lines of the file. Minimum 50% match ratio.

**Auto-generation:** `scripts/build-asset-registry.py` reads file H1 headers and generates the registry from them. Manual edits are forbidden — the file is regenerated on every commit.

---

## Coverage Enforcement (NEW in v2.0)

### R-COVERAGE-001 (severity: error)

Every C-NN.md file in `knowledge-base/` MUST have a corresponding entry in `asset-registry.yaml`. v1.0 covered 18/96 (19%); v2.0 requires 96/96 (100%).

**Implementation:** the integrity engine scans `knowledge-base/` and reports any file not in the registry.

### R-COVERAGE-002 (severity: warning)

Every entry in the registry MUST have a corresponding file in `knowledge-base/`. Caught by R-SCHEMA-006 (path exists) but separately reported for clarity.

---

## CI Integration

```yaml
# .github/workflows/knowledge-ci.yml
check-registry-integrity:
  name: Registry Integrity Check
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Setup Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    - name: Install PyYAML
      run: pip install pyyaml
    - name: Regenerate registry
      run: python3 scripts/build-asset-registry.py
    - name: Verify no manual edits to registry
      run: git diff --exit-code architecture/asset-registry.yaml
    - name: Run Registry Integrity Engine
      run: bash evals/check-registry-integrity.sh
```

**Workflow:**
1. PR opened
2. CI regenerates `asset-registry.yaml` from file headers
3. CI verifies no manual edits (git diff must be clean after regeneration)
4. CI runs `check-registry-integrity.sh`
5. If any of: schema errors, semantic drift, coverage < 100%, or cycle detected → CI fails

---

## Workflow for Editing a C-Document

```bash
# 1. Before editing, analyze the blast radius
python3 scripts/registry-impact-analysis.py C-XX

# 2. Make your edit to the C-NN.md file (update H1, Truth State, etc.)

# 3. Regenerate the registry
python3 scripts/build-asset-registry.py

# 4. Run all CI checks
bash evals/check-registry-integrity.sh
bash evals/check-truth-framework.sh
bash evals/check-c57-index.sh
# ... other CI checks

# 5. Commit (registry changes auto-included)
git add knowledge-base/C-XX.md architecture/asset-registry.yaml
git commit -m "docs(C-XX): <your change>"
```

---

## Lifecycle Phases

| Phase | Status | Scope |
|-------|--------|-------|
| Phase 1 (v3.6.0) | ✅ Delivered | Auto-generation + semantic rules + coverage + CI integration |
| Phase 2 (Weeks 3–5) | Planned | Resolve 30 errors detected by Phase 1 (cycles, tier mismatches) |
| Phase 3 (Weeks 6–8) | Planned | Add lifecycle transition enforcement (R-LIFE-001 history tracking) |
| Phase 4 (Weeks 9–12) | Planned | Pre-commit hook + GitHub Code Scanning SARIF integration |

---

## Success Metrics

| Metric | v3.4.0 baseline | v3.5.0 (Authority Automation) | v3.6.0 (Registry Integrity) | Phase 2 target |
|--------|----------------|-------------------------------|------------------------------|----------------|
| Registry coverage | 19% (18/96) | n/a | 100% (96/96) | 100% (maintained) |
| Semantic errors | undetectable | n/a | 6 detected | 0 |
| Coverage errors | undetectable | n/a | 0 | 0 |
| Cycle errors | undetectable | n/a | 24 detected | 0 |
| Tier-truth mismatches | undetectable | n/a | 2 detected | 0 |
| Total errors | undetectable | n/a | 30 | 0 |
| Time-to-detect drift | days | minutes (CDG) | minutes (auto-gen + R-SEMANTIC) | < 1 minute |

---

## Open Questions (Deferred to Phase 2)

1. **Should `institutional_role` be a free-text string or a controlled vocabulary?** Currently free-text with fuzzy match. Phase 2 may introduce a controlled vocabulary.
2. **Should ADRs (ADR-001 to ADR-008) be first-class registry entries or remain under C-64?** Currently they are sub-entries of C-64. Promoting them would simplify impact analysis.
3. **Should the registry support multi-language institutional_role?** Currently English-only. Phase 3 may add Arabic aliases for internal docs.
4. **Should lifecycle transitions require ADR approval?** Currently R-LIFE-001 validates the transition shape but not the governance approval. Phase 3 may require an ADR for `current-state → planned-state` (regression).

---

## Relationship to Other Constitutions

```
C-00  Platform Constitution (Authority Base)
  ↓
C-67  Source of Truth Matrix (Hierarchy Definition)
  ↓
C-93  Institutional Verification Constitution (Verification Theory)
  ↓
C-94  Governed Capability Constitution (Capability Theory)
  ↓
C-95  Institutional Knowledge Constitution (Knowledge Theory)
  ↓
C-116 Authority Automation Constitution (AHV Engine)
  ↓
C-117 Registry Integrity Constitution  ← THIS DOCUMENT
       (Auto-generated, semantically-validated registry)
```

C-117 is the **registry layer** for C-116. Without C-117, C-116's CDG manifest would have to be maintained manually, reintroducing drift. With C-117, the registry is auto-generated and drift-proof.

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | June 2026 (Session 12) | Initial constitution. Auto-generation + R-SEMANTIC + R-COVERAGE + CI integration. |

---

## Related Documents

```
C-00  — Platform Constitution
C-67  — Source of Truth Matrix
C-93  — Institutional Verification Constitution
C-94  — Governed Capability Constitution
C-95  — Institutional Knowledge Constitution
C-116 — Authority Automation Constitution
architecture/asset-registry.yaml          — Auto-generated registry
architecture/registry-integrity-rules.yaml — 28 rules across 7 categories
scripts/build-asset-registry.py            — Auto-generator
scripts/registry-impact-analysis.py        — Blast radius calculator
evals/check-registry-integrity.sh          — CI engine
```

---

*C-117 v1.0 — June 2026 (Session 12) · Authority: CEO + Platform Governance Layer · Truth State: [Current State]*
