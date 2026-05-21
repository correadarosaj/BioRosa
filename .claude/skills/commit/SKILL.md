---
name: commit
description: Stage and commit changes to this R package, filtering out R-session / IDE noise. Inspects the working tree, excludes `.RData`, `.Rhistory`, `.Rproj.user/*`, `.DS_Store`, and bare PDF artefacts by default, suggests a concise commit message, and confirms before committing. Use when the user says "commit", "commit my changes", "save these changes", "make a commit", "commit my work", or "commit and write a message".
---

# Commit changes (R package)

Stage and commit only the changes the user actually wants. Filter out R-session and IDE noise.

## Steps

### 1. Survey the working tree

Run in parallel:
- `git status --short`
- `git diff --stat` (unstaged)
- `git diff --stat --staged` (already staged)

### 2. Classify every modified / untracked file

| Category | Examples | Default action |
|----------|----------|----------------|
| **Wanted** | `R/*`, `man/*.Rd`, `DESCRIPTION`, `NAMESPACE`, `.Rbuildignore`, `.gitignore`, `tests/*`, `vignettes/*`, top-level `*.md` | Stage |
| **Noise** | `.RData`, `.Rhistory`, `.Rproj.user/*`, `.DS_Store`, `renv/library/*`, untracked `*.pdf` | Exclude |
| **Suspect** | Large binaries (`*.rds`, `*.RData` outside top level if huge), files outside `R/` / `man/` / `tests/` | Ask |
| **Refuse** | `.env*`, `*.pem`, `credentials*`, anything that looks like a secret | Refuse to stage, warn |

If the user explicitly asks to include a noise file ("commit my .Rhistory too"), respect that — but flag once.

### 3. Sanity checks on the wanted set

All sanity-check failures use the same severity: **warn the user, list the issue clearly, and ask "commit anyway? (y / fix / abort)" before staging.** Never silently swallow a finding, never block hard.

#### 3a. R-source / docs structure

- **New `R/<name>.R` file**: confirm it has at least minimal roxygen (`#'`) above the function, including an `@export` if it's meant to be public. If NAMESPACE uses `exportPattern("^[[:alpha:]]+")` the function will auto-export — note that, no warning.
- **Modified `man/*.Rd` without a matching R/ change**: warn (probably stale roxygen output).
- **Modified `R/*.R` without a matching `man/*.Rd` change**: only flag if the project already has `man/` populated and seems to be maintaining `.Rd` files in sync. Origin/master for this repo does NOT keep custom `.Rd` files — don't push to regenerate them unless asked.

#### 3b. DESCRIPTION integrity (run when DESCRIPTION is in the staged set)

Three lightweight checks. All findings warn + ask, never block.

**Check A — DCF parse + empty-entry**

Parse the staged `DESCRIPTION` and verify each dependency field is well-formed:

```bash
Rscript -e '
  d <- read.dcf("DESCRIPTION")
  for (f in intersect(c("Imports","Suggests","Depends","LinkingTo","Enhances"),
                      colnames(d))) {
    pkgs <- trimws(strsplit(d[1, f], "[,\n]")[[1]])
    pkgs <- pkgs[nzchar(pkgs)]
    raw  <- trimws(strsplit(d[1, f], ",")[[1]])
    if (length(raw) != length(pkgs))
      cat("WARN", f, "field: empty entry (likely trailing/double comma)\n")
  }
'
```

If WARN lines appear: surface them, ask, commit anyway only on explicit yes.

**Check B — Dep-name typo / rename heuristic**

Compare the staged `DESCRIPTION`'s dependency lists against `HEAD:DESCRIPTION`. For each name that *disappeared* and each name that *appeared*, compute Levenshtein distance:

