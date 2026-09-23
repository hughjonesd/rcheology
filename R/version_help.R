#' Get help for a function from an earlier R build
#'
#' Returns the help page recorded for a function in a released or development
#' build of R. Help from R 2.10.0 onwards is stored as Rd. Earlier help is
#' reconstructed as valid modern Rd from the text rendered by that version of
#' R; its original HTML is retained for HTML output.
#'
#' @param fn Character name of a function.
#' @param build R version, `"r-next"`, or `"r-devel"`. Defaults to the latest
#'   build available in the installed package.
#' @param package Package name. Required when the function name occurs in more
#'   than one package in the requested build.
#' @param format One of `"rd"`, `"text"`, or `"html"`.
#'
#' @return An object of class `Rd` for `format = "rd"`; otherwise a single
#'   character string containing plain text or an HTML fragment.
#' @export
#'
#' @examples
#' old_mean <- version_help("mean", "1.9.1", package = "base")
#' old_mean
.version_help_cache <- new.env(parent = emptyenv())

version_help <- function(fn, build = NULL, package = NULL,
                     format = c("rd", "text", "html")) {
  format <- match.arg(format)
  data <- rcheology::rcheology
  builds <- unique(data[c("Rversion", "status")])
  builds <- builds[order(
    as.package_version(builds$Rversion),
    match(builds$status, c("released", "r-next", "r-devel"))
  ), , drop = FALSE]

  if (is.null(build)) {
    build_row <- builds[nrow(builds), , drop = FALSE]
  } else if (build %in% c("r-next", "r-devel")) {
    build_row <- builds[builds$status == build, , drop = FALSE]
  } else {
    build_row <- builds[
      builds$status == "released" &
        as.package_version(builds$Rversion) == as.package_version(build),
      , drop = FALSE
    ]
  }
  if (nrow(build_row) != 1L) {
    stop("R build ", build, " is not available in this package")
  }

  found <- data[
    data$name == fn &
      data$Rversion == build_row$Rversion &
      data$status == build_row$status,
    , drop = FALSE
  ]
  if (! is.null(package)) {
    found <- found[found$package == package, , drop = FALSE]
  }
  found <- found[! is.na(found$help), , drop = FALSE]
  if (nrow(found) == 0L) stop("Couldn't find help for that function and build")
  if (length(unique(found$package)) > 1L) {
    stop("Multiple packages contain help for that function; specify package")
  }
  help_file <- system.file("rcheology-help.rds", package = "rcheology")
  if (! nzchar(help_file)) help_file <- file.path("inst", "rcheology-help.rds")
  if (! exists("records", envir = .version_help_cache, inherits = FALSE)) {
    .version_help_cache$records <- readRDS(help_file)
  }
  help <- unserialize(memDecompress(
    .version_help_cache$records[[found$help[1]]],
    type = "gzip"
  ))
  rd <- help$rd
  if (is.character(rd)) rd <- tools::parse_Rd(textConnection(rd))
  if (format == "rd") return(rd)

  if (format == "html" && ! is.na(help$html)) return(help$html)
  if (format == "text" && ! is.na(help$text)) return(help$text)

  output <- tempfile(fileext = if (format == "html") ".html" else ".txt")
  on.exit(unlink(output))
  if (format == "html") {
    tools::Rd2HTML(
      rd,
      out = output,
      package = found$package[1],
      no_links = TRUE
    )
  } else {
    tools::Rd2txt(rd, out = output, package = found$package[1])
  }
  rendered <- paste(
    readLines(output, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  if (format == "html") {
    rendered <- sub("(?is).*?<main>(.*)</main>.*", "\\1", rendered, perl = TRUE)
  } else {
    while (grepl(".\\x08", rendered, perl = TRUE)) {
      rendered <- gsub(".\\x08", "", rendered, perl = TRUE)
    }
  }
  rendered
}
