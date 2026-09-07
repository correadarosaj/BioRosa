#  This will extract a column of a data frame or tibble and convert into a vector
#' The function outputs a vector from a data frame or a tibble
#' @description The function extract a column from a data frame and converts it into a vector
#' @param data a data frame of tibble
#' @param var the name of the column to be extracted
#' @examples

pullvector<-function(data,var='GENENAME'){
  data |> dplyr::select({{var}}) |> pull()
}
