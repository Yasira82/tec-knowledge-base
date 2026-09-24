# TEC Platform — Persistent Memory Configuration

Integration guide for claude-mem (persistent memory across sessions).

## Setup (claude-mem v13+)

```bash
# Install claude-mem globally
npx claude-mem install

# Verify installation
npx claude-mem status
```

## What to Persist

The following context should be captured in every TEC session:

### Session Start — Always Load
```
1. C-02 Current State → what violations are open, what's closed
2. C-47 Kernel Spec → platform invariants and forbidden behaviors
3. Active branch state → what's in progress
```

### Session End — Always Save
```
1. Decisions made → ADR references
2. Violations found/closed → update C-02 §1–§2 in place
   The session narrative → memory/sessions/session-<id>.md (+ a row in its README)
3. Files modified → with rationale
4. Outstanding items → for handoff
```

## Privacy Tags

Use `<private>` tags to exclude sensitive data from memory:
```
<private>
INTERNAL_SECRET=xxxxx
API keys
Railway credentials
</private>
```

## Memory Domains

| Domain | Memory Priority | Retention |
|--------|----------------|----------|
| Architectural decisions | HIGH | Permanent |
| P1 Violations status | HIGH | Until closed |
| Active PR/branch context | MEDIUM | 7 days |
| Test failures / fixes | MEDIUM | 30 days |
| Debugging sessions | LOW | 24 hours |

## Integration with Knowledge Orchestrator

The `knowledge-orchestrator` skill auto-triggers memory load:
- On session start → pulls relevant C-documents
- On session end → compresses to semantic summary
- Cross-session → maintains platform invariant awareness
