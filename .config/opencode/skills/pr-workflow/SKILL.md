---
name: pr-workflow
description: Pull request creation and lifecycle management. Enforces branch naming, ADO card linking, and the correct PR template. Owned by orchestrator — apply this skill whenever the user asks to create or update a PR.
compatibility: opencode
metadata:
  mcp: github, ado
  agents: [orchestrator]
---

# PR Workflow

You are creating or updating a pull request. Every PR must be traceable to an ADO work item. No card number, no PR — stop and ask the user before proceeding.

---

## Section 0: Extract the card number

```bash
git branch --show-current
```

Branch format: `<card-number>-<short-description>`

Extract the card number from the branch name. If the branch name contains no card number, stop immediately:

> "The current branch `<name>` has no card number. Please confirm the ADO card number before I create the PR."

Do not invent or assume a card number.

---

## Section 1: Fetch the ADO work item

Use the `ado` MCP to retrieve the work item:

```
ado: get_work_item(id=<card-number>)
```

Use the work item title as the PR title unless the user has specified one. Use the description to inform the PR summary.

---

## Section 2: Confirm the target branch

Ask the user which branch to target before creating the PR. Default to `main` unless told otherwise. Never assume.

---

## Section 3: Write the PR body

Every PR body uses this structure exactly — do not omit or reorder sections:

```markdown
Card Number: <card-number>
Desc: <work item title from ADO>

<1–3 sentence summary of what this change does and why>

Testing Procedures:
<bullet list of concrete steps a QA engineer would follow to verify this change>
```

Rules:

- **Card Number** — the ADO card number from the branch name, never freeform
- **Desc** — the ADO work item title verbatim, fetched via MCP, not paraphrased
- **Summary** — your own concise factual description of the change
- **Testing Procedures** — ordered, concrete steps. If the change has no testable surface, write: "No functional changes — verify CI passes."

---

## Section 4: Create the PR

Use the `github` MCP:

```
github: create_pull_request(
  title=<work item title>,
  body=<filled template>,
  head=<current branch>,
  base=<confirmed target branch>
)
```

After creation, confirm the PR URL and verify the ADO card number is visible in the body.

---

## Section 5: Updating an existing PR

If the PR already exists, fetch the current body via the `github` MCP, update only the sections that have changed, and push the update. Never rewrite the whole body unless the user explicitly asks.

---

## Hard stops

- Never open a PR from a branch with no card number without explicit user confirmation
- Never target `main` with a PR that has no Testing Procedures entry
- Never fabricate ADO card details — always fetch from the `ado` MCP
- Never push or create a PR without confirming the target branch with the user first
