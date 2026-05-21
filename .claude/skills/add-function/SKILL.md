---
name: add-function
description: Add a new function to this R package end-to-end — create `R/<name>.R`, draft a roxygen2 docblock, generate `man/<name>.Rd`, bootstrap testthat if missing, write `tests/testthat/test-<name>.R`, run `devtools::load_all()` and `devtools::test()`, then commit and push to `master`. Use when the user says "add a function", "new function", "create function in this package", "scaffold a function", "add R function", or "add and push a function".
---

# Add a function to the package (R)

End-to-end workflow that turns a new function into a documented, tested, and pushed change on `master`. The skill stays opinionated and confirms with the user at each non-trivial decision point.

## Steps

### 1. Collect inputs

Determine three things, asking the user only for what is missing:

- **Function name** (`fn_name`). Must be a syntactically valid R identifier and not collide with an existing file in `R/` or an existing object in the package namespace. Check with `ls R/ | grep -i <fn_name>` and `Rscript -e 'devtools::load_all("."); exists("<fn_name>", inherits = FALSE)'`.
- **Function source**. One of:
  - Pasted inline in the user's message.
  - Path to an existing file the user wants moved into `R/`.
  - A short spec ("write a function that does X with signature `f(a, b = 1)`") — in this case draft the body yourself and confirm with the user before writing.
- **Purpose / one-line description**. Needed for the roxygen `@title` and the commit message. If the user did not provide one, ask in one sentence.

If anything is ambiguous (e.g. the name clashes), warn and ask before continuing.

### 2. Drop the function into `R/<fn_name>.R`

- Create `R/<fn_name>.R`. **Never overwrite an existing file** without asking first.
- Preserve the user-provided body verbatim. Do not refactor, rename arguments, or add error handling the user did not request.
- If the source had no roxygen block, add a stub (see step 3) before the function definition.

### 3. Document with roxygen2

Match the established style in this package (`R/muScore.R`, `R/GA_logistic_regresion.R`, `R/FancyAnnotatedHeatmap.R`):

- `#' <Title>` (sentence case, no trailing period).
- `#' @description` paragraph explaining *what the function does and why*, not just what.
- One `#' @param <name>` per argument, including `...` if present. Describe the expected type and default behaviour.
- `#' @return` describing the structure of the output.
- `#' @examples` block with a small, runnable example.
- `#' @export` — the package's `NAMESPACE` uses `exportPattern("^[[:alpha:]]+")` so functions auto-export, but include `@export` anyway for clarity and to keep roxygen2 from emitting warnings.
- Use `[other_function()]` cross-references where relevant.

After editing, run roxygen2 to generate the matching `.Rd`:

```bash
Rscript -e 'roxygen2::roxygenise(".", roclets = "rd")' 2>&1 | tail -20
```

Side-effect warning: `roxygenise()` will also regenerate `.Rd` files for *other* `R/*.R` files that have roxygen blocks. **Do not stage those** — only stage `man/<fn_name>.Rd`. If `DESCRIPTION` gained a `RoxygenNote` bump and one is not already present on `HEAD`, stage that too; otherwise leave it.

### 4. Bootstrap testthat if missing

Check for `tests/testthat.R` and `tests/testthat/`. If either is missing, set the scaffold up before writing the new test:

- Create `tests/testthat.R` with the canonical launcher:
  ```r
  library(testthat)
  library(GuttmanHeatmap)

  test_check("GuttmanHeatmap")
  ```
- Create the `tests/testthat/` directory.
- Update `DESCRIPTION`:
  - Add `testthat (>= 3.0.0)` under `Suggests:` (or create the field if absent).
  - Add `Config/testthat/edition: 3` if not already present.
- **Do not** add `^tests$` to `.Rbuildignore`; tests must ship with the package source.

If the scaffold already exists, skip this step.

### 5. Write `tests/testthat/test-<fn_name>.R`

At minimum, write one `test_that()` block that:

- Loads the function (no `library()` calls needed inside the test — `tests/testthat.R` already attaches the package).
- Calls `fn_name` with simple, deterministic inputs.
- Asserts a property of the output that would actually break if the function were wrong (not just `expect_true(TRUE)` or `expect_no_error()`).

If the function has clear edge cases (empty input, NA handling, dimension mismatches) and they are cheap to test, add one more `test_that()` block per edge case. Do not invent failure modes that do not apply — three small, real assertions beat ten generic ones.

If the function depends on heavy IO, randomness, or external state (writes a PDF, hits the network, opens a graphics device), set `set.seed()` and either:

- Wrap the call in `withr::with_tempdir()` / `withr::with_tempfile()`.
- Use `expect_no_error()` *and* an assertion against a side-effect (e.g. the file exists and is non-empty).

### 6. Verify

Run in this order, stopping on the first non-zero exit:

```bash
# 6a. Parse-check the new file
Rscript -e 'invisible(parse("R/<fn_name>.R")); cat("OK\n")'

# 6b. Load the whole package
Rscript -e 'devtools::load_all(".", quiet = TRUE); cat("LOAD OK\n")' 2>&1 | tail -10

# 6c. Run only the new test file
Rscript -e 'devtools::test(filter = "<fn_name>")' 2>&1 | tail -30
```

Report the result compactly:

```
parse: OK
load_all: OK / FAIL — <first error line>
testthat: N pass, M fail, K warn, S skip
```

If any step fails, **stop and surface the error to the user**. Do not silently patch the function or the test to make it pass.

### 7. Stage and commit

Delegate to `.claude/skills/commit/SKILL.md`, but pre-classify so the confirmation prompt is tight:

- **Stage**: `R/<fn_name>.R`, `man/<fn_name>.Rd`, `tests/testthat/test-<fn_name>.R`, plus `tests/testthat.R`, `DESCRIPTION` if the scaffold was bootstrapped in step 4, and `DESCRIPTION` if `RoxygenNote` was newly added in step 3.
- **Exclude**: `.Rhistory`, `.RData`, other `man/*.Rd` files regenerated by `roxygenise()` for unrelated functions.
- **Commit subject**: short and direct, e.g. `feat: add <fn_name>() to the package` or `feat: add <fn_name>() with tests`. Match the recent log style:
  ```bash
  git log --oneline -10
  ```
  No body unless something non-obvious motivated the change.

### 8. Push to `master`

Delegate to `.claude/skills/push/SKILL.md`.

- Pre-flight: `git fetch origin`, confirm `master` is not behind, no diverged history.
- If `master` is behind upstream: **stop** and tell the user to `/pull` first — never auto-merge or auto-rebase from inside this skill.
- If safe: `git push origin master`, then report the new `origin/master` SHA.

## Safety rules

- Never overwrite an existing `R/<fn_name>.R`, `man/<fn_name>.Rd`, or `tests/testthat/test-<fn_name>.R` without explicit user confirmation.
- Never silently rewrite the user's function body. If the body has a clear bug discovered during testing, surface it and ask before changing.
- Never stage `.Rd` files for functions other than the one being added. `roxygenise()` is global; staging must be selective.
- Never delete or modify `NAMESPACE` by hand — it is generated; let `roxygenise()` rewrite it if the new function needs `@export` plumbing.
- Never push to `master` from inside this skill if the local branch has diverged from upstream. Defer to `/pull` first.
- Never bypass hooks (`--no-verify`) or skip the verification step in §6 to "save time".
- If a verification step fails, fix the underlying cause (a real bug, a wrong assertion, a missing dependency). Do not loosen the test to make it pass.
