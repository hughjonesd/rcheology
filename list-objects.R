#! Rscript
#

options(error = traceback)

ip <- rownames(installed.packages())
pkg_data <- data.frame(
        name     = character(0), 
        type     = character(0),
        class    = character(0),
       # S3method = character(0),
        generic  = logical(0),
        args     = character(0),
        package  = character(0),
        Rversion = character(0)
      )
rv <- R.Version()
short_rversion <- paste(rv$major, rv$minor, sep = ".")

get_args <- function (fn) {
  a <- deparse(args(fn))
  res <- paste(a[-length(a)], collapse = "")
  res <- sub("^function ", "", res)
  
  res
}

for (pkg in ip) {
  try({
    if (! require(pkg, character.only = TRUE)) {
      warning(sprintf("Could not load %s", pkg))
      break
    }
    
    ns_name <- paste("package:", pkg, sep = "")
    pkg_obj_names <- ls(ns_name) 
    pkg_obj_names <- sort(pkg_obj_names)
    pkg_objs      <- lapply(pkg_obj_names, get, ns_name)
    types         <- sapply(pkg_objs, typeof)
    classes       <- sapply(pkg_objs, function (x) paste(class(x), collapse = "/"))
    generics      <- sapply(pkg_obj_names, methods::isGeneric)
    args          <- sapply(pkg_objs, function (x) if (is.function(x)) get_args(x) else NA) 
    
    this_pkg_data <- data.frame(
            name     = pkg_obj_names,
            type     = types,
            class    = classes,
            generic  = generics,
            args     = args,
            package  = pkg,
            Rversion = short_rversion
          )
    pkg_data <- rbind(pkg_data, this_pkg_data)
  })
}

# simulate write.csv for older Rs
write.table(pkg_data, 
        file = file.path("docker-data", paste("pkg_data-R-", short_rversion, ".csv", sep = "")),
        row.names = FALSE,
        dec       = ".",
        sep       = ",",
        qmethod   = "double",
        col.names = TRUE
      )
