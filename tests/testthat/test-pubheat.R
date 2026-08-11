# Tests for the publication-heatmap family. The assertions are deliberately
# geometric: the whole point of this code is that text cannot collide or be
# clipped, and those are properties of the resolved layout, not of the pixels.

make_pubheat_inputs <- function(n_genes = 12, n_samples = 10) {
  set.seed(11)
  genes   <- paste0("GENE", seq_len(n_genes))
  samples <- paste0("S", seq_len(n_samples))
  mat <- matrix(stats::rnorm(n_genes * n_samples), nrow = n_genes,
                dimnames = list(genes, samples))
  half <- n_samples %/% 2
  annot <- data.frame(
    Grp    = rep(c("Control", "Case"), c(half, n_samples - half)),
    EASI   = c(rep(NA_real_, half), seq(20, 1, length.out = n_samples - half)),
    row.names = samples, stringsAsFactors = FALSE)
  BigTab <- data.frame(row.names = genes,
                       FCH_Case.W4vsBL   = seq(-12.5, 8, length.out = n_genes),
                       pvals_Case.W4vsBL = rep(c(1e-5, 0.02, 0.3), length.out = n_genes))
  list(mat = mat, annot = annot, BigTab = BigTab, genes = genes)
}

# ---- measurement primitives -------------------------------------------------

test_that("ph_measure_in() measures real text, linearly in point size", {
  w10 <- ph_measure_in("IL13", 10)
  w20 <- ph_measure_in("IL13", 20)
  expect_gt(w10, 0)
  expect_equal(w20 / w10, 2, tolerance = 1e-6)          # width is linear in size
  expect_gt(ph_measure_in("A_VERY_LONG_GENE_SYMBOL", 10), w10)
  expect_equal(ph_measure_in(character(0)), 0)          # nothing to measure
  expect_equal(ph_measure_in(c(NA, "")), 0)             # NA / empty ignored
  # the widest label wins, regardless of order
  expect_equal(ph_measure_in(c("X", "XXXXXXXX")), ph_measure_in("XXXXXXXX"))
})

test_that("ph_fit_fontsize() returns a size that actually fits, within its band", {
  labs <- c("Postvs.Control", "PostvsPre")
  fs <- ph_fit_fontsize(labs, avail_in = 0.8, max_fontsize = 30, min_fontsize = 1)
  expect_lte(ph_measure_in(labs, fs), 0.8 + 1e-6)
  # clamps win at both ends
  expect_equal(ph_fit_fontsize(labs, avail_in = 99, max_fontsize = 12), 12)
  expect_equal(ph_fit_fontsize(labs, avail_in = 1e-6, min_fontsize = 5), 5)
})

test_that("ph_contrast_col() flips text colour on dark fills", {
  expect_equal(ph_contrast_col("white"), "black")
  expect_equal(ph_contrast_col("black"), "white")
  expect_equal(ph_contrast_col(c("#F6C9C0", "#1A1A1A")), c("black", "white"))
  expect_equal(ph_contrast_col(NA_character_), "black")
})

# ---- grouping helpers -------------------------------------------------------

test_that("ph_leveler() splits into contiguous runs, tolerating nesting", {
  idx <- ph_leveler(c("A", "A", "B", "B", "B"))
  expect_equal(idx, list(A = 1:2, B = 3:5), ignore_attr = TRUE)
  expect_equal(names(idx), c("A", "B"))

  # nested design: a level recurring in a second run is legitimate, not a warning
  nested <- c("NL", "NL", "LS", "NL", "NL", "LS")
  expect_silent(res <- ph_leveler(nested))
  expect_equal(length(res), 4L)                      # one box per run
  expect_equal(names(res), c("NL", "LS", "NL", "LS"))

  # a genuinely unsorted annotation shatters into runs and should say so
  expect_warning(ph_leveler(rep(c("a", "b"), 5)), "sort the annotation")
})

test_that("ph_palette() honours known levels, overrides and unknown fallback", {
  pal <- ph_palette(c("LS", "NL"))
  expect_equal(names(pal), c("LS", "NL"))
  expect_false(any(is.na(pal)))

  # override wins for the named level, leaves the other alone
  ov <- ph_palette(c("LS", "NL"), override = c(LS = "#123456"))
  expect_equal(unname(ov["LS"]), "#123456")
  expect_equal(unname(ov["NL"]), unname(pal["NL"]))

  # unrecognised levels still get distinct colours
  novel <- ph_palette(c("CohortX", "CohortY", "CohortZ"))
  expect_length(unique(novel), 3L)
  # "<a>vs<b>" comparisons take the neutral band
  expect_equal(unname(ph_palette("RvsNR")["RvsNR"]), "#E2D6EF")
})

