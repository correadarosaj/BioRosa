#' Mixed-model estimated trajectories with significance stars
#'
#' @description
#' `doTrajectoryModel()` fits a linear mixed-effects model to a longitudinal
#' clinical score and plots the **model-estimated marginal means** per visit and
#' treatment arm, with error bars and **significance stars**. Stars are computed
#' from the model by default (each visit vs. baseline within an arm, and,
#' optionally, between-arm difference-in-change), but can be **overridden** with
#' p-values from a BigTab or a plain p-value table.
#'
#' The model is a cell-means model, `score ~ group * time` with a per-subject
#' random intercept (the standard repeated-measures structure). Estimated means
#' and contrasts come from \pkg{emmeans}.
#'
#' @param data A long-format data frame (one row per subject-visit).
#' @param subject,time,score Character. Columns for the patient, the visit, and
#'   the numeric clinical score.
#' @param group Character or `NULL`. Treatment/arm column. Needed for between-arm
#'   comparisons; within-arm-vs-baseline still works with a single arm.
#' @param baseline The visit treated as baseline for vs-baseline contrasts.
#'   Defaults to the first level of `time_levels`.
#' @param time_levels Character vector giving the visit order. Defaults to the
#'   factor levels / sorted unique values of `time`.
#' @param value What to plot on the y-axis: `"mean"` (estimated marginal mean,
#'   the default), `"change"` (estimated change from baseline), or `"pchange"`
#'   (estimated percent change from baseline).
#' @param random Optional random-effects specification. For `engine = "lme"` an
#'   \pkg{nlme} formula (default `~ 1 | subject`); for `engine = "lmer"` a
#'   parenthesised \pkg{lme4} term (default `(1 | subject)`).
#' @param engine `"lme"` (\pkg{nlme}, default) or `"lmer"` (\pkg{lme4}).
#' @param error `"se"` (default) or `"ci"` — error bars as mean +/- SE or as the
#'   confidence interval.
#' @param impute One of `"none"` (default), `"locf"`, or `"mice"`; see
#'   [doTrajectory()].
#' @param reference Reference arm for between-arm stars. Defaults to the first
#'   level of `group`.
#' @param between Logical or `NULL`. Draw between-arm stars (vs `reference`).
#'   `NULL` (default) enables them when `group` has more than one level.
#' @param pvals Optional override for the stars. Either a data frame with columns
#'   `time` and `p.value` (optionally `group`, and `p.between`), **or** a BigTab:
#'   a data frame whose columns follow `pvals_<group>.<time>vs<baseline_label>`
#'   (see `pval_prefix`, `baseline_label`, `score_row`).
#' @param score_row When `pvals` is a BigTab, the row (gene/score) to read,
#'   matched against row names or a `GENENAME` column.
#' @param pval_prefix Column prefix for BigTab p-values. Default `"pvals_"`.
#' @param baseline_label Token used for baseline in BigTab contrast suffixes
#'   (e.g. `"BL"` in `pvals_Drug.W16vsBL`). Default `"BL"`.
#' @param star_breaks,star_labels Cutoffs and labels passed to [pval2star()].
#' @param palette Optional named colour vector for the arms.
#' @param title,xlab,ylab Title and axis labels. `ylab` defaults to a label
#'   derived from `value`.
#' @param conf.interval Confidence level for `error = "ci"`. Default `0.95`.
#' @param mice_m,seed MICE controls; see [doTrajectory()].
#' @param file Optional path; if given the plot is written with [ggplot2::ggsave()].
#' @param width,height Saved figure size in inches. Defaults `8.5` x `5.5`.
#'
#' @return A list with `$plot` (a `ggplot`), `$estimates` (the per-arm, per-visit
#'   estimate table with `p_within` / `p_between` and the star labels), and
#'   `$model` (the fitted model).
#'
#' @details
#' **Within-arm stars** test each visit against `baseline` within an arm.
#' **Between-arm stars** test, at each visit, the difference in change-from-
#' baseline between an arm and `reference` (a difference-in-differences
#' interaction contrast; for `value = "pchange"` the arms are compared directly
#' at each visit). Between-arm contrasts are best-effort: if \pkg{emmeans} cannot
#' form them they are skipped with a warning.
#'
#' Stars use the [pval2star()] convention: `***` < 0.001, `**` < 0.01,
#' `*` < 0.05, `+` < 0.1.
#'
#' @seealso [doTrajectory()] for observed (non-model) trajectories.
#'
#' @examples
#' \dontrun{
#' res <- doTrajectoryModel(clin, subject = "record_id", time = "Visit",
#'                          score = "EASI", group = "Trt", baseline = "W0",
#'                          value = "change", reference = "Pbo")
#' res$plot
#' res$estimates
#'
#' # Override stars with p-values stored in a BigTab row:
#' res <- doTrajectoryModel(clin, subject = "record_id", time = "Visit",
#'                          score = "EASI", group = "Trt", baseline = "W0",
#'                          pvals = BigTab, score_row = "EASI")
#' }
#' @export
doTrajectoryModel <- function(data, subject, time, score, group = NULL,
                              baseline = NULL, time_levels = NULL,
                              value = c("mean", "change", "pchange"),
                              random = NULL, engine = c("lme", "lmer"),
                              error = c("se", "ci"),
                              impute = c("none", "locf", "mice"),
                              reference = NULL, between = NULL,
                              pvals = NULL, score_row = NULL,
                              pval_prefix = "pvals_", baseline_label = "BL",
                              star_breaks = c(-Inf, 0.001, 0.01, 0.05, 0.1, Inf),
                              star_labels = c("***", "**", "*", "+", ""),
                              palette = NULL,
                              title = NULL, xlab = "Visit", ylab = NULL,
                              conf.interval = 0.95, mice_m = 5, seed = 1970,
                              file = NULL, width = 8.5, height = 5.5) {

  value  <- match.arg(value)
  engine <- match.arg(engine)
  error  <- match.arg(error)
  impute <- match.arg(impute)
  if (engine == "lmer" && !requireNamespace("lme4", quietly = TRUE))
    stop("engine = 'lmer' requires the 'lme4' package.")

  d <- .traj_std(data, subject, time, score, group, time_levels)
  if (is.null(baseline)) baseline <- levels(d$.time)[1]
  if (!baseline %in% levels(d$.time))
    stop("`baseline` (", baseline, ") is not among the visit levels.")
  d$.time <- stats::relevel(d$.time, ref = baseline)

  nlev_g <- nlevels(d$.group)
  if (nlev_g > 1) {
    if (is.null(reference)) reference <- levels(d$.group)[1]
    if (!reference %in% levels(d$.group))
      stop("`reference` (", reference, ") is not among the group levels.")
    d$.group <- stats::relevel(d$.group, ref = reference)
  }
  if (is.null(between)) between <- nlev_g > 1

  d <- .traj_impute(d, impute, mice_m = mice_m, seed = seed)
  d <- d[!is.na(d$.score), ]

  # ---- percent / absolute change pre-processing -----------------------------
  if (value == "pchange") {
    bl <- d[d$.time == baseline, c(".subject", ".score")]
    names(bl)[2] <- ".bl"
    d <- merge(d[d$.time != baseline, ], bl, by = ".subject")
    d$.score <- 100 * (d$.score - d$.bl) / d$.bl
    d <- d[is.finite(d$.score), ]
    d$.time <- droplevels(factor(as.character(d$.time),
                                 levels = setdiff(levels(d$.time), baseline)))
  }
  d$.subject <- droplevels(d$.subject)
  d$.group   <- droplevels(d$.group)
  nlev_g     <- nlevels(d$.group)

  # ---- fit the mixed model --------------------------------------------------
  rhs <- if (nlev_g > 1) ".group * .time" else ".time"
  fit <- .traj_fit(d, rhs, random, engine, subject)

  emm_spec <- if (nlev_g > 1) stats::as.formula("~ .time | .group") else
                              stats::as.formula("~ .time")
  emm <- emmeans::emmeans(fit, emm_spec)

  # ---- assemble the estimate table ------------------------------------------
  est <- .traj_estimates(fit, emm, d, value, baseline, nlev_g, conf.interval)

  # ---- within-arm stars (vs baseline) ---------------------------------------
  if (value != "pchange") {
    wc <- emmeans::contrast(emm, method = "trt.vs.ctrl1")
    wc_df <- as.data.frame(stats::confint(wc))
    wc_df$p.value <- as.data.frame(wc)$p.value
    wc_df$.time <- factor(sub("\\s*-.*$", "", as.character(wc_df$contrast)),
                          levels = levels(est$.time))
    if (nlev_g == 1) wc_df$.group <- factor("All")
    if (value == "change") {
      est$p_within <- est$.p_change   # already the change contrast p-value
    } else {
      key <- if (nlev_g > 1) c(".group", ".time") else ".time"
      est <- merge(est, wc_df[c(key, "p.value")], by = key, all.x = TRUE)
      est$p_within <- est$p.value; est$p.value <- NULL
    }
  } else {
    est$p_within <- est$.p_change     # emmean vs 0 for percent change
  }
  est$.p_change <- NULL

  # ---- between-arm stars (difference in change vs reference) -----------------
  est$p_between <- NA_real_
  if (isTRUE(between) && nlev_g > 1) {
    bw <- tryCatch(.traj_between(fit, d, value), error = function(e) {
      warning("Between-arm contrasts skipped: ", conditionMessage(e))
      NULL
    })
    if (!is.null(bw)) {
      est$p_between <- NULL
      est <- merge(est, bw, by = c(".group", ".time"), all.x = TRUE)
    }
  }

  # ---- optional override from a BigTab / p-value table ----------------------
  if (!is.null(pvals))
    est <- .traj_override(est, pvals, baseline, pval_prefix, baseline_label,
                          score_row)

  # ---- stars + error-bar limits ---------------------------------------------
  est$star_within  <- as.character(pval2star(est$p_within, star_breaks, star_labels))
  est$star_between <- as.character(pval2star(est$p_between, star_breaks, star_labels))
  est$star_within[is.na(est$star_within)]   <- ""
  est$star_between[is.na(est$star_between)] <- ""
  if (error == "se") {
    est$ymin <- est$estimate - est$SE; est$ymax <- est$estimate + est$SE
  } else {
    est$ymin <- est$lower;             est$ymax <- est$upper
  }
  est <- est[order(est$.group, est$.time), ]

  if (is.null(ylab))
    ylab <- switch(value, mean = score,
                   change = paste("Change from", baseline),
                   pchange = "% change from baseline")

  gf <- .traj_model_plot(est, palette, title, xlab, ylab)

  if (!is.null(file))
    ggplot2::ggsave(file, plot = gf, width = width, height = height)

  list(plot = gf, estimates = est, model = fit)
}

