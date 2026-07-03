---
name: developer
description: Execute the development plan for a Linear issue following TDD — implement tests first, then production code, with an automated fix-loop (max 5 attempts per task) before escalating to the user. Use this skill whenever the user says /developer, "implement the plan for ISSUE", "execute the plan", "start coding ISSUE", or "develop ISSUE". Always requires a plan.md in .workspace/ISSUE_ID/ — run /planner first if it doesn't exist.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(npm test), Bash(npm run *), Bash(git *)
argument-hint: "<ISSUE_ID> (e.g., HAR-5)"
---

# developer

Executes the development plan from `.workspace/$0/plan.md` following a strict TDD cycle.
Tracks every task in `.workspace/$0/progress.md` as an audit trail.

The core philosophy: tests define correctness. Write them first so they fail, then make them pass. Never skip a failing test — fix the root cause.

---

## Phase 0 — Pre-flight

Before writing a single line of code, establish ground truth.

### 1. Verify the plan exists

Check that `.workspace/$0/plan.md` exists. If it doesn't, stop:
```
✗ No plan found at .workspace/$0/plan.md
Run /planner $0 first to generate the development plan.
```

### 2. Feature branch

Check the current branch with `git branch --show-current`.

- If already on a feature branch for this issue (e.g. `feat/$0-*`), continue — no action needed.
- If on `main` or any other branch, ask the user:

```
⚠ You are on branch '[current-branch]'.

How do you want to handle the feature branch?

  [A] Create it automatically  →  git checkout -b feat/$0-<slug>
  [B] I'll create it manually  →  you run the git command yourself

Reply A or B.
```

Wait for the user's reply before continuing.

- If **A**: run `git checkout -b feat/$0-<slug>` (derive the slug from the issue title in plan.md — lowercase, hyphens, max ~5 words). Confirm the branch name to the user.
- If **B**: show the suggested command and wait for the user to confirm they are on the right branch before proceeding.

### 3. Read context

Read both files completely:
- `.workspace/$0/spec.md` — the source of truth for WHAT to build
- `.workspace/$0/plan.md` — the ordered task list for HOW to build it

Extract from plan.md:
- All task IDs and their descriptions (TASK-1, TASK-2, ...)
- Which tasks are "test" tasks (they touch `tests/test_app.js`)
- Which tasks are "production" tasks (they touch `app.js`, `index.html`, `styles.css`, etc.)
- The dependency map

### 4. Record the baseline

```bash
npm test
```

Record how many tests currently pass. This is your baseline — after the full implementation, you must have: baseline_count + (number of new test tasks) tests passing.

Initialize `.workspace/$0/progress.md`:

```markdown
# Progress: [Issue Title] ($0)

**Started:** [today's date YYYY-MM-DD HH:MM]
**Baseline tests:** [N passing]
**Plan tasks:** [total count]

## Tasks

(tasks will be appended here as they complete)
```

---

## Phase 1 — TDD: Write tests first

Identify all tasks in plan.md that modify `tests/test_app.js` (typically labeled as the "Tests" phase).

Implement **all test tasks first**, before touching any production file. The reason: a test written against non-existent code will fail immediately, giving you a clear red-green-refactor signal. If you write tests after the implementation, you lose confidence that the tests actually catch regressions.

For each test task, in order:
1. Read the target file at the exact line range referenced in plan.md
2. Add the test code as described in the "How" section of the task
3. After adding each test, append to `progress.md`:
   ```
   - [ ] TASK-N: [task name] — test written, awaiting red confirmation
   ```

After all test tasks are written, run:
```bash
npm test
```

**Expected outcome**: existing tests still pass, new tests FAIL. This is correct — it proves the tests are actually testing something that doesn't exist yet.

If a new test passes at this point, flag it to the user:
```
⚠ TASK-N test passed before implementation — this may mean:
  - The feature already exists (check the codebase)
  - The test assertion is too weak
Please review before continuing.
```

Update progress.md for each test task:
```
- [~] TASK-N: [task name] — test written ✓ (failing as expected — red phase)
```

---

## Phase 2 — Implement production code

Now work through every non-test task in the order they appear in plan.md. The order matters because of the dependency map — TASK-1 may declare a variable that TASK-2 reads.

For each task:

### Implement

1. Read the target file. Use the file path and line number from plan.md to find the exact location.
2. Apply the change described in the task's "What" and "How" sections. Stay surgical — change only what the task describes, nothing more.

### Test and fix loop

After each change, run:
```bash
npm test
```

**If all tests pass:**
Update progress.md:
```
- [x] TASK-N: [task name] — ✓ tests passed ([date])
```
Continue to the next task.

**If any test fails**, enter the fix loop. You get **5 attempts maximum**:

```
Attempt 1/5: Read the failure message. Identify the specific assertion that failed and why.
             Apply a targeted fix. Run npm test.

Attempt 2/5: If still failing, re-read the relevant spec.md section and the task description.
             Check if the failure is in the new test or a regression in an existing one.
             Apply fix. Run npm test.

Attempt 3/5: Re-read the complete target file from scratch — not just the section you changed.
             The bug may be in how your change interacts with surrounding code.
             Apply fix. Run npm test.

Attempt 4/5: Check the dependency map. Maybe a prerequisite task left the file in an unexpected state.
             Verify your change against a fresh read of the spec.
             Apply fix. Run npm test.

Attempt 5/5: Final attempt. Apply the most conservative fix you can reason about confidently.
             Run npm test.
```

