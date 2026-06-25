#' Enrichment dotplot (OpenXGR format)
#'
#' Reproduces the OpenXGR enrichment dotplot: each enriched term is a dot
#' positioned by enrichment z-score (x) and significance `-log10(FDR)` (y), with
#' dot size proportional to the number of overlapping genes. Dots that pass the
#' FDR cut-off are drawn in the "significant" colour (dark green by default,
#' matching OpenXGR's `c("#95c11f", "#026634")`), and the top terms (by FDR) are
#' labelled.
#'
#' @param obj an `eSET` from [oSEA()], or a data frame as returned by
#'   [oSEAextract()] (must contain `zscore`, `adjp`, `nO`, `name`).
#' @param FDR.cutoff significance threshold for colouring. Default `0.05`.
#' @param label.top number of top terms (smallest FDR) to label. Default `5`.
#' @param colors length-2 vector `c(non-significant, significant)`. Default
#'   `c("#95c11f", "#026634")` as used by OpenXGR.
#' @param size.range dot size range. Default `c(0.5, 3.5)`.
#' @param size.title legend title for dot size. Default `"Number of genes"`.
#' @param label.direction.y one of `"none"`, `"left"`, `"right"`; nudges labels.
#' @param label.size text size for labels. Default `2`.
#' @return A `ggplot` object.
#' @examples
#' \dontrun{
#' data("guttman_pathways", package = "BioRosa")
#' sets <- guttman_pathways[lengths(guttman_pathways) > 0]
#' eset <- oSEA(sets[["Immune Genes (EG)"]], sets, min.overlap = 2,
#'              size.range = c(3, 5000))
#' oSEAdotplot(eset)
#' }
#' @export
oSEAdotplot <- function(obj, FDR.cutoff = 0.05, label.top = 5,
                        colors = c("#95c11f", "#026634"),
                        size.range = c(0.5, 3.5),
                        size.title = "Number of genes",
                        label.direction.y = c("none", "left", "right"),
                        label.size = 2) {
  label.direction.y <- match.arg(label.direction.y)
  df <- .rxgr_as_df(obj)
  if (nrow(df) == 0L) stop("No enriched terms to plot.")

  df$logFDR <- -log10(df$adjp)
  df$flag <- ifelse(df$adjp < FDR.cutoff, "Y", "N")
  names(colors) <- c("N", "Y")

  # Top terms to label (by FDR ascending)
  ord <- order(df$adjp)
  lab_idx <- utils::head(ord, label.top)
  df$label <- ""
  df$label[lab_idx] <- as.character(df$name[lab_idx])

  nudge_y <- switch(label.direction.y, none = 0,
                    left = 0, right = 0)

  flag <- logFDR <- nO <- label <- NULL  # appease R CMD check
  gp <- ggplot2::ggplot(df, ggplot2::aes(x = .data$zscore, y = .data$logFDR)) +
    ggplot2::geom_point(ggplot2::aes(size = .data$nO, colour = .data$flag)) +
    ggplot2::scale_colour_manual(values = colors, guide = "none") +
    ggplot2::scale_size_continuous(range = size.range, name = size.title) +
    ggplot2::geom_hline(yintercept = -log10(FDR.cutoff), linetype = "dashed",
                        colour = "grey60") +
    ggrepel::geom_text_repel(
      ggplot2::aes(label = .data$label), size = label.size,
      box.padding = 0.5, max.overlaps = Inf, min.segment.length = 0,
      segment.color = "grey50", colour = "black",
      nudge_x = if (label.direction.y == "left") -0.5 else if (label.direction.y == "right") 0.5 else 0
    ) +
    ggplot2::labs(x = "Enrichment z-score", y = expression(-log[10]("FDR"))) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "right"
    )
  gp
}

# Coerce eSET or extracted data frame to a plotting data frame with list/str
# overlap normalised away.
.rxgr_as_df <- function(obj) {
  if (inherits(obj, "eSET")) {
    df <- obj$info
  } else if (is.data.frame(obj)) {
    df <- obj
  } else {
    stop("`obj` must be an eSET or a data frame from oSEAextract().")
  }
  need <- c("zscore", "adjp", "nO", "name", "or", "CIl", "CIu")
  miss <- setdiff(intersect(need, c("zscore", "adjp", "nO", "name")), names(df))
  if (length(miss)) stop("Input is missing required column(s): ", paste(miss, collapse = ", "))
  df
}
