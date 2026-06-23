#' GuttmanLab curated pathway / gene-set list (May 2026)
#'
#' @description
#' The curated collection of gene sets ("pathways") maintained by the Guttman
#' laboratory and used across its inflammatory-skin-disease analyses (e.g.
#' atopic dermatitis and psoriasis transcriptomic signatures, immune and
#' structural gene panels, and disease meta-analysis derived MADAD/MAPP sets).
#' This is the May 2026 release of the list.
#'
#' Each element is a character vector of gene symbols; the element name is the
#' gene-set name. Many signature sets are split into directional `"... Up"` and
#' `"... Down"` halves (e.g. `"MADAD (LSvsNL) Up"` / `"... Down"`, where LS/NL/NN
#' denote lesional / non-lesional / normal tissue). A small number of sets may be
#' empty; entries are retained as released and are not deduplicated or filtered.
#'
#' This dataset is the package-shipped replacement for the lab's standalone
#' `ML_pathways_<date>.RData` file (the in-memory object was historically named
#' `ML`); use `BioRosa::guttman_pathways` instead of `load()`-ing that file.
#'
#' @format A named `list` of 350 character vectors. Each vector holds the gene
#'   symbols (HGNC) of one gene set; `names()` gives the gene-set names. The list
#'   spans 20,347 unique gene symbols.
#'
#' @source GuttmanLab pathways repository, version `version_may_2026`
#'   (`ML_pathways_2026_05_11.RData`).
#'
#' @examples
#' data("guttman_pathways", package = "BioRosa")
#' length(guttman_pathways)
#' head(names(guttman_pathways))
#' # genes in one immune set
#' \dontrun{
#' guttman_pathways[["MADAD (LSvsNL) Up"]]
#' }
"guttman_pathways"
