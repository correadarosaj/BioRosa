# Imports: dplyr, tidyr, ggplot2, ggrepel, stats, tools, utils
# =============================================================================
# Molecular improvement: gene-level and subject-level evaluation + figures.
#
# The "improvement" of a dysregulated feature (gene or protein) measures how far
# a treatment pushed it back toward the healthy reference. For feature g and
# subject i:
#
#   Regulation_g   = mean(BL.LS)_g - mean(BL.NL)_g     (disease signature,
#                                                        group-level, pooled)
#   Modulation_ig  = POST.LS_ig    - BL.LS_ig          (treatment effect, paired)
#   Improvement_ig = -100 * Modulation_ig / Regulation_g
#
# The leading minus sign makes improvement positive whenever the treatment moves
# a dysregulated feature toward the non-lesional / control level, irrespective of
# whether it was up- or down-dysregulated at baseline. Because improvement is a
# ratio of (approximately) normal log-fold-changes its distribution is
# heavy-tailed (Cauchy), so the MEDIAN is the headline central-tendency metric
# and the median absolute deviation (MAD) quantifies its uncertainty.
#
# The "LS / NL" (lesional / non-lesional) language is just the tissue contrast;
# the same machinery serves a healthy-control design by mapping the tissue axis
# to a group column (disease group = lesional role, control group = nonlesional).
# =============================================================================

# Tidy-eval / aes() column names referenced without .data$ — declared so R CMD
# check does not flag them as undefined globals.
utils::globalVariables(c(
  ".gene", ".value", ".subj", ".visit", ".tiss", ".arm", ".m",
  "Regulation", "Reg.Type", "bl.ls", "post.ls", "Modulation", "Improvement",
  "med", "MAD", "n_inner", "p", "fdr", "uw", "lo", "hi", "ytop",
  "y_pct", "y_star", "pct", "star"
))

# Default treatment colours (override via the `arm_palette` argument).
.IMP_ARM_PALETTE <- c("Drug" = "darkgreen", "Placebo" = "orange",
                      "Active" = "darkgreen", "Control" = "orange",
                      "All" = "grey40")
# Up / Down regulation colours — same convention as the lab heatmaps.
.IMP_REG_COLORS <- c("Down" = "#2166AC", "Up" = "#B2182B")
.IMP_Y_LABEL    <- "Lesional % Improvement to Non-Lesional"

# ------------------------------------------------------------------ internals

# significance stars from a p-value
.imp_pstars <- function(p) as.character(
  cut(p, breaks = c(-Inf, 0.001, 0.01, 0.05, 0.10, Inf),
      labels = c("***", "**", "*", "+", "")))

# pretty visit labels: "W4" -> "Week 4", "D2"/"Day2" -> "Day 2" (data untouched)
.imp_week_label <- function(x) {
  x <- gsub("^W(?=[0-9])", "Week ", x, perl = TRUE)
  x <- gsub("^Day(?=[0-9])", "Day ", x, perl = TRUE)
  gsub("^D(?=[0-9])", "Day ", x, perl = TRUE)
}

# one-sample test that the improvement differs from mu0 (black stars)
.imp_p_onesample <- function(x, mu0 = 0) {
  x <- x[is.finite(x)]
  if (length(x) < 3 || stats::sd(x) == 0) return(NA_real_)
  tryCatch(stats::t.test(x, mu = mu0)$p.value, error = function(e) NA_real_)
}

# two-sample test that arm a differs from arm b (red stars)
.imp_p_twosample <- function(xa, xb) {
  xa <- xa[is.finite(xa)]; xb <- xb[is.finite(xb)]
  if (length(xa) < 3 || length(xb) < 3) return(NA_real_)
  tryCatch(stats::t.test(xa, xb)$p.value, error = function(e) NA_real_)
}

# box envelope [min lower-whisker, max upper-whisker] across grouped boxplots.
# Used to scale the gene-level axis to the boxes, since per-gene improvement is
# Cauchy-distributed and raw extremes (hidden outliers) would crush the boxes.
.imp_box_range <- function(df, keys) {
  s <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(
      lo = { q <- stats::quantile(Improvement, c(.25, .75), na.rm = TRUE)
             max(min(Improvement, na.rm = TRUE), q[[1]] - 1.5 * (q[[2]] - q[[1]])) },
      hi = { q <- stats::quantile(Improvement, c(.25, .75), na.rm = TRUE)
             min(max(Improvement, na.rm = TRUE), q[[2]] + 1.5 * (q[[2]] - q[[1]])) },
      .groups = "drop")
  c(min(s$lo, na.rm = TRUE), max(s$hi, na.rm = TRUE))
}

