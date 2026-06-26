#' Load an OpenXGR annotation / gene-set collection (`SET` object)
#'
#' OpenXGR stores its ontology and pathway annotations as pre-built `.RDS`
#' objects. This loader reproduces that mechanism: given an RDS base name (e.g.
#' `"org.Hs.egKEGG"`, `"org.Hs.egGOBP"`) it reads the object either from a local
#' directory or by downloading from a remote host -- exactly like the original
#' `oRDS(RDS, placeholder = ...)`.
#'
#' The returned `SET` object is a list whose `$info` is a data frame with a
#' list-column `member` (the genes annotated to each term) plus `name`, `id`,
#' `namespace` and `distance`. It can be passed directly to [oSEA()].
#'
#' @param RDS character; the RDS base name, without the `.RDS` extension.
#' @param placeholder where to read from. Either a local directory path, or a
#'   URL beginning `http://` / `https://`. Defaults to the public OpenXGR data
#'   host `http://www.comptransmed.pro/bigdata_openxgr`.
#' @param verbose logical; print progress.
#' @return The loaded R object (typically a `SET`-like list), or `NULL` on
#'   failure.
#' @details The download requires network access and the relevant `.RDS` file to
#'   exist on the host. For offline use, supply your own gene sets directly to
#'   [oSEA()] (a named list of gene vectors), or use the bundled
#'   [guttman_pathways].
#' @examples
#' \dontrun{
#' set <- oRDS("org.Hs.egKEGG")
#' eset <- oSEA(my_genes, set)
#' }
#' @export
oRDS <- function(RDS = NULL,
                 placeholder = "http://www.comptransmed.pro/bigdata_openxgr",
                 verbose = TRUE) {
  if (is.null(RDS) || !nzchar(RDS)) stop("`RDS` (the object base name) is required.")

  is_url <- grepl("^https?://", placeholder)
  if (is_url) {
    load_remote <- paste0(placeholder, "/", RDS, ".RDS")
    if (verbose) message(sprintf("oRDS: downloading '%s' ...", load_remote))
    destfile <- tempfile(RDS)
    on.exit(unlink(destfile), add = TRUE)
    ok <- tryCatch({
      utils::download.file(load_remote, destfile = destfile, quiet = !verbose,
                           mode = "wb")
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (!ok || !file.exists(destfile) || file.info(destfile)$size == 0) {
      warning(sprintf("oRDS: could not download '%s'.", load_remote))
      return(NULL)
    }
    out <- readRDS(destfile)
  } else {
    load_local <- file.path(placeholder, paste0(RDS, ".RDS"))
    if (verbose) message(sprintf("oRDS: reading '%s' ...", load_local))
    if (!file.exists(load_local)) {
      warning(sprintf("oRDS: file not found '%s'.", load_local))
      return(NULL)
    }
    out <- readRDS(load_local)
  }
  out
}
