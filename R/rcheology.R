
#' Data on base packages from current and previous versions of R
#' 
#' rcheology is a data package providing two data frames: 
#' 
#' * [rcheology] lists objects in versions of R from 0.50 onwards.
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
#' * R 0.60 data is not yet included.
#' * Functions in package tcltk are not yet included before R 2.0.0.
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
#' @name rcheology-package
"_PACKAGE"

#' Data on objects from current and previous versions of R
#' 
#' A data frame with every function (and other object) in versions
#' of R from 0.50 onwards. Variables are:

#' * `package`: package the object comes from
#' * `name`: name of the object
#' * `Rversion`: version of R as major.minor.patch
#' * `status`: one of `"released"`, `"r-patched"`, or `"r-devel"`. The CRAN
#'   package contains released versions only; daily GitHub builds also contain
#'   the latest patched and development snapshots.
#' * `type`: Result of calling [typeof()] on the object
#' * `class`: [class()] of the object, separated by slashes if there are multiple classes.
#' * `exported`: `TRUE` if the object name was found in [getNamespaceExports()]. True for 
#'    anything in the "base" package. `NA` if the package does not have a namespace 
#'    (e.g. "datasets" in early versions).
#' * `hidden`: `TRUE` if the object name starts with `"."`. These objects
#'   are not reported by [ls()].
#' * `S4generic`: `TRUE` if the object is an S4 generic according to 
#'   [`methods::isGeneric()`][methods::GenericFunctions]. Note that in earlier
#'   versions of rcheology, this column was called `generic`.
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
#' @param package Name of the package (optional).
#' @param from Minimum R build (optional). This can be an R version or, in a
#'   daily GitHub build, `"patched"` or `"devel"`.
#' @param to Maximum R build (optional). This can be an R version or, in a
#'   daily GitHub build, `"patched"` or `"devel"`.
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
  if (! "status" %in% names(rch)) rch$status <- "released"

  status_order <- c("released", "r-patched", "r-devel")
  if (! all(rch$status %in% status_order)) {
    stop("Unknown R build status in the rcheology data")
  }

  builds <- unique(rch[c("Rversion", "status")])
  builds <- builds[order(
    as.package_version(builds$Rversion),
    match(builds$status, status_order)
  ), , drop = FALSE]
  builds$id <- paste(builds$Rversion, builds$status, sep = "/")
  build_versions <- as.package_version(builds$Rversion)

  bound_position <- function(x, side) {
    if (is.null(x)) {
      if (side == "from") return(1L)
      return(nrow(builds))
    }
    if (! is.character(x) || length(x) != 1L || is.na(x)) {
      stop(side, " must be one R version, \"patched\", or \"devel\"")
    }

    if (x %in% c("patched", "devel")) {
      wanted <- paste0("r-", x)
      position <- which(builds$status == wanted)
      if (length(position) == 0L) {
        stop(
          "The ", x, " snapshot is not available in this package; ",
          "install the daily GitHub build instead"
        )
      }
      return(position)
    }

    version <- tryCatch(
      as.package_version(x),
      error = function(e) stop(
        side, " must be one R version, \"patched\", or \"devel\""
      )
    )
    if (side == "from") {
      position <- which(build_versions >= version)
      if (length(position) == 0L) return(nrow(builds) + 1L)
      return(min(position))
    }

    position <- which(
      build_versions < version |
        (build_versions == version & builds$status == "released")
    )
    if (length(position) == 0L) return(0L)
    max(position)
  }

  first_build <- bound_position(from, "from")
  last_build <- bound_position(to, "to")
  if (first_build > last_build) stop("from must not be later than to")

  relevant_builds <- builds$id[seq.int(first_build, last_build)]
  build_id <- paste(rch$Rversion, rch$status, sep = "/")
  range <- rch$name == fn & build_id %in% relevant_builds
  if (! is.null(package)) range <- range & rch$package == package

  fns <- rch[range, , drop = FALSE]
  fn_builds <- unique(build_id[range])
  args <- fns$args
  if (length(unique(fns$package)) > 1) stop("Multiple functions found with that name")
  if (nrow(fns) == 0) stop("Couldn't find function of those versions")
  if (length(fn_builds) < length(relevant_builds)) return(2)
  if (length(unique(args)) > 1) return(1)
  return(0)
}
