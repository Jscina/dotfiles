---
name: git-workflow
description: Builder-only. Manages worktree lifecycle for parallel junior workers and merges their branches into the base branch. Load this skill before spawning any builder-junior instances.
compatibility: opencode
metadata:
  workflow: worktree-parallel-merge
  agents: [builder]
---

# Git Workflow — Builder

This skill owns the full Git lifecycle for a subtask: creating isolated worktrees for each junior worker, collecting their completed branches, and squash-merging everything into a single clean commit on the base branch.

---

## Section 0: Record the base branch

Before anything else:

```bash
BASE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CARD_NUMBER=$(echo "$BASE_BRANCH" | grep -oP '^\d+')
```

Record `BASE_BRANCH` and `CARD_NUMBER`. All worktrees and branches will be named relative to these.

---

## Section 1: Create a worktree for each junior

For each atomic coding unit you are about to delegate, create a worktree **before** spawning the junior:

```bash
git worktree add ./worktree/work-<task-id> -b ai/<BASE_BRANCH>-<task-id>
```

- `<task-id>` — a short slug identifying the unit (e.g. `auth-handler`, `schema-migration`)
- The worktree lives at `./worktree/work-<task-id>` relative to the repo root
- The branch `ai/<BASE_BRANCH>-<task-id>` is created and checked out inside it automatically

Pass the following to each junior in its spec:

```
worktree_path: ../work-<task-id>
branch_name: ai/<BASE_BRANCH>-<task-id>
base_branch: <BASE_BRANCH>
card_number: <CARD_NUMBER>
```

Spawn all juniors in parallel after all worktrees are created.

> **Never push `ai/*` branches to remote.** They are local-only scratch branches.

---

## Section 2: Wait and verify junior output

As each junior reports completion:

1. Check its reported diff:

   ```bash
   git -C ../work-<task-id> diff <BASE_BRANCH>..ai/<BASE_BRANCH>-<task-id>
   ```

2. Verify the output meets your review criteria (compiles, follows patterns, no regressions)
3. If a junior failed or the diff is wrong, spawn `@debugger` and have the junior retry in place — the worktree stays open until you accept the output

---

## Section 3: Merge all branches into base

Once all juniors have passed review, merge their branches into the base branch one at a time using fast-forward:

```bash
git checkout <BASE_BRANCH>
```

For each completed junior branch in dependency order:

```bash
git rebase ai/<BASE_BRANCH>-<task-id>
```

If a rebase conflict occurs:

1. Resolve it in the affected files
2. `git add <conflicted-files>`
3. `git rebase --continue`

> Never use merge commits. Never use `--force`. Conflicts are resolved by editing and continuing.

After all branches are rebased in, verify the final state:

```bash
git log --oneline <BASE_BRANCH>
git diff origin/<BASE_BRANCH>..<BASE_BRANCH>
```

---

## Section 4: Cleanup

Remove every worktree and delete its branch:

```bash
git worktree remove ../work-<task-id>
git branch -d ai/<BASE_BRANCH>-<task-id>
```

Repeat for each worktree. Then verify no worktrees remain:

```bash
git worktree list
```

---

## Section 5: Handoff reminder

After cleanup, remind yourself:

> All changes from junior workers are now on `<BASE_BRANCH>`.
> Do not push. Hand off to reviewer.
> The reviewer or user will push when approved:
>
> ```
> git diff origin/<BASE_BRANCH>..<BASE_BRANCH>
> git push origin <BASE_BRANCH>
> ```

---

## Safety guardrails

- Never push `ai/*` branches to remote
- Never force-push without explicit user instruction
- Never rebase a branch that exists on remote
- Worktrees are temporary — always clean them up before reporting done
- If `git worktree list` shows stale entries after removal, run `git worktree prune`
