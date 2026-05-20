#!/usr/bin/env bash
#
# seed_demo.sh — Idempotently create the 3 demo issues in Linear.
#
# Issues created:
#   HAR-DEMO-1 — Secret Blocked Demo
#   HAR-DEMO-2 — CI Bug Demo
#   HAR-DEMO-3 — PR Approval Demo
#
# Each issue gets a description with pre-filled acceptance criteria,
# pre-checked for HAR-DEMO-3 (so Gate 4 of close_issue.sh passes during the demo).
#
# Usage:
#   bash scripts/seed_demo.sh            # create or update
#   bash scripts/seed_demo.sh --dry-run  # show what would happen
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        *) ;;
    esac
done

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

seed() {
    local id="$1"
    local title="$2"
    local body="$3"

    echo -e "${YELLOW}Seeding ${id}: ${title}${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo "  (dry-run — no API call)"
        return
    fi

    # Try to fetch existing
    if python3 "$SCRIPT_DIR/linear_client.py" get "$id" --full &>/dev/null; then
        echo -e "  ${GREEN}exists — updating description${NC}"
        python3 "$SCRIPT_DIR/linear_client.py" update "$id" --description "$body" || true
    else
        echo -e "  ${GREEN}creating${NC}"
        python3 "$SCRIPT_DIR/linear_client.py" create --title "$title" --description "$body" || {
            echo "  ⚠️  create failed — check LINEAR_API_KEY and team key"
            return 1
        }
    fi
}

BODY_DEMO1='## Objective
Demonstrate that a hardcoded secret is blocked by the pre-commit hook (Layer 1)
and by CI (Layer 2) if the local hook is bypassed.

## Acceptance Criteria
- [ ] Hardcoded API key in source is blocked by gitleaks pre-commit
- [ ] After fix (using .env + process.env), commit is accepted
- [ ] If --no-verify is used, GitHub Actions gitleaks job fails the PR

## Technical Notes
- Edit `app.js` to introduce a fake `LINEAR_API_KEY = "lin_api_..."`
- Show pre-commit blocking
- Fix using process.env
- Run `npm test` to confirm app still works
'

BODY_DEMO2='## Objective
Demonstrate that a bug caught by CI auto-creates a tracked Linear bug
via the linear-bridge.yml workflow (Layer 2 + Layer 4).

## Acceptance Criteria
- [ ] Introduce a regression in `deleteTask` (filter inverted)
- [ ] Local tests pass (path is uncovered)
- [ ] Push triggers CI failure
- [ ] linear-bridge.yml fires ci_failure_bridge.py
- [ ] New Linear bug appears with run link, branch, author

## Technical Notes
- Tests live in `tests/test_app.js`
- After demo, run `git revert HEAD --no-edit` to undo
'

BODY_DEMO3='## Objective
Demonstrate that /close-issue blocks when the PR has no human approval,
even if everything else is green (Layer 5).

## Acceptance Criteria
- [x] Branch created and PR opened
- [x] Tests passing
- [x] CI green
- [x] Acceptance criteria checked (this checklist)

## Technical Notes
- Try `/close-issue HAR-DEMO-3` → expect Gate 3 (PR approval) to FAIL
- Run `gh pr review <N> --approve` from a second account
- Retry `/close-issue` → expect all 4 gates PASS
- Verify evidence comment in Linear cites the reviewer
'

seed "HAR-DEMO-1" "Demo 1: Secret Blocked" "$BODY_DEMO1"
seed "HAR-DEMO-2" "Demo 2: CI Bug → Linear Bridge" "$BODY_DEMO2"
seed "HAR-DEMO-3" "Demo 3: PR Approval Gate" "$BODY_DEMO3"

echo ""
echo -e "${GREEN}Done. Three demo issues seeded.${NC}"
