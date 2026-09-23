library(dplyr)
library(purrr)
library(readr)

help_records <- if (file.exists("inst/rcheology-help.rds")) {
  readRDS("inst/rcheology-help.rds")
} else {
  list()
}
help_lookup <- new.env(parent = emptyenv(), hash = TRUE)
if (length(help_records) > 0L) {
  for (i in seq_along(help_records)) {
    key <- digest::digest(help_records[[i]], algo = "sha256", serialize = FALSE)
    help_lookup[[key]] <- i
  }
}
store_help <- function(records) {
  vapply(records, function(record) {
    key <- digest::digest(record, algo = "sha256", serialize = FALSE)
    id <- help_lookup[[key]]
    if (is.null(id)) {
      id <- length(help_records) + 1L
      help_records[[id]] <<- record
      help_lookup[[key]] <- id
    }
    id
  }, integer(1))
}

existing_help <- NULL
if (file.exists("data/rcheology.rda")) {
  existing_data <- new.env(parent = emptyenv())
  load("data/rcheology.rda", envir = existing_data)
  if ("help" %in% names(existing_data$rcheology)) {
    existing_help <- existing_data$rcheology |>
      select(package, name, Rversion, status, existing_help = help)
  }
}

escape_rd <- function(x) {
  x <- gsub("\\", "\\\\", x, fixed = TRUE)
  x <- gsub("%", "\\%", x, fixed = TRUE)
  x <- gsub("{", "\\{", x, fixed = TRUE)
  gsub("}", "\\}", x, fixed = TRUE)
}

escape_html <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}

read_modern_help <- function(path) {
  help_data <- new.env(parent = emptyenv())
  load(path, envir = help_data)

  pages <- help_data$pages
  strip_rd_sources <- function(x) {
    attr(x, "Rdfile") <- NULL
    attr(x, "srcref") <- NULL
    attr(x, "srcfile") <- NULL
    attr(x, "wholeSrcref") <- NULL
    if (is.list(x)) {
      for (i in seq_along(x)) x[[i]] <- strip_rd_sources(x[[i]])
    }
    x
  }
  records <- lapply(pages$rd, function(rd) {
    rd <- strip_rd_sources(rd)
    memCompress(serialize(
      list(rd = rd, html = NA_character_, text = NA_character_),
      NULL,
      version = 2
    ), type = "gzip")
  })
  pages$help <- store_help(records)

  help_data$aliases |>
    inner_join(
      select(pages, package, topic, help),
      by = c("package", "topic")
    ) |>
    select(package, name, Rversion, status, topic, help)
}

read_legacy_help <- function(path, released_versions) {
  source_version <- sub("^help-R-", "", basename(path))
  source_version <- sub("\\.tar\\.gz$", "", source_version)
  source_version <- sub("-a[0-9]+$", "", source_version)
  version_match <- as.package_version(released_versions) ==
    as.package_version(source_version)
  if (! any(version_match)) {
    message("Skipping R ", source_version, ": no matching function data")
    return(NULL)
  }
  r_version <- released_versions[which(version_match)[1]]

  extract_dir <- tempfile("rcheology-help-")
  dir.create(extract_dir)
  on.exit(unlink(extract_dir, recursive = TRUE), add = TRUE)
  utils::untar(path, exdir = extract_dir)
  index_files <- list.files(
    extract_dir,
    pattern = "^AnIndex$",
    recursive = TRUE,
    full.names = TRUE
  )

  help_parts <- list()
  for (i in seq_along(index_files)) {
    index_file <- index_files[i]
    package_dir <- dirname(dirname(index_file))
    package <- basename(package_dir)
    index_lines <- readLines(index_file, warn = FALSE)
    index_bits <- strsplit(index_lines, "\t", fixed = TRUE)
    index_bits <- index_bits[lengths(index_bits) >= 2L]
    aliases <- vapply(index_bits, `[[`, character(1), 1L)
    topics <- vapply(index_bits, `[[`, character(1), 2L)
    page_topics <- unique(topics)

    page_records <- lapply(page_topics, function(topic) {
      html_file <- file.path(package_dir, "html", paste0(topic, ".html"))
      text_file <- file.path(package_dir, "help", topic)
      text <- if (file.exists(text_file)) {
        paste(readLines(text_file, warn = FALSE, encoding = "latin1"),
          collapse = "\n")
      } else {
        ""
      }
      if (! nzchar(text) && file.exists(html_file)) {
        text <- paste(
          readLines(html_file, warn = FALSE, encoding = "latin1"),
          collapse = "\n"
        )
        text <- gsub("(?is)<script[^>]*>.*?</script>", "", text, perl = TRUE)
        text <- gsub("(?s)<[^>]+>", " ", text, perl = TRUE)
        text <- gsub("&lt;", "<", text, fixed = TRUE)
        text <- gsub("&gt;", ">", text, fixed = TRUE)
        text <- gsub("&quot;", '"', text, fixed = TRUE)
        text <- gsub("&nbsp;", " ", text, fixed = TRUE)
        text <- gsub("&amp;", "&", text, fixed = TRUE)
        text <- gsub("[[:space:]]+", " ", text)
      }
      text <- iconv(text, from = "latin1", to = "UTF-8", sub = "byte")
      text <- gsub("\\033\\[[0-9;]*[[:alpha:]]", "", text, perl = TRUE)
      while (grepl(".\\x08", text, perl = TRUE)) {
        text <- gsub(".\\x08", "", text, perl = TRUE)
      }

      topic_aliases <- aliases[topics == topic]
      rd <- paste0(
        "\\name{", escape_rd(topic), "}\n",
        paste0("\\alias{", escape_rd(topic_aliases), "}", collapse = "\n"),
        "\n\\title{", escape_rd(topic), "}\n",
        "\\description{\\preformatted{", escape_rd(text), "}}\n"
      )

      html <- if (file.exists(html_file)) {
        paste(readLines(html_file, warn = FALSE, encoding = "latin1"),
          collapse = "\n")
      } else {
        paste0("<pre>", escape_html(text), "</pre>")
      }
      html <- iconv(html, from = "latin1", to = "UTF-8", sub = "byte")
      html <- sub("(?is).*?<body[^>]*>(.*)</body>.*", "\\1", html, perl = TRUE)
      html <- gsub("(?is)<script[^>]*>.*?</script>", "", html, perl = TRUE)
      html <- gsub("(?is)</?a\\b[^>]*>", "", html, perl = TRUE)

      memCompress(serialize(
        list(rd = rd, html = html, text = text),
        NULL,
        version = 2
      ), type = "gzip")
    })
    page_help <- store_help(page_records)

    help_parts[[i]] <- tibble(
      package,
      name = aliases,
      Rversion = r_version,
      status = "released",
      topic = topics,
      help = page_help[match(topics, page_topics)]
    )
  }

  list_rbind(help_parts)
}

