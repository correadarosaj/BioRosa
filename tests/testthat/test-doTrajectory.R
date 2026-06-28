## Synthetic two-arm longitudinal clinical data with missingness
make_traj <- function(seed = 1) {
  set.seed(seed)
  visits <- c("W0", "W4", "W8", "W16")
  vtime  <- c(0, 4, 8, 16)
  mk <- function(arm, n, slope) {
    do.call(rbind, lapply(seq_len(n), function(id) {
      b  <- rnorm(1, 20, 4)
      sc <- b + slope * vtime + rnorm(length(vtime), 0, 2)
      data.frame(record_id = paste0(arm, "_", id), Trt = arm,
                 Visit = visits, EASI = sc)
    }))
  }
  d <- rbind(mk("Pbo", 16, -0.15), mk("Drug", 16, -0.7))
  d$EASI[sample(nrow(d), 20)] <- NA
  d
}
visits <- c("W0", "W4", "W8", "W16")

test_that("doTrajectory returns a ggplot for spaghetti and mean modes", {
  d <- make_traj()
  p1 <- doTrajectory(d, "record_id", "Visit", "EASI", group = "Trt",
                     time_levels = visits)
  expect_s3_class(p1, "ggplot")

  p2 <- doTrajectory(d, "record_id", "Visit", "EASI", group = "Trt",
                     time_levels = visits, spaghetti = FALSE, error = "se")
  expect_s3_class(p2, "ggplot")
})

test_that("doTrajectory validates inputs", {
  d <- make_traj()
  expect_error(doTrajectory(d, "nope", "Visit", "EASI"), "not found")
  expect_error(
    doTrajectory(d, "record_id", "Visit", "EASI", spaghetti = FALSE,
                 group_mean = FALSE),
    "Nothing to draw")
  expect_error(
    doTrajectory(d, "record_id", "Visit", "EASI", time_levels = c("W0", "W4")),
    "not in `time_levels`")
})

test_that("doTrajectoryModel computes within- and between-arm stars", {
  d <- make_traj()
  res <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                           baseline = "W0", time_levels = visits,
                           value = "change", reference = "Pbo")
  expect_s3_class(res$plot, "ggplot")
  expect_true(all(c(".group", ".time", "estimate", "SE",
                    "p_within", "p_between",
                    "star_within", "star_between") %in% names(res$estimates)))
  # Drug effect is strong: late-visit within-arm change is significant
  drug16 <- subset(res$estimates, .group == "Drug" & .time == "W16")
  expect_lt(drug16$p_within, 0.05)
  expect_true(nzchar(drug16$star_within))
  # Drug separates from Pbo by W16
  expect_lt(drug16$p_between, 0.05)
})

test_that("doTrajectoryModel supports mean and pchange value modes", {
  d <- make_traj()
  rm <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                          baseline = "W0", time_levels = visits, value = "mean")
  expect_equal(nrow(rm$estimates), 8)   # 2 arms x 4 visits (baseline kept)
  rp <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                          baseline = "W0", time_levels = visits,
                          value = "pchange")
  expect_equal(nrow(rp$estimates), 6)   # baseline excluded
})

test_that("LOCF imputation runs and fills the visit grid", {
  d <- make_traj()
  res <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                           baseline = "W0", time_levels = visits,
                           value = "change", impute = "locf")
  expect_s3_class(res$plot, "ggplot")
})

test_that("MICE imputation runs when mice is available", {
  skip_if_not_installed("mice")
  d <- make_traj()
  res <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                           baseline = "W0", time_levels = visits,
                           value = "change", impute = "mice", mice_m = 2)
  expect_s3_class(res$plot, "ggplot")
})

test_that("stars can be overridden from a plain p-value table", {
  d <- make_traj()
  pt <- data.frame(
    group   = rep(c("Drug", "Pbo"), each = 3),
    time    = rep(c("W4", "W8", "W16"), 2),
    p.value = c(0.2, 0.02, 0.0001, 0.5, 0.4, 0.3))
  res <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                           baseline = "W0", time_levels = visits,
                           value = "change", pvals = pt)
  drug16 <- subset(res$estimates, .group == "Drug" & .time == "W16")
  expect_equal(drug16$p_within, 1e-4)
  expect_equal(drug16$star_within, "***")
})

test_that("stars can be overridden from a BigTab row", {
  d <- make_traj()
  bt <- data.frame(
    pvals_Drug.W4vsBL = 0.3, pvals_Drug.W8vsBL = 0.004,
    pvals_Drug.W16vsBL = 1e-5,
    pvals_Pbo.W4vsBL = 0.6, pvals_Pbo.W8vsBL = 0.5, pvals_Pbo.W16vsBL = 0.2)
  rownames(bt) <- "EASI"
  res <- doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                           baseline = "W0", time_levels = visits,
                           value = "change", pvals = bt, score_row = "EASI")
  drug8 <- subset(res$estimates, .group == "Drug" & .time == "W8")
  expect_equal(drug8$p_within, 0.004)
  expect_equal(drug8$star_within, "**")
  expect_error(
    doTrajectoryModel(d, "record_id", "Visit", "EASI", group = "Trt",
                      baseline = "W0", time_levels = visits, pvals = bt),
    "score_row")
})
