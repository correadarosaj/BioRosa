make_bigtab <- function() {
  data.frame(
    GENENAME       = c("TP53", "MYC", "BRCA1", "EGFR", "GAPDH"),
    lgFCH_A_vs_B   = c( 2.1, -1.8,  0.2,  3.0,  0.0),
    pvals_A_vs_B   = c(1e-7, 8e-5, 0.4, 1e-9, 0.99),
    fdr_A_vs_B     = c(3e-5, 2e-3, 0.5, 1e-6, 0.99),
    Status_A_vs_B  = c( 1L,  -1L,  0L,  1L,  0L),
    lgFCH_C_vs_D   = c( 0.1,  2.5, -2.2, 0.0, 0.3),
    pvals_C_vs_D   = c(0.5,  1e-6, 1e-5, 0.9, 0.4),
    fdr_C_vs_D     = c(0.6,  1e-4, 5e-4, 0.95,0.5),
    Status_C_vs_D  = c( 0L,   1L,  -1L,  0L,  0L),
    stringsAsFactors = FALSE
  )
}

test_that("process_degs() rejects bad inputs", {
  expect_error(process_degs(),                  "data frame", fixed = TRUE)
  expect_error(process_degs(BigTab = list()),   "data frame", fixed = TRUE)
  expect_error(
    process_degs(BigTab = data.frame(x = 1)),
    "GENENAME",
    fixed = TRUE
  )
  expect_error(
    process_degs(BigTab = make_bigtab(), cont.list = character(0)),
    "non-empty",
    fixed = TRUE
  )
})

test_that("process_degs() returns correct counts and DEG vectors", {
  bt  <- make_bigtab()
  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  res  <- process_degs(
    BigTab      = bt,
    cont.list   = c("A_vs_B", "C_vs_D"),
    FCH         = 1,
    pcut        = 0.05,
    method      = "fdr",
    output_xlsx = xlsx
  )

  expect_named(res, c("summary", "degs"))
  expect_equal(nrow(res$summary), 2L)
  expect_equal(res$summary$contrast, c("A_vs_B", "C_vs_D"))
  expect_equal(res$summary$Down, c(1L, 1L))
  expect_equal(res$summary$Up,   c(2L, 1L))
  expect_true("FDR"  %in% colnames(res$summary))
  expect_false("PVAL" %in% colnames(res$summary))

  expect_equal(sort(res$degs$A_vs_B), c("EGFR", "MYC", "TP53"))
  expect_equal(sort(res$degs$C_vs_D), c("BRCA1", "MYC"))

  expect_true(file.exists(xlsx))
  expect_gt(file.info(xlsx)$size, 0)
})

test_that("process_degs() reports PVAL when method = 'none'", {
  bt  <- make_bigtab()
  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  res  <- process_degs(bt, c("A_vs_B"), output_xlsx = xlsx)  # method default = "none"
  expect_true("PVAL" %in% colnames(res$summary))
  expect_false("FDR" %in% colnames(res$summary))
})

test_that("process_degs() errors when a contrast does not map to a unique Status column", {
  bt <- make_bigtab()
  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  expect_error(
    process_degs(bt, c("missing_contrast"), output_xlsx = xlsx),
    "unique Status column",
    fixed = TRUE
  )
})
