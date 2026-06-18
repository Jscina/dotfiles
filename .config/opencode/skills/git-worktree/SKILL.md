---
name: git-worktree
description: Builder-junior only. Enforces the atomic fixup commit workflow inside the worktree assigned by builder. Load this skill before making any changes.
compatibility: opencode
metadata:
  workflow: fixup-atomic
  agents: [builder-junior]
---

# Git Worktree — Builder Junior

You work inside a pre-created worktree. Builder has already created it and handed you the path and branch. You do not create branches, manage remotes, or touch anything outside your assigned worktree path.

---

## Section 0: Orient yourself

You will receive these values in your spec:

```
worktree_path: ../work-<task-id>
branch_name:   ai/<base-branch>-<task-id>
base_branch:   <base-branch>
issue_number:  <issue-number>  (may be empty)
```

Confirm you are in the right place before touching anything:

```bash
cd <worktree_path>
git rev-parse --abbrev-ref HEAD   # must match branch_name
git status                        # must be clean
```

If either check fails, stop immediately and report:
`BLOCKED: worktree not in expected state — HEAD is <actual>, expected <branch_name>`

All git commands from this point forward run from `<worktree_path>`.

---

## Section 1: Seed commit

Make your first real change, then create the seed commit. This is the only commit with a real message — all subsequent commits are fixups targeting this one.

```bash
git add <files>
git commit -m "<type>: <description>"
# If issue_number is set, add the trailer:
git commit -m "<type>: <description>" -m "Closes #<issue_number>"
```

Conventional commit types: `fix`, `feat`, `chore`, `refactor`, `docs`, `test`, `ci`

Record the seed SHA:

```bash
SEED=$(git rev-parse HEAD)
```

---

## Section 2: Fixup loop

For every subsequent change:

```bash
git add <files>
git commit --fixup $SEED
```

Repeat until your spec is fully implemented.

---

## Section 3: Self-review gate

Before cleanup, review your own diff:

```bash
git diff <base_branch>..<branch_name>
```

Check:

- All intended changes are present
- No unintended files, debug artifacts, or out-of-scope changes
- No syntax errors or missing imports

**This is a gate.** If anything looks wrong, make more fixup commits and re-check. Do not proceed to cleanup until the diff is clean.

---

## Section 4: Cleanup

Collapse all fixup commits into the seed:

```bash
git rebase --autosquash <base_branch>
```

Verify the final commit looks correct:

```bash
git log -1 --format="%B"
```

If a conflict occurs during rebase:

1. Resolve the conflict in the affected file
2. `git add <conflicted-files>`
3. `git rebase --continue`

> Never abort the rebase. Never merge instead of rebasing.

---

## Section 5: Report to builder

When done, report:

```
DONE
branch: <branch_name>
worktree: <worktree_path>
seed: <final commit SHA after rebase>
files changed: <list every file you modified with one-line description>
diff summary: <what changed at a high level>
```

If you encountered compilation errors or test failures in adjacent code you did not touch, report them separately:

```
PRE-EXISTING ISSUES: <description>
```

Do not attempt to fix anything outside your spec. Report it and stop.

---

## Safety guardrails

- Never run `git push` — you have no remote access and should not need it
- Never `git checkout` a different branch — stay on `<branch_name>`
- Never modify files outside your spec without reporting it explicitly
- Never run `git worktree` commands — worktree management is builder's responsibility
- If `git rebase --autosquash` fails in a way you cannot resolve, report: `BLOCKED: rebase conflict unresolvable — <description>` and stop