files <- list.files(
  pattern = "\\.csv$",
  path = "docker-data",
  full.names = TRUE
)

rcheology <- map(files,
  ~ read_csv(.x, col_types = "cccllcccccl", trim_ws = TRUE)
) |>
  list_rbind() |>
  select(
    package, name, Rversion, status, priority, type, exported, hidden,
    class, S4generic, args
  ) |>
  arrange(
    package, name, as.package_version(Rversion),
    match(status, c("released", "r-next", "r-devel"))
  ) |>
  tibble::remove_rownames()

modern_files <- list.files(
  "docker-data",
  pattern = "^help-R-.*\\.RData$",
  full.names = TRUE
)
legacy_files <- list.files(
  "docker-data",
  pattern = "^help-R-.*\\.tar\\.gz$",
  full.names = TRUE
)
legacy_files <- legacy_files[! grepl(
  "help-R-(0\\.49|0\\.50-a1)\\.tar\\.gz$",
  legacy_files
)]

modern_help <- map(modern_files, read_modern_help) |>
  list_rbind()
legacy_help <- map(
  legacy_files,
  read_legacy_help,
  released_versions = unique(rcheology$Rversion[rcheology$status == "released"])
) |>
  list_rbind()

help <- bind_rows(legacy_help, modern_help) |>
  mutate(topic_matches_name = topic == name) |>
  arrange(
    package, name, as.package_version(Rversion), status,
    desc(topic_matches_name), topic
  ) |>
  distinct(package, name, Rversion, status, .keep_all = TRUE) |>
  select(-topic, -topic_matches_name)

rcheology <- rcheology |>
  left_join(help, by = c("package", "name", "Rversion", "status"))
if (! is.null(existing_help)) {
  rcheology <- rcheology |>
    left_join(
      existing_help,
      by = c("package", "name", "Rversion", "status")
    )
  rcheology <- rcheology |>
    mutate(help = coalesce(help, existing_help)) |>
    select(-existing_help)
}

dir.create("inst", showWarnings = FALSE)
saveRDS(
  help_records,
  "inst/rcheology-help.rds",
  compress = "xz",
  version = 2
)

cat("Dimensions:", dim(rcheology), "\n")
cat("Functions with help:", sum(! is.na(rcheology$help)), "\n")
cat("Distinct help records:", length(help_records), "\n")
cat("Versions:\n")
print(table(rcheology$Rversion))

if (all(rcheology$status == "released")) {
  url <- paste0("https://cran.r-project.org/src/base/R-", 0:4)
  Rversions <- lapply(url, function(x) {
    html <- paste(readLines(x, warn = FALSE), collapse = "\n")
    XML::readHTMLTable(html, stringsAsFactors = FALSE)[[1]]
  })
  Rversions <- do.call(rbind, Rversions)
  Rversions <- Rversions[
    grep("R-(.*)(\\.tar\\.gz|\\.tgz)", Rversions$Name),
    c(-1, -5)
  ]
  Rversions$Rversion <- gsub("R-(.*)\\.(tar\\.gz|tgz)", "\\1", Rversions$Name)
  Rversions$date <- as.Date(Rversions[["Last modified"]])
  Rversions <- Rversions[, c("Rversion", "date")]

  print(Rversions)
  usethis::use_data(Rversions, overwrite = TRUE)
}
usethis::use_data(rcheology, overwrite = TRUE, compress = "xz")