# --- internal: fit the mixed model -----------------------------------------
.traj_fit <- function(d, rhs, random, engine, subject) {
  if (engine == "lme") {
    rform <- if (is.null(random)) stats::as.formula("~ 1 | .subject") else random
    nlme::lme(stats::as.formula(paste(".score ~", rhs)),
              random = rform, data = d, method = "REML",
              na.action = stats::na.omit,
              control = nlme::lmeControl(opt = "optim"))
  } else {
    rterm <- if (is.null(random)) "(1 | .subject)" else random
    lme4::lmer(stats::as.formula(paste(".score ~", rhs, "+", rterm)), data = d)
  }
}

# --- internal: build the per-arm, per-visit estimate table ------------------
.traj_estimates <- function(fit, emm, d, value, baseline, nlev_g, conf.interval) {
  if (value == "change") {
    wc <- emmeans::contrast(emm, method = "trt.vs.ctrl1")
    s  <- as.data.frame(summary(wc, infer = c(TRUE, TRUE),
                                level = conf.interval))
    tlev <- setdiff(levels(d$.time), baseline)
    out <- data.frame(
      .group   = if (nlev_g > 1) s$.group else factor("All"),
      .time    = factor(sub("\\s*-.*$", "", as.character(s$contrast)),
                        levels = tlev),
      estimate = s$estimate, SE = s$SE,
      lower    = s$lower.CL, upper = s$upper.CL,
      .p_change = s$p.value)
  } else {
    s <- as.data.frame(summary(emm, infer = c(TRUE, TRUE),
                               level = conf.interval))
    out <- data.frame(
      .group   = if (nlev_g > 1) s$.group else factor("All"),
      .time    = factor(as.character(s$.time), levels = levels(d$.time)),
      estimate = s$emmean, SE = s$SE,
      lower    = s$lower.CL, upper = s$upper.CL,
      .p_change = s$p.value)   # vs 0 (used for pchange within-stars)
  }
  out
}

