---
name: copeland-code-search
description: Org-wide semantic code search via the Copeland Code Cortex MCP. Use this for any task requiring understanding of existing code patterns, finding implementations, cross-repo analysis, or before writing new code that may already exist.
compatibility: opencode
metadata:
  mcp: copeland-code-search
  access: read-only
  scope: organization-wide
---

# Copeland Code Cortex Protocol

You have access to `search_code` and `list_indexed_repositories` via the `copeland-code-search` MCP. This gives you semantic + keyword search across all indexed Copeland repositories.

## When to use this skill

Use `search_code` **before writing any new code** when:

- You need to understand how something is already implemented
- You're looking for patterns, conventions, or examples in the codebase
- You suspect something similar already exists elsewhere
- You need cross-repo context (e.g. how other services handle auth, error handling, logging)
- You're debugging and need to find related logic

Use `list_indexed_repositories` when:

- You need to know which repos are available to search
- You want to scope a search to specific repos and need the exact name format (`org/repo`)

## How to query effectively

**Prefer natural language over keyword matching.** The index is semantic — describe what the code _does_, not what it's _called_.

| Instead of          | Use                                                      |
| ------------------- | -------------------------------------------------------- |
| `"AzureOpenAI"`     | `"embedding generation with Azure OpenAI"`               |
| `"webhook handler"` | `"GitHub webhook push event processing"`                 |
| `"auth"`            | `"OAuth token verification middleware"`                  |
| `"search"`          | `"vector similarity search with Azure Cognitive Search"` |

**Use `repo_filter` when you know the scope.** Searching all 49 shards is slower and noisier. If you know the relevant repo, filter to it:

```
search_code("queue-based fanout for indexing jobs", repo_filter=["copelandsoftware/copeland-cortex"])
```

**Adjust `top` based on task.** Default 10 is fine for exploration. For broad pattern analysis, use 20-30. For targeted lookup, use 5.

**Use `include_docs=False` for code-only searches.** When you want implementation details, not README content.

## Interpreting results

Results include:

- `file_path` — relative path within the repo
- `repo` — in `org/repo` format
- `line_numbers` — where the chunk starts/ends
- `github_url` — direct link to the code on GitHub
- `snippet` — the actual code chunk

Always cite the `github_url` when referencing found code. Do not reproduce large snippets verbatim — summarize what you found and where.

## Before writing new code

Run at least one search to check for existing implementations. If you find something relevant:

1. Reference it explicitly: "I found similar logic in `copelandsoftware/X` at `path/to/file.py`"
2. Prefer extending or adapting existing patterns over introducing new ones
3. If the existing implementation is insufficient, note why before proceeding

## Mandatory constraints

- **Read-only.** This skill provides search context only. No writes, no modifications.
- **Do not hallucinate results.** If `search_code` returns nothing relevant, say so. Do not fabricate file paths or implementations.
- **Always search before assuming.** If you're uncertain whether something exists in the codebase, search first.
