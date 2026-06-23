test_that("guttman_pathways ships as a named list of gene-symbol vectors", {
  data("guttman_pathways", package = "BioRosa", envir = environment())

  expect_type(guttman_pathways, "list")
  expect_length(guttman_pathways, 350)
  expect_true(!is.null(names(guttman_pathways)))
  expect_false(any(names(guttman_pathways) == ""))

  # every element is a character vector of symbols
  expect_true(all(vapply(guttman_pathways, is.character, logical(1))))

  # a known directional signature set is present
  expect_true("MADAD (LSvsNL) Up" %in% names(guttman_pathways))
})
