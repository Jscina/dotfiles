---
name: git-rebase-fixup
description: Enforces an atomic "fixup-first" Git workflow. Use this for all iterative coding tasks, bug fixes, and history cleanup.
compatibility: opencode
metadata:
  workflow: rebase-autosquash
  commit_style: fixup-atomic
---

# Atomic Fixup & Rebase Workflow

You are an expert at maintaining a pristine, linear Git history. You must never create "noise" commits (e.g., "fix typo", "oops", "more work"). Instead, you will use `git commit --fixup` to target the original functional commit.

## 1. The Iterative Coding Loop

When you modify code that was already committed in the current feature branch:

1. **Identify the Target:** Find the SHA of the original commit that introduced the feature/file you are modifying.
2. **Stage Changes:** `git add <files>`
3. **Fixup:** Execute `git commit --fixup <SHA>`.
   - _Note:_ Do not write a new message. Git will automatically prefix it with `fixup!`.

## 2. The Rebase Sync (Manual Trigger or Pre-Push)

Before declaring a task "done" or if the user asks to "cleanup history":

1. **Autosquash:** Run `git rebase -i --autosquash <base-branch>`.
2. **Environment:** Since `rebase.autoStash` and `rebase.autoSquash` are enabled in the global config, you do not need to manually move lines in the interactive editor. Just verify the plan and proceed.

## 3. Conflict Resolution

- Use `git rerere` to resolve previously encountered conflicts.
- If a rebase stalls, resolve conflicts, `git add`, and `git rebase --continue`.
- **NEVER** switch to `git merge` or `git cherry-pick` to bypass a rebase conflict.

## 4. Safety Guardrails

- **No Force Pushing:** Never `push --force` without explicit user permission.
- **Local Only:** This workflow applies ONLY to local feature branches. Never rebase commits that have been merged into `main` or `shared-dev`.

## Example Interaction

**User:** "Fix the padding in the header component."
**Assistant:** 1. (Finds SHA `a1b2c3d` "feat: add header component") 2. `git add src/components/Header.tsx` 3. `git commit --fixup a1b2c3d` 4. "I've applied the padding fix as a fixup to 'feat: add header component'. Ready to autosquash?"
