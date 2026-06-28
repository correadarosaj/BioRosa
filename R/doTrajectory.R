#' Plot per-patient trajectories of a clinical score over visits
#'
#' @description
#' `doTrajectory()` draws publication-quality **observed** longitudinal
#' trajectories of a clinical score: one coloured line per patient
#' ("spaghetti"), an optional bold **group-mean** line, and optional
#' **error bars** (SE / SD / CI) on that mean. It is the descriptive companion
#' to [doTrajectoryModel()], which plots model-estimated means with significance
#' stars.
#'
#' Input is a **long-format** data frame: one row per patient-visit, with
#' columns identifying the subject, the visit/time, the score, and (optionally)
#' the treatment group.
#'
#' @param data A long-format data frame (one row per subject-visit).
#' @param subject Character. Column identifying the patient.
#' @param time Character. Column with the visit / time point.
#' @param score Character. Numeric column with the clinical score to plot.
#' @param group Character or `NULL`. Treatment/arm column. When supplied and
#'   `facet = TRUE`, spaghetti panels are faceted by group.
#' @param time_levels Character vector giving the visit order. Defaults to the
#'   factor levels of `time`, or its sorted unique values.
#' @param impute One of `"none"` (default), `"locf"` (last observation carried
#'   forward), or `"mice"` (predictive-mean-matching multiple imputation,
#'   averaged over `mice_m` completions). Imputation first completes the full
#'   subject \eqn{\times} visit grid.
#' @param spaghetti Logical. Draw one line per patient. Default `TRUE`.
#' @param group_mean Logical. Overlay the group-mean trajectory. Default `TRUE`.
#' @param error One of `"none"` (default), `"se"`, `"sd"`, or `"ci"` — the
#'   error bar drawn on the group mean. Computed with [summarySE()].
#' @param facet Logical. Facet the spaghetti by `group` (only when `spaghetti`
#'   and `group` has more than one level). Default `TRUE`.
#' @param palette Optional colour vector. For spaghetti it colours patients; for
#'   a mean-only plot it colours groups. Defaults to a distinct HCL palette.
#' @param title,xlab,ylab Plot title and axis labels. `ylab` defaults to `score`.
#' @param conf.interval Confidence level for `error = "ci"`. Default `0.95`.
#' @param mice_m Number of imputations when `impute = "mice"`. Default `5`.
#' @param seed Random seed for MICE reproducibility. Default `1970`.
#' @param file Optional path; if given the plot is written with [ggplot2::ggsave()].
#' @param width,height Saved figure size in inches. Defaults `12` x `6`.
#'
#' @return A `ggplot` object (returned invisibly when `file` is written).
#'
#' @seealso [doTrajectoryModel()] for mixed-model estimated means with
#'   significance stars; [summarySE()] for the error-bar summaries.
#'
#' @examples
#' \dontrun{
#' # Per-patient spaghetti + bold group mean, faceted by arm
#' doTrajectory(clin, subject = "record_id", time = "Visit",
#'              score = "EASI", group = "Trt",
#'              time_levels = c("W0", "W4", "W8", "W16"))
#'
#' # Group mean +/- SE only (the classic mean-with-error-bars trajectory)
#' doTrajectory(clin, subject = "record_id", time = "Visit",
#'              score = "EASI", group = "Trt",
#'              spaghetti = FALSE, error = "se")
#' }
#' @export
doTrajectory <- function(data, subject, time, score, group = NULL,
                         time_levels = NULL,
                         impute = c("none", "locf", "mice"),
                         spaghetti = TRUE, group_mean = TRUE,
                         error = c("none", "se", "sd", "ci"),
                         facet = TRUE, palette = NULL,
                         title = NULL, xlab = "Visit", ylab = NULL,
                         conf.interval = 0.95, mice_m = 5, seed = 1970,
                         file = NULL, width = 12, height = 6) {

  impute <- match.arg(impute)
  error  <- match.arg(error)
  if (is.null(ylab)) ylab <- score
  if (!spaghetti && !group_mean)
    stop("Nothing to draw: set `spaghetti = TRUE` and/or `group_mean = TRUE`.")

  has_group <- !is.null(group)
  d <- .traj_std(data, subject, time, score, group, time_levels)
  d <- .traj_impute(d, impute, mice_m = mice_m, seed = seed)

  p <- ggplot2::ggplot(mapping = ggplot2::aes(x = .data[[".time"]],
                                              y = .data[[".score"]]))

  if (spaghetti) {
    dd  <- d[!is.na(d$.score), ]
    dd$.subject <- droplevels(dd$.subject)
    pal <- .traj_palette(nlevels(dd$.subject), palette)
    p <- p +
      ggplot2::geom_line(data = dd,
                         ggplot2::aes(group = .data[[".subject"]],
                                      colour = .data[[".subject"]]),
                         alpha = 0.6) +
      ggplot2::geom_point(data = dd,
                          ggplot2::aes(colour = .data[[".subject"]]),
                          size = 1, alpha = 0.7) +
      ggplot2::scale_colour_manual(values = pal, guide = "none")
  }

  if (group_mean) {
    ss <- summarySE(d, measurevar = ".score",
                    groupvars = c(".group", ".time"),
                    na.rm = TRUE, conf.interval = conf.interval)
    ss <- ss[!is.na(ss$.score), ]
    err_col <- switch(error, se = "se", sd = "sd", ci = "ci", none = NA)

    if (spaghetti) {
      # bold black mean line(s) so they stand out over the coloured patients
      p <- p +
        ggplot2::geom_line(data = ss,
                           ggplot2::aes(y = .data[[".score"]],
                                        group = .data[[".group"]]),
                           linewidth = 1.2, colour = "black") +
        ggplot2::geom_point(data = ss, ggplot2::aes(y = .data[[".score"]]),
                            colour = "black", size = 2)
      if (!is.na(err_col))
        p <- p + ggplot2::geom_errorbar(
          data = ss,
          ggplot2::aes(ymin = .data[[".score"]] - .data[[err_col]],
                       ymax = .data[[".score"]] + .data[[err_col]]),
          width = 0.15, colour = "black")
    } else {
      pal <- .traj_palette(nlevels(ss$.group), palette)
      p <- p +
        ggplot2::geom_line(data = ss,
                           ggplot2::aes(y = .data[[".score"]],
                                        colour = .data[[".group"]],
                                        group = .data[[".group"]]),
                           linewidth = 1) +
        ggplot2::geom_point(data = ss,
                            ggplot2::aes(y = .data[[".score"]],
                                         colour = .data[[".group"]]),
                            size = 2) +
        ggplot2::scale_colour_manual(values = pal, name = NULL)
      if (!is.na(err_col))
        p <- p + ggplot2::geom_errorbar(
          data = ss,
          ggplot2::aes(ymin = .data[[".score"]] - .data[[err_col]],
                       ymax = .data[[".score"]] + .data[[err_col]],
                       colour = .data[[".group"]]),
          width = 0.15)
    }
  }

  if (facet && spaghetti && has_group && nlevels(d$.group) > 1)
    p <- p + ggplot2::facet_grid(cols = ggplot2::vars(.data[[".group"]]))

  p <- p +
    ggplot2::labs(title = title, x = xlab, y = ylab) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      plot.title   = ggplot2::element_text(size = 16, face = "bold"),
      axis.title   = ggplot2::element_text(size = 14),
      axis.text    = ggplot2::element_text(size = 12),
      strip.text   = ggplot2::element_text(size = 13, face = "bold"))

  if (!is.null(file)) {
    ggplot2::ggsave(file, plot = p, width = width, height = height)
    return(invisible(p))
  }
  p
}
