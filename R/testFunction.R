#' Sanity check that the package is installed and loadable
#'
#' @description
#' `testFunction()` is a trivial smoke test: it prints `"Hello, world!"`. It
#' exists only to confirm that an installed/updated BioRosa can be loaded and
#' that its functions are callable — useful right after a reinstall.
#'
#' @return Invisibly, the string `"Hello, world!"` (printed as a side effect).
#' @examples
#' testFunction()
#' @export
testFunction <- function() {
  print("Hello, world!")
}
