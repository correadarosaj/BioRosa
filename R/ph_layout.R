#' Resolve heatmap cell sizes, fonts and canvas from the content
#'
#' @description
#' The layout engine behind [doPatientHeatmap()], [doGroupMeanHeatmap()] and
#' [doAnnotatedGridHeatmap()]. Given the shape of a figure and the labels it has
#' to carry, it returns the cell sizes, font sizes and page dimensions that let
#' everything fit. Exported so a caller composing a bespoke `ComplexHeatmap`
#' figure can reuse the same sizing rules.
#'
#' @details
#' The invariants, applied in priority order (later rules never break earlier
#' ones):
#'
#' 1. **A row is at least 1.22x its font's height**, so row labels cannot touch.
#'    The font is derived *from* the row height, not chosen independently; if
#'    the legibility floor raises the font, the row grows to match rather than
#'    the text being squeezed.
#' 2. **A column is at least as wide as its bottom label needs.** Labels rotate
#'    to vertical when horizontal does not fit, at which point the binding
#'    constraint becomes glyph height instead of length.
#' 3. **The row-label gutter is the measured width of the longest label**, via
#'    [ph_measure_in()] -- not `max(nchar())` times a fudge factor.
#' 4. **The legend gutter is the measured width of the widest legend string.**
#'
#' Only after all four is the page size computed, so the page fits the figure
#' rather than the figure being squeezed into a guessed page.
#'
#' @param n_rows,n_cols Shape of the heatmap body.
#' @param row_labels Row labels that must fit in the gutter, or `NULL` if none
#'   are shown.
#' @param bottom_labels Labels printed under the columns, or `NULL`.
#' @param legend_labels Strings appearing in the legend column, used to reserve
#'   its width.
#' @param row_in,col_in Cell height and width in inches. `NULL` derives them
#'   from the figure's shape.
#' @param row_fontsize,bottom_fontsize Point sizes. `NULL` derives them from the
#'   resolved cell geometry.
#' @param top_anno_in Height in inches already committed to the top annotation.
#' @param title_in Height in inches reserved for the caption.
#' @param density Scale factor applied to the derived cell sizes; below 1
#'   tightens the figure, above 1 loosens it.
#' @param row_font_max,row_font_min Legibility band for the row-label font.
#' @param col_span_in,row_span_in Nominal inches of body the defaults spread
#'   over before clamping.
#' @param row_min_in Floor on row height. Callers that print text *inside* each
#'   row -- the fold-change table -- raise this so the numbers get clearance.
#'
#' @return A list with `row_in`, `col_in`, `row_fontsize`, `bottom_fontsize`,
#'   `bottom_rot`, `body_w`, `body_h`, `gutter_in`, `legend_in`, `width` and
#'   `height` (the last two in inches).
#' @seealso [ph_measure_in()], [doPatientHeatmap()]
#' @examples
#' ph_layout(n_rows = 40, n_cols = 20, row_labels = c("IL13", "CXCL9"))[
#'   c("row_in", "col_in", "row_fontsize", "width", "height")]
#' @export
ph_layout <- function(n_rows, n_cols,
                      row_labels = NULL, bottom_labels = NULL,
                      legend_labels = c("Z-score", "-1.5", "1.5"),
                      row_in = NULL, col_in = NULL,
                      row_fontsize = NULL, bottom_fontsize = NULL,
                      top_anno_in = 0, title_in = 0.5, density = 1,
                      row_font_max = 12, row_font_min = 5,
                      col_span_in = 11, row_span_in = 9, row_min_in = 0) {

  if (is.null(row_in))       row_in <- .ph_clamp(row_span_in / max(n_rows, 1), 0.075, 0.26) * density
  # A caller that prints text INSIDE each row (the fold-change table) needs the
  # row tall enough for that text too, so it can raise the floor here rather
  # than discover the collision after drawing.
  row_in <- max(row_in, row_min_in)
  if (is.null(row_fontsize)) row_fontsize <- .ph_clamp(row_in * 72 / 1.22, row_font_min, row_font_max)
  row_in <- max(row_in, row_fontsize * 1.22 / 72)          # no vertical collisions

  if (is.null(col_in)) col_in <- .ph_clamp(col_span_in / max(n_cols, 1), 0.13, 0.60) * density

  bottom_in <- 0; bottom_rot <- NA_integer_
  if (!is.null(bottom_labels)) {
    bf <- bottom_fontsize %||% .ph_clamp(col_in * 72 / 1.30, 5, 11)
    bw <- ph_measure_in(bottom_labels, bf)
    if (bw <= col_in * 0.86) { bottom_rot <- 0; bottom_in <- bf * 1.45 / 72 }
    else {
      bottom_rot <- 90
      col_in <- max(col_in, bf * 1.30 / 72)                # room for rotated glyph height
      bottom_in <- ph_measure_in(bottom_labels, bf) + 0.08
    }
    bottom_fontsize <- bf
  }

  gutter_in <- if (is.null(row_labels)) 0.05 else ph_measure_in(row_labels, row_fontsize) + 0.12
  legend_in <- ph_measure_in(legend_labels, 9) + 0.70

  list(row_in = row_in, col_in = col_in,
       row_fontsize = row_fontsize,
       bottom_fontsize = bottom_fontsize, bottom_rot = bottom_rot,
       body_w = n_cols * col_in, body_h = n_rows * row_in,
       gutter_in = gutter_in, legend_in = legend_in,
       width  = n_cols * col_in + gutter_in + legend_in + 0.55,
       height = n_rows * row_in + top_anno_in + bottom_in + title_in + 0.75)
}

# ---------------------------------------------------------------------------
# 5. The three heatmaps
# ---------------------------------------------------------------------------