# --- internal: between-arm difference-in-change p-values --------------------
.traj_between <- function(fit, d, value) {
  if (value == "pchange") {
    bw <- emmeans::contrast(emmeans::emmeans(fit, ~ .group | .time),
                            method = "trt.vs.ctrl1")
    s  <- as.data.frame(bw)
    grp <- sub("\\s*-.*$", "", as.character(s$contrast))
    data.frame(.group = factor(grp, levels = levels(d$.group)),
               .time  = factor(as.character(s$.time), levels = levels(d$.time)),
               p_between = s$p.value)
  } else {
    bw <- emmeans::contrast(emmeans::emmeans(fit, ~ .group * .time),
                            interaction = c(.group = "trt.vs.ctrl1",
                                            .time  = "trt.vs.ctrl1"))
    s  <- as.data.frame(bw)
    grp <- sub("\\s*-.*$", "", as.character(s$`.group_trt.vs.ctrl1`))
    tim <- sub("\\s*-.*$", "", as.character(s$`.time_trt.vs.ctrl1`))
    data.frame(.group = factor(grp, levels = levels(d$.group)),
               .time  = factor(tim, levels = levels(d$.time)),
               p_between = s$p.value)
  }
}

# --- internal: override stars from a BigTab or p-value table ----------------
.traj_override <- function(est, pvals, baseline, pval_prefix, baseline_label,
                           score_row) {
  is_bigtab <- is.data.frame(pvals) &&
    !all(c("time") %in% tolower(names(pvals))) &&
    any(startsWith(names(pvals), pval_prefix))

  if (is_bigtab) {
    if (is.null(score_row))
      stop("`pvals` looks like a BigTab; supply `score_row`.")
    ridx <- if (!is.null(rownames(pvals)) && score_row %in% rownames(pvals))
              match(score_row, rownames(pvals))
            else if ("GENENAME" %in% names(pvals))
              match(score_row, pvals$GENENAME)
            else NA
    if (is.na(ridx)) stop("`score_row` (", score_row, ") not found in BigTab.")
    pcols <- names(pvals)[startsWith(names(pvals), pval_prefix)]
    for (i in seq_len(nrow(est))) {
      suffix <- paste0(est$.group[i], ".", est$.time[i], "vs", baseline_label)
      col <- paste0(pval_prefix, suffix)
      if (col %in% pcols) est$p_within[i] <- as.numeric(pvals[ridx, col])
    }
    return(est)
  }

  # plain p-value table: columns time + p.value (+ optional group, p.between)
  nm <- tolower(names(pvals))
  names(pvals) <- nm
  if (!all(c("time", "p.value") %in% nm))
    stop("`pvals` table needs at least `time` and `p.value` columns.")
  key <- "time"
  if ("group" %in% nm) key <- c("group", "time")
  m <- pvals
  m$.time <- factor(as.character(m$time), levels = levels(est$.time))
  if ("group" %in% nm)
    m$.group <- factor(as.character(m$group), levels = levels(est$.group))
  on <- if ("group" %in% nm) c(".group", ".time") else ".time"
  keep <- c(on, "p.value", if ("p.between" %in% nm) "p.between")
  est$p_within <- NULL
  est <- merge(est, m[keep], by = on, all.x = TRUE)
  names(est)[names(est) == "p.value"] <- "p_within"
  if ("p.between" %in% nm) {
    est$p_between <- NULL
    names(est)[names(est) == "p.between"] <- "p_between"
  }
  est
}