# horizontal line at the group MEAN (drawn as a zero-height crossbar). Sits on
# top of the box; the box's own middle line remains the median. Drawn THICKER
# than, and SHORTER than (frac < 1), the box's median line.
.imp_mean_line <- function(width, position = "identity", group = NULL,
                           colour = "#E69F00", frac = 0.55, linewidth = 2) {
  ggplot2::stat_summary(
    mapping = if (is.null(group)) NULL
              else ggplot2::aes(group = .data[[group]]),
    fun = mean, fun.min = mean, fun.max = mean, geom = "crossbar",
    width = width * frac, position = position,
    colour = colour, fill = NA, linewidth = linewidth, fatten = 1,
    show.legend = FALSE)
}

# --------------------------------------------------------------- exported API

#' Build the per-subject, per-gene molecular improvement table
#'
#' @description
#' `compute_improvement()` turns a long expression table (one row per
#' Subject x Visit x Tissue x Gene) into a tidy table of per-subject,
#' per-gene improvement values. For each gene it derives the baseline disease
#' signature
#' \deqn{Regulation_g = mean(BL.LS)_g - mean(BL.NL)_g}
#' (pooled across all subjects), and for each subject the paired treatment effect
#' \deqn{Modulation_{ig} = POST.LS_{ig} - BL.LS_{ig},}
#' then combines them into
#' \deqn{Improvement_{ig} = -100 \times Modulation_{ig} / Regulation_g.}
#' Genes are restricted to those dysregulated at baseline, either via an
#' explicit `degs` set (the usual workflow: pull DEGs from a "BigTab") or by an
#' internal fold-change + significance filter on baseline lesional vs
#' non-lesional expression.
#'
#' The lesional / non-lesional contrast is generic: for a healthy-control design
#' set `tissue_col` to the group column, `lesional` to the disease group and
#' `nonlesional` to the control group.
#'
#' @param data Long data frame, one row per Subject x Visit x Tissue x Gene.
#' @param gene_col,value_col,subject_col,visit_col,tissue_col Column names in
#'   `data` holding the gene/protein id, the (log-scale) expression value, the
#'   subject id, the visit, and the tissue/group.
#' @param arm_col Optional treatment-arm column name; `NULL` for a single arm.
#' @param baseline,lesional,nonlesional Level labels: the baseline visit in
#'   `visit_col`, and the lesional (disease) and non-lesional (control) levels in
#'   `tissue_col`.
#' @param genes Optional character vector of genes to restrict to before any
#'   computation (e.g. a pathway / panel).
#' @param degs Optional character vector of pre-computed dysregulated genes. When
#'   supplied the internal significance / fold-change filter is skipped and
#'   exactly these genes are used.
#' @param fc_threshold Fold-change cutoff for the baseline lesional-vs-non-lesional
#'   dysregulation filter (default `1.5`, i.e. `|log2 Regulation| > log2(1.5)`).
#'   Ignored when `degs` is supplied.
#' @param p_cut,use_fdr Significance cutoff on the baseline lesional-vs-non-lesional
#'   t-test; set `use_fdr = TRUE` to threshold on BH-FDR rather than the raw
#'   p-value (default `p_cut = 0.05`). Ignored when `degs` is supplied.
#'
#' @return A list with
#'   \describe{
#'     \item{`improvement`}{tidy data frame, one row per kept subject x gene x
#'       visit x arm, with `Regulation`, `Reg.Type` ("Up"/"Down"), `Modulation`
#'       and `Improvement` (percent).}
#'     \item{`reference`}{per-gene baseline regulation table for the kept genes.}
#'     \item{`n_genes`}{number of dysregulated genes retained.}
#'   }
#' @seealso [aggregate_improvement()], [evaluate_improvement()]
#' @examples
#' df <- expand.grid(SubjectID = paste0("S", 1:4),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = c("G1", "G2"), stringsAsFactors = FALSE)
#' df$Value <- with(df, ifelse(Tissue == "NL", 0,
#'                      ifelse(Visit == "BL", 2, 1)) *
#'                      ifelse(Gene == "G2", -1, 1))
#' ci <- compute_improvement(df, degs = c("G1", "G2"))
#' head(ci$improvement)
#' @export
compute_improvement <- function(
  data,
  gene_col    = "Gene",      value_col = "Value",
  subject_col = "SubjectID", visit_col = "Visit", tissue_col = "Tissue",
  arm_col     = NULL,
  baseline    = "BL",        lesional  = "LS", nonlesional = "NL",
  genes       = NULL,        degs      = NULL,
  fc_threshold = 1.5,        p_cut     = 0.05, use_fdr = FALSE
) {
  need <- c(gene_col, value_col, subject_col, visit_col, tissue_col)
  miss <- setdiff(need, names(data))
  if (length(miss)) stop("Missing columns: ", paste(miss, collapse = ", "))

  d <- data |> dplyr::transmute(
    .gene  = .data[[gene_col]],    .value = .data[[value_col]],
    .subj  = .data[[subject_col]], .visit = .data[[visit_col]],
    .tiss  = .data[[tissue_col]],
    .arm   = if (!is.null(arm_col) && arm_col %in% names(data))
               as.character(.data[[arm_col]]) else "All"
  )
  if (!is.null(genes)) d <- d |> dplyr::filter(.gene %in% genes)

  lreg <- log2(fc_threshold)

  # ---- per-gene disease signature (group-level, pooled across arms) ----------
  bl_long <- d |> dplyr::filter(.visit == baseline,
                                .tiss %in% c(lesional, nonlesional))

  ref <- bl_long |>
    dplyr::group_by(.gene, .tiss) |>
    dplyr::summarise(.m = mean(.value, na.rm = TRUE), .groups = "drop") |>
    tidyr::pivot_wider(names_from = .tiss, values_from = .m) |>
    dplyr::filter(!is.na(.data[[lesional]]), !is.na(.data[[nonlesional]])) |>
    dplyr::mutate(Regulation = .data[[lesional]] - .data[[nonlesional]],
                  Reg.Type   = ifelse(Regulation < 0, "Down", "Up"))

  # significance of lesional vs non-lesional at baseline (skipped when degs given)
  if (is.null(degs)) {
    sig <- bl_long |>
      dplyr::group_by(.gene) |>
      dplyr::summarise(
        p = tryCatch(stats::t.test(.value[.tiss == lesional],
                                   .value[.tiss == nonlesional])$p.value,
                     error = function(e) NA_real_),
        .groups = "drop") |>
      dplyr::mutate(fdr = stats::p.adjust(p, method = "BH"))
    ref  <- ref |> dplyr::left_join(sig, by = ".gene")
    keep <- ref |>
      dplyr::filter(abs(Regulation) > lreg,
                    if (use_fdr) fdr < p_cut else p < p_cut) |>
      dplyr::pull(.gene)
  } else {
    keep <- intersect(degs, ref$.gene)
  }
  ref <- ref |> dplyr::filter(.gene %in% keep)

  # ---- per-subject baseline lesional (paired numerator) ----------------------
  subj_bl <- d |>
    dplyr::filter(.visit == baseline, .tiss == lesional) |>
    dplyr::group_by(.subj, .gene, .arm) |>
    dplyr::summarise(bl.ls = mean(.value, na.rm = TRUE), .groups = "drop")

  # ---- per-subject post-treatment lesional -> improvement --------------------
  improvement <- d |>
    dplyr::filter(.visit != baseline, .tiss == lesional) |>
    dplyr::group_by(.subj, .gene, .visit, .arm) |>
    dplyr::summarise(post.ls = mean(.value, na.rm = TRUE), .groups = "drop") |>
    dplyr::inner_join(dplyr::select(ref, .gene, Regulation, Reg.Type),
                      by = ".gene") |>
    dplyr::inner_join(subj_bl, by = c(".subj", ".gene", ".arm")) |>
    dplyr::mutate(Modulation  = post.ls - bl.ls,
                  Improvement = -100 * Modulation / Regulation) |>
    dplyr::filter(is.finite(Improvement))

  list(improvement = improvement, reference = ref, n_genes = length(keep))
}

