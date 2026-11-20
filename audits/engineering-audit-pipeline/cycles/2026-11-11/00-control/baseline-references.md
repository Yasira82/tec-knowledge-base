# Baseline references — cycle 2026-11-11

What the code is compared with. Authority order (CLAUDE.md): C-00 → C-67 → ADRs (C-64) →
current-state docs → runtime evidence → code. Each was confirmed to exist on `main`.

| Area | Reference | Used by |
|---|---|---|
| Constitution | C-00 v3.0 · C-47 Kernel Spec & Architecture Binding (§12 enforcement map, invariants, forbidden behaviours) | P1 every check |
| Identity of the apps | C-01 (Pi App IDs) · `architecture/app-fleet.yaml` (the list of apps) | P0 |
| Current state | C-02 | P0 |
| Repository map | C-11 (**generated**) — stale on 11 Nov, TEC-AUDIT-0009 | P0, P10 |
| Payments | C-12 Dual-Mode Payment · C-76 ADR-007 · ADR-004 Outbox · ADR-009 unified contract | P1 C16/C18/C20 |
| Auth & cookies | C-13 · C-123 Pi Browser session & cookie law · ADR-001 · ADR-002 | P1 C01/C02/C13 |
| Backend services & ports | C-20 — all 20 services (TEC-AUDIT-0017 was raised in error and closed) | P0, P5 |
| Environment variables | C-44 (**generated**) — stale, TEC-AUDIT-0009 | P8 |
| Decisions | C-64 ADR system (ADR-001 … ADR-011) | P1 |
| Ownership | C-68 Domain Ownership Matrix | P1 C21, P10 |
| Events | C-70 · `manifests/events-catalog.yaml` | P5 |
| Money | C-71 Financial Integrity Spec | P1 C06, P4 |
| Release | C-75 | P8 |
| Operations / SLOs | C-78 · `manifests/` SLO definitions | P8 |
| Design tokens | C-83 | P2 |
| Previous review | `audits/ENGINEERING_REVIEW_2026-11-11.md` — its 8 findings carried as TEC-AUDIT-0001…0008 | registry |

**Unavailable:** none. **Inconsistent at Run 1, resolved after it:** the type of a Pi amount
in an API (ADR-009 vs C-71 vs the backend CLAUDE.md) — TEC-AUDIT-0016, now one rule in C-71 §3.
