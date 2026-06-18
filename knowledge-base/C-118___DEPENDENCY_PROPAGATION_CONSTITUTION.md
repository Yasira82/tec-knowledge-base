# C-118 — DEPENDENCY PROPAGATION CONSTITUTION

> **Version:** v1.0
> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Implemented]`

---

## Purpose

Establish the Dependency Propagation Runtime (DPR) as a governed constitutional asset. The DPR automatically marks downstream documents as stale when an upstream document changes, closing the "Dependency Propagation Runtime" gap identified in the v3.6.1 evaluation.

**C-116 defines:** *how authority is validated* (AHV engine + CDG manifest).
**C-117 defines:** *how the registry is generated and kept in sync*.
**C-118 defines:** *how changes propagate through the dependency graph* — when C-93 changes, C-95 and C-99 are automatically flagged for re-review.

---

## Constitutional Question

When document A changes, how does TEC guarantee that every document B (where B depends_on A) is reviewed and re-verified?

---

## Core Constitutional Principle

```
A change without propagation = silent drift.

When A changes:
  - All B where B.depends_on ⊇ {A} MUST be flagged stale
  - All C where C.depends_on ⊇ {B} MUST be flagged stale (transitive)
  - The flag MUST be visible in CI before merge
  - The flag MUST be cleared by explicit re-verification

Manual propagation = guaranteed drift.
Automated propagation = guaranteed visibility.
```

### Iron Rules

```
1. Every change to a C-document triggers propagation
2. Propagation is transitive (closure over depends_on)
3. Stale flags block CI until cleared
4. Re-verification requires explicit `last_verified` update
5. Propagation history is logged for audit
```

---

## Constitutional Assets

### 1. Dependency Propagation Engine

**Path:** `scripts/propagate-dependency.py`

Reads `architecture/asset-registry.yaml` + a target document ID, computes the transitive closure of downstream dependents, and outputs:
- Direct dependents (must re-review immediately)
- Transitive dependents (review if change is non-trivial)
- Suggested stale-flag list (for CI)
- Review priority (ranked by tier + depth)

**Usage:**
```bash
# Before editing C-67, see what will be affected
python3 scripts/propagate-dependency.py C-67

# After editing C-67, mark downstream docs as stale
python3 scripts/propagate-dependency.py C-67 --mark-stale

# Output JSON for CI integration
python3 scripts/propagate-dependency.py C-67 --format json
```

### 2. Stale Flag in Asset Registry

The asset registry (per C-117) gains a new optional field:

```yaml
- id: C-95
  # ... existing fields ...
  stale_flags:
    - source: C-93
      detected: 2026-06-18
      reason: "C-93 changed; C-95 depends_on C-93"
      requires_reverification: true
```

When `stale_flags` is non-empty:
- `check-registry-integrity.sh` reports the doc as stale
- `check-vam-compliance.sh` requires re-verification before merge
- The doc's `verification_state` is effectively downgraded to `unverified` until cleared

### 3. CI Gate (Future — Phase B3)

**Path:** `evals/check-dependency-propagation.sh`

Runs on every PR that modifies a C-document. Computes propagation, verifies stale flags are set on downstream docs, fails CI if any downstream doc lacks a stale flag.

---

## Propagation Algorithm

```python
def propagate_change(target_id, registry):
    """Compute transitive closure of downstream dependents."""
    # Build reverse index: who depends_on X?
    reverse = defaultdict(list)
    for asset in registry.assets:
        for dep in asset.depends_on:
            reverse[dep].append(asset.id)

    # BFS from target_id
    affected = {}  # cid → depth
    queue = [(target_id, 0)]
    while queue:
        current, depth = queue.pop(0)
        for dependent in reverse.get(current, []):
            if dependent not in affected or affected[dependent] > depth + 1:
                affected[dependent] = depth + 1
                queue.append((dependent, depth + 1))

    return affected  # {C-95: 1, C-99: 2, ...}
```

---

## Worked Example

**Scenario:** C-93 (Institutional Verification Constitution) is updated.

**Propagation:**
```
C-93 changes
  ↓
Direct dependents (depth 1):
  - C-94 (Governed Capability Constitution)
  - C-95 (Institutional Knowledge Constitution)
  - C-99 (Institutional Governance Constitution)
  - C-02 (Current State — references C-93)
  ↓
Transitive dependents (depth 2+):
  - C-96 (depends on C-92 which depends on C-78 which depends on C-93)
  - C-97 (depends on C-92)
  - C-98 (depends on C-92)
  ↓
Total: 7 documents flagged stale
```

**CI behavior:**
- PR modifies C-93 → CI runs `check-dependency-propagation.sh`
- 7 downstream docs are flagged stale
- PR cannot merge until each stale doc has `last_verified` updated (or stale flag explicitly cleared with ADR)

---

## Relationship to Other Constitutions

```
C-00  Platform Constitution
  ↓
C-67  Source of Truth Matrix
  ↓
C-93  Institutional Verification Constitution
  ↓
C-116 Authority Automation Constitution (AHV engine)
  ↓
C-117 Registry Integrity Constitution (auto-generated registry)
  ↓
C-118 Dependency Propagation Constitution  ← THIS DOCUMENT
       (change propagation runtime)
```

C-118 is the **propagation layer** for C-117. Without C-118, C-117's registry is a snapshot — it knows the current state but not the change consequences. With C-118, every change is automatically traced to its blast radius.

---

## Lifecycle Phases

| Phase | Status | Scope |
|-------|--------|-------|
| Phase 1 (v3.6.2) | ✅ Delivered | `propagate-dependency.py` script + propagation algorithm + worked examples in this constitution |
| Phase 2 (Weeks 6–7) | Planned | `stale_flags` field in asset-registry.yaml + `check-dependency-propagation.sh` CI gate |
| Phase 3 (Weeks 8–9) | Planned | Pre-commit hook: auto-run propagation on every C-doc edit, auto-set stale flags |
| Phase 4 (Weeks 10–12) | Planned | GitHub Code Scanning integration: stale flags appear as PR review comments |

---

## Success Metrics

| Metric | v3.6.1 baseline | v3.6.2 (Phase 1) | Phase 4 target |
|--------|-----------------|-------------------|----------------|
| Time-to-detect downstream impact | Manual (hours) | < 5 seconds (script) | < 5 seconds (CI) |
| Stale flag coverage | 0% (no flags) | Algorithm ready | 100% on every PR |
| Silent drift incidents | Unknown (undetectable) | Detectable | 0 |
| Re-verification audit trail | None | None | Full history |

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | June 2026 (Session 12.2) | Initial constitution. propagate-dependency.py script + algorithm + worked examples. |

---

## Related Documents

```
C-00  — Platform Constitution
C-67  — Source of Truth Matrix
C-93  — Institutional Verification Constitution
C-116 — Authority Automation Constitution
C-117 — Registry Integrity Constitution
scripts/propagate-dependency.py        — Propagation engine
scripts/build-asset-registry.py        — Registry generator (C-117)
scripts/regenerate-cdg.py              — CDG regenerator
```

---

*C-118 v1.0 — June 2026 (Session 12.2) · Authority: CEO + Platform Governance Layer · Truth State: [Current State]*
