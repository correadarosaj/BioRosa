# FGSEA & Classic Enrichment Pipeline
# Alberto Atencia Rodriguez
#
# Single self-contained, package-ready function. Drop this file into the
# `R/` directory of an R package and add the following to DESCRIPTION:
#
#   Imports: clusterProfiler, ReactomePA, msigdbr, enrichplot, fgsea,
#            org.Hs.eg.db, openxlsx, ggplot2, data.table, grDevices,
#            utils, stats


# msigdbr (>= 2025) no longer bundles the MSigDB gene sets: the first call
# downloads a zip from Zenodo into tools::R_user_dir("msigdbr", "cache") and
# later calls read per-collection .rds files extracted from it. If that first
# download or extraction is interrupted, the zip is left in place but the .rds
# files are missing -- and because msigdbr skips both download and extraction
# whenever the zip exists, every subsequent call fails permanently with
# "RDS not found: .../msigdb.<release>.<sp>.<coll>.rds". This wrapper detects
# that state, wipes the stale cache, and retries once so a clean download and
# extraction can run.
.msigdbr_fetch <- function(...) {
  tryCatch(
    msigdbr::msigdbr(...),
    error = function(e) {
      if (!grepl("RDS not found", conditionMessage(e), fixed = TRUE)) stop(e)
      cache_dir <- tools::R_user_dir("msigdbr", "cache")
      message(
        "msigdbr cache at '", cache_dir, "' is incomplete ",
        "(interrupted first download?). Clearing it and re-downloading MSigDB."
      )
      unlink(cache_dir, recursive = TRUE)
      msigdbr::msigdbr(...)
    }
  )
}

