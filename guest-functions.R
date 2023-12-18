getRVersion <- function () {
  if (exists("version")) return(version)
  if (exists("R.Version")) {
    if (is.list(R.Version)) {
      return(R.version)  
    } else {
      return(R.version())
    }
  }
  rv <- system("echo $RV", intern = T)
  bits <- strsplit(rv, ".")[[1]]
  major <- bits[1]
  minor <- paste(bits[-1], sep = ".")
  return(list(major = major, minor = minor))
}


pasteCollapse <- function (..., collapse = "") {
  x <- paste(..., sep = "")
  out <- ""
  if (length(x) == 0) return(out)
  
  for (i in seq(length(x))) {
    out <- paste(out, x[i], sep = "")
    if (i < length(x)) {
      out <- paste(out, collapse, sep = "")
    }
  }
  
  return(out)
}


myGetEnv <- if (exists("Sys.getenv")) {
  Sys.getenv 
} else if (exists("getenv")) {
  getenv
} else {
  function (x) {""}
}

mySetEnv <- if (exists("Sys.setenv")) {
  Sys.setenv
} else if (exists("Sys.putenv")) {
  Sys.putenv
} else {
  function (...) {NULL}
}


funArgs <- function (fn) {
  if (exists("args")) {
    a <- deparse(args(fn)) 
    res <- pasteCollapse(a[-length(a)], collapse = "") 
  } else {
    a <- deparse(fn)
    res <- pasteCollapse(a, collapse = "")
  }
  
  if (exists("sub")) {
    res <- sub("function *", "", res)
    res <- sub("\\{.*", "", res)
  } else {
    functionStripped <- strsplit(res, "function ")[[1]]
    if (length(functionStripped))  res[1] <- functionStripped[2]
    braceStripped <- strsplit(res, "{")[[1]]
    if (length(braceStripped))  res[1] <- braceStripped[1]
  }
  
  res
}


is.primitive <- function (x) {
  switch(typeof(x), special = , builtin = T, F)
}


nsToPos <- function (nsName) {
  nsPos <- nsName
  if (exists("search")) {
    searchPath <- search()
    nsPos <- which(searchPath == nsName)
  }
  nsPos
}


safelyTestGeneric <- function (fname, ns) {
  nsPos <- nsToPos(ns)
  if (is.primitive(get(fname, nsPos))) return(NA)
  if (! S4exists) return(F)
  
  return(isGeneric(fname)) # can't use namespacing for early R, so no methods::
}


checkExported <- function(objName, pkg) {
  if (pkg == "base") return(T)
  
  if (rv$major > 1 || (rv$major == 1 && rv$minor >= "7.0")) {
    # some packages used not to have a namespace. In this case we return NA
    # try(silent = *) is available in 1.7.0
    cond <- try(objName %in% getNamespaceExports(pkg), silent = T)
    if (inherits(cond, "try-error")) return(NA) 
    return(cond)
  } else {
    return(T)
  }
}


makeNsName <- function (pkg) {
  if (exists("search")) {
    searchPath <- search()
    pkgPattern <- paste(":", pkg, "$", sep = "")
    nsName <- grep(pkgPattern, searchPath, value = T)
  }
  if (length(nsName) == 0) nsName <- ".SystemEnv" # 0.49
  
  nsName
}


makeData <- function (pkg, priority) {
  nsName <- makeNsName(pkg)
  
  pkgObjNames  <- if (any(names(formals(ls)) == "all.names")) {
    do.call("ls", list(nsName, all.names = T)) # NSE weirdness in early R
  } else {
    do.call("ls", list(nsName))
  }
  pkgObjNames  <- sort(pkgObjNames)

  nsPos <- nsToPos(nsName)
  pkgObjs      <- lapply(as.list(pkgObjNames), get, pos = nsPos, inherits = T)
  # no sapply!
  types        <- unlist(lapply(pkgObjs, typeof))
  isExported   <- unlist(lapply(as.list(pkgObjNames), checkExported, pkg))
  classes      <- unlist(lapply(pkgObjs, function (x) pasteCollapse(class(x), collapse = "/")))
  S4generics   <- unlist(lapply(as.list(pkgObjNames), safelyTestGeneric, nsName))
  args         <- unlist(lapply(pkgObjs, function (x) if (is.function(x)) funArgs(x) else NA))
  
  thisPkgData <- data.frame(
    name     = I(pkgObjNames),
    type     = I(types),
    class    = I(classes),
    exported = isExported,
    S4generic  = S4generics,
    args     = I(args),
    package  = I(rep(pkg, length(pkgObjNames))), # rep necessary for old R
    priority = I(rep(priority, length(pkgObjNames))),
    Rversion = I(rep(shortRversion, length(pkgObjNames)))
  )
  
  thisPkgData
}


myRbind <- function (df1, df2) {
  data.frame(
    name = I(c(df1$name, df2$name)),
    type = I(c(df1$type, df2$type)),
    class = I(c(df1$class, df2$class)),
    exported = c(as.character(df1$exported), as.character(df2$exported)),
    S4generic = c(as.character(df1$S4generic), as.character(df2$S4generic)),
    args = I(c(df1$args, df2$args)),
    package = I(c(df1$package, df2$package)),
    priority = I(c(df1$priority, df2$priority)),
    Rversion = I(c(df1$Rversion, df2$Rversion))
  )
}



# backported
write.table <- function (x, file = "", append = F, quote = T, sep = " ", 
  eol = "\n", na = "NA", dec = ".", row.names = T, col.names = T, 
  qmethod = c("escape", "double")) 
{

  if (is.logical(quote) && quote) 
    quote <- which(unlist(lapply(x, function(x) is.character(x) || 
        is.factor(x))))

  i <- is.na(x)
  x <- as.matrix(x)
  if (any(i)) 
    x[i] <- na
  p <- ncol(x)
  d <- dimnames(x)
  if (is.logical(quote)) 
    quote <- if (quote) 
      1:p
  else NULL
  else if (is.numeric(quote)) {
    if (any(quote < 1 | quote > p)) 
      stop("invalid numbers in quote")
  }
  else stop("invalid quote specification")
  rn <- F
 
  if (!is.null(quote) && (p < ncol(x))) 
    quote <- c(0, quote) + 1
  if (is.logical(col.names)) 
    col.names <- if (is.na(col.names) && rn) 
      c("", d[[2]])
  else if (col.names) 
    d[[2]]
  else NULL
  else {
    col.names <- as.character(col.names)
    if (length(col.names) != p) 
      stop("invalid col.names specification")
  }
  if (!is.null(col.names)) {
    if (append) 
      warning("appending column names to file")
    if (!is.null(quote)) 
      col.names <- paste("\"", col.names, "\"", sep = "")
    cat(col.names, file = file, sep = rep(sep, p - 1), append = append)
    cat(eol, file = file, append = T)
    append <- T
  }
  qstring <- switch(qmethod, escape = "\\\\\"", double = "\"\"")
  for (i in quote) x[, i] <- paste("\"", gsub("\"", qstring, 
    x[, i]), "\"", sep = "")
  cat(t(x), file = file, sep = c(rep(sep, ncol(x) - 1), eol), 
    append = append)
}
