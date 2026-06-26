# Imports: dplyr, ggplot2, ggh4x, stats, utils
# =============================================================================
# Molecular NORMALIZATION boxplots: how far the lesional signature sits from a
# healthy reference at each visit, and how it returns toward it under treatment.
#
# Companion to the improvement functions (see improvement.R). For gene g, visit
# v and arm a, the group-level log-fold change against a FIXED healthy reference
# (the same reference subtracted at every visit):
#
#   logFC_{g,v,a} = mean(LS_{g,v,a}) - reference_g
#
#   reference_g = mean baseline NON-LESIONAL   -> "towards non-lesional"
#                 mean HEALTHY CONTROL group    -> "towards healthy controls"
#
# At baseline this equals the disease regulation (LS vs reference); as treatment
# works the boxes shrink toward 0 = normalization. The Up/Down split is the
# baseline regulation direction. Improvement reports a percent return toward
# health; normalization keeps the raw logFC so the absolute distance is shown.
# =============================================================================

# Tidy-eval / aes() names referenced without .data$ — declared so R CMD check
# does not flag them as undefined globals.
utils::globalVariables(c(
  ".gene", ".value", ".subj", ".visit", ".tiss", ".arm", ".ls",
  "reference", "bl.ls", "Regulation", "Reg.Type", "logFC", "p", "fdr"
))

# Regulation fill colours (Down = blue, Up = red) and treatment strip colours,
# matching the APG777 deliverable figures.
.NORM_REG_COLORS <- c("Down" = "blue", "Up" = "red")
.NORM_ARM_STRIP  <- c("Drug" = "darkgreen", "Placebo" = "darkorange",
                      "Active" = "darkgreen", "Control" = "darkorange",
                      "All" = "grey30")

# pretty visit labels: "W4" -> "Week 4", "D2"/"Day2" -> "Day 2" (data untouched)
.norm_week_label <- function(x) {
  x <- gsub("^W(?=[0-9])", "Week ", x, perl = TRUE)
  x <- gsub("^Day(?=[0-9])", "Day ", x, perl = TRUE)
  gsub("^D(?=[0-9])", "Day ", x, perl = TRUE)
}

# --------------------------------------------------------------- exported API

