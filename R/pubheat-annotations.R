# pubheat-annotations.R ------------------------------------------------------
# Boxed, colour-filled top annotations and the continuous clinical-score track.
# ----------------------------------------------------------------------------

#' Boxed, colour-filled group band annotation
#'
#' @description
#' One bordered, filled rectangle per contiguous run of `x`, with the level name
#' centred inside. This is the header style used across the publication
#' heatmaps: the box carries the label, so no separate slice title is needed.
#'
#' @details
#' The label font is resolved *inside* the panel, at draw time, where the true
#' box geometry is finally known. It shrinks to fit, and rotates 90 degrees when
#' rotation buys more than 25% -- which is why a two-column `LS` block and a
#' twenty-column `Control` block are both legible in the same figure. A label
#' therefore cannot spill out of its box however narrow the group turns out to
#' be. Text colour follows [ph_contrast_col()] so a dark custom fill stays
#' readable.
#'
#' Runs come from [ph_leveler()], so nested designs (Tissue inside Group) box
#' correctly; sort the annotation by its block variables first.
#'
#' @param x Grouping vector, in column order.
#' @param fill Named colour vector (level -> fill). Levels not named here fall
#'   back to [ph_palette()]. This is the customisable-colour hook.
#' @param height_mm Band height in millimetres.
#' @param fontsize Maximum label size in points; the drawn size is at most this.
#' @param border_col,border_lwd Colour and line width of the box borders.
#' @param text_col Optional named colour vector overriding the automatic
#'   black/white choice for specific levels.
#' @param fontface Font face for the labels.
#' @param pad Fraction of the box the label may occupy, leaving a margin.
#'
#' @return A `ComplexHeatmap` annotation function, to be passed inside
#'   [ComplexHeatmap::HeatmapAnnotation()] (or via the `blocks` argument of
#'   [doPatientHeatmap()]).
#' @seealso [ph_box_row()] for one box per column, [ph_top_annotation()]
#' @examples
#' \dontrun{
#' ComplexHeatmap::HeatmapAnnotation(
#'   Grp = ph_block(annot$Grp, fill = c(Control = "#B9C6D6", Rash = "#D4645A")))
#' }
#' @export
ph_block <- function(x, fill = NULL, height_mm = 8, fontsize = 13,
                     border_col = "black", border_lwd = 1.2,
                     text_col = NULL, fontface = "bold", pad = 0.92) {
  .ph_require()
  xs <- as.character(x)
  lv <- ph_leveler(xs)
  cols <- ph_palette(unique(xs), fill)
  tcol <- if (is.null(text_col)) stats::setNames(ph_contrast_col(cols), names(cols))
          else { t <- stats::setNames(ph_contrast_col(cols), names(cols))
                 t[intersect(names(text_col), names(t))] <- text_col[intersect(names(text_col), names(t))]; t }

  ComplexHeatmap::anno_block(
    align_to = lv,
    panel_fun = function(index, ...) {
      # Derive the level from the data rather than trusting the second argument,
      # which differs between align_to= and column_split= call paths.
      nm <- xs[index[1]]
      grid::grid.rect(gp = grid::gpar(fill = unname(cols[nm]), col = border_col, lwd = border_lwd))
      aw <- grid::convertWidth(grid::unit(pad, "npc"), "in", valueOnly = TRUE)
      ah <- grid::convertHeight(grid::unit(pad, "npc"), "in", valueOnly = TRUE)
      g  <- grid::textGrob(nm, gp = grid::gpar(fontsize = fontsize, fontface = fontface))
      tw <- max(grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE), 1e-6)
      th <- max(grid::convertHeight(grid::grobHeight(g), "in", valueOnly = TRUE), 1e-6)
      fs_h <- fontsize * min(1, aw / tw, ah / th)   # horizontal
      fs_v <- fontsize * min(1, ah / tw, aw / th)   # rotated 90
      if (fs_v > fs_h * 1.25) { rot <- 90; fs <- fs_v } else { rot <- 0; fs <- fs_h }
      grid::grid.text(nm, rot = rot,
                      gp = grid::gpar(fontsize = max(fs, 3.5), fontface = fontface,
                                      col = unname(tcol[nm])))
    },
    height = grid::unit(height_mm, "mm"))
}

