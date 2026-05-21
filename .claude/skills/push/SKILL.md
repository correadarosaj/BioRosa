---
name: push
description: Push local commits to GitHub safely. Refreshes origin, compares local vs remote, prefers `--force-with-lease` over `--force`, refuses to force-push to `master`/`main` without explicit confirmation, and offers pushing to a new branch as a safer alternative when remote has diverged. Use when the user says "push", "push to github", "send to github", "publish my changes", "push to origin", "push my work", or "push branch".
---

# Push to GitHub (R package)

Get local commits onto GitHub without overwriting other people's work.

## Steps

### 1. Pre-flight

In parallel:
- `git fetch origin`
- `git branch --show-current` — refuse to push from detached HEAD; offer to create a branch first.
- `git status --short` — flag uncommitted changes; suggest `/commit` first.
- `git log --oneline @{u}..HEAD` (commits ahead) and `git log --oneline HEAD..@{u}` (commits behind) if the branch has an upstream.
- If no upstream is set: `git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || echo "no upstream"`.

### 2. Classify the situation

| Situation | Action |
|-----------|--------|
| Branch has no upstream | Push with `-u origin <branch>`. Confirm branch name. |
| Up to date with remote | Nothing to push — report and stop. |
| Local ahead, remote unchanged | Simple `git push`. |
| Local behind | Suggest `/pull` first; do not push. |
| Both diverged (local ahead + remote ahead) | **Stop and present options.** See section 3. |

### 3. Diverged-branch options

Present these in this order (safest first) and pause:

1. **Push to a new branch (safe)** — `git checkout -b <new-branch> && git push -u origin <new-branch>`.
   - Default when the current branch is `master` or `main`.
   - Suggest a descriptive branch name from the commit message subject.

2. **Rebase first, then push** — invoke `/pull` rebase path, resolve conflicts, then normal push.

3. **Force-push (destructive)** — overwrites remote.
   - ALWAYS use `--force-with-lease`, never bare `--force`.
   - If branch is `master`/`main`: **refuse by default**. Only proceed if the user explicitly says something like "force-push master, I know this overwrites X commits, do it anyway".
   - Show exactly what would be lost: `git log --oneline @{u} ^HEAD`.

### 4. Execute

- Show the exact `git push` command before running it.
- Run the push; capture and report success / failure.
- Report the new remote HEAD: `git rev-parse origin/<branch>`.

### 5. After-push

- If pushed to a new branch and origin is a GitHub URL: print the PR-create URL: `https://github.com/<org>/<repo>/pull/new/<branch>`.
- If pushed to a tracked branch that matches an open PR: mention it.

## Safety rules

- **Never force-push `master`/`main` without explicit, specific user consent** (the consent must mention force-pushing the protected branch by name).
- Default to `--force-with-lease` whenever a force-push is needed.
- Never push with `--no-verify`.
- If push is rejected because remote moved, **do not** auto-force-push. Re-run the pre-flight, show the new divergence, and ask again.
- Refuse to push if the working tree has uncommitted real changes (noise files are OK to ignore).
