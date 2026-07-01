# Tests for the tidy-model -> ebfit -> BigTab pipeline:
#   runEbfit()  reshapes a long tidy table into list(coef, p.value) matrices
#   runBigTab() turns that into the per-contrast BigTab consumed downstream
#
# NOTE: both functions apply() over contrast columns, which collapses to a
# vector for a *single* contrast and breaks the colnames() assignment. The
# fixtures therefore use two contrasts (A_vs_B, C_vs_D), which is also the
# realistic case.

make_tidy <- function() {
  data.frame(
    biomarker = c("G1", "G1", "G2", "G2", "G3", "G3"),
    contrasts = c("A_vs_B", "C_vs_D", "A_vs_B", "C_vs_D", "A_vs_B", "C_vs_D"),
    estimate  = c( 2.0,  0.1,  -1.0, 3.0,  0.0,  -2.0),
    p.value   = c( 0.001, 0.4,  0.02, 0.001, 0.5, 0.01),
    stringsAsFactors = FALSE
  )
}

test_that("runEbfit() reshapes tidy results into aligned coef/p.value matrices", {
  skip_if_not_installed("reshape2")
  eb <- runEbfit(make_tidy())

  expect_named(eb, c("coef", "p.value"))
  expect_true(is.matrix(eb$coef))
  expect_equal(rownames(eb$coef), c("G1", "G2", "G3"))
  expect_equal(colnames(eb$coef), c("A_vs_B", "C_vs_D"))  # dcast sorts contrasts

  expect_equal(eb$coef["G1", "A_vs_B"], 2.0)
  expect_equal(eb$coef["G2", "C_vs_D"], 3.0)
  expect_equal(eb$coef["G3", "A_vs_B"], 0.0)

  expect_equal(eb$p.value["G1", "A_vs_B"], 0.001)
  expect_equal(eb$p.value["G3", "C_vs_D"], 0.01)
  # coef and p.value share the same shape/order so downstream indexing lines up
  expect_equal(dimnames(eb$coef), dimnames(eb$p.value))
})

# A hand-built ebfit list (the shape runEbfit produces) with analytically known
# logFC / FCH / p-value / FDR blocks.
make_ebfit <- function() {
  coef <- matrix(c( 2.0, 0.1,
                   -1.0, 3.0,
                    0.0, -2.0),
                 nrow = 3, byrow = TRUE,
                 dimnames = list(c("G1", "G2", "G3"), c("A_vs_B", "C_vs_D")))
  pval <- matrix(c(0.001, 0.4,
                   0.02,  0.001,
                   0.5,   0.01),
                 nrow = 3, byrow = TRUE,
                 dimnames = list(c("G1", "G2", "G3"), c("A_vs_B", "C_vs_D")))
  list(coef = coef, p.value = pval)
}

test_that("runBigTab() emits the exact lgFCH / FCH / pvals / fdrs blocks", {
  skip_if_not_installed("limma")
  bt <- runBigTab(make_ebfit())  # defaults: adj = BH, mcut = 1.2, pcut = 0.05

  # Underscores in contrast names become dots in the column suffixes.
  expect_true(all(c("lgFCH_A.vs.B", "FCH_A.vs.B", "pvals_A.vs.B",
                    "fdrs_A.vs.B") %in% colnames(bt)))
  expect_equal(rownames(bt), c("G1", "G2", "G3"))

  # log2 fold change is the rounded coefficient.
  expect_equal(unname(bt[, "lgFCH_A.vs.B"]), c(2, -1, 0))

  # signed linear fold change = sign(lgFCH) * 2^|lgFCH|, rounded to 2 dp.
  expect_equal(unname(bt[, "FCH_A.vs.B"]), c(4, -2, 0))
  expect_equal(unname(bt[, "FCH_C.vs.D"]), c(round(2^0.1, 2), 8, -4))

  # p-values are carried through; FDR is per-contrast Benjamini-Hochberg.
  expect_equal(unname(bt[, "pvals_A.vs.B"]), c(0.001, 0.02, 0.5))
  expect_equal(unname(bt[, "fdrs_A.vs.B"]), c(0.003, 0.03, 0.5))
  expect_equal(unname(bt[, "fdrs_C.vs.D"]), c(0.4, 0.003, 0.015))
})

test_that("runBigTab() Status column encodes the DEG call and is grouped by contrast", {
  skip_if_not_installed("limma")
  bt <- runBigTab(make_ebfit())

  status_a <- "StatusFCH1.2FDR0.05_A.vs.B"
  status_c <- "StatusFCH1.2FDR0.05_C.vs.D"
  expect_true(all(c(status_a, status_c) %in% colnames(bt)))

  # DEG call: |lgFCH| > log2(1.2) AND FDR < 0.05, signed by direction.
  #   A_vs_B: G1 up (fdr .003), G2 down (fdr .03), G3 n.s. (lgFCH 0)
  #   C_vs_D: G1 n.s. (fdr .4), G2 up (fdr .003), G3 down (fdr .015)
  expect_equal(unname(bt[, status_a]), c(1, -1, 0))
  expect_equal(unname(bt[, status_c]), c(0, 1, -1))
  expect_true(all(bt[, status_a] %in% c(-1, 0, 1)))

  # Columns are regrouped so each contrast's five columns are contiguous.
  expect_equal(which(colnames(bt) == "lgFCH_C.vs.D") -
               which(colnames(bt) == "lgFCH_A.vs.B"), 5L)
})

test_that("runEbfit() output feeds runBigTab() end-to-end", {
  skip_if_not_installed("reshape2")
  skip_if_not_installed("limma")
  bt <- runBigTab(runEbfit(make_tidy()))
  expect_equal(unname(bt[, "lgFCH_A.vs.B"]), c(2, -1, 0))
  expect_equal(unname(bt[, "lgFCH_C.vs.D"]), c(0.1, 3, -2))
})

test_that("FromEbfit2Table() builds a BigTab from a real limma eBayes fit", {
  skip_if_not_installed("limma")
  # Small, seeded two-group design -> a genuine MArrayLM object, which is the
  # input contract FromEbfit2Table expects (decideTests dispatches on it).
  set.seed(42)
  expr   <- matrix(stats::rnorm(30 * 6), nrow = 30,
                   dimnames = list(paste0("G", 1:30), NULL))
  grp    <- factor(rep(c("A", "B"), each = 3))
  design <- stats::model.matrix(~grp)
  fit    <- limma::eBayes(limma::lmFit(expr, design))

  Tab <- FromEbfit2Table(fit, pcut = 0.05, mcut = 2)

  expect_equal(nrow(Tab), 30L)
  expect_true(any(grepl("^lgFCH_", colnames(Tab))))
  expect_true(any(grepl("^FCH_",   colnames(Tab))))
  expect_true(any(grepl("^pvals_", colnames(Tab))))
  expect_true(any(grepl("^fdrs_",  colnames(Tab))))
  status_cols <- grep("^StatusFCH2FDR0.05_", colnames(Tab))
  expect_gt(length(status_cols), 0)
  expect_true(all(as.vector(Tab[, status_cols]) %in% c(-1, 0, 1)))
})
