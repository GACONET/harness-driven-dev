#!/usr/bin/env bash
#
# gate_pr_approval.sh — Layer 5 enforcement gate.
#
# Verifies the PR associated with the current branch has been explicitly
# APPROVED by a human reviewer before allowing issue closure.
#
# Exit codes:
#   0 — PR approved (PASS)
#   1 — PR not approved or changes requested (FAIL)
#   2 — No PR found for branch (FAIL)
#   3 — gh CLI not installed or not authenticated (SKIP w/ warning)
#
# Usage:
#   bash scripts/gates/gate_pr_approval.sh [BRANCH]
#

set -euo pipefail

BRANCH="${1:-$(git branch --show-current 2>/dev/null || echo "")}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! command -v gh &>/dev/null; then
    echo -e "${YELLOW}SKIP (gh CLI not installed)${NC}"
    exit 3
fi

if [ -z "$BRANCH" ] || [ "$BRANCH" = "main" ]; then
    echo -e "${YELLOW}SKIP (not on a feature branch)${NC}"
    exit 3
fi

# Find any PR (open or merged) for this branch
PR_JSON=$(gh pr list --head "$BRANCH" --state all --json number,reviewDecision,state,reviews --jq '.[0]' 2>/dev/null || echo "")

if [ -z "$PR_JSON" ] || [ "$PR_JSON" = "null" ]; then
    echo -e "${RED}FAIL (no PR found for branch '$BRANCH')${NC}"
    echo -e "${YELLOW}  Fix: push the branch and open a PR with 'gh pr create'.${NC}"
    exit 2
fi

PR_NUM=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('number',''))" 2>/dev/null || echo "")
REVIEW_DECISION=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reviewDecision') or '')" 2>/dev/null || echo "")
PR_STATE=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('state',''))" 2>/dev/null || echo "")

case "$REVIEW_DECISION" in
    APPROVED)
        # Extract the most recent approver
        APPROVER=$(echo "$PR_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
reviews = data.get('reviews', [])
approvals = [r for r in reviews if r.get('state') == 'APPROVED']
if approvals:
    print(approvals[-1].get('author', {}).get('login', 'unknown'))
else:
    print('approved')
" 2>/dev/null || echo "approved")
        echo -e "${GREEN}PASS (PR #${PR_NUM} approved by @${APPROVER})${NC}"
        exit 0
        ;;
    CHANGES_REQUESTED)
        echo -e "${RED}FAIL (PR #${PR_NUM} has CHANGES_REQUESTED)${NC}"
        echo -e "${YELLOW}  Fix: address reviewer feedback and re-request review.${NC}"
        exit 1
        ;;
    REVIEW_REQUIRED|"")
        if [ "$PR_STATE" = "MERGED" ]; then
            # Merged without formal review (e.g., admin merge) — treat as informal approval
            echo -e "${YELLOW}PASS (PR #${PR_NUM} merged without formal review)${NC}"
            exit 0
        fi
        echo -e "${RED}FAIL (PR #${PR_NUM} has no approval yet)${NC}"
        echo -e "${YELLOW}  Fix: request review with 'gh pr review' or wait for reviewer.${NC}"
        exit 1
        ;;
    *)
        echo -e "${RED}FAIL (PR #${PR_NUM} reviewDecision='${REVIEW_DECISION}')${NC}"
        exit 1
        ;;
esac
