---
name: new-skill
description: Scaffold a new SKILL.md for the TEC knowledge base
---

Create a new skill in the TEC knowledge base.

## Steps

1. **Determine skill domain**
   - `platform` — platform invariants, architectural patterns
   - `engineering` — code patterns, BFF routes, testing
   - `marketing` — Pi Network growth, content, community
   - `design` — UI patterns, design system, Pi Browser compatibility

2. **Determine tier**
   - `CRITICAL` — always check, platform invariants
   - `HIGH` — significant impact, use when domain matches
   - `MEDIUM` — supporting, additional depth

3. **Create skill directory and file**
   - Path: `skills/[domain]/[skill-name]/SKILL.md`
   - Copy `templates/new-skill/SKILL.md`
   - Fill all frontmatter fields

4. **Write skill content**
   - When to activate (trigger condition)
   - Decision framework or flowchart
   - Code patterns or templates
   - Common mistakes table
   - Related skills and documents

5. **Validate locally**
   ```bash
   bash evals/validate-skills.sh
   ```

6. **Update `skills/README.md`**
   - Add entry to the appropriate domain table

7. **Commit**
   ```
   feat(skill): add [skill-name] — [one line description]
   ```

## Invoke

Provide:
- **Name**: snake_case skill identifier
- **Domain**: platform / engineering / marketing / design
- **Trigger**: When should this skill activate?
- **Core content**: What knowledge does it encode?
