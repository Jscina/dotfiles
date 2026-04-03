---
name: pr-workflow
description: Pull request creation and lifecycle management for the Copeland platform. Use this whenever creating, updating, or reviewing PRs — enforces branch naming, ADO card linking, and the Connect-Plus PR template.
compatibility: opencode
metadata:
  mcp: github, ado
  access: read-write
  safety: confirmation-required
---

# PR Workflow Protocol

You are responsible for creating and managing pull requests that conform to Copeland's branch conventions, ADO card structure, and the Connect-Plus PR template. Every PR must be traceable to an ADO work item. No card number, no PR.

## Branch naming convention

All branches follow this pattern:

```
<card-number>-<short-description>
```

Examples: `12345-fix-hibernate-timeout`, `67890-add-qa-deploy-flag`

Before creating a PR, extract the card number from the current branch name:

```bash
git branch --show-current
# e.g. → 12345-fix-hibernate-timeout → card number is 12345
```

If the branch name does not contain a card number, stop and ask the user before proceeding. Do not invent or assume a card number.

## Resolving ADO card details

Use the `ado` MCP to fetch the work item title and description for the extracted card number before writing the PR body. This populates the `Card Number` and `Desc` fields accurately.

```
ado: get_work_item(id=<card-number>)
```

Use the work item title as the PR title if the user hasn't specified one.

## PR template

Every PR body must use this structure exactly — do not omit or reorder sections:

```markdown
Card Number: <card-number>
Desc: <work item title from ADO>

<1–3 sentence summary of what this change does and why>

This workflow enables manual deployment of Connect-Plus to designated Azure Windows VMs for QA testing, supporting branch/PR/tag-based deployments. It builds the WAR package and a deployment patch (including Hibernate and license files) via Gradle, and automates Azure VM deployment through PowerShell script execution.

Testing Procedures:
<bullet list of steps a QA engineer would follow to verify this change>
```

Rules for filling in the template:

- **Card Number** — always the ADO card number from the branch name, never freeform
- **Desc** — the ADO work item title, fetched via MCP, not paraphrased
- **Summary paragraph** — your own concise description of the change; keep it factual
- **Testing Procedures** — concrete, ordered steps. If the change has no testable surface, write "No functional changes — verify CI passes."

## Creating the PR

Use the `github` MCP to open the PR. Always confirm the target branch with the user before submitting — default to `main` unless told otherwise.

```
github: create_pull_request(
  title=<work item title>,
  body=<filled template>,
  head=<current branch>,
  base=<target branch>
)
```

After creation, post the PR URL back and confirm the ADO card number is visible in the PR body.

## Updating an existing PR

If the PR already exists, use the `github` MCP to fetch the current body, update only the changed sections, and push the update. Never rewrite the whole body unless the user asks.

## Hard stops

- Never open a PR from a branch with no card number in its name without explicit user confirmation
- Never target `main` with a PR that has no Testing Procedures entry
- Never fabricate ADO card details — always fetch from the `ado` MCP
