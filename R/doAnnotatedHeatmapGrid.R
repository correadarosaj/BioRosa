# doAnnotatedHeatmapGrid.R --------------------------------------------------
# A publication-quality annotated heatmap where the fold-change table beside the
# expression body is itself a heatmap-quality GRID: white cells (no internal
# lines), one continuous rectangle around each contrast group, and a signed
# fold-change + significance star printed inside every cell, decimal-aligned
# down each column. Contrast groups get boxed, colour-filled header bands over a
# bottom-aligned sub-label row.
#
# Imports: ComplexHeatmap, circlize, grid, grDevices, stats
# ----------------------------------------------------------------------------

.agh_clamp     <- function(x, lo, hi) max(lo, min(hi, x))
.agh_scalerows <- function(x) {
  m <- apply(x, 1, mean, na.rm = TRUE)
  s <- apply(x, 1, sd,   na.rm = TRUE)
  (x - m) / s
}

# Soft per-group fill. Named defaults cover the contrast dimensions BioRosa is
# used for -- response (R/NR), treatment (Drug/Pbo and synonyms), tissue
# (Lesional/Nonlesional) and any "<a>vs<b>" comparison column -- and anything
# unrecognised falls back to evenly-spaced pastel HCL hues so novel groupings
# (cohort, timepoint, dose, ...) still get distinct, legible bands.
.agh_group_palette <- function(groups) {
  known <- c(
    R = "#CDE7D0", NR = "#F9D9B7", RvsNR = "#E2D6EF",          # response
    Drug = "#F4C7C3", Pbo = "#C9DAF0", DrugvsPbo = "#E2D6EF",  # treatment
    Active = "#F4C7C3", Placebo = "#C9DAF0",                   # treatment (synonyms)
    Lesional = "#F6C9C0", Nonlesional = "#CDE0F0",             # tissue
    LS = "#F6C9C0", NL = "#CDE0F0", LSvsNL = "#E2D6EF"         # tissue (abbrev.)
  )
  pal <- known[groups]
  na  <- is.na(pal)
  # "<a>vs<b>" comparison groups (not named above) get the neutral purple band.
  cmp <- na & grepl("vs", groups, ignore.case = TRUE)
  if (any(cmp)) { pal[cmp] <- "#E2D6EF"; na <- is.na(pal) }
  if (any(na))
    pal[na] <- grDevices::hcl(h = seq(20, 360, length.out = sum(na) + 1)[-1],
                              c = 32, l = 88)
  stats::setNames(unname(pal), groups)
}

# Drop leading dot-tokens that are CONSTANT across all labels, so a uniform arm
# disappears while the varying part stays:
#   c("Drug.W2vsBL", "Drug.W4vsBL") -> c("W2vsBL", "W4vsBL")
.agh_strip_constant <- function(labels) {
  repeat {
    parts <- strsplit(labels, ".", fixed = TRUE)
    if (any(lengths(parts) < 2)) break
    if (length(unique(vapply(parts, `[`, "", 1))) != 1) break
    labels <- vapply(parts, function(p) paste(p[-1], collapse = "."), "")
  }
  labels
}