#' Run a one-step enrichment pipeline from a gene list and its statistics
#'
#' @description
#' `enrichment_onestep()` is a single entry point that takes a
#' differential-expression result — described either by three parallel
#' vectors (`genes`, `log2FoldChange`, `padj`) or by a `BigTab` table plus a
#' `contrast` suffix (e.g. `"Drug.W16vsBL"`), from which the log2 fold-changes
#' and p-values are read directly — and runs the full standard
#' pathway-analysis battery in one call. The motivation is to remove the
#' boilerplate (DEG splitting, ID conversion, per-collection looping,
#' plot saving, Excel export) that otherwise sits between a DE table and
#' a publishable enrichment figure, while keeping every intermediate
#' result available for downstream inspection.
#'
#' Internally the function:
#'
#' 1. **Builds the candidate (UP / DOWN) sets for ORA.** When a `BigTab`
#'    status column is available (and `ora_from_status = TRUE`), genes with
#'    status `1` form the **UP** set and status `-1` the **DOWN** set, with the
#'    universe being every gene that has a non-`NA` status. Otherwise the sets
#'    are derived from thresholds: `padj < padj_cutoff` together with
#'    `log2FoldChange > log2fc_cutoff` (UP) or `< -log2fc_cutoff` (DOWN), and
#'    the universe is every gene with a non-`NA` `padj`.
#' 2. **Runs FGSEA** against the MSigDB Hallmark, GO_BP (`C5 / BP`), and
#'    Reactome (`C2 / REACTOME`) collections. GSEA is run **once on the full
#'    gene list ranked by the `rank_by` statistic** (default `log2FoldChange`)
#'    — not on a `padj`-filtered or UP/DOWN-split subset — because its
#'    statistic depends on where a set's members fall across the *entire*
#'    ranking, with direction encoded in the sign of the NES. One worksheet per
#'    collection is saved to `FGSEA_results.xlsx`.
#' 3. **Runs over-representation analysis (ORA)** on each direction:
#'    `clusterProfiler::enrichGO` for GO `BP`, `MF`, `CC`;
#'    `ReactomePA::enrichPathway`; `clusterProfiler::enrichKEGG`
#'    (organism `"hsa"`); and `clusterProfiler::enricher` against MSigDB
#'    Hallmark. SYMBOL → ENTREZ conversion is done with
#'    `clusterProfiler::bitr` only for the backends that require Entrez
#'    IDs (Reactome, KEGG).
#' 4. **Runs `gseGO`** with `ont = "ALL"` once on the same full ranked list
#'    (again, not split by direction), then collapses redundant terms with
#'    `clusterProfiler::simplify(cutoff = 0.7, by = "p.adjust")`.
#' 5. **Persists everything to `output_dir`** — Excel tables (`.xlsx`),
#'    UP/DOWN gene lists (`.csv`), dotplots / treeplots / cnetplots /
#'    ridgeplots (`.png` and `.pdf`), and a timestamped `log.txt` capturing
#'    every save and any per-plot error. The function also returns the
#'    full set of in-memory result objects so callers can iterate without
#'    re-reading from disk.
#'
#' 6. **Runs the OpenXGR-style RXGR engine** (when `run_rxgr = TRUE`) on the
#'    same UP / DOWN sets via [rxgr_enrichment()], against MSigDB Hallmark,
#'    GO_BP, Reactome and the bundled [guttman_pathways] lab list. This adds
#'    Fisher's-exact statistics (enrichment z-score, odds ratio with 95% CI,
#'    FDR) plus a dotplot and forest plot per collection, written under
#'    `output_dir/RXGR/`.
#'
#' Each per-plot rendering step is wrapped in `tryCatch()`, so a single
#' failing plot (e.g. an `enrichplot::treeplot` on a result with too few
#' terms) is logged and skipped rather than aborting the whole pipeline.
#'
#' Human-only: uses `org.Hs.eg.db::org.Hs.eg.db`, KEGG organism `"hsa"`,
#' and `msigdbr` species `"human"`.
#'
#' @param genes Character vector of HGNC gene symbols. Optional when `BigTab`
#'   is supplied.
#' @param log2FoldChange Numeric vector of log2 fold-changes, same length
#'   and order as `genes`. Used as the GSEA ranking statistic and for the
#'   UP / DOWN split. Optional when `BigTab` is supplied.
#' @param padj Numeric vector of p-values (or adjusted p-values), same length
#'   and order as `genes`, used for thresholding. Optional when `BigTab` is
#'   supplied.
#' @param output_dir Directory for Excel tables, plots, and `log.txt`.
#'   Created if missing.
#' @param padj_cutoff Maximum `padj` for a gene to enter the ORA gene sets.
#' @param log2fc_cutoff Absolute `log2FoldChange` threshold. Genes with
#'   `log2FoldChange > log2fc_cutoff` form the UP set; genes with
#'   `log2FoldChange < -log2fc_cutoff` form the DOWN set.
#' @param pval_cutoff p-value cutoff passed to the ORA / GSEA backends.
#' @param qval_cutoff q-value cutoff passed to the ORA backends.
#' @param BigTab Optional data frame of differential-expression results indexed
#'   by gene (a `GENENAME` column, or row names). When supplied with `contrast`,
#'   `genes`, `log2FoldChange` and `padj` are read from it instead of the
#'   parallel-vector arguments. This is the same table consumed by
#'   [doAnnotatedHeatmapGrid()] and produced by [process_degs()].
#' @param contrast Single contrast suffix selecting the `BigTab` columns to use,
#'   e.g. `"Drug.W16vsBL"` reads `paste0(lgfch_prefix, contrast)` and
#'   `paste0(pval_prefix, contrast)`. Required when `BigTab` is supplied.
#' @param lgfch_prefix,pval_prefix Column-name prefixes for the log2
#'   fold-change and the p-value columns in `BigTab`. Defaults `"lgFCH_"` and
#'   `"pvals_"`; set `pval_prefix = "fdr_"` (or similar) to threshold on adjusted
#'   p-values.
#' @param status_prefix Prefix used to locate the DEG status column in `BigTab`
#'   for the chosen `contrast`; the column is the one whose name starts with
#'   `status_prefix` and ends with `_<contrast>` (e.g. `"Status_Drug.W16vsBL"`
#'   or `"StatusFCH1.3P0.05_Drug.W16vsBL"`). Default `"Status"`.
#' @param ora_from_status Logical. When `TRUE` (default) and a status column is
#'   found in `BigTab`, the ORA UP / DOWN sets are taken from it (`1` = UP,
#'   `-1` = DOWN) instead of the `padj` / `log2fc` thresholds.
#' @param rank_by Statistic used to rank genes for GSEA (`fgsea` / `gseGO`).
#'   One of `"lgFCH"` (log2 fold change, default), `"FCH"` (signed linear fold
#'   change `sign(lgFCH) * 2^|lgFCH|`), or `"signed_pval"`
#'   (`sign(lgFCH) * -log10(p)`). Affects the weighted enrichment score, since
#'   the magnitude of the statistic weights each gene.
#' @param run_rxgr Logical. When `TRUE` (default) the OpenXGR-style Fisher's
#'   exact set-enrichment engine ([rxgr_enrichment()]) is also run on the same
#'   UP / DOWN gene sets, reporting enrichment z-score, odds ratio with 95%
#'   confidence interval and FDR, and writing the matching dotplot and forest
#'   plot. Outputs go to `output_dir/RXGR/<collection>/`.
#' @param rxgr_sets Named list of gene-set collections for the RXGR engine, each
#'   element itself a named list of gene-symbol vectors. `NULL` (default) uses
#'   MSigDB Hallmark, GO biological process and Reactome together with the
#'   bundled [guttman_pathways] lab list.
#' @param rxgr_fdr FDR cut-off applied when keeping RXGR terms for the tables and
#'   figures. Default `0.05`.
#'
#' @return A named list:
#'   * `fgsea` — named per-collection list (`Hallmark`, `GO_BP`, `Reactome`),
#'     each a `data.table` of FGSEA results on the full ranked list (NES sign
#'     gives direction).
#'   * `ora`   — list with `$UP` and `$DOWN`, each holding `GO`, `Reactome`,
#'     `KEGG`, and `Hallmark` enrichment result objects.
#'   * `gsea`  — a single `gseGO` result object (run on the full ranked list).
#'   * `rxgr`  — list with `$UP` and `$DOWN`, each a per-collection
#'     [rxgr_enrichment()] result (`$table`, `$dotplot`, `$forest`, ...);
#'     `NULL` entries when `run_rxgr = FALSE` or a direction has no genes.
#'
#' @examples
#' \dontrun{
#' # (a) parallel vectors
#' degs <- readxl::read_excel("path/to/deg.xlsx")
#' res  <- enrichment_onestep(
#'   genes          = degs$SYMBOL,
#'   log2FoldChange = degs$log2FoldChange,
#'   padj           = degs$padj,
#'   output_dir     = "results/enrichment"
#' )
#'
#' # (b) straight from a BigTab + contrast suffix (reads lgFCH_/pvals_ columns)
#' res <- enrichment_onestep(
#'   BigTab     = BigTab,            # GENENAME-indexed DE table
#'   contrast   = "Drug.W16vsBL",
#'   output_dir = "results/Drug.W16vsBL"
#' )
#' }
#'
#' @export
enrichment_onestep <- function(genes          = NULL,
                               log2FoldChange = NULL,
                               padj           = NULL,
                               output_dir     = "output_enrichment",
                               padj_cutoff    = 0.05,
                               log2fc_cutoff  = 0,
                               pval_cutoff    = 0.05,
                               qval_cutoff    = 0.1,
                               BigTab          = NULL,
                               contrast        = NULL,
                               lgfch_prefix    = "lgFCH_",
                               pval_prefix     = "pvals_",
                               status_prefix   = "Status",
                               ora_from_status = TRUE,
                               rank_by         = c("lgFCH", "FCH", "signed_pval"),
                               run_rxgr        = TRUE,
                               rxgr_sets       = NULL,
                               rxgr_fdr        = 0.05) {

  rank_by <- match.arg(rank_by)

  # ---- Resolve inputs: parallel vectors OR a BigTab + contrast suffix ----
  if (!is.null(BigTab)) {
    if (!is.data.frame(BigTab)) stop("`BigTab` must be a data frame.")
    if (is.null(contrast) || length(contrast) != 1L) {
      stop("With `BigTab`, supply a single `contrast` suffix (e.g. \"Drug.W16vsBL\").")
    }
    sym <- if ("GENENAME" %in% colnames(BigTab)) as.character(BigTab$GENENAME)
           else rownames(BigTab)
    if (is.null(sym)) {
      stop("`BigTab` needs gene names in a `GENENAME` column or in its row names.")
    }
    lf_col <- paste0(lgfch_prefix, contrast)
    pv_col <- paste0(pval_prefix,  contrast)
    miss   <- setdiff(c(lf_col, pv_col), colnames(BigTab))
    if (length(miss)) {
      avail <- unique(sub(paste0("^", lgfch_prefix), "",
                          grep(paste0("^", lgfch_prefix), colnames(BigTab),
                               value = TRUE)))
      stop("Contrast column(s) not found in `BigTab`: ", paste(miss, collapse = ", "),
           ". Available contrasts: ", paste(avail, collapse = ", "))
    }
    genes          <- sym
    log2FoldChange <- BigTab[[lf_col]]
    padj           <- BigTab[[pv_col]]

    # Optional DEG status column (1 = UP, -1 = DOWN, 0 = n.s.), matched as
    # <status_prefix>..._<contrast> (e.g. "Status_..." or "StatusFCH1.3P0.05_...").
    if (ora_from_status) {
      cand <- colnames(BigTab)[startsWith(colnames(BigTab), status_prefix) &
                               endsWith(colnames(BigTab), paste0("_", contrast))]
      if (length(cand) == 1L) {
        status <- as.numeric(BigTab[[cand]])
      } else if (length(cand) > 1L) {
        stop("Multiple status columns match contrast '", contrast, "': ",
             paste(cand, collapse = ", "), ". Set `status_prefix` more specifically.")
      } else {
        message("No '", status_prefix, "...' column for contrast '", contrast,
                "'; ORA UP/DOWN sets fall back to padj/log2fc thresholds.")
      }
    }
  } else if (is.null(genes) || is.null(log2FoldChange) || is.null(padj)) {
    stop("`genes`, `log2FoldChange`, and `padj` are all required.")
  }

  if (length(genes) != length(log2FoldChange) ||
      length(genes) != length(padj)) {
    stop("`genes`, `log2FoldChange`, and `padj` must have the same length.")
  }
  if (!is.character(genes))         genes          <- as.character(genes)
  if (!is.numeric(log2FoldChange))  log2FoldChange <- as.numeric(log2FoldChange)
  if (!is.numeric(padj))            padj           <- as.numeric(padj)
  if (!exists("status", inherits = FALSE)) status <- NULL

  df <- data.frame(
    SYMBOL         = genes,
    log2FoldChange = log2FoldChange,
    padj           = padj,
    stringsAsFactors = FALSE
  )
  if (!is.null(status)) df$status <- status

  # Ranking statistic for GSEA (fgsea / gseGO). Magnitude matters for the
  # weighted enrichment score, so the choice of stat is exposed:
  #   "lgFCH"       log2 fold change (default)
  #   "FCH"         signed linear fold change, sign(lgFCH) * 2^|lgFCH|
  #   "signed_pval" sign(lgFCH) * -log10(p), significance with direction
  df$rank_stat <- switch(
    rank_by,
    lgFCH       = df$log2FoldChange,
    FCH         = sign(df$log2FoldChange) * 2 ^ abs(df$log2FoldChange),
    signed_pval = sign(df$log2FoldChange) * -log10(pmax(df$padj, 1e-300))
  )

  # ---- Nested helpers ----
  make_dir <- function(path) {
    if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  }

  write_log <- function(dir, msg) {
    tryCatch({
      make_dir(dir)
      ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      cat(paste0("[", ts, "] ", msg, "\n"),
          file = file.path(dir, "log.txt"), append = TRUE)
    }, error = function(e) message("Log could not be written: ", e$message))
  }

  save_plot <- function(plot, filename, width = 10, height = 8, dir = NULL) {
    tryCatch({
      ggplot2::ggsave(filename, plot = plot, width = width, height = height)
      if (!is.null(dir)) write_log(dir, paste("Saved plot:", filename))
    }, error = function(e) {
      msg <- paste("Error saving plot", filename, ":", e$message)
      message(msg)
      if (!is.null(dir)) write_log(dir, msg)
    })
  }

  save_enrich_excel <- function(enrich_obj, filepath, dir = NULL) {
    tryCatch({
      wb <- openxlsx::createWorkbook()
      openxlsx::addWorksheet(wb, "Results")
      tbl <- tryCatch(as.data.frame(enrich_obj), error = function(e) NULL)
      if (is.null(tbl) || nrow(tbl) == 0) {
        openxlsx::writeData(wb, "Results", data.frame(Message = "No results"))
      } else {
        openxlsx::writeData(wb, "Results", tbl)
      }
      openxlsx::saveWorkbook(wb, filepath, overwrite = TRUE)
      if (!is.null(dir)) write_log(dir, paste("Saved enrichment excel:", filepath))
    }, error = function(e) {
      msg <- paste("Error saving enrichment Excel", filepath, ":", e$message)
      message(msg)
      if (!is.null(dir)) write_log(dir, msg)
    })
  }

  plot_all_enrichment <- function(enrich_obj, outdir, prefix, max_show = 15) {
    if (is.null(enrich_obj) || nrow(enrich_obj@result) == 0) return(NULL)

    save_enrich_excel(enrich_obj@result,
                      file.path(outdir, paste0(prefix, ".xlsx")), outdir)

    tryCatch({
      p_dot <- enrichplot::dotplot(enrich_obj, showCategory = max_show) +
        ggplot2::ggtitle(paste(prefix, "Dotplot"))
      save_plot(p_dot, file.path(outdir, paste0(prefix, "_dotplot.png")), dir = outdir)
    }, error = function(e) write_log(outdir, paste("Error dotplot", prefix, e$message)))

    tryCatch({
      terms  <- enrichplot::pairwise_termsim(enrich_obj)
      p_tree <- enrichplot::treeplot(terms, showCategory = max_show, label_format = 30) +
        ggplot2::ggtitle(paste(prefix, "Treeplot"))
      save_plot(p_tree, file.path(outdir, paste0(prefix, "_treeplot.png")), dir = outdir)
    }, error = function(e) write_log(outdir, paste("Error treeplot", prefix, e$message)))

    tryCatch({
      p_map <- enrichplot::cnetplot(enrich_obj, showCategory = 10) +
        ggplot2::ggtitle(paste(prefix, "Cnetplot"))
      save_plot(p_map, file.path(outdir, paste0(prefix, "_cnetplot.pdf")), dir = outdir)
    }, error = function(e) write_log(outdir, paste("Error cnetplot", prefix, e$message)))

    invisible(TRUE)
  }

  perform_go <- function(sym, universe, outdir, label) {
    out <- list()
    for (ont in c("BP", "MF", "CC")) {
      ego <- clusterProfiler::enrichGO(
        gene          = sym,
        OrgDb         = org.Hs.eg.db::org.Hs.eg.db,
        universe      = universe,
        keyType       = "SYMBOL",
        ont           = ont,
        pAdjustMethod = "BH",
        pvalueCutoff  = pval_cutoff,
        qvalueCutoff  = qval_cutoff,
        readable      = TRUE
      )
      if (!is.null(ego) && nrow(ego@result) > 0) {
        plot_all_enrichment(ego, outdir, paste0("GO_", ont, "_", label))
      }
      out[[ont]] <- ego
    }
    out
  }

  perform_reactome <- function(entrez, outdir, label) {
    res <- ReactomePA::enrichPathway(
      gene         = entrez,
      organism     = "human",
      pvalueCutoff = pval_cutoff,
      qvalueCutoff = qval_cutoff,
      readable     = TRUE
    )
    if (!is.null(res) && nrow(res@result) > 0) {
      plot_all_enrichment(res, outdir, paste0("Reactome_", label))
    }
    res
  }

  perform_kegg <- function(entrez, outdir, label) {
    res <- clusterProfiler::enrichKEGG(
      gene         = entrez,
      organism     = "hsa",
      pvalueCutoff = pval_cutoff,
      qvalueCutoff = qval_cutoff
    )
    if (!is.null(res) && nrow(res@result) > 0) {
      plot_all_enrichment(res, outdir, paste0("KEGG_", label))
    }
    res
  }

  perform_hallmark <- function(sym, outdir, label) {
    sets      <- .msigdbr_fetch(species = "human", collection = "H")
    term2gene <- sets[, c("gs_name", "gene_symbol")]
    res <- clusterProfiler::enricher(
      gene         = sym,
      TERM2GENE    = term2gene,
      pvalueCutoff = pval_cutoff,
      qvalueCutoff = qval_cutoff
    )
    if (!is.null(res) && nrow(res@result) > 0) {
      plot_all_enrichment(res, outdir, paste0("Hallmark_", label))
    }
    res
  }

  # gseGO is GSEA: run it once on the full ranked list (see .ranked_list /
  # perform_fgsea_all). Up- and down-regulated terms are distinguished by the
  # sign of the enrichment score, so there is no UP/DOWN split.
  perform_gse <- function(df, outdir) {
    ranks <- .ranked_list(df)

    gse <- clusterProfiler::gseGO(
      geneList      = ranks,
      ont           = "ALL",
      keyType       = "SYMBOL",
      minGSSize     = 3,
      maxGSSize     = 800,
      pvalueCutoff  = pval_cutoff,
      verbose       = FALSE,
      OrgDb         = org.Hs.eg.db::org.Hs.eg.db,
      pAdjustMethod = "none"
    )
    if (nrow(gse@result) == 0) return(gse)

    gse2 <- clusterProfiler::simplify(
      gse, cutoff = 0.7, by = "p.adjust",
      select_fun = min, measure = "Wang", semData = NULL
    )
    plot_all_enrichment(gse2, outdir, "GSE")

    tryCatch({
      p_ridge <- enrichplot::ridgeplot(gse2, showCategory = 15) +
        ggplot2::labs(x = "enrichment distribution")
      save_plot(p_ridge, file.path(outdir, "GSE_ridgeplot.png"), dir = outdir)
    }, error = function(e) write_log(outdir, paste("Error ridgeplot:", e$message)))

    gse2
  }

  # GSEA must see the FULL ranked gene list (every gene with a finite
  # statistic), NOT a padj-filtered or direction-split subset: its null comes
  # from where a set's members fall across the whole ranking, and direction is
  # encoded in the sign of the NES. Duplicated symbols are collapsed to their
  # mean log2FC so the ranking vector has unique names.
  .ranked_list <- function(df) {
    rk <- df[is.finite(df$rank_stat) & !is.na(df$SYMBOL) & nzchar(df$SYMBOL), ]
    ranks <- tapply(rk$rank_stat, rk$SYMBOL, mean)
    # tapply() returns an array; gseGO requires a plain numeric vector for
    # `geneList`, so strip the array class while keeping the gene names.
    ranks <- stats::setNames(as.numeric(ranks), names(ranks))
    sort(ranks, decreasing = TRUE)
  }

  perform_fgsea_all <- function(df, output_excel) {
    make_dir(dirname(output_excel))
    ranks <- .ranked_list(df)
    if (length(ranks) < 2) stop("Too few ranked genes for FGSEA.")

    hm <- .msigdbr_fetch(species = "human", collection = "H")
    bp <- .msigdbr_fetch(species = "human", collection = "C5", subcollection = "BP")
    re <- .msigdbr_fetch(species = "human", collection = "C2", subcollection = "REACTOME")

    sets <- list(
      Hallmark = split(hm$gene_symbol, hm$gs_name),
      GO_BP    = split(bp$gene_symbol, bp$gs_name),
      Reactome = split(re$gene_symbol, re$gs_name)
    )

    wb <- openxlsx::createWorkbook()
    results <- list()

    for (set_name in names(sets)) {
      pathways <- sets[[set_name]]
      res <- fgsea::fgsea(pathways = pathways, stats = ranks,
                          minSize = 15, maxSize = 500)
      res <- data.table::as.data.table(res)
      results[[set_name]] <- res

      openxlsx::addWorksheet(wb, set_name)
      openxlsx::writeData(wb, set_name, res)

      if (nrow(res) > 0) {
        # plot the single most significant pathway (its NES sign shows the
        # direction of regulation). which.min on padj works on data.table and
        # data.frame regardless of the data.table cedta state.
        top_path <- res$pathway[which.min(res$padj)]
        png_path <- file.path(dirname(output_excel),
                              paste0("FGSEA_", set_name, "_top.png"))
        grDevices::png(png_path, width = 800, height = 600)
        on.exit(grDevices::dev.off(), add = TRUE)
        print(
          fgsea::plotEnrichment(pathways[[top_path]], ranks) +
            ggplot2::labs(title = paste(set_name, ":", top_path))
        )
      }
    }

    openxlsx::saveWorkbook(wb, output_excel, overwrite = TRUE)
    message("FGSEA Excel saved at: ", output_excel)
    results
  }

  # ---- Pipeline ----
  make_dir(output_dir)
  write_log(output_dir, "Pipeline started.")

  fgsea_excel   <- file.path(output_dir, "FGSEA_results.xlsx")
  fgsea_results <- perform_fgsea_all(df, fgsea_excel)

  # UP / DOWN sets for ORA: from the BigTab status column when available
  # (1 = UP, -1 = DOWN), otherwise from the padj / log2fc thresholds.
  if (!is.null(df$status)) {
    message("ORA UP/DOWN sets defined by the BigTab status column.")
    universe <- df$SYMBOL[!is.na(df$status)]
    up_df    <- df[!is.na(df$status) & df$status ==  1, ]
    down_df  <- df[!is.na(df$status) & df$status == -1, ]
  } else {
    universe <- df$SYMBOL[!is.na(df$padj)]
    up_df    <- df[!is.na(df$padj) & df$padj < padj_cutoff &
                     df$log2FoldChange >  log2fc_cutoff, ]
    down_df  <- df[!is.na(df$padj) & df$padj < padj_cutoff &
                     df$log2FoldChange < -log2fc_cutoff, ]
  }

  message("UP genes:   ", nrow(up_df))
  message("DOWN genes: ", nrow(down_df))
  utils::write.csv(up_df,   file.path(output_dir, "up_df.csv"),   row.names = FALSE)
  utils::write.csv(down_df, file.path(output_dir, "down_df.csv"), row.names = FALSE)

  entrez_up <- if (nrow(up_df)   > 0)
    clusterProfiler::bitr(up_df$SYMBOL,   fromType = "SYMBOL",
                          toType = "ENTREZID",
                          OrgDb = org.Hs.eg.db::org.Hs.eg.db) else NULL
  entrez_dn <- if (nrow(down_df) > 0)
    clusterProfiler::bitr(down_df$SYMBOL, fromType = "SYMBOL",
                          toType = "ENTREZID",
                          OrgDb = org.Hs.eg.db::org.Hs.eg.db) else NULL

  go_dir   <- file.path(output_dir, "GO")
  re_dir   <- file.path(output_dir, "Reactome")
  kegg_dir <- file.path(output_dir, "KEGG")
  hm_dir   <- file.path(output_dir, "Hallmark")
  gse_dir  <- file.path(output_dir, "gse")
  lapply(list(go_dir, re_dir, kegg_dir, hm_dir, gse_dir), make_dir)

  # ORA (over-representation) is the method that legitimately takes the UP /
  # DOWN significant gene sets.
  ora <- list(UP = list(), DOWN = list())

  if (nrow(up_df) > 0) {
    ora$UP$GO       <- perform_go(up_df$SYMBOL, universe, go_dir,  "UP")
    ora$UP$Reactome <- perform_reactome(entrez_up$ENTREZID, re_dir, "UP")
    ora$UP$KEGG     <- perform_kegg(entrez_up$ENTREZID, kegg_dir,   "UP")
    ora$UP$Hallmark <- perform_hallmark(up_df$SYMBOL, hm_dir,       "UP")
  }

  if (nrow(down_df) > 0) {
    ora$DOWN$GO       <- perform_go(down_df$SYMBOL, universe, go_dir,  "DOWN")
    ora$DOWN$Reactome <- perform_reactome(entrez_dn$ENTREZID, re_dir, "DOWN")
    ora$DOWN$KEGG     <- perform_kegg(entrez_dn$ENTREZID, kegg_dir,   "DOWN")
    ora$DOWN$Hallmark <- perform_hallmark(down_df$SYMBOL, hm_dir,     "DOWN")
  }

  # GSEA (gseGO) runs ONCE on the full ranked list; NES sign gives direction.
  gsea <- perform_gse(df, gse_dir)

  # ---- RXGR: OpenXGR-style Fisher / odds-ratio enrichment ----
  rxgr <- list(UP = NULL, DOWN = NULL)
  if (run_rxgr) {
    if (is.null(rxgr_sets)) {
      hm <- .msigdbr_fetch(species = "human", collection = "H")
      bp <- .msigdbr_fetch(species = "human", collection = "C5", subcollection = "BP")
      re <- .msigdbr_fetch(species = "human", collection = "C2", subcollection = "REACTOME")
      gp <- get("guttman_pathways", envir = asNamespace("BioRosa"))
      rxgr_sets <- list(
        Hallmark         = split(hm$gene_symbol, hm$gs_name),
        GO_BP            = split(bp$gene_symbol, bp$gs_name),
        Reactome         = split(re$gene_symbol, re$gs_name),
        guttman_pathways = gp[lengths(gp) > 0]
      )
    }
    rxgr_root <- file.path(output_dir, "RXGR"); make_dir(rxgr_root)
    queries   <- list(UP = up_df$SYMBOL, DOWN = down_df$SYMBOL)
    for (dir_name in names(queries)) {
      q <- queries[[dir_name]]
      if (length(q) == 0L) next
      rxgr[[dir_name]] <- list()
      for (sn in names(rxgr_sets)) {
        rxgr[[dir_name]][[sn]] <- tryCatch(
          rxgr_enrichment(
            data = q, set = rxgr_sets[[sn]], background = universe,
            FDR.cutoff = rxgr_fdr, min.overlap = 3, size.range = c(5, 5000),
            output.dir = file.path(rxgr_root, sn),
            prefix = paste0(sn, "_", dir_name), verbose = FALSE),
          error = function(e) {
            write_log(output_dir, paste("RXGR error", sn, dir_name, ":", e$message))
            NULL
          })
      }
    }
  }

  write_log(output_dir, "Pipeline finished.")
  message("=== PIPELINE IS FINISHED ===")

  list(fgsea = fgsea_results, ora = ora, gsea = gsea, rxgr = rxgr)
}
