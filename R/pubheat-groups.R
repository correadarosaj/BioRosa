# pubheat-groups.R -----------------------------------------------------------
# Grouping, colour and matrix helpers shared by the publication heatmaps.
# ----------------------------------------------------------------------------

#' Contiguous runs of a grouping vector, for `anno_block(align_to = )`
#'
#' @description
#' Splits a grouping vector into the index sets `ComplexHeatmap::anno_block()`
#' expects. The improvement over the older [leveler()] is that this is
#' run-length based: it returns one entry per contiguous *run*, not one per
#' distinct level.
#'
#' @details
#' `which(f == level)` -- the obvious implementation -- returns a scattered
#' index set for any level that appears in more than one place, and
#' `anno_block()` then draws a single block spanning everything between its
#' first and last column. The figure is silently mislabelled. Run-length
#' encoding gives one box per run, which is also exactly right for nested
#' designs where a level legitimately recurs (Tissue inside Group).
#'
#' Because nesting is legitimate, repetition alone is not warned about. Many
#' more runs than levels is a different matter -- it means the annotation was
#' never sorted, and produces a forest of one-column boxes -- so that warns.
#'
#' @param fact Grouping vector in column order (factor or character).
#'
#' @return A named list of integer index vectors, one per contiguous run, named
#'   by the level of that run. Names may repeat in a nested design.
#' @seealso [ph_block()], [leveler()] for the original non-run-length version.
#' @examples
#' ph_leveler(c("Control", "Control", "Case", "Case", "Case"))
#' @export
ph_leveler <- function(fact) {
  f <- as.character(fact)
  r <- rle(f)
  idx <- split(seq_along(f), rep(seq_along(r$lengths), r$lengths))
  names(idx) <- r$values
  # A level legitimately recurs when blocks are nested (Tissue inside Group), so
  # repetition alone is not an error. Many more runs than levels, though, means
  # the annotation was never sorted -- that produces a forest of one-column
  # boxes, which is worth flagging.
  if (length(r$values) > 2 * length(unique(f)) && length(r$values) > 4)
    warning("'", deparse(substitute(fact)), "' breaks into ",
            length(r$values), " runs over ", length(unique(f)),
            " levels -- sort the annotation by its block variables first.", call. = FALSE)
  idx
}

#' Default annotation fills for common lab groupings
#'
#' @description
#' Supplies a fill colour per level, using built-in defaults for the groupings
#' this toolkit is used for -- tissue (`LS`/`NL`), response (`R`/`NR`),
#' treatment (`Drug`/`Pbo`), visit (`Pre`/`Post`), `Control` -- and an evenly
#' spaced pastel HCL fallback for anything unrecognised, so a novel grouping
#' still gets distinct, legible bands.
#'
#' Any level whose name contains `"vs"` gets the neutral comparison purple.
#' All defaults are deliberately light so black text sits on top of them;
#' [ph_contrast_col()] handles the cases where a caller overrides with
#' something dark.
#'
#' @param levels Levels needing colours (duplicates are dropped).
#' @param override Optional named colour vector; entries matching a level win
#'   over the default. This is the customisable-colour hook used by the
#'   `block_colors` arguments of the `do*Heatmap()` functions.
#'
#' @return A named character vector of colours, one per unique level, in the
#'   order the levels first appear.
#' @seealso [ph_block()], [ph_contrast_col()]
#' @examples
#' ph_palette(c("Control", "NoRash", "Rash"))
#' ph_palette(c("Control", "Rash"), override = c(Rash = "#D4645A"))
#' @export
ph_palette <- function(levels, override = NULL) {
  levels <- unique(as.character(levels))
  known <- c(
    Control = "#D9D9D9", HC = "#D9D9D9", Healthy = "#D9D9D9", Normal = "#D9D9D9",
    NL = "#CDE0F0", Nonlesional = "#CDE0F0", LS = "#F6C9C0", Lesional = "#F6C9C0",
    R = "#CDE7D0", Responder = "#CDE7D0", NR = "#F9D9B7", N = "#F9D9B7",
    NonResponder = "#F9D9B7", Nonresponder = "#F9D9B7",
    Drug = "#F4C7C3", Active = "#F4C7C3", Pbo = "#C9DAF0", Placebo = "#C9DAF0",
    Pre = "#E6E6E6", BL = "#E6E6E6", Baseline = "#E6E6E6", Post = "#C9DAF0",
    Rash = "#F6C9C0", NoRash = "#CDE0F0", NoRash. = "#CDE0F0"
  )
  pal <- known[levels]
  na <- is.na(pal)
  cmp <- na & grepl("vs", levels, ignore.case = TRUE)
  if (any(cmp)) { pal[cmp] <- "#E2D6EF"; na <- is.na(pal) }
  if (any(na))
    pal[na] <- grDevices::hcl(h = seq(20, 360, length.out = sum(na) + 1)[-1], c = 32, l = 88)
  pal <- stats::setNames(unname(pal), levels)
  if (!is.null(override)) {
    hit <- intersect(names(override), levels)
    pal[hit] <- override[hit]
  }
  pal
}

