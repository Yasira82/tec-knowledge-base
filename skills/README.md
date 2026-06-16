# TEC Knowledge Base — Skills Directory

All skills in this library follow the [SKILL.md standard](templates/new-skill/SKILL.md).

## Platform Skills (auto-activate on any TEC task)

| Skill | Tier | When it activates |
|-------|------|------------------|
| [knowledge-orchestrator](platform/knowledge-orchestrator/SKILL.md) | CRITICAL | Every session start — loads context + routes to right skill |
| [platform-architect](platform/platform-architect/SKILL.md) | CRITICAL | Any architectural decision — validates against C-47 |
| [payment-expert](platform/payment-expert/SKILL.md) | CRITICAL | Any payment, ADR-007 guard, BFF payment route |
| [security-reviewer](platform/security-reviewer/SKILL.md) | CRITICAL | Any PR review, auth change, sensitive operation |
| [charter-advisor](platform/charter-advisor/SKILL.md) | HIGH | Any app modification — load charter before touching app code |
| [mcp-orchestrator](platform/mcp-orchestrator/SKILL.md) | HIGH | Using GitHub/Vercel/Railway/Supabase MCPs in TEC context |
| [observability](platform/observability/SKILL.md) | HIGH | SLOs, incident response, circuit breaker, health monitoring |

## Engineering Skills

| Skill | Tier | When it activates |
|-------|------|------------------|
| [bff-patterns](engineering/bff-patterns/SKILL.md) | HIGH | Writing/modifying any /api/bff/* route |
| [tec-testing](engineering/tec-testing/SKILL.md) | HIGH | Writing tests, CI failures, coverage gaps |

## Marketing Skills

| Skill | Tier | When it activates |
|-------|------|------------------|
| [pi-growth](marketing/pi-growth/SKILL.md) | HIGH | User acquisition, retention, growth strategy |
| [content-strategy](marketing/content-strategy/SKILL.md) | MEDIUM | Blog posts, social content, Pi community updates |
| [product-launch](marketing/product-launch/SKILL.md) | HIGH | Launching new TEC app or major feature |
| [community-marketing](marketing/community-marketing/SKILL.md) | MEDIUM | Pi Chat, Pi Forum, Telegram community |
| [seo-aeo](marketing/seo-aeo/SKILL.md) | MEDIUM | Search visibility, AI engine optimization |

## Design Skills

| Skill | Tier | When it activates |
|-------|------|------------------|
| [tec-design-system](design/tec-design-system/SKILL.md) | HIGH | Any TEC UI component — tokens, Pi Browser rules |
| [ui-patterns](design/ui-patterns/SKILL.md) | MEDIUM | Modals, drawers, loaders, payment states UI |

## Tiers

| Tier | Meaning |
|------|---------|
| CRITICAL | Platform invariants — always check before any action |
| HIGH | Significant impact — use when task matches domain |
| MEDIUM | Supporting skills — use when additional depth needed |

## Adding New Skills

1. Copy `templates/new-skill/SKILL.md`
2. Fill in frontmatter: name, description, version, domain
3. Run `bash evals/validate-skills.sh` locally
4. Add entry to this README
5. PR — CI validates automatically
