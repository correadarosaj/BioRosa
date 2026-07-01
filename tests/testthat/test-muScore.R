# muScore() is a pure, base-R rank statistic with an exact documented contract:
#   contribution[i, v] = rank_min[i, v] + rank_max[i, v] - (n + 1)
# and muScore[i] = rowSums over variables. The fixtures below carry
# analytically hand-computed expectations so a regression in the ranking or
# tie handling is caught precisely (not just "it ran").

test_that("muScore() sums the per-variable rank contribution across columns", {
  # Two strictly increasing columns over 3 subjects. For distinct values,
  # rank_min == rank_max == rank, so per_var = 2*rank - (n+1) = 2*rank - 4:
  #   ranks 1,2,3 -> -2, 0, 2 per column; two identical columns double it.
  mat <- matrix(c(1, 2, 3,
                  10, 20, 30),
                nrow = 3,
                dimnames = list(c("S1", "S2", "S3"), c("V1", "V2")))
  expect_equal(muScore(mat), c(S1 = -4, S2 = 0, S3 = 4))
})

test_that("muScore() is tie-aware: a tie contributes 0, keeping the column centred", {
  # One column with a tie at the bottom: values 5, 5, 9 over 3 subjects.
  #   rank_min = 1, 1, 3 ; rank_max = 2, 2, 3
  #   per_var  = (1+2-4), (1+2-4), (3+3-4) = -1, -1, 2  (sums to 0)
  mat <- matrix(c(5, 5, 9), ncol = 1,
                dimnames = list(c("S1", "S2", "S3"), "V1"))
  score <- muScore(mat)
  expect_equal(score, c(S1 = -1, S2 = -1, S3 = 2))
  expect_equal(sum(score), 0)          # no-tie / balanced-tie zero-centring
})

test_that("muScore() propagates rownames and coerces a data frame", {
  df <- data.frame(V1 = c(3, 1, 2), V2 = c(1, 2, 3),
                   row.names = c("a", "b", "c"))
  score <- muScore(df)                 # as.matrix() coercion path
  expect_named(score, c("a", "b", "c"))
  expect_equal(sum(score), 0)          # every column is a permutation -> centred
})

test_that("muScore() returns unnamed output for an unnamed matrix", {
  mat <- matrix(c(1, 2, 3, 4), nrow = 2)
  expect_null(names(muScore(mat)))
})
