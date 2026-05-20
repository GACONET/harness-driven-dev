---
name: new-runbook
description: Scaffold a new operational runbook from a template (incident-response or deployment). Outputs a runbook ready to fill in for your specific scenario.
user-invocable: true
allowed-tools: Bash(ls *) Bash(cp *) Bash(mkdir *)
argument-hint: "<type> <slug> — type: incident|deploy · slug: kebab-case-name (e.g., db-connection-pool-exhausted)"
---

# New Runbook

Scaffold a new operational runbook in `runbooks/` from one of the templates in `runbooks/templates/`.

## Steps

1. **Parse arguments** from `$ARGUMENTS`:
   - First word: `incident` or `deploy` (type)
   - Rest: kebab-case slug (e.g., `db-connection-pool-exhausted`)

2. **Pick the template**:
   - `incident` → `runbooks/templates/incident-response.md`
   - `deploy` → `runbooks/templates/deployment.md`

   If type is unknown, list available templates and stop.

3. **Copy and rename**:
   ```bash
   cp runbooks/templates/<type>-*.md runbooks/<slug>.md
   ```

4. **Customize the header** of the new file:
   - Replace `<RUNBOOK_TITLE>` with a title derived from the slug
   - Replace `<DATE>` with today's date
   - Replace `<OWNER>` with the user's git identity (`git config user.name`)
   - Leave all `<PLACEHOLDER>` markers in the body for the human to fill in

5. **Report**:
   ```
   Created runbooks/<slug>.md from <type> template.
   Fill in the placeholders, then commit:
     git add runbooks/<slug>.md
     git commit -m "docs: add runbook for <slug>

     Refs DEMO-XXX"
   ```

## Rules

- NEVER auto-fill `<PLACEHOLDER>` markers — the human knows the specifics.
- ALWAYS leave the header `Last reviewed:` blank for the human to set on first commit.
- If a file with the same slug already exists, refuse and suggest a different name. Don't overwrite.
- The runbook MUST stay under 200 lines — if longer, split into multiple runbooks.

## Why this skill exists

Operational runbooks are how DevOps teams capture institutional knowledge that can't live in code. Without a scaffold, runbooks get written ad-hoc with inconsistent structure, then forgotten. This skill enforces a shape so every runbook is grep-able, on-call-friendly, and version-controlled.

The two starter templates cover ~80% of cases:
- **incident-response**: when something is broken in production
- **deployment**: when you're rolling out a change manually

For other types (e.g., disaster recovery, compliance audit), copy and adapt one of the templates manually.
