
test_that("numbers unchanged from version 4.3.2.0", {
  rcheology$rv <- as.package_version(rcheology$Rversion) 
  rch_4320 <- rcheology[rcheology$rv > "0.50" & rcheology$rv <= "4.3.2", ]
  rch_4320$rv <- NULL
  pkg_table <- table(rch_4320$Rversion, rch_4320$package)
  pkg_matrix <- unclass(pkg_table)
  expect_snapshot_value(pkg_matrix, style = "deparse")
})

test_that("status identifies released and daily builds", {
  expect_true(all(rcheology$status %in% c("released", "r-patched", "r-devel")))
  if (! any(rcheology$status %in% c("r-patched", "r-devel"))) {
    expect_identical(unique(rcheology$status), "released")
  }
})

test_that("function arguments have no trailing whitespace", {
  expect_false(any(grepl("[[:space:]]$", rcheology$args), na.rm = TRUE))
})

test_that("fun_changed handles daily build bounds", {
  if (all(c("r-patched", "r-devel") %in% rcheology$status)) {
    latest_release <- max(as.package_version(
      rcheology$Rversion[rcheology$status == "released"]
    ))
    expect_true(fun_changed("mean", from = as.character(latest_release),
      to = "r-patched", package = "base") %in% 0:2)
    expect_true(fun_changed("mean", from = "r-patched", to = "r-devel",
      package = "base") %in% 0:2)
    expect_equal(fun_changed("mean", from = "r-devel", to = "r-devel",
      package = "base"), 0)
    expect_error(fun_changed("mean", from = "r-devel", to = "r-patched",
      package = "base"),
      "from must not be later")
  } else {
    expect_error(fun_changed("mean", to = "r-patched", package = "base"),
      "not available")
    expect_error(fun_changed("mean", to = "r-devel", package = "base"),
      "not available")
  }
})

test_that("released version bounds keep their existing behavior", {
  expect_equal(fun_changed("debugonce", "3.4.0", "3.4.3"), 0)
  expect_equal(fun_changed("debugonce", "3.3.0", "3.4.3"), 1)
})
