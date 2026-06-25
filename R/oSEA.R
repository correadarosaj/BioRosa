#' Set Enrichment Analysis (OpenXGR-compatible)
#'
#' Performs over-representation / set enrichment analysis of a query gene list
#' against a collection of gene sets (ontology terms, pathways, ...), using
#' Fisher's exact test. The statistics returned are identical in definition to
#' those produced by the OpenXGR web server's `oSEA()`:
#'
#' For each term, with `X` = number of overlapping genes, `K` = number of query
#' genes present in the universe, `M` = number of genes annotated to the term
#' (within the universe), and `N` = universe size, a 2x2 contingency table is
#' built as `matrix(c(X, K-X, M-X, N-M-K+X), nrow = 2)` and:
#' \itemize{
#'   \item \strong{pvalue}: \code{fisher.test(cTab, alternative = "greater")$p.value}
#'         (one-tailed by default).
#'   \item \strong{zscore}: \code{(X - K*M/N) / sqrt(K*M/N * (N-M)/N * (N-K)/(N-1))}
#'         (theoretical hypergeometric mean/variance).
#'   \item \strong{fc}: fold change, \code{X / (K*M/N)}.
#'   \item \strong{or}, \strong{CIl}, \strong{CIu}: odds ratio and 95\% confidence
#'         interval from a two-sided \code{fisher.test(cTab)}.
#'   \item \strong{adjp}: FDR via \code{p.adjust(pvalue, method)} (BH by default).
#' }
#'
#' @param data a character vector of query gene identifiers (e.g. gene symbols).
#' @param set the gene-set collection. Either (a) a named `list` of character
#'   vectors (each element one gene set), or (b) a `SET`-like list as returned
#'   by [oRDS()], i.e. a list with `$info`, a data frame carrying a list-column
#'   `member` of genes and (optionally) columns `name`, `id`, `namespace`,
#'   `distance`.
#' @param background optional character vector defining the gene universe. If
#'   `NULL` (default), the universe is the union of all genes across `set` --
#'   matching how OpenXGR derives the background from the annotation.
#' @param size.range integer length-2: keep only gene sets whose size (within
#'   the universe) falls in this inclusive range. Default `c(10, 2000)`.
#' @param min.overlap minimum number of overlapping genes required to keep a
#'   term. Default `3`.
#' @param test the test to use. Currently `"fisher"` (default). `"hypergeo"` and
#'   `"binomial"` are accepted as aliases that also report Fisher p-values for
#'   compatibility.
#' @param p.tail `"one-tail"` (default) or `"two-tails"`.
#' @param p.adjust.method method passed to [stats::p.adjust()]. Default `"BH"`.
#' @param verbose logical; print progress messages.
#' @return An object of S3 class `eSET`: a list with elements `data`,
#'   `background`, and `info` (a data frame of per-term statistics, columns
#'   `name, id, nA, nO, fc, zscore, pvalue, adjp, or, CIl, CIu, distance,
#'   namespace, overlap`, sorted by `pvalue` then descending `or`).
#'   Use [oSEAextract()] to obtain a flat results table.
#' @examples
#' data("guttman_pathways", package = "BioRosa")
#' sets  <- guttman_pathways[lengths(guttman_pathways) > 0]
#' query <- sets[["Immune Genes (EG)"]]
#' eset  <- oSEA(query, sets, min.overlap = 2, size.range = c(3, 5000),
#'               verbose = FALSE)
#' head(oSEAextract(eset))
#' @export
oSEA <- function(data, set, background = NULL,
                 size.range = c(10, 2000), min.overlap = 3,
                 test = c("fisher", "hypergeo", "binomial"),
                 p.tail = c("one-tail", "two-tails"),
                 p.adjust.method = c("BH", "BY", "bonferroni", "holm", "hochberg", "hommel"),
                 verbose = TRUE) {

  test <- match.arg(test)
  p.tail <- match.arg(p.tail)
  p.adjust.method <- match.arg(p.adjust.method)

  norm <- .rxgr_normalise_set(set)
  gs <- norm$gs                  # named list of gene vectors
  set_info <- norm$info          # data frame: name, id, namespace, distance

  if (length(gs) == 0L) stop("`set` contains no gene sets.")

  data <- unique(as.character(data))
  data <- data[!is.na(data) & nzchar(data)]

  # Universe / background
  if (is.null(background)) {
    background <- unique(unlist(gs, use.names = FALSE))
  } else {
    background <- unique(as.character(background))
  }
  N <- length(background)

  genes.group <- intersect(data, background)
  K <- length(genes.group)
  if (verbose) {
    message(sprintf("oSEA: %d query genes (%d in universe of %d), %d gene sets.",
                    length(data), K, N, length(gs)))
  }
  if (K == 0L) stop("None of the query genes are in the universe (background).")

  # Restrict each set to the universe; per-term overlaps and sizes
  gs <- lapply(gs, function(g) intersect(g, background))
  overlaps <- lapply(gs, function(g) sort(intersect(genes.group, g)))
  nA <- vapply(gs, length, integer(1))           # M, term size in universe
  nO <- vapply(overlaps, length, integer(1))     # X, overlap

  keep <- nA >= size.range[1] & nA <= size.range[2] & nO >= min.overlap
  if (!any(keep)) {
    if (verbose) message("oSEA: no gene set passes the size/overlap filter.")
    eSET <- list(data = data, background = background, info = .rxgr_empty_info())
    class(eSET) <- "eSET"
    return(eSET)
  }

  gs <- gs[keep]; overlaps <- overlaps[keep]
  nA <- nA[keep]; nO <- nO[keep]
  set_info <- set_info[keep, , drop = FALSE]

  M <- nA; X <- nO
  exp <- K * M / N

  # Z-score: theoretical hypergeometric moments
  var.exp <- K * M / N * (N - M) / N * (N - K) / (N - 1)
  zscore <- ifelse(is.na(var.exp) | var.exp == 0, NA_real_, (X - exp) / sqrt(var.exp))

  # Fold change
  fc <- X / exp

  # Per-term Fisher's exact test (p-value one/two tailed; OR + CI two-sided)
  pvalue <- numeric(length(X))
  or <- numeric(length(X)); CIl <- numeric(length(X)); CIu <- numeric(length(X))
  for (i in seq_along(X)) {
    cTab <- matrix(c(X[i], K - X[i], M[i] - X[i], N - M[i] - K + X[i]), nrow = 2)
    if (all(cTab == 0)) {
      pvalue[i] <- 1
    } else if (p.tail == "one-tail") {
      pvalue[i] <- stats::fisher.test(cTab, alternative = "greater")$p.value
    } else {
      alt <- if (X[i] >= exp[i]) "greater" else "less"
      pvalue[i] <- stats::fisher.test(cTab, alternative = alt)$p.value
    }
    ft <- stats::fisher.test(cTab)
    or[i] <- unname(ft$estimate)
    ci <- ft$conf.int
    CIl[i] <- ci[1]; CIu[i] <- ci[2]
  }

  adjp <- stats::p.adjust(pvalue, method = p.adjust.method)

  # Rounding mirrors the original (signif 3 for effect sizes, 2 for p-values)
  zscore <- signif(zscore, 3); fc <- signif(fc, 3)
  or <- signif(or, 3); CIl <- signif(CIl, 3); CIu <- signif(CIu, 3)
  pvalue <- signif(pvalue, 2); adjp <- signif(adjp, 2)

  info <- data.frame(
    name = set_info$name,
    id = set_info$id,
    nA = nA, nO = nO,
    fc = fc, zscore = zscore,
    pvalue = pvalue, adjp = adjp,
    or = or, CIl = CIl, CIu = CIu,
    distance = set_info$distance,
    namespace = set_info$namespace,
    stringsAsFactors = FALSE
  )
  info$overlap <- overlaps
  rownames(info) <- NULL

  # Sort by pvalue then descending odds ratio (as in the original)
  ord <- order(info$pvalue, -info$or)
  info <- info[ord, , drop = FALSE]
  rownames(info) <- NULL

  eSET <- list(data = data, background = background, info = info)
  class(eSET) <- "eSET"
  eSET
}

