#' Enrichment forest plot (OpenXGR format)
#'
#' Reproduces the OpenXGR enrichment forest plot exactly. Each enriched term is
#' drawn as a diamond on the `log2(odds ratio)` axis with a horizontal range
#' giving the 95% confidence interval (`log2(CIl)`..`log2(CIu)`). Diamonds are
#' coloured by significance `-log10(FDR)` using the `spectral.top` colour map
#' (light yellow -> red) and sized by the number of overlapping genes. Terms are
#' ordered by odds ratio (highest at the top) and, when more than one namespace
#' is present, faceted by namespace. The styling (`theme_classic`, small fonts,
#' vertically stacked legends with point-size above the colour bar) mirrors the
#' original `oSEAforest()`.
#'
#' @param obj an `eSET` from [oSEA()], or a data frame from [oSEAextract()]
#'   (must contain `name`, `adjp`, `or`, `CIl`, `CIu`; `nO` and `namespace` are
#'   used when present).
#' @param top keep the top-N terms by odds ratio within each namespace (after
#'   filtering to `adjp < adjp.cutoff`). Default `10`.
#' @param adjp.cutoff FDR threshold for inclusion. Default `0.05`.
#' @param colormap colour map name passed to [oColormap()]. Default
#'   `"spectral.top"` (as used by OpenXGR).
#' @param color.title legend title for the colour scale. Default
#'   `expression(-log[10]("FDR"))`.
#' @param zlim length-2 numeric limits for the colour scale, or `NULL` to take
#'   `c(0, ceiling(max(-log10(adjp))))`. Values outside are clamped.
#' @param shape plotting shape. Default `18` (filled diamond).
#' @param size.range point-size range. Default `c(0, 1)` (matching OpenXGR).
#' @param slim length-2 size limits, or `NULL` to take
#'   `c(0, ceiling(max(nO)))`. Values outside are clamped.
#' @param size.title legend title for point size. Default `"Number\nof genes"`.
#' @param wrap.width wrap term labels to this width (characters), collapsing to
#'   the first line plus "..." when wrapped, or `NULL` to leave labels intact.
#'   Default `50`.
#' @param legend.direction `"vertical"` (default), `"horizontal"`, or `"auto"`.
#' @param sortBy `"or"` (default) to order terms by odds ratio, or `"none"`.
#' @return A `ggplot` object (or `NULL` if no term passes the filters).
#' @examples
#' \dontrun{
#' data("guttman_pathways", package = "BioRosa")
#' sets <- guttman_pathways[lengths(guttman_pathways) > 0]
#' eset <- oSEA(sets[["Immune Genes (EG)"]], sets, min.overlap = 2,
#'              size.range = c(3, 5000))
#' oSEAforest(eset)
#' }
#' @export
oSEAforest <- function(obj, top = 10, adjp.cutoff = 0.05,
                       colormap = "spectral.top",
                       color.title = expression(-log[10]("FDR")),
                       zlim = NULL, shape = 18, size.range = c(0, 1), slim = NULL,
                       size.title = "Number\nof genes", wrap.width = 50,
                       legend.direction = c("vertical", "horizontal", "auto"),
                       sortBy = c("or", "none")) {
  legend.direction <- match.arg(legend.direction)
  sortBy <- match.arg(sortBy)

  df <- .rxgr_as_df(obj)
  if (!all(c("name", "adjp", "or", "CIl", "CIu") %in% names(df))) {
    stop("Forest plot requires columns name/adjp/or/CIl/CIu.")
  }
  if (!"nO" %in% names(df)) df$nO <- 1L
  if (!"namespace" %in% names(df)) df$namespace <- "namespace"
  df$namespace[is.na(df$namespace)] <- "namespace"
  df$name <- as.character(df$name)

  # drop non-finite/non-positive odds ratios or CIs (cannot be log2'd)
  df <- df[is.finite(df$or) & df$or > 0 & is.finite(df$CIl) & df$CIl > 0 &
             is.finite(df$CIu) & df$CIu > 0, , drop = FALSE]

  # top-N by odds ratio within each namespace
  if (is.numeric(top) && nrow(df) > 0L) {
    top <- as.integer(top)
    keep <- unlist(lapply(split(seq_len(nrow(df)), df$namespace), function(idx) {
      idx[order(-df$or[idx])][seq_len(min(top, length(idx)))]
    }), use.names = FALSE)
    df <- df[sort(keep), , drop = FALSE]
  }

  # filter on significance
  df <- df[df$adjp < adjp.cutoff, , drop = FALSE]
  if (nrow(df) == 0L) {
    warning("No enriched terms pass adjp.cutoff for the forest plot.")
    return(NULL)
  }

  # label wrapping: first line + "..." when wrapped (matches the original)
  if (!is.null(wrap.width)) {
    w <- as.integer(wrap.width)
    df$name <- vapply(df$name, function(x) {
      x <- gsub("_", " ", x)
      y <- strwrap(x, width = w)
      if (length(y) > 1) paste0(y[1], "...") else y
    }, character(1))
  }

  # order terms: ascending odds ratio so the highest sits at the top of the y-axis
  if (sortBy == "or") {
    ord <- order(df$namespace, df$or, df$name)
  } else {
    ord <- order(df$namespace, rev(df$name))
  }
  df <- df[ord, , drop = FALSE]
  df$name <- factor(df$name, levels = unique(df$name))

  # colour = -log10(FDR), clamped to zlim
  df$color <- -log10(df$adjp)
  if (is.null(zlim)) {
    z <- df$color[!is.infinite(df$color)]
    zlim <- c(0, ceiling(max(z, na.rm = TRUE)))
  }
  df$color[df$color <= zlim[1]] <- zlim[1]
  df$color[df$color >= zlim[2]] <- zlim[2]

  # size = number of overlapping genes, clamped to slim
  df$size <- df$nO
  if (is.null(slim)) {
    s <- df$size[!is.infinite(df$size)]
    slim <- c(0, ceiling(max(s, na.rm = TRUE)))
  }
  df$size[df$size <= slim[1]] <- slim[1]
  df$size[df$size >= slim[2]] <- slim[2]

  gp <- ggplot2::ggplot(df, ggplot2::aes(y = .data$name, x = log2(.data$or),
                                         xmin = log2(.data$CIl),
                                         xmax = log2(.data$CIu),
                                         color = .data$color)) +
    ggplot2::geom_pointrange(ggplot2::aes(size = .data$size), shape = shape) +
    ggplot2::xlab(expression(log[2]("odds ratio"))) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      legend.position = "right",
      legend.title = ggplot2::element_text(size = 7),
      legend.text = ggplot2::element_text(size = 6),
      axis.title.y = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_text(size = 7),
      axis.text.y = ggplot2::element_text(size = 6, angle = 0),
      axis.text.x = ggplot2::element_text(size = 7),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )

  if (legend.direction == "auto") {
    legend.direction <- if (nlevels(df$name) <= 15) "horizontal" else "vertical"
  }
  one_size <- length(unique(df$size)) == 1L

  if (legend.direction == "vertical") {
    gp <- gp +
      ggplot2::scale_colour_gradientn(
        colours = oColormap(colormap)(64), limits = zlim,
        guide = ggplot2::guide_colorbar(title = color.title,
                                        title.position = "top", order = 2)) +
      ggplot2::scale_size_continuous(
        limits = slim, range = size.range,
        guide = ggplot2::guide_legend(title = size.title,
                                      title.position = "top", ncol = 1, order = 1))
  } else {
    gp <- gp +
      ggplot2::scale_colour_gradientn(
        colours = oColormap(colormap)(64), limits = zlim,
        guide = ggplot2::guide_colorbar(title = color.title,
                                        title.position = "top",
                                        direction = "horizontal", order = 2)) +
      ggplot2::scale_size_continuous(
        limits = slim, range = size.range,
        guide = ggplot2::guide_legend(title = size.title, title.position = "top",
                                      ncol = 3, byrow = TRUE, order = 1))
  }
  if (one_size) gp <- gp + ggplot2::guides(size = "none")

  # facet by namespace when more than one is present
  if (length(unique(df$namespace)) > 1L) {
    gp <- gp + ggplot2::facet_grid(namespace ~ ., scales = "free_y", space = "free_y") +
      ggplot2::theme(
        strip.placement = "outside",
        strip.background = ggplot2::element_rect(fill = "transparent", color = "grey80"),
        strip.text.y = ggplot2::element_text(size = 7, face = "italic", angle = 0, hjust = 0)
      )
  }

  gp
}
