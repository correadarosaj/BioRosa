#' Map a grouping vector to a named list of position indices
#'
#' @description
#' `leveler()` turns a factor or character vector into a named list whose
#' elements are the integer positions of each distinct level, in order of first
#' appearance. This is the shape `ComplexHeatmap::anno_block(align_to = ...)`
#' (and the heatmap panel helpers) expect to align a band to the columns
#' belonging to each group.
#'
#' @param fact A factor or vector of group labels.
#'
#' @return A named list; each element holds the indices of `fact` equal to that
#'   level, named by the level.
#' @examples
#' leveler(c("A", "A", "B", "C", "B"))
#' @export
leveler<-function(fact){
  lev<-c()
  for (i in unique(fact)){
    lev<-c(lev,list(which(fact==i)))
  }
  names(lev)<-unique(fact)
  return(lev)}
