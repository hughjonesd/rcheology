
library(dplyr)
library(purrr)
library(readr)

files <- list.files(pattern = "\\.csv$", path = "docker-data", full.names = TRUE)

rcheology <- purrr::map(files,
  ~ readr::read_csv(.x, col_types = "cccllcccccl", trim_ws = TRUE)
) |>
  purrr::list_rbind() |> 
  select(package, name, Rversion, status, priority, type, exported, hidden, class,
         S4generic, args) |> 
  arrange(package, name, as.package_version(Rversion),
    match(status, c("released", "r-next", "r-devel"))) |>
  tibble::remove_rownames()
  
cat("Dimensions:", dim(rcheology), "\n")
cat("First rows:\n")
print(head(rcheology))
cat("Versions:\n")
print(table(rcheology$Rversion))

if (all(rcheology$status == "released")) {
  url <- paste0("https://cran.r-project.org/src/base/R-", 0:4)
  Rversions <- lapply(url, function (x) {
    html <- paste(readLines(x, warn = FALSE), collapse = "\n")
    XML::readHTMLTable(html, stringsAsFactors = FALSE)[[1]]
  })
  Rversions <- do.call(rbind, Rversions)
  Rversions <- Rversions[grep("R-(.*)(\\.tar\\.gz|\\.tgz)", Rversions$Name), c(-1, -5)]
  Rversions$Rversion <- gsub("R-(.*)\\.(tar\\.gz|tgz)", "\\1", Rversions$Name)
  Rversions$date <- as.Date(Rversions[["Last modified"]])
  Rversions <- Rversions[, c("Rversion", "date")]

  print(Rversions)
  usethis::use_data(Rversions, overwrite = TRUE)
}
usethis::use_data(rcheology, overwrite = TRUE)
