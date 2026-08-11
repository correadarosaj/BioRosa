#' Group-mean heatmap, one column per group with sample counts underneath
#'
#' @description
#' The summary counterpart to [doPatientHeatmap()]. Give it the sample-level
#' matrix and a grouping vector; it computes the means, labels each column with
#' boxed headers, and prints the n beneath -- because a mean column is not
#' interpretable without its n.
#'
#' @details
#' Same layout engine as [doPatientHeatmap()], with defaults suited to a handful
#' of wide columns rather than many narrow ones.
#'
#' Compound group levels are unpacked automatically: `"Rash.LS"` becomes a
#' two-row boxed header (Rash over LS) rather than one cramped label, which is
#' how a crossed design should read. Name the layers with `group_names` and
#' change the separator with `sep`.
#'
#' @param grafname Output PDF path.
#' @param mat Feature x sample matrix of raw values. If `groups` is `NULL`,
#'   `mat` is taken to be already summarised, one column per group.
#' @param groups Group membership, one entry per column of `mat`.
#' @param annot.col Optional per-column annotation. By default it is derived by
#'   splitting the group level names on `sep`.
#' @param group_levels Optional level order for the mean columns.
#' @param group_names Names for the parts of a compound level, outermost first.
#' @param sep Separator splitting compound levels.
#' @param colsplitx Optional vector splitting the body into labelled slices.
#' @param blocks Columns of `annot.col` drawn as boxed headers. Defaults to all
#'   of them, since an unlabelled mean heatmap is unreadable.
#' @param block_colors Named list: block column -> named colour vector.
#' @param show_n Print per-group sample counts beneath the columns.
#' @param bottom_labels Overrides the counts with arbitrary labels.
#' @param setname Caption drawn beneath the figure.
#' @param zlim,zcol Colour saturation point and optional ramp override.
#' @param show_row_names Show feature names.
#' @param cluster_rows Cluster the rows.
#' @param row_in,col_in,row_fontsize Cell geometry and font; `NULL` auto-derives.
#' @param block_height_mm,block_fontsize Geometry of the boxed headers.
#' @param wdt,hgt Optional page overrides in inches; normally unnecessary.
#' @param density Scale factor for the whole figure.
#' @param split_gap_mm,border_lwd,split_title_fontsize Slice gap, border width
#'   and slice-title size, as in [doPatientHeatmap()].
#' @param legend_title Title of the expression colour legend.
#' @param verbose Report the resolved page size and any dropped features.
#'
#' @return Invisibly, the resolved layout plus page size and shape. Called for
#'   the side effect of writing `grafname`.
#' @seealso [doPatientHeatmap()], [ph_group_means()]
#' @examples
#' \dontrun{
#' doGroupMeanHeatmap(
#'   grafname = "mean_immune.pdf",
#'   mat      = expr[genes, rownames(annotx)],
#'   groups   = droplevels(interaction(annotx$Grp, annotx$Tissue, sep = ".")),
#'   group_names = c("Group", "Tissue"),
#'   setname  = "Immune genes - group means")
#' }
#' @export
doGroupMeanHeatmap <- function(
    grafname, mat, groups = NULL, annot.col = NULL, group_levels = NULL,
    group_names = NULL, sep = ".",
    colsplitx = NULL, blocks = NULL, block_colors = list(),
    show_n = TRUE, bottom_labels = NULL,
    setname = "", zlim = 1.5, zcol = NULL,
    show_row_names = TRUE, cluster_rows = TRUE,
    row_in = NULL, col_in = NULL, row_fontsize = NULL,
    block_height_mm = 9, block_fontsize = 14,
    wdt = NULL, hgt = NULL, density = 1,
    split_gap_mm = 3, border_lwd = 1.2, split_title_fontsize = NULL,
    legend_title = "Z-score", verbose = TRUE) {

  .ph_require()
  mat <- as.matrix(mat)
  if (!is.null(groups)) {
    mm <- ph_group_means(mat, groups, group_levels)
    n  <- attr(mm, "n")
  } else {
    mm <- mat; n <- NULL
  }
  if (is.null(annot.col)) {
    parts <- strsplit(colnames(mm), sep, fixed = TRUE)
    k <- unique(lengths(parts))
    if (length(k) == 1 && k > 1) {
      annot.col <- as.data.frame(do.call(rbind, parts), stringsAsFactors = FALSE)
      names(annot.col) <- group_names %||% paste0("Level", seq_len(k))
    } else {
      annot.col <- data.frame(Group = colnames(mm), stringsAsFactors = FALSE)
    }
    rownames(annot.col) <- colnames(mm)
  }
  annot.col <- as.data.frame(annot.col)[colnames(mm), , drop = FALSE]
  # A mean heatmap whose columns are unlabelled is unreadable, so header boxes
  # are the default here rather than something the caller has to remember.
  if (is.null(blocks)) blocks <- names(annot.col)
  if (is.null(bottom_labels) && show_n && !is.null(n)) bottom_labels <- paste0("n=", n)

  doPatientHeatmap(
    grafname = grafname, mat = mm, annot.col = annot.col, colsplitx = colsplitx,
    blocks = blocks, block_colors = block_colors,
    bottom_labels = bottom_labels, setname = setname, zlim = zlim, zcol = zcol,
    show_row_names = show_row_names, cluster_rows = cluster_rows, cluster_columns = FALSE,
    row_in = row_in, col_in = col_in %||% .ph_clamp(5.5 / ncol(mm), 0.35, 0.95),
    row_fontsize = row_fontsize,
    block_height_mm = block_height_mm, block_fontsize = block_fontsize,
    wdt = wdt, hgt = hgt, density = density,
    split_gap_mm = split_gap_mm, border_lwd = border_lwd,
    split_title_fontsize = split_title_fontsize,
    legend_title = legend_title, verbose = verbose)
}
