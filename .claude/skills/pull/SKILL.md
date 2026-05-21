---
name: pull
description: Safely pull upstream changes for this R package from GitHub. Fetches origin, summarises any divergence between local and remote, recommends fast-forward / rebase / merge, and protects R-session / IDE noise (`.RData`, `.Rhistory`, `.Rproj.user/*`, `.DS_Store`) from accidental clobber. Use when the user says "pull", "sync from github", "fetch latest", "bring in upstream changes", "update from origin", or "what's new on github".
---

# Pull from GitHub (R package)

Bring upstream changes into the local repository without surprising the user. Mirror the safe pattern used during the muScore / GA_logistic_regression session.

## Steps

### 1. Fetch and assess

Run in parallel and report a compact summary:

- `git fetch origin`
- `git branch --show-current` — flag if HEAD is detached
- `git status --short` — what's dirty locally
- `git log --oneline @{u}..HEAD` — local commits not on remote (commits ahead)
- `git log --oneline HEAD..@{u}` — remote commits not on local (commits behind)
- `git merge-base --is-ancestor HEAD @{u}` — fast-forward possible?

Report results like:

```
Branch: <name>   ahead: <n>   behind: <m>
Working tree: <clean | N files modified>
```

### 2. Pre-flight on the working tree

Before integrating, classify any uncommitted changes:

- **Real changes**: `R/*`, `man/*`, `DESCRIPTION`, `NAMESPACE`, `tests/*`, `vignettes/*`, `.Rbuildignore`, `.gitignore`, top-level `*.md`.
- **R-session / IDE noise**: `.RData`, `.Rhistory`, `.Rproj.user/*`, `.DS_Store`, `renv/library/*`, untracked `*.pdf`.

If only noise is dirty, ignore it and proceed.
If real changes are dirty, **stop and ask** before pulling:
- (a) stash everything, pull, then `git stash pop`
- (b) commit first (suggest `/commit`)
- (c) cancel

### 3. Decide the integration path

- **Up to date** → report and stop.
- **Strictly behind, working tree clean or noise-only** → `git merge --ff-only @{u}` (after confirming).
- **Diverged** → present options and pause:
  - **Rebase local onto upstream** — cleaner linear history; may require conflict resolution.
  - **Merge upstream into local** — preserves both lines; adds a merge commit.
  - **Cancel** — investigate manually.
- **Detached HEAD** → refuse to pull. Explain and offer to (a) check out `master` first, or (b) create a branch at HEAD.

### 4. Execute and verify

After integration:
- Report new HEAD: `git log -1 --oneline`
- If conflicts: surface them, stop, and ask the user how to resolve. Never auto-resolve with `-X ours`/`-X theirs` unless explicitly requested.
- If stashed in step 2: `git stash pop` and report any conflicts from that.

## Safety rules

- Never silently merge or rebase when there are conflicts.
- Never delete or overwrite local commits without showing the user exactly what they would lose (use `git log` to enumerate).
- Never use `--allow-unrelated-histories` unless the user explicitly asks for it.
- If `git pull` is needed, prefer the explicit two-step (`git fetch` + `git merge` / `git rebase`) over `git pull`, so the user sees what's happening.
