
test_that("numbers unchanged from version 4.3.2.0", {
  rcheology$rv <- as.package_version(rcheology$Rversion) 
  rch_4320 <- rcheology[rcheology$rv > "0.50" & rcheology$rv <= "4.3.2", ]
  rch_4320$rv <- NULL
  pkg_table <- table(rch_4320$Rversion, rch_4320$package)
  pkg_matrix <- unclass(pkg_table)
  expect_snapshot_value(pkg_matrix, style = "deparse")
})
