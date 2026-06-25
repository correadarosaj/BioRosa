#' Extract a flat enrichment results table from an `eSET`
#'
#' Mirrors OpenXGR's `oSEAextract()`: returns a data frame of enriched terms
#' with the `overlap` (member) genes collapsed into a single comma-separated
#' string, sorted by the requested key.
#'
#' @param obj an `eSET` object from [oSEA()].
#' @param sortBy ordering of the output. One of `"adjp"`, `"pvalue"`,
#'   `"zscore"`, `"fc"`, `"nA"`, `"nO"`, `"or"`, `"id"`, `"name"`,
#'   `"distance"`. Default `"adjp"` (which orders by `pvalue` then descending
#'   `zscore`, as in the original).
#' @return A data frame with columns `name, id, nA, nO, fc, zscore, pvalue,
#'   adjp, or, CIl, CIu, distance, namespace, overlap`.
#' @examples
#' data("guttman_pathways", package = "BioRosa")
#' sets  <- guttman_pathways[lengths(guttman_pathways) > 0]
#' eset  <- oSEA(sets[["Immune Genes (EG)"]], sets, min.overlap = 2,
#'               size.range = c(3, 5000), verbose = FALSE)
#' oSEAextract(eset, sortBy = "or")
#' @export
oSEAextract <- function(obj, sortBy = c("adjp", "pvalue", "zscore", "fc", "nA",
                                        "nO", "or", "id", "name", "distance")) {
  sortBy <- match.arg(sortBy)
  if (!inherits(obj, "eSET")) {
    warning("There is no enrichment in the input object.")
    return(NULL)
  }
  tab <- obj$info
  if (nrow(tab) == 0L) return(tab[, setdiff(names(tab), "overlap"), drop = FALSE])

  tab$overlap <- vapply(tab$overlap, function(g) paste(g, collapse = ", "), character(1))

  ord <- switch(
    sortBy,
    adjp     = order(tab$pvalue, -tab$zscore),
    pvalue   = order(tab$pvalue, -tab$zscore),
    zscore   = order(-tab$zscore, tab$pvalue),
    fc       = order(-tab$fc, tab$pvalue),
    or       = order(-tab$or, tab$pvalue),
    nA       = order(-tab$nA, tab$pvalue, -tab$zscore),
    nO       = order(-tab$nO, tab$pvalue, -tab$zscore),
    name     = order(tab$name),
    id       = order(tab$id),
    distance = order(tab$distance, tab$pvalue, -tab$zscore)
  )
  res <- tab[ord, , drop = FALSE]
  rownames(res) <- NULL
  res
}
