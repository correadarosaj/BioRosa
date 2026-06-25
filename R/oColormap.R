#' Color palettes used by RXGR figures
#'
#' A faithful, self-contained reimplementation of the colour maps used by
#' OpenXGR (via the `o`-prefixed function library). Returns a palette
#' *function* `f(n)` that generates `n` interpolated colours, mirroring the
#' behaviour of the original `oColormap()`.
#'
#' Supported names include the `spectral` family used by the OpenXGR forest
#' plot (`"spectral"`, `"spectral.top"`, `"spectral.bottom"`, `"spectral.both"`),
#' plus a handful of common maps (`"jet"`, `"bwr"`, `"gbr"`, `"wyr"`,
#' `"rainbow"`). `"brewer.*"` names map to the corresponding sequential ramps.
#'
#' @param colormap character string naming the palette.
#' @param interpolate interpolation method passed to
#'   [grDevices::colorRampPalette()]: `"spline"` (default) or `"linear"`.
#' @return A function `f(n)` returning a character vector of `n` hex colours.
#' @examples
#' pal <- oColormap("spectral.top")
#' pal(5)
#' @export
oColormap <- function(colormap = "spectral", interpolate = c("spline", "linear")) {
  interpolate <- match.arg(interpolate)

  spectral <- c("#D53E4F", "#F46D43", "#FDAE61", "#FEE08B", "#FFFFBF",
                "#E6F598", "#ABDDA4", "#66C2A5", "#3288BD")

  cols <- switch(
    colormap,
    "spectral"        = rev(spectral),
    "spectral.both"   = rev(spectral)[c(-1, -length(spectral))],
    "spectral.top"    = rev(c("#D53E4F", "#F46D43", "#FDAE61", "#FEE08B", "#FFFFBF")),
    "spectral.bottom" = rev(c("#FFFFBF", "#E6F598", "#ABDDA4", "#66C2A5", "#3288BD")),
    "bwr"             = c("blue", "white", "red"),
    "gbr"            = c("green", "black", "red"),
    "wyr"             = c("white", "yellow", "red"),
    "jet"             = c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F",
                          "yellow", "#FF7F00", "red", "#7F0000"),
    "rainbow"         = grDevices::rainbow(7),
    "brewer.Reds"     = c("#FFF5F0", "#FCBBA1", "#FB6A4A", "#CB181D", "#67000D"),
    "brewer.Blues"    = c("#F7FBFF", "#C6DBEF", "#6BAED6", "#2171B5", "#08306B"),
    "brewer.Greens"   = c("#F7FCF5", "#C7E9C0", "#74C476", "#238B45", "#00441B"),
    NULL
  )

  if (is.null(cols)) {
    # Unknown name: fall back to the spectral ramp rather than erroring,
    # matching the permissive behaviour of the original.
    cols <- rev(spectral)
  }

  grDevices::colorRampPalette(cols, interpolate = interpolate)
}
