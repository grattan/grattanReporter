context("Spellchecker")

test_that("School funding report checks out", {
  check_spelling("SchoolFunding.tex", known.correct = c("SRS", "SE.XPD.TOTL.GD.XS", "WDI", "SSNP", "underfunded", "overfund[a-z]*", "NMS", "WPI", "DET", "phas", "NP", "SATs", "ENG", "th", "stds", "RCTs", "CAGR"), ignore.lines = 1551)
})