# Registry Integrity Report

> **Generated:** 2026-07-17T19:44:25.658945
> **Registry:** `/workspace/architecture/asset-registry.yaml`
> **Rules:** `/workspace/architecture/registry-integrity-rules.yaml`
> **Status:** ✅ CLEAN

## Summary

| Metric | Count |
|--------|-------|
| Total assets in registry | 113 |
| Total C-docs on disk | 113 |
| Coverage | 100.0% |
| Errors | 0 |
| Warnings | 0 |
| Info | 60 |

## Per-Tier Breakdown

| Tier | Assets | Errors | Warnings |
|------|--------|--------|----------|
| tier-0-foundational | 4 | 0 | 0 |
| tier-1-constitutional-runtime | 60 | 0 | 0 |
| tier-1-institutional-intelligence | 45 | 0 | 0 |
| tier-2-experimental | 4 | 0 | 0 |

## Coverage Report (R-COVERAGE)

- Files on disk: 113
- Files registered: 113
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
