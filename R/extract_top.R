#  This function will return top differentially expressed genes
#' creates an output table including all genes in ebfit
#' @description For a pre-specified contrast this function will return the top differentially expressed genes
#' @param BigTab is a big tab object with GENENAME as the column with name of the gene
#' @param ebfit it is an object from eBayes function in limma package
#' @param pcut this is the cutoff for significance
#' @param cont this is the label of the contrast that is prefixed with lgFCH, FCH, pvals , fdr or status
#' @param method a parameter indicating which method is used for type-I error control (none, fdr , bonferroni)
#' @param n the number of genes to be included in the list of top differentially expressed
#' @param direction the direction of regulation induced by the treatment (both = both directions, up = upregulation, down = downregulation)
#' @examples

extract_top <-
  function(BigTab = NULL,
           ebfit,
           pcut = 0.05 ,
           cont = NULL ,
           method = 'none' ,
           n = 75 ,
           direction = 'both',
           coefColumn) {

    cont = paste0('_',cont)

    if (is.null(BigTab)) {
      return(NULL)


    } else{


      if(method == 'none'){
      BigTab = BigTab |> dplyr::select(GENENAME,
                                        fch = contains(paste0('lgFCH', cont)),
                                        pval = contains(paste0('pvals', cont)))
      }else if(method == 'fdr'){
        BigTab = BigTab |> dplyr::select(GENENAME,
                                          fch = contains(paste0('lgFCH', cont)),
                                          pval = contains(paste0('fdrs', cont)))
      }

      if (direction == 'both') {
        # The toptable function will capture the top genes according their log fold-change
        Top = topTable(
          fit = ebfit,
          coef = coefColumn,
          number = n,
          p.value = pcut,
          adjust.method = method,
          sort.by = 'logFC'
        ) |> data.frame() |>
          rownames_to_column('GENENAME') |>
          dplyr::select(GENENAME) |> pull()

      } else if (direction == 'up') {
        Top = BigTab |> dplyr::filter(pval < pcut &
                                         fch > 0) |>
          dplyr::arrange(desc(fch)) |> head(n) |>
          dplyr::select(GENENAME) |>
          pull()

      } else if (direction == 'down') {
        Top = BigTab |> dplyr::filter(pval < pcut &
                                         fch < 0) |>
          dplyr::arrange(fch) |> head(n) |>
          dplyr::select(GENENAME) |>
          pull()

      }
      return(Top)
    }

  }
