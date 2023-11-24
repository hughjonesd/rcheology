
#' Data on base packages from current and previous versions of R
#' 
#' rcheology is a data package providing two data frames: 
#' 
#' * [rcheology] lists objects in all versions of R from 0.62.3 onwards.
#' * [Rversions] lists R versions and their release dates. NB: For a more complete 
#'   and "canonical" solution, see the 
#'   [rversions](https://cran.r-project.org/package=rversions) package.
#' 
#' The version of the rcheology package reflects the latest R version to be included in the data, 
#' e.g. 3.5.1.x contains data up to and including R 3.5.1.
#' 
#' An online app for data exploration is available at <https://hughjonesd.shinyapps.io/rcheology/>.
#' 
#' @includeRmd data-where-from.Rmd
#' 
#' @section Limitations:
#' 
#' * Functions not built on the relevant platform - e.g. Windows functions - are not included.
#' 
#' @section Historical quirks:
#' 
#' * In 2.9.0, package Matrix was mistakenly given priority `"Recommended"` not 
#'   `"recommended"` in the output of [installed.packages()].
#' * In 2.5.0, package rcompgen was given priority `NA`. The NEWS file records
#'   it as a recommended package.
#'   
#' Both these errors have been corrected in the rcheology data.
#' 
#' @docType package
#' @name rcheology-package
NULL

#' Data on objects from current and previous versions of R
#' 
#' A data frame with every function (and other object) in versions
#' of R from 1.0.1 onwards. Variables are:

#' * `package`: package the object comes from
#' * `name`: name of the object
#' * `Rversion`: version of R as major.minor.patch
#' * `type`: Result of calling [typeof()] on the object
#' * `class`: [class()] of the object, separated by slashes if there are multiple classes.
#' * `exported`: `TRUE` if the object name was found in [getNamespaceExports()]. True for 
#'    anything in the "base" package. `NA` if the package does not have a namespace 
#'    (e.g. "datasets" in early versions).
#' * `generic`: `TRUE` if the object is an S4 generic according to 
#'   [`methods::isGeneric()`][methods::GenericFunctions]
#' * `priority`: `"base"` for base packages, `"recommended"` for recommended
#'   packages. `NA` for earlier versions of R (pre 1.6.0) when the priority 
#'   concept did not exist.
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
