# BioRosa

Annotated heatmaps and downstream analysis helpers for RNA-seq gene-expression
data. Built on top of `ComplexHeatmap`, with support for significance
annotations, multi-contrast log2 fold-change overlays, clinical metadata
tracks, GA-based predictor selection, rank-based subject scoring, and a
one-step enrichment pipeline (ORA + GSEA + FGSEA).

## Installation

Several dependencies live on Bioconductor, so install those first on a clean
machine:

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c(
  "ComplexHeatmap", "clusterProfiler", "ReactomePA",
  "msigdbr", "enrichplot", "fgsea", "org.Hs.eg.db"
))

if (!requireNamespace("remotes", quietly = TRUE))
  install.packages("remotes")

remotes::install_github("correadarosaj/BioRosa")
```

`remotes::install_github()` will pull the remaining CRAN dependencies
(`circlize`, `stringr`, `weights`, `plyr`, `tidyverse`, `GA`, `pROC`,
`openxlsx`, `ggplot2`, `data.table`) automatically.

### One-line alternative with `pak`

`pak` resolves Bioconductor and GitHub dependencies in a single call:

```r
install.packages("pak")
pak::pkg_install("github::correadarosaj/BioRosa")
```

### Pinning to a specific version

For reproducibility, pin to a tag, branch, or commit:

```r
remotes::install_github("correadarosaj/BioRosa", ref = "master")
remotes::install_github("correadarosaj/BioRosa", ref = "<commit-sha>")
```

## Quick start

```r
library(BioRosa)

# Annotated heatmap with a per-contrast fold-change side table
doAnnotatedHeatmap(
  grafname  = "heatmap.pdf",
  matx      = expr_matrix,        # genes x samples
  annot.col = sample_annotation,  # rownames = sample IDs
  cfx       = log2_fc_matrix,     # genes x contrasts
  fdx       = padj_matrix         # genes x contrasts
)

# One-step enrichment from a DEG result
res <- enrichment_onestep(
  genes          = degs$SYMBOL,
  log2FoldChange = degs$log2FoldChange,
  padj           = degs$padj,
  output_dir     = "results/enrichment"
)

# Rank-based subject scoring across a panel of variables
scores <- muScore(biomarker_matrix)
```

## Main functions

| Function | Purpose |
|---|---|
| `doAnnotatedHeatmap()` | Annotated heatmap with a per-contrast fold-change side table. |
| `doAnnotatedHeatmapGrid()` | Annotated heatmap whose fold-change table is a decimal-aligned grid with boxed group bands. |
| `enrichment_onestep()` | UP/DOWN split + GO/Reactome/KEGG/Hallmark ORA + GSEA + FGSEA + OpenXGR-style RXGR. |
| `muScore()` | Tie-aware, rank-based ordinal subject summary across variables. |
| `GA_logistic_regression()` | Genetic-algorithm predictor selection for binary logistic regression. |

See `?<function>` for full argument documentation.

## License

MIT.
