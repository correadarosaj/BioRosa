# The default RXGR collections mirror the OpenXGR web server: Hallmark, GO BP,
# KEGG, Reactome, plus the bundled lab list. Needs MSigDB via msigdbr.
test_that(".rxgr_default_sets() includes KEGG alongside the other collections", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not_installed("msigdbr")

  sets <- .rxgr_default_sets()
  expect_named(sets, c("Hallmark", "GO_BP", "KEGG", "Reactome", "guttman_pathways"))
  expect_gt(length(sets$KEGG), 150)
  expect_true(all(startsWith(names(sets$KEGG), "KEGG_")))
  expect_true("KEGG_JAK_STAT_SIGNALING_PATHWAY" %in% names(sets$KEGG))
  expect_true(is.character(sets$KEGG[[1]]))
})
