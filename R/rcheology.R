
#' Data on functions from current and previous versions of R
#' 
#' A data frame with every function (and other object) in versions
#' of R from 2.0.0 to 3.4.3. Variables are:
#' 
#' * `name`: name of the object
#' * `type`: Result of calling [typeof()] on the object
#' * `class`: [class()] of the object, separated by slashes if there are multiple classes.
#' * `generic`: `TRUE` if the object is an (S4) generic according to [methods::isGeneric()]
#' * `args`: the arguments of the function, or NA for non-functions
#' * `package`: package the object comes from
#' * `Rversion`: version of R as major.minor.patch
#' 
#' @name rcheology 
NULL



#' Previous R versions with dates
#' 
#' A data frame with 2 variables:
#' 
#' * `Rversion`: version of R as major.minor.patch
#' * `date`: date of release
#' 
#' This goes back to 0.x releases. Some version 1's are "recommended";
#' I don't know what these are. For 2.15.1-w, see 
#' https://cran.r-project.org/src/base/R-2/README-2.15.1-w
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
#' fun_changed("debugonce", "3.4.0", "3.4.3")
#' fun_changed("debugonce", "3.3.0", "3.4.3")
fun_changed <- function (fn, from = NULL, to = NULL, package = NULL) {
  vns <- as.package_version(rcheology$Rversion)
  relevant_vns <- unique(vns)
  range <- rcheology$name == fn
  if (! is.null(package)) range <- range & rcheology$package == package
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
  fns <- rcheology[range, , drop = FALSE]
  args <- fns$args
  if (length(unique(fns$package)) > 1) stop("Multiple functions found with that name")
  if (nrow(fns) == 0) stop("Couldn't find function of those versions")
  if (nrow(fns) < length(relevant_vns)) return(2)
  if (length(unique(args)) > 1) return(1)
  return(0)
}
