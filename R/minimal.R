#' This function creates a minimal example dataset
#' The output of this function is a matrix of log-fold changes and a matrix of p-values
#' @description Generation of artificial dataset for testing purposes


minimal<-function(){
require(tidyverse)
#--------------------------------------------
# create a small artificial dataset
#--------------------------------------------
  mat = cbind.data.frame(
    G1 = rnorm(3),
    G2 = rnorm(3),
    G3 = rnorm(3),
    G4 = rnorm(3),
    G5 = rnorm(3),
    G6 = rnorm(3),
    G7 = rnorm(3),
    G8 = rnorm(3),
    G9 = rnorm(3),
    G10 = rnorm(3)
  )

  mat= as.matrix(t(mat))
# assign colnames
  colnames(mat) = c('A','B','C')
#-----------------------------------------------
  annot = cbind.data.frame(
    Group = c('A','B','C')
  )

  row.names(annot) = c('A','B','C')
#-----------------------------------------------


  lgfch.matrix = cbind.data.frame(
    AvsB = runif(10,-2,2),
    AvsC = runif(10,-6,6),
    BvsC = runif(10,-2,2)
  ) |> as.matrix()

  fdr.matrix = cbind.data.frame(
    AvsB = runif(10,0,.25),
    AvsC = runif(10,0,.25),
    BvsC = runif(10,0,.25)
  ) |> as.matrix()



  colnames(lgfch.matrix) = c('lgfch_AvsB','lgfch_AvsC','lgfch_BvsC')
  colnames(fdr.matrix)   = c('pvals_AvsB','pvals_AvsC','pvals_BvsC')
  rownames(lgfch.matrix) = c('G1','G2','G3','G4','G5','G6','G7','G8','G9','G10')
  rownames(fdr.matrix) = rownames(lgfch.matrix)

  lgfch.matrix = as.matrix(lgfch.matrix)
  fdr.matrix = as.matrix(fdr.matrix)

return(list(mat = mat, lgfch = lgfch.matrix, fdr = fdr.matrix, annot = annot))

}


