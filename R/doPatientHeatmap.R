#' Per-patient publication heatmap, one column per sample
#'
#' @description
#' The workhorse for "show me every patient": a row-Z-scored expression body
#' with boxed, colour-filled group headers and an optional continuous clinical
#' score (EASI, SCORAD, PASI, ...) drawn immediately above the expression.
#'
#' Sizes are derived from the content -- see [ph_layout()] -- so `wdt`/`hgt` are
#' not normally needed and the figure will not clip, overlap or waste
#' whitespace as the gene set changes size.
#'
#' @details
#' **Column order is yours.** Columns follow `rownames(annot.col)` and nothing
#' reorders them; the sort *is* the argument the figure makes. The lab
#' convention is group, then tissue, then descending clinical score:
#'
#' ```
#' annotx <- annotx[order(annotx$Grp, annotx$Tissue, -annotx$EASI), ]
#' ```
#'
#' **Redundant titles are dropped.** If `colsplitx` names the same variable as
#' one of `blocks`, the slice title is suppressed and the box keeps the label --
#' otherwise the name is printed twice, and the title font gets squeezed to
#' whatever the narrowest slice allows. Pass `split_title_fontsize` to force it
#' back.
#'
#' **Missing scores read as missing**, drawn white, distinct from a scored zero
#' (see [ph_easi_ramp()]).
#'
#' @param grafname Output PDF path.
#' @param mat Feature x sample matrix of raw values; row Z-scoring happens here
#'   via [ph_zscore()], which also drops zero-variance features.
#' @param annot.col Data frame of per-sample annotation whose row names define
#'   the column order.
#' @param colsplitx Optional vector splitting the body into labelled slices.
#' @param blocks Character vector of `annot.col` columns drawn as boxed grid
#'   headers.
#' @param block_colors Named list: block column -> named colour vector. This is
#'   the customisable-colour hook; label colours auto-contrast on the fill.
#' @param categorical,categorical_colors Columns drawn as simple colour strips
#'   (with legends), and their colours.
#' @param easi Name of a numeric column in `annot.col` to draw as a continuous
#'   greyscale severity track, or `NULL`. Any severity instrument works.
#' @param easi_max Top of the ramp; defaults to the observed maximum.
#' @param easi_show_values Also print the numeric values under the track.
#' @param numeric,numeric_colors Additional numeric tracks and their
#'   `circlize::colorRamp2()` mappings.
#' @param top_annotation Optional pre-built `HeatmapAnnotation`, bypassing the
#'   `blocks`/`easi` arguments entirely.
#' @param bottom_labels Vector printed under the columns, e.g. subject IDs.
#'   Rotates automatically when the columns are too narrow.
#' @param setname Caption drawn beneath the figure.
#' @param zlim Colour saturation point for the Z-scores; the legend ticks follow
#'   it.
#' @param zcol Optional `circlize::colorRamp2()` overriding the blue-white-red
#'   default.
#' @param show_row_names Show feature names in the right-hand gutter.
#' @param cluster_rows,cluster_columns Cluster rows / columns. Column clustering
#'   overrides the `annot.col` order, so it is off by default.
#' @param row_in,col_in Cell height and width in inches; `NULL` auto-derives.
#' @param row_fontsize,bottom_fontsize Point sizes; `NULL` auto-derives from the
#'   resolved cell geometry.
#' @param block_height_mm,block_fontsize Geometry of the boxed headers.
#' @param track_height_mm Height of each continuous or categorical strip.
#' @param wdt,hgt Optional page overrides in inches. Last resort: setting these
#'   defeats the auto-fit, so anything that no longer fits is clipped silently.
#' @param density Scale factor for the whole figure; below 1 tightens, above 1
#'   loosens.
#' @param split_gap_mm Gap between body slices.
#' @param border_lwd Line width of the body and box borders.
#' @param split_title_fontsize Point size for slice titles; `NULL` auto-sizes
#'   and applies the redundancy rule above.
#' @param legend_title Title of the expression colour legend.
#' @param verbose Report the resolved page size and any dropped features.
#'
#' @return Invisibly, the resolved layout (see [ph_layout()]) plus `width`,
#'   `height`, `n_rows` and `n_cols`. Called for the side effect of writing
#'   `grafname`.
#' @seealso [doGroupMeanHeatmap()], [doAnnotatedGridHeatmap()], [ph_layout()]
#' @examples
#' \dontrun{
#' doPatientHeatmap(
#'   grafname  = "patient_immune.pdf",
#'   mat       = expr[genes, rownames(annotx)],
#'   annot.col = annotx,
#'   colsplitx = annotx$Grp,
#'   blocks       = c("Grp", "Tissue"),
#'   block_colors = list(Grp = c(Control = "#B9C6D6", Rash = "#D4645A")),
#'   easi = "EASI", bottom_labels = annotx$SubjectID,
#'   setname = "Immune genes")
#' }
#' @export
doPatientHeatmap <- function(
    grafname, mat, annot.col, colsplitx = NULL,
    blocks = NULL, block_colors = list(),
    categorical = NULL, categorical_colors = list(),
    easi = NULL, easi_max = NULL, easi_show_values = FALSE,
    numeric = NULL, numeric_colors = list(),
    top_annotation = NULL, bottom_labels = NULL,
    setname = "", zlim = 1.5, zcol = NULL,
    show_row_names = TRUE, cluster_rows = TRUE, cluster_columns = FALSE,
    row_in = NULL, col_in = NULL, row_fontsize = NULL, bottom_fontsize = NULL,
    block_height_mm = 8, block_fontsize = 13, track_height_mm = 5.5,
    wdt = NULL, hgt = NULL, density = 1,
    split_gap_mm = 3, border_lwd = 1.2, split_title_fontsize = NULL,
    legend_title = "Z-score", verbose = TRUE) {

  .ph_require()
  annot.col <- as.data.frame(annot.col)
  if (is.null(rownames(annot.col))) stop("`annot.col` needs row names = sample order.")
  mat <- as.matrix(mat)
  miss <- setdiff(rownames(annot.col), colnames(mat))
  if (length(miss)) stop("samples missing from `mat`: ", paste(utils::head(miss, 5), collapse = ", "))
  mat <- mat[, rownames(annot.col), drop = FALSE]
  z <- ph_zscore(mat, verbose)

  if (!is.null(easi)) {
    numeric <- unique(c(numeric, easi))
    numeric_colors[[easi]] <- numeric_colors[[easi]] %||%
      ph_easi_ramp(easi_max %||% max(suppressWarnings(as.numeric(annot.col[[easi]])), na.rm = TRUE))
  }

  n_tracks <- length(categorical) + length(numeric)
  top_in <- if (!is.null(top_annotation)) 0.75
            else (length(blocks) * block_height_mm + n_tracks * track_height_mm +
                  (length(blocks) + n_tracks) * 1.2) / 25.4 +
                 (if (easi_show_values) 0.42 else 0)

  lay <- ph_layout(nrow(z), ncol(z),
                   row_labels = if (show_row_names) rownames(z) else NULL,
                   bottom_labels = bottom_labels,
                   legend_labels = c(legend_title, format(c(-zlim, zlim)), easi %||% "", "0"),
                   row_in = row_in, col_in = col_in, row_fontsize = row_fontsize,
                   bottom_fontsize = bottom_fontsize,
                   top_anno_in = top_in,
                   title_in = if (nzchar(setname)) 0.5 else 0.25,
                   density = density)

  if (is.null(top_annotation))
    top_annotation <- ph_top_annotation(
      annot.col, blocks = blocks, block_colors = block_colors,
      categorical = categorical, categorical_colors = categorical_colors,
      numeric = numeric, numeric_colors = numeric_colors,
      block_height_mm = block_height_mm, block_fontsize = block_fontsize,
      track_height_mm = track_height_mm,
      numeric_show_values = easi_show_values, col_in = lay$col_in)

  bottom_annotation <- NULL
  if (!is.null(bottom_labels))
    bottom_annotation <- ComplexHeatmap::HeatmapAnnotation(
      lab = ph_anno_fit_text(bottom_labels, col_in = lay$col_in,
                             max_fontsize = lay$bottom_fontsize),
      show_annotation_name = FALSE, which = "column")

  zcol <- zcol %||% circlize::colorRamp2(c(-zlim, 0, zlim), c("blue", "white", "red"))
  stf  <- split_title_fontsize %||% .ph_split_title_fontsize(colsplitx, lay$col_in)
  if (is.null(split_title_fontsize) && .ph_split_is_redundant(colsplitx, annot.col, blocks))
    attr(stf, "suppress") <- TRUE

  ht <- .ph_body(z, annot.col, colsplitx, zcol, lay, top_annotation, bottom_annotation,
                 cluster_rows, cluster_columns, show_row_names, split_gap_mm,
                 border_lwd, stf, legend_title, "right", zlim)

  draw_args <- list(padding = grid::unit(c(4, 4, 4, 4), "mm"),
                    column_title = setname, column_title_side = "bottom",
                    column_title_gp = grid::gpar(fontsize = 12),
                    merge_legends = TRUE, heatmap_legend_side = "right")
  fit <- .ph_autofit(ht, draw_args, c(lay$width, lay$height))
  W <- wdt %||% fit[1]; H <- hgt %||% fit[2]

  grDevices::pdf(grafname, width = W, height = H)
  on.exit(grDevices::dev.off(), add = TRUE)
  do.call(ComplexHeatmap::draw, c(list(ht), draw_args))
  if (verbose) message(sprintf("pubheat: %s  [%dx%d, %.1f x %.1f in]",
                               basename(grafname), nrow(z), ncol(z), W, H))
  invisible(c(lay, list(width = W, height = H, n_rows = nrow(z), n_cols = ncol(z))))
}