#' Build the per-gene, per-visit molecular normalization table
#'
#' @description
#' `compute_normalization()` turns a long expression table (one row per
#' Subject x Visit x Tissue x Gene) into the group-level log-fold change of
#' lesional tissue against a fixed healthy reference, at every visit:
#' \deqn{logFC_{g,v,a} = mean(LS_{g,v,a}) - reference_g.}
#' The reference is computed once (the baseline mean of the `reference` level,
#' pooled across arms) and subtracted at every visit, so the baseline column
#' reproduces the disease regulation and later visits show the return toward 0.
#' Set `reference = "NL"` to normalize toward non-lesional skin, or to a control
#' group level (e.g. `"HC"` / `"Control"`) to normalize toward healthy controls.
#'
#' Genes are restricted to those dysregulated at baseline, either via an explicit
#' `degs` set or by an internal fold-change + significance filter on baseline
#' lesional vs reference.
#'
#' @param data Long data frame, one row per Subject x Visit x Tissue x Gene.
#' @param gene_col,value_col,subject_col,visit_col,tissue_col Column names in
#'   `data` holding the gene/protein id, the (log-scale) expression value, the
#'   subject id, the visit, and the tissue/group.
#' @param arm_col Optional treatment-arm column name; `NULL` for a single arm.
#' @param baseline,lesional Level labels for the baseline visit and the lesional
#'   (disease) tissue.
#' @param reference The tissue/group level to normalize toward, e.g. `"NL"`
#'   (non-lesional) or `"HC"` / `"Control"` (healthy controls).
#' @param visit_levels Optional ordering of the visits on the x-axis (baseline
#'   first). Defaults to the sorted unique visits with `baseline` moved first.
#' @param genes Optional character vector to restrict to before computation.
#' @param degs Optional character vector of pre-computed dysregulated genes;
#'   skips the internal baseline significance / fold-change filter.
#' @param fc_threshold Fold-change cutoff for the baseline lesional-vs-reference
#'   dysregulation filter (default `1.5`). Ignored when `degs` is supplied.
#' @param p_cut,use_fdr Significance cutoff on the baseline lesional-vs-reference
#'   t-test; set `use_fdr = TRUE` to threshold on BH-FDR (default `p_cut = 0.05`).
#'   Ignored when `degs` is supplied.
#'
#' @return A list with
#'   \describe{
#'     \item{`normalization`}{tidy data frame, one row per kept gene x visit x
#'       arm, with the `reference` value, `Reg.Type` ("Up"/"Down") and `logFC`.}
#'     \item{`reference`}{per-gene baseline regulation table for the kept genes.}
#'     \item{`n_genes`}{number of dysregulated genes retained.}
#'   }
#' @seealso [plot_normalization()], [evaluate_normalization()],
#'   [compute_improvement()]
#' @examples
#' df <- expand.grid(SubjectID = paste0("S", 1:4),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = c("G1", "G2"), stringsAsFactors = FALSE)
#' df$Value <- with(df, ifelse(Tissue == "NL", 0,
#'                      ifelse(Gene == "G1",
#'                             ifelse(Visit == "BL", 2, 1),
#'                             ifelse(Visit == "BL", -2, -1))))
#' compute_normalization(df, reference = "NL", degs = c("G1", "G2"))$normalization
#' @export
compute_normalization <- function(
  data,
  gene_col    = "Gene",      value_col = "Value",
  subject_col = "SubjectID", visit_col = "Visit", tissue_col = "Tissue",
  arm_col     = NULL,
  baseline    = "BL",        lesional  = "LS", reference = "NL",
  visit_levels = NULL,
  genes       = NULL,        degs      = NULL,
  fc_threshold = 1.5,        p_cut     = 0.05, use_fdr = FALSE
) {
  need <- c(gene_col, value_col, subject_col, visit_col, tissue_col)
  miss <- setdiff(need, names(data))
  if (length(miss)) stop("Missing columns: ", paste(miss, collapse = ", "))

  d <- data |> dplyr::transmute(
    .gene  = .data[[gene_col]],    .value = .data[[value_col]],
    .subj  = .data[[subject_col]], .visit = as.character(.data[[visit_col]]),
    .tiss  = .data[[tissue_col]],
    .arm   = if (!is.null(arm_col) && arm_col %in% names(data))
               as.character(.data[[arm_col]]) else "All"
  )
  if (!is.null(genes)) d <- d |> dplyr::filter(.gene %in% genes)

  lreg <- log2(fc_threshold)

  # ---- fixed healthy reference per gene (baseline reference samples, pooled) --
  ref_long <- d |> dplyr::filter(.tiss == reference)
  if (any(ref_long$.visit == baseline))
    ref_long <- ref_long |> dplyr::filter(.visit == baseline)
  ref <- ref_long |>
    dplyr::group_by(.gene) |>
    dplyr::summarise(reference = mean(.value, na.rm = TRUE), .groups = "drop")

  # ---- baseline regulation (defines Up/Down and the dysregulation filter) -----
  bl_ls <- d |>
    dplyr::filter(.visit == baseline, .tiss == lesional) |>
    dplyr::group_by(.gene) |>
    dplyr::summarise(bl.ls = mean(.value, na.rm = TRUE), .groups = "drop")
  reg <- ref |>
    dplyr::inner_join(bl_ls, by = ".gene") |>
    dplyr::mutate(Regulation = bl.ls - reference,
                  Reg.Type   = ifelse(Regulation < 0, "Down", "Up"))

  if (is.null(degs)) {
    sig <- d |>
      dplyr::filter(.visit == baseline, .tiss %in% c(lesional, reference)) |>
      dplyr::group_by(.gene) |>
      dplyr::summarise(
        p = tryCatch(stats::t.test(.value[.tiss == lesional],
                                   .value[.tiss == reference])$p.value,
                     error = function(e) NA_real_),
        .groups = "drop") |>
      dplyr::mutate(fdr = stats::p.adjust(p, method = "BH"))
    reg  <- reg |> dplyr::left_join(sig, by = ".gene")
    keep <- reg |>
      dplyr::filter(abs(Regulation) > lreg,
                    if (use_fdr) fdr < p_cut else p < p_cut) |>
      dplyr::pull(.gene)
  } else {
    keep <- intersect(degs, reg$.gene)
  }
  reg <- reg |> dplyr::filter(.gene %in% keep)

  # ---- group logFC of lesional vs the fixed reference, every visit + arm ------
  norm <- d |>
    dplyr::filter(.tiss == lesional, .gene %in% keep) |>
    dplyr::group_by(.gene, .visit, .arm) |>
    dplyr::summarise(.ls = mean(.value, na.rm = TRUE), .groups = "drop") |>
    dplyr::inner_join(ref, by = ".gene") |>
    dplyr::inner_join(dplyr::select(reg, .gene, Reg.Type), by = ".gene") |>
    dplyr::mutate(logFC = .ls - reference) |>
    dplyr::filter(is.finite(logFC))

  lev <- if (!is.null(visit_levels)) visit_levels
         else c(baseline, setdiff(sort(unique(norm$.visit)), baseline))
  norm <- norm |> dplyr::mutate(.visit = factor(.visit, levels = lev))

  list(normalization = norm, reference = reg, n_genes = length(keep))
}

