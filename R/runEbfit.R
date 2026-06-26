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
  coefs = reshape2::dcast(tb,biomarker~contrasts,value.var = 'estimate')%>%
    column_to_rownames('biomarker')%>% as.matrix()

  pvals = reshape2::dcast(tb,biomarker~contrasts,value.var = 'p.value')%>%
    column_to_rownames('biomarker')%>% as.matrix()

  return(list(coef = coefs , p.value = pvals))
}
