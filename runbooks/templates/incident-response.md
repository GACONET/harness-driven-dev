# Runbook — <RUNBOOK_TITLE>

| | |
|---|---|
| **Owner** | <OWNER> |
| **Created** | <DATE> |
| **Last reviewed** | _(fill in on first commit; quarterly thereafter)_ |
| **Severity** | _(S1 / S2 / S3)_ |
| **Estimated MTTR** | _(e.g., 15 min)_ |

## 1. Trigger

How do you know you need this runbook? List concrete signals.

- [ ] Alert fires: `<ALERT_NAME>`
- [ ] Symptom in dashboard: `<DASHBOARD_PANEL>`
- [ ] User report: `<DESCRIPTION>`
- [ ] Log pattern: `<GREP_PATTERN>`

## 2. Severity & impact

- **What's broken**: `<USER_VISIBLE_IMPACT>`
- **Who's affected**: `<TENANTS | REGIONS | PERCENT>`
- **What's NOT affected**: `<SCOPE_LIMITS>` (write this so you know what to communicate)

## 3. Diagnosis (confirm the scenario)

Commands to confirm before acting. Each command should print something distinctive:

```bash
# Confirm the alert is real (not a flap)
<COMMAND_1>

# Check current state
<COMMAND_2>

# Check upstream dependency
<COMMAND_3>
```

If any of these don't match the expected pattern, **this is not the runbook for your problem** — escalate.

## 4. Immediate mitigation (stop the bleeding)

What to do RIGHT NOW to reduce user impact, even if the root cause isn't fixed:

```bash
<MITIGATION_COMMAND>
```

Expected outcome: `<METRIC_OR_ALERT_SHOULD_DO_THIS>`.

If mitigation doesn't work in `<TIME_BUDGET>`: escalate to `<ON_CALL_NEXT>`.

## 5. Resolution (actual fix)

Steps to fix the root cause:

1. `<STEP_1>` — what and why
2. `<STEP_2>` — what and why
3. `<STEP_3>` — what and why

## 6. Verification

How you know it worked:

- [ ] `<METRIC>` back to baseline (link to dashboard)
- [ ] No new alerts in `<TIME_WINDOW>`
- [ ] Synthetic check passes: `<CHECK_COMMAND>`

## 7. Comms template

What to post in `#incidents` (or your channel):

> **Status update — <SERVICE>**
> Detected at `<TIME>`. Symptom: `<USER_IMPACT>`. Mitigation applied at `<TIME>`. Investigating root cause.

When resolved:

> **Resolved — <SERVICE>**
> Root cause: `<RCA>`. Postmortem: `<LINK>`.

## 8. After-action

- [ ] File postmortem (even if low-severity)
- [ ] Update this runbook if a step was wrong or missing
- [ ] If this is the **second occurrence**, link to the postmortem here:
  - `<POSTMORTEM_LINK>`
- [ ] If this happens a **third time**, the fix belongs in code or infra — not in this runbook

## Related runbooks

- `<LINK_TO_RELATED_RUNBOOK>`
