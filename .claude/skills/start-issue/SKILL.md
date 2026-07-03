---
name: start-issue
description: Start work on a Linear issue — fetch details, create branch, create .workspace/ISSUE_ID/ folder, move to In Progress, and guide the user through the spec-writer → planner workflow
user-invocable: true
allowed-tools: Bash(git *) Bash(python3 scripts/*) Bash(New-Item *) Bash(mkdir *)
argument-hint: "<ISSUE_ID> (e.g., DEMO-1)"
---

# Start Issue

Begin work on Linear issue `$ARGUMENTS`.

## Steps

### 1. Fetch issue from Linear

```bash
python3 scripts/linear_client.py get $0 --full
```

If the issue does not exist, stop and inform the user.

Show the user: title, description, acceptance criteria, current state.

### 2. Create the workspace folder

Create `.workspace/$0/` to hold the spec, plan, and any other development artifacts for this issue.

On Windows:
```powershell
New-Item -ItemType Directory -Force .workspace\$0
```
On Unix:
```bash
mkdir -p .workspace/$0
```

### 3. Create a feature branch

```bash
git checkout -b feat/$0-<slugified-title>
```

Use the issue title to generate a short kebab-case slug (lowercase, hyphens, no special chars, max ~5 words).

### 4. Move to In Progress in Linear

```bash
python3 scripts/linear_client.py move $0 "In Progress"
```

### 5. Confirm and guide next steps

```
✓ Issue $0 started.

  Branch    : feat/$0-<slug>
  Status    : In Progress
  Workspace : .workspace/$0/

Next steps:
  1. Run /spec-writer $0  →  generates the development spec (source of truth)
  2. Run /planner $0      →  generates the step-by-step development plan
  3. Implement tasks from plan.md in order
  4. Run /close-issue $0  →  runs gates and closes with evidence
```

## Rules

- NEVER start coding without running this skill first.
- If the issue does not exist, stop and inform the user.
- If already on a feature branch for this issue, skip branch creation but still create the workspace folder if it doesn't exist.
- The workspace folder `.workspace/$0/` must always be created — it's the home for all development artifacts of this issue.