# --- internal: the model-estimate ggplot -----------------------------------
.traj_model_plot <- function(est, palette, title, xlab, ylab) {
  pd  <- ggplot2::position_dodge(width = 0.3)
  rng <- range(c(est$ymin, est$ymax), na.rm = TRUE)
  off <- 0.04 * (rng[2] - rng[1])

  gf <- ggplot2::ggplot(est, ggplot2::aes(x = .data[[".time"]],
                                          y = .data[["estimate"]],
                                          colour = .data[[".group"]],
                                          group = .data[[".group"]])) +
    ggplot2::geom_line(position = pd) +
    ggplot2::geom_point(position = pd, size = 2) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = .data[["ymin"]],
                                        ymax = .data[["ymax"]]),
                           width = 0.15, position = pd) +
    ggplot2::geom_text(ggplot2::aes(y = .data[["ymin"]] - off,
                                    label = .data[["star_within"]]),
                       position = pd, size = 6, show.legend = FALSE)

  if (any(nzchar(est$star_between)))
    gf <- gf + ggplot2::geom_text(
      ggplot2::aes(y = .data[["ymax"]] + off, label = .data[["star_between"]]),
      position = pd, size = 6, colour = "black", show.legend = FALSE)

  if (!is.null(palette))
    gf <- gf + ggplot2::scale_colour_manual(values = palette)

  gf +
    ggplot2::labs(title = title, x = xlab, y = ylab, colour = NULL) +
    ggplot2::theme_bw() +
    ggplot2::theme(text = ggplot2::element_text(size = 16))
}
