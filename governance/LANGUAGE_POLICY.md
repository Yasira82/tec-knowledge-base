# TEC GOVERNANCE CHARTER — LANGUAGE POLICY

> **Version:** v1.0 — June 2026 (Session 11)
> **Authority:** TEC_GOVERNANCE_CHARTER_v1.2 § Documentation Standards
> **Scope:** All TEC documentation (knowledge-base/, governance/, architecture/, README, CONTRIBUTING, agent skills, slash commands)

---

## Purpose

Establish a clear, enforceable language policy for TEC documentation. The project's founder thinks in Egyptian Arabic; external auditors (Pi Network Portal, prospective investors, open-source contributors) read English. Without a policy, the knowledge base drifts into inconsistent bilingualism that hurts both audiences.

---

## Policy

### 1. Two-Audience Rule

Every TEC document has exactly one **primary audience**:

| Audience | Language | Examples |
|----------|----------|---------|
| **Internal** — Founder, contributors, future-self | Egyptian Arabic + English mixed | C-02 Current State, C-50 Session Log, internal commit messages, code comments |
| **External** — Pi Network Portal, investors, open-source auditors | English only | README.md, SECURITY.md, LICENSE, governance charters, App Institutional Charters (C-100 → C-115), ADRs (C-64), public-facing docs |

### 2. Document Classification

| Path | Audience | Language |
|------|----------|----------|
| `README.md` | External | **English only** |
| `CONTRIBUTING.md` | External | **English only** |
| `SECURITY.md` | External | **English only** |
| `CODE_OF_CONDUCT.md` | External | **English only** |
| `LICENSE` | External | English (legal) |
| `governance/TEC_GOVERNANCE_CHARTER_v1.2.md` | External | **English only** |
| `architecture/PLATFORM_ARCHITECTURE.md` | External | **English only** |
| `knowledge-base/C-00` → `C-23` (Constitution + Architecture + Backend) | External | **English only** |
| `knowledge-base/C-30` → `C-32` (Vision + Blueprints) | External | **English only** |
| `knowledge-base/C-47` (Kernel Spec) | External | **English only** |
| `knowledge-base/C-64` (ADRs) | External | **English only** |
| `knowledge-base/C-67` → `C-78` (Governance + Operations) | External | **English only** |
| `knowledge-base/C-93` → `C-99` (Institutional Loop) | External | **English only** |
| `knowledge-base/C-100` → `C-115` (App Charters) | External | **English only** |
| `knowledge-base/C-116` (Authority Automation) | External | **English only** |
| `knowledge-base/C-02` (Current State — Living Document) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-50` (Session Log) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-40` (Open Violations Map) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-55` (Scoring & Audit Strategy) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-80` (Engineering Assessment Report) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-81` (P1 Fixes Implementation) | **Internal** | Arabic + English mixed |
| `memory/` (Agent memory snapshots) | **Internal** | Arabic + English mixed |
| `agents/*/SKILL.md` | External (Claude Code plugin users) | **English only** |
| `skills/*/SKILL.md` | External | **English only** |
| `commands/*.md` | External | **English only** |
| `templates/**/*.md` | External | **English only** |
| `evals/*.sh` (comments) | External | **English only** |

### 3. Mixed-Language Rules (Internal Docs Only)

For internal documents that mix Arabic and English:

- **Table headers:** English only (e.g., `| Metric | Value |`)
- **Table cells:** May mix Arabic and English
- **Code blocks:** English only
- **Section headings (H1, H2, H3):** English only
- **Body paragraphs:** May mix freely
- **Inline code:** English only
- **File paths, command names, identifiers:** English only (never transliterate)

### 4. Arabic-Specific Conventions

When Arabic is used in internal docs:

- Use **Egyptian Arabic** (not MSA) for natural voice — matches how the founder thinks
- Use **Arabic numerals (0-9)**, not Eastern Arabic numerals (٠-٩), for code compatibility
- Use **straight quotes** `"..."` not curly quotes `"..."` — avoids encoding issues
- Use **ASCII parentheses** `(...)` not Arabic parentheses `﴾...﴿`
- Use **ASCII dash** `-` not Arabic dash `—` in code blocks
- Use **`<br>`** for line breaks inside Markdown table cells (not `\n`)

### 5. Bilingual Headers (Allowed Exception)

For documents that need to surface both languages in the heading (e.g., for grep-ability):

```markdown
# C-XX — Document Title (English)
## عنوان المستند (Arabic)
```

The H1 is always English; an optional H2 in Arabic may follow immediately.

### 6. CI Enforcement (Future)

In Phase 2, the following CI checks will be added:

| Check | Rule | Severity |
|-------|------|----------|
| `check-language-policy.sh` | External-audience docs must not contain Arabic characters outside code blocks | Blocking |
| `check-rtl-mixing.sh` | Internal docs must not contain mixed RTL/LTR text in table headers | Warning |

For Phase 1, language compliance is reviewed manually in PR review.

### 7. Translation Protocol

When a previously-internal document needs to become external-facing:

1. Translate Arabic body paragraphs to English
2. Preserve all code blocks, identifiers, and technical terms as-is
3. Move the Arabic version to `knowledge-base/archive/C-XX-ar.md` (preserve institutional memory)
4. Add a note at the top: `> Translated from Arabic in Session NN. Original preserved in archive/.`

### 8. Non-Goals

This policy does NOT:
- Forbid Arabic in internal docs (founder's thinking language is respected)
- Require translating historical session logs (they are internal institutional memory)
- Apply to commit messages (those follow Conventional Commits in English)
- Apply to GitHub issues / PRs (English only, per CONTRIBUTING.md)

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | June 2026 (Session 11) | Initial policy. Two-audience rule + document classification table. |

---

## Related Documents

```
TEC_GOVERNANCE_CHARTER_v1.2  — Governance charter (parent)
CONTRIBUTING.md               — Contribution workflow
C-02 Current State            — Living document (internal, mixed)
C-57 Master Contents Index    — Index (external, English only)
```
