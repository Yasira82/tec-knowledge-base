# TEC Engineering Audit Pipeline

> Truth State: **[Current State]** — the platform's official engineering review process
> (owner, 11 Nov 2026). Governance State: **[Governance Approved]** by the owner.
> Verification: **[Documentation Verified]** for the process itself; each run declares
> its own verification per finding.

A sequential, evidence-driven audit of every TEC repository. Each phase receives the
previous phase's results, verifies them, and does not hand over until its own conditions
are met. It exists to stop the shallow review — one pass over everything that misses what
sits *between* repositories — and to make sure no problem is lost from one repository,
phase or run to the next.

It replaces ad-hoc reviews such as `audits/ENGINEERING_REVIEW_2026-11-11.md` (6.8/10),
which is this pipeline's baseline: its findings are carried into the registry, not
re-discovered.

## 1. Phases

Strict order: **P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8 → P9 → P10 → P11.**
After P0 and P1, P2–P9 may run in parallel; P10 and P11 never start before all of them
have a terminal status.

| Phase | Name | What it establishes | Folder |
|---|---|---|---|
| P0 | Discovery & Repository Mapping | Every repository, application, service, package, database, integration, technology, deployment target and dependency | `01-discovery/` |
| P1 | Architecture & Baseline Compliance | The implementation compared with the canonical architecture; deviations registered | `02-architecture/` |
| P2 | Code Quality & Static Analysis | Types, errors, duplication, complexity, dead and incomplete code | `03-code-quality/` |
| P3 | Security & Privacy | Identity, authorization, isolation, input validation, secrets, data protection, dependency vulnerabilities | `04-security/` |
| P4 | Database & Data Integrity | Schemas, migrations, constraints, indexes, transactions, isolation, recovery readiness | `05-database/` |
| P5 | API & Integration Contracts | Gateway routing, SDK interfaces, auth propagation, events, webhooks, retries | `06-api-integration/` |
| P6 | Functional & Business Logic | Critical workflows traced from the screen to the database and external services | `07-functional/` |
| P7 | Testing & QA | Tests executed, coverage and scenario gaps — actual results only | `08-testing/` |
| P8 | Infrastructure & DevOps | Vercel, Railway, environments, deploys, health checks, monitoring, backup and rollback | `09-infrastructure/` |
| P9 | Performance & Scalability | Query efficiency, concurrency, caching, resources, latency — benchmarks only where safe | `10-performance/` |
| P10 | Cross-Repository Audit | The ecosystem as one system: contract mismatches, orphans, duplicated logic, version conflicts | `11-ecosystem/` |
| P11 | Final Engineering Assessment | Consolidation, revalidation of critical findings, root causes, scores, roadmap, production-readiness verdict | `12-final-assessment/` |

P6 classifies every major capability as `VERIFIED`, `PARTIALLY_IMPLEMENTED`, `BROKEN`,
`NOT_IMPLEMENTED`, `BLOCKED` or `NOT_VERIFIABLE`.

## 2. Run cadence

The twelve phases are not run in one session:

| Run | Phases | Purpose |
|---|---|---|
| Run 1 | P0–P1 | Discover and fix the baseline |
| Run 2 | P2–P3 | Code and security |
| Run 3 | P4–P5 | Databases and integration |
| Run 4 | P6–P7 | Functions and tests |
| Run 5 | P8–P9 | Infrastructure and performance |
| Run 6 | P10–P11 | The ecosystem and the final verdict |

A complete audit is one **cycle** (Runs 1–6). Each cycle lives in its own dated folder,
`cycles/<YYYY-MM-DD>/`, and is never edited after its P11 closes — the next cycle starts
a new folder, so engineering quality can be compared between cycles.

## 3. What every phase produces

| File | Content |
|---|---|
| `findings.json` | The phase's findings, in the format of §6 |
| `evidence.md` | The evidence: commands run, file paths, line numbers, outputs |
| `report.md` | The phase's engineering report |
| `handoff.md` | What the next phase must take over: open questions, scope, blocked checks |

`00-control/` holds `pipeline-status.md`, `repository-inventory.json`, `audit-scope.md`,
`baseline-references.md`. `registry/` holds `master-findings.json`, `evidence-index.json`
and `phase-dependencies.json` — the one place a finding's current state is read from.
P10 adds `dependency-map.md`; P11 produces `executive-report.md`,
`engineering-scorecard.md`, `remediation-roadmap.md`, `production-readiness.md`.

## 4. Transition rules

- A phase does not hand over before its four outputs exist and validate.
- A finding is never closed without evidence.
- One finding, one ID (`TEC-AUDIT-NNNN`) — for the whole history of the pipeline, not per
  phase or per run. A later phase that meets an earlier finding **references** its ID.
