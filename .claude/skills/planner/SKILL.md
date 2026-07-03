---
name: planner
description: Generate a detailed, step-by-step development plan from a spec and the current codebase, saving it as .workspace/ISSUE_ID/plan.md. Use this skill after /spec-writer has generated the spec, when the user wants to plan the implementation, create a task breakdown, or know exactly what files to touch and in what order before writing code. Triggers on /planner, "make a plan for ISSUE", "plan the implementation", or any request to break down development work for a specific issue.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(python3 scripts/*)
argument-hint: "<ISSUE_ID> (e.g., HAR-5)"
---

# planner

Reads the spec (`spec.md`) as the source of truth and the current codebase, then produces
a detailed, ordered development plan saved to `.workspace/$0/plan.md`.

The plan is the **contract for development**: every code change in this issue must correspond
to a task in this plan, and every task must trace back to a functional requirement in the spec.

## Pre-condition check

Before doing anything, verify the spec exists:
```
.workspace/$0/spec.md
```

If it doesn't exist, stop and tell the user to run `/spec-writer $0` first.

## Steps

### 1. Read the spec

Read `.workspace/$0/spec.md` in full. Extract:
- All Functional Requirements (FR-1, FR-2, ...)
- The "Files to modify" table
- The "Functions / methods" section
- The Acceptance Criteria

This is your source of truth. The plan must cover every FR.

### 2. Deep codebase read

Read every file listed in the spec's "Files to modify" table — completely, not just the relevant sections. Understanding the full context prevents surprises mid-implementation.

Also read:
- `tests/test_app.js` — understand the test structure (describe/it blocks, helpers used)
- Any file that imports from or is imported by the files to modify

Grep for every function name mentioned in the spec to confirm it exists and find its exact location (file + line number).

### 3. Identify all tasks

From the spec's FRs and your codebase reading, derive a complete, ordered list of development tasks. A task is atomic: one coherent code change to one area. Tasks must be ordered so that each one can be implemented without depending on a later task.

Group tasks into phases:
- **Phase 1 — Foundation**: data structure changes, new helper functions, localStorage keys
- **Phase 2 — Core logic**: main feature functions
- **Phase 3 — UI/DOM**: HTML changes, event listeners, rendering logic
- **Phase 4 — Tests**: one test task per FR
- **Phase 5 — Polish**: edge cases, error states, accessibility

### 4. Write `.workspace/$0/plan.md`

Use this exact structure:

```markdown
# Development Plan: [Issue Title] ([ISSUE_ID])

**Spec:** `.workspace/$0/spec.md`
**Date:** [today's date YYYY-MM-DD]
**Estimated tasks:** [N]

---

## Summary

[2-3 sentences: what will be built, what the main implementation approach is, and which
files are the primary targets.]

---

## Task Breakdown

### Phase 1 — Foundation

#### TASK-1: [Short, imperative task name]

- **FR:** FR-X
- **File:** `path/to/file.ext` (line ~N)
- **What:** [One paragraph describing exactly what to add or change. Be specific enough
  that a developer can implement it without re-reading the spec.]
- **How:**
  ```javascript
  // Show a minimal skeleton or pseudocode if it helps clarify the change
  ```
- **Acceptance check:** [How to verify this specific task is correct before moving on]

#### TASK-2: [Short, imperative task name]
...

### Phase 2 — Core logic
...

### Phase 3 — UI/DOM
...

### Phase 4 — Tests

#### TASK-N: Add test for FR-X

- **FR:** FR-X
- **File:** `tests/test_app.js`
- **What:** Add a `describe`/`it` block that verifies [specific behavior].
- **Test structure:**
  ```javascript
  describe('[feature name]', () => {
    it('[should do X when Y]', () => {
      // setup
      // action
      // assertion
    });
  });
  ```
- **Acceptance check:** `npm test` passes with the new test included.

### Phase 5 — Polish
...

---

## Dependency Map

[List any tasks that must be completed before another can start]

- TASK-2 depends on TASK-1 (needs the data structure defined in TASK-1)
- TASK-5 depends on TASK-3 (needs the DOM element created in TASK-3)

---

## Files Changed Summary

| File                  | Tasks          | Type of change              |
|-----------------------|----------------|-----------------------------|
| `app.js`              | TASK-1, TASK-3 | New functions, event handler |
| `index.html`          | TASK-4         | New element added            |
| `styles.css`          | TASK-5         | New CSS class                |
| `tests/test_app.js`   | TASK-6         | New test cases               |

---

## Risk & Edge Cases

[List anything that could go wrong during implementation, or edge cases the developer
must handle even if not explicitly mentioned in the spec.]

- [Risk 1: e.g., "localStorage may be unavailable in private browsing — handle with try/catch"]
- [Edge case 1: e.g., "Empty task list: the counter should show 0, not NaN"]

---

## Definition of Done

All tasks completed when:
- [ ] All TASK-N items implemented
- [ ] `npm test` passes
- [ ] Acceptance criteria in spec.md all checkable as done
- [ ] No console errors in the browser
```

### 5. Confirm to the user

```
✓ Plan generado para $0

  .workspace/$0/plan.md

  Phases  : [N]
  Tasks   : [N total]
  Files   : [list the file names]

El plan cubre todos los FRs del spec.

Siguiente paso: implementa las tareas en orden. Cualquier cambio al scope
debe actualizarse primero en spec.md, luego en plan.md, luego en el código.
```

---

## Rules

- Read the spec completely before reading the codebase. The spec defines WHAT; the codebase defines WHERE and HOW.
- Every FR in the spec must appear in at least one task. If an FR produces no tasks, that's a bug in the spec.
- Every task must reference its FR. This traceability lets us verify the plan covers all requirements.
- Tasks must be atomic and ordered. A developer should be able to implement TASK-1, commit, then do TASK-2 — without going back.
- The plan lives at `.workspace/$0/plan.md`. If `spec.md` changes, the plan must be regenerated or updated to match.
- Do not invent tasks not traceable to the spec. If you notice something the spec missed, add it under "Risk & Edge Cases" and tell the user to update the spec first.
