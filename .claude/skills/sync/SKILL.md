---
name: sync
description: One-shot wrapper for this R package: pull upstream changes, commit local work, push to GitHub. Runs the `pull` → `commit` → `push` skills in order with safety prompts at each step and bails on any disagreement. Use when the user says "sync", "sync with github", "sync the package", "update everything", "pull and push", or "do the whole git dance".
---

# Sync (R package)

One-shot **pull → commit → push** flow. Each phase delegates to the matching skill (`pull`, `commit`, `push`); this wrapper just sequences them and bails on any error or refusal.

## Steps

### 1. Pull phase

Apply the logic in `.claude/skills/pull/SKILL.md`.

- If the working tree has real changes and the upstream has new commits, offer stash-and-restore before pulling.
- If conflicts arise: surface them, stop the whole sync, and let the user resolve manually.

### 2. Commit phase

Apply the logic in `.claude/skills/commit/SKILL.md`.

- If `git status --short` is clean after the pull, **skip this phase silently** and continue to push.
- Otherwise: classify, draft a message, confirm with the user, and commit.

### 3. Push phase

Apply the logic in `.claude/skills/push/SKILL.md`.

- If the pull phase fast-forwarded the local branch and no commit was made, there might be nothing to push — check `git log @{u}..HEAD` first.
- Default to the safest push path (no force).

### 4. Stop conditions

Any of the following halts the sequence and reports the final state:
- User declines confirmation in any phase ("no", "abort", "cancel").
- A git operation returns non-zero (conflict, rejected push, hook failure).
- A safety rule triggers (would force-push master, would commit secrets, etc.).

When stopping, report:
- Which phase stopped the sync.
- The current state of the branch (clean / dirty / ahead / behind).
- A suggested next action.

## Safety rules

- Each phase must complete (or be intentionally skipped) before the next starts.
- Never combine phases into a single command (e.g. `git pull && git commit && git push`) — the user needs to see and approve each step.
- Inherit all safety rules from `pull`, `commit`, and `push`.
