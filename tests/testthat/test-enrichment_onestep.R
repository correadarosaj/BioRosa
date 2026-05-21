test_that("enrichment_onestep() rejects missing required arguments", {
  expect_error(
    enrichment_onestep(),
    "are all required",
    fixed = TRUE
  )
  expect_error(
    enrichment_onestep(genes = c("A", "B")),
    "are all required",
    fixed = TRUE
  )
  expect_error(
    enrichment_onestep(genes = c("A", "B"), log2FoldChange = c(1, -1)),
    "are all required",
    fixed = TRUE
  )
})

test_that("enrichment_onestep() rejects unequal-length inputs", {
  expect_error(
    enrichment_onestep(
      genes          = c("A", "B", "C"),
      log2FoldChange = c(1, -1),
      padj           = c(0.01, 0.02, 0.5)
    ),
    "same length",
    fixed = TRUE
  )
  expect_error(
    enrichment_onestep(
      genes          = c("A", "B"),
      log2FoldChange = c(1, -1),
      padj           = c(0.01, 0.02, 0.5)
    ),
    "same length",
    fixed = TRUE
  )
})

test_that("enrichment_onestep() errors cleanly when no genes pass the padj filter", {
  skip_if_not_installed("msigdbr")
  out_dir <- withr::local_tempdir()
  expect_error(
    enrichment_onestep(
      genes          = c("TP53", "MYC", "BRCA1"),
      log2FoldChange = c(1.2, -0.8, 0.5),
      padj           = c(0.9, 0.95, 0.99),
      output_dir     = out_dir,
      padj_cutoff    = 0.05
    ),
    "No genes after filtering padj",
    fixed = TRUE
  )
})