#' Collapse the improvement table to gene- or subject-level data points
#'
#' @description
#' Reduces the per-subject, per-gene table from [compute_improvement()] to the
#' unit of analysis used in the figures. At the **subject** level each subject
#' becomes one point (the median improvement across genes); at the **gene** level
#' each gene becomes one point (the median improvement across subjects). The MAD
#' across the collapsed dimension is carried alongside as an uncertainty measure.
#'
#' @param improvement The `improvement` data frame from [compute_improvement()].
#' @param level `"subject"` (median across genes, per subject) or `"gene"`
#'   (median across subjects, per gene).
#' @param by_reg Keep the Up / Down regulation split (`TRUE`) or pool both
#'   directions (`FALSE`, default).
#'
#' @return A data frame with the grouping keys plus `Improvement` (median),
#'   `MAD`, and `n_inner` (number of values collapsed).
#' @seealso [compute_improvement()], [plot_improvement_genes()],
#'   [plot_improvement_subjects()]
#' @examples
#' df <- expand.grid(SubjectID = paste0("S", 1:4),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = c("G1", "G2"), stringsAsFactors = FALSE)
#' df$Value <- with(df, ifelse(Tissue == "NL", 0,
#'                      ifelse(Visit == "BL", 2, 1)) *
#'                      ifelse(Gene == "G2", -1, 1))
#' imp <- compute_improvement(df, degs = c("G1", "G2"))$improvement
#' aggregate_improvement(imp, "subject")
#' @export
aggregate_improvement <- function(improvement, level = c("subject", "gene"),
                                  by_reg = FALSE) {
  level <- match.arg(level)
  unit  <- if (level == "subject") ".subj" else ".gene"
  grp   <- c(unit, ".visit", ".arm", if (by_reg) "Reg.Type")
  # NB: compute median and MAD as separately-named summaries so the second does
  # not read the (already collapsed) first; rename afterwards.
  improvement |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grp))) |>
    dplyr::summarise(med     = stats::median(Improvement, na.rm = TRUE),
                     MAD     = stats::mad(Improvement, na.rm = TRUE),
                     n_inner = dplyr::n(),
                     .groups = "drop") |>
    dplyr::rename(Improvement = med)
}

