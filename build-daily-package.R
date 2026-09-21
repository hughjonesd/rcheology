args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("Usage: build-daily-package.R OUTPUT_DIR")
}

output_dir <- args[[1]]

load("data/rcheology.rda")
if (! setequal(unique(rcheology$status), c("released", "r-patched", "r-devel"))) {
  stop("The package data must contain released, r-patched, and r-devel builds")
}

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
