#' Draw a richly annotated expression heatmap with side fold-change tables
#'
#' @description
#' `FancyAnnotatedHeatmap` produces a publication-style heatmap PDF of a
#' gene-by-sample expression matrix using `ComplexHeatmap`. On top of the
#' standard heatmap it can attach:
#'
#' * a column annotation block (`column_ha`) and an optional column split
#'   (`colsplitx`) for grouping samples;
#' * a left-hand row annotation containing gene symbols rendered in a
#'   monospace font with consistent column widths;
#' * one extra right-hand text column per contrast, each cell carrying
#'   the (transformed) log2 fold-change plus a significance star derived
#'   from the corresponding FDR / p-value.
#'
#' Fold-change values are transformed for display via
#' `sign(lgfch) * 2 ^ |lgfch|` so the rendered numbers are on a fold-change
#' scale rather than log2 scale. Significance stars follow the cut-points
#' `c(0.001, 0.01, 0.05, 0.1, 1)` with symbols `***`, `**`, `*`, `+`, and
#' blank. Numeric formatting is handled by the inline `padding()` helper,
#' which uses invisible white hyphens to align decimal points across rows.
#'
#' The heatmap is colour-scaled either as row Z-scores (default) or on the
#' raw log2-expression scale, using a blue / white / red ramp built with
#' `circlize::colorRamp2`. Rows are clustered by Euclidean distance with
#' complete linkage; columns are kept in the order supplied by
#' `rownames(annot.col)`.
#'
#' The function has the side effect of writing the heatmap to `grafname`
#' as a PDF (via `pdf()` / `dev.off()`) and returns invisibly.
#'
#' @param grafname Character. Path to the output PDF file.
#' @param matx Numeric matrix of expression values. Rows are genes
#'   (named), columns are samples. Must contain every sample listed in
#'   `rownames(annot.col)`.
#' @param annot.col Data frame of sample-level annotation. Row names are
#'   sample IDs and define the column order of the heatmap.
#' @param colsplitx Optional vector used by `ComplexHeatmap::Heatmap` to
#'   split the heatmap into column groups. Default `NULL` (no split).
#' @param column_ha Optional `HeatmapAnnotation` object to place above
#'   the heatmap (e.g. clinical / phenotype tracks). Default `NULL`.
#' @param BigTab Optional data frame of additional per-gene columns from
#'   which a subset can be selected via `BigTabcols`. Default `NULL`.
#' @param wdt Numeric. PDF width in inches. If `NULL`, derived from the
#'   matrix dimensions as `ncol(matx) * 2 + ncol(cfx) / 10`.
#' @param hgt Numeric. PDF height in inches. If `NULL`, derived as
#'   `max(8, nrow(matx) / 4)`.
#' @param setname Character. Title drawn at the bottom of the heatmap
#'   (e.g. the gene-set name). Default empty string.
#' @param column_names_max_height A `grid::unit` giving the maximum
#'   height reserved for column labels. Default `unit(5, "cm")`.
#' @param BigTabcols Optional character vector of column-name patterns;
#'   columns of `BigTab` matching any pattern (via `stringr::str_detect`)
#'   are kept. Default `NULL`.
#' @param cfx Optional numeric matrix of log2 fold changes. Rows are
#'   genes (must include all of `rownames(matx)`), columns are contrasts.
#'   When supplied, one annotated text column per contrast is appended
#'   to the heatmap. Default `NULL`.
#' @param fdx Optional matrix of FDR or p-values matching the shape of
#'   `cfx`. Required when `cfx` is supplied. Used to attach significance
#'   stars to each fold-change cell.
#' @param ShowColumnNames Logical. Show sample names along the heatmap's
#'   bottom axis. Default `FALSE`.
#' @param fnt_size_title Numeric. Font size for the column-split titles.
#'   Default `8`.
#' @param scalerows Logical. If `TRUE` (default), each row of `matx` is
#'   converted to a Z-score before plotting and the legend is labelled
#'   `Z-score`. If `FALSE`, raw values are used and the legend is
#'   labelled `log2-expression`.
#' @param rampvalues Numeric. Symmetric extreme of the colour ramp when
#'   `scalerows = TRUE`: the ramp spans
#'   `c(-rampvalues, 0, rampvalues)`. Default `2`.
#' @param ... Currently unused; reserved for future extensions.
#'
#' @return Invisibly `NULL`. Called for the side effect of writing a PDF
#'   to `grafname`.
#'
#' @seealso [doAnnotatedHeatmap()] for the earlier non-fancy variant.
#'
#' @export
FancyAnnotatedHeatmap <- function(
    grafname,
    matx,        # matrix of expression
    annot.col,   # annotation data
    colsplitx = NULL,
    column_ha = NULL,
    BigTab = NULL,
    wdt = NULL,
    hgt = NULL,
    setname = '',
    column_names_max_height = unit(5, "cm"),
    BigTabcols = NULL,
    cfx = NULL,  # log2 fold change of contrasts of interest
    fdx = NULL,  # FDR or p-value for contrasts of interest
    ShowColumnNames = FALSE,
    fnt_size_title = 8,
    scalerows = TRUE,
    rampvalues = 2,
    ...
) {
  require(stringr)
  require(weights)
  require(circlize)
  require(ComplexHeatmap)

  if (!is.null(BigTabcols)) {
    allBigTabcols <- c()
    for (i in BigTabcols) {
      allBigTabcols <- append(allBigTabcols, colnames(BigTab)[str_detect(colnames(BigTab), i)])
    }
    BigTab <- BigTab[allBigTabcols]
  }

  ncontrasts <- dim(cfx)[2]
  n.genes    <- dim(matx)[1]

  if (is.null(wdt)) { wdt <- dim(matx)[2] * 2 + dim(cfx)[2] / 10 }
  if (is.null(hgt)) { hgt <- max(8, n.genes / 4) }

  mat <- matx[, rownames(annot.col)]

  scale_rows <- function(x) {
    m <- apply(x, 1, mean, na.rm = TRUE)
    s <- apply(x, 1, sd,   na.rm = TRUE)
    return((x - m) / s)
  }

  if (scalerows) mat <- scale_rows(mat)

  if (!is.null(cfx)) {
    coefsx <- cfx[rownames(mat), ]
    fdrsx  <- fdx[rownames(mat), ]

    transformfch <- function(lgfch) {
      sign(lgfch) * (2 ^ abs(lgfch))
    }

    # Format a number as a fixed-width HTML string so that values in a column
    # align visually when rendered via gt_render().
    #
    # Alignment is achieved by prepending invisible white-colored hyphens that
    # occupy the same horizontal space as digits or a minus sign would. This
    # keeps the decimal point and sign column consistent across all values.
    #
    # Args:
    #   x  : numeric scalar — the (already-transformed) fold-change value.
    #   n  : integer — number of digits to the left of the decimal in the
    #        largest absolute value in the column (i.e. ceiling(log10(max|coefsx|))).
    #        Controls how many leading invisible characters are prepended.
    #
    # Returns:
    #   A character string containing an HTML <span> with white-colored leading
    #   hyphens followed by the zero-padded number, e.g.:
    #     "  3.14"  →  "<span style='color:white'>\\-\\-</span>3.14"
    #     " -3.14"  →  "<span style='color:white'>\\-</span>-3.14"
    #     " 12.50"  →  "<span style='color:white'>\\-</span>12.50"
    #     "-12.50"  →  "-12.50"   (no leading span needed)
    padding <- function(x, n) {
      # Number of integer digits in x (used to determine leading padding)
      m <- ceiling(log10(abs(x) + .001))
      x <- as.character(x)

      # Positive numbers get one extra leading space to align with the '-' sign
      # of negative numbers
      initspace <- n - m
      if (substr(x, 1, 1) != '-') initspace <- initspace + 1

      # Ensure a decimal point is present, then zero-pad to a consistent width
      if (!str_detect(x, '\\.'))  x <- paste(x, '.', sep = '')
      while (nchar(x) < n - initspace + 4) x <- paste(x, '0', sep = '')

      # Build invisible leading characters as white-colored hyphens
      initstr <- paste0("<span style='color:white'>", str_c(rep('\\-', initspace), collapse = ''))
      paste(initstr, "</span>", x, sep = '')
    }

    p.cuts.stars   <- c(0.001, 0.01, 0.05, 0.1, 1)
    p.symbols.stars <- c(
      "<span style='font-size:8pt;color:black'>***</span>",
      paste0("<span style='font-size:8pt;color:black'>**</span>",  "<span style='font-size:8pt;color:white'>o</span>"),
      paste0("<span style='font-size:8pt;color:black'>*</span>",   "<span style='font-size:8pt;color:white'>oo</span>"),
      paste0("<span style='font-size:8pt;color:black'><sup>+</sup></span>", "<span style='font-size:8pt;color:white'>oo</span>"),
      paste0("<span style='font-size:8pt;color:black'></span>",    "<span style='font-size:8pt;color:white'>ooo</span>")
    )

    coefsx[coefsx == 0] <- 1e-10
    fdrsx[] <- sapply(fdrsx, starmaker, p.levels = p.cuts.stars, symbols = p.symbols.stars)
    coefsx[] <- sapply(coefsx, transformfch)
    coefsx   <- round(coefsx, 2)

    ss    <- rownames(coefsx)
    maxss <- max(sapply(ss, nchar))
    adspaceText <- function(x, n) {
      paste0(
        x,
        "<span style='font-size:8pt;color:black'>",
        ' ',
        str_c(rep("\\-", (n - nchar(x))), collapse = ''),
        "</span>", "\\:"
      )
    }
    ss <- sapply(ss, adspaceText, maxss + 1)

    maxdigits <- ceiling(log10(max(abs(coefsx))))
    Tab <- data.frame(Symbol = ss)
    for (i in seq_len(ncol(coefsx))) {
      Tab[colnames(coefsx)[i]] <- paste(sapply(coefsx[, i], padding, maxdigits), fdrsx[, i], sep = "")
    }
    rownames(Tab) <- ss
    colnames(Tab) <- c('Symbol', colnames(coefsx))

  } else {
    Tab <- cbind.data.frame(Gene = rownames(matx))
  }

  col_fun   <- colorRamp2(c(-1 * rampvalues, 0, rampvalues), c("blue", 'white', "red"), space = 'sRGB')
  scalename <- 'Z-score'
  if (!scalerows) {
    col_fun   <- colorRamp2(c(min(mat) + 1, mean(mat), max(mat) - 1), c("blue", 'white', "red"), space = 'sRGB')
    scalename <- 'log2-expression'
  }

  row_dend <- as.dendrogram(hclust(dist(mat)))

  ht <- ComplexHeatmap::Heatmap(
    mat,
    name = scalename,
    heatmap_legend_param = list(
      legend_height = unit(2.5, "cm"),
      legend_width  = unit(0.5, "cm"),
      legend_gp     = gpar(fontsize = 8),
      title_gp      = gpar(fontsize = 8, fontface = "bold")
    ),
    column_split      = colsplitx,
    column_title_gp   = gpar(fontsize = fnt_size_title),
    col               = col_fun,
    top_annotation    = column_ha,
    cluster_rows      = TRUE,
    cluster_columns   = FALSE,
    show_row_names    = FALSE,
    show_column_names = ShowColumnNames,
    column_order      = rownames(annot.col),
    use_raster        = TRUE
  )

  ha_names <- rowAnnotation(
    Gene = anno_text(
      gt_render(Tab[, 1], align_widths = TRUE),
      location = 0,
      just = 'left',
      gp = gpar(
        fill       = 'white',
        border     = 'white',
        col        = "black",
        fontface   = 2,
        fontsize   = 8,
        fontfamily = "mono"
      )
    )
  )

  htlist <- ht + ha_names

  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {
      thisha <- rowAnnotation(
        x = anno_text(
          gt_render(
            Tab[, i + 1],
            align_widths = FALSE,
            gp = gpar(box_col = 'white', fontface = 2, fontsize = 8, fontfamily = 'mono')
          ),
          just      = "left",
          show_name = FALSE
        )
      )
      names(thisha) <- paste0('Tab', i)
      htlist <- htlist + thisha
    }
  }

  pdf(file = grafname, width = wdt, height = hgt)

  draw(
    htlist,
    padding          = unit(c(8, 8, 8, 8), "mm"),
    ht_gap           = unit(0.6, "mm"),
    column_title      = setname,
    column_title_side = 'bottom'
  )

  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {
      nm <- paste0('Tab', i)
      decorate_annotation(nm, {
        grid.text(
          gsub('\\.', '\n', substring(colnames(Tab)[i + 1], 7)),
          y    = unit(1, "npc") + unit(2, "mm"),
          x    = unit(0, "npc") + unit(2, "mm"),
          just = "bottom",
          hjust = 0,
          rot  = 0,
          gp   = gpar(
            box_col    = "white",
            box_lwd    = 1,
            fontface   = 2,
            fontsize   = 8,
            fontfamily = 'mono'
          )
        )
      })
    }
  }

  dev.off()
}