#' Gene-level improvement boxplot
#'
#' @description
#' Draws a publication-quality boxplot of gene-level improvement (one box
#' summarises many genes). In the **overall** view the treatment arms sit
#' side-by-side with black significance stars (one-sample test that the median
#' improvement differs from `mu0`) and, when a `reference` arm is given, red
#' stars (between-arm test). In the **by-regulation** view the panel is faceted
#' by treatment with Up = red and Down = blue boxes. Each box carries its median
#' percentage and a thick mean line; the axis is scaled to the box whiskers so
#' the Cauchy tails of per-gene improvement do not crush the boxes.
#'
#' @param agg A gene-level aggregate from [aggregate_improvement()].
#' @param by_reg Facet by treatment and split Up / Down (`TRUE`) or pool
#'   directions with arms side-by-side (`FALSE`, default).
#' @param reference Treatment arm used as the comparator for the between-arm
#'   (red) stars in the overall view; `NULL` for none.
#' @param mu0 Null value for the within-group (black-star) test.
#' @param y_label,title Axis title and plot title.
#' @param box_width Box width (a little narrower than the ggplot2 default).
#' @param arm_palette Named colours for the treatment arms (default darkgreen /
#'   orange for Drug / Placebo).
#' @param reg_palette Named colours for Down / Up regulation.
#' @param mean_color Colour of the horizontal mean line; `NULL` resolves to red
#'   on the overall view and white on the by-regulation view.
#' @param week_labels When `TRUE`, relabel `"W4"` as `"Week 4"` on the x-axis
#'   (the underlying data are untouched).
#'
#' @return A [ggplot2::ggplot] object.
#' @seealso [plot_improvement_subjects()], [evaluate_improvement()]
#' @examples
#' \donttest{
#' df <- expand.grid(SubjectID = paste0("S", 1:8),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = paste0("G", 1:10), stringsAsFactors = FALSE)
#' set.seed(1)
#' df$Value <- rnorm(nrow(df)) + ifelse(df$Tissue == "LS" & df$Visit == "BL", 2, 0)
#' imp <- compute_improvement(df, degs = paste0("G", 1:10))$improvement
#' plot_improvement_genes(aggregate_improvement(imp, "gene"))
#' }
#' @export
plot_improvement_genes <- function(
  agg, by_reg = FALSE, reference = NULL, mu0 = 0,
  y_label = .IMP_Y_LABEL, title = NULL, box_width = 0.55,
  arm_palette = .IMP_ARM_PALETTE, reg_palette = .IMP_REG_COLORS,
  mean_color = NULL, week_labels = TRUE
) {
  has_arm <- dplyr::n_distinct(agg$.arm) > 1
  dodge   <- ggplot2::position_dodge(width = 0.85)
  mc      <- if (!is.null(mean_color)) mean_color else if (by_reg) "white" else "red"

  # axis scaled to the boxes (outliers are hidden), not the Cauchy extremes
  keys <- if (by_reg) c(".arm", ".visit", "Reg.Type") else c(".visit", ".arm")
  rng  <- .imp_box_range(agg, keys)
  span <- diff(rng); if (!is.finite(span) || span == 0) span <- 1
  # per-box label offsets above each box's own upper whisker
  off_pct <- 0.05 * span; off_star <- 0.12 * span

  if (!by_reg) {
    # ---- OVERALL: x = visit, fill = arm, dodged --------------------------------
    black <- agg |>
      dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::summarise(
        med = stats::median(Improvement, na.rm = TRUE),
        p   = .imp_p_onesample(Improvement, mu0),
        uw  = { q <- stats::quantile(Improvement, c(.25, .75), na.rm = TRUE)
                min(max(Improvement, na.rm = TRUE), q[[2]] + 1.5 * (q[[2]] - q[[1]])) },
        .groups = "drop") |>
      dplyr::mutate(star = .imp_pstars(p), pct = sprintf("%.1f%%", med),
                    y_pct = uw + off_pct, y_star = uw + off_star)
    red <- NULL
    if (has_arm && !is.null(reference) && reference %in% agg$.arm) {
      other <- setdiff(unique(agg$.arm), reference)[1]
      red <- agg |>
        dplyr::group_by(.visit) |>
        dplyr::summarise(p = .imp_p_twosample(Improvement[.arm == other],
                                              Improvement[.arm == reference]),
                         .groups = "drop") |>
        dplyr::left_join(
          black |> dplyr::group_by(.visit) |>
            dplyr::summarise(y_star = max(y_star) + 0.07 * span, .groups = "drop"),
          by = ".visit") |>
        dplyr::mutate(star = .imp_pstars(p))
    }
    y_hi <- max(black$y_star, red$y_star, na.rm = TRUE) + 0.04 * span
    p <- ggplot2::ggplot(agg, ggplot2::aes(.visit, Improvement,
                                           fill = .arm, color = .arm)) +
      ggplot2::geom_hline(yintercept = mu0, linetype = "dashed", color = "grey60") +
      ggplot2::geom_boxplot(width = box_width, position = dodge,
                            outlier.shape = NA, alpha = 0.35, show.legend = has_arm) +
      .imp_mean_line(width = box_width, position = dodge, group = ".arm", colour = mc) +
      ggplot2::scale_fill_manual(values = arm_palette) +
      ggplot2::scale_color_manual(values = arm_palette) +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_pct, label = pct,
                                      group = .arm, color = .arm),
                         position = dodge, size = 6.5, fontface = "bold",
                         show.legend = FALSE) +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_star, label = star, group = .arm),
                         position = dodge, size = 8, color = "black") +
      ggplot2::coord_cartesian(ylim = c(min(rng[1], 0) - 0.05 * span, y_hi),
                               clip = "off")
    if (!is.null(red))
      p <- p + ggplot2::geom_text(data = red, inherit.aes = FALSE,
                                  ggplot2::aes(.visit, y_star, label = star),
                                  size = 8, color = "red")
  } else {
    # ---- byReg: facet by treatment, fill = Reg.Type (blue/red), no alpha -------
    black <- agg |>
      dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::summarise(
        med = stats::median(Improvement, na.rm = TRUE),
        p   = .imp_p_onesample(Improvement, mu0),
        uw  = { q <- stats::quantile(Improvement, c(.25, .75), na.rm = TRUE)
                min(max(Improvement, na.rm = TRUE), q[[2]] + 1.5 * (q[[2]] - q[[1]])) },
        .groups = "drop") |>
      dplyr::mutate(star = .imp_pstars(p), pct = sprintf("%.1f%%", med),
                    y_pct = uw + off_pct, y_star = uw + off_star)
    y_hi <- max(black$y_star, na.rm = TRUE) + 0.04 * span
    p <- ggplot2::ggplot(agg, ggplot2::aes(.visit, Improvement, fill = Reg.Type)) +
      ggplot2::geom_hline(yintercept = mu0, linetype = "dashed", color = "grey60") +
      ggplot2::geom_boxplot(width = box_width, position = dodge,
                            outlier.shape = NA, alpha = 1) +
      .imp_mean_line(width = box_width, position = dodge, group = "Reg.Type", colour = mc) +
      ggplot2::scale_fill_manual(values = reg_palette) +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_pct, label = pct, group = Reg.Type),
                         position = dodge, size = 5.5, fontface = "bold") +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_star, label = star, group = Reg.Type),
                         position = dodge, size = 7, color = "black") +
      ggplot2::coord_cartesian(ylim = c(min(rng[1], 0) - 0.05 * span, y_hi),
                               clip = "off")
    if (has_arm) p <- p + ggplot2::facet_wrap(~ .arm)  # single-arm -> no facet
  }

  p +
    ggplot2::labs(x = NULL, y = y_label, title = title, fill = NULL, color = NULL) +
    ggplot2::scale_x_discrete(labels = if (week_labels) .imp_week_label
                                       else ggplot2::waiver()) +
    ggplot2::theme_bw(base_size = 15) +
    ggplot2::theme(
      legend.title = ggplot2::element_blank(),
      legend.position = if (by_reg || has_arm) "top" else "none",
      legend.text = ggplot2::element_text(size = 14),
      axis.title.y = ggplot2::element_text(size = 15),
      axis.text.y  = ggplot2::element_text(size = 13),
      axis.text.x  = ggplot2::element_text(size = 18, face = "bold", color = "black"),
      plot.title   = ggplot2::element_text(hjust = 0.5, face = "bold"),
      strip.text   = ggplot2::element_text(size = 15, face = "bold"))
}