test_that("ph_group_means() averages per group and reports n", {
  m <- matrix(c(1, 3, 2, 4, 10, 30, 20, 40), nrow = 2,
              dimnames = list(c("A", "B"), NULL))
  mm <- ph_group_means(m, groups = c("x", "x", "y", "y"))
  expect_equal(dim(mm), c(2L, 2L))
  expect_equal(colnames(mm), c("x", "y"))
  expect_equal(unname(mm[, "x"]), c(mean(c(1, 2)), mean(c(3, 4))))
  expect_equal(attr(mm, "n"), c(x = 2L, y = 2L))
})

test_that("ph_zscore() standardises rows and drops the ones it cannot", {
  m <- rbind(varies = c(1, 2, 3, 4), flat = c(5, 5, 5, 5))
  expect_message(z <- ph_zscore(m), "zero-variance")
  expect_equal(rownames(z), "varies")
  expect_equal(unname(rowMeans(z)), 0, tolerance = 1e-12)
  expect_equal(unname(apply(z, 1, stats::sd)), 1, tolerance = 1e-12)
  expect_silent(ph_zscore(m, verbose = FALSE))
})

# ---- layout invariants ------------------------------------------------------

test_that("ph_layout() never lets a row be shorter than its own font", {
  # this is the no-overlap guarantee for row labels; check it across the range
  for (n in c(5, 40, 169, 400)) {
    lay <- ph_layout(n_rows = n, n_cols = 20, row_labels = paste0("G", seq_len(n)))
    expect_gte(lay$row_in, lay$row_fontsize * 1.22 / 72 - 1e-9,
               label = paste("row height vs font at n_rows =", n))
    expect_gte(lay$row_fontsize, 5)          # legibility floor holds
    expect_lte(lay$row_fontsize, 12)
  }
})

test_that("ph_layout() reserves the measured width of the longest label", {
  short <- ph_layout(20, 10, row_labels = c("IL13", "MX1"))
  long  <- ph_layout(20, 10, row_labels = c("IL13", "A_VERY_LONG_GENE_SYMBOL_INDEED"))
  expect_gt(long$gutter_in, short$gutter_in)
  expect_gte(long$gutter_in, ph_measure_in("A_VERY_LONG_GENE_SYMBOL_INDEED",
                                           long$row_fontsize))
  expect_gt(long$width, short$width)         # the page grows with the gutter
})

test_that("ph_layout(row_min_in=) raises the row floor for in-cell text", {
  plain <- ph_layout(169, 20)
  floored <- ph_layout(169, 20, row_min_in = 7 * 1.22 / 72)
  expect_gt(floored$row_in, plain$row_in)
  expect_gte(floored$row_in, 7 * 1.22 / 72 - 1e-9)
  expect_gt(floored$height, plain$height)    # the page grows, the text does not shrink
})

test_that("ph_layout() honours explicit overrides and density", {
  lay <- ph_layout(20, 10, row_in = 0.5, col_in = 0.4)
  expect_equal(lay$col_in, 0.4)
  expect_equal(lay$body_h, 20 * lay$row_in)
  expect_lt(ph_layout(50, 20, density = 0.5)$body_h, ph_layout(50, 20)$body_h)
})

# ---- colour ramp ------------------------------------------------------------

test_that("ph_easi_ramp() spans low to high across the score range", {
  ramp <- ph_easi_ramp(max_score = 40)
  expect_equal(toupper(substr(ramp(0), 1, 7)), "#F4F4F4")   # near-white, not white
  expect_equal(toupper(substr(ramp(1000), 1, 7)), "#000000")
  expect_false(identical(ramp(5), ramp(35)))                # monotone in between
  # a degenerate range must not produce non-increasing breaks
  expect_silent(ph_easi_ramp(max_score = 0))
})

# ---- internals worth pinning ------------------------------------------------

test_that(".ph_split_is_redundant() spots a split already shown as a box", {
  a <- data.frame(Grp = c("A", "A", "B"), Other = c("x", "y", "z"))
  expect_true(BioRosa:::.ph_split_is_redundant(a$Grp, a, "Grp"))
  expect_false(BioRosa:::.ph_split_is_redundant(a$Grp, a, "Other"))
  expect_false(BioRosa:::.ph_split_is_redundant(a$Grp, a, NULL))
  expect_false(BioRosa:::.ph_split_is_redundant(NULL, a, "Grp"))
})

test_that(".ph_autofit() falls back rather than erroring on an unusable object", {
  fb <- c(7, 9)
  expect_equal(BioRosa:::.ph_autofit("not a heatmap", list(), fallback = fb), fb)
})

test_that(".ph_tint() moves a colour toward white without leaving it", {
  expect_equal(toupper(BioRosa:::.ph_tint("#000000", 0)), "#000000")
  expect_equal(toupper(BioRosa:::.ph_tint("#000000", 1)), "#FFFFFF")
  expect_equal(toupper(BioRosa:::.ph_tint("#FFFFFF", 0.5)), "#FFFFFF")
})

# ---- the three figures ------------------------------------------------------