- A tool that fails does not hide a problem: the check is recorded as `BLOCKED`, never `PASSED`.
- A phase that cannot be completed is `BLOCKED`, not `PASSED`.
- **No code is changed in the audited repositories during a run.** Remediation is a
  separate step, after the run, against the roadmap. (Writing the run's own outputs here,
  in the knowledge base, is the deliverable, not a change to the audited code.)

## 5. Phase statuses and gates

`NOT_STARTED` · `IN_PROGRESS` · `PASSED` · `PASSED_WITH_FINDINGS` · `BLOCKED` · `FAILED`.
Passing means the investigation was completed — not that the code is defect-free.

| Gate | Before | Condition |
|---|---|---|
| A — Discovery completeness | P1 | The repository scope is identified |
| B — Architecture baseline | P2–P9 | The canonical references are identified, or explicitly marked unavailable |
| C — Security | P11 verdict | Every critical security finding is registered and visible |
| D — Data integrity | P11 | Database and migration risks are explicitly assessed |
| E — Integration | P11 | Critical end-to-end contracts are examined |
| F — Verification | P11 | Test limitations and execution evidence are documented |
| G — Final assessment | P11 | Every phase has a terminal status |

A blocked gate is never bypassed silently.

## 6. Finding format

```json
{
  "id": "TEC-AUDIT-0001",
  "phase": "P1",
  "repository": "Tec-core-backend",
  "category": "architecture",
  "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "confidence": "HIGH|MEDIUM|LOW",
  "title": "",
  "description": "",
  "evidence": [{ "ref": "EV-0001", "location": "path/to/file.ts:42", "observation": "" }],
  "affected_files": [],
  "root_cause": "",
  "technical_impact": "",
  "business_impact": "",
  "recommendation": "",
  "acceptance_criteria": [],
  "complexity": "S|M|L|XL",
  "status": "OPEN|CLOSED|ACCEPTED_RISK",
  "disclosure": "public|withheld",
  "first_seen": "cycle/run/phase",
  "references": ["C-47 §…", "ADR-…"],
  "remediation": { "state": "", "refs": [], "note": "", "verification": "" },
  "resolution": "INVALID (only when the finding itself was wrong)"
}
```

- **Severity.** CRITICAL — money, identity or data can be lost or taken now. HIGH — a
  violated invariant or a breach path that needs one more condition. MEDIUM — a defect or
  deviation with a bounded effect. LOW — hygiene. INFO — a fact worth recording.
- **Confidence.** HIGH — seen in code and reproduced or measured. MEDIUM — seen in code,
  not exercised. LOW — inferred.
- `acceptance_criteria` say what must be true for the finding to close — a test, a query, a
  measured value — so a fix can be checked rather than asserted.
- `ACCEPTED_RISK` is the owner's decision, recorded with its reason, never the auditor's.
- `remediation` is added after a run and never replaces the finding: `FIXED_PENDING_MERGE`,
  `FIXED_NO_PR_UNTIL_<date>`, `DEFERRED_TO_<phase>` (with the reason), `SCHEDULED`,
  `OWNER_ACTION`, `INVALID`. A finding becomes `CLOSED` only when its acceptance criteria are
  met on `main` — a merged fix is evidence, a pushed one is not.
- A finding the auditor got wrong is closed with `"resolution": "INVALID"` and stays in the
  register with its ID and the reason. IDs are never reused or deleted.
- **A search that returns nothing proves nothing until it has been shown to find
  something** (cycle 2026-11-11: P1-C18's first pattern, and check-drift's service scan).

## 7. Rules for this repository (it is public)

- **An open security finding is `"disclosure": "withheld"`.** Its ID, severity, repository
  and category are published; the description, evidence and reproduction go to the owner
  only, and are published here once the finding is closed and the fix deployed. A
  description of an open hole in a public repository is an instruction manual (the order
  hole of 11 Nov 2026 was handled this way).
- No secret value, token, password or private key appears in any output — redact to the
  variable name.
- An AI never assigns a `C-NN` number. If the pipeline should become a C-doc, the owner
  numbers it.
- The audit reads each repository's **`main`**; open pull requests are listed as pending,
  not as the state of the code.
- Every claim is marked as **verified** (seen in code, run, or measured) or **assumed**;
  metrics are measured, never estimated into a number.

## 8. Success criteria

Every finding has an ID, evidence, a priority and acceptance criteria. Every phase has a
status. Every architectural decision has a reference. Every integration has a
verification state. The final report is measurable, not long.