#' One bordered, filled box per column, label fitted inside
#'
#' `ph_block()` draws one box per contiguous *run*; this draws one per *column*.
#' That is what a contrast header needs: each fold-change column gets its own
#' cell in the header grid, nested under its group band, so the header reads as
#' a table rather than as text floating above one.
#'
#' Height is derived from the labels: if they fit across the column they are
#' drawn horizontally in a shallow band, otherwise the band grows to the label's
#' length and they rotate. Either way the font is refined at draw time against
#' the real box, so a label cannot spill out of its cell.
#'
#' @param labels One label per column.
#' @param col_in Column width in inches -- decides horizontal vs rotated.
#' @param fill Fill colour(s): one value, or one per column. Recycled by index.
#' @param fontsize Maximum label size in points; the drawn size is at most this.
#' @param border_col,border_lwd Colour and line width of the cell borders.
#' @param text_col Optional colour(s) overriding the automatic black/white
#'   choice from [ph_contrast_col()].
#' @param fontface Font face for the labels.
#' @param pad Fraction of the cell the label may occupy.
#' @param height_mm Optional fixed band height; by default it is derived from
#'   the labels and the rotation decision.
#'
#' @return A `ComplexHeatmap::AnnotationFunction` for use as a column
#'   annotation.
#' @seealso [ph_block()] for one box per group run,
#'   [doAnnotatedGridHeatmap()] which uses this for its contrast header.
#' @examples
#' \dontrun{
#' ComplexHeatmap::HeatmapAnnotation(
#'   Contrast = ph_box_row(c("W4vsBL", "W16vsBL"), col_in = 0.7,
#'                         fill = c("#F6C9C0", "#CDE0F0")))
#' }
#' @export
ph_box_row <- function(labels, col_in, fill = NULL, fontsize = 10,
                       border_col = "black", border_lwd = 1.0,
                       text_col = NULL, fontface = "bold", pad = 0.90,
                       height_mm = NULL) {
  .ph_require()
  labels <- as.character(labels)
  n <- length(labels)
  fills <- if (is.null(fill)) rep("white", n) else rep_len(unname(fill), n)
  tcols <- if (is.null(text_col)) ph_contrast_col(fills) else rep_len(text_col, n)

  w_h <- ph_measure_in(labels, fontsize, fontface)
  rot <- if (w_h <= col_in * pad) 0 else 90
  height_in <- if (!is.null(height_mm)) height_mm / 25.4
               else if (rot == 0) max(fontsize * 1.9 / 72, 0.22) else w_h + 0.12

  ComplexHeatmap::AnnotationFunction(
    fun = function(index, k, n2) {
      ni <- length(index)
      lab <- labels[index]; fl <- fills[index]; tc <- tcols[index]
      cw <- grid::convertWidth(grid::unit(1 / ni, "npc"), "in", valueOnly = TRUE)
      ch <- grid::convertHeight(grid::unit(1, "npc"), "in", valueOnly = TRUE)
      for (i in seq_along(lab)) {
        x <- (i - 0.5) / ni
        grid::grid.rect(x = x, width = grid::unit(1 / ni, "npc"),
                        gp = grid::gpar(fill = fl[i], col = border_col, lwd = border_lwd))
        g  <- grid::textGrob(lab[i], gp = grid::gpar(fontsize = fontsize, fontface = fontface))
        tw <- max(grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE), 1e-6)
        th <- max(grid::convertHeight(grid::grobHeight(g), "in", valueOnly = TRUE), 1e-6)
        aw <- cw * pad; ah <- ch * pad
        fs_h <- fontsize * min(1, aw / tw, ah / th)
        fs_v <- fontsize * min(1, ah / tw, aw / th)
        if (fs_v > fs_h * 1.15) { r <- 90; fs <- fs_v } else { r <- 0; fs <- fs_h }
        grid::grid.text(lab[i], x = x, y = 0.5, rot = r,
                        gp = grid::gpar(fontsize = max(fs, 3.5), fontface = fontface,
                                        col = tc[i]))
      }
    },
    var_import = list(labels = labels, fills = fills, tcols = tcols, pad = pad,
                      fontsize = fontsize, fontface = fontface,
                      border_col = border_col, border_lwd = border_lwd),
    n = n, which = "column", height = grid::unit(height_in, "in"))
}

