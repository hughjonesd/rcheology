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
if (nrow(snapshot) < 4000L) stop("Snapshot has implausibly few rows")
if (! all(c("base", "stats", "utils", "methods", "MASS", "Matrix") %in%
  snapshot$package)) {
  stop("Snapshot is missing expected base or recommended packages")
}
if (anyDuplicated(snapshot[c("package", "name")])) {
  stop("Snapshot contains duplicate package/name pairs")
}
if (length(unique(snapshot$Rversion)) != 1L) {
  stop("Snapshot contains more than one R version")
}

snapshot$status <- status
snapshot <- snapshot[c(
  "package", "name", "Rversion", "status", "priority", "type", "exported",
  "hidden", "class", "S4generic", "args"
)]

svn_revision <- R.version[["svn rev"]]
if (is.null(svn_revision)) svn_revision <- NA_character_
metadata <- data.frame(
  status = status,
  Rversion = unique(snapshot$Rversion),
  version_string = R.version.string,
  R_status = R.version$status,
  svn_revision = svn_revision,
  platform = R.version$platform,
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  stringsAsFactors = FALSE
)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(snapshot, file.path(output_dir, paste0(status, ".rds")),
  compress = "xz", version = 2)
write.csv(metadata, file.path(output_dir, paste0(status, "-metadata.csv")),
  row.names = FALSE, na = "")
