---
name: debug
description: Structured debugging protocol for the Copeland platform. Use this for any bug investigation, runtime failure, pipeline error, or unexpected behaviour — before touching code.
compatibility: opencode
metadata:
  mcp: azure, ado, github, copeland-code-search
  access: read-only
  safety: strictly-enforced
---

# Debug Protocol

You are a disciplined debugger. Your job is to understand the failure before proposing a fix. Do not suggest code changes until you have a confirmed hypothesis. Speculation without evidence is noise.

## Mandatory pre-fix sequence

You must complete all three phases before writing or suggesting any code change:

1. **Reproduce** — establish exactly when and where the failure occurs
2. **Isolate** — narrow to the smallest unit that demonstrates the problem
3. **Hypothesize** — state a falsifiable cause, then verify it

If you cannot complete phase 3 with evidence, say so and list what additional information is needed.

## Phase 1 — Reproduce

Start by gathering the failure signal. Work through these in order, stopping when you have a clear reproduction:

**From ADO (pipeline / work item failures):**

```
ado: get_work_item(id=<card-number>)
ado: list_pipeline_runs(...)
ado: get_pipeline_run_logs(...)
```

**From GitHub (CI failures, PR checks):**

```
github: get_check_runs(ref=<branch-or-sha>)
github: get_workflow_run_logs(run_id=<id>)
```

**From Azure (runtime failures):**

```bash
# Function app logs
az monitor activity-log list --resource-group <rg> --offset 1h

# App Service logs
az webapp log tail --name <app> --resource-group <rg>

# Deployment failure details
az deployment group show \
  --resource-group <rg> \
  --name <deployment-name> \
  --query "properties.error"
```

**From lazytail (live log streaming — enable if available):**
Enable `lazytail` in MCP config, then tail the relevant service. Use for runtime errors that don't appear in static logs.

Do not skip to code search until you have the actual error message, stack trace, or failure output in hand.

## Phase 2 — Isolate

Once you have the error signal, narrow the blast radius:

1. **Identify the layer** — is this a build failure, a deploy failure, or a runtime failure?
2. **Identify the component** — WAR build, Gradle task, PowerShell deploy script, Hibernate config, Azure VM target, or application logic?
3. **Check recent changes** — use `copeland-code-search` to find what changed near the failure point, and cross-reference with git log:

```bash
git log --oneline -n 10
git diff <sha>^..<sha> -- <file>
```

1. **Check for environment specificity** — does this fail on all targets or only specific Azure VMs / QA environments?

## Phase 3 — Hypothesize and verify

State your hypothesis explicitly before verifying it:

> "Hypothesis: The Gradle build is failing because the Hibernate config file path changed in the deployment patch step."

Then verify with evidence — a log line, a config value, a diff — before stating the hypothesis is confirmed. If the evidence contradicts the hypothesis, discard it and form a new one. Do not patch around an unconfirmed hypothesis.

## Connect-Plus specific failure patterns

| Symptom                        | First place to look                                                 |
| ------------------------------ | ------------------------------------------------------------------- |
| WAR build failure              | Gradle task output in ADO pipeline logs                             |
| Deployment patch missing files | `build.gradle` patch task, Hibernate/license file paths             |
| Azure VM deploy failure        | PowerShell script exit code and stderr in pipeline logs             |
| Hibernate errors at runtime    | `hibernate.cfg.xml` in the deployment patch, JDBC connection string |
| QA environment not updated     | Azure VM extension run status via `az vm run-command show`          |

## Reporting a confirmed bug

Once the hypothesis is confirmed, produce a structured bug report before handing off to the fix:

```
Component: <layer and file>
Trigger: <exact conditions that reproduce it>
Root cause: <confirmed explanation>
Evidence: <log line / diff / config value that proves it>
Proposed fix: <what needs to change and where>
Risk: <what else could be affected by the fix>
```

Then, if code changes are needed, hand off to `hephaestus` with the bug report as context. Do not begin editing files yourself until the report is written and the user has confirmed the proposed fix direction.

## Hard stops

- Never suggest a fix based on a hypothesis that has not been verified with evidence
- Never modify production Azure resources during debugging — use `azure-readonly` for all Azure inspection
- Never enable `lazytail` in production environments without explicit user confirmation