#' The lab's EASI colour ramp: near-white at 0, grey through the range, black at max
#'
#' Reproduces the shape used in the pulsinelli per-patient heatmaps
#' (`colorRamp2(c(0, seq(1,74,.1), 75), c('white', rev(gray.colors(n)), 'black'))`)
#' but parameterised on the observed maximum so it works for any instrument.
#'
#' One deliberate change: `low` defaults to a barely-off-white rather than pure
#' white, because unscored samples (healthy controls, missing visits) draw as
#' white `na_col`. If clear skin and no-data both rendered white the reader
#' could not tell them apart. Pass `low = "white"` for the literal lab ramp.
#'
#' Works for any severity instrument on a non-negative scale -- EASI, SCORAD,
#' PASI, BSA, IGA -- by setting `max_score` to the observed maximum.
#'
#' @param max_score Top of the scale; values at or above it draw as `high`.
#' @param low Colour at zero.
#' @param high Colour at the top of the scale.
#' @param n Number of interpolation steps in the grey ramp between them.
#'
#' @return A `circlize::colorRamp2()` colour mapping function.
#' @seealso [ph_top_annotation()], [doPatientHeatmap()]
#' @examples
#' ramp <- ph_easi_ramp(max_score = 40)
#' ramp(c(0, 10, 40))
#' @export
ph_easi_ramp <- function(max_score = 72, low = "#F4F4F4", high = "black", n = 200) {
  max_score <- max(as.numeric(max_score), 2, na.rm = TRUE)
  brk <- c(0, seq(1, max_score, length.out = n), max_score * 1.02 + 0.5)
  circlize::colorRamp2(brk, c(low, rev(grDevices::gray.colors(n)), high))
}

