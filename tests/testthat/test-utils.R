# Small, dependency-free helper functions. These are pure base R, so the
# expectations are exact and the tests run anywhere the package loads.

test_that("numerize() turns stringified numbers (incl. factors) into numerics", {
  expect_identical(numerize(c("1", "2", "10")), c(1, 2, 10))
  # A factor's *labels*, not its integer codes, must be recovered:
  expect_identical(numerize(factor(c("10", "2", "3"))), c(10, 2, 3))
  expect_identical(numerize("3.5"), 3.5)
  expect_true(is.na(suppressWarnings(numerize("not a number"))))
})

test_that("leveler() maps a grouping vector to named index lists by first appearance", {
  expect_identical(
    leveler(c("A", "A", "B", "C", "B")),
    list(A = c(1L, 2L), B = c(3L, 5L), C = 4L)
  )
  # Order follows first appearance, not sorting:
  expect_identical(names(leveler(c("z", "a", "z"))), c("z", "a"))
  expect_identical(leveler(factor(c("x", "x"))), list(x = c(1L, 2L)))
})

test_that("pval2star() bins p-values into significance stars at the documented breaks", {
  p   <- c(0.0009, 0.001, 0.005, 0.03, 0.05, 0.07, 0.5)
  out <- pval2star(p)
  expect_s3_class(out, "factor")
  expect_equal(as.character(out),
               c("***", "***", "**", "*", "*", "+", ""))
  # Break points are right-closed: 0.05 is still "*", 0.1 is still "+".
  expect_equal(as.character(pval2star(c(0.1, 0.100001))), c("+", ""))
})

test_that("generate.Zscores() returns per-sample gene-set z-scores in long form", {
  # 2 genes x 2 samples. Any monotone-increasing 2-value row standardizes to
  # (-1/sqrt2, +1/sqrt2), so with k = 2 genes the set score per sample is
  # sum(z)/sqrt(k) = (-2/sqrt2)/sqrt2 = -1 for Sa and +1 for Sb.
  #   GeneX row = (1, 2) ; GeneY row = (3, 6)
  mat <- matrix(c(1, 2, 3, 6), nrow = 2, byrow = TRUE,
                dimnames = list(c("GeneX", "GeneY"), c("Sa", "Sb")))
  z <- generate.Zscores(mat, geneset = c("GeneX", "GeneY"),
                        geneset.name = "MySet")
  expect_equal(z$z.scores, c(-1, 1))
  expect_equal(rownames(z), c("Sa", "Sb"))
  expect_true(all(z$geneset.name == "MySet"))
})