**If attempt 5 fails**, stop immediately and report to the user:

```
✗ Stuck on TASK-N after 5 attempts.

Failing test:
  [test name and describe/it block]

Error:
  [exact error message from npm test]

What I tried:
  1. [brief description of attempt 1]
  2. [brief description of attempt 2]
  ...

What I think the problem is:
  [your best diagnosis of the root cause]

Please review and tell me how to proceed.
```

Do not guess further. Human judgment is cheaper than wrong fixes at this point.

---

## Phase 3 — Final validation

After all tasks (test + production) are implemented:

### Run the full suite
```bash
npm test
```

Expected: baseline_count + new_test_count tests passing. Zero failures.

### Update progress.md with the final summary

```markdown
## Summary

**Completed:** [date]
**Tasks implemented:** [N]/[N]
**Tests added:** [N]
**Final test count:** [N] passing, 0 failing

### All tasks
- [x] TASK-1: ...
- [x] TASK-2: ...
(full list)
```

### Write `.workspace/$0/dev-summary.md`

This file is the human-readable record of the entire development session. It goes beyond what `progress.md` tracks (task status) — it captures the reasoning, decisions, and surprises that future maintainers would need to understand why the code looks the way it does.

Write it now, while the context is fresh:

```markdown
# Dev Summary: [Issue Title] ($0)

**Issue:** $0
**Date:** [YYYY-MM-DD]
**Duration:** [start time → end time]
**Developer:** Claude (automated via /developer skill)

---

## What was built

[2–3 paragraphs summarizing what was implemented. Write for a developer who hasn't read
the spec — they should understand the feature just from this section.]

---

## Approach

[Describe the main technical approach taken. Why this approach and not another?
Reference the spec's Technical Design section and explain where you followed it exactly
and where reality diverged.]

---

## Decisions made during implementation

For each non-trivial decision, document it:

### Decision: [Short title, e.g., "Used toLowerCase() on both sides of filter comparison"]
- **What:** [The specific choice made]
- **Why:** [The reason — spec requirement, edge case discovered, constraint found in the code]
- **Alternative considered:** [What else could have been done]
- **Impact:** [What breaks if this decision is changed]

(Repeat for each significant decision)

---

## Deviations from plan.md

[If everything went exactly as planned, write "None — implementation matched plan exactly."
Otherwise, for each deviation:]

### Deviation in TASK-N
- **Plan said:** [what plan.md described]
- **What actually happened:** [what you did instead]
- **Why:** [the reason — line number was wrong, function signature different, dependency issue, etc.]

---

## Fix loops triggered

[If no task required more than 1 attempt, write "None — all tasks passed on first attempt."
Otherwise:]

### TASK-N — [N] attempts needed
- **Symptom:** [what failed and the error message]
- **Root cause:** [what was actually wrong]
- **Fix applied:** [what change resolved it]

---

## Observations for future work

[Things noticed during implementation that were outside the current scope but matter:
potential bugs, missing edge cases, tech debt, tests that could be stronger, etc.
These are NOT things that were implemented — just things worth knowing.]

- [Observation 1]
- [Observation 2]

---

## Test coverage added

| Test | FR | What it verifies |
|------|----|-----------------|
| [test name] | FR-X | [one line description] |

**Final test count:** [N] passing (was [baseline] before this issue)
```

### Confirm to the user

```
✓ Implementation complete for $0

  Tasks completed : [N]/[N]
  Tests added     : [N]
  Tests passing   : [N] (was [baseline])
  Tests failing   : 0

Artifacts:
  .workspace/$0/progress.md    — task-by-task audit trail
  .workspace/$0/dev-summary.md — decisions, deviations, observations

Next step: run /close-issue $0
  → runs gates (tests + CI + acceptance criteria)
  → posts evidence to Linear
  → moves issue to Done
```

---

## Commit discipline

**NEVER commit automatically.** The user must review all changes before any commit is made.

After Phase 3 validation, present the diff summary and suggested commit messages, then stop:

```
📋 Ready to commit — please review the changes above.

Suggested commits (in order):

  1. test: add <feature> tests for $0
     Files: tests/test_app.js

  2. feat: <short description of what was built>
     Files: app.js, index.html, styles.css

Refs $0 must appear in every commit message.
Use `Refs` — never `Closes`, `Fixes`, or `Resolves` (those bypass harness gates).

When you're ready, ask me to commit or run git commands yourself.
```

Do NOT run `git add` or `git commit` unless the user explicitly asks.

---

## Guard rails

**On plan.md**: Treat it as read-only during execution. If you find the plan has a mistake (wrong line number, missing dependency, incorrect pseudocode), do not silently work around it. Flag it:
```
⚠ plan.md TASK-N references line 55 of app.js, but that function is at line 72.
Should I proceed with the correct line, or update the plan first?
```

**On test integrity**: A test is only valid if it can fail. Never delete, weaken, or skip an assertion to make a test pass. The fix belongs in the implementation, not the test — unless the test itself was wrong (which should be rare and requires user confirmation).

**On scope**: The plan defines the scope. If during implementation you notice something the spec missed that could cause a bug, document it in progress.md under a "Observations" section and mention it to the user after completing the current task. Do not expand scope unilaterally.