#' Per-column text that shrinks or rotates instead of colliding
#'
#' @description
#' A drop-in replacement for `ComplexHeatmap::anno_text()` in column
#' annotations. `anno_text()` draws at a fixed size and happily overprints when
#' columns are narrow; this resolves the font against the real per-column width
#' at draw time, so labels shrink rather than collide.
#'
#' @details
#' Rotation is decided up front, from the layout's column width, because the
#' annotation's reserved height depends on it; only the font is refined at draw
#' time. Used for subject IDs under a per-patient heatmap and for printed
#' clinical-score values.
#'
#' @param labels One label per column.
#' @param col_in Column width in inches -- decides horizontal vs rotated.
#' @param max_fontsize,min_fontsize Bounds on the drawn point size.
#' @param fontface,fontfamily Font, as in [ph_measure_in()].
#' @param pad Fraction of the column the label may occupy.
#' @param side Annotation orientation; only `"column"` is supported.
#' @param anchor Which edge rotated text grows from. `"top"` hangs downward and
#'   suits a bottom annotation; `"bottom"` grows upward so the label sits
#'   directly on whatever it labels, which is what a header row above a table
#'   needs.
#'
#' @return A `ComplexHeatmap::AnnotationFunction` for use as a column
#'   annotation.
#' @seealso [ph_box_row()] for the boxed equivalent.
#' @examples
#' \dontrun{
#' ComplexHeatmap::HeatmapAnnotation(
#'   Subject = ph_anno_fit_text(annot$SubjectID, col_in = 0.3),
#'   show_annotation_name = FALSE)
#' }
#' @export
ph_anno_fit_text <- function(labels, col_in, max_fontsize = 11, min_fontsize = 4.5,
                             fontface = "plain", fontfamily = "", pad = 0.86,
                             side = c("column"), anchor = c("top", "bottom")) {
  .ph_require()
  anchor <- match.arg(anchor)
  labels <- as.character(labels)
  fs0 <- max_fontsize
  w_h <- ph_measure_in(labels, fs0, fontface, fontfamily)
  rot <- if (w_h <= col_in * pad) 0 else 90
  if (rot == 0) {
    height_in <- fs0 * 1.45 / 72
  } else {
    # Rotated: the label's length becomes vertical extent; its height becomes the
    # per-column footprint, so shrink the font if the column is thinner than that.
    fs0 <- .ph_clamp(col_in * pad * 72 / 1.25, min_fontsize, max_fontsize)
    height_in <- ph_measure_in(labels, fs0, fontface, fontfamily) + 0.06
  }
  ComplexHeatmap::AnnotationFunction(
    fun = function(index, k, n) {
      ni <- length(index)
      cw <- grid::convertWidth(grid::unit(1 / ni, "npc"), "in", valueOnly = TRUE)
      ch <- grid::convertHeight(grid::unit(1, "npc"), "in", valueOnly = TRUE)
      lab <- labels[index]
      if (rot == 0) {
        avail <- cw * pad
        wmax <- max(ph_measure_in(lab, fs0, fontface, fontfamily), 1e-6)
        fs <- .ph_clamp(fs0 * min(1, avail / wmax, ch * 0.9 * 72 / (fs0 * 1.25)),
                        min_fontsize, fs0)
        for (i in seq_along(lab))
          grid::grid.text(lab[i], x = (i - 0.5) / ni, y = 0.5,
                          gp = grid::gpar(fontsize = fs, fontface = fontface,
                                          fontfamily = fontfamily))
      } else {
        wmax <- max(ph_measure_in(lab, fs0, fontface, fontfamily), 1e-6)
        fs <- .ph_clamp(fs0 * min(1, ch * 0.94 / wmax, cw * pad * 72 / (fs0 * 1.25)),
                        min_fontsize, fs0)
        yy <- if (anchor == "top") grid::unit(1, "npc") else grid::unit(0, "npc")
        ju <- if (anchor == "top") "right" else "left"
        for (i in seq_along(lab))
          grid::grid.text(lab[i], x = (i - 0.5) / ni, y = yy, just = ju, rot = 90,
                          gp = grid::gpar(fontsize = fs, fontface = fontface,
                                          fontfamily = fontfamily))
      }
    },
    var_import = list(labels = labels, rot = rot, fs0 = fs0, pad = pad, anchor = anchor,
                      fontface = fontface, fontfamily = fontfamily,
                      min_fontsize = min_fontsize,
                      ph_measure_in = ph_measure_in, .ph_clamp = .ph_clamp),
    n = length(labels), which = match.arg(side),
    height = grid::unit(height_in, "in"))
}

