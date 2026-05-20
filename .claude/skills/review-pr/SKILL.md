---
name: review-pr
description: Review a pull request substantively (not just CI status). Posts a structured comment with self-review checklist, NEVER auto-approves.
user-invocable: true
allowed-tools: Bash(git *) Bash(gh *) Bash(python3 scripts/*)
argument-hint: "<ISSUE_ID> (e.g., DEMO-1) — Linear issue ref linked to the PR"
---

# Review PR

Perform a substantive review of the pull request linked to Linear issue `$ARGUMENTS`. The agent does NOT approve the PR — it posts a structured review comment so a human can make the final call. This enforces "the agent never self-approves" (Layer 5 of the harness).

## Steps

1. **Find the PR** for the current branch:
   ```bash
   PR_NUM=$(gh pr list --head "$(git branch --show-current)" --json number --jq '.[0].number')
   ```
   If no PR exists, report and stop.

2. **Fetch context**:
   - PR diff: `gh pr diff $PR_NUM`
   - Linear issue: `python3 scripts/linear_client.py get $0 --full`
   - CI status: `gh pr checks $PR_NUM`

3. **Build the self-review checklist** with these sections:

   ### Diff Audit
   - [ ] Changes scoped to the issue (no scope creep)
   - [ ] No secrets, API keys, or credentials in diff
   - [ ] No `console.log`, `print`, debug statements left behind
   - [ ] No `--no-verify` bypasses in commit history
   - [ ] No `// TODO` or `// FIXME` introduced without a follow-up issue

   ### Acceptance Criteria
   - [ ] Each checkbox in the Linear issue is addressed by the diff
   - [ ] Test coverage exists for the new behavior
   - [ ] No defensive `pytest.skip()` or `it.skip()` without linked blocker

   ### Architecture & Conventions
   - [ ] Follows existing patterns in the codebase (no random refactors)
   - [ ] Commit messages follow `<type>: <desc>\n\nRefs $0` format
   - [ ] No `Closes/Fixes/Resolves` keywords (these bypass harness gates)

   ### CI & Quality
   - [ ] CI status reported (link to run)
   - [ ] All checks green or explicitly explained
   - [ ] No unexplained skipped tests

4. **Post the comment** on the PR (non-approving):
   ```bash
   gh pr comment $PR_NUM --body-file /tmp/review-$0.md
   ```
   Use `gh pr comment` (NOT `gh pr review --approve`). The agent leaves observations; the human decides.

5. **Recommend** at the end of the comment: one of
   - `Recommendation: APPROVE` (all checks subjectively pass)
   - `Recommendation: REQUEST CHANGES` (real issues found)
   - `Recommendation: NEEDS DISCUSSION` (judgment call needed)

   This is a recommendation only — the human reviewer applies the actual GitHub review status.

## Rules

- NEVER use `gh pr review --approve` — the agent has no authority to approve.
- NEVER use `gh pr merge` — merging is a human decision.
- ALWAYS link to the Linear issue in the comment.
- ALWAYS reference the specific files/lines when reporting issues (`file.js:42`).
- If diff is huge (>500 LOC), report it as a concern in the recommendation.
- If the PR has no linked Linear issue (no `Refs $0` in commits), call it out — that violates harness Rule #2.

## Why this skill exists

CI green ≠ ready for merge. CI catches mechanical issues (syntax, tests, secrets). A substantive review catches:
- Scope creep
- Architectural drift
- Missed acceptance criteria
- Subtle security issues

This skill encodes that human judgment as a repeatable checklist. The agent prepares the review; the human signs it.