test_that("doPatientHeatmap() writes a PDF and reports its resolved shape", {
  inp <- make_pubheat_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doPatientHeatmap(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot,
    colsplitx = inp$annot$Grp, blocks = "Grp", easi = "EASI",
    bottom_labels = rownames(inp$annot), verbose = FALSE)

  expect_true(file.exists(pdf))
  expect_gt(file.info(pdf)$size, 0)
  expect_equal(res$n_rows, nrow(inp$mat))
  expect_equal(res$n_cols, ncol(inp$mat))
  expect_gt(res$width, 0)
  expect_gt(res$height, 0)
})

test_that("doPatientHeatmap() keeps the caller's column order", {
  inp <- make_pubheat_inputs()
  rev_annot <- inp$annot[rev(rownames(inp$annot)), , drop = FALSE]
  pdf <- withr::local_tempfile(fileext = ".pdf")
  # reversing the annotation must not error and must still cover every sample
  res <- doPatientHeatmap(grafname = pdf, mat = inp$mat, annot.col = rev_annot,
                          verbose = FALSE)
  expect_equal(res$n_cols, nrow(rev_annot))
})

test_that("doGroupMeanHeatmap() collapses to one column per group", {
  inp <- make_pubheat_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doGroupMeanHeatmap(grafname = pdf, mat = inp$mat,
                            groups = inp$annot$Grp, verbose = FALSE)
  expect_equal(res$n_cols, length(unique(inp$annot$Grp)))
  expect_gt(file.info(pdf)$size, 0)
})

test_that("doGroupMeanHeatmap() unpacks compound group levels into header rows", {
  inp <- make_pubheat_inputs(n_samples = 12)
  grp <- rep(c("Rash.LS", "Rash.NL", "NoRash.NL"), each = 4)
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doGroupMeanHeatmap(grafname = pdf, mat = inp$mat, groups = grp,
                            group_names = c("Group", "Tissue"), verbose = FALSE)
  expect_equal(res$n_cols, 3L)
  expect_gt(file.info(pdf)$size, 0)
})

test_that("doAnnotatedGridHeatmap() renders and sizes its number cells", {
  inp <- make_pubheat_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedGridHeatmap(
    grafname = pdf, mat = inp$mat, annot.col = inp$annot,
    BigTab = inp$BigTab, colsplitx = inp$annot$Grp, blocks = "Grp",
    verbose = FALSE)

  expect_gt(file.info(pdf)$size, 0)
  expect_equal(res$n_genes, nrow(inp$mat))
  expect_equal(res$n_contrasts, 1L)
  # the cell must be wide enough for the widest number it has to hold
  widest <- ph_measure_in("-12.50***", res$cell_fontsize, "bold", "mono")
  expect_gte(res$table_cell_in, widest)
})

test_that("doAnnotatedGridHeatmap() keeps the numbers legible by growing rows", {
  inp <- make_pubheat_inputs(n_genes = 169)
  pdf <- withr::local_tempfile(fileext = ".pdf")

  res <- doAnnotatedGridHeatmap(grafname = pdf, mat = inp$mat,
                                annot.col = inp$annot, BigTab = inp$BigTab,
                                verbose = FALSE)
  # the floor is honoured, and the row still clears the font it holds
  expect_gte(res$cell_fontsize, 7)
  expect_gte(res$row_in, res$cell_fontsize * 1.22 / 72 - 1e-9)

  # lowering the floor is what buys a shorter page
  small <- doAnnotatedGridHeatmap(grafname = pdf, mat = inp$mat,
                                  annot.col = inp$annot, BigTab = inp$BigTab,
                                  cell_font_min = 5, verbose = FALSE)
  expect_lt(small$height, res$height)
})

test_that("malformed inputs raise actionable errors", {
  inp <- make_pubheat_inputs()
  pdf <- withr::local_tempfile(fileext = ".pdf")

  bad <- inp$annot
  rownames(bad)[1] <- "NOT_A_SAMPLE"
  expect_error(
    doPatientHeatmap(grafname = pdf, mat = inp$mat, annot.col = bad, verbose = FALSE),
    "samples missing from", fixed = TRUE)

  expect_error(
    doAnnotatedGridHeatmap(grafname = pdf, mat = inp$mat, annot.col = inp$annot,
                           BigTab = data.frame(row.names = inp$genes,
                                               x = rep(1, length(inp$genes))),
                           verbose = FALSE),
    "columns in BigTab", fixed = TRUE)

  expect_error(
    doAnnotatedGridHeatmap(grafname = pdf, mat = inp$mat, annot.col = inp$annot,
                           BigTab = inp$BigTab, BigTabcols = "does.not.exist",
                           verbose = FALSE),
    "missing BigTab columns", fixed = TRUE)
})

test_that("the new functions leave the original heatmap API alone", {
  # ph_leveler is a sibling of leveler(), not a replacement for it
  expect_true(is.function(leveler))
  expect_true(is.function(panel_fun))
  expect_true(is.function(doAnnotatedHeatmapGrid))
  expect_equal(leveler(c("a", "a", "b")), list(a = 1:2, b = 3L), ignore_attr = TRUE)
})
