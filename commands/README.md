# TEC Knowledge Base — Commands

Slash commands for common TEC platform workflows.

## Available Commands

| Command | Description | Uses MCP |
|---------|-------------|----------|
| `/check-ci` | Check GitHub Actions CI status for all TEC repos | GitHub MCP |
| `/check-deployments` | Check Vercel deployment status for all TEC apps | Vercel MCP |
| `/check-violations` | Audit all P1 violations status | GitHub MCP |
| `/platform-health` | Full platform health check (CI + deployments + Railway + payments) | All MCPs |
| `/knowledge-sync` | Sync knowledge base with current platform state | GitHub MCP |
| `/new-adr` | Scaffold a new Architecture Decision Record | — |
| `/new-skill` | Scaffold a new SKILL.md | — |

## Usage

In Claude Code, type the command name preceded by `/`:

```
/check-ci
/platform-health
/new-adr
```

## MCP Requirements

For MCP-powered commands, configure `.mcp.json` with tokens:

```bash
# Required environment variables
GITHUB_TOKEN=ghp_xxx         # repo + actions:read permissions
VERCEL_TOKEN=xxx             # Vercel account token
RAILWAY_TOKEN=xxx           # Railway account token
```

See `.mcp.json` for full configuration.
