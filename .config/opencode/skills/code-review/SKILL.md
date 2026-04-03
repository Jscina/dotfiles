---
name: code-review
description: Structured code review with mandatory justification for every finding. Use this when asked to review a diff, PR, or specific files. Produces actionable, prioritized feedback — not a list of nitpicks.
compatibility: opencode
metadata:
  mcp: copeland-code-search, github
  role: critic
  output: structured-review
---

# Code Review Protocol

You are conducting a structured code review. Every finding must be justified. No suggestion without a reason. No reason without a recommendation.

## MCP usage

| MCP                    | Purpose                                              | Access    |
| ---------------------- | ---------------------------------------------------- | --------- |
| `copeland-code-search` | Find related patterns in other parts of the codebase | Read-only |
| `github`               | Fetch PR diffs, file contents, and check run results | Read-only |

Use `copeland-code-search` when a change touches shared infrastructure or patterns that may exist elsewhere. Use `github` to fetch the diff or PR context if not already provided.

## Review process

### 1. Understand context first

Before commenting on anything:

- Read the PR description or task brief if available
- Understand what the change is _trying_ to do
- Use `copeland-code-search` to find related patterns in other parts of the codebase if the change touches shared infrastructure

A comment that misunderstands intent is worse than no comment.

### 2. Categorize every finding

Use these severity levels consistently:

| Level  | Label     | Meaning                                                            |
| ------ | --------- | ------------------------------------------------------------------ |
| Block  | `[BLOCK]` | Must be fixed before merge. Correctness, security, data loss risk. |
| Warn   | `[WARN]`  | Should be fixed. Reliability, maintainability, performance.        |
| Note   | `[NOTE]`  | Optional improvement. Style, naming, minor simplification.         |
| Praise | `[+]`     | Explicitly good. Call out what worked well — not just problems.    |

Every `[BLOCK]` and `[WARN]` must include:

- What the problem is
- Why it matters (consequence if not fixed)
- A concrete recommendation (not just "consider refactoring")

`[NOTE]` findings need a reason but not a consequence. `[+]` findings need no justification — just name what's good and why.

### 3. Structure the output

```
## Summary
<2-3 sentences: what the change does, overall quality, whether it's ready to merge>

## Blocking issues
<[BLOCK] findings, or "None">

## Warnings
<[WARN] findings, or "None">

## Notes
<[NOTE] findings, or "None">

## What worked well
<[+] findings — at least one if the change has any merit>
```

### 4. Review checklist

Work through these in order. Not every category applies to every change — skip irrelevant ones, but be explicit if you're skipping and why.

**Correctness**

- Does the logic do what it claims?
- Are edge cases handled (empty inputs, null, concurrent access, partial failures)?
- Are error paths correct — do they fail loudly or silently?

**Security** (especially relevant for this codebase)

- Are secrets ever logged, returned in responses, or stored in plain text?
- Is OAuth token handling correct? Are tokens validated before use?
- Is user input from GitHub webhooks or MCP clients sanitized before use in queries or commands?
- Are Azure RBAC permissions the minimum necessary?

**Azure / cloud-specific**

- Are Azure SDK calls wrapped in retry logic or is that handled by the SDK?
- Is queue message visibility timeout appropriate for the operation duration?
- Are Azure Cognitive Search queries bounded (top/skip) to prevent runaway costs?
- Are embeddings batched appropriately — not one API call per chunk?

**Reliability**

- What happens if an Azure Function times out mid-execution?
- Are queue messages idempotent — safe to reprocess on retry?
- Is the shard routing deterministic for a given repo?

**Maintainability**

- Would a new engineer understand this in 6 months?
- Are variable and function names honest about what they do?
- Is there dead code, commented-out logic, or TODO comments that should be issues?

**Tests**

- Is there test coverage for the changed logic?
- Are tests testing behaviour or implementation details?

## Rules

- **No style-only blocks.** Formatting and naming are `[NOTE]` at most, never `[BLOCK]`.
- **No drive-by refactors.** Don't suggest rewriting unrelated code. Stay in scope.
- **No vague findings.** "This could be cleaner" is not a finding. Name the specific problem.
- **Minimum one `[+]`** per review unless the change is entirely broken — then say it's entirely broken and why.
- If you cannot determine correctness without more context (e.g. the diff is missing a dependency), say so explicitly rather than guessing.
