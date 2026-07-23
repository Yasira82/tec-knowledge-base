# Registry Integrity Report

> **Generated:** 2026-07-23T16:23:23.745898
> **Registry:** `/home/user/tec-knowledge-base/architecture/asset-registry.yaml`
> **Rules:** `/home/user/tec-knowledge-base/architecture/registry-integrity-rules.yaml`
> **Status:** ✅ CLEAN

## Summary

| Metric | Count |
|--------|-------|
| Total assets in registry | 114 |
| Total C-docs on disk | 114 |
| Coverage | 100.0% |
| Errors | 0 |
| Warnings | 0 |
| Info | 61 |

## Per-Tier Breakdown

| Tier | Assets | Errors | Warnings |
|------|--------|--------|----------|
| tier-0-foundational | 4 | 0 | 0 |
| tier-1-constitutional-runtime | 61 | 0 | 0 |
| tier-1-institutional-intelligence | 45 | 0 | 0 |
| tier-2-experimental | 4 | 0 | 0 |

## Coverage Report (R-COVERAGE)

- Files on disk: 114
- Files registered: 114
- Coverage: 100.0%
- Missing from registry: 0 ✅
- Orphan registry entries: 0 ✅

## Semantic Drift Report (R-SEMANTIC)

- Semantic errors: 0
- Semantic warnings: 0

## Errors (must fix)

_No errors._ ✅

## Warnings (should fix)

_No warnings._ ✅

## Recommended Actions

1. Registry is clean and complete. Run `python3 scripts/registry-impact-analysis.py C-XX` for change analysis.
