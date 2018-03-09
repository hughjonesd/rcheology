#! Rscript
#

options(error = traceback)

ip <- rownames(installed.packages())
pkg_data <- data.frame(
        name     = character(0), 
        type     = character(0),
        class    = character(0),
        S3method = character(0),
        generic  = character(0),
        package  = character(0),
        Rversion = character(0)
      )
rv <- R.Version()
short_rversion <- paste(rv$major, rv$minor, sep = ".")


for (pkg in ip) {
  try({
    if (! require(pkg, character.only = TRUE)) {
      warning(sprintf("Could not load %s", pkg))
      break
    }
    ns_name <- paste0("package:", pkg)
    pkg_obj_names <- ls(ns_name, sort = TRUE) 
    pkg_objs      <- lapply(pkg_obj_names, get, ns_name)
    types         <- sapply(pkg_objs, typeof)
    classes       <- sapply(pkg_objs, function (x) paste(class(x), collapse = "/"))
    S3methods     <- sapply(pkg_obj_names, utils::isS3method)
    generics      <- sapply(pkg_obj_names, methods::isGeneric)
    # generic_names <- getGenerics(ns_name)
    # pkg_obj_names <- c(pkg_obj_names, generic_names@.Data)
    
    this_pkg_data <- data.frame(
            name     = pkg_obj_names,
            type     = types,
            class    = classes,
            S3method = S3methods,
            generic  = generics,
            package  = pkg,
            Rversion = short_rversion
          )
    pkg_data <- rbind(pkg_data, this_pkg_data)
  })
}

write.csv(pkg_data, 
        file = file.path("docker-data", paste("pkg_data-R-", short_rversion, ".csv", sep = "")),
        row.names = FALSE, 
        na = "N/A"
      )
