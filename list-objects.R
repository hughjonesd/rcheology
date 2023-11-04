#! Rscript
#

if (exists("try")) try(options(error = traceback)) # no traceback in 0.0

getRVersion <- function () {
  if (exists("version")) return(version)
  if (exists("R.Version")) {
    if (is.list(R.Version)) {
      return(R.version)  
    } else {
      return(R.version())
    }
  }
  warning("Couldn't find version string")
  return(NULL)
}

pasteCollapse <- function (..., collapse = "") {
  x <- paste(..., )
  out <- ""
  if (length(x) == 0) return(out)
  
  for (i in seq(length(x))) {
    out <- paste(out, x[i])
    if (i < length(x)) {
      out <- paste(out, collapse, sep = "")
    }
  }
  
  return(out)
}


rv <- getRVersion()
shortRversion <- paste(rv$major, rv$minor, sep = ".")
S4exists <- rv$major > 1 || (rv$major == 1 && rv$minor >= "4.0") # think doing string comparisons OK
if (S4exists) library(methods)


funArgs <- function (fn) {
  if (exists("args")) {
    a <- deparse(args(fn)) 
    res <- pasteCollapse(a[-length(a)], collapse = "") 
  } else {
    a <- deparse(fn)
    res <- pasteCollapse(a, collapse = "")
  }
  
  res[1] <- strsplit(res, "function ")[[1]][1] # get rid of 'function (', sub() may not exist
    
  res
}


is.primitive <- function (x) switch(typeof(x), special = , builtin = T, F)

safelyTestGeneric <- function (fname, ns) {
  if (is.primitive(get(fname, ns))) return(NA)
  if (! S4exists) return(F)
  
  return(isGeneric(fname)) # can't use namespacing for early R, so no methods::
}


checkExported <- function(objName, pkg) {
  if (pkg == "base") return(T)
  
  if (rv$major > 1 || (rv$major == 1 && rv$minor >= "7.0")) {
  # some packages used not to have a namespace. In this case we return NA
    cond <- try(objName %in% getNamespaceExports(pkg))
    if (inherits(cond, "try-error")) return(NA) 
    return(cond)
  } else {
    return(T)
  }
}

makeData <- function (pkg) {
  nsName <- paste("package:", pkg, sep = "")
  # no do.call
  pkgObjNames  <- do.call("ls", list(nsName, all.names = T)) # NSE weirdness in early R
  pkgObjNames  <- sort(pkgObjNames)

  pkgObjs      <- lapply(list(pkgObjNames), get, pos = nsName, inherits = F)
  # no sapply!
  types        <- unlist(lapply(pkgObjs, typeof))
  isExported   <- unlist(lapply(list(pkgObjNames), checkExported, pkg))
  classes      <- unlist(lapply(pkgObjs, function (x) paste(class(x), collapse = "/")))
  generics     <- unlist(lapply(pkgObjNames, safelyTestGeneric, nsName))
  args         <- unlist(lapply(pkgObjs, function (x) if (is.function(x)) funArgs(x) else NA))
  
  thisPkgData <- data.frame(
    name     = pkgObjNames,
    type     = types,
    class    = classes,
    exported = isExported,
    generic  = generics,
    args     = args,
    package  = rep(pkg, length(pkgObjNames)),
    Rversion = rep(shortRversion, length(pkgObjNames)) # necessary for old R
  )
  
  thisPkgData
}


# no installed.packages! and no library()
ip <- installed.packages()[, "Package"]
pkgData <- data.frame(
        name     = character(0), 
        type     = character(0),
        class    = character(0),
        exported = logical(0),
       # S3method = character(0),
        generic  = logical(0),
        args     = character(0),
        package  = character(0),
        Rversion = character(0)
      )

for (pkg in ip) {
  try({
    if (! library(pkg, character.only = T, logical.return = T)) {
      warning(paste("Could not load", pkg))
      break
    }
    thisPkgData <- makeData(pkg)
    pkgData <- rbind(pkgData, thisPkgData)
  })
}


if (rv$major <= 1 && rv$minor < "2.0") {
  source("write-table-backport.R")
}
# simulate write.csv for older Rs
write.table(pkgData, 
        file = paste("docker-data/pkg_data-R-", shortRversion, ".csv", sep = ""),
        row.names = F,
        sep       = ",",
        qmethod   = "double",
        col.names = T
      )