#' Assemble a heatmap top annotation from blocks, strips and score tracks
#'
#' @description
#' Builds the full top-annotation stack used by the publication heatmaps: boxed
#' group bands first, then categorical strips, then continuous clinical-score
#' tracks closest to the heatmap body.
#'
#' @details
#' The order is deliberate. Blocks are the coarse design (group, tissue) and
#' read as headers, so they sit at the top; a continuous severity score belongs
#' immediately above the expression it is meant to be compared against.
#'
#' Unscored samples are drawn in `na_col` (white by default) rather than
#' ComplexHeatmap's grey, which would otherwise land in the middle of a
#' greyscale severity ramp and make a healthy control read as moderately
#' diseased.
#'
#' @param annot Data frame in column order (row names = sample order).
#' @param blocks Character vector of `annot` columns to draw as boxed grids.
#' @param block_colors Named list: block column -> named colour vector, passed
#'   to [ph_block()].
#' @param block_height_mm,block_fontsize Geometry of the boxed bands.
#' @param categorical Character vector of `annot` columns to draw as simple
#'   colour strips (with a legend, unlike blocks).
#' @param categorical_colors Named list: column -> named colour vector.
#' @param numeric Character vector of numeric `annot` columns, e.g. `"EASI"`.
#' @param numeric_colors Named list: column -> a `circlize::colorRamp2()`
#'   mapping. Defaults to [ph_easi_ramp()] over the observed range.
#' @param track_height_mm Height of each simple (categorical or numeric) strip.
#' @param numeric_show_values Also print the numeric values beneath the track.
#' @param numeric_value_fontsize Maximum point size for those printed values.
#' @param gap_mm Gap between stacked annotation rows.
#' @param name_fontsize Point size of the annotation names in the left margin.
#' @param col_in Column width in inches, normally from [ph_layout()]; decides
#'   whether printed values have to rotate.
#' @param border_col,border_lwd Borders for the boxed blocks.
#' @param na_col Colour for missing values in the numeric and categorical
#'   tracks.
#'
#' @return A `ComplexHeatmap::HeatmapAnnotation`, or `NULL` if nothing was
#'   requested.
#' @seealso [ph_block()], [ph_easi_ramp()], [doPatientHeatmap()]
#' @examples
#' \dontrun{
#' ph_top_annotation(annot, blocks = c("Grp", "Tissue"),
#'                   block_colors = list(Grp = c(Rash = "#D4645A")),
#'                   numeric = "EASI")
#' }
#' @export
ph_top_annotation <- function(
    annot,
    blocks = NULL, block_colors = list(), block_height_mm = 8, block_fontsize = 13,
    categorical = NULL, categorical_colors = list(),
    numeric = NULL, numeric_colors = list(),
    track_height_mm = 5.5,
    numeric_show_values = FALSE, numeric_value_fontsize = 7,
    gap_mm = 1.2, name_fontsize = 9, col_in = 0.3,
    border_col = "black", border_lwd = 1.2, na_col = "white") {

  .ph_require()
  av <- list(); colmap <- list(); shown <- logical(0)

  for (b in blocks) {
    av[[b]] <- ph_block(annot[[b]], fill = block_colors[[b]],
                        height_mm = block_height_mm, fontsize = block_fontsize,
                        border_col = border_col, border_lwd = border_lwd)
    shown[b] <- FALSE                       # the box already carries its label
  }
  for (k in categorical) {
    v <- as.character(annot[[k]])
    colmap[[k]] <- categorical_colors[[k]] %||% ph_palette(unique(v))
    av[[k]] <- v; shown[k] <- TRUE
  }
  for (nn in numeric) {
    v <- suppressWarnings(as.numeric(annot[[nn]]))
    colmap[[nn]] <- numeric_colors[[nn]] %||% ph_easi_ramp(max(v, na.rm = TRUE))
    av[[nn]] <- v; shown[nn] <- TRUE
    if (numeric_show_values) {
      lab <- ifelse(is.na(v), "", formatC(v, format = "fg", digits = 3))
      key <- paste0(nn, ".value")
      av[[key]] <- ph_anno_fit_text(lab, col_in = col_in,
                                    max_fontsize = numeric_value_fontsize,
                                    anchor = "bottom")
      shown[key] <- FALSE
    }
  }
  if (!length(av)) return(NULL)

  args <- av
  args$col <- colmap
  args$show_annotation_name <- unname(shown[names(av)])
  args$annotation_name_gp <- grid::gpar(fontsize = name_fontsize)
  args$annotation_name_side <- "left"
  args$gap <- grid::unit(gap_mm, "mm")
  args$simple_anno_size <- grid::unit(track_height_mm, "mm")
  args$border <- TRUE
  # Unscored samples must read as "no data", not as a mid-range value. The
  # default grey ComplexHeatmap uses for NA sits right in the middle of a
  # greyscale severity ramp, which is the worst possible ambiguity.
  args$na_col <- na_col
  do.call(ComplexHeatmap::HeatmapAnnotation, args)
}

# ---------------------------------------------------------------------------
# 4. Layout engine
# ---------------------------------------------------------------------------
