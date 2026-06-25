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

# Regression test for "undefined columns selected" inside FGSEA's run_block().
#
# The bug: data.table's cedta() check sees that BioRosa does not
# `Imports: data.table`, so `[.data.table` falls through to `[.data.frame`
# when called from inside the package namespace. The previous
# `res[order(-res$NES)][1, ]$pathway` then attempts column indexing with
# positions 1..nrow(res), which exceeds the 8 columns fgsea returns.
#
# The bug only fires when an FGSEA collection returns >0 rows, so the
# test builds a synthetic DEG list whose UP set is a real Hallmark
# pathway. The test is gated behind every heavy Bioc dep so it skips
# cleanly on machines without them.
test_that("enrichment_onestep() completes end-to-end on a DEG list with FGSEA hits", {
  skip_on_cran()
  skip_if_offline()
  for (p in c("msigdbr", "fgsea", "clusterProfiler", "ReactomePA",
              "enrichplot", "org.Hs.eg.db", "openxlsx", "ggplot2",
              "data.table")) {
    skip_if_not_installed(p)
  }

  hm <- msigdbr::msigdbr(species = "human", collection = "H")
  ifn_genes <- unique(hm$gene_symbol[
    hm$gs_name == "HALLMARK_INTERFERON_ALPHA_RESPONSE"
  ])
  skip_if(length(ifn_genes) < 40,
          "Hallmark IFN-alpha pathway unexpectedly small")

  set.seed(1)
  up   <- head(ifn_genes, 30)
  down <- c("MYC", "TP53", "BRCA1", "EGFR", "CDKN1A", "GAPDH",
            "ACTB", "TUBB", "RPL5", "RPS6")

  genes  <- c(up, down)
  lgfc   <- c(runif(length(up),    min =  0.7, max =  2.0),
              runif(length(down),  min = -2.0, max = -0.7))
  padj_v <- runif(length(genes),   min = 1e-6, max = 0.04)

  out_dir <- withr::local_tempdir()

  res <- expect_no_error(
    enrichment_onestep(
      genes          = genes,
      log2FoldChange = lgfc,
      padj           = padj_v,
      output_dir     = out_dir,
      padj_cutoff    = 0.05,
      log2fc_cutoff  = 0,
      pval_cutoff    = 0.5,
      qval_cutoff    = 0.5,
      run_rxgr       = FALSE   # keep this regression test focused on FGSEA
    )
  )

  expect_named(res, c("fgsea", "ora", "gsea", "rxgr"))
  expect_named(res$fgsea, c("UP", "DOWN"))
  expect_true(file.exists(file.path(out_dir, "FGSEA_results.xlsx")))
  expect_true(file.exists(file.path(out_dir, "up_df.csv")))
  expect_true(file.exists(file.path(out_dir, "down_df.csv")))

  # Most important: FGSEA UP/Hallmark should be non-empty (the IFN
  # pathway is built from itself) and at least one top-pathway PNG must
  # have been emitted by the previously-failing code path.
  expect_gt(nrow(res$fgsea$UP$Hallmark), 0)
  pngs <- list.files(out_dir, pattern = "^FGSEA_.*_top\\.png$", full.names = TRUE)
  expect_gt(length(pngs), 0)
  expect_true(all(file.info(pngs)$size > 0))
})
