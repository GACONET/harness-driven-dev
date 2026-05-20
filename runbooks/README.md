# Operational Runbooks

Versioned, grep-able runbooks for incidents and deployments. Designed for on-call use at 3 AM.

## What lives here

- `templates/` — starter templates (don't edit, copy from)
- `<slug>.md` — actual runbooks for your team (one per scenario)

## When to write a runbook

Write one when:

- An incident happens for the second time (the first time is a postmortem; the second is a runbook)
- A manual deployment step exists that more than one person needs to do
- A piece of operational knowledge lives only in someone's head

Don't write one when:

- The procedure is fully automated (your CI/CD is the runbook)
- The scenario hasn't happened yet (you're guessing — wait for reality)
- A single tribal expert knows it and refuses to write it down (the runbook IS the fix)

## How to create one

```bash
# Via the harness skill (recommended)
/new-runbook incident db-connection-pool-exhausted

# Or manually
cp runbooks/templates/incident-response.md runbooks/<your-slug>.md
```

Fill in the `<PLACEHOLDER>` markers. Commit with `Refs <TEAM>-<N>` so the harness logs it.

## Anatomy of a good runbook

Every runbook in this repo follows the same shape:

1. **Trigger** — how do you know you need this runbook?
2. **Owner** — who maintains it
3. **Severity / impact** — what's at stake
4. **Diagnosis** — commands to confirm the scenario
5. **Mitigation** — immediate steps to stop the bleeding
6. **Resolution** — the actual fix
7. **Verification** — how to confirm it worked
8. **Postmortem hook** — if this is the second occurrence, link to the incident

This shape is grep-able. Your on-call can `grep -l "trigger" runbooks/` to find the right one.

## Maintenance

- **Quarterly review**: an owner re-reads their runbook. If it's stale, they update or delete it.
- **Post-incident update**: every postmortem checks "did our runbook help?". If not, the runbook gets a PR.
- **Stale check**: runbooks with `Last reviewed:` older than 6 months get flagged by the harness (TODO: extend `stop_gate.sh` to check this).

## Templates

| Template | When to use |
|----------|-------------|
| [incident-response.md](templates/incident-response.md) | Production is broken and you need to fix it |
| [deployment.md](templates/deployment.md) | Manual rollout step that needs reproducibility |

For other scenarios (disaster recovery, compliance audits, security incidents), copy and adapt.
