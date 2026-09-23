#! Rscript

# This is sourced only by R versions which store help in compiled databases.
# Earlier versions already contain HTML, which guest-run-r-versions.sh copies.

versionDir <- file.path("help-site", shortRversion)
dir.create(versionDir, recursive = TRUE, showWarnings = FALSE)
aliasFile <- file.path(versionDir, "aliases.tsv")

renderHtmlHelp <- function(pkg) {
  helpDir <- file.path(baseLibDir, pkg, "help")
  indexFile <- file.path(helpDir, "AnIndex")
  database <- file.path(helpDir, paste(pkg, "rdb", sep = "."))
  if (! file.exists(indexFile) || ! file.exists(database)) return()

  indexLines <- readLines(indexFile, warn = FALSE)
  indexBits <- strsplit(indexLines, "\t", fixed = TRUE)
  indexBits <- indexBits[unlist(lapply(indexBits, length)) >= 2L]
  aliases <- unlist(lapply(indexBits, function(x) x[1L]))
  topics <- unlist(lapply(indexBits, function(x) x[2L]))
  write(
    paste(pkg, aliases, topics, sep = "\t"),
    file = aliasFile,
    append = TRUE
  )

  rdDatabase <- try(
    tools:::fetchRdDB(file.path(helpDir, pkg)),
    silent = TRUE
  )
  if (inherits(rdDatabase, "try-error")) return()

  packageDir <- file.path(versionDir, pkg)
  dir.create(packageDir, recursive = TRUE, showWarnings = FALSE)
  pageTopics <- unique(topics)
  pageTopics <- pageTopics[pageTopics %in% names(rdDatabase)]
  for (topic in pageTopics) {
    outputFile <- file.path(packageDir, paste(topic, "html", sep = "."))
    rendered <- try(
      tools::Rd2HTML(
        rdDatabase[[topic]],
        out = outputFile,
        package = pkg
      ),
      silent = TRUE
    )
    if (inherits(rendered, "try-error") && file.exists(outputFile)) {
      unlink(outputFile)
    }
  }
}