#' Subject-level improvement boxplot with labelled subjects
#'
#' @description
#' Draws subject-level improvement with every subject shown as a point labelled
#' by id, so outliers are immediately identifiable (the "per-patient" style).
#' The panel is faceted by treatment (dropped automatically for a single arm).
#' In the **by-regulation** view boxes are solid with Up = red / Down = blue and
#' subjects drawn in dark grey so they stay visible on the fills. Each box
#' carries its median percentage, a thick mean line, and a black significance
#' star (one-sample test vs `mu0`).
#'
#' @inheritParams plot_improvement_genes
#' @param agg A subject-level aggregate from [aggregate_improvement()].
#' @param label When `TRUE` (default), label each subject point with its id via
#'   [ggrepel::geom_text_repel()].
#'
#' @return A [ggplot2::ggplot] object.
#' @seealso [plot_improvement_genes()], [evaluate_improvement()]
#' @examples
#' \donttest{
#' df <- expand.grid(SubjectID = paste0("S", 1:12),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = paste0("G", 1:10), stringsAsFactors = FALSE)
#' set.seed(1)
#' df$Value <- rnorm(nrow(df)) + ifelse(df$Tissue == "LS" & df$Visit == "BL", 2, 0)
#' imp <- compute_improvement(df, degs = paste0("G", 1:10))$improvement
#' plot_improvement_subjects(aggregate_improvement(imp, "subject"))
#' }
#' @export
plot_improvement_subjects <- function(
  agg, by_reg = FALSE, mu0 = 0,
  y_label = .IMP_Y_LABEL, title = NULL, box_width = 0.5, label = TRUE,
  arm_palette = .IMP_ARM_PALETTE, reg_palette = .IMP_REG_COLORS,
  mean_color = NULL, week_labels = TRUE
) {
  mc <- if (!is.null(mean_color)) mean_color else if (by_reg) "white" else "red"
  has_arm <- dplyr::n_distinct(agg$.arm) > 1   # single-arm -> no treatment facet

  rng  <- range(agg$Improvement, na.rm = TRUE)
  span <- diff(rng); if (!is.finite(span) || span == 0) span <- 1
  # subjects: all points are drawn, so place labels above each box's top point
  off_pct <- 0.05 * span; off_star <- 0.12 * span

  base_theme <- ggplot2::theme_bw(base_size = 15) +
    ggplot2::theme(
      legend.position = if (by_reg) "top" else "none",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 14),
      axis.title.y = ggplot2::element_text(size = 15),
      axis.text.y  = ggplot2::element_text(size = 13),
      axis.text.x  = ggplot2::element_text(size = 18, face = "bold", color = "black"),
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      strip.text = ggplot2::element_text(size = 15, face = "bold"))

  if (!by_reg) {
    keys  <- c(".arm", ".visit")
    black <- agg |>
      dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::summarise(med = stats::median(Improvement, na.rm = TRUE),
                       p   = .imp_p_onesample(Improvement, mu0),
                       ytop = max(Improvement, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(star = .imp_pstars(p), pct = sprintf("%.1f%%", med),
                    y_pct = ytop + off_pct, y_star = ytop + off_star)
    p <- ggplot2::ggplot(agg, ggplot2::aes(.visit, Improvement)) +
      ggplot2::geom_hline(yintercept = mu0, linetype = "dashed", color = "grey60") +
      ggplot2::geom_boxplot(ggplot2::aes(fill = .arm), width = box_width,
                            outlier.shape = NA, alpha = 0.25, show.legend = FALSE) +
      ggplot2::geom_point(size = 1.8, color = "grey25") +
      .imp_mean_line(width = box_width, colour = mc) +
      ggplot2::scale_fill_manual(values = arm_palette) +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_pct, label = pct),
                         size = 6.5, fontface = "bold") +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_star, label = star),
                         size = 8, color = "black")
    if (label)
      p <- p + ggrepel::geom_text_repel(ggplot2::aes(label = .subj), size = 3.0,
                                        fontface = "bold", max.overlaps = 100,
                                        segment.size = 0.2, box.padding = 0.25)
  } else {
    keys  <- c(".arm", ".visit", "Reg.Type")
    dodge <- ggplot2::position_dodge(width = 0.85)
    black <- agg |>
      dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::summarise(med = stats::median(Improvement, na.rm = TRUE),
                       p   = .imp_p_onesample(Improvement, mu0),
                       ytop = max(Improvement, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(star = .imp_pstars(p), pct = sprintf("%.1f%%", med),
                    y_pct = ytop + off_pct, y_star = ytop + off_star)
    # solid (no transparency) boxes -> draw subject points in dark grey so they
    # remain visible on top of the blue / red fills.
    p <- ggplot2::ggplot(agg, ggplot2::aes(.visit, Improvement, fill = Reg.Type)) +
      ggplot2::geom_hline(yintercept = mu0, linetype = "dashed", color = "grey60") +
      ggplot2::geom_boxplot(width = box_width, position = dodge,
                            outlier.shape = NA, alpha = 1) +
      ggplot2::geom_point(ggplot2::aes(group = Reg.Type), position = dodge,
                          size = 1.6, color = "grey15", show.legend = FALSE) +
      .imp_mean_line(width = box_width, position = dodge, group = "Reg.Type", colour = mc) +
      ggplot2::scale_fill_manual(values = reg_palette) +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_pct, label = pct, group = Reg.Type),
                         position = dodge, size = 5.2, fontface = "bold") +
      ggplot2::geom_text(data = black, inherit.aes = FALSE,
                         ggplot2::aes(.visit, y_star, label = star, group = Reg.Type),
                         position = dodge, size = 7, color = "black")
    if (label)
      p <- p + ggrepel::geom_text_repel(
        ggplot2::aes(label = .subj, group = Reg.Type),
        position = ggplot2::position_dodge(width = 0.85),
        size = 2.7, max.overlaps = 100, color = "grey15",
        segment.size = 0.2, show.legend = FALSE)
  }

  if (has_arm) p <- p + ggplot2::facet_wrap(~ .arm)
  y_hi <- max(black$y_star, na.rm = TRUE) + 0.04 * span
  p +
    ggplot2::coord_cartesian(ylim = c(min(rng[1], 0) - 0.05 * span, y_hi),
                             clip = "off") +
    ggplot2::labs(x = NULL, y = y_label, title = title, fill = NULL, color = NULL) +
    ggplot2::scale_x_discrete(labels = if (week_labels) .imp_week_label
                                       else ggplot2::waiver()) +
    base_theme
}

