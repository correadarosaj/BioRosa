#' Run the full OpenXGR-style enrichment workflow and write outputs
#'
#' One-call convenience wrapper that reproduces what the OpenXGR web server
#' produces for a gene list: it runs [oSEA()], extracts the results table with
#' [oSEAextract()], and renders the dotplot ([oSEAdotplot()]) and forest plot
#' ([oSEAforest()]). Optionally it writes the same output files OpenXGR offers
#' for download: an enrichment table (`.txt` and `.xlsx`) and each figure as
#' both `.pdf` and `.png`.
#'
#' @param data a character vector of query genes, or a path to a one-column
#'   text file of gene identifiers.
#' @param set the gene-set collection: a named list of gene vectors, a `SET`
#'   object from [oRDS()], or `NULL` to use the bundled [guttman_pathways].
#' @param background optional gene universe; see [oSEA()].
#' @param FDR.cutoff keep only terms with `adjp < FDR.cutoff` in the returned
#'   table and figures. Default `0.05` (use `1` to keep all).
#' @param min.overlap minimum overlap to keep a term. Default `3`.
#' @param size.range gene-set size filter. Default `c(10, 2000)`.
#' @param output.dir if non-`NULL`, a directory into which output files are
#'   written (created if needed). Default `NULL` (no files written).
#' @param prefix file-name prefix for written outputs. Default `"EAgene"`.
#' @param width,height figure size in inches. Defaults match OpenXGR.
#' @param verbose logical.
#' @return Invisibly, a list with elements `eset` (the `eSET`), `table` (the
#'   extracted data frame), `dotplot` and `forest` (ggplot objects), and
#'   `files` (named paths of anything written).
#' @examples
#' \dontrun{
#' data("guttman_pathways", package = "BioRosa")
#' sets <- guttman_pathways[lengths(guttman_pathways) > 0]
#' res  <- rxgr_enrichment(
#'   sets[["Immune Genes (EG)"]], set = sets,
#'   min.overlap = 2, size.range = c(3, 5000), FDR.cutoff = 1
#' )
#' res$table
#' }
#' @export
rxgr_enrichment <- function(data, set = NULL, background = NULL,
                            FDR.cutoff = 0.05, min.overlap = 3,
                            size.range = c(10, 2000),
                            output.dir = NULL, prefix = "EAgene",
                            width = 5, height = 4, verbose = TRUE) {

  if (length(data) == 1L && file.exists(data)) {
    data <- readLines(data, warn = FALSE)
    data <- trimws(data)
    data <- data[nzchar(data)]
  }
  if (is.null(set)) {
    set <- get("guttman_pathways", envir = asNamespace("BioRosa"))
    set <- set[lengths(set) > 0]
  }

  eset <- oSEA(data, set, background = background, size.range = size.range,
               min.overlap = min.overlap, verbose = verbose)

  # Filter to significant terms (matching OpenXGR: filter(adjp < FDR.cutoff))
  keep <- eset$info$adjp < FDR.cutoff
  eset$info <- eset$info[keep, , drop = FALSE]
  rownames(eset$info) <- NULL

  tab <- oSEAextract(eset, sortBy = "adjp")

  files <- list()
  dotplot <- forest <- NULL
  if (nrow(eset$info) > 0L) {
    dotplot <- oSEAdotplot(eset, FDR.cutoff = min(FDR.cutoff, 0.05),
                           label.top = 5, size.title = "Number of genes")
    # zlim as OpenXGR sets it: 0 .. ceiling(95th percentile of -log10(FDR))
    zmax <- ceiling(stats::quantile(-log10(eset$info$adjp), 0.95, names = FALSE))
    forest <- tryCatch(
      oSEAforest(eset, top = 10, colormap = "spectral.top", zlim = c(0, zmax),
                 size.title = "Number\nof genes", sortBy = "or"),
      error = function(e) { if (verbose) message("forest: ", conditionMessage(e)); NULL }
    )
  } else if (verbose) {
    message("rxgr_enrichment: no terms pass FDR.cutoff = ", FDR.cutoff)
  }

  if (!is.null(output.dir) && nrow(tab) > 0L) {
    if (!dir.exists(output.dir)) dir.create(output.dir, recursive = TRUE)
    p <- function(...) file.path(output.dir, paste0(prefix, ...))

    f_txt <- p("_enrichment.txt")
    utils::write.table(tab, f_txt, sep = "\t", quote = FALSE, row.names = FALSE)
    files$txt <- f_txt

    if (requireNamespace("openxlsx", quietly = TRUE)) {
      f_xlsx <- p("_enrichment.xlsx")
      openxlsx::write.xlsx(tab, f_xlsx)
      files$xlsx <- f_xlsx
    }
    if (!is.null(dotplot)) {
      ggplot2::ggsave(p("_enrichment_dotplot.pdf"), dotplot, width = width, height = height)
      ggplot2::ggsave(p("_enrichment_dotplot.png"), dotplot, width = width, height = height, dpi = 300)
      files$dotplot_pdf <- p("_enrichment_dotplot.pdf")
      files$dotplot_png <- p("_enrichment_dotplot.png")
    }
    if (!is.null(forest)) {
      ggplot2::ggsave(p("_enrichment_forest.pdf"), forest, width = width, height = 3.5)
      ggplot2::ggsave(p("_enrichment_forest.png"), forest, width = width, height = 3.5, dpi = 300)
      files$forest_pdf <- p("_enrichment_forest.pdf")
      files$forest_png <- p("_enrichment_forest.png")
    }
    if (verbose) message("rxgr_enrichment: wrote ", length(files), " file(s) to ", output.dir)
  }

  invisible(list(eset = eset, table = tab, dotplot = dotplot,
                 forest = forest, files = files))
}
