# Deterministic synthetic universe: 100 genes, query = g1..g10. One gene set
# ("hit") is built to overlap the query strongly; the rest are background noise.
make_sets <- function() {
  universe <- paste0("g", 1:100)
  query    <- paste0("g", 1:10)
  sets <- list(
    hit  = paste0("g", 1:15),          # overlap 10/10, size 15  -> strongly enriched
    half = paste0("g", 8:25),          # overlap 3,  size 18
    bg1  = paste0("g", 40:70),         # overlap 0
    bg2  = paste0("g", 60:95)          # overlap 0
  )
  list(universe = universe, query = query, sets = sets)
}

test_that("oSEA returns an eSET with OpenXGR statistics and ranks the true hit first", {
  d <- make_sets()
  eset <- oSEA(d$query, d$sets, background = d$universe,
               min.overlap = 1, size.range = c(2, 90), verbose = FALSE)

  expect_s3_class(eset, "eSET")
  expect_true(all(c("name", "nA", "nO", "fc", "zscore", "pvalue", "adjp",
                    "or", "CIl", "CIu", "overlap") %in% names(eset$info)))
  expect_gt(nrow(eset$info), 0)

  # most significant term (sorted by pvalue) is the constructed hit
  expect_equal(eset$info$name[1], "hit")
  expect_equal(eset$info$nO[eset$info$name == "hit"], 10L)
  # odds ratio of a real enrichment is > 1 with a finite CI
  expect_gt(eset$info$or[eset$info$name == "hit"], 1)
  expect_true(is.finite(eset$info$CIl[eset$info$name == "hit"]))
})

test_that("oSEAextract flattens overlap genes to a sorted character table", {
  d <- make_sets()
  eset <- oSEA(d$query, d$sets, background = d$universe,
               min.overlap = 1, size.range = c(2, 90), verbose = FALSE)
  tab <- oSEAextract(eset, sortBy = "or")

  expect_s3_class(tab, "data.frame")
  expect_type(tab$overlap, "character")          # list-column collapsed to string
  expect_equal(tab$name[1], "hit")               # highest odds ratio on top
})

test_that("oSEAdotplot and oSEAforest return ggplot objects", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggrepel")
  d <- make_sets()
  eset <- oSEA(d$query, d$sets, background = d$universe,
               min.overlap = 1, size.range = c(2, 90), verbose = FALSE)

  expect_s3_class(oSEAdotplot(eset, FDR.cutoff = 1), "ggplot")
  # adjp.cutoff = 1 keeps every term so the forest is always drawable
  expect_s3_class(oSEAforest(eset, adjp.cutoff = 1), "ggplot")
})

test_that("oColormap returns an interpolating palette function", {
  pal <- oColormap("spectral.top")
  expect_type(pal, "closure")
  cols <- pal(5)
  expect_length(cols, 5)
  expect_true(all(grepl("^#", cols)))
})

test_that("oSEA errors when no query gene is in the universe", {
  d <- make_sets()
  expect_error(
    oSEA(c("zzz1", "zzz2"), d$sets, background = d$universe, verbose = FALSE),
    "None of the query genes", fixed = TRUE)
})
