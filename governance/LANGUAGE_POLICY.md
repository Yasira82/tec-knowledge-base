# TEC GOVERNANCE CHARTER — LANGUAGE POLICY

> **Version:** v1.1 — 24 September 2026 (KB remediation step 10; v1.0 June 2026, Session 11)
> **Authority:** TEC_GOVERNANCE_CHARTER_v1.2 § Documentation Standards
> **Scope:** All TEC documentation (knowledge-base/, governance/, architecture/, README, CONTRIBUTING, agent skills, slash commands)

---

## Purpose

Establish a clear, enforceable language policy for TEC documentation. The project's founder thinks in Egyptian Arabic; external auditors (Pi Network Portal, prospective investors, open-source contributors) read English. Without a policy, the knowledge base drifts into inconsistent bilingualism that hurts both audiences.

> **v1.1 context.** This repository is **public** (since September 2026), so "external" is no
> longer hypothetical: every reader of a C-doc may be outside the project. v1.0 classified
> only some C-doc ranges and left the rest undecided; ~40 English-only documents had drifted
> to 522 lines of Arabic prose by the 2026-09-24 audit (F18). v1.1 classifies everything,
> and §6's gate — promised in v1.0 as "future" — now runs in CI.

---

## Policy

### 1. Two-Audience Rule

Every TEC document has exactly one **primary audience**:

| Audience | Language | Examples |
|----------|----------|---------|
| **Internal** — Founder, contributors, future-self | Egyptian Arabic + English mixed | C-02 Current State, C-50 Session Log, internal commit messages, code comments |
| **External** — Pi Network Portal, investors, open-source auditors | English only | README.md, SECURITY.md, LICENSE, governance charters, App Institutional Charters (C-100 → C-115), ADRs (C-64), public-facing docs |

### 2. Document Classification

**The rule (v1.1): every document is external — English only — unless it is listed as internal
below.** A new C-doc is therefore English by default; there is no unclassified range.

| Path | Audience | Language |
|------|----------|----------|
| `knowledge-base/C-02` (Current State) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-40` (Open Violations Map) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-50` (Session Log) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-55` (Scoring & Audit Strategy) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-80` (Engineering Assessment Report) | **Internal** | Arabic + English mixed |
| `knowledge-base/C-81` (P1 Fixes Implementation) | **Internal** | Arabic + English mixed |
| `memory/` (session records, snapshots) | **Internal** | Arabic + English mixed |
| `audits/` (dated audits and plans) | **Internal** | Arabic + English mixed |
| `marketing/` | **Its audience** | The language of the people it is written for — Arabic launch copy for Arab pioneers is correct |
| **Every other C-doc** (C-00 → C-135, charters, ADRs, constitutions, runtimes) | External | **English only** |
| `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md` | External | **English only** |
| `LICENSE` | External | English (legal) |
| `governance/`, `architecture/`, `docs/` | External | **English only** |
| `skills/`, `agents/`, `commands/`, `templates/` | External (Claude Code plugin users) | **English only** |
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
- Use **Western digits (0-9)**, not Eastern Arabic-Indic digits (U+0660–U+0669), for code compatibility
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

### 6. CI Enforcement

`evals/check-language-policy.sh` runs in CI (and in `scripts/preflight.sh`) since v1.1:

| Rule | Checks | Severity |
|------|--------|----------|
| **LP-1** | Arabic in the **prose** of an external document (outside ``` fences). The §5 bilingual H2 is allowed. | Blocking |
| **LP-2** | Arabic **inside code blocks** of external documents. A ratchet against `manifests/language-baseline.yaml`: a file may only go down; above its count, or a file not listed, fails. | Blocking |
| `check-rtl-mixing.sh` | Internal docs: no mixed RTL/LTR text in table headers | Future (warning) |

LP-2 exists because 669 lines of Arabic sit inside code blocks (diagrams, annotated
examples). Translating them is worth doing but not all at once; the ratchet stops the number
growing while it shrinks. After translating some: `UPDATE_BASELINE=1 bash evals/check-language-policy.sh`.

### 7. Translation Protocol

When a previously-internal document needs to become external-facing:

1. Translate Arabic body paragraphs to English — **line for line**, keeping the document's
   line count, so `git diff` shows each original beside its translation
2. Preserve all identifiers, file paths, `C-NN` citations and technical terms as-is
3. The original stays in git history; no archive copy is made (v1.1 — a second copy of a
   document is a second place for it to drift, which is what C-67 forbids)

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
| v1.1 | 24 Sep 2026 (KB remediation step 10) | Repository public. "External unless listed internal" replaces partial ranges (C-02's contradiction removed: it sat in the English-only C-00 → C-23 range and in the internal list). `audits/` internal, `marketing/` audience-language, `docs/` external. §6 gate live (LP-1, LP-2). §7: line-for-line, no archive copy. 522 prose lines in 61 documents translated. |

---

## Related Documents

```
TEC_GOVERNANCE_CHARTER_v1.2  — Governance charter (parent)
CONTRIBUTING.md               — Contribution workflow
C-02 Current State            — Living document (internal, mixed)
C-57 Master Contents Index    — Index (external, English only)
```