#' Molecular normalization boxplot (gene-level logFC vs reference)
#'
#' @description
#' Draws the normalization figure: per visit (baseline included) the
#' distribution of gene-level log-fold changes of lesional tissue against the
#' healthy reference, faceted by treatment arm. Boxes are filled by baseline
#' regulation (Down = blue, Up = red) and the mean of each box is a
#' white-bordered filled circle; a dashed line marks the healthy reference at 0.
#' Treatment facet strips are coloured (Drug = darkgreen, Placebo = darkorange)
#' via [ggh4x::facet_grid2()]; a single arm drops the facet.
#'
#' @param norm The `normalization` table from [compute_normalization()].
#' @param reference_label Short reference name for the y-axis, e.g.
#'   `"Non-Lesional"` or `"Controls"` -> `"logFCH (vs. <label>)"`.
#' @param y_label Full y-axis title (overrides `reference_label` when given).
#' @param title Plot title.
#' @param reg_palette Named colours for Down / Up (default blue / red).
#' @param arm_strip Named fill colours for the treatment facet strips
#'   (default Drug = darkgreen, Placebo = darkorange).
#' @param box_width Width of the (dodged) boxes.
#' @param week_labels When `TRUE`, relabel `"W4"` as `"Week 4"` on the x-axis
#'   (the underlying data are untouched).
#'
#' @return A [ggplot2::ggplot] object.
#' @seealso [compute_normalization()], [evaluate_normalization()]
#' @examples
#' \donttest{
#' df <- expand.grid(SubjectID = paste0("S", 1:6),
#'                   Visit = c("BL", "W4"), Tissue = c("LS", "NL"),
#'                   Gene = paste0("G", 1:8), stringsAsFactors = FALSE)
#' set.seed(1)
#' df$Value <- rnorm(nrow(df)) + ifelse(df$Tissue == "LS" & df$Visit == "BL", 2, 0)
#' nz <- compute_normalization(df, reference = "NL", degs = paste0("G", 1:8))
#' plot_normalization(nz$normalization, reference_label = "Non-Lesional")
#' }
#' @export
plot_normalization <- function(
  norm, reference_label = "Non-Lesional", y_label = NULL, title = NULL,
  reg_palette = .NORM_REG_COLORS, arm_strip = .NORM_ARM_STRIP,
  box_width = 0.7, week_labels = TRUE
) {
  norm <- norm |>
    dplyr::mutate(Reg.Type = factor(Reg.Type, levels = c("Down", "Up")))
  has_arm <- dplyr::n_distinct(norm$.arm) > 1
  dodge   <- ggplot2::position_dodge(width = box_width + 0.05)
  if (is.null(y_label)) y_label <- sprintf("logFCH (vs. %s)", reference_label)

  arms  <- levels(factor(norm$.arm))
  fills <- ifelse(arms %in% names(arm_strip), arm_strip[arms], "grey30")

  p <- ggplot2::ggplot(norm, ggplot2::aes(x = .visit, y = logFC, fill = Reg.Type)) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    ggplot2::geom_boxplot(width = box_width, position = dodge, alpha = 0.5) +
    # mean = white-bordered filled circle, coloured by regulation
    ggplot2::stat_summary(fun = mean, geom = "point", shape = 21, size = 3,
                          color = "white", position = dodge,
                          ggplot2::aes(group = Reg.Type, fill = Reg.Type)) +
    ggplot2::scale_fill_manual(values = reg_palette) +
    ggplot2::labs(x = "Visit", y = y_label, title = title, fill = NULL) +
    ggplot2::scale_x_discrete(labels = if (week_labels) .norm_week_label
                                       else ggplot2::waiver()) +
    ggplot2::theme_bw(base_size = 14) +
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = 15),
      axis.text  = ggplot2::element_text(size = 13),
      axis.text.x = ggplot2::element_text(size = 15, face = "bold", color = "black"),
      legend.title = ggplot2::element_blank(),
      legend.text  = ggplot2::element_text(size = 14),
      plot.title   = ggplot2::element_text(hjust = 0.5, face = "bold"))

  if (has_arm) {
    p <- p + ggh4x::facet_grid2(
      . ~ .arm,
      strip = ggh4x::strip_themed(
        background_x = ggh4x::elem_list_rect(fill = fills),
        text_x = ggh4x::elem_list_text(colour = rep("white", length(arms)),
                                       face = rep("bold", length(arms)),
                                       size = rep(16, length(arms)))))
  }
  p
}

