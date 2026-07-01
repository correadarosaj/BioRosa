# deltaCtNormalize() normalizes RT-PCR/TLDA Ct values against a housekeeping
# gene. Its three documented steps are exercised with a hand-computed fixture:
#   1. Ct == 40 (undetected) is set to NA.
#   2. deltaCt = HK column - each column (per sample).
#   3. Remaining NAs are imputed as log2(0.2 * 2^min(column, na.rm = TRUE)).
#
# Fixture (rows = samples, columns = genes, hk = "RPLP0"):
#          RPLP0  GeneA  GeneB
#   S1        20     22     40   <- 40 becomes NA
#   S2        20     18     25
#
# After HK subtraction:
#   RPLP0: 0, 0 ; GeneA: -2, 2 ; GeneB: NA, -5
# GeneB's NA is imputed from its own min (-5):
#   log2(0.2 * 2^-5) = log2(0.2) - 5 = -7.321928

make_ct <- function() {
  matrix(c(20, 22, 40,
           20, 18, 25),
         nrow = 2, byrow = TRUE,
         dimnames = list(c("S1", "S2"), c("RPLP0", "GeneA", "GeneB")))
}

test_that("deltaCtNormalize() subtracts the housekeeping gene per sample", {
  out <- deltaCtNormalize(make_ct(), hk = "RPLP0")
  expect_equal(unname(out[, "RPLP0"]), c(0, 0))
  expect_equal(unname(out[, "GeneA"]), c(-2, 2))
  expect_equal(unname(out[, "GeneB"]),
               c(log2(0.2 * 2^-5), -5))
})

test_that("deltaCtNormalize() treats Ct == 40 as undetected and imputes it", {
  out <- deltaCtNormalize(make_ct(), hk = "RPLP0")
  # The S1/GeneB cell started at 40 -> NA -> imputed floor, never left as NA.
  expect_false(anyNA(out))
  expect_equal(out["S1", "GeneB"], log2(0.2 * 2^-5))
  # Imputed value is strictly below the observed minimum of the column.
  expect_lt(out["S1", "GeneB"], -5)
})

test_that("deltaCtNormalize() leaves a column with no undetected values unchanged by imputation", {
  ct <- matrix(c(20, 22,
                 20, 18),
               nrow = 2, byrow = TRUE,
               dimnames = list(c("S1", "S2"), c("RPLP0", "GeneA")))
  out <- deltaCtNormalize(ct, hk = "RPLP0")
  expect_equal(unname(out[, "GeneA"]), c(-2, 2))
  expect_false(anyNA(out))
})
