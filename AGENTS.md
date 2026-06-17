# AGENTS.md

## Cursor Cloud specific instructions

This repository is the **TEC Knowledge Base** — a Claude Code plugin made of Markdown
documentation (`knowledge-base/`, `governance/`, `architecture/`, `skills/`, `agents/`,
`commands/`, `templates/`, `memory/`) plus bash validation scripts in `evals/`. There is
**no application server, build step, or package manager** (no `package.json`, no Python
deps). The only "runtime" is the validation/CI suite.

### Lint / test / build / run

The "application" is the validation suite. It mirrors `.github/workflows/knowledge-ci.yml`
and is the canonical way to lint/test/run this repo. Run from the repo root:

- `bash evals/validate-skills.sh` — validates every `skills/**/SKILL.md` (frontmatter, size).
- `bash evals/validate-charters.sh` — validates the 16 App Institutional Charters (C-100→C-115).
- `bash evals/check-knowledge-gaps.sh` — checks required C-documents exist.

All three are blocking (non-zero exit on failure) and are invoked via `bash`, so the
executable bit is not required. The startup update script also `chmod +x evals/*.sh` so
they can be run directly as `./evals/<script>.sh` if preferred.

### Non-obvious caveats

- The CI `check-truth-framework` job is **informational only**: it prints
  `⚠️ Missing Truth State` warnings for documents lacking a `Truth State` declaration but
  **always exits 0** and never fails the build. Do not treat its warnings as failures.
- `evals/*.sh` are tracked in git as non-executable (`100644`); the CI workflow and the
  update script both `chmod +x` them. Running via `bash evals/<script>.sh` works regardless.
- The `.mcp.json` MCP connectors (GitHub, Vercel, Railway, Supabase) and the external
  Railway/Vercel services referenced in `README.md` live in **other repositories** — they
  are not part of this repo and are not needed to validate or work on the knowledge base.
