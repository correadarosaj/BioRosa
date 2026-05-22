# Imports: openxlsx

#' Summarise DEGs from a BigTab and export per-contrast gene lists to Excel
#'
#' @description
#' `process_degs()` consolidates two previously separate helpers
#' (`extract_degs()` and `build_DEGsTable()`) into a single call. Given a
#' "BigTab" data frame holding per-contrast statistics with one `Status_*`
#' column per contrast (encoded as `-1` for down-regulated, `0` for
#' unchanged, `1` for up-regulated), the function:
#'
#' 1. **Builds a count summary** — for every contrast in `cont.list`,
#'    counts the number of `Down` (`Status == -1`) and `Up`
#'    (`Status == 1`) genes, and annotates the row with the fold-change
#'    cutoff (`FCH`) and either the p-value cutoff (`PVAL`) or FDR
#'    cutoff (`FDR`) depending on `method`.
#' 2. **Extracts DEG identities** — for each contrast, collects the
#'    `GENENAME` values where `Status != 0` together with every BigTab
#'    column tagged with that contrast (e.g. `lgFCH_*`, `pvals_*`,
#'    `fdr_*`, `Status_*`).
#' 3. **Writes a single Excel workbook** — sheet `Summary` carries the
#'    count table; one further sheet per contrast carries the DEG rows
#'    with their statistics, ready for hand-off to collaborators.
#'
#' The return value contains the summary table and a named character
#' vector of DEG symbols per contrast, so downstream code can keep
#' working from memory without re-reading the workbook.
#'
#' @param BigTab Data frame with a `GENENAME` column and one
#'   `Status_<contrast>` column per contrast (values in `{-1, 0, 1}`).
#'   Typically also carries `lgFCH_<contrast>`, `pvals_<contrast>`, and
#'   `fdr_<contrast>` columns — these are copied into the per-contrast
#'   Excel sheets when present.
#' @param cont.list Character vector of contrast labels. Each label must
#'   match (as a substring of `_<label>`) the suffix of the corresponding
#'   `Status_*` column in `BigTab`.
#' @param FCH Numeric. Fold-change threshold used to build the BigTab.
#'   Recorded in the `Summary` table for traceability only — it is not
#'   re-applied here.
#' @param pcut Numeric. P-value (or FDR) threshold used to build the
#'   BigTab. Recorded in the `Summary` table for traceability only.
#' @param method One of `"none"` (default) or `"fdr"`. Controls whether
#'   `pcut` is reported as a `PVAL` or `FDR` column in the `Summary`
#'   sheet.
#' @param output_xlsx Path to the output `.xlsx` file. The parent
#'   directory is created if missing. Default `"degs.xlsx"`.
#'
#' @return Invisibly, a list with two elements:
#'   * `summary` — a data frame with columns `contrast`, `Down`, `Up`,
#'     `FCH`, and either `PVAL` or `FDR`.
#'   * `degs` — a named list (one entry per contrast) of character
#'     vectors of DEG `GENENAME` values.
#'
#' Side effect: writes the workbook at `output_xlsx`.
#'
#' @examples
#' \dontrun{
#' res <- process_degs(
#'   BigTab      = my_bigtab,
#'   cont.list   = c("treated_vs_ctrl", "high_vs_low"),
#'   FCH         = 1,
#'   pcut        = 0.05,
#'   method      = "fdr",
#'   output_xlsx = "results/degs.xlsx"
#' )
#' res$summary
#' res$degs$treated_vs_ctrl
#' }
#'
#' @export
process_degs <- function(BigTab,
                         cont.list,
                         FCH         = 1,
                         pcut        = 0.05,
                         method      = c("none", "fdr"),
                         output_xlsx = "degs.xlsx") {

  if (missing(BigTab) || !is.data.frame(BigTab))
    stop("`BigTab` must be a data frame.")
  if (!"GENENAME" %in% colnames(BigTab))
    stop("`BigTab` must contain a `GENENAME` column.")
  if (missing(cont.list) || !is.character(cont.list) || length(cont.list) == 0)
    stop("`cont.list` must be a non-empty character vector.")
  method <- match.arg(method)

  cont_keys <- paste0("_", cont.list)

  degs       <- vector("list", length(cont.list))
  sheet_dfs  <- vector("list", length(cont.list))
  summary_rows <- vector("list", length(cont.list))
  names(degs) <- names(sheet_dfs) <- cont.list

  for (i in seq_along(cont.list)) {
    key <- cont_keys[i]

    status_cols <- colnames(BigTab)[
      grepl("Status", colnames(BigTab), fixed = TRUE) &
      grepl(key,      colnames(BigTab), fixed = TRUE)
    ]
    if (length(status_cols) != 1L)
      stop(sprintf(
        "Could not find a unique Status column for contrast '%s' (found %d).",
        cont.list[i], length(status_cols)
      ))

    status_vec <- BigTab[[status_cols]]
    deg_idx    <- which(status_vec != 0 & !is.na(status_vec))

    cont_cols  <- colnames(BigTab)[grepl(key, colnames(BigTab), fixed = TRUE)]
    sheet_dfs[[i]] <- BigTab[deg_idx, c("GENENAME", cont_cols), drop = FALSE]
    degs[[i]]      <- as.character(BigTab[["GENENAME"]][deg_idx])

    summary_rows[[i]] <- data.frame(
      contrast = cont.list[i],
      Down     = sum(status_vec == -1, na.rm = TRUE),
      Up       = sum(status_vec ==  1, na.rm = TRUE),
      FCH      = FCH,
      stringsAsFactors = FALSE
    )
  }

  summary_df <- do.call(rbind, summary_rows)
  if (method == "fdr")  summary_df$FDR  <- pcut
  if (method == "none") summary_df$PVAL <- pcut

  out_dir <- dirname(output_xlsx)
  if (!identical(out_dir, "") && !dir.exists(out_dir))
    dir.create(out_dir, recursive = TRUE)

  sanitize <- function(s) {
    s <- gsub("[\\[\\]:*?/\\\\]", "_", s, perl = TRUE)
    substr(s, 1L, 31L)
  }

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Summary")
  openxlsx::writeData(wb, "Summary", summary_df)

  for (i in seq_along(cont.list)) {
    sheet <- sanitize(cont.list[i])
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, sheet_dfs[[i]])
  }

  openxlsx::saveWorkbook(wb, output_xlsx, overwrite = TRUE)
  message("Wrote DEG workbook to ", output_xlsx)

  invisible(list(summary = summary_df, degs = degs))
}
