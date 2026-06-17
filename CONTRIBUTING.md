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
