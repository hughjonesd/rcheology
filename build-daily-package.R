args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: build-daily-package.R INPUT_DIR OUTPUT_DIR")
}

input_dir <- args[[1]]
output_dir <- args[[2]]

load("data/rcheology.rda")
if (! identical(unique(rcheology$status), "released")) {
  stop("The package data must contain released versions only")
}

patched <- readRDS(file.path(input_dir, "r-patched.rds"))
devel <- readRDS(file.path(input_dir, "r-devel.rds"))
if (! identical(unique(patched$status), "r-patched")) stop("Invalid patched data")
if (! identical(unique(devel$status), "r-devel")) stop("Invalid devel data")

rcheology <- rbind(rcheology, patched, devel)
status_order <- c("released", "r-patched", "r-devel")
rcheology <- rcheology[order(
  rcheology$package,
  rcheology$name,
  as.package_version(rcheology$Rversion),
  match(rcheology$status, status_order)
), ]
row.names(rcheology) <- NULL

usethis::use_data(rcheology, overwrite = TRUE, compress = "xz", version = 2)

description <- readLines("DESCRIPTION")
version_line <- grepl("^Version:", description)
if (sum(version_line) != 1L) stop("DESCRIPTION must contain one Version field")
released_version <- sub("^Version: *", "", description[version_line])
snapshot_date <- format(Sys.time(), "%Y%m%d", tz = "UTC")
daily_version <- paste(released_version, snapshot_date, sep = ".")
description[version_line] <- paste("Version:", daily_version)
writeLines(description, "DESCRIPTION")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(rcheology, file.path(output_dir, "rcheology-daily.csv"),
  row.names = FALSE, na = "")
saveRDS(rcheology, file.path(output_dir, "rcheology-daily.rds"),
  compress = "xz", version = 2)
