# FGSEA & Classic Enrichment Pipeline
# Alberto Atencia Rodriguez
#
# Single self-contained, package-ready function. Drop this file into the
# `R/` directory of an R package and add the following to DESCRIPTION:
#
#   Imports: clusterProfiler, ReactomePA, msigdbr, enrichplot, fgsea,
#            org.Hs.eg.db, openxlsx, ggplot2, data.table, grDevices,
#            utils, stats


#' Run a one-step enrichment pipeline from a gene list and its statistics
#'
#' Given three parallel vectors describing a differential-expression result
#' (gene symbol, log2 fold-change, adjusted p-value), this function:
#'   * splits genes into UP and DOWN subsets using `padj_cutoff` and
#'     `log2fc_cutoff`,
#'   * runs over-representation analysis (GO BP/MF/CC, Reactome, KEGG,
#'     MSigDB Hallmark) on each subset,
#'   * runs GSEA against GO terms (`gseGO`) ranked by `log2FoldChange`,
#'   * runs FGSEA against the MSigDB Hallmark, GO_BP, and Reactome
#'     collections.
#'
#' Tables (.xlsx, .csv), plots (.png, .pdf), and a `log.txt` are written
#' under `output_dir`. The full set of result objects is also returned.
#'
#' Human-only: uses `org.Hs.eg.db`, KEGG organism `"hsa"`, and `msigdbr`
#' species `"human"`.
#'
#' @param genes Character vector of HGNC gene symbols.
#' @param log2FoldChange Numeric vector of log2 fold-changes, same length
#'   and order as `genes`. Used as the GSEA ranking statistic and for the
#'   UP / DOWN split.
#' @param padj Numeric vector of adjusted p-values, same length and order
#'   as `genes`. Used for thresholding.
#' @param output_dir Directory for Excel tables, plots, and `log.txt`.
#'   Created if missing.
#' @param padj_cutoff Maximum `padj` for a gene to enter the ORA gene sets.
#' @param log2fc_cutoff Absolute `log2FoldChange` threshold. Genes with
#'   `log2FoldChange > log2fc_cutoff` form the UP set; genes with
#'   `log2FoldChange < -log2fc_cutoff` form the DOWN set.
#' @param pval_cutoff p-value cutoff passed to the ORA / GSEA backends.
#' @param qval_cutoff q-value cutoff passed to the ORA backends.
#'
#' @return A named list:
#'   * `fgsea` — list with `$UP` and `$DOWN`, each a per-collection
#'     `data.table` of FGSEA results.
#'   * `ora`   — list with `$UP` and `$DOWN`, each holding `GO`, `Reactome`,
#'     `KEGG`, and `Hallmark` enrichment result objects.
#'   * `gsea`  — list with `$UP` and `$DOWN` `gseGO` result objects.
#'
#' @examples
#' \dontrun{
#' degs <- readxl::read_excel("path/to/deg.xlsx")
#' res  <- enrichment_onestep(
#'   genes          = degs$SYMBOL,
#'   log2FoldChange = degs$log2FoldChange,
#'   padj           = degs$padj,
#'   output_dir     = "results/enrichment"
#' )
#' }
#'
#' @export
enrichment_onestep <- function(genes,
                               log2FoldChange,
                               padj,
                               output_dir    = "output_enrichment",
                               padj_cutoff   = 0.05,
                               log2fc_cutoff = 0,
                               pval_cutoff   = 0.05,
                               qval_cutoff   = 0.1) {

  # ---- Validate inputs ----
  if (missing(genes) || missing(log2FoldChange) || missing(padj)) {
    stop("`genes`, `log2FoldChange`, and `padj` are all required.")
  }
  if (length(genes) != length(log2FoldChange) ||
      length(genes) != length(padj)) {
    stop("`genes`, `log2FoldChange`, and `padj` must have the same length.")
  }
  if (!is.character(genes))         genes          <- as.character(genes)
  if (!is.numeric(log2FoldChange))  log2FoldChange <- as.numeric(log2FoldChange)
  if (!is.numeric(padj))            padj           <- as.numeric(padj)

  df <- data.frame(
    SYMBOL         = genes,
    log2FoldChange = log2FoldChange,
    padj           = padj,
    stringsAsFactors = FALSE
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
    sets      <- msigdbr::msigdbr(species = "human", category = "H")
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

  perform_gse <- function(sub_df, outdir, label) {
    ranks <- sub_df$log2FoldChange
    names(ranks) <- sub_df$SYMBOL
    ranks <- sort(ranks, decreasing = TRUE)

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
    plot_all_enrichment(gse2, outdir, paste0("GSE_", label))

    tryCatch({
      p_ridge <- enrichplot::ridgeplot(gse2, showCategory = 15) +
        ggplot2::labs(x = "enrichment distribution")
      save_plot(p_ridge,
                file.path(outdir, paste0("GSE_", label, "_ridgeplot.png")),
                dir = outdir)
    }, error = function(e) write_log(outdir, paste("Error ridgeplot", label, e$message)))

    gse2
  }

  perform_fgsea_all <- function(df, output_excel) {
    make_dir(dirname(output_excel))
    flt <- df[!is.na(df$padj) & df$padj < padj_cutoff, ]
    if (nrow(flt) == 0) stop("No genes after filtering padj < ", padj_cutoff)

    up   <- flt[flt$log2FoldChange >  log2fc_cutoff, ]
    down <- flt[flt$log2FoldChange < -log2fc_cutoff, ]

    hm <- msigdbr::msigdbr(species = "human", category = "H")
    bp <- msigdbr::msigdbr(species = "human", category = "C5", subcategory = "BP")
    re <- msigdbr::msigdbr(species = "human", category = "C2", subcategory = "REACTOME")

    sets <- list(
      Hallmark = split(hm$gene_symbol, hm$gs_name),
      GO_BP    = split(bp$gene_symbol, bp$gs_name),
      Reactome = split(re$gene_symbol, re$gs_name)
    )

    wb <- openxlsx::createWorkbook()
    results <- list(UP = list(), DOWN = list())

    run_block <- function(sub_df, direction, set_name, pathways) {
      if (nrow(sub_df) == 0) return(NULL)
      ranks <- stats::setNames(sub_df$log2FoldChange, sub_df$SYMBOL)
      res   <- fgsea::fgsea(pathways = pathways, stats = ranks,
                            minSize = 15, maxSize = 500)
      res   <- data.table::as.data.table(res)
      results[[direction]][[set_name]] <<- res

      sheet <- paste0(set_name, "_", direction)
      openxlsx::addWorksheet(wb, sheet)
      openxlsx::writeData(wb, sheet, res)

      if (nrow(res) > 0) {
        top_path <- res[order(-res$NES)][1, ]$pathway
        png_path <- file.path(dirname(output_excel),
                              paste0("FGSEA_", set_name, "_", direction, "_top.png"))
        grDevices::png(png_path, width = 800, height = 600)
        on.exit(grDevices::dev.off(), add = TRUE)
        print(
          fgsea::plotEnrichment(pathways[[top_path]], ranks) +
            ggplot2::labs(title = paste(set_name, direction, ":", top_path))
        )
      }
      invisible(NULL)
    }

    for (sn in names(sets)) {
      run_block(up,   "UP",   sn, sets[[sn]])
      run_block(down, "DOWN", sn, sets[[sn]])
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

  universe <- df$SYMBOL[!is.na(df$padj)]
  up_df    <- df[!is.na(df$padj) & df$padj < padj_cutoff &
                   df$log2FoldChange >  log2fc_cutoff, ]
  down_df  <- df[!is.na(df$padj) & df$padj < padj_cutoff &
                   df$log2FoldChange < -log2fc_cutoff, ]

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

  ora  <- list(UP = list(), DOWN = list())
  gsea <- list(UP = NULL,   DOWN = NULL)

  if (nrow(up_df) > 0) {
    ora$UP$GO       <- perform_go(up_df$SYMBOL, universe, go_dir,  "UP")
    ora$UP$Reactome <- perform_reactome(entrez_up$ENTREZID, re_dir, "UP")
    ora$UP$KEGG     <- perform_kegg(entrez_up$ENTREZID, kegg_dir,   "UP")
    ora$UP$Hallmark <- perform_hallmark(up_df$SYMBOL, hm_dir,       "UP")
    gsea$UP         <- perform_gse(up_df, gse_dir, "UP")
  }

  if (nrow(down_df) > 0) {
    ora$DOWN$GO       <- perform_go(down_df$SYMBOL, universe, go_dir,  "DOWN")
    ora$DOWN$Reactome <- perform_reactome(entrez_dn$ENTREZID, re_dir, "DOWN")
    ora$DOWN$KEGG     <- perform_kegg(entrez_dn$ENTREZID, kegg_dir,   "DOWN")
    ora$DOWN$Hallmark <- perform_hallmark(down_df$SYMBOL, hm_dir,     "DOWN")
    gsea$DOWN         <- perform_gse(down_df, gse_dir, "DOWN")
  }

  write_log(output_dir, "Pipeline finished.")
  message("=== PIPELINE IS FINISHED ===")

  list(fgsea = fgsea_results, ora = ora, gsea = gsea)
}
