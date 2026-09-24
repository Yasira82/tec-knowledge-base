# KNOWLEDGE BASE UPGRADE (Session 6 — v3.1.0) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

### Phase 1 — Foundation
| الملف | الوظيفة |
|------|----------|
| `.claude-plugin/plugin.json` | Plugin marketplace manifest |
| `skills/platform/knowledge-orchestrator` | Meta-skill: تحميل C-docs تلقائياً + توجيه كل task |
| `skills/platform/platform-architect` | C-47 guardian: تحقق من كل قرار معماري |
| `skills/platform/payment-expert` | ADR-007 + C-76 + Mode 1/2 decision tree |
| `skills/platform/security-reviewer` | P6 Fail Closed + 10 Forbidden behaviors checklist |
| `skills/engineering/bff-patterns` | BFF route template كامل |
| `skills/engineering/tec-testing` | Vitest + Pi mock + coverage targets |
| `evals/validate-skills.sh` | CI quality gate للـ skills |
| `templates/new-skill, new-adr, new-c-document` | Scaffolds |
| `.github/workflows/knowledge-ci.yml` | CI pipeline |

### Phase 2 — Marketing + Design + Agents
| المجال | Skills |
|-------|--------|
| Marketing | pi-growth, content-strategy, product-launch, community-marketing, seo-aeo |
| Design | tec-design-system, ui-patterns |
| Agents | cmo-advisor, growth-advisor, design-system-advisor |

### Phase 3 — MCP + Commands + Observability
| الملف | الوظيفة |
|------|----------|
| `.mcp.json` | GitHub + Vercel + Railway + Supabase connectors |
| `commands/check-ci` | CI status لكل 8 repos |
| `commands/check-deployments` | Vercel deployments + runtime logs |
| `commands/check-violations` | P1 violations audit |
| `commands/platform-health` | Full health check (CI + Vercel + Railway + payments) |
| `commands/knowledge-sync` | مزامنة C-02 مع الكود |
| `commands/new-adr, new-skill` | Scaffolding commands |
| `skills/platform/mcp-orchestrator` | كيفية استخدام MCP في context الـ TEC |
| `skills/platform/observability` | SLOs + incident response + circuit breaker |

### إجمالي Knowledge Base v3.1.0
```
Skills:   11 skills (4 platform + 2 engineering + 5 marketing + 2 design)
Agents:    3 agents (cmo-advisor + growth-advisor + design-system-advisor)
Commands:  7 commands
Templates: 3 scaffolds (skill, ADR, C-document)
CI:        1 workflow (knowledge-ci.yml)
MCP:       4 connectors (GitHub, Vercel, Railway, Supabase)
```
