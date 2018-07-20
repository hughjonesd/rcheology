#! Rscript
#

try(options(error = traceback))

rv <- R.Version()
shortRversion <- paste(rv$major, rv$minor, sep = ".")
S4exists <- rv$major > 1 || (rv$major == 1 && rv$minor >= "4.0") # think doing string comparisons OK
if (S4exists) library(methods)

funArgs <- function (fn) {
  a <- deparse(args(fn))
  res <- paste(a[-length(a)], collapse = "")
  res <- sub("^function ", "", res)
  
  res
}

# backported
is.primitive <- function (x) switch(typeof(x), special = , builtin = TRUE, FALSE)

safelyTestGeneric <- function (fname, ns) {
  if (is.primitive(get(fname, ns))) return(NA)
  if (! S4exists) return(FALSE)
  
  return(isGeneric(fname)) # can't use namespacing for early R
}

makeData <- function (pkg) {
  nsName <- paste("package:", pkg, sep = "")
  pkgObjNames  <- do.call("ls", list(nsName)) # NSE weirdness in early R
  pkgObjNames  <- sort(pkgObjNames)
  pkgObjs      <- lapply(pkgObjNames, get, nsName)
  types        <- sapply(pkgObjs, typeof)
  classes      <- sapply(pkgObjs, function (x) paste(class(x), collapse = "/"))
  generics     <- sapply(pkgObjNames, safelyTestGeneric, nsName)
  args         <- sapply(pkgObjs, function (x) if (is.function(x)) funArgs(x) else NA)
  
  thisPkgData <- data.frame(
    name     = pkgObjNames,
    type     = types,
    class    = classes,
    generic  = generics,
    args     = args,
    package  = rep(pkg, length(pkgObjNames)),
    Rversion = rep(shortRversion, length(pkgObjNames)) # necessary for old R
  )
  
  thisPkgData
}


ip <- installed.packages()[, "Package"]
pkgData <- data.frame(
        name     = character(0), 
        type     = character(0),
        class    = character(0),
       # S3method = character(0),
        generic  = logical(0),
        args     = character(0),
        package  = character(0),
        Rversion = character(0)
      )

for (pkg in ip) {
  try({
    if (! library(pkg, character.only = TRUE, logical.return = TRUE)) {
      warning(paste("Could not load", pkg))
      break
    }
    thisPkgData <- makeData(pkg)
    pkgData <- rbind(pkgData, thisPkgData)
  })
}

# simulate write.csv for older Rs
if (rv$major == 1 && rv$minor <= "2.0") {
  write.table(pkgData, 
    file = file.path("docker-data", paste("pkg_data-R-", shortRversion, ".csv", sep = "")),
    row.names = FALSE,
    sep       = ",",
    col.names = TRUE,
    # quote = TRUE only gets applied to character cols in early R
    quote     = seq(1, ncol(pkgData)) 
  )
} else {
  write.table(pkgData, 
          file = file.path("docker-data", paste("pkg_data-R-", shortRversion, ".csv", sep = "")),
          row.names = FALSE,
          sep       = ",",
          qmethod   = "double",
          col.names = TRUE
        )
}
