# biorosa_summary() is exercised on a hand-written, minimal enrichment export
# tree (CSV format, which the function accepts alongside XLSX). Two Hallmark
# pathways are significant in both ORA and FGSEA on the same side and must
# reach consensus; one is ORA-only and one is FGSEA-nonsignificant, and both
# must be excluded. A third consensus pathway (IFN-gamma) shares most of its
# genes with IFN-alpha and must be hidden as redundant. Running through the package namespace (not source()) is
# deliberate: it guards the data.table-awareness of the package.

make_fixture <- function(root) {
  dir.create(file.path(root, "Hallmark"), recursive = TRUE)
  write.csv(data.frame(
    pathway     = c("HALLMARK_INTERFERON_ALPHA_RESPONSE",
                    "HALLMARK_INTERFERON_GAMMA_RESPONSE",
                    "HALLMARK_OXIDATIVE_PHOSPHORYLATION",
                    "HALLMARK_APOPTOSIS"),
    pval        = c(1e-12, 1e-9, 1e-8, 0.2),
    padj        = c(1e-10, 1e-7, 1e-6, 0.3),
    log2err     = NA_real_,
    ES          = c(0.8, 0.7, -0.7, 0.3),
    NES         = c(2.5, 2.1, -2.0, 1.2),
    size        = c(4, 4, 3, 2),
    leadingEdge = c("ISG15/MX1/IFI6", "ISG15/MX1/IFI6/OAS1", "NDUFA1/COX7A2", "BAX/CASP3")
  ), file.path(root, "FGSEA_results.csv"), row.names = FALSE)
  ora <- function(id, padj, genes) data.frame(
    ID = id, Description = id, GeneRatio = "3/7", BgRatio = "50/20000",
    FoldEnrichment = 5, pvalue = padj / 10, p.adjust = padj, qvalue = padj,
    geneID = genes, Count = 3)
  write.csv(rbind(
    ora("HALLMARK_INTERFERON_ALPHA_RESPONSE", 1e-8, "ISG15/MX1/IFI6/OAS1"),
    ora("HALLMARK_INTERFERON_GAMMA_RESPONSE", 1e-6, "ISG15/MX1/IFI6/OAS1"),
    ora("HALLMARK_APOPTOSIS", 0.5, "BAX")),
    file.path(root, "Hallmark", "Hallmark_UP.csv"), row.names = FALSE)
  write.csv(rbind(
    ora("HALLMARK_OXIDATIVE_PHOSPHORYLATION", 1e-5, "NDUFA1/COX7A2/ATP5F1A"),
    ora("HALLMARK_MYC_TARGETS_V1", 0.01, "ATP5F1A")),
    file.path(root, "Hallmark", "Hallmark_DOWN.csv"), row.names = FALSE)
  write.csv(data.frame(SYMBOL = c("ISG15", "MX1", "IFI6", "OAS1", "BAX"),
                       log2FoldChange = c(2, 1.8, 1.5, 1.2, 0.9), padj = 0.01),
            file.path(root, "up_df.csv"), row.names = FALSE)
  write.csv(data.frame(SYMBOL = c("NDUFA1", "COX7A2", "ATP5F1A"),
                       log2FoldChange = c(-1.5, -1.2, -1.1), padj = 0.01),
            file.path(root, "down_df.csv"), row.names = FALSE)
  root
}

test_that("biorosa_summary() finds cross-method consensus pathways and writes a lollipop report", {
  for (p in c("readxl", "data.table", "Matrix", "igraph", "ggplot2", "jsonlite")) {
    skip_if_not_installed(p)
  }
  root <- make_fixture(withr::local_tempdir())

  res <- expect_no_error(biorosa_summary(root, contrast = "A vs B"))

  cons <- res$consensus
  expect_setequal(cons$pathway, c("interferon alpha response", "interferon gamma response",
                                  "oxidative phosphorylation"))
  expect_equal(cons[cons$pathway == "interferon alpha response", ]$direction, "UP")
  expect_equal(cons[cons$pathway == "interferon alpha response", ]$mean_NES, 2.5)
  expect_equal(cons[cons$pathway == "interferon alpha response", ]$best_padj, 1e-10)
  expect_equal(cons[cons$pathway == "oxidative phosphorylation", ]$direction, "DOWN")
  expect_equal(cons[cons$pathway == "oxidative phosphorylation", ]$mean_NES, -2.0)
  expect_true(all(cons$n_tools == 2L))
  # IFN-gamma shares all its genes with the better-ranked IFN-alpha: redundant
  ifng <- cons[cons$pathway == "interferon gamma response", ]
  expect_equal(ifng$redundant_with, "Hallmark::interferon alpha response")
  expect_false(ifng$plotted)
  expect_true(all(cons$plotted[is.na(cons$redundant_with)]))

  expect_s3_class(res$figure, "ggplot")

  out <- file.path(root, "biorosa_consensus_summary")
  for (f in c("report.html", "summary_figure.png", "summary_figure.pdf",
              "consensus_pathways.csv")) {
    expect_true(file.exists(file.path(out, f)), info = f)
  }
  csv <- read.csv(file.path(out, "consensus_pathways.csv"))
  expect_equal(nrow(csv), 3L)
  expect_equal(sum(csv$plotted), 2L)

  html <- paste(readLines(file.path(out, "report.html"), warn = FALSE), collapse = "\n")
  expect_match(html, "interferon alpha response", fixed = TRUE)
  expect_match(html, "<details>", fixed = TRUE)
  expect_false(grepl("myc targets", html, fixed = TRUE))
  expect_false(grepl("interferon gamma response", html, fixed = TRUE))

  # max_overlap = 1 disables the redundancy filter
  res2 <- biorosa_summary(root, output_dir = file.path(root, "nofilter"), max_overlap = 1)
  expect_true(all(is.na(res2$consensus$redundant_with)))
  expect_equal(sum(res2$consensus$plotted), 3L)
})

test_that("biorosa_summary() handles no consensus without error", {
  for (p in c("readxl", "data.table", "Matrix", "igraph", "ggplot2", "jsonlite")) {
    skip_if_not_installed(p)
  }
  root <- withr::local_tempdir()
  dir.create(file.path(root, "Hallmark"))
  write.csv(data.frame(ID = "HALLMARK_APOPTOSIS", Description = "HALLMARK_APOPTOSIS",
                       p.adjust = 0.01, geneID = "BAX"),
            file.path(root, "Hallmark", "Hallmark_UP.csv"), row.names = FALSE)
  res <- expect_no_error(biorosa_summary(root))
  expect_equal(nrow(res$consensus), 0L)
  expect_s3_class(res$figure, "ggplot")
  expect_true(file.exists(file.path(root, "biorosa_consensus_summary", "report.html")))
})
