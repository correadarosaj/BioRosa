# Deterministic fixture with analytically known normalization (logFC) values.
#
# Reference (NL) = 0 at baseline for every gene, so logFC = mean lesional value.
#   G1 (Up):   LS = 2 at BL, 1 at W4  -> logFC 2 (BL), 1 (W4); Reg.Type "Up"
#   G2 (Down): LS = -2 at BL, -1 at W4 -> logFC -2 (BL), -1 (W4); Reg.Type "Down"
# Two arms (Drug = S1,S2; Placebo = S3,S4) carry identical values, so the group
# logFC per gene x visit x arm is exact.
make_long <- function() {
  ls_val <- function(g, v) if (g == "G1") c(BL = 2, W4 = 1)[[v]] else
                                            c(BL = -2, W4 = -1)[[v]]
  subj <- c(S1 = "Drug", S2 = "Drug", S3 = "Placebo", S4 = "Placebo")
  rows <- list()
  for (s in names(subj)) for (g in c("G1", "G2")) {
    rows[[length(rows) + 1]] <- data.frame(
      SubjectID = s, Treatment = subj[[s]], Gene = g,
      Visit  = c("BL", "BL", "W4"),
      Tissue = c("LS", "NL", "LS"),
      Value  = c(ls_val(g, "BL"), 0, ls_val(g, "W4")),
      stringsAsFactors = FALSE)
  }
  do.call(rbind, rows)
}

test_that("compute_normalization() returns the exact logFC and regulation", {
  cn <- compute_normalization(make_long(), reference = "NL",
                              arm_col = "Treatment", degs = c("G1", "G2"))
  expect_equal(cn$n_genes, 2L)
  nz <- cn$normalization

  # baseline = the disease regulation; reference subtracted is 0
  expect_equal(unique(nz$reference), 0)
  g1bl <- nz$logFC[nz$.gene == "G1" & nz$.visit == "BL" & nz$.arm == "Drug"]
  g1w4 <- nz$logFC[nz$.gene == "G1" & nz$.visit == "W4" & nz$.arm == "Drug"]
  g2bl <- nz$logFC[nz$.gene == "G2" & nz$.visit == "BL" & nz$.arm == "Drug"]
  expect_equal(g1bl, 2);  expect_equal(g1w4, 1);  expect_equal(g2bl, -2)
  expect_equal(unique(nz$Reg.Type[nz$.gene == "G1"]), "Up")
  expect_equal(unique(nz$Reg.Type[nz$.gene == "G2"]), "Down")
})

test_that("compute_normalization() orders visits with baseline first", {
  nz <- compute_normalization(make_long(), reference = "NL",
                              arm_col = "Treatment", degs = c("G1", "G2"))$normalization
  expect_equal(levels(nz$.visit)[1], "BL")
})

test_that("plot_normalization() and evaluate_normalization() return ggplots", {
  res <- evaluate_normalization(make_long(), reference = "NL",
                                arm_col = "Treatment", degs = c("G1", "G2"),
                                signature_name = "Demo")
  expect_named(res, c("normalization", "reference", "plot"))
  expect_s3_class(res$plot, "ggplot")
  # the figure builds without error (boxplot + facet + mean points)
  expect_no_error(ggplot2::ggplot_build(res$plot))
})

test_that("a single-arm design builds without the treatment facet", {
  one <- make_long()[make_long()$Treatment == "Drug", ]
  res <- evaluate_normalization(one, reference = "NL", arm_col = NULL,
                                degs = c("G1", "G2"), signature_name = "Solo")
  expect_s3_class(res$plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(res$plot))
})

test_that("compute_normalization() errors on missing columns", {
  expect_error(compute_normalization(data.frame(Gene = 1)),
               "Missing columns", fixed = TRUE)
})

test_that("evaluate_normalization() errors when no gene passes the filter", {
  expect_error(evaluate_normalization(make_long(), reference = "NL",
                                      arm_col = "Treatment", degs = "ZZZ"),
               "No genes passed", fixed = TRUE)
})
