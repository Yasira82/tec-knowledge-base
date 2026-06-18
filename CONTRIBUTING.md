# Contributing to the TEC Knowledge Base

Thank you for contributing. This repository is the **single source of truth** for the TEC
Federated Platform: Markdown knowledge documents (`knowledge-base/`), governance, skills,
agents, commands, templates, and the `evals/` CI validators. There is no application runtime
here — changes are documentation + validation logic.

Please read `CLAUDE.md` (navigation index) and `knowledge-base/C-00` (Platform Constitution)
before making substantial changes.

## Ground Rules

- **Authority hierarchy** (conflicts resolve top-down): C-00 → C-67 (Source of Truth) → ADRs (C-64)
  → C-77 → Current-State (C-02, C-78) → App Charters (C-100→C-115) → Runtime Evidence → Code.
- **Truth Framework:** every C-document must declare a **Truth State** and **Governance State**
  in its header. Never present `[Planned State]` as `[Current State]`.
- **No rule duplication:** extend/link an existing document instead of restating it (C-47 P2).

## Workflow

1. **Branch** off `main` using a descriptive name (e.g. `cursor/<topic>` or `claude/<topic>`).
2. **Make changes.** For a new C-document, copy `templates/new-c-document/C-XX-TEMPLATE.md`
   (or `templates/new-charter/` for an App Charter, `templates/new-adr/` for an ADR).
3. **Register new documents** in `knowledge-base/C-57` (Master Index) and, if platform state
   changed, in `knowledge-base/C-02` (Current State).
4. **Validate locally** (see below) — all checks must pass.
5. **Open a PR** using the template in `.github/PULL_REQUEST_TEMPLATE.md`.

## Local Validation

Run the same checks CI runs (mirrors `.github/workflows/knowledge-ci.yml`):

```bash
bash evals/validate-skills.sh                   # SKILL.md frontmatter
bash evals/validate-charters.sh                 # C-100→C-115 charter structure
bash evals/validate-structure.sh                # dirs + plugin.json manifest
bash evals/check-knowledge-gaps.sh              # required core documents exist
bash evals/check-links.sh                       # relative Markdown links resolve
bash evals/check-truth-framework.sh             # Truth/Governance State — BLOCKING on C-00→C-23
bash evals/check-c57-index.sh                   # C-57 index drift — BLOCKING
bash evals/check-authority-consistency.sh       # AHV engine — BLOCKING on authority violations
bash evals/check-registry-integrity.sh          # Registry integrity — BLOCKING (NEW v3.6.0)
bash evals/check-vam-compliance.sh           # VAM compliance — BLOCKING (NEW v3.6.1)
```

All ten are **blocking** (v3.6.2: 0 errors across all gates). The first five validate structure; the last five enforce the Truth Framework, index accuracy, authority hierarchy (per C-116), and registry integrity (per C-117).

### v3.6.0 Workflow for Editing a C-Document

```bash
# 1. Before editing, analyze the blast radius
python3 scripts/registry-impact-analysis.py C-67

# 2. Make your edit to the C-NN.md file

# 3. Regenerate the registry (DO NOT manually edit asset-registry.yaml)
python3 scripts/build-asset-registry.py  # v1.2 — DAG-guaranteed
python3 scripts/regenerate-cdg.py           # Derive CDG from registry
python3 scripts/propagate-dependency.py C-XX  # Check blast radius

# 4. Run all CI checks
for s in evals/*.sh; do bash "$s" || break; done

# 5. Commit (registry changes auto-included)
git add knowledge-base/C-XX.md architecture/asset-registry.yaml
git commit -m "docs(C-XX): <your change>"```
bash
bash evals/validate-skills.sh          # SKILL.md frontmatter
bash evals/validate-charters.sh        # C-100→C-115 charter structure
bash evals/validate-structure.sh       # dirs + plugin.json manifest
bash evals/check-knowledge-gaps.sh     # required core documents exist
bash evals/check-links.sh              # relative Markdown links resolve
bash evals/check-truth-framework.sh    # Truth/Governance State adoption (informational)
```

The first five are **blocking**. `check-truth-framework` is informational (it reports adoption
but does not fail the build, because Truth/Governance values require per-document judgement).

## Document Conventions

- C-documents are named `C-<NN>___TITLE.md` (or `C-<NN>_Title.md`). Keep one C-number per file.
- Use relative Markdown links that resolve from the file's own directory (the link checker enforces this).
- Add a **Change Log** row and bump the document `Version` on meaningful edits.
- Do not commit secrets. This repo is public-documentation oriented; treat all credentials as out of scope.

## Commit & PR

- Use clear, conventional-style messages (e.g. `feat(kb): ...`, `fix(evals): ...`, `docs(c-17): ...`).
- One logical change per commit where practical.
- PRs should be small and reviewable; fill in the PR template (type, Truth State, checklist).

## Reporting Issues

- Documentation errors / knowledge gaps: open a GitHub issue (see `.github/ISSUE_TEMPLATE/`).
- Security vulnerabilities: follow `SECURITY.md` (do **not** open a public issue).

## Registry Freeze Policy (v3.6.0+)

Per `knowledge-base/C-117___REGISTRY_INTEGRITY_CONSTITUTION.md`, the asset registry is now an auto-generated artifact. The following restrictions apply:

### Forbidden (CI will reject)

- Manually editing `architecture/asset-registry.yaml` — this file is regenerated by `scripts/build-asset-registry.py` on every commit
- Editing `architecture/registry-integrity-rules.yaml` without an ADR — rules changes affect the entire validation pipeline
- Adding C-documents without a corresponding `path` field — R-SCHEMA-006 will fail
- Setting `truth_state` to a value incompatible with the tier — R-GOV-008 will fail
- Creating circular `depends_on` chains — R-STRUCT-002 will fail

### Required for every C-document PR

1. Run `python3 scripts/registry-impact-analysis.py C-XX` (where C-XX is the doc you're editing) — paste the output in the PR description
2. Run `python3 scripts/build-asset-registry.py  # v1.2 — DAG-guaranteed
python3 scripts/regenerate-cdg.py           # Derive CDG from registry
python3 scripts/propagate-dependency.py C-XX  # Check blast radius` to regenerate the registry
3. Run all 9 CI checks locally — all must pass
4. If the PR changes Truth State or tier: add `governance` label

### Allowed (normal PR)

- Fixing typos, formatting, broken links in C-documents
- Adding new content to existing C-documents (the registry will auto-update on next commit)
- Adding new C-documents (the registry will auto-include them on next commit)
- Translating Arabic content to English per `governance/LANGUAGE_POLICY.md`

### Forbidden

- Editing `memory/platform-snapshot.md` directly (auto-generated)
- Editing `knowledge-base/archive/` content (archived = immutable)
- Editing `C-50___SESSION_LOG.md` retroactively (append-only)
- Removing files without an ADR documenting the deprecation reason
- Manually editing `architecture/asset-registry.yaml` (use `scripts/build-asset-registry.py`)

