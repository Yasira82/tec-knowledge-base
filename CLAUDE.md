# TEC Knowledge Base

Centralized knowledge base for the TEC Federated Platform Ecosystem.

> **This file is navigation and the rules that bite. It is not a log.** What a session did
> goes to `memory/sessions/` (the old "Session N Additions" blocks, Sessions 12 → 46, are in
> `memory/sessions/kb-claude-md-log.md`). A gate keeps this file under 150 lines.

## Start here

1. `knowledge-base/C-02___CURRENT_STATE_.md` — where the platform stands now (≤ 150 lines)
2. The newest `memory/sessions/session-*.md` — what the last session did and left open
3. `knowledge-base/C-57___MASTER_CONTENTS_INDEX.md` — every C-doc

## Structure

| Folder | What lives there |
|---|---|
| `knowledge-base/` | The C-docs (C-00 → C-135, with reserved gaps) — the canonical knowledge |
| `memory/sessions/` | One record per session + an index; history, not current state |
| `architecture/` | `app-fleet.yaml` (**the** list of apps) · `asset-registry.yaml` (**generated**) |
| `manifests/` | Events catalog · SLO definitions · dependency graph (**generated**) · VAM |
| `audits/` | Dated audits and plans (e.g. `KB_REMEDIATION_PLAN_2026-09-24.md`) |
| `evals/` · `scripts/` | The gates CI runs · the generators and checkers |
| `runtime-evidence/` | Records from production, bound to the C-docs they prove |
| `governance/` | `TEC_GOVERNANCE_CHARTER_v1.2.md` |
| `marketing/` | Launch kit (executes C-133; SSoT = tec-app registry `valueProp`) |
| `skills/` · `agents/` · `commands/` | Claude Code plugin content |

## Contents (C-57 is authoritative)

| Range | Domain |
|-------|--------|
| C-00 · C-01 · C-02 | Constitution · Identity (Pi App IDs: C-01 §4) · Current State |
| C-10 – C-23 | Architecture, rules, backend, apps, SDK (C-11, the repo map, is **generated**) |
| C-30 – C-49 | Vision, blueprints, engineering, violations (C-40), roadmap, env vars (C-44, **generated**) |
| C-50 – C-66 | Sessions, patterns, protocols, templates, ADRs (C-64) |
| C-67 – C-99 | Governance, integrity, operations (C-78), institutional loop, runtime governance |
| C-100 – C-115 · C-124 – C-131 | App charters |
| C-116 – C-123 | Constitutional automation · OS model · Analytics runtime · **C-123 Pi Browser session & cookie law** |
| C-132 – C-135 | Modules-first policy (ADR-011) · Adoption growth · Pioneer runtime · Launch strategy |

## Before you push

```bash
bash scripts/preflight.sh      # runs EXACTLY what CI runs, in CI's order — not `bash evals/*.sh`
```

Running every eval is not CI: CI first **regenerates** the asset registry and the dependency
graph and diffs them against what you committed. It has shipped red twice: once before
`preflight.sh` existed, and once after, by a session that did not know it was there.

- **If you edit a C-doc, the registry is part of your change.** `depends_on` is derived from
  the document BODY — citing another `C-NN` anywhere changes it. Commit the regenerated files.
- **Preflight cannot see the code.** For facts the code can confirm (ports, versions, events,
  cookies, the fleet, C-11/C-44):
  `python3 scripts/check-drift.py --repos-dir <dir with the repo clones> --ref origin/main`
  — the same check `drift.yml` runs every Monday. Regenerate C-11/C-44 with
  `python3 scripts/generate-code-docs.py --repos-dir … --ref origin/main`.
- **Blast radius of an edit:** `python3 scripts/registry-impact-analysis.py C-XX` (C-116 §1.3).

## Rules that bite

| Rule | Why / where |
|---|---|
| Never hand-edit `asset-registry.yaml` or `dependency-graph.yaml` — edit the C-doc, regenerate | C-117 · C-118; CI rejects it |
| Never hand-edit between `GENERATED` markers (C-11, C-44) | `generate-code-docs.py`; drift job fails on stale |
| An AI never invents, renumbers or reuses a `C-NN` — a human assigns numbers | `.cursorrules` RULE 6 |
| C-02 is edited **in place** (≤ 150 lines); a session's narrative is a new file in `memory/sessions/` | C-02 §5; gate in `check-knowledge-gaps.sh` |
| `[Code Verified]` needs `Last verified …: YYYY-MM-DD` (≤ 60 days) or a generated block | `check-verification-freshness.sh` |
| The events catalog is code-sourced — no entry without a producer in code | `manifests/events-catalog.yaml` (C-70 governs) |
| A cookie / login / refresh change in any app cites C-123 and names the LAW it keeps. `sameSite=lax` is forbidden; cookies are set only on a 200; refresh renews the token **with** `tec_user` + `tec_csrf` | C-123 §2 · C-13 §1 |
| A shared package's major bump includes auditing every consumer's range (`^1.x` never reaches 2.x) | Session 46; C-11 shows each app's ranges |
| Pushing to the development branch and opening its PR are one step | Session 46 |
| Check what `main` has, not what the PR says — a merge can race a push | Session 56q |
| Merged ≠ deployed (Vercel's daily build quota) | Session 56q |

## Authority hierarchy

C-00 → C-67 → ADRs (C-64) → Current State docs → Runtime Evidence → Code

## Truth Framework

Every architectural statement must declare:
- Truth State: [Current State] | [Planned State] | [Future Vision] | [Speculation]
- Governance State: [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]
- Verification: [Documentation Verified] | [Code Verified] | [Runtime Verified] | [Assumed]

No counts or version numbers are kept in this file — they were each true only on the day
they were written. `preflight.sh` prints the live gate count; C-57 the live document count.

## Skills

Available via plugin — invoke automatically when the situation matches:

| Situation | Skill |
|-----------|-------|
| Updating or reviewing any knowledge-base document | `/docs-guard` |
| Stress-testing an architectural decision against existing ADRs | `/grill-with-docs` |
| Converting a strategic discussion into a PRD | `/to-prd` |
| Breaking a roadmap item into GitHub Issues | `/to-issues` |
| Session is getting long or context is filling up | `/handoff` |
