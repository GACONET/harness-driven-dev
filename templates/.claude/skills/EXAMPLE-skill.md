---
name: example-skill
description: Template for creating your own Claude Code skill. Replace this description with one sentence about what the skill does.
user-invocable: true
allowed-tools: Bash(git *) Bash(gh *) Bash(npm test*)
argument-hint: "<ARGUMENT_DESCRIPTION>"
---

# Example Skill

<ONE-PARAGRAPH PURPOSE STATEMENT.
What problem does this skill solve? When should the user invoke it?
What does it produce as output?>

## Steps

1. **<STEP NAME>**:
   ```bash
   # exact command(s) the agent runs
   ```
   Expected outcome: <what the user sees>

2. **<NEXT STEP>**:
   <description of the action>

3. **Report**:
   Tell the user what happened: success criteria, what changed, where to look.

## Rules

- NEVER <action that would violate the harness or be destructive>
- ALWAYS <action that ensures consistency>
- If <edge case>, then <what to do>

## Why this skill exists

<2–3 sentences explaining the WHY.
Link to the lesson/incident that originated this skill if applicable.>

## Example invocation

```
/example-skill MY-ARGUMENT
```

Expected:
- <observable outcome 1>
- <observable outcome 2>
