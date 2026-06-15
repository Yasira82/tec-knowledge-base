---
name: knowledge-sync
description: Sync the knowledge base with current platform state — update C-02 and flag any stale documents
---

Sync the TEC knowledge base with the current state of all platform repositories.

## Steps

1. **Read current C-02** (Current State document)
   - Load `knowledge-base/C-02___CURRENT_STATE_.md`
   - Note what's marked as CLOSED vs OPEN

2. **Check actual code state via GitHub MCP**
   - For each closed violation: verify the fix is in `main`
   - For each open item: check if there are recent PRs closing it
   - Check latest commits on main for each repo

3. **Identify stale knowledge**
   - Documents that reference old branch names
   - Skills that reference wrong file paths
   - ADRs that have been superseded but not updated

4. **Update C-02 if needed**
   - Use `/docs-guard` skill before editing
   - Update Truth State, Verification status
   - Add change log entry

5. **Check master index (C-57)**
   - Verify all C-documents are listed
   - Check for new C-documents not yet indexed

6. **Output sync report**

```
KNOWLEDGE SYNC REPORT
=====================
Date: [ISO date]

Documents checked: XX
Stale found: X
  — C-XX: [reason stale]

Violations re-verified:
  ✅ NEW-A: confirmed closed in tec-app main
  ⚠️ NEW-B: still open (ops task)

C-02 updated: [yes/no]
C-57 updated: [yes/no]

Recommendations:
  1. [Action needed]
```

## Truth Framework (apply to all updates)

```
Truth State:  [Current State] | [Planned] | [Future Vision] | [Speculation]
Governance:   [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]
Verification: [Code Verified] | [Runtime Verified] | [Documentation Verified] | [Assumed]
```
