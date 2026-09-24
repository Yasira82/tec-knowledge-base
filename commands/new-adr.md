---
name: new-adr
description: Scaffold a new Architecture Decision Record (ADR) for the TEC platform
---

Create a new ADR for the TEC platform following the C-64 ADR system.

## Steps

1. **Determine ADR number**
   - Check `knowledge-base/C-64___ARCHITECTURE_DECISION_RECORDS.md` for the last ADR number
   - Increment by 1

2. **Validate the decision needs an ADR**
   Required for:
   - Any change to `/hub?pay=1` URL pattern
   - Cookie name changes
   - New inter-service communication pattern
   - Breaking API contract changes
   - New service or app added to platform
   - Payment state machine changes

3. **Fill the ADR template**
   - Copy `templates/new-adr/ADR-TEMPLATE.md`
   - Fill: status, date, context, decision, rationale, consequences
   - Complete the cross-repo impact table
   - Document enforcement mechanism (Policy CI, Gateway, etc.)

4. **Create ADR file**
   - Path: `knowledge-base/ADR-[NUMBER]___[TITLE].md`
   - Status: `Draft`

5. **Update C-64 ADR Index**
   - Add new ADR entry to the index table in C-64

6. **Update C-57 Master Index**
   - Add reference to new ADR

7. **Cross-repo impact**
   - Notify affected repos via PR description
   - Update CLAUDE.md in affected repos if pattern changes

## Invoke

Provide:
- **Title**: What decision is being made?
- **Context**: What problem does it solve?
- **Decision**: What will we do?
- **Repos affected**: Which repos need to change?
