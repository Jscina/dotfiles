---
name: pr-workflow
description: Pull request creation and lifecycle management. Enforces branch naming, GitHub issue linking, and the correct PR template. Owned by orchestrator — apply this skill whenever the user asks to create or update a PR.
compatibility: opencode
metadata:
  mcp: github
  agents: [orchestrator]
---

# PR Workflow

You are creating or updating a pull request. Every PR should be traceable to a GitHub issue where one exists. If the branch name contains an issue number, link it. If there is no issue, proceed without one.

---

## Section 0: Extract the issue number

```bash
git branch --show-current
```

Branch format: `<issue-number>-<short-description>` (e.g. `42-fix-auth-bug`)

Extract the issue number from the branch name if present. If no issue number is found in the branch name, continue without one — do not stop.

---

## Section 1: Fetch the GitHub issue (if issue number found)

Use the `github` MCP to retrieve the issue:

```
github: get_issue(owner=<repo-owner>, repo=<repo-name>, issue_number=<issue-number>)
```

Use the issue title as the PR title unless the user has specified one. Use the issue body to inform the PR summary.

If no issue number was found, use the user's description or the branch name to derive the PR title.

---

## Section 2: Confirm the target branch

Ask the user which branch to target before creating the PR. Default to `main` unless told otherwise. Never assume.

---

## Section 3: Write the PR body

Every PR body uses this structure exactly — do not omit or reorder sections:

```markdown
<1–3 sentence summary of what this change does and why>

Closes: #<issue-number> (omit this line if there is no linked issue)

Testing Procedures:
<bullet list of concrete steps to verify this change>
```

Rules:

- **Summary** — concise, factual description of the change
- **Closes** — GitHub issue number; omit entirely if no issue is linked
- **Testing Procedures** — ordered, concrete steps. If the change has no testable surface, write: "No functional changes — verify CI passes."

---

## Section 4: Create the PR

Use the `github` MCP:

```
github: create_pull_request(
  title=<title>,
  body=<filled template>,
  head=<current branch>,
  base=<confirmed target branch>
)
```

After creation, confirm the PR URL. If an issue was linked, verify the `Closes: #<issue-number>` line is present in the body.

---

## Section 5: Updating an existing PR

If the PR already exists, fetch the current body via the `github` MCP, update only the sections that have changed, and push the update. Never rewrite the whole body unless the user explicitly asks.

---

## Hard stops

- Never target `main` with a PR that has no Testing Procedures entry
- Never push or create a PR without confirming the target branch with the user first
- Never fabricate issue details — always fetch from the `github` MCP if an issue number is present
