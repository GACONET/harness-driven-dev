#!/usr/bin/env bash
#
# stop_gate.sh — Layer 6: Session hygiene check.
#
# Runs at the end of a Claude Code session (Stop hook). Reports — does not block —
# any inconsistent state left behind:
#   - Local commits not pushed to remote
#   - Branch with no PR yet
#   - Last commit missing `Refs <TEAM>-<NUM>`
#   - Open PR without approval
#
# Output is purely informative. Never exits non-zero (would block agent termination).
#

YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

WARNINGS=0
report() {
    echo -e "${YELLOW}⚠  $*${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# Skip if not in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Skip on main/master — nothing to enforce
if [ -z "$BRANCH" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    exit 0
fi

echo ""
echo "── Session hygiene check (Layer 6) ──"

# Check 1: unpushed commits
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")
if [ -n "$UPSTREAM" ]; then
    UNPUSHED=$(git rev-list "$UPSTREAM"..HEAD --count 2>/dev/null || echo "0")
    if [ "$UNPUSHED" -gt 0 ]; then
        report "$UNPUSHED local commit(s) on '$BRANCH' not yet pushed."
    fi
else
    # No upstream — branch never pushed
    LOCAL_COMMITS=$(git rev-list main..HEAD --count 2>/dev/null || echo "0")
    if [ "$LOCAL_COMMITS" -gt 0 ]; then
        report "Branch '$BRANCH' has $LOCAL_COMMITS commit(s) but no upstream (never pushed)."
    fi
fi

# Check 2: last commit message has Refs
if [ -n "$(git log -1 --format='%H' 2>/dev/null)" ]; then
    LAST_MSG=$(git log -1 --format='%B' 2>/dev/null || echo "")
    if ! echo "$LAST_MSG" | grep -qE 'Refs [A-Z]+-[0-9]+'; then
        report "Last commit missing 'Refs <TEAM>-<NUM>' — harness rule #2 violated."
    fi
fi

# Check 3: PR status
if command -v gh &>/dev/null; then
    PR_JSON=$(gh pr list --head "$BRANCH" --state open --json number,reviewDecision --jq '.[0]' 2>/dev/null || echo "")
    if [ -n "$PR_JSON" ] && [ "$PR_JSON" != "null" ]; then
        REVIEW=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reviewDecision') or 'PENDING')" 2>/dev/null || echo "PENDING")
        PR_NUM=$(echo "$PR_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('number',''))" 2>/dev/null || echo "")
        if [ "$REVIEW" != "APPROVED" ]; then
            report "PR #${PR_NUM} on '$BRANCH' is open but reviewDecision=${REVIEW}."
        fi
    else
        # Branch has commits but no PR
        if [ -n "$UPSTREAM" ]; then
            report "Branch '$BRANCH' pushed but no PR opened yet."
        fi
    fi
fi

if [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ Session hygiene clean.${NC}"
else
    echo -e "${YELLOW}${WARNINGS} warning(s). Review before closing the session.${NC}"
fi

exit 0
