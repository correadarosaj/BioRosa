#' Internal helpers for clinical-score trajectory plots
#'
#' These are not exported. They standardise a long-format clinical table,
#' optionally impute missing visits (LOCF / MICE), and build colour palettes
#' shared by [doTrajectory()] and [doTrajectoryModel()].
#'
#' @keywords internal
#' @name traj-utils
NULL

# Standardise a long clinical table to the internal column names
# .subject / .time / .score / .group used throughout the trajectory functions.
.traj_std <- function(data, subject, time, score, group = NULL,
                      time_levels = NULL) {
  if (!is.data.frame(data)) stop("`data` must be a data frame.")
  need <- c(subject, time, score, group)
  miss <- setdiff(need, names(data))
  if (length(miss))
    stop("Column(s) not found in `data`: ", paste(miss, collapse = ", "))

  d <- data.frame(
    .subject = as.factor(data[[subject]]),
    .score   = suppressWarnings(as.numeric(data[[score]])),
    stringsAsFactors = FALSE
  )
  d$.group <- if (is.null(group)) factor("All") else as.factor(data[[group]])

  if (is.null(time_levels)) {
    time_levels <- if (is.factor(data[[time]])) levels(data[[time]])
                   else sort(unique(as.character(data[[time]])))
  }
  raw_time <- as.character(data[[time]])
  d$.time  <- factor(raw_time, levels = time_levels)
  bad <- setdiff(unique(raw_time), time_levels)
  if (length(bad))
    stop("These `time` values are not in `time_levels`: ",
         paste(bad, collapse = ", "))
  d
}

# Last observation carried forward for a single ordered vector.
# Leading NAs (no prior observation) are left as NA.
.traj_locf <- function(x) {
  good <- !is.na(x)
  if (!any(good)) return(x)
  idx <- cumsum(good)
  idx[idx == 0] <- NA
  x[good][idx]
}

# Optionally complete the subject x time grid and impute missing scores.
# impute = "none" returns the data unchanged.
.traj_impute <- function(d, impute = "none", mice_m = 5, seed = 1970) {
  impute <- match.arg(impute, c("none", "locf", "mice"))
  if (impute == "none") return(d)

  lev <- levels(d$.time)
  grp <- unique(d[c(".subject", ".group")])
  full <- merge(grp,
                data.frame(.time = factor(lev, levels = lev)),
                by = NULL)
  d2 <- merge(full, d[c(".subject", ".time", ".score")],
              by = c(".subject", ".time"), all.x = TRUE)
  d2$.time <- factor(as.character(d2$.time), levels = lev)
  d2 <- d2[order(d2$.subject, d2$.time), ]

  if (impute == "locf") {
    d2$.score <- stats::ave(d2$.score, d2$.subject, FUN = .traj_locf)
    return(d2[c(".subject", ".time", ".score", ".group")])
  }

  # impute == "mice": predictive mean matching on the subject x visit matrix,
  # averaged over the m completed data sets for a single stable value.
  if (!requireNamespace("mice", quietly = TRUE))
    stop("impute = 'mice' requires the 'mice' package (install.packages('mice')).")
  if (!requireNamespace("tidyr", quietly = TRUE))
    stop("impute = 'mice' requires the 'tidyr' package.")

  wide <- tidyr::pivot_wider(d2[c(".subject", ".time", ".score")],
                             names_from = ".time", values_from = ".score")
  ids   <- wide$.subject
  tvars <- setdiff(names(wide), ".subject")
  mat   <- as.data.frame(wide[tvars])

  set.seed(seed)
  mids <- mice::mice(mat, m = mice_m, method = "pmm", printFlag = FALSE)
  comp <- mice::complete(mids, action = "long")
  agg  <- stats::aggregate(comp[tvars], by = list(.id = comp$.id), FUN = mean)
  agg  <- agg[order(agg$.id), ]

  wide_imp <- data.frame(.subject = ids, agg[tvars], check.names = FALSE)
  out <- tidyr::pivot_longer(wide_imp, cols = -".subject",
                             names_to = ".time", values_to = ".score")
  out$.time <- factor(as.character(out$.time), levels = lev)
  out <- merge(as.data.frame(out), grp, by = ".subject")
  out[c(".subject", ".time", ".score", ".group")]
}

# Distinct colour palette for n series (patients or groups).
.traj_palette <- function(n, palette = NULL) {
  if (!is.null(palette)) return(rep_len(palette, n))
  if (n <= 0) return(character(0))
  grDevices::hcl.colors(max(n, 2), palette = "Dynamic")[seq_len(n)]
}