#' @export
print.eSET <- function(x, ...) {
  cat(sprintf("<eSET> RXGR enrichment: %d query genes, universe %d, %d enriched terms\n",
              length(x$data), length(x$background), nrow(x$info)))
  invisible(x)
}

# ---- internal helpers -------------------------------------------------------

# Normalise a `set` argument into list(gs = named list of gene vectors,
# info = data.frame(name, id, namespace, distance)).
.rxgr_normalise_set <- function(set) {
  # SET-like object from oRDS: a list with $info data.frame carrying `member`
  if (is.list(set) && !is.null(set$info) && "member" %in% names(set$info)) {
    info <- set$info
    gs <- info$member
    if (!is.list(gs)) gs <- as.list(gs)
    gs <- lapply(gs, function(g) unique(as.character(unlist(g))))
    ids <- if (!is.null(info$id)) as.character(info$id) else as.character(seq_along(gs))
    nm  <- if (!is.null(info$name)) as.character(info$name) else ids
    ns  <- if (!is.null(info$namespace)) as.character(info$namespace) else NA_character_
    di  <- if (!is.null(info$distance)) info$distance else NA
    names(gs) <- ids
    return(list(gs = gs,
                info = data.frame(name = nm, id = ids, namespace = ns,
                                  distance = di, stringsAsFactors = FALSE)))
  }
  # Plain named list of character vectors
  if (is.list(set)) {
    gs <- lapply(set, function(g) unique(as.character(g)))
    ids <- names(gs)
    if (is.null(ids) || any(!nzchar(ids))) ids <- as.character(seq_along(gs))
    names(gs) <- ids
    return(list(gs = gs,
                info = data.frame(name = ids, id = ids,
                                  namespace = NA_character_, distance = NA,
                                  stringsAsFactors = FALSE)))
  }
  stop("`set` must be a named list of gene vectors or a SET object from oRDS().")
}

.rxgr_empty_info <- function() {
  info <- data.frame(name = character(), id = character(), nA = integer(),
                     nO = integer(), fc = numeric(), zscore = numeric(),
                     pvalue = numeric(), adjp = numeric(), or = numeric(),
                     CIl = numeric(), CIu = numeric(), distance = numeric(),
                     namespace = character(), stringsAsFactors = FALSE)
  info$overlap <- list()
  info
}
