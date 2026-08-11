#' Annotated grid heatmap: expression body plus a fold-change table
#'
#' @description
#' A row-Z-scored expression body, the feature names, and a companion table in
#' which every cell holds a signed fold-change plus a significance star,
#' decimal-aligned down each column. Contrasts are gathered into boxed,
#' colour-filled group bands with one boxed cell per contrast beneath them, so
#' the header reads as a continuous grid.
#'
#' This is [doAnnotatedHeatmapGrid()] with the guesswork removed.
#'
#' @details
#' **Measured, not estimated.** [doAnnotatedHeatmapGrid()] approximates string
#' widths as `nchar * fontsize * 0.62`; here they are measured with
#' [ph_measure_in()], and the decimal anchor is placed so the widest integer
#' part and the widest fraction-plus-stars both fit inside the cell. That is
#' what stops `-12.34***` running into its neighbour while `1.02` sits alone in
#' a needlessly wide column.
#'
#' **The numbers set the row height.** They are the reason this figure exists,
#' so `cell_font_min` acts as a legibility floor and the rows grow to give the
#' digits clearance rather than the font shrinking to fit the rows. A large gene
#' set therefore produces a taller page, not a denser unreadable one.
#'
#' **Contrast names drive the layout.** The first dot-token becomes the group
#' band, the remainder becomes the sub-label, and any token constant across all
#' contrasts is dropped so a uniform arm disappears. Stars follow the lab
#' cut-points `0.001 / 0.01 / 0.05 / 0.1` as `***`, `**`, `*`, `+`.
#'
#' @param grafname Output PDF path.
#' @param mat Feature x sample matrix of raw values.
#' @param annot.col Data frame whose row names define the body column order.
#' @param BigTab Feature-indexed table carrying `FCH_<contrast>` and
#'   `pvals_<contrast>` columns.
#' @param BigTabcols Contrasts to show, in order. Default: every contrast found
#'   via `fch_prefix`.
#' @param colsplitx Optional vector splitting the body into labelled slices.
#' @param blocks,block_colors Boxed headers over the body, and their colours.
#' @param categorical,categorical_colors Simple colour strips over the body.
#' @param easi,easi_max Continuous severity track over the body, and its ramp
#'   maximum.
#' @param numeric,numeric_colors Further numeric tracks and their ramps.
#' @param top_annotation Optional pre-built `HeatmapAnnotation` for the body.
#' @param bottom_labels Labels printed under the body columns.
#' @param fch_prefix,pval_prefix Column-name prefixes locating the fold-change
#'   and p-value columns for each contrast.
#' @param group_of Function mapping a contrast name to its group band label.
#' @param sublab_of Optional function mapping a contrast name to its sub-label;
#'   `NULL` derives it from the remainder.
#' @param collapse_constant Drop leading dot-tokens that are constant across all
#'   contrasts when deriving sub-labels.
#' @param group_fill Named colours for the group bands.
#' @param setname Caption drawn beneath the figure.
#' @param zlim,zcol Colour saturation point and optional ramp override.
#' @param cluster_rows,cluster_columns Cluster rows / body columns.
#' @param row_in,col_in,row_fontsize Body cell geometry and feature-label size.
#' @param cell_fontsize Point size of the table numbers; `NULL` derives it from
#'   the resolved row height.
#' @param cell_font_min,cell_font_max Legibility band for those numbers.
#'   `cell_font_min` is enforced by growing the rows, so lowering it shortens
#'   the page at the cost of smaller digits.
#' @param sublab_fontsize Maximum point size for the contrast labels.
#' @param table_cell_in Fixed table column width in inches; `NULL` derives it
#'   from the measured numbers and labels.
#' @param sublab_fill Fill colour(s) for the contrast boxes; defaults to a
#'   lighter tint of each group band.
#' @param block_height_mm,block_fontsize,track_height_mm Body annotation
#'   geometry.
#' @param group_band_mm,group_label_fontsize Geometry of the table's group
#'   bands.
#' @param wdt,hgt Optional page overrides in inches; normally unnecessary.
#' @param density Scale factor for the whole figure.
#' @param split_gap_mm,border_lwd,split_title_fontsize Slice gap, border width
#'   and slice-title size, as in [doPatientHeatmap()].
#' @param legend_title Title of the expression colour legend.
#' @param verbose Report the resolved page size and any dropped features.
#'
#' @return Invisibly, the resolved layout plus `width`, `height`, `n_genes`,
#'   `n_contrasts`, `table_cell_in` and `cell_fontsize`. Called for the side
#'   effect of writing `grafname`.
#' @seealso [doAnnotatedHeatmapGrid()] for the original, [doPatientHeatmap()]
#' @examples
#' \dontrun{
#' doAnnotatedGridHeatmap(
#'   grafname = "annotated_immune.pdf",
#'   mat = expr[genes, rownames(annotx)], annot.col = annotx,
#'   colsplitx = annotx$Grp, BigTab = BigTab,
#'   BigTabcols = c("LS.PostvsPre", "NL.PostvsPre"),
#'   blocks = c("Grp", "Tissue"), easi = "EASI")
#' }
#' @export
doAnnotatedGridHeatmap <- function(
    grafname, mat, annot.col, BigTab, BigTabcols = NULL,
    colsplitx = NULL, blocks = NULL, block_colors = list(),
    categorical = NULL, categorical_colors = list(),
    easi = NULL, easi_max = NULL, numeric = NULL, numeric_colors = list(),
    top_annotation = NULL, bottom_labels = NULL,
    fch_prefix = "FCH_", pval_prefix = "pvals_",
    group_of = function(x) sub("\\..*$", "", x), sublab_of = NULL,
    collapse_constant = TRUE, group_fill = NULL,
    setname = "", zlim = 1.5, zcol = NULL,
    cluster_rows = TRUE, cluster_columns = FALSE,
    row_in = NULL, col_in = NULL, row_fontsize = NULL, cell_fontsize = NULL,
    cell_font_min = 7, cell_font_max = 11,
    sublab_fontsize = NULL, table_cell_in = NULL, sublab_fill = NULL,
    block_height_mm = 8, block_fontsize = 13, track_height_mm = 5.5,
    group_band_mm = 8.5, group_label_fontsize = 13,
    wdt = NULL, hgt = NULL, density = 1,
    split_gap_mm = 3, border_lwd = 1.2, split_title_fontsize = NULL,
    legend_title = "Z-score", verbose = TRUE) {

  .ph_require()
  annot.col <- as.data.frame(annot.col)
  mat <- as.matrix(mat)[, rownames(annot.col), drop = FALSE]

  fch_all <- grep(paste0("^", fch_prefix), colnames(BigTab), value = TRUE)
  if (!length(fch_all)) stop("no '", fch_prefix, "*' columns in BigTab")
  contr <- BigTabcols %||% sub(paste0("^", fch_prefix), "", fch_all)
  need <- c(paste0(fch_prefix, contr), paste0(pval_prefix, contr))
  if (any(!need %in% colnames(BigTab)))
    stop("missing BigTab columns: ", paste(need[!need %in% colnames(BigTab)], collapse = ", "))

  genes <- intersect(rownames(BigTab), rownames(mat))
  if (!length(genes)) stop("no features shared between BigTab and mat")
  BigTab <- BigTab[genes, , drop = FALSE]
  z <- ph_zscore(mat[genes, , drop = FALSE], verbose)
  genes <- rownames(z)
  BigTab <- BigTab[genes, , drop = FALSE]

  fchm <- as.matrix(BigTab[, paste0(fch_prefix, contr), drop = FALSE])
  pv   <- as.matrix(BigTab[, paste0(pval_prefix, contr), drop = FALSE])
  colnames(fchm) <- colnames(pv) <- contr
  nG <- nrow(fchm); nC <- ncol(fchm)

  grp <- factor(group_of(contr), levels = unique(group_of(contr)))
  glev <- levels(grp)
  if (is.null(sublab_of)) {
    rem <- sub("^[^.]+\\.", "", contr); rem[rem == contr] <- ""
    if (collapse_constant) {
      repeat {
        parts <- strsplit(rem, ".", fixed = TRUE)
        if (any(lengths(parts) < 2)) break
        if (length(unique(vapply(parts, `[`, "", 1))) != 1) break
        rem <- vapply(parts, function(p) paste(p[-1], collapse = "."), "")
      }
    }
    rem[rem == ""] <- contr[rem == ""]
    sublab <- rem
  } else sublab <- sublab_of(contr)
  gfill <- ph_palette(glev, group_fill)
  gtext <- ph_contrast_col(gfill)

  star <- matrix(as.character(cut(as.vector(pv), c(-Inf, .001, .01, .05, .1, Inf),
                                  c("***", "**", "*", "+", ""), right = TRUE)),
                 nrow = nG, dimnames = dimnames(pv))
  star[is.na(star)] <- ""
  num  <- ifelse(is.finite(fchm), formatC(fchm, format = "f", digits = 2), "")
  pre  <- ifelse(num == "", "", sub("\\..*$", ".", num))
  post <- ifelse(num == "", "", paste0(sub("^[^.]*\\.", "", num), star))

  # ---- table geometry: measured, so the decimal alignment cannot collide ----
  # The numbers are the reason this figure exists, so they set the floor on row
  # height rather than inheriting whatever the gene count left over. Sizing the
  # cell font from the raw row estimate (as an earlier version did) let a large
  # gene set drive rows to ~6pt tall while the digits stayed 6pt -- technically
  # inside the cell, but with no daylight between rows. The row grows instead.
  lay <- ph_layout(nG, ncol(z),
                   row_labels = genes, bottom_labels = bottom_labels,
                   legend_labels = c(legend_title, format(c(-zlim, zlim)), easi %||% ""),
                   row_in = row_in, col_in = col_in, row_fontsize = row_fontsize,
                   top_anno_in = 0.75, title_in = 0.5, density = density,
                   row_min_in = if (is.null(row_in) && is.null(cell_fontsize))
                                  cell_font_min * 1.22 / 72 else 0)

  if (is.null(cell_fontsize))
    cell_fontsize <- .ph_clamp(lay$row_in * 72 / 1.22, cell_font_min, cell_font_max)
  pre_w  <- ph_measure_in(pre,  cell_fontsize, "bold", "mono")
  post_w <- ph_measure_in(post, cell_fontsize, "bold", "mono")
  sub_fs <- sublab_fontsize %||% .ph_clamp(cell_fontsize + 1, 7, 12)
  sub_w  <- ph_measure_in(sublab, sub_fs, "bold")
  # Widen the column so the contrast label sits horizontally when that is not
  # extravagant -- a horizontal header is far easier to read than a rotated one,
  # but not worth doubling the table width for, so cap the concession.
  num_in   <- pre_w + post_w + 0.16
  sub_flat <- sub_w / 0.90 + 0.06
  cell_in  <- table_cell_in %||% max(num_in, min(sub_flat, num_in * 2.2), 0.30)
  anchor_frac <- ((cell_in - pre_w - post_w) / 2 + pre_w) / cell_in  # decimal anchor

  # gene names live in their own middle column here, not in the body's margin
  gene_w <- ph_measure_in(genes, lay$row_fontsize, "bold", "mono") + 0.14

  if (!is.null(easi)) {
    numeric <- unique(c(numeric, easi))
    numeric_colors[[easi]] <- numeric_colors[[easi]] %||%
      ph_easi_ramp(easi_max %||% max(suppressWarnings(as.numeric(annot.col[[easi]])), na.rm = TRUE))
  }
  if (is.null(top_annotation))
    top_annotation <- ph_top_annotation(
      annot.col, blocks = blocks, block_colors = block_colors,
      categorical = categorical, categorical_colors = categorical_colors,
      numeric = numeric, numeric_colors = numeric_colors,
      block_height_mm = block_height_mm, block_fontsize = block_fontsize,
      track_height_mm = track_height_mm, col_in = lay$col_in)

  bottom_annotation <- if (is.null(bottom_labels)) NULL else
    ComplexHeatmap::HeatmapAnnotation(
      lab = ph_anno_fit_text(bottom_labels, col_in = lay$col_in,
                             max_fontsize = lay$bottom_fontsize),
      show_annotation_name = FALSE, which = "column")

  zcol <- zcol %||% circlize::colorRamp2(c(-zlim, 0, zlim), c("blue", "white", "red"))
  stf  <- split_title_fontsize %||% .ph_split_title_fontsize(colsplitx, lay$col_in)
  if (is.null(split_title_fontsize) && .ph_split_is_redundant(colsplitx, annot.col, blocks))
    attr(stf, "suppress") <- TRUE

  ht_body <- .ph_body(z, annot.col, colsplitx, zcol, lay, top_annotation, bottom_annotation,
                      cluster_rows, cluster_columns, FALSE, split_gap_mm,
                      border_lwd, stf, legend_title, "right", zlim)

  ha_gene <- ComplexHeatmap::rowAnnotation(
    Gene = ComplexHeatmap::anno_text(
      genes, just = "left", location = grid::unit(0.02, "npc"),
      gp = grid::gpar(fontsize = lay$row_fontsize, fontface = "bold", fontfamily = "mono")),
    width = grid::unit(gene_w, "in"), show_annotation_name = FALSE)

  # Group bands: same boxed-grid treatment as the top annotation, so the whole
  # figure reads as one design language.
  tab_top <- ComplexHeatmap::HeatmapAnnotation(
    Group = ComplexHeatmap::anno_block(
      panel_fun = function(index, ...) {
        nm <- as.character(grp[index[1]])
        grid::grid.rect(gp = grid::gpar(fill = unname(gfill[nm]), col = "black", lwd = border_lwd))
        aw <- grid::convertWidth(grid::unit(0.92, "npc"), "in", valueOnly = TRUE)
        ah <- grid::convertHeight(grid::unit(0.92, "npc"), "in", valueOnly = TRUE)
        g  <- grid::textGrob(nm, gp = grid::gpar(fontsize = group_label_fontsize, fontface = "bold"))
        tw <- max(grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE), 1e-6)
        th <- max(grid::convertHeight(grid::grobHeight(g), "in", valueOnly = TRUE), 1e-6)
        fs <- group_label_fontsize * min(1, aw / tw, ah / th)
        grid::grid.text(nm, gp = grid::gpar(fontsize = max(fs, 4), fontface = "bold",
                                            col = unname(gtext[match(nm, names(gfill))])))
      },
      height = grid::unit(group_band_mm, "mm")),
    # Each contrast gets its own box in the header grid, tinted from its group
    # band and butted straight against it (gap 0) so band and contrasts read as
    # one continuous table header rather than as text hovering above one.
    Sub = ph_box_row(sublab, col_in = cell_in,
                     fill = sublab_fill %||% .ph_tint(unname(gfill[as.character(grp)]), 0.45),
                     fontsize = sub_fs, border_lwd = max(border_lwd - 0.2, 0.6)),
    show_annotation_name = FALSE, gap = grid::unit(0, "mm"))

  white <- circlize::colorRamp2(c(0, 1), c("white", "white"))
  # ComplexHeatmap advises switching to the vectorised `layer_fun` past 100
  # rows. That advice does not apply here: the two-part decimal anchoring needs
  # per-cell placement, and a few seconds of draw time is the price of the
  # alignment. Muffle just that one message so callers are not warned off using
  # the function exactly as designed; every other warning still surfaces.
  ht_tab <- withCallingHandlers(
    ComplexHeatmap::Heatmap(
    matrix(0, nG, nC, dimnames = dimnames(fchm)),
    col = white, show_heatmap_legend = FALSE,
    column_split = grp, cluster_rows = FALSE, cluster_columns = FALSE,
    # Blank (a space, see .ph_body) -- the group name is in the boxed band.
    column_order = seq_len(nC), column_title = rep(" ", length(glev)),
    top_annotation = tab_top,
    column_gap = grid::unit(0, "mm"), border = TRUE,
    border_gp = grid::gpar(col = "black", lwd = border_lwd),
    rect_gp = grid::gpar(col = NA, fill = "white"),
    width = grid::unit(nC * cell_in, "in"),
    height = grid::unit(lay$body_h, "in"),
    show_row_names = FALSE, show_column_names = FALSE,
    cell_fun = function(j, i, x, y, w, h, fill) {
      if (pre[i, j] == "") return(invisible())
      a <- x - 0.5 * w + anchor_frac * w
      gp <- grid::gpar(fontsize = cell_fontsize, fontface = "bold", fontfamily = "mono")
      grid::grid.text(pre[i, j],  a, y, just = "right", gp = gp)
      grid::grid.text(post[i, j], a, y, just = "left",  gp = gp)
    }, use_raster = FALSE),
    warning = function(w) {
      if (grepl("vectorized version", conditionMessage(w), fixed = TRUE))
        invokeRestart("muffleWarning")
    })

  ht_list <- ht_body + ha_gene + ht_tab
  draw_args <- list(padding = grid::unit(c(4, 4, 4, 4), "mm"),
                    column_title = setname, column_title_side = "bottom",
                    column_title_gp = grid::gpar(fontsize = 12), merge_legends = TRUE)
  fit <- .ph_autofit(ht_list, draw_args,
                     c(lay$body_w + gene_w + nC * cell_in + lay$legend_in + 0.7, lay$height))
  W <- wdt %||% fit[1]; H <- hgt %||% fit[2]

  grDevices::pdf(grafname, width = W, height = H)
  on.exit(grDevices::dev.off(), add = TRUE)
  do.call(ComplexHeatmap::draw, c(list(ht_list), draw_args))
  if (verbose) message(sprintf("pubheat: %s  [%d genes x %d contrasts, %.1f x %.1f in]",
                               basename(grafname), nG, nC, W, H))
  invisible(c(lay, list(width = W, height = H, n_genes = nG, n_contrasts = nC,
                        table_cell_in = cell_in, cell_fontsize = cell_fontsize)))
}
