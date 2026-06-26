# Deterministic fixture with analytically known improvement values.
#
# For every subject and gene: baseline NL = 0, so Regulation = baseline LS, and
#   Improvement = -100 * (post.LS - BL.LS) / (BL.LS - 0).
#   G1: BL.LS =  2 (Up),   post = 1  -> -100 * (1 - 2)  /  2  =  50
#   G2: BL.LS = -2 (Down), post = -1 -> -100 * (-1 + 2) / -2  =  50
#   G3: BL.LS =  2 (Up),   post = 3  -> -100 * (3 - 2)  /  2  = -50   (worsens)
make_long <- function(subjects = paste0("S", 1:4)) {
  base_ls <- c(G1 = 2, G2 = -2, G3 = 2)
  post_ls <- c(G1 = 1, G2 = -1, G3 = 3)
  rows <- list()
  for (s in subjects) for (g in names(base_ls)) {
    rows[[length(rows) + 1]] <- data.frame(
      SubjectID = s, Gene = g,
      Visit  = c("BL", "BL", "W4"),
      Tissue = c("LS", "NL", "LS"),
      Value  = c(base_ls[[g]], 0, post_ls[[g]]),
      stringsAsFactors = FALSE)
  }
  do.call(rbind, rows)
}

test_that("compute_improvement() returns the exact improvement and regulation", {
  ci <- compute_improvement(make_long(), degs = c("G1", "G2", "G3"))

  expect_equal(ci$n_genes, 3L)
  imp <- ci$improvement
  expect_true(all(imp$.visit == "W4"))
  expect_equal(imp$Improvement[imp$.gene == "G1"], rep(50, 4))
  expect_equal(imp$Improvement[imp$.gene == "G2"], rep(50, 4))
  expect_equal(imp$Improvement[imp$.gene == "G3"], rep(-50, 4))   # worsened
  expect_equal(unique(imp$Reg.Type[imp$.gene == "G1"]), "Up")
  expect_equal(unique(imp$Reg.Type[imp$.gene == "G2"]), "Down")
})

test_that("aggregate_improvement() collapses to the right unit with median + MAD", {
  imp <- compute_improvement(make_long(), degs = c("G1", "G2", "G3"))$improvement

  so <- aggregate_improvement(imp, "subject")
  expect_equal(nrow(so), 4L)                       # 4 subjects, 1 visit, 1 arm
  expect_equal(so$Improvement, rep(50, 4))         # median(50, 50, -50) = 50
  expect_true(all(c("Improvement", "MAD", "n_inner") %in% names(so)))
  expect_equal(unique(so$n_inner), 3L)             # 3 genes per subject

  gr <- aggregate_improvement(imp, "gene", by_reg = TRUE)
  expect_true("Reg.Type" %in% names(gr))
  expect_equal(gr$Improvement[gr$.gene == "G3"], -50)  # median across 4 subjects
})

test_that("evaluate_improvement() returns the four labelled ggplot figures", {
  res <- evaluate_improvement(make_long(), degs = c("G1", "G2", "G3"))

  expect_named(res, c("improvement", "reference", "summary", "plots"))
  expect_named(res$plots,
               c("gene_overall", "gene_byReg", "subject_overall", "subject_byReg"))
  expect_length(res$summary, 4L)
  expect_true(all(vapply(res$plots,
                         function(p) inherits(p, "ggplot"), logical(1))))
})

test_that("compute_improvement() errors on missing columns", {
  expect_error(compute_improvement(data.frame(Gene = 1)),
               "Missing columns", fixed = TRUE)
})

test_that("the internal significance filter drops zero-variance genes", {
  # constant values -> baseline LS-vs-NL t-test has zero variance -> dropped
  expect_equal(compute_improvement(make_long())$n_genes, 0L)
})

test_that("evaluate_improvement() errors when no gene passes the filter", {
  expect_error(evaluate_improvement(make_long(), degs = "ZZZ"),
               "No genes passed", fixed = TRUE)
})
