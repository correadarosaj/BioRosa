#' Reshape tidy model results into an `ebfit` object
#'
#' @description
#' `runEbfit()` converts a long, tidy table of per-gene / per-contrast model
#' results (e.g. from a mixed-effects model fit one biomarker at a time) into the
#' compact `ebfit` structure that [runBigTab()] expects: a list of two matrices,
#' `coef` (estimates) and `p.value`, both with biomarkers as rows and contrasts
#' as columns.
#'
#' @param tb A data frame in long form with (at least) the columns `biomarker`,
#'   `contrasts`, `estimate`, and `p.value` — one row per biomarker x contrast.
#'
#' @return A list with `coef` and `p.value` numeric matrices (biomarkers x
#'   contrasts), suitable as the `ebfit` argument of [runBigTab()].
#' @seealso [runBigTab()]
#' @examples
#' \dontrun{
#' ebfit <- runEbfit(tidy_model_table)
#' str(ebfit)
#' }
#' @export
runEbfit = function(tb){
  # Reshape one value column at a time into a biomarker x contrast matrix.
  # Uses base-R row-name handling so the function is self-contained (no
  # magrittr/tibble needing to be attached on the search path).
  to_matrix <- function(value.var) {
    wide <- reshape2::dcast(tb, biomarker ~ contrasts, value.var = value.var)
    rn   <- wide$biomarker
    wide$biomarker <- NULL
    m <- as.matrix(wide)
    rownames(m) <- rn
    m
  }

  return(list(coef = to_matrix('estimate'), p.value = to_matrix('p.value')))
}
