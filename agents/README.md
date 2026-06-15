# TEC Knowledge Base — Agents Directory

Specialist agents for complex, domain-specific advisory.

## Available Agents

| Agent | Domain | When to Activate |
|-------|--------|------------------|
| [cmo-advisor](cmo-advisor/SKILL.md) | C-Level Marketing | Marketing strategy, go-to-market, Pi Network positioning |
| [growth-advisor](growth-advisor/SKILL.md) | Growth | Funnel analysis, A/B testing, retention optimization |
| [design-system-advisor](design-system-advisor/SKILL.md) | Design | tec-ui upgrades, Pi Browser compatibility, coordinated deploy |

## Platform Specialist Skills (in skills/platform/)

These are used as agents too:

| Skill | When to Activate |
|-------|------------------|
| platform-architect | Architectural decisions, ADR creation, cross-repo impact |
| payment-expert | Payment flows, ADR-007 compliance, BFF payment routes |
| security-reviewer | Security audits, forbidden pattern detection, P6 enforcement |

## Agent vs Skill Distinction

```
Skill  = Auto-activating instruction set for a specific task type
Agent  = Opinionated advisor with a persistent persona and strategic view

Skills are REACTIVE (triggered by task type).
Agents are PROACTIVE (provide strategic guidance and recommendations).
```

## Adding New Agents

1. Create `agents/[name]/SKILL.md`
2. Use SKILL.md format (same as skills)
3. Include: persona, decision framework, strategic context
4. Add entry to this README
