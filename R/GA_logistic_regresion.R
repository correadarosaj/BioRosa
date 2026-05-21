#' Genetic-algorithm predictor selection for binary logistic regression
#'
#' @description
#' Wraps `GA::ga` (binary chromosome — one bit per predictor) around
#' `stats::glm(..., family = binomial)` to search for the predictor subset
#' that optimises either the model's `AIC` or its in-sample `AUC`. The
#' input is a single matrix (or data frame) in which one column is the
#' binary response (0/1) and the remaining columns are candidate
#' predictors. The function returns a list collecting the fitted final
#' model, the selected subset, fit statistics, the ROC object, the
#' generation-by-generation fitness trace, and the underlying `GA`
#' object — everything a downstream pipeline typically needs to report
#' or plot results.
#'
#' Selection rule: the "best subset" is the set of predictors that appear
#' in every elite solution returned by `GA::ga` (i.e. columns where
#' `colSums(GA@solution) == nrow(GA@solution)`). When the GA has a unique
#' best chromosome this collapses to that chromosome's selected bits.
#'
#' Fitness:
#' - `criterion = "AIC"` returns `-AIC(fit)` (GA maximises, lower AIC is better).
#' - `criterion = "AUC"` returns `AUC - 1e-5 * length(selected)` so that
#'   ties in AUC are broken by parsimony. AIC already penalises complexity.
#' Models with an empty predictor set are assigned `-Inf` (AIC) or `0` (AUC).
#'
#' @param data A matrix or data frame containing the binary response and
#'   the candidate predictors. Will be coerced to a data frame internally.
#' @param response Column of `data` holding the binary response (0/1).
#'   May be a character column name or an integer column index.
#'   Default `1` — i.e. the first column is taken as the response.
#' @param predictors Optional character vector of predictor column names
#'   to consider. Default `NULL` uses every column of `data` except the
#'   response.
#' @param criterion Fitness criterion, either `"AIC"` (default) or
#'   `"AUC"`. See description for how each is maximised.
#' @param popSize,maxiter,run,pmutation,pcrossover GA control parameters
#'   forwarded to `GA::ga`. Defaults: `popSize = 50`, `maxiter = 40`,
#'   `run = 500`, `pmutation = 0.1`, `pcrossover = 0.8`.
#' @param elitism Number of elite chromosomes preserved each generation.
#'   Default `base::max(1, round(popSize * 0.05))` — the `GA::ga` default.
#' @param parallel Logical or integer passed to `GA::ga`. Default `FALSE`
#'   so the function is deterministic given `seed` and does not silently
#'   fork worker processes.
#' @param seed Integer seed forwarded to `GA::ga` for reproducibility.
#'   Default `1234`.
#' @param keepBest Logical, passed to `GA::ga`. Default `TRUE`.
#' @param verbose If `TRUE`, prints a short summary at the end. Default
#'   `FALSE`.
#'
#' @return A list of class `"GA_logistic_regression"` with components:
#' \describe{
#'   \item{`best_subset`}{Character vector of predictors selected in every
#'     elite solution.}
#'   \item{`final_model`}{The `glm` refit on `best_subset` (or the
#'     intercept-only model if `best_subset` is empty).}
#'   \item{`coefficients`}{Data frame of coefficient estimates, standard
#'     errors, z-values, p-values and 95\% Wald confidence intervals for
#'     `final_model`.}
#'   \item{`fit_stats`}{Named numeric vector: `AIC`, `BIC`, `deviance`,
#'     `null_deviance`, `df_residual`, `df_null`, `n_predictors`.}
#'   \item{`auc`}{In-sample AUC of `final_model` (numeric scalar).}
#'   \item{`roc`}{The `pROC::roc` object for `final_model`.}
#'   \item{`predictions`}{Data frame with columns `observed`, `prob`,
#'     `predicted` (0/1 at threshold 0.5).}
#'   \item{`fitness_trace`}{Data frame of GA progress with columns
#'     `generation`, `best`, `mean`, `median`. For `criterion = "AIC"` the
#'     values are reported on the AIC scale (i.e. sign-flipped back).}
#'   \item{`best_fitness`}{The optimal raw fitness value reported by GA
#'     (negative AIC, or AUC with parsimony tweak — same scale used during
#'     evolution).}
#'   \item{`criterion`}{The criterion used (`"AIC"` or `"AUC"`).}
#'   \item{`ga`}{The full `GA::ga` result object.}
#'   \item{`call`}{The matched function call.}
#' }
#'
#' @examples
#' \dontrun{
#'   set.seed(1)
#'   n <- 60; p <- 10
#'   X <- matrix(rnorm(n * p), nrow = n,
#'               dimnames = list(NULL, paste0("X", 1:p)))
#'   beta <- c(2.5, -2.0, 1.8, rep(0, p - 3))
#'   y <- rbinom(n, 1, 1 / (1 + exp(-(X %*% beta))))
#'   dat <- data.frame(y = y, X)
#'   res <- GA_logistic_regression(dat, response = "y",
#'                                 criterion = "AIC", maxiter = 20)
#'   res$best_subset
#'   res$fit_stats
#'   res$coefficients
#' }
#'
#' @importFrom stats glm binomial AIC BIC predict as.formula coef
#'   confint.default pnorm
#' @export
GA_logistic_regression <- function(data,
                                   response   = 1,
                                   predictors = NULL,
                                   criterion  = c("AIC", "AUC"),
                                   popSize    = 50,
                                   maxiter    = 40,
                                   run        = 500,
                                   pmutation  = 0.1,
                                   pcrossover = 0.8,
                                   elitism    = base::max(1, round(popSize * 0.05)),
                                   parallel   = FALSE,
                                   seed       = 1234,
                                   keepBest   = TRUE,
                                   verbose    = FALSE) {

  if (!requireNamespace("GA", quietly = TRUE)) {
    stop("Package 'GA' is required for GA_logistic_regression(). ",
         "Install it with install.packages('GA').")
  }
  if (!requireNamespace("pROC", quietly = TRUE)) {
    stop("Package 'pROC' is required for GA_logistic_regression(). ",
         "Install it with install.packages('pROC').")
  }

  criterion <- match.arg(criterion)
  call      <- match.call()

  # ---- normalise the input matrix --------------------------------------
  data <- as.data.frame(data)

  if (is.numeric(response)) {
    if (response < 1L || response > ncol(data)) {
      stop("`response` index is out of range for `data`.")
    }
    response_name <- colnames(data)[response]
  } else {
    response_name <- as.character(response)
    if (!response_name %in% colnames(data)) {
      stop(sprintf("Response column '%s' not found in `data`.", response_name))
    }
  }

  y_vec <- data[[response_name]]
  if (!all(stats::na.omit(y_vec) %in% c(0, 1))) {
    stop("Response column must be coded as 0/1.")
  }

  if (is.null(predictors)) {
    predictors <- setdiff(colnames(data), response_name)
  } else {
    missing_p <- setdiff(predictors, colnames(data))
    if (length(missing_p)) {
      stop("Predictors not found in `data`: ",
           paste(missing_p, collapse = ", "))
    }
  }

  if (length(predictors) < 1L) {
    stop("Need at least one candidate predictor.")
  }

  # Make sure downstream formula building uses the column literally named "y".
  work_data        <- data[, c(response_name, predictors), drop = FALSE]
  names(work_data) <- c("y", predictors)

  # ---- fitness function ------------------------------------------------
  fitness_fn <- function(x) {
    selected <- predictors[x == 1L]
    if (length(selected) == 0L) {
      return(if (criterion == "AIC") -Inf else 0)
    }
    form <- as.formula(paste("y ~", paste(selected, collapse = " + ")))
    fit  <- tryCatch(
      suppressWarnings(glm(form, data = work_data,
                           family = binomial(link = "logit"))),
      error = function(e) NULL
    )
    if (is.null(fit) || !fit$converged) {
      return(if (criterion == "AIC") -Inf else 0)
    }
    if (criterion == "AIC") {
      return(-AIC(fit))
    }
    pred <- predict(fit, newdata = work_data, type = "response")
    auc_val <- as.numeric(
      pROC::auc(pROC::roc(work_data$y, pred, quiet = TRUE))
    )
    auc_val - 1e-5 * length(selected)
  }

  # ---- run GA ----------------------------------------------------------
  ga_res <- GA::ga(
    type       = "binary",
    fitness    = fitness_fn,
    nBits      = length(predictors),
    popSize    = popSize,
    maxiter    = maxiter,
    run        = run,
    pmutation  = pmutation,
    pcrossover = pcrossover,
    elitism    = elitism,
    parallel   = parallel,
    seed       = seed,
    keepBest   = keepBest,
    monitor    = FALSE
  )

  # ---- distill outputs -------------------------------------------------
  sol <- ga_res@solution
  if (is.null(dim(sol))) sol <- matrix(sol, nrow = 1L)
  best_subset <- predictors[colSums(sol) == nrow(sol) & colSums(sol) > 0]

  if (length(best_subset) == 0L) {
    final_form <- as.formula("y ~ 1")
  } else {
    final_form <- as.formula(paste("y ~", paste(best_subset, collapse = " + ")))
  }
  final_fit <- suppressWarnings(
    glm(final_form, data = work_data, family = binomial(link = "logit"))
  )

  # Coefficient table (tidy).
  co  <- summary(final_fit)$coefficients
  ci  <- tryCatch(suppressWarnings(confint.default(final_fit)),
                  error = function(e) matrix(NA_real_, nrow = nrow(co), ncol = 2))
  coef_df <- data.frame(
    term      = rownames(co),
    estimate  = co[, "Estimate"],
    std.error = co[, "Std. Error"],
    statistic = co[, "z value"],
    p.value   = co[, "Pr(>|z|)"],
    conf.low  = ci[, 1],
    conf.high = ci[, 2],
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  # Predictions / ROC / AUC.
  prob <- as.numeric(predict(final_fit, type = "response"))
  predictions <- data.frame(
    observed  = work_data$y,
    prob      = prob,
    predicted = as.integer(prob >= 0.5)
  )
  roc_obj <- pROC::roc(work_data$y, prob, quiet = TRUE)
  auc_val <- as.numeric(pROC::auc(roc_obj))

  # Fit statistics.
  fit_stats <- c(
    AIC           = AIC(final_fit),
    BIC           = BIC(final_fit),
    deviance      = final_fit$deviance,
    null_deviance = final_fit$null.deviance,
    df_residual   = final_fit$df.residual,
    df_null       = final_fit$df.null,
    n_predictors  = length(best_subset)
  )

  # Fitness trace (sign-flipped back to AIC scale when criterion = "AIC").
  summary_mat <- ga_res@summary
  trace <- data.frame(
    generation = seq_len(nrow(summary_mat)),
    best       = summary_mat[, "max"],
    mean       = summary_mat[, "mean"],
    median     = summary_mat[, "median"]
  )
  if (criterion == "AIC") {
    trace$best   <- -trace$best
    trace$mean   <- -trace$mean
    trace$median <- -trace$median
  }

  out <- list(
    best_subset   = best_subset,
    final_model   = final_fit,
    coefficients  = coef_df,
    fit_stats     = fit_stats,
    auc           = auc_val,
    roc           = roc_obj,
    predictions   = predictions,
    fitness_trace = trace,
    best_fitness  = ga_res@fitnessValue,
    criterion     = criterion,
    ga            = ga_res,
    call          = call
  )
  class(out) <- c("GA_logistic_regression", "list")

  if (isTRUE(verbose)) {
    cat("Fitness criterion :", criterion, "\n")
    cat("Best subset       :",
        if (length(best_subset)) paste(best_subset, collapse = ", ") else "(none)",
        "\n")
    cat(sprintf("AIC = %.3f | AUC = %.3f | n predictors = %d\n",
                fit_stats[["AIC"]], auc_val, fit_stats[["n_predictors"]]))
  }

  out
}
