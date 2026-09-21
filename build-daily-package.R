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

devel_version <- unique(devel$Rversion)
if (length(devel_version) != 1L) stop("R-devel data has multiple versions")
description <- readLines("DESCRIPTION")
description[grepl("^Version:", description)] <- paste0("Version: ", devel_version, ".9000")
writeLines(description, "DESCRIPTION")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(rcheology, file.path(output_dir, "rcheology-daily.csv"),
  row.names = FALSE, na = "")
saveRDS(rcheology, file.path(output_dir, "rcheology-daily.rds"),
  compress = "xz", version = 2)

metadata_files <- file.path(input_dir, c(
  "r-patched-metadata.csv", "r-devel-metadata.csv"
))
metadata <- do.call(rbind, lapply(metadata_files, read.csv,
  stringsAsFactors = FALSE))
write.csv(metadata, file.path(output_dir, "snapshot-metadata.csv"),
  row.names = FALSE, na = "")

snapshot_description <- paste(
  metadata$status,
  metadata$version_string,
  paste0("r", metadata$svn_revision),
  sep = ": "
)
snapshot_date <- substr(max(metadata$generated_at), 1L, 10L)
writeLines(
  paste0("Daily snapshots ", snapshot_date, " (",
    paste(snapshot_description, collapse = "; "), ")"),
  file.path(output_dir, "commit-message.txt")
)
writeLines(c(
  "Daily development package built automatically from:",
  "",
  paste0("- ", snapshot_description),
  "",
  "Install the current snapshot with:",
  "",
  "```r",
  "install.packages(\"rcheology-daily.tar.gz\", repos = NULL, type = \"source\")",
  "```",
  "",
  "The automatic GitHub source archives belong to the fixed release tag; use",
  "the `rcheology-daily.tar.gz` asset for the current daily package."
), file.path(output_dir, "release-notes.md"))