#' Annotated grid heatmap with a decimal-aligned fold-change table
#'
#' @description
#' `doAnnotatedHeatmapGrid()` draws a publication-quality annotated heatmap and
#' writes it to a PDF. The left part is a row-Z-scored expression body
#' (features x samples) rendered with `ComplexHeatmap`; the right part is a
#' companion table -- itself styled as a clean grid -- in which every cell holds
#' the signed fold-change plus a significance star for one contrast, all
#' decimal-aligned down each column. Contrasts are gathered into groups, each
#' drawn as a boxed, colour-filled header band sitting above a sub-label row.
#'
#' The function is *auto-adjusting*: with no size hints it scales per-row height,
#' the gene/cell fonts and the overall canvas to the gene-set size, and it parses
#' the group bands and per-column sub-labels directly from the contrast names.
#' This makes it agnostic to the comparison dimension -- the same call works for
#' response (`R`/`NR`), treatment (`Drug`/`Pbo`), tissue
#' (`Lesional`/`Nonlesional`), visit/timepoint contrasts, or any combination such
#' as `response.treatment.visit`. Every auto value can be overridden by passing
#' the matching argument.
#'
#' @details
#' **Contrast table input.** Fold-changes and p-values are read from `BigTab` by
#' name: for a contrast `"R.Drug.W2vsBL"` the function looks for columns
#' `paste0(fch_prefix, contrast)` and `paste0(pval_prefix, contrast)` (default
#' `"FCH_R.Drug.W2vsBL"` and `"pvals_R.Drug.W2vsBL"`). `FCH_*` is expected on the
#' fold-change scale (`1.00` = no change). Matching by full name (rather than
#' positional or token splitting) means contrast names may themselves contain
#' dots or underscores.
#'
#' **Grouping rule (default).** The group of a contrast is its first dot-token
#' (`group_of`); the header sub-label is the remainder with any dot-token that is
#' constant across all shown contrasts removed (so a uniform arm like `Drug`
#' disappears while `W2vsBL` stays). Pass `group_of` / `sublab_of` to override.
#'
#' **Significance stars** follow the cut-points `0.001 / 0.01 / 0.05 / 0.1` with
#' symbols `***`, `**`, `*`, `+` and blank above `0.1`.
#'
#' The function has the side effect of writing the heatmap to `grafname` as a
#' PDF and returns a small summary list invisibly.
#'
#' @param grafname Character. Path to the output PDF file.
#' @param mat Numeric matrix of expression values, features (rows, named) x
#'   samples (columns, named). Must contain every feature in `rownames(BigTab)`
#'   and every sample in `rownames(annot.col)`.
#' @param annot.col Data frame of per-sample annotation. Its row names define the
#'   body column order.
#' @param colsplitx Optional vector/factor used to split the body into column
#'   groups (e.g. a response or treatment factor). Default `NULL`.
#' @param column_ha Optional `ComplexHeatmap::HeatmapAnnotation` drawn above the
#'   body (caller-built clinical / phenotype tracks). Default `NULL`.
#' @param BigTab Data frame indexed by feature name (row names) carrying the
#'   fold-change and p-value columns (see Details). Required.
#' @param BigTabcols Optional character vector of contrast names to show, in the
#'   desired order. Default `NULL` uses every contrast found via `fch_prefix`.
#' @param fch_prefix,pval_prefix Character column-name prefixes used to locate
#'   the fold-change and p-value columns for each contrast. Defaults `"FCH_"`
#'   and `"pvals_"`.
#' @param setname Character. Caption drawn at the bottom. Default `""`.
#' @param group_of Function mapping a contrast name to its group label. Default
#'   takes the first dot-token.
#' @param sublab_of Optional function mapping a contrast name to its header
#'   sub-label. Default `NULL` derives it from the contrast remainder.
#' @param collapse_constant Logical. When deriving sub-labels automatically, drop
#'   leading dot-tokens that are constant across all contrasts. Default `TRUE`.
#' @param group_fill Optional named character vector of fill colours per group.
#'   Default `NULL` uses a built-in palette with an HCL fallback.
#' @param zcol A `circlize::colorRamp2` colour mapping for the body Z-scores.
#' @param split_gap A `grid::unit` gap between body column slices.
#' @param slice_border_gp,subsplit_border_gp `grid::gpar` for the slice border
#'   and the within-slice divider, respectively.
#' @param body_subsplit Optional vector (one value per body column) marking a
#'   sub-group; a divider line is drawn within each slice wherever it changes
#'   (e.g. Drug | Pbo within each response slice). Default `NULL`.
#' @param body_title_fontsize,group_label_fontsize Font sizes for the body column
#'   titles and the group band labels.
#' @param cell_fontsize,gene_fontsize,sublab_fontsize Font sizes for table cells,
#'   gene labels and sub-labels. `NULL` (default) auto-derives them.
#' @param table_cell_cm,row_cm,body_col_cm Cell width, row height and body column
#'   width in cm. `NULL` table/row values auto-derive from content.
#' @param wdt,hgt PDF width / height in inches. `0` (default) auto-derives.
#' @param rowclust Logical. Cluster the body rows. Default `TRUE`.
#'
#' @return Invisibly, a list with the chosen canvas size (`wdt`, `hgt`), counts
#'   (`n_genes`, `n_contrasts`), the parsed `groups`, and the resolved
#'   `table_cell_cm`, `gene_fontsize` and `cell_fontsize`.
#'
#' @seealso [doAnnotatedHeatmap()] for the row-annotation (non-grid) variant.
#'
#' @examples
#' \dontrun{
#' # Response x treatment x visit contrasts: groups parsed as R / NR / RvsNR,
#' # the constant "Drug" arm dropped from the sub-labels.
#' doAnnotatedHeatmapGrid(
#'   grafname  = "immune.pdf",
#'   mat       = expr_means,            # features x group-mean columns
#'   annot.col = annotx,               # row names = column order
#'   colsplitx = annotx$response,
#'   BigTab    = BigTab,               # FCH_* / pvals_* columns
#'   BigTabcols = c("R.Drug.W2vsBL", "NR.Drug.W2vsBL", "RvsNR.Drug.W2vsBL"),
#'   setname   = "Immune proteins")
#' }
#' @export
doAnnotatedHeatmapGrid <- function(
    grafname, mat, annot.col, colsplitx = NULL, column_ha = NULL,
    BigTab = NULL, BigTabcols = NULL,
    fch_prefix = "FCH_", pval_prefix = "pvals_", setname = "",
    # grouping / labels (auto from contrast names unless supplied)
    group_of = function(contr) sub("\\..*$", "", contr),
    sublab_of = NULL, collapse_constant = TRUE,
    group_fill = NULL,
    # styling (sensible defaults; matched across the body + table)
    zcol = circlize::colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
    split_gap = grid::unit(6, "mm"),
    slice_border_gp = grid::gpar(col = "black", lwd = 1.4),
    body_subsplit = NULL,
    subsplit_border_gp = grid::gpar(col = "black", lwd = 1.2),
    body_title_fontsize = 22, group_label_fontsize = 13,
    # sizes: NULL => auto from gene-set size / contrast count / string widths
    cell_fontsize = NULL, gene_fontsize = NULL, sublab_fontsize = NULL,
    table_cell_cm = NULL, row_cm = NULL, body_col_cm = 1.0,
    wdt = 0, hgt = 0, rowclust = TRUE) {

  ## ---- validate -----------------------------------------------------------
  if (missing(grafname) || !is.character(grafname) || length(grafname) != 1)
    stop("`grafname` must be a single output PDF path.")
  if (missing(mat) || !is.matrix(mat) || is.null(rownames(mat)) || is.null(colnames(mat)))
    stop("`mat` must be a matrix with row (feature) and column (sample) names.")
  if (missing(annot.col) || is.null(rownames(annot.col)))
    stop("`annot.col` must be a data frame whose row names are the sample order.")
  if (is.null(BigTab))
    stop("`BigTab` is required (a feature-indexed table of FCH_/pvals_ columns).")
  if (!all(rownames(annot.col) %in% colnames(mat)))
    stop("Every row name of `annot.col` must be a column of `mat`.")

  ## ---- pull the contrasts to display (preserving BigTabcols order) --------
  fch_all  <- grep(paste0("^", fch_prefix), colnames(BigTab), value = TRUE)
  if (!length(fch_all))
    stop("No fold-change columns found with prefix '", fch_prefix, "' in `BigTab`.")
  contr <- if (is.null(BigTabcols)) sub(paste0("^", fch_prefix), "", fch_all) else BigTabcols

  fch_cols  <- paste0(fch_prefix,  contr)
  pval_cols <- paste0(pval_prefix, contr)
  miss <- !c(fch_cols, pval_cols) %in% colnames(BigTab)
  if (any(miss))
    stop("Missing columns in `BigTab`: ",
         paste(c(fch_cols, pval_cols)[miss], collapse = ", "))

  fchm <- as.matrix(BigTab[, fch_cols,  drop = FALSE]); colnames(fchm) <- contr
  pv   <- as.matrix(BigTab[, pval_cols, drop = FALSE]); colnames(pv)   <- contr
  nC <- ncol(fchm); nG <- nrow(fchm); genes <- rownames(BigTab)
  if (!all(genes %in% rownames(mat)))
    stop("Every feature in `BigTab` must be a row of `mat`.")

  ## ---- groups + sub-labels (parsed from contrast names) -------------------
  grp     <- factor(group_of(contr), levels = unique(group_of(contr)))
  glevels <- levels(grp)
  if (is.null(sublab_of)) {
    rem <- sub("^[^.]+\\.", "", contr); rem[rem == contr] <- ""  # remainder after first token
    sublab <- if (collapse_constant) .agh_strip_constant(rem) else rem
    sublab[sublab == ""] <- contr[sublab == ""]                  # fall back to full name
  } else sublab <- sublab_of(contr)
  gfill <- if (is.null(group_fill)) .agh_group_palette(glevels)
           else { f <- group_fill[glevels]; f[is.na(f)] <- "#E0E0E0"; stats::setNames(f, glevels) }

  ## ---- per-cell strings + auto sizing -------------------------------------
  star <- matrix(vapply(as.vector(pv), function(p)
            as.character(cut(p, c(-Inf, .001, .01, .05, .1, Inf),
                             c("***", "**", "*", "+", ""), right = TRUE)),
            character(1)), nrow = nG, dimnames = dimnames(pv))
  star[is.na(star)] <- ""
  num  <- ifelse(is.finite(fchm), formatC(fchm, format = "f", digits = 2), "")
  pre  <- ifelse(num == "", "", sub("\\..*$", ".", num))                  # "-3."
  post <- ifelse(num == "", "", paste0(sub("^[^.]*\\.", "", num), star))  # "03***"
  cellstr <- ifelse(num == "", "", paste0(num, star))

  if (is.null(row_cm))          row_cm        <- .agh_clamp(30 / nG, 0.18, 0.62)
  if (is.null(gene_fontsize))   gene_fontsize <- .agh_clamp(row_cm / 2.54 * 72 * 0.72, 5, 11)
  if (is.null(cell_fontsize))   cell_fontsize <- .agh_clamp(gene_fontsize + 1, 7, 13)
  if (is.null(sublab_fontsize)) sublab_fontsize <- .agh_clamp(cell_fontsize, 8, 13)
  if (is.null(table_cell_cm)) {                                            # widen to fit widest string
    maxchars <- max(nchar(c(cellstr, sublab)), 4)
    char_cm  <- max(cell_fontsize, sublab_fontsize) / 72 * 2.54 * 0.62
    table_cell_cm <- maxchars * char_cm + 0.30
  }

  ## ---- expression body ----------------------------------------------------
  body <- .agh_scalerows(mat[genes, rownames(annot.col), drop = FALSE])
  ht_body <- ComplexHeatmap::Heatmap(
    body, name = "Z-score", column_split = colsplitx, col = zcol,
    width = grid::unit(ncol(body) * body_col_cm, "cm"),
    column_title_gp = grid::gpar(fontsize = body_title_fontsize, fontface = "bold"),
    column_gap = split_gap, border = TRUE, border_gp = slice_border_gp,
    top_annotation = column_ha, cluster_rows = rowclust, cluster_columns = FALSE,
    show_row_names = FALSE, show_column_names = FALSE,
    row_names_gp = grid::gpar(fontsize = gene_fontsize),
    column_order = rownames(annot.col), use_raster = TRUE)

  ha_gene <- ComplexHeatmap::rowAnnotation(
    Gene = ComplexHeatmap::anno_text(
      genes, just = "left", location = grid::unit(0, "npc"),
      gp = grid::gpar(fontsize = gene_fontsize, fontface = "bold", fontfamily = "mono")))

  ## ---- fold-change grid table ---------------------------------------------
  tab_top <- ComplexHeatmap::HeatmapAnnotation(
    Group = ComplexHeatmap::anno_block(
      gp = grid::gpar(fill = unname(gfill), col = "black", lwd = 1.2),
      labels = glevels,
      labels_gp = grid::gpar(fontface = "bold", fontsize = group_label_fontsize),
      height = grid::unit(0.85, "cm")),
    Visit = ComplexHeatmap::anno_text(
      sublab, rot = 0, just = "bottom", location = grid::unit(0, "npc"),
      gp = grid::gpar(fontsize = sublab_fontsize, fontface = "bold"),
      height = grid::unit(0.55, "cm")),
    show_annotation_name = FALSE, gap = grid::unit(1.2, "mm"))

  white <- circlize::colorRamp2(c(0, 1), c("white", "white"))
  ht_tab <- ComplexHeatmap::Heatmap(
    matrix(0, nG, nC, dimnames = dimnames(fchm)),
    col = white, show_heatmap_legend = FALSE,
    column_split = grp, cluster_rows = FALSE, cluster_columns = FALSE,
    column_order = seq_len(nC), column_title = rep("", length(glevels)),
    top_annotation = tab_top,
    column_gap = grid::unit(0, "mm"), border = TRUE,
    border_gp = grid::gpar(col = "black", lwd = 1.2),
    rect_gp = grid::gpar(col = NA, fill = "white"),               # no internal grid
    width = grid::unit(nC * table_cell_cm, "cm"),
    show_row_names = FALSE, show_column_names = FALSE,
    cell_fun = function(j, i, x, y, w, h, fill) {
      if (pre[i, j] == "") return(invisible())
      anchor <- x - 0.12 * w                                      # decimal-point anchor
      gp <- grid::gpar(fontsize = cell_fontsize, fontface = 2, fontfamily = "mono")
      grid::grid.text(pre[i, j],  anchor, y, just = "right", gp = gp)
      grid::grid.text(post[i, j], anchor, y, just = "left",  gp = gp)
    }, use_raster = FALSE)

  ## ---- auto canvas + draw -------------------------------------------------
  if (wdt == 0) wdt <- ncol(mat) * body_col_cm / 2.54 + nC * (table_cell_cm / 2.54) +
                       max(nchar(genes)) * gene_fontsize / 72 * 0.62 + 2.4
  if (hgt == 0) hgt <- nG * row_cm / 2.54 + 3.0
  grDevices::pdf(file = grafname, width = wdt, height = hgt)
  on.exit(grDevices::dev.off(), add = TRUE)
  ComplexHeatmap::draw(
    ht_body + ha_gene + ht_tab, padding = grid::unit(c(8, 8, 16, 12), "mm"),
    column_title = setname, column_title_side = "bottom",
    column_title_gp = grid::gpar(fontsize = 13), merge_legends = TRUE)

  # internal body divider(s) where the sub-group changes within each slice
  if (!is.null(body_subsplit)) {
    ss <- as.character(body_subsplit)
    sp_lvls <- if (is.null(colsplitx)) list(seq_along(ss))
               else { lv <- if (is.factor(colsplitx)) levels(colsplitx) else unique(colsplitx)
                      lapply(lv, function(L) which(colsplitx == L)) }
    for (si in seq_along(sp_lvls)) {
      idx <- sp_lvls[[si]]; sub <- ss[idx]; n <- length(sub)
      if (n < 2) next
      bnd <- which(sub[-1] != sub[-n])
      if (!length(bnd)) next
      ComplexHeatmap::decorate_heatmap_body("Z-score", column_slice = si, {
        for (b in bnd)
          grid::grid.lines(grid::unit(c(b / n, b / n), "npc"),
                           grid::unit(c(0, 1), "npc"), gp = subsplit_border_gp)
      })
    }
  }

  invisible(list(wdt = wdt, hgt = hgt, n_genes = nG, n_contrasts = nC,
                 groups = glevels, table_cell_cm = table_cell_cm,
                 gene_fontsize = gene_fontsize, cell_fontsize = cell_fontsize))
}
