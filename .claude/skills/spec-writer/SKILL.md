---
name: spec-writer
description: Generate a detailed, implementation-ready development specification from a Linear issue and save it as the source of truth in .workspace/ISSUE_ID/. Use this skill whenever the user wants to write a technical spec, generate implementation details from a Linear ticket, or before starting any development work. Triggers on /spec-writer, "write spec for ISSUE", "generate spec", or any request to document what needs to be built for a specific Linear issue. Always run this after /start-issue and before /planner.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(python3 scripts/*), Bash(New-Item *), Bash(mkdir *)
argument-hint: "<ISSUE_ID> (e.g., HAR-5)"
---

# spec-writer

Generates a deep, implementation-ready development specification from a Linear issue.
Saves two files — English and Spanish — to `.workspace/$0/`.
The spec becomes the **source of truth**: all code changes must trace back to it.

## Steps

### 1. Fetch the full issue from Linear

```bash
python3 scripts/linear_client.py get $0 --full
```

If the issue is not found, stop immediately and tell the user.

Show the user: title, description, acceptance criteria, and current state.

### 2. Move issue to "In Progress"

```bash
python3 scripts/linear_client.py move $0 "In Progress"
```

This must happen before any other work. Confirm to the user:
```
✓ $0 moved to In Progress
```

### 3. Ensure the workspace directory exists

```
.workspace/$0/
```

Create it if it doesn't exist. On Windows use:
```powershell
New-Item -ItemType Directory -Force .workspace\$0
```
On Unix:
```bash
mkdir -p .workspace/$0
```

### 4. Explore the codebase for technical context



Before writing a single line of the spec, understand what already exists.
This step is what separates a useful spec from a vague one.

- Read `index.html`, `app.js`, `styles.css` to understand the app structure
- Read `tests/test_app.js` to understand what's already covered
- Grep for any functions, CSS classes, element IDs, or keywords that appear in the issue description
- Identify the exact files and line ranges that will need to change

Take notes mentally. The Technical Design section will reference real file paths and real function names — not hypothetical ones.

### 5. Write `.workspace/$0/spec.md` (English)

Use this exact structure. Fill every section — leave nothing as a placeholder.

```markdown
# Spec: [Issue Title] ([ISSUE_ID])

**Linear Issue:** [ISSUE_ID]
**Status:** Draft
**Date:** [today's date YYYY-MM-DD]

---

## Overview

[One paragraph: WHAT needs to be built and WHY. Synthesize the Linear description into a
clear statement of intent. Include the business value or user impact. Do not just copy-paste
the issue description — interpret and clarify it.]

---

## Scope

### Included
- [Specific deliverable 1]
- [Specific deliverable 2]

### Out of Scope
- [Explicit list of related things that are NOT part of this issue]
- [Boundaries that prevent scope creep]

---

## Functional Requirements

Each requirement is numbered (FR-1, FR-2, ...) and specific enough to implement without
re-reading the Linear issue.

| ID   | Requirement                                      | Derived from         |
|------|--------------------------------------------------|----------------------|
| FR-1 | [Specific, testable, implementation-level req]   | AC #1 / Description  |
| FR-2 | [Specific, testable, implementation-level req]   | AC #2                |

---

## Technical Design

### Files to modify

| File              | What changes                                     |
|-------------------|--------------------------------------------------|
| `app.js`          | [Specific function/logic to add or change]       |
| `index.html`      | [Specific elements to add or modify]             |
| `styles.css`      | [Specific classes to add or modify]              |
| `tests/test_app.js` | [New test cases to add]                        |

### New files to create

| File              | Purpose                                          |
|-------------------|--------------------------------------------------|
| (if any)          |                                                  |

### Functions / methods

For each function to add or change, provide a mini-signature:

```
function functionName(param1, param2)
  Purpose    : [what it does in one sentence]
  Inputs     : [param types and what they represent]
  Returns    : [return value / side effects]
  DOM impact : [element IDs read or mutated, if any]
  Storage    : [localStorage keys read or written, if any]
  Events     : [events emitted or listeners attached, if any]
```

### Data & state

- **LocalStorage**: [key names, data shape stored, when read/written]
- **DOM elements**: [IDs / classes that will be added, removed, or mutated]
- **Events**: [custom events fired or consumed, with their payload]

### UI changes

[Describe visual changes. Reference existing element IDs or CSS class names where possible.
If a new element is introduced, describe its structure.]

---

## Acceptance Criteria

Copied verbatim from the Linear issue:

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

---

## Constraints & Assumptions

[Every ambiguity found in the Linear issue is resolved here with an explicit decision.]

- **Assumption:** [State the assumption and why it was made]
- **Constraint:** [Technical or business constraint that limits the design]

---

## Test Plan

| FR   | How to verify                                    |
|------|--------------------------------------------------|
| FR-1 | [Unit test in test_app.js: describe/it block]    |
| FR-2 | [Manual check: open app, do X, expect Y]         |
```

### 6. Write `.workspace/$0/spec.es.md` (Spanish)

Translate the complete spec.md into Spanish. Every section, every table, every requirement.
Keep all file paths, function names, element IDs, and code snippets in their original form (do not translate code).

### 7. Confirm to the user

```
✓ Spec generado para $0

  .workspace/$0/spec.md      (English)
  .workspace/$0/spec.es.md   (Spanish)

  Functional Requirements : [N]
  Files to modify         : [list the file names]

Siguiente paso: ejecuta /planner $0 para generar el plan de desarrollo.
```

---

## Rules

- Use `--full` when fetching the issue — the truncated output misses most of the description.
- Explore the codebase **before** writing. The spec must reference real file paths and real function names.
- Resolve every ambiguity in the issue. Do not leave open questions — document your decision under "Constraints & Assumptions".
- The spec is the **source of truth**. If requirements change mid-development, update `spec.md` first, then the code.
- Both files must be fully written before reporting success.
- Do not create empty or placeholder sections. If a section doesn't apply, write "N/A — [reason]".