```bash
Rscript -e '
  parse_deps <- function(text) {
    d <- read.dcf(textConnection(text))
    fields <- intersect(c("Imports","Suggests","Depends","LinkingTo"),
                        colnames(d))
    out <- list()
    for (f in fields) {
      pkgs <- trimws(strsplit(d[1, f], "[,\n]")[[1]])
      pkgs <- sub("\\s*\\(.*\\)$", "", pkgs)  # strip version constraints
      out[[f]] <- pkgs[nzchar(pkgs)]
    }
    out
  }
  old <- parse_deps(system("git show HEAD:DESCRIPTION", intern = TRUE) |> paste(collapse = "\n"))
  new <- parse_deps(paste(readLines("DESCRIPTION"), collapse = "\n"))
  for (f in union(names(old), names(new))) {
    removed <- setdiff(old[[f]], new[[f]])
    added   <- setdiff(new[[f]], old[[f]])
    for (r in removed) for (a in added) {
      if (adist(r, a)[1,1] <= 2L && r != a)
        cat(sprintf("WARN %s: %s -> %s (edit distance %d) — typo?\n",
                    f, r, a, adist(r, a)[1,1]))
    }
  }
'
```

Each WARN: surface, ask, commit anyway only on explicit yes. The user may legitimately rename a dep — that's why it asks rather than blocks.

**Check C — Hidden dependency scan**

For every new or modified `R/*.R` file in the staged set, extract package references and compare against declared deps. Whitelist base packages bundled with R so they don't false-positive:

```bash
# Bundle these with R: never flag as missing
BASE_PKGS="base|stats|utils|methods|grDevices|graphics|datasets|parallel|tools|tcltk|splines|compiler"

# Extract pkg names from `pkg::fn`, `pkg:::fn`, library(pkg), require(pkg),
# requireNamespace("pkg") — only from staged R files.
staged_r=$(git diff --cached --name-only --diff-filter=AM -- 'R/*.R')
[ -n "$staged_r" ] && \
  grep -hEo '([A-Za-z][A-Za-z0-9.]*)(:::|::)|library\([A-Za-z][A-Za-z0-9.]*\)|require\([A-Za-z][A-Za-z0-9.]*\)|requireNamespace\(["\047][A-Za-z][A-Za-z0-9.]*["\047]' $staged_r \
  | sed -E 's/(::|:::|library\(|require\(|requireNamespace\(["\047])//g; s/["\047]?\)$//' \
  | sort -u \
  | grep -Ev "^($BASE_PKGS)$"
```

Then in R, compare that set against `DESCRIPTION`'s declared deps (reuse `parse_deps()` from check B). Any package in code but not in `Imports|Suggests|Depends|LinkingTo` → WARN and ask.

#### 3c. Secrets refusal (hard)

Refuse to stage filenames matching `^\.env`, `*.pem`, `credentials*`, `*.key`, `id_rsa*`. This is the **only** hard block; everything else above is warn-and-ask.

### 4. Draft a commit message

Follow the style observed in recent commits (`git log --oneline -10`). For this repo, short and direct ("update X", "add Y", "fix Z"). Keep the message under ~70 chars on the subject line; add a body only if the change is non-obvious.

Avoid:
- Marketing words ("comprehensive", "robust").
- "What" descriptions when the diff already says what — focus on **why** if useful.
- The Co-Authored-By trailer unless the user has asked for it on previous commits.

### 5. Confirm with the user

Print:
- The file list grouped by category (Wanted / Excluded as noise / Suspect / Refused).
- The proposed commit message.

Ask: "Stage these and commit with this message? (y / edit message / change files / abort)"

### 6. Stage and commit

- Stage by explicit path: `git add <file1> <file2> ...`. Never `git add -A` or `git add .`.
- Commit using a heredoc to preserve formatting:
  ```
  git commit -m "$(cat <<'EOF'
  <subject>

  <optional body>
  EOF
  )"
  ```
- Report `git log -1 --oneline` afterwards.

## Safety rules

- Never amend a previous commit unless the user explicitly says "amend".
- Never use `--no-verify`, `--no-gpg-sign`, or other hook-bypass flags unless the user explicitly asks for them.
- Never stage files matching obvious secret patterns (`.env`, `*.pem`, `credentials.*`, `*.key`, `id_rsa*`).
- If a pre-commit hook fails: fix the underlying issue and create a NEW commit. Do not amend.
