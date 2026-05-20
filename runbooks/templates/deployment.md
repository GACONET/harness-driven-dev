# Runbook — <RUNBOOK_TITLE>

| | |
|---|---|
| **Owner** | <OWNER> |
| **Created** | <DATE> |
| **Last reviewed** | _(fill in on first commit; quarterly thereafter)_ |
| **Frequency** | _(one-off / monthly / per-release)_ |
| **Estimated duration** | _(e.g., 30 min)_ |

## 1. When to run this

The trigger or schedule that justifies this manual procedure.

- _When `<EVENT>` happens_
- _Before/after `<MILESTONE>`_
- _As part of `<RELEASE_PROCESS>`_

If you find yourself running this more than once a month, **it should be automated** — file an issue.

## 2. Pre-flight checklist

Before starting:

- [ ] All CI checks green on the artifact being deployed
- [ ] Change advertised in `#deploys` (or your channel)
- [ ] Rollback artifact identified and reachable: `<ROLLBACK_REF>`
- [ ] Maintenance window confirmed (if applicable)
- [ ] On-call engineer paged for awareness

## 3. Procedure

Each step has: command + expected outcome + go/no-go gate.

### Step 1 — `<NAME>`

```bash
<COMMAND_1>
```

**Expected**: `<OUTPUT_OR_STATE>`

**Go/no-go**: if you see `<UNEXPECTED>`, STOP. Run `<DIAGNOSTIC>` and escalate.

### Step 2 — `<NAME>`

```bash
<COMMAND_2>
```

**Expected**: `<OUTPUT_OR_STATE>`

### Step 3 — `<NAME>`

```bash
<COMMAND_3>
```

**Expected**: `<OUTPUT_OR_STATE>`

## 4. Verification

After all steps complete:

- [ ] Smoke test: `<URL_OR_COMMAND>` returns `<EXPECTED>`
- [ ] Dashboard `<DASHBOARD>` shows healthy state for `<TIME>`
- [ ] No new alerts in `<TIME_WINDOW>`
- [ ] Sample user action works: `<MANUAL_CHECK>`

## 5. Rollback

If verification fails:

```bash
<ROLLBACK_COMMAND>
```

**Expected after rollback**: traffic returns to the previous version within `<TIME>`. Confirm with the same verification steps as section 4.

If rollback also fails: escalate to `<NEXT_OWNER>`. **Do not retry the deployment.**

## 6. Communication

Post-deployment announcement template:

> **Deploy complete — <SERVICE> <VERSION>**
> Started: `<TIME>` · Finished: `<TIME>` · Status: healthy
> Changes: `<CHANGELOG_LINK>`
> Rollback ref: `<ROLLBACK_REF>` (keep handy for 1 hour)

## 7. After-action

- [ ] Update `Last reviewed` on this runbook if any step changed
- [ ] If a step was added, document why
- [ ] If this took longer than `<EXPECTED_DURATION>`, note what slowed it down

## Related runbooks

- `<LINK_TO_RELATED_DEPLOY_OR_INCIDENT_RUNBOOK>`