#' Per-group means, one column per level
#'
#' @description
#' Collapses a feature-by-sample matrix to a feature-by-group matrix of means,
#' replacing the usual melt / join / summarise / dcast idiom with a single call.
#' The group sizes come back attached, because a mean column is not
#' interpretable without its n.
#'
#' @param mat Numeric matrix (or data frame), features x samples.
#' @param groups Group membership, one entry per column of `mat`.
#' @param levels Optional level order for the output columns. Defaults to the
#'   factor levels of `groups`, or first appearance for a character vector.
#'   Levels not present in `groups` are dropped.
#'
#' @return A numeric matrix, features x groups, carrying an integer `"n"`
#'   attribute of per-group sample counts.
#' @seealso [doGroupMeanHeatmap()], which calls this and labels the result.
#' @examples
#' m <- matrix(1:12, nrow = 3, dimnames = list(c("A", "B", "C"), NULL))
#' mm <- ph_group_means(m, groups = c("x", "x", "y", "y"))
#' attr(mm, "n")
#' @export
ph_group_means <- function(mat, groups, levels = NULL) {
  mat <- as.matrix(mat)
  g <- as.character(groups)
  if (is.null(levels)) levels <- if (is.factor(groups)) levels(droplevels(groups)) else unique(g)
  levels <- levels[levels %in% g]
  out <- vapply(levels, function(L) rowMeans(mat[, g == L, drop = FALSE], na.rm = TRUE),
                numeric(nrow(mat)))
  out <- matrix(out, nrow = nrow(mat), dimnames = list(rownames(mat), levels))
  attr(out, "n") <- stats::setNames(as.integer(table(factor(g, levels = levels))), levels)
  out
}

#' Row Z-score, dropping features with no variance to score
#'
#' @description
#' Centres and scales each row. Features whose standard deviation is zero (or
#' non-finite) are removed rather than divided by zero.
#'
#' @details
#' A constant row scores as `NaN` and paints as an unfilled stripe the reader
#' cannot distinguish from missing data -- a silent lie in the middle of the
#' figure. Dropping the row and saying which ones went is the honest handling.
#' This most often catches genes with zero counts across every sample in the
#' selected subset.
#'
#' @param x Numeric matrix (or data frame), features x samples.
#' @param verbose Report how many features were dropped, and name the first few.
#'
#' @return The row-Z-scored matrix, possibly with fewer rows than `x`.
#' @examples
#' m <- rbind(varies = c(1, 2, 3), flat = c(5, 5, 5))
#' ph_zscore(m, verbose = FALSE)
#' @export
ph_zscore <- function(x, verbose = TRUE) {
  x <- as.matrix(x)
  s <- apply(x, 1, stats::sd, na.rm = TRUE)
  bad <- !is.finite(s) | s < 1e-12
  if (any(bad)) {
    if (verbose)
      message("dropped ", sum(bad), " zero-variance feature(s): ",
              paste(utils::head(rownames(x)[bad], 6), collapse = ", "))
    x <- x[!bad, , drop = FALSE]; s <- s[!bad]
  }
  (x - rowMeans(x, na.rm = TRUE)) / s
}