#' Evaluate molecular improvement and build the four figures
#'
#' @description
#' One-call pipeline that runs [compute_improvement()], collapses the result to
#' both the gene and subject level with [aggregate_improvement()], and renders
#' the four standard figures via [plot_improvement_genes()] and
#' [plot_improvement_subjects()]: gene/subject x overall/by-regulation. When
#' `outdir` is given the figures are also written as PDFs.
#'
#' @inheritParams compute_improvement
#' @param ... Additional arguments passed to [compute_improvement()] (e.g.
#'   `gene_col`, `tissue_col`, `lesional`, `nonlesional`, `degs`,
#'   `fc_threshold`).
#' @param reference Treatment arm used as the comparator for the between-arm
#'   (red) stars in the gene-level overall figure (e.g. `"Placebo"`); `NULL`
#'   for none.
#' @param mu0 Null value for the within-group (black-star) significance test.
#' @param y_label Y-axis title. Defaults to
#'   `"Lesional % Improvement to Non-Lesional"`; use a control-based wording when
#'   `nonlesional` is a control group.
#' @param arm_palette,reg_palette Named colour vectors for the treatment arms and
#'   the Down / Up regulation classes.
#' @param week_labels When `TRUE`, relabel `"W4"` as `"Week 4"` on the x-axis.
#' @param signature_name Label used in plot titles and output file names.
#' @param outdir If not `NULL`, a directory to write the four PDFs into (created
#'   if needed).
#'
#' @return A list with
#'   \describe{
#'     \item{`improvement`}{the per-subject, per-gene table.}
#'     \item{`reference`}{the per-gene regulation table.}
#'     \item{`summary`}{the four aggregates (gene/subject x overall/byReg).}
#'     \item{`plots`}{the four [ggplot2::ggplot] objects named `gene_overall`,
#'       `gene_byReg`, `subject_overall`, `subject_byReg`.}
#'   }
#' @seealso [compute_improvement()], [aggregate_improvement()],
#'   [plot_improvement_genes()], [plot_improvement_subjects()]
#' @examples
#' \donttest{
#' set.seed(1)
#' subj <- paste0("S", 1:12)
#' df <- expand.grid(SubjectID = subj, Visit = c("BL", "W4", "W16"),
#'                   Tissue = c("LS", "NL"), Gene = paste0("G", 1:20),
#'                   stringsAsFactors = FALSE)
#' df$Value <- rnorm(nrow(df), 0, 0.3) +
#'   ifelse(df$Tissue == "LS" & df$Visit == "BL", 2,
#'   ifelse(df$Tissue == "LS" & df$Visit == "W4", 1.2,
#'   ifelse(df$Tissue == "LS" & df$Visit == "W16", 0.6, 0)))
#' df$Visit <- factor(df$Visit, levels = c("BL", "W4", "W16"))
#' res <- evaluate_improvement(df, degs = paste0("G", 1:20),
#'                             signature_name = "Demo")
#' res$plots$subject_overall
#' }
#' @export
evaluate_improvement <- function(
  data, ...,
  arm_col = NULL, reference = NULL, mu0 = 0,
  y_label = .IMP_Y_LABEL,
  arm_palette = .IMP_ARM_PALETTE, reg_palette = .IMP_REG_COLORS,
  week_labels = TRUE,
  signature_name = "Transcriptome", outdir = NULL
) {
  ci  <- compute_improvement(data, arm_col = arm_col, ...)
  imp <- ci$improvement
  if (!nrow(imp))
    stop("No genes passed the dysregulation filter; relax fc_threshold/p_cut ",
         "or pass `genes`/`degs` explicitly.")
  message(sprintf("Using %d dysregulated genes.", ci$n_genes))

  ttl <- function(level, by_reg)
    sprintf("%s - %s improvement%s", signature_name, tools::toTitleCase(level),
            if (by_reg) " by regulation" else " (overall)")

  go_agg <- aggregate_improvement(imp, "gene",    FALSE)
  gr_agg <- aggregate_improvement(imp, "gene",    TRUE)
  so_agg <- aggregate_improvement(imp, "subject", FALSE)
  sr_agg <- aggregate_improvement(imp, "subject", TRUE)

  plots <- list(
    gene_overall    = plot_improvement_genes(go_agg, FALSE, reference, mu0,
                       y_label, ttl("gene", FALSE), arm_palette = arm_palette,
                       reg_palette = reg_palette, week_labels = week_labels),
    gene_byReg      = plot_improvement_genes(gr_agg, TRUE,  reference, mu0,
                       y_label, ttl("gene", TRUE), arm_palette = arm_palette,
                       reg_palette = reg_palette, week_labels = week_labels),
    subject_overall = plot_improvement_subjects(so_agg, FALSE, mu0,
                       y_label, ttl("subject", FALSE), arm_palette = arm_palette,
                       reg_palette = reg_palette, week_labels = week_labels),
    subject_byReg   = plot_improvement_subjects(sr_agg, TRUE,  mu0,
                       y_label, ttl("subject", TRUE), arm_palette = arm_palette,
                       reg_palette = reg_palette, week_labels = week_labels)
  )

  if (!is.null(outdir)) {
    dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
    sfx <- gsub("[^A-Za-z0-9]+", "_", signature_name)
    for (nm in names(plots)) {
      wide <- grepl("byReg|subject", nm)
      ggplot2::ggsave(
        file.path(outdir, sprintf("Improvement_%s_%s.pdf", sfx, nm)),
        plots[[nm]], width = if (wide) 12 else 7.5, height = if (wide) 6.5 else 5.5)
    }
    message("Wrote ", length(plots), " PDFs to ", outdir)
  }

  list(
    improvement = imp,
    reference   = ci$reference,
    summary     = list(gene_overall = go_agg, gene_byReg = gr_agg,
                       subject_overall = so_agg, subject_byReg = sr_agg),
    plots       = plots
  )
}
