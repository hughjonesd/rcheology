#' Open a function's help page from an earlier R version
#'
#' Opens the historical HTML help page for a function in a web browser. Help is
#' available for released R versions and is hosted by the rcheology GitHub
#' Pages site.
#'
#' @param fn Character name of a function.
#' @param build Released R version. Defaults to the latest released version in
#'   the installed data.
#' @param package Package name. Required when the function occurs in more than
#'   one package in the requested version.
#'
#' @return The help URL, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' version_help("lm", "3.6.3", package = "stats")
#' }
version_help <- function(fn, build = NULL, package = NULL) {
  data <- rcheology::rcheology
  released <- data[data$status == "released", , drop = FALSE]
  versions <- sort(unique(as.package_version(released$Rversion)))
  if (is.null(build)) build <- as.character(utils::tail(versions, 1L))

  version_match <- as.package_version(released$Rversion) ==
    as.package_version(build)
  if (! any(version_match)) {
    stop("R version ", build, " is not available in this package")
  }

  found <- released[version_match & released$name == fn, , drop = FALSE]
  if (! is.null(package)) {
    found <- found[found$package == package, , drop = FALSE]
  }
  if (nrow(found) == 0L) {
    stop("Couldn't find that function and R version")
  }
  if (length(unique(found$package)) > 1L) {
    stop("Multiple packages contain that function; specify package")
  }

  query <- paste0(
    "package=", utils::URLencode(found$package[1L], reserved = TRUE),
    "&name=", utils::URLencode(fn, reserved = TRUE)
  )
  url <- paste0(
    "https://hughjonesd.github.io/rcheology/help/",
    as.character(as.package_version(build)),
    "/index.html?",
    query
  )
  if (interactive()) utils::browseURL(url)
  invisible(url)
}
