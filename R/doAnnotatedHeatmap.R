# doAnnotatedHeatmap.R --------------------------------------------------------
# Imports: ComplexHeatmap, circlize, grid, stringr, weights, grDevices, stats
# ----------------------------------------------------------------------------

#' Annotated expression heatmap with a per-contrast fold-change side table
#'
#' @description
#' `doAnnotatedHeatmap()` draws a `ComplexHeatmap` of a gene-by-sample
#' expression matrix and appends, to its right, one text column per contrast in
#' which each cell carries the (display-transformed) fold change plus a
#' significance star. A left-hand row annotation lists the gene symbols in a
#' monospace font.
#'
#' Fold changes are shown on a linear scale via `sign(lgFCH) * 2^|lgFCH|`, and
#' significance stars follow the cut-points `0.001 / 0.01 / 0.05 / 0.1`
#' (`***`, `**`, `*`, `+`). Cell numbers are decimal-aligned down each column
#' using invisible white hyphens, rendered with `ComplexHeatmap::gt_render`. The
#' string-building logic (formerly the standalone `doTab()` helper) is now
#' internal to this function.
#'
#' The matrix is colour-scaled either as row Z-scores (default) or on the raw
#' log2-expression scale, with a blue / white / red ramp from
#' `circlize::colorRamp2`. Rows are clustered; columns are kept in the order
#' given by `rownames(annot.col)`. The heatmap is written to `grafname` as a PDF.
#'
#' For the grid-style table variant — boxed, colour-filled group bands over
#' decimal-aligned numeric cells — see [doAnnotatedHeatmapGrid()].
#'
#' @param grafname Character. Path to the output PDF file.
#' @param matx Numeric matrix of expression values (genes x samples). Must
#'   contain every sample in `rownames(annot.col)`.
#' @param annot.col Data frame of per-sample annotation; its row names define
#'   the heatmap column order.
#' @param colsplitx Optional vector used to split the heatmap into column
#'   groups. Default `NULL`.
#' @param column_ha Optional `ComplexHeatmap::HeatmapAnnotation` drawn above the
#'   heatmap. Default `NULL`.
#' @param BigTab Optional data frame of additional per-gene columns; a subset is
#'   selected via `BigTabcols`. Default `NULL`.
#' @param wdt,hgt Numeric PDF width / height in inches. `NULL` (default) derives
#'   them from the matrix dimensions.
#' @param setname Character. Caption drawn at the bottom. Default `""`.
#' @param column_names_max_height A `grid::unit` giving the maximum height
#'   reserved for column labels. Default `grid::unit(8, "cm")`.
#' @param BigTabcols Optional character vector; columns of `BigTab` matching any
#'   entry (via `stringr::str_detect`) are kept. Default `NULL`.
#' @param cfx Optional numeric matrix of log2 fold changes (genes x contrasts).
#'   When supplied together with `fdx`, one annotated text column per contrast
#'   is appended. Default `NULL`.
#' @param fdx Optional matrix of FDR / p-values matching the shape of `cfx`.
#'   Required when `cfx` is supplied. Default `NULL`.
#' @param ShowColumnNames Logical. Show sample names under the heatmap.
#'   Default `FALSE`.
#' @param fnt_size_title Numeric. Font size for the column-split titles.
#'   Default `20`.
#' @param scalerows Logical. Row Z-score the matrix (`TRUE`, default) or plot it
#'   on the raw log2-expression scale (`FALSE`).
#' @param rampvalues Numeric. Symmetric limit of the blue/white/red colour ramp
#'   when `scalerows = TRUE`. Default `1.5`.
#' @param ... Reserved for future use; currently ignored.
#'
#' @return Invisibly `NULL`; called for the side effect of writing `grafname`.
#' @seealso [doAnnotatedHeatmapGrid()] for the grid-style table variant.
#' @examples
#' \dontrun{
#' doAnnotatedHeatmap(
#'   grafname  = "heatmap.pdf",
#'   matx      = expr,            # genes x samples
#'   annot.col = annotx,          # row names = sample order
#'   colsplitx = annotx$group,
#'   cfx       = lgfch_mat,       # genes x contrasts (log2 FC)
#'   fdx       = pval_mat)        # genes x contrasts (p / FDR)
#' }
#' @export
doAnnotatedHeatmap <- function(grafname, matx, annot.col, colsplitx = NULL,
                               column_ha = NULL, BigTab = NULL,
                               wdt = NULL, hgt = NULL, setname = "",
                               column_names_max_height = grid::unit(8, "cm"),
                               BigTabcols = NULL, cfx = NULL, fdx = NULL,
                               ShowColumnNames = FALSE, fnt_size_title = 20,
                               scalerows = TRUE, rampvalues = 1.5, ...) {

  # ---- per-cell "<padded FCH><stars>" table builder (formerly doTab()) -----
  .build_tab <- function(fdrsx, coefsx) {
    transformfch <- function(lgfch) sign(lgfch) * (2 ^ abs(lgfch))
    padding <- function(x, n) {
      m <- ceiling(log10(abs(x) + .001)); x <- as.character(x)
      initspace <- n - m
      if (substr(x, 1, 1) != "-") initspace <- initspace + 1
      if (!stringr::str_detect(x, "\\.")) x <- paste0(x, ".")
      while (nchar(x) < n - initspace + 4) x <- paste0(x, "0")
      paste0("<span style='color:white'>",
             stringr::str_c(rep("\\-", initspace), collapse = ""), "</span>", x)
    }
    adspaceText <- function(x, n)
      paste0(x, "<span style='font-size:12pt;color:black'> ",
             stringr::str_c(rep("\\-", (n - nchar(x))), collapse = ""), "</span>\\:")

    # p-value -> star map (white spans keep every cell the same width)
    p.cuts.stars <- c(0.001, 0.01, 0.05, 0.1, 1)
    wsp <- "<span style='font-size:12pt;color:white'>*</span>"
    p.symbols.stars <- c(
      "***",
      paste0("**", wsp),
      paste0("*",  wsp, wsp),
      paste0("+",  wsp, wsp),
      paste0(wsp,  wsp, wsp)
    )

    coefsx[coefsx == 0] <- 1e-10
    fdrsx[] <- sapply(fdrsx, weights::starmaker,
                      p.levels = p.cuts.stars, symbols = p.symbols.stars)
    coefsx[] <- sapply(coefsx, transformfch); coefsx <- round(coefsx, 2)

    ss    <- rownames(coefsx)
    maxss <- max(sapply(ss, nchar))
    ss    <- sapply(ss, adspaceText, maxss + 1)
    maxdigits <- ceiling(log10(max(abs(coefsx))))

    Tab <- data.frame(Symbol = ss)
    for (i in seq_len(ncol(coefsx)))
      Tab[colnames(coefsx)[i]] <-
        paste0(sapply(coefsx[, i], padding, maxdigits), fdrsx[, i])
    rownames(Tab) <- ss
    colnames(Tab) <- c("Symbol", colnames(coefsx))
    Tab
  }

  scale_rows <- function(x) {
    m <- apply(x, 1, mean, na.rm = TRUE)
    s <- apply(x, 1, sd,   na.rm = TRUE)
    (x - m) / s
  }

  if (!is.null(BigTabcols)) {
    allBigTabcols <- c()
    for (i in BigTabcols)
      allBigTabcols <- append(allBigTabcols,
                              colnames(BigTab)[stringr::str_detect(colnames(BigTab), i)])
    BigTab <- BigTab[allBigTabcols]
  }

  ncontrasts <- dim(cfx)[2]
  n.genes    <- dim(matx)[1]

  if (is.null(wdt)) wdt <- dim(matx)[2] * 2 + dim(BigTab)[2] / 10
  if (is.null(hgt)) hgt <- max(8, n.genes / 4)

  mat <- matx[, rownames(annot.col)]
  if (scalerows) mat <- scale_rows(mat)

  Tab <- if (!is.null(cfx)) .build_tab(fdrsx = fdx, coefsx = cfx)
         else cbind.data.frame(Gene = rownames(matx))

  col_fun   <- circlize::colorRamp2(c(-1 * rampvalues, 0, rampvalues),
                                    c("blue", "white", "red"), space = "sRGB")
  scalename <- "Z-score"
  if (!scalerows) {
    col_fun   <- circlize::colorRamp2(c(min(mat) + 1, mean(mat), max(mat) - 1),
                                      c("blue", "white", "red"), space = "sRGB")
    scalename <- "log2-expression"
  }

  ht <- ComplexHeatmap::Heatmap(
    mat, name = scalename, column_split = colsplitx,
    column_title_gp = grid::gpar(fontsize = fnt_size_title), col = col_fun,
    top_annotation = column_ha, cluster_rows = TRUE, cluster_columns = FALSE,
    show_row_names = FALSE, show_column_names = ShowColumnNames,
    column_order = rownames(annot.col), use_raster = TRUE)

  ha_names <- ComplexHeatmap::rowAnnotation(
    Gene = ComplexHeatmap::anno_text(
      ComplexHeatmap::gt_render(Tab[, 1], align_widths = TRUE), location = 0, just = "left",
      gp = grid::gpar(fill = "white", border = "white", col = "black",
                      fontface = 2, fontsize = 12, fontfamily = "mono")))
  htlist <- ht + ha_names

  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {
      thisha <- ComplexHeatmap::rowAnnotation(
        x = ComplexHeatmap::anno_text(
          ComplexHeatmap::gt_render(Tab[, i + 1], align_widths = FALSE),
          gp = grid::gpar(box_col = "white", box_lwd = 1, fontface = 2,
                          fontsize = 12, fontfamily = "mono"),
          just = "left", show_name = FALSE))
      names(thisha) <- paste0("Tab", i)
      htlist <- htlist + thisha
    }
  }

  grDevices::pdf(file = grafname, width = wdt, height = hgt)
  on.exit(grDevices::dev.off(), add = TRUE)
  ComplexHeatmap::draw(htlist, padding = grid::unit(c(8, 8, 12, 12), "mm"),
                       column_title = setname, column_title_side = "bottom")

  # two-line bold header per contrast column (strip the "lgFCH_" prefix)
  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {
      nm <- paste0("Tab", i)
      ComplexHeatmap::decorate_annotation(nm, {
        grid::grid.text(gsub("\\.", "\n", substring(colnames(Tab)[i + 1], 7)),
                        y = grid::unit(1, "npc") + grid::unit(2, "mm"),
                        just = "bottom", hjust = 0, rot = 0,
                        gp = grid::gpar(box_col = "white", box_lwd = 1, fontface = 2,
                                        fontsize = 10, fontfamily = "mono"))
      })
    }
  }

  invisible(NULL)
}
