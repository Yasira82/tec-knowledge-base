# KNOWLEDGE BASE (Session 8) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

### C-92 Platform Health Model

Closes the Observability gap identified in architectural review (9.1/10 → target 9.5/10):

| Section | Content |
|---------|--------|
| Health Philosophy | Health ≠ Uptime. Health = economic function delivered correctly |
| 5 Dimensions | Identity × Payment × App × Service × Event Bus |
| State Machine | GREEN → DEGRADED → CRITICAL → DOWN (formal transitions) |
| PHS Formula | Composite score: Identity 30% + Payment 30% + Service 20% + App 15% + Events 5% |
| Propagation Rules | Identity cascade + Gateway cascade + Payment independence |
| Health Gates | Deployment gate (PHS < 80 = block) + Release chain gate |
| Dashboard Spec | 5 panels with signal layouts — Phase 1 implementation target |
| Phase 0 Checklist | Manual health verification before every deployment |

### C-57 Updated
- C-92 added to TIER 7 (now C-87→C-92)
- Count updated: 91 → 92 documents
- Quick Lookup: added "Check platform health → C-92"
- Content Ranges: C-87→C-92
