# pubheat-internals.R --------------------------------------------------------
# Shared, unexported machinery for the publication heatmap family
# (doPatientHeatmap / doGroupMeanHeatmap / doAnnotatedGridHeatmap).
#
# Everything here is named with a leading dot so the package's
# exportPattern("^[[:alpha:]]+") keeps it out of the public API.
# ----------------------------------------------------------------------------

#' Clamp a scalar into a range
#' @noRd
.ph_clamp <- function(x, lo, hi) max(lo, min(hi, x))

#' NULL-coalescing default. Not exported (the name is not alphabetic).
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a

#' Fail early and by name when a drawing dependency is absent
#' @noRd
.ph_require <- function() {
  need <- c("ComplexHeatmap", "circlize", "grid", "grDevices")
  miss <- need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss))
    stop("these packages are needed for publication heatmaps: ",
         paste(miss, collapse = ", "), call. = FALSE)
  invisible(TRUE)
}

#' Mix a colour toward white -- a lighter tint of the same hue
#'
#' Used to derive contrast-box fills from their group band, so a sub-label reads
#' as belonging to the band above it without competing with it for attention.
#' @noRd
.ph_tint <- function(col, amount = 0.45) {
  m <- grDevices::col2rgb(col) / 255
  m <- m + (1 - m) * amount
  grDevices::rgb(m[1, ], m[2, ], m[3, ])
}

#' Largest split-title font that the narrowest slice can hold
#' @noRd
.ph_split_title_fontsize <- function(colsplitx, col_in, cap = 20) {
  if (is.null(colsplitx)) return(cap)
  lv <- if (is.factor(colsplitx)) levels(droplevels(colsplitx)) else unique(as.character(colsplitx))
  narrowest <- min(table(as.character(colsplitx))) * col_in
  ph_fit_fontsize(lv, narrowest * 0.88, max_fontsize = cap, min_fontsize = 8, fontface = "bold")
}

#' Is the split variable already spelled out by one of the header boxes?
#'
#' Printing "Rash" as a slice title AND inside a block box says the same thing
#' twice, and the duplicate forces the title font down to whatever the narrowest
#' slice allows. When they match, drop the title and keep the box.
#' @noRd
.ph_split_is_redundant <- function(colsplitx, annot.col, blocks) {
  if (is.null(colsplitx) || !length(blocks)) return(FALSE)
  s <- as.character(colsplitx)
  any(vapply(blocks, function(b)
    !is.null(annot.col[[b]]) && identical(as.character(annot.col[[b]]), s),
    logical(1)))
}

#' Size the page by drawing it and asking how big it came out
#'
#' Every component (annotation stack, rotated sub-labels, split titles, bottom
#' caption, legends) contributes height and width that no closed-form estimate
#' gets right for every input -- and being wrong here means a clipped figure.
#' So draw once on a throwaway oversized device, measure the result, then draw
#' for real at exactly that size.
#'
#' ComplexHeatmap does not export a way to ask a drawn HeatmapList its size, so
#' this reaches for the unexported `width()`/`height()` via `getFromNamespace()`.
#' That is a deliberate, load-bearing coupling and the only one in the package:
#' the alternative is a closed-form estimate that clips figures. It is resolved
#' lazily and wrapped in `try()`, so if a future ComplexHeatmap drops or renames
#' those functions the layout falls back to the analytic estimate rather than
#' erroring -- the symptom would be slightly roomier or tighter pages, not a
#' broken package. `getFromNamespace()` rather than `:::` keeps `R CMD check`
#' quiet; the coupling is identical either way.
#' @noRd
.ph_autofit <- function(ht_list, draw_args, fallback, pad_in = 0.10) {
  out <- try({
    ch_width  <- utils::getFromNamespace("width",  "ComplexHeatmap")
    ch_height <- utils::getFromNamespace("height", "ComplexHeatmap")
    grDevices::pdf(NULL, width = 200, height = 200)
    on.exit(grDevices::dev.off(), add = TRUE)
    d <- do.call(ComplexHeatmap::draw, c(list(ht_list), draw_args))
    c(grid::convertWidth(ch_width(d),   "in", valueOnly = TRUE) + pad_in,
      grid::convertHeight(ch_height(d), "in", valueOnly = TRUE) + pad_in)
  }, silent = TRUE)
  if (inherits(out, "try-error") || !all(is.finite(out)) || any(out < 1)) fallback else out
}

#' The shared expression-body Heatmap, built once for all three entry points
#' @noRd
.ph_body <- function(mat, annot.col, colsplitx, zcol, lay, top_annotation, bottom_annotation,
                     cluster_rows, cluster_columns, show_row_names, split_gap_mm,
                     border_lwd, split_title_fontsize, legend_title, row_names_side,
                     zlim = 1.5, na_col = "grey90") {
  ComplexHeatmap::Heatmap(
    mat, name = legend_title, col = zcol,
    column_split = colsplitx,
    width  = grid::unit(lay$body_w, "in"),
    height = grid::unit(lay$body_h, "in"),
    column_gap = grid::unit(split_gap_mm, "mm"),
    border = TRUE, border_gp = grid::gpar(col = "black", lwd = border_lwd),
    # A space, not "". ComplexHeatmap reads a length-1 empty title as "none
    # given" and falls back to printing the split level, so `rep("", 1)` puts
    # the group name back exactly where it was being suppressed.
    column_title = if (isTRUE(attr(split_title_fontsize, "suppress")))
                     rep(" ", length(unique(as.character(colsplitx)))) else NULL,
    column_title_gp = grid::gpar(fontsize = as.numeric(split_title_fontsize), fontface = "bold"),
    top_annotation = top_annotation, bottom_annotation = bottom_annotation,
    cluster_rows = cluster_rows, cluster_columns = cluster_columns,
    show_row_names = show_row_names, show_column_names = FALSE,
    row_names_side = row_names_side,
    row_names_gp = grid::gpar(fontsize = lay$row_fontsize),
    # ComplexHeatmap caps the row-name gutter at 6cm by default and truncates
    # anything longer -- silently, and only visible once you look at the PDF.
    # `gutter_in` is the measured width of the longest name, so use that.
    row_names_max_width = grid::unit(max(lay$gutter_in, 0.1), "in"),
    row_dend_width = grid::unit(if (isTRUE(cluster_rows)) 6 else 0, "mm"),
    column_order = if (isTRUE(cluster_columns)) NULL else colnames(mat),
    use_raster = (nrow(mat) * ncol(mat) > 40000), na_col = na_col,
    heatmap_legend_param = list(
      # Tie the ticks to the ramp. ComplexHeatmap otherwise labels round numbers
      # beyond the saturation point, implying a range the colours never reach.
      at = c(-zlim, -zlim / 2, 0, zlim / 2, zlim),
      title_gp = grid::gpar(fontsize = 10, fontface = "bold"),
      labels_gp = grid::gpar(fontsize = 9),
      grid_width = grid::unit(4.5, "mm")))
}
