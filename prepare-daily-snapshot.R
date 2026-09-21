args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: prepare-daily-snapshot.R STATUS OUTPUT_DIR")
}

status <- args[[1]]
output_dir <- args[[2]]
if (! status %in% c("r-patched", "r-devel")) {
  stop("STATUS must be r-patched or r-devel")
}

input <- list.files("docker-data", pattern = "^pkg_data-R-.*\\.csv$", full.names = TRUE)
if (length(input) != 1L) stop("Expected exactly one extracted R data file")

snapshot <- read.csv(input, na.strings = "NA", stringsAsFactors = FALSE)
expected <- c(
  "name", "type", "class", "exported", "S4generic", "args", "package",
  "priority", "Rversion", "hidden"
)
if (! identical(names(snapshot), expected)) stop("Unexpected snapshot columns")
if (nrow(snapshot) == 0L) stop("Snapshot is empty")
if (length(unique(snapshot$Rversion)) != 1L) stop("Multiple R versions found")

snapshot$status <- status
snapshot <- snapshot[c(
  "package", "name", "Rversion", "status", "priority", "type", "exported",
  "hidden", "class", "S4generic", "args"
)]

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(snapshot, file.path(output_dir, paste0(status, ".rds")),
  compress = "xz", version = 2)
