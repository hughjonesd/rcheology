
#' Data on base packages from current and previous versions of R
#' 
#' rcheology is a data package providing two data frames: 
#' 
#' * [rcheology] lists objects in all versions of R from 2.0.0 onwards.
#' * [Rversions] lists R versions and their release dates.
#' 
#' The version of the rcheology package reflects the latest R version to be included in the data, 
#' e.g. 3.5.1.x contains data up to and including R 3.5.1.
#' 
#' An online app for data exploration is available at <https://hughjonesd.shinyapps.io/rcheology/>.
#' 
#' @section How the data is created:
#' 
#' Previous R versions are downloaded and installed on a Docker image. Objects in 
#' all base packages are then listed. (Note that recommended packages, like `nnet` or `MASS`,
#' are not installed.) For functions, the [formals()] of the function are recorded.
#' 
#' * Versions 3.0.1 and up are installed from the 
#' [CRAN apt repositories for Ubuntu Trusty Tahr](https://cran.r-project.org/bin/linux/ubuntu/trusty/). Version 3.5.0 and up use a 
#' [special repository](https://cran.r-project.org/bin/linux/ubuntu/trusty-cran35/).
#' 
#' * Versions 2.5.1 to 3.0.0 are built from source on [Ubuntu Lucid Lynx](https://hub.docker.com/r/yamamuteki/ubuntu-lucid-i386/).
#' 
#' * Versions 1.2.3 to 2.4.1 are built from source on [Debian Sarge](https://hub.docker.com/r/debian/eol/).
#' 
#' * Versions 1.0.1 to 1.2.2, and versions 1.7.0 and 1.7.1, are built from source on [Debian Woody](https://hub.docker.com/r/debian/eol/).
#' 
#' @section Limitations:
#' 
#' * Functions not built on the relevant platform - e.g. Windows functions - are not included.
#' * Because data is collected using the original R version, it is subject to changes in the way
#'   R works. For example, before 2.5.0, [args()] didn't work on `Primitive` functions, so
#'   those functions have no value in the `args` column.
#' 
#' @docType package
#' @name rcheology-package
NULL

#' Data on objects from current and previous versions of R
#' 
#' A data frame with every function (and other object) in versions
#' of R from 2.0.0 onwards. Variables are:

#' * `package`: package the object comes from
#' * `name`: name of the object
#' * `Rversion`: version of R as major.minor.patch
#' * `type`: Result of calling [typeof()] on the object
#' * `class`: [class()] of the object, separated by slashes if there are multiple classes.
#' * `exported`: `TRUE` if the object name was found in [getNamespaceExports()]
#' * `generic`: `TRUE` if the object is an (S4) generic according to [methods::isGeneric()]
#' * `args`: the arguments of the function, or NA for non-functions
#' 
#' @name rcheology 
NULL



#' Previous R versions with dates
#' 
#' A data frame with 2 variables:
#' * `Rversion`: version of R as major.minor.patch
#' * `date`: date of release
#' 
#' This goes back to 0.x releases. For 2.15.1-w, see 
#' [here](https://cran.r-project.org/src/base/R-2/README-2.15.1-w).
#' 
#' @name Rversions 
NULL



#' Check if a core R function changed between R versions
#'
#' @param fn Character name of a function in a core R package.
#' @param from Minimum R version (optional).
#' @param to Maximum R version (optional).
#' @param package Name of the package (optional).
#' 
#' @return 0 if there was no change. 1 if the function's arguments changed.
#'   2 if the function was not present in all versions. If the function can't
#'   be found or exists in multiple packages, throws an error.
#' @export
#'
#' @examples
#' fun_changed("debugonce")
#' \donttest{
#' fun_changed("debugonce", "3.4.0", "3.4.3")
#' fun_changed("debugonce", "3.3.0", "3.4.3")
#' }
fun_changed <- function (fn, from = NULL, to = NULL, package = NULL) {
  rch <- rcheology::rcheology
  vns <- as.package_version(rch$Rversion) 
  # unique.character MUCH faster than unique.package_version:
  relevant_vns <- as.package_version(unique(rch$Rversion))
  range <- rch$name == fn
  if (! is.null(package)) range <- range & rch$package == package
  if (! is.null(from))    {
    from <- as.package_version(from)
    range <- range & vns >= from
    relevant_vns <- relevant_vns[relevant_vns >= from]
  }
  if (! is.null(to)) {
    to   <- as.package_version(to)
    range <- range & vns <= to
    relevant_vns <- relevant_vns[relevant_vns <= to]
  }
  fns <- rch[range, , drop = FALSE]
  args <- fns$args
  if (length(unique(fns$package)) > 1) stop("Multiple functions found with that name")
  if (nrow(fns) == 0) stop("Couldn't find function of those versions")
  if (nrow(fns) < length(relevant_vns)) return(2)
  if (length(unique(args)) > 1) return(1)
  return(0)
}
