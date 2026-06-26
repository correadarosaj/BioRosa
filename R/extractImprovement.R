#' Per-gene transcriptomic improvement in a lesional / non-lesional design
#'
#' @description
#' `extractImprovement()` quantifies how far treatment moves the lesional
#' transcriptome back toward the non-lesional (healthy) state, gene by gene, for
#' a paired baseline-lesional / baseline-non-lesional / post-treatment-lesional
#' design. From a matrix of group-mean expression it derives, per gene:
#'
#' * `Regulation = bl.ls - bl.nl` — baseline disease dysregulation
#'   (`Reg.Type` = Up / Down).
#' * `Modulation = post.ls - bl.ls` — treatment-induced change
#'   (`Mod.Type` = Up / Down).
#' * `Normalization = post.ls - bl.nl` — residual distance from healthy.
#' * `Improvement = -100 * Modulation / Regulation` — percent reversal of the
#'   baseline dysregulation (100% = fully normalised).
#'
#' @param PRE.LS,PRE.NL,POST.LS Column names in `coefs` holding the group means
#'   for baseline lesional, baseline non-lesional, and post-treatment lesional.
#' @param genes Character vector of genes to keep.
#' @param coefs A matrix or data frame of group-mean expression with genes as
#'   row names and the three group-mean columns named above.
#'
#' @return A data frame with one row per gene: `GENENAME`, `Improvement`,
#'   `Regulation`, `Reg.Type`, `Modulation`, `Mod.Type`, `Normalization`,
#'   `post.expr`, and the `PRE.LS` / `PRE.NL` / `POST.LS` column names used.
#' @export
extractImprovement = function(PRE.LS,PRE.NL,POST.LS,genes,coefs){

  d = coefs %>%
    data.frame()  %>%
    rownames_to_column('GENENAME') %>%
    dplyr::filter(GENENAME %in% genes) %>%
    dplyr::select(GENENAME,bl.ls = all_of(PRE.LS) , bl.nl = all_of(PRE.NL) , post.ls = all_of(POST.LS))%>%
    mutate(Regulation = bl.ls - bl.nl) %>%
    mutate(Reg.Type = ifelse(Regulation<0,'Down','Up'))%>%
    mutate(Modulation = post.ls - bl.ls ) %>%
    mutate(Mod.Type = ifelse(Modulation<0,'Down','Up'))%>%
    mutate(Normalization = post.ls-bl.nl)%>%
    mutate(post.expr = post.ls)%>%
    dplyr::filter(GENENAME %in% genes) %>%
    mutate(Improvement =  -100*(Modulation/Regulation))

  regData = d%>%
    dplyr::select(GENENAME,Improvement,Regulation,Reg.Type,Modulation,Mod.Type,Normalization,post.expr) %>%
    mutate(PRE.LS = PRE.LS, PRE.NL=PRE.NL, POST.LS = POST.LS)


  return(regData)
}
