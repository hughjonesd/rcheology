
#' Data on functions from current and previous versions of R
#' 
#' A data frame with every function (and other object) in versions
#' of R from 3.0.1 to 3.4.3. Variables are:
#' 
#' * `name`: name of the object
#' * `type`: Result of calling [typeof()] on the object
#' * `class`: [class()] of the object, separated by slashes if there are multiple classes.
#' * `S3method`: `TRUE` if the object is an S3 method.
#' * `generic`: `TRUE` if the object is a generic according to [methods::isGeneric()]
#' * `package`: package the object comes from
#' * `Rversion`: version of R as major.minor.patch
#' 
#' @name rcheology 
NULL

