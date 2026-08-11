# pubheat-measure.R ----------------------------------------------------------
# Text measurement: the foundation the publication-heatmap layout stands on.
#
# Every overlap in a heatmap traces back to a guess about how wide some text is.
# These three functions replace the guess with a measurement, and everything in
# [ph_layout()] and the `do*Heatmap()` family is built on them.
# ----------------------------------------------------------------------------

#' Width in inches of the widest label, at a given font
#'
#' @description
#' Measures rendered text rather than estimating it from `nchar()`. This is the
#' primitive behind the publication-heatmap layout engine: gutters, table cell
#' widths and font sizes are all derived from real string metrics, which is what
#' keeps gene names, fold-changes and header labels from colliding.
#'
#' @details
#' `grid` can only resolve string metrics against an open graphics device, so
#' this opens a throwaway null PDF device when none is active and closes it
#' again on exit. Font metrics in inches are device-independent at a given point
#' size, so measuring on the null device and drawing later on the real one is
#' safe. `NA` and empty labels are ignored; an empty input measures `0`.
#'
#' @param labels Character vector (or anything coercible) of labels to measure.
#' @param fontsize Point size to measure at.
#' @param fontface Font face, as understood by [grid::gpar()] (e.g. `"plain"`,
#'   `"bold"`).
#' @param fontfamily Font family, e.g. `""` for the device default or `"mono"`.
#'
#' @return A single numeric: the width in inches of the widest label.
#' @seealso [ph_fit_fontsize()], [ph_layout()]
#' @examples
#' ph_measure_in(c("IL13", "A_VERY_LONG_GENE_SYMBOL"), fontsize = 10)
#' @export
ph_measure_in <- function(labels, fontsize = 10, fontface = "plain", fontfamily = "") {
  labels <- as.character(labels)
  labels <- labels[!is.na(labels) & nzchar(labels)]
  if (!length(labels)) return(0)
  opened <- FALSE
  if (is.null(grDevices::dev.list())) {
    grDevices::pdf(NULL, width = 7, height = 7); opened <- TRUE
  }
  on.exit(if (opened) grDevices::dev.off(), add = TRUE)
  gp <- grid::gpar(fontsize = fontsize, fontface = fontface, fontfamily = fontfamily)
  max(vapply(labels, function(s)
    grid::convertWidth(grid::grobWidth(grid::textGrob(s, gp = gp)), "in", valueOnly = TRUE),
    numeric(1)))
}

#' Largest font size at which every label still fits a given width
#'
#' @description
#' Returns the point size at which the widest of `labels` exactly fills
#' `avail_in` inches, clamped to a legibility band. Used wherever a label has to
#' be fitted into a space whose size is already fixed -- split titles, contrast
#' sub-labels, boxed group bands.
#'
#' @details
#' Text width is linear in point size, so one measurement at a 10pt reference
#' lands on the answer in closed form (`10 * avail_in / w10`) without a search.
#'
#' That estimate is then verified, because graphics devices *quantise* the point
#' size they actually render: a request for 8.86pt is drawn at 9pt, which is up
#' to ~2% wider than the linear model predicts and enough to push a "just fits"
#' label over the edge. So the estimate is measured and stepped down in half
#' points until it genuinely fits. The walk is short (the estimate is already
#' close) and bounded by `min_fontsize`.
#'
#' The clamp matters as much as the arithmetic: `min_fontsize` is a floor below
#' which print is illegible, and it is deliberately allowed to win over fitting,
#' on the principle that a figure nobody can read has failed regardless of how
#' neatly it fits. When the floor wins the labels may overflow -- that is the
#' intended trade, and the caller decides what to do about it.
#'
#' @param labels Labels that must fit.
#' @param avail_in Available width in inches.
#' @param max_fontsize Upper bound on the returned size.
#' @param min_fontsize Lower bound; returned even if the labels then overflow.
#' @param fontface,fontfamily Font, as in [ph_measure_in()].
#'
#' @return A single numeric point size in `[min_fontsize, max_fontsize]`.
#' @seealso [ph_measure_in()]
#' @examples
#' ph_fit_fontsize(c("W2vsBL", "W16vsBL"), avail_in = 0.6)
#' @export
ph_fit_fontsize <- function(labels, avail_in, max_fontsize = 12, min_fontsize = 5,
                            fontface = "plain", fontfamily = "") {
  w <- ph_measure_in(labels, 10, fontface, fontfamily)
  if (w <= 0) return(max_fontsize)
  fs <- .ph_clamp(10 * avail_in / w, min_fontsize, max_fontsize)
  # Correct for device font-size quantisation (see Details): step down until the
  # rendered width really fits, or until the legibility floor stops us.
  while (fs > min_fontsize &&
         ph_measure_in(labels, fs, fontface, fontfamily) > avail_in)
    fs <- max(fs - 0.5, min_fontsize)
  fs
}

#' Black or white text, whichever stays readable on a given fill
#'
#' @description
#' Picks a text colour per fill colour using WCAG relative luminance. This
#' matters because callers choose their own annotation-box colours: a dark
#' custom fill with fixed black text would be unreadable, and silently so.
#'
#' @param fill Character vector of colours (names, hex, or anything
#'   [grDevices::col2rgb()] accepts). `NA` yields `"black"`.
#'
#' @return Character vector the same length as `fill`, each `"black"` or
#'   `"white"`.
#' @seealso [ph_block()], [ph_box_row()], [ph_palette()]
#' @examples
#' ph_contrast_col(c("#D4645A", "#F2D680", "white"))
#' @export
ph_contrast_col <- function(fill) {
  vapply(fill, function(f) {
    if (is.na(f)) return("black")
    v <- grDevices::col2rgb(f)[, 1] / 255
    lin <- ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    L <- sum(c(0.2126, 0.7152, 0.0722) * lin)
    if (L > 0.45) "black" else "white"
  }, character(1), USE.NAMES = FALSE)
}