#' Evaluate molecular normalization and build the figure
#'
#' @description
#' One-call pipeline that runs [compute_normalization()] and renders the
#' normalization boxplot via [plot_normalization()]. When `outdir` is given the
#' figure is written as a 10.5 x 4.5 inch PDF.
#'
#' @inheritParams compute_normalization
#' @param ... Additional arguments passed to [compute_normalization()].
#' @param reference_label Short reference name for the y-axis and file name; when
#'   `NULL` it is guessed from `reference` (`"NL"` -> "Non-Lesional",
#'   `"HC"`/`"Control"` -> "Controls").
#' @param reg_palette,arm_strip Colour overrides forwarded to
#'   [plot_normalization()].
#' @param week_labels When `TRUE`, relabel `"W4"` as `"Week 4"` on the x-axis.
#' @param signature_name Label used in the plot title and output file name.
#' @param outdir If not `NULL`, a directory to write the PDF into (created if
#'   needed).
#'
#' @return A list with `normalization` (the table), `reference` (the per-gene
#'   regulation table) and `plot` (the [ggplot2::ggplot]).
#' @seealso [compute_normalization()], [plot_normalization()],
#'   [evaluate_improvement()]
#' @examples
#' \donttest{
#' set.seed(1)
#' df <- expand.grid(SubjectID = paste0("S", 1:8), Visit = c("BL", "W4", "W16"),
#'                   Tissue = c("LS", "NL"), Gene = paste0("G", 1:15),
#'                   stringsAsFactors = FALSE)
#' df$Value <- rnorm(nrow(df), 0, 0.3) +
#'   ifelse(df$Tissue == "LS" & df$Visit == "BL", 2,
#'   ifelse(df$Tissue == "LS" & df$Visit == "W4", 1.2,
#'   ifelse(df$Tissue == "LS" & df$Visit == "W16", 0.6, 0)))
#' res <- evaluate_normalization(df, reference = "NL", degs = paste0("G", 1:15),
#'                               signature_name = "Demo")
#' res$plot
#' }
#' @export
evaluate_normalization <- function(
  data, ...,
  arm_col = NULL, reference = "NL", reference_label = NULL,
  reg_palette = .NORM_REG_COLORS, arm_strip = .NORM_ARM_STRIP,
  week_labels = TRUE, signature_name = "Transcriptome", outdir = NULL
) {
  cn   <- compute_normalization(data, arm_col = arm_col, reference = reference, ...)
  norm <- cn$normalization
  if (!nrow(norm))
    stop("No genes passed the dysregulation filter; relax fc_threshold/p_cut ",
         "or pass `genes`/`degs` explicitly.")
  message(sprintf("Using %d dysregulated genes.", cn$n_genes))

  if (is.null(reference_label))
    reference_label <- if (toupper(reference) %in% c("HC", "CONTROL", "CONTROLS"))
                         "Controls" else if (reference == "NL") "Non-Lesional"
                       else reference

  p <- plot_normalization(
    norm, reference_label = reference_label,
    title = sprintf("%s - normalization toward %s", signature_name, reference_label),
    reg_palette = reg_palette, arm_strip = arm_strip, week_labels = week_labels)

  if (!is.null(outdir)) {
    dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
    sfx <- gsub("[^A-Za-z0-9]+", "_", signature_name)
    rfx <- gsub("[^A-Za-z0-9]+", "_", reference_label)
    f   <- file.path(outdir, sprintf("Normalization_LSto%s_%s.pdf", rfx, sfx))
    ggplot2::ggsave(f, p, width = 10.5, height = 4.5)
    message("Wrote ", f)
  }

  list(normalization = norm, reference = cn$reference, plot = p)
}
