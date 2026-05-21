#' Annotated heatmap with a bordered, high-resolution side table (v2)
#'
#' @description
#' Successor to [FancyAnnotatedHeatmap()] that renders the per-contrast side
#' table with explicit rectangular borders and larger, bolder header/body
#' fonts so the table reads clearly when the heatmap is exported at
#' publication resolution. Behaviour is otherwise compatible with
#' [FancyAnnotatedHeatmap()]; new visual parameters control the appearance of
#' the side table without changing the heatmap body.
#'
#' @param grafname Output PDF path.
#' @param matx Numeric matrix of expression values (rows = genes, columns = samples).
#' @param annot.col Sample annotation data frame whose row names match `colnames(matx)`.
#' @param colsplitx Optional vector used to split heatmap columns into groups.
#' @param column_ha Optional `HeatmapAnnotation` placed at the top of the heatmap.
#' @param BigTab Optional big table of contrast statistics (passed through for sub-setting).
#' @param wdt,hgt PDF width / height (inches). When `NULL` (the default) the
#'   PDF is sized to drop directly into a 16:9 PowerPoint slide
#'   (13.33in x 7.5in): `wdt` defaults to `ppt_slide_width` and `hgt` scales
#'   with the number of genes at `rows_per_inch` rows per inch, floored at
#'   35\% of the slide height and capped at `ppt_slide_height`.
#' @param setname Caption shown below the heatmap.
#' @param column_names_max_height Max height for column-name labels.
#' @param BigTabcols Optional character vector; columns of `BigTab` whose names match are kept.
#' @param cfx Matrix of log fold-changes (rows = genes, columns = contrasts).
#' @param fdx Matrix of p-values or FDRs aligned to `cfx`.
#' @param ShowColumnNames Logical; show heatmap column labels.
#' @param fnt_size_title Font size for the heatmap column-split titles.
#' @param scalerows Logical; if `TRUE` z-score rows before plotting.
#' @param rampvalues Symmetric limit of the z-score colour ramp.
#' @param bottom_annotation Optional `HeatmapAnnotation` placed at the bottom.
#' @param border Logical; pass-through to `ComplexHeatmap::Heatmap`.
#' @param cell_fun Cell-drawing function for the heatmap body. Defaults to
#'   `NULL` so `ComplexHeatmap::Heatmap` renders the colour ramp normally.
#'   Pass a function (e.g. one that fills cells with white) to override.
#' @param table_border_col Colour of the rectangular border drawn around each
#'   side-table column. Defaults to `NA` (no column border); set to a colour
#'   such as `"black"` to draw outlines.
#' @param table_border_lwd Line width of the side-table column border (only
#'   used when `table_border_col` is not `NA`).
#' @param table_header_fontsize Font size of each side-table column title (was 10 in v1).
#' @param table_header_fontface Font face of the side-table column title (1 = plain, 2 = bold).
#' @param table_header_fill Optional fill colour for the title box above each
#'   side-table column. Use `NA` for no fill.
#' @param table_header_border_col Border colour for the title box. Defaults to
#'   `NA` (no border); set to a colour to enable.
#' @param table_header_border_lwd Line width for the title box border (only
#'   used when `table_header_border_col` is not `NA`).
#' @param table_header_pad_mm Vertical padding (mm) between the heatmap and the title box.
#' @param table_header_height_mm Height (mm) of the title box.
#' @param table_body_fontsize Font size of the side-table cell values (was 10 in v1).
#' @param table_body_fontface Font face of the side-table cell values.
#' @param gene_col_fontsize Font size of the leading gene-name column.
#' @param gene_col_fontface Font face of the leading gene-name column.
#' @param table_cell_pad_spaces Number of non-breaking spaces (`&nbsp;`) added
#'   to the left and right of every side-table cell value so text does not
#'   press against the column border. Increase for more breathing room.
#' @param heatmap_column_width_cm Width (cm) of each individual heatmap body
#'   column. Decrease to make the heatmap body thinner so the side table gets
#'   relatively more space.
#' @param table_col_width_cm Explicit width (cm) for each contrast column in
#'   the side table. `NULL` lets ComplexHeatmap auto-size from the text width.
#' @param ppt_slide_width Default PDF width (inches) when `wdt` is `NULL`.
#'   Default `13.33` matches a 16:9 PowerPoint slide. Use `10` for legacy
#'   4:3 slides.
#' @param ppt_slide_height Default PDF height (inches) when `hgt` is `NULL`.
#'   Default `7.5` matches a 16:9 PowerPoint slide.
#' @param rows_per_inch Target row density (rows per inch) used to auto-size
#'   `hgt`. Higher values pack rows more tightly. Default `10`.
#' @param ... Reserved for forward compatibility; currently ignored.
#'
#' @return Invisibly returns `NULL`; called for its side effect of writing a PDF to `grafname`.
#' @seealso [FancyAnnotatedHeatmap()], [doAnnotatedHeatmap()], [doTab()]
#' @export
FancyAnnotatedHeatmap_vs2 <- function(
    grafname,
    matx,
    annot.col,
    colsplitx = NULL,
    column_ha = NULL,
    BigTab = NULL,
    wdt = NULL,
    hgt = NULL,
    setname = '',
    column_names_max_height = unit(8, "cm"),
    BigTabcols = NULL,
    cfx = NULL,
    fdx = NULL,
    ShowColumnNames = FALSE,
    fnt_size_title = 20,
    scalerows = TRUE,
    rampvalues = 1.5,
    bottom_annotation = NULL,
    border = TRUE,
    # NULL lets ComplexHeatmap render the colour ramp; pass a function to
    # override (e.g. one that fills cells with white).
    cell_fun = NULL,

    # ---- v2-specific side-table styling -----------------------------------
    # Borders default to off; set table_border_col / table_header_border_col
    # to a colour to re-enable the bordered look from earlier defaults.
    table_border_col        = NA,
    table_border_lwd        = 1.2,
    table_header_fontsize   = 9,
    table_header_fontface   = 2,
    table_header_fill       = "grey95",
    table_header_border_col = NA,
    table_header_border_lwd = 1.2,
    table_header_pad_mm     = 1.5,
    table_header_height_mm  = 14,
    table_body_fontsize     = 10,
    table_body_fontface     = 2,
    gene_col_fontsize       = 10,
    gene_col_fontface       = 2,
    # Number of &nbsp; characters added to each side of every cell value so
    # text does not press against the column border.
    table_cell_pad_spaces   = 2,
    heatmap_column_width_cm = 0.6,
    table_col_width_cm      = NULL,

    # ---- PowerPoint slide sizing ------------------------------------------
    # 13.33in x 7.5in is the canvas of a 16:9 PowerPoint slide. Defaults aim
    # the PDF at that frame so it can be inserted at native size; row density
    # is set to ~10 rows/inch so the heatmap stays tight rather than leaving
    # wide gaps between rows when n.genes is small.
    ppt_slide_width  = 13.33,
    ppt_slide_height = 7.5,
    rows_per_inch    = 10,
    ...
) {

  # Optionally restrict BigTab to columns matching any of the requested patterns.
  if (!is.null(BigTabcols)) {
    allBigTabcols <- c()
    for (i in BigTabcols) {
      allBigTabcols <- append(allBigTabcols,
                              colnames(BigTab)[str_detect(colnames(BigTab), i)])
    }
    BigTab <- BigTab[allBigTabcols]
  }

  ncontrasts <- if (is.null(cfx)) 0 else dim(cfx)[2]
  n.genes    <- dim(matx)[1]

  # Auto-size the PDF to fit a 16:9 PowerPoint slide. Width defaults to the
  # slide width; height scales with gene count at `rows_per_inch` rows per
  # inch (so small gene sets don't stretch into 8in of blank space) but is
  # always capped at the slide height so the PDF fits on one slide.
  if (is.null(wdt)) wdt <- ppt_slide_width
  if (is.null(hgt)) hgt <- min(1.25*ppt_slide_height,
                               1.25*max(ppt_slide_height * 0.35,
                                   n.genes / (rows_per_inch/1.5)))

  # Reorder columns to match the sample annotation.
  mat <- matx[, rownames(annot.col)]

  # Row-wise z-score helper (mean/sd by row, NA-safe).
  scale_rows <- function(x) {
    m <- apply(x, 1, mean, na.rm = TRUE)
    s <- apply(x, 1, sd,   na.rm = TRUE)
    (x - m) / s
  }
  if (isTRUE(scalerows)) mat <- scale_rows(mat)

  # Build the per-contrast statistics table (gene names + formatted lgFCH/p columns).
  # Logic inlined from `doTab()` so v2 has no implicit dependency on that helper;
  # `doTab()` is still exported for other callers / standalone use.
  if (!is.null(cfx)) {
    # Local copies so we don't mutate the caller's matrices.
    fdrsx    <- fdx
    coefsx   <- cfx
    cell_pad <- table_cell_pad_spaces

    # Signed log2-FC -> signed fold-change.
    transformfch <- function(lgfch) sign(lgfch) * (2 ^ abs(lgfch))

    # Pad a number so all entries share a width: leading invisible white "-"
    # reserves space, trailing zeros align decimals.
    padding <- function(x, n) {
      m <- ceiling(log10(abs(x) + .001))
      x <- as.character(x)
      initspace <- n - m
      if (substr(x, 1, 1) != "-") initspace <- initspace + 1
      if (!str_detect(x, "\\.")) x <- paste(x, ".", sep = "")
      while (nchar(x) < n - initspace + 4) x <- paste(x, "0", sep = "")
      initstr <- paste0("<span style='color:white'>",
                        str_c(rep("\\-", initspace), collapse = ""))
      paste(initstr, "</span>", x, sep = "")
    }

    # Pad the gene-symbol column with trailing invisible "-" to a common width.
    adspaceText <- function(x, n) {
      paste0(x,
             "<span style='font-size:10pt;color:black'>",
             " ",
             str_c(rep("\\-", (n - nchar(x))), collapse = ""),
             "</span>",
             "\\:")
    }

    # p-value cuts -> star symbols; trailing white stars keep column width fixed.
    p.cuts.stars <- c(0.001, 0.01, 0.05, 0.1, 1)
    white_star   <- "<span style='font-size:10pt;color:white'>*</span>"
    p.symbols.stars <- c(
      "***",
      paste0("**", white_star,            collapse = ""),
      paste0("*",  white_star, white_star, collapse = ""),
      paste0("+",  white_star, white_star, collapse = ""),
      paste0(white_star, white_star, white_star, collapse = "")
    )

    coefsx[coefsx == 0] <- 1e-10
    fdrsx[]  <- sapply(fdrsx, starmaker,
                       p.levels = p.cuts.stars,
                       symbols  = p.symbols.stars)
    coefsx[] <- sapply(coefsx, transformfch)
    coefsx   <- round(coefsx, 2)

    ss    <- rownames(coefsx)
    maxss <- max(sapply(ss, nchar))
    ss    <- sapply(ss, adspaceText, maxss + 1)

    maxdigits <- ceiling(log10(max(abs(coefsx))))

    # &thinsp; (~1/6 em) keeps cell values from pressing against the column border
    # without being collapsed by gridtext.
    pad <- strrep("&thinsp;", cell_pad)

    Tab <- data.frame(Symbol = ss)
    for (i in seq_len(ncol(coefsx))) {
      Tab[colnames(coefsx)[i]] <- paste0(
        pad,
        paste(sapply(coefsx[, i], padding, maxdigits), fdrsx[, i], sep = ""),
        pad
      )
    }
    rownames(Tab) <- ss
    colnames(Tab) <- c("Symbol", colnames(coefsx))
  } else {
    Tab <- cbind.data.frame(Gene = rownames(matx))
  }

  # Colour ramp: symmetric around zero when scaling rows, data-driven otherwise.
  if (isTRUE(scalerows)) {
    col_fun   <- colorRamp2(c(-rampvalues, 0, rampvalues),
                            c("blue", "white", "red"), space = "sRGB")
    scalename <- "Z-score"
  } else {
    col_fun   <- colorRamp2(c(min(mat) + 1, mean(mat), max(mat) - 1),
                            c("blue", "white", "red"), space = "sRGB")
    scalename <- "log2-expression"
  }

  ht <- ComplexHeatmap::Heatmap(
    mat,
    name              = scalename,
    column_split      = colsplitx,
    column_title_gp   = gpar(fontsize = fnt_size_title, fontface = 2),
    col               = col_fun,
    top_annotation    = column_ha,
    cluster_rows      = TRUE,
    cluster_columns   = FALSE,
    show_row_names    = FALSE,
    show_column_names = ShowColumnNames,
    column_order      = rownames(annot.col),
    use_raster        = TRUE,
    bottom_annotation = bottom_annotation,
    border            = border,
    cell_fun          = cell_fun,
    width             = unit(ncol(mat) * heatmap_column_width_cm, "cm")
  )

  # Leading gene-name column (left of the heatmap), rendered slightly larger/bolder than v1.
  ha_names <- rowAnnotation(
    Gene = anno_text(
      gt_render(Tab[, 1], align_widths = TRUE),
      location = 0, just = "left",
      gp = gpar(
        fill       = "white",
        border     = "white",
        col        = "black",
        fontface   = gene_col_fontface,
        fontsize   = gene_col_fontsize,
        fontfamily = "mono"
      )
    )
  )

  htlist <- ht + ha_names

  # Append one rowAnnotation per contrast (formatted lgFCH + significance stars).
  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {

      # Slim spacer between contrast columns so borders read as distinct boxes.
      column_box <- rowAnnotation(
        x     = anno_empty(),
        width = unit(0.005, "cm")
      )

      thisha <- rowAnnotation(
        x = anno_text(
          gt_render(
            Tab[, i + 1],
            align_widths = FALSE,
            gp = gpar(
              border     = NA,
              box_col    = NA,
              box_lwd    = 0,
              fontface   = table_body_fontface,
              fontsize   = table_body_fontsize,
              fontfamily = "mono"
            )
          ),
          just      = "left",
          show_name = FALSE
        ),
        width = if (!is.null(table_col_width_cm)) unit(table_col_width_cm, "cm") else NULL
      )

      names(thisha) <- paste0("Tab", i)
      htlist <- htlist + column_box + thisha
    }
    # Trailing spacer so the last contrast border is not clipped at the page edge.
    htlist <- htlist + rowAnnotation(x = anno_empty(), width = unit(0.005, "cm"))
  }

  # ---- Draw -----------------------------------------------------------------
  pdf(file = grafname, width = wdt, height = hgt)

  draw(
    htlist,
    padding             = unit(c(8, 8, 12, 12), "mm"),
    column_title        = setname,
    column_title_side   = "bottom",
    heatmap_legend_side = "right",
    gap                 = unit(0.5, "mm")
  )

  # ---- Decorate each contrast column with a bordered, titled header ---------
  if (!is.null(cfx)) {
    for (i in seq_len(ncontrasts)) {
      nm <- paste0("Tab", i)

      decorate_annotation(nm, {
        # The contrast label is stored as e.g. "lgFCH_A.vs.B"; v1 strips the
        # leading 6 chars + "_" and replaces dots with newlines for stacking.
        AnnotationText <- gsub("\\.", "\n", substring(colnames(Tab)[i + 1], 7))

        # 1. Full rectangle around the data column (was top + bottom lines only in v1).
        if (!is.na(table_border_col)) {
          grid.rect(
            x      = unit(0, "npc"),
            y      = unit(0, "npc"),
            width  = unit(1, "npc"),
            height = unit(1, "npc"),
            just   = c("left", "bottom"),
            gp     = gpar(fill = NA,
                          col  = table_border_col,
                          lwd  = table_border_lwd)
          )
        }

        # 2. Title box sitting just above the column with its own border + fill.
        header_y_bottom <- unit(1, "npc") + unit(table_header_pad_mm, "mm")
        header_height   <- unit(table_header_height_mm, "mm")

        grid.rect(
          x      = unit(0, "npc"),
          y      = header_y_bottom,
          width  = unit(1, "npc"),
          height = header_height,
          just   = c("left", "bottom"),
          gp     = gpar(
            fill = if (is.na(table_header_fill)) NA else table_header_fill,
            col  = if (is.na(table_header_border_col)) NA else table_header_border_col,
            lwd  = table_header_border_lwd
          )
        )

        # 3. Title text, vertically centred inside the header box.
        grid.text(
          AnnotationText,
          x    = unit(0.5, "npc"),
          y    = header_y_bottom + 0.5 * header_height,
          just = "centre",
          gp   = gpar(
            fontface   = table_header_fontface,
            fontsize   = table_header_fontsize,
            fontfamily = "mono"
          )
        )
      })
    }
  }

  dev.off()
  invisible(NULL)
}
