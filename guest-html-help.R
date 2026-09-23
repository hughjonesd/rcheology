#! Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 2L && args[1L] == "--build-indexes") {
  root <- args[2L]
  htmlEscape <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    x <- gsub(">", "&gt;", x, fixed = TRUE)
    gsub('"', "&quot;", x, fixed = TRUE)
  }

  versionDirs <- list.dirs(root, recursive = FALSE, full.names = TRUE)
  for (versionDir in versionDirs) {
    version <- basename(versionDir)
    aliasFiles <- list.files(
      versionDir,
      pattern = "^aliases.*\\.tsv$",
      full.names = TRUE
    )
    aliases <- if (length(aliasFiles) == 0L) {
      data.frame(package = character(), name = character(), topic = character())
    } else {
      do.call(rbind, lapply(aliasFiles, read.delim,
        header = FALSE,
        quote = "",
        col.names = c("package", "name", "topic")
      ))
    }
    aliases <- unique(aliases[order(aliases$package, aliases$name), ])
    links <- sprintf(
      '<li><a data-package="%s" data-name="%s" href="%s/%s.html">%s::%s</a></li>',
      htmlEscape(aliases$package),
      htmlEscape(aliases$name),
      htmlEscape(aliases$package),
      htmlEscape(aliases$topic),
      htmlEscape(aliases$package),
      htmlEscape(aliases$name)
    )
    writeLines(c(
      "<!doctype html>",
      '<html lang="en"><head><meta charset="utf-8">',
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
      paste0("<title>R ", htmlEscape(version), " help</title>"),
      "<style>body{max-width:70rem;margin:2rem auto;padding:0 1rem;font-family:sans-serif;line-height:1.45}ul{columns:3 16rem;padding:0;list-style:none}li{break-inside:avoid}#missing{padding:.75rem;background:#fff4d6}</style>",
      "<script>window.addEventListener('DOMContentLoaded',function(){var q=new URLSearchParams(window.location.search),p=q.get('package'),n=q.get('name');if(!p||!n)return;var a=document.querySelectorAll('a[data-package]');for(var i=0;i<a.length;i++){if(a[i].dataset.package===p&&a[i].dataset.name===n){window.location.replace(a[i].href);return}}document.getElementById('missing').hidden=false})</script>",
      "</head><body>",
      paste0("<h1>R ", htmlEscape(version), " help</h1>"),
      '<p id="missing" hidden>No help page was found for that package and function.</p>',
      "<ul>", links, "</ul></body></html>"
    ), file.path(versionDir, "index.html"))
    unlink(aliasFiles)
  }

  versions <- basename(versionDirs)
  versions <- versions[order(as.package_version(versions), decreasing = TRUE)]
  links <- paste0('<li><a href="', htmlEscape(versions), '/">R ',
    htmlEscape(versions), "</a></li>")
  writeLines(c(
    "<!doctype html>",
    '<html lang="en"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    "<title>Historical R help</title></head><body>",
    "<h1>Historical R help</h1><ul>", links, "</ul></body></html>"
  ), file.path(root, "index.html"))
  quit(save = "no")
}

rv <- getRVersion()
rVersion <- paste(rv$major, rv$minor, sep = ".")
rHome <- Sys.getenv("R_HOME")
if (rHome == "") rHome <- Sys.getenv("RHOME")
if (rHome == "") rHome <- paste("/opt/R", rVersion, sep = "/")
libraryDir <- file.path(rHome, "library")
if (! file.exists(libraryDir)) {
  libraryDir <- file.path(rHome, "lib", "R", "library")
}

versionDir <- file.path("help-site", rVersion)
dir.create(versionDir, recursive = TRUE, showWarnings = FALSE)
aliasFile <- file.path(versionDir, "aliases.tsv")

for (pkg in list.files(libraryDir)) {
  helpDir <- file.path(libraryDir, pkg, "help")
  indexFile <- file.path(helpDir, "AnIndex")
  database <- file.path(helpDir, paste(pkg, "rdb", sep = "."))
  if (! file.exists(indexFile) || ! file.exists(database)) next

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
  if (inherits(rdDatabase, "try-error")) next

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
