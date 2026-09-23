#! Rscript

# Build the static indexes after all Docker images have added their HTML.

htmlEscape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}

versionDirs <- list.dirs("help-site", recursive = FALSE, full.names = TRUE)
for (versionDir in versionDirs) {
  aliasFile <- file.path(versionDir, "aliases.tsv")
  if (! file.exists(aliasFile) || file.size(aliasFile) == 0L) next

  aliases <- read.delim(
    aliasFile,
    header = FALSE,
    quote = "",
    col.names = c("package", "name", "topic")
  )
  aliases <- unique(aliases[order(aliases$name, aliases$package), ])
  links <- sprintf(
    '<li><a data-package="%s" data-name="%s" href="%s/%s.html">%s::%s</a></li>',
    htmlEscape(aliases$package),
    htmlEscape(aliases$name),
    htmlEscape(aliases$package),
    htmlEscape(aliases$topic),
    htmlEscape(aliases$package),
    htmlEscape(aliases$name)
  )

  version <- basename(versionDir)
  writeLines(c(
    "<!doctype html>",
    '<html lang="en"><head><meta charset="utf-8">',
    paste0("<title>R ", version, " help</title>"),
    "<script>window.addEventListener('DOMContentLoaded', function () {",
    "var query = new URLSearchParams(window.location.search);",
    "var links = document.querySelectorAll('a[data-package]');",
    "for (var i = 0; i < links.length; i++) {",
    "if (links[i].dataset.package === query.get('package') && links[i].dataset.name === query.get('name')) {",
    "window.location.replace(links[i].href); return;",
    "}}",
    "});</script></head><body>",
    paste0("<h1>R ", version, " help</h1><ul>"),
    links,
    "</ul></body></html>"
  ), file.path(versionDir, "index.html"))
  unlink(aliasFile)
}

versions <- basename(versionDirs)
versions <- versions[order(as.package_version(versions), decreasing = TRUE)]
links <- paste0('<li><a href="', versions, '/">R ', versions, "</a></li>")
writeLines(c(
  "<!doctype html>",
  '<html lang="en"><head><meta charset="utf-8">',
  "<title>Historical R help</title></head><body>",
  "<h1>Historical R help</h1><ul>", links, "</ul></body></html>"
), "help-site/index.html")
