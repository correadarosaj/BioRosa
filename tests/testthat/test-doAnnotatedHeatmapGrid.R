# Small deterministic fixture: 6 features x 8 samples, with a matching BigTab of
# FCH_/pvals_ columns for a response x treatment x visit contrast set.
make_inputs <- function(contrasts = c("R.Drug.W2vsBL", "NR.Drug.W2vsBL", "RvsNR.Drug.W2vsBL")) {
  genes   <- c("TP53", "MYC", "BRCA1", "EGFR", "GAPDH", "IL13")
  samples <- paste0("S", 1:8)

  set.seed(1)
  mat <- matrix(stats::rnorm(length(genes) * length(samples)),
                nrow = length(genes), dimnames = list(genes, samples))

  annot.col <- data.frame(
    response  = rep(c("R", "NR"), each = 4),
    Treatment = rep(c("Drug", "Pbo"), times = 4),
    row.names = samples
  )

  # one FCH_ + pvals_ column per contrast, deterministic values
  BigTab <- data.frame(row.names = genes)
  for (k in seq_along(contrasts)) {
    BigTab[[paste0("FCH_",   contrasts[k])]] <- seq(-2, 2, length.out = length(genes)) + k
    BigTab[[paste0("pvals_", contrasts[k])]] <- c(1e-5, 1e-3, 0.02, 0.08, 0.5, 0.9)
  }
  list(mat = mat, annot.col = annot.col, BigTab = BigTab, contrasts = contrasts)
}

test_that("doAnnotatedHeatmapGrid() writes a non-empty PDF and reports the contrast set", {
  inp <- make_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedHeatmapGrid(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot.col,
    colsplitx = inp$annot.col$response, BigTab = inp$BigTab)

  expect_true(file.exists(pdf))
  expect_gt(file.info(pdf)$size, 0)
  expect_equal(res$n_genes, nrow(inp$mat))
  expect_equal(res$n_contrasts, length(inp$contrasts))
  # group = first dot-token, parsed in contrast order
  expect_equal(res$groups, c("R", "NR", "RvsNR"))
})

test_that("BigTabcols selects and orders the displayed contrasts", {
  inp <- make_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedHeatmapGrid(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot.col,
    BigTab = inp$BigTab,
    BigTabcols = c("RvsNR.Drug.W2vsBL", "R.Drug.W2vsBL"))

  expect_equal(res$n_contrasts, 2L)
  expect_equal(res$groups, c("RvsNR", "R"))   # order follows BigTabcols
})

test_that("grouping generalizes to a tissue contrast dimension", {
  inp <- make_inputs(contrasts = c("Lesional.W4vsBL", "Nonlesional.W4vsBL"))
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedHeatmapGrid(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot.col, BigTab = inp$BigTab)

  expect_equal(res$groups, c("Lesional", "Nonlesional"))
  expect_gt(file.info(pdf)$size, 0)
})

test_that("custom column prefixes are honoured", {
  inp <- make_inputs()
  bt  <- inp$BigTab
  colnames(bt) <- sub("^FCH_",   "fc.",  colnames(bt))
  colnames(bt) <- sub("^pvals_", "p.",   colnames(bt))
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedHeatmapGrid(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot.col, BigTab = bt,
    fch_prefix = "fc.", pval_prefix = "p.")

  expect_equal(res$n_contrasts, length(inp$contrasts))
  expect_gt(file.info(pdf)$size, 0)
})

test_that("missing or malformed inputs raise actionable errors", {
  inp <- make_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  expect_error(
    doAnnotatedHeatmapGrid(grafname = pdf, mat = inp$mat, annot.col = inp$annot.col),
    "BigTab", fixed = TRUE)

  # a requested contrast that has no matching columns
  expect_error(
    doAnnotatedHeatmapGrid(grafname = pdf, mat = inp$mat, annot.col = inp$annot.col,
                           BigTab = inp$BigTab, BigTabcols = "does.not.exist"),
    "Missing columns", fixed = TRUE)

  # a feature in BigTab absent from mat
  bad <- inp$BigTab[c("TP53", "MYC"), ]
  rownames(bad)[1] <- "NOT_A_GENE"
  expect_error(
    doAnnotatedHeatmapGrid(grafname = pdf, mat = inp$mat, annot.col = inp$annot.col,
                           BigTab = bad),
    "must be a row of `mat`", fixed = TRUE)
})

test_that(".agh_strip_constant drops constant leading dot-tokens", {
  expect_equal(
    BioRosa:::.agh_strip_constant(c("Drug.W2vsBL", "Drug.W4vsBL")),
    c("W2vsBL", "W4vsBL"))
  # nothing constant => unchanged
  expect_equal(
    BioRosa:::.agh_strip_constant(c("R.W2vsBL", "NR.W2vsBL")),
    c("R.W2vsBL", "NR.W2vsBL"))
})
