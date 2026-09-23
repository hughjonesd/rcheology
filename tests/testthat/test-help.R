test_that("version_help returns modern Rd for legacy and compiled help", {
  legacy <- version_help("lm", "1.9.1", package = "stats")
  compiled <- version_help("lm", "2.10.0", package = "stats")

  expect_s3_class(legacy, "Rd")
  expect_s3_class(compiled, "Rd")
})

test_that("version_help renders readable text and HTML", {
  earliest_html <- version_help(
    ".C", "0.50", package = "base", format = "html"
  )
  legacy_html <- version_help(
    "lm", "1.9.1", package = "stats", format = "html"
  )
  compiled_html <- version_help(
    "lm", "2.10.0", package = "stats", format = "html"
  )
  compiled_text <- version_help(
    "lm", "2.10.0", package = "stats", format = "text"
  )

  expect_match(earliest_html, "Foreign Function Interface", fixed = TRUE)
  expect_match(legacy_html, "Fitting Linear Models", fixed = TRUE)
  expect_false(grepl("href=", legacy_html, fixed = TRUE))
  expect_match(compiled_html, "<h2>Fitting Linear Models</h2>", fixed = TRUE)
  expect_false(grepl("<!DOCTYPE", compiled_html, fixed = TRUE))
  expect_match(compiled_text, "Fitting Linear Models", fixed = TRUE)
  expect_false(grepl("\\x08", compiled_text, perl = TRUE))
})

test_that("version_help validates build and package choices", {
  expect_error(version_help("lm", "99.0.0"), "not available")
  expect_error(version_help("not-a-function", "2.10.0"), "Couldn't find help")
  expect_error(version_help("coef", "3.6.3"), "Multiple packages")
})
