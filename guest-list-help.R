#! Rscript

source("guest-functions.R")

stripRdSources <- function(x) {
  attr(x, "Rdfile") <- NULL
  attr(x, "srcref") <- NULL
  attr(x, "srcfile") <- NULL
  attr(x, "wholeSrcref") <- NULL
  if (is.list(x)) {
    for (i in seq_along(x)) x[[i]] <- stripRdSources(x[[i]])
  }
  x
}

rv <- getRVersion()
shortRversion <- paste(rv$major, rv$minor, sep = ".")
Rstatus <- if (is.null(rv$status) || rv$status == "") "released" else
  if (rv$status == "Under development (unstable)") "r-devel" else "r-next"

RHome <- myGetEnv("R_HOME")
if (RHome == "") RHome <- myGetEnv("RHOME")
if (RHome == "") RHome <- paste("/opt/R/", shortRversion, sep = "")
baseLibDir <- paste(RHome, "/library", sep = "")
if (! file.exists(baseLibDir)) {
  baseLibDir <- paste(RHome, "/lib/R/library", sep = "")
}

packages <- list.files(baseLibDir)
packageFilter <- myGetEnv("RCHEOLOGY_HELP_PACKAGE")
if (packageFilter != "") packages <- packages[packages == packageFilter]
pageParts <- list()
aliasParts <- list()
part <- 0L

for (pkg in packages) {
  helpDir <- file.path(baseLibDir, pkg, "help")
  indexFile <- file.path(helpDir, "AnIndex")
  database <- file.path(helpDir, paste(pkg, "rdb", sep = "."))
  if (! file.exists(indexFile) || ! file.exists(database)) next

  indexLines <- readLines(indexFile, warn = FALSE)
  indexBits <- strsplit(indexLines, "\t", fixed = TRUE)
  keep <- unlist(lapply(indexBits, length)) >= 2L
  indexBits <- indexBits[keep]
  aliases <- unlist(lapply(indexBits, function(x) x[1L]))
  topics <- unlist(lapply(indexBits, function(x) x[2L]))

  rdDatabase <- try(
    tools:::fetchRdDB(file.path(helpDir, pkg)),
    silent = TRUE
  )
  if (inherits(rdDatabase, "try-error")) {
    warning(paste("Could not read help database for", pkg))
    next
  }

  pageTopics <- unique(topics)
  pageTopics <- pageTopics[pageTopics %in% names(rdDatabase)]

  part <- part + 1L
  packagePages <- data.frame(
    package = I(rep(pkg, length(pageTopics))),
    topic = I(pageTopics)
  )
  packagePages$rd <- I(lapply(
    unname(rdDatabase[pageTopics]),
    stripRdSources
  ))
  pageParts[[part]] <- packagePages
  aliasParts[[part]] <- data.frame(
    package = I(rep(pkg, length(aliases))),
    name = I(aliases),
    topic = I(topics)
  )
}

if (length(pageParts) == 0L) {
  pages <- data.frame(
    package = character(), topic = character(),
    stringsAsFactors = FALSE
  )
  pages$rd <- I(vector("list", 0L))
  aliases <- data.frame(
    package = character(), name = character(), topic = character(),
    stringsAsFactors = FALSE
  )
} else {
  pages <- do.call(rbind, pageParts)
  aliases <- do.call(rbind, aliasParts)
}

aliases$Rversion <- shortRversion
aliases$status <- Rstatus

outputFile <- myGetEnv("RCHEOLOGY_HELP_OUTPUT_FILE")
if (outputFile == "") {
  outputFile <- paste(
    "docker-data/help-R-", shortRversion, ".RData", sep = ""
  )
}

save(
  pages,
  aliases,
  file = outputFile,
  compress = TRUE,
  version = 2
)
