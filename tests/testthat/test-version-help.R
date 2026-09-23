test_that("version_help constructs released help URLs", {
  expect_identical(
    version_help("lm", "3.6.3", package = "stats"),
    paste0(
      "https://hughjonesd.github.io/rcheology/help/3.6.3/",
      "index.html?package=stats&name=lm"
    )
  )
})

test_that("version_help validates function and package choices", {
  expect_error(version_help("not-a-function", "3.6.3"), "Couldn't find")
  expect_error(version_help("coef", "3.6.3"), "stats, stats4")
  expect_error(version_help("lm", "99.0.0"), "not available")
})
