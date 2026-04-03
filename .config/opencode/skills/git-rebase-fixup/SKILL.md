---
name: git-rebase-fixup
description: Enforces an atomic "fixup-first" Git workflow on an isolated AI working branch. Use this for all iterative coding tasks, bug fixes, and history cleanup.
compatibility: opencode
metadata:
  workflow: rebase-autosquash
  commit_style: fixup-atomic
---

# Atomic Fixup & Rebase Workflow

You are an expert at maintaining a pristine, linear Git history. You must never create "noise" commits (e.g., "fix typo", "oops", "more work"). All work happens on a short-lived, local-only AI working branch that is squash-rebased back onto the user's branch when complete.

## 0. The AI Working Branch

Before writing any code, always create a local working branch off the user's current branch:

1. **Record the base:** Note the user's current branch as `<base-branch>` (e.g. `feat/my-feature`).
2. **Extract the card number** from the branch name — branches follow `<card-number>-<description>`. The card number is required for all commit messages. If the branch has no card number, ask the user before proceeding.
3. **Branch:** `git checkout -b ai/<base-branch>` (e.g. `ai/feat/my-feature`).
   - This branch is **local-only** and **never pushed**.
4. Make your first meaningful commit on this branch — this becomes the fixup target for all subsequent iterations.

## 1. Commit message format

Every non-fixup commit message must end with the ADO work item footer:

```
<type>: <description>

AB#<card-number>
```

Examples:

```
fix: correct padding in header component

AB#12345
```

```
feat: add QA deploy flag to pipeline

AB#67890
```

Rules:

- `AB#<card-number>` goes in the **commit body**, on its own line, separated from the subject by a blank line
- Never put it in the subject line
- `type` follows conventional commits: `fix`, `feat`, `chore`, `refactor`, `docs`, `test`, `ci`
- Fixup commits (`git commit --fixup <SHA>`) do not need the footer — they will be squashed away before handoff

## 2. The Iterative Coding Loop

While iterating on `ai/<base-branch>`:

1. **Identify the Target:** Find the SHA of the commit on this branch that introduced the work you are amending.
2. **Stage Changes:** `git add <files>`
3. **Fixup:** Execute `git commit --fixup <SHA>`.
   - _Note:_ Do not write a new message. Git will automatically prefix it with `fixup!`.

Repeat until the task is complete.

## 3. Cleanup & Rebase Back (Pre-Handoff)

When the task is done or the user asks to "clean up" or "finish":

1. **Autosquash internally:** Run `git rebase -i --autosquash <base-branch>`.
   - Because `rebase.autoSquash` and `rebase.autoStash` are enabled globally, no manual editor interaction is needed. Verify the plan and proceed.
   - This collapses all fixup commits into clean, atomic commits.
2. **Verify AB# footer** — after squashing, confirm every resulting commit message contains `AB#<card-number>`. If any are missing, amend before proceeding.
3. **Switch back to user's branch:** `git checkout <base-branch>`
4. **Rebase AI work on top:** `git rebase ai/<base-branch>`
   - This fast-forwards `<base-branch>` to include the clean commits, preserving linear history.
5. **Delete the working branch:** `git branch -d ai/<base-branch>`

## 4. Conflict Resolution

- Use `git rerere` to resolve previously encountered conflicts (auto-enabled via config).
- If a rebase stalls, resolve conflicts, `git add`, then `git rebase --continue`.
- **NEVER** switch to `git merge` or `git cherry-pick` to bypass a rebase conflict.

## 5. Safety Guardrails

- **No Force Pushing:** Never `push --force` without explicit user permission.
- **Local Only:** The `ai/*` branch is never pushed. The user's `<base-branch>` is only modified locally via rebase — never touch `main` or any shared branch.
- **Never rebase shared history:** This workflow applies only to local feature/bug/hotfix branches that have not been merged upstream.

## Example Interaction

**User:** "Fix the padding in the header component." _(on branch `12345-fix-header`)_

**Assistant:**

1. Extracts card number: `12345`
2. `git checkout -b ai/12345-fix-header`
3. Makes the fix, then: `git add src/components/Header.tsx`

4. ```
   git commit -m "fix: correct padding in header component

   AB#12345"
   ```

5. _(iterates, finds an issue)_ `git commit --fixup <SHA>`
6. When done: `git rebase -i --autosquash 12345-fix-header` → squashes fixups
7. Verifies `AB#12345` is present in all resulting commits
8. `git checkout 12345-fix-header && git rebase ai/12345-fix-header`
9. `git branch -d ai/12345-fix-header`
10. "Done — the padding fix is a single clean commit on `12345-fix-header` with `AB#12345` linked. Ready to push?"
