
library(dplyr)
library(purrr)
library(readr)

rcheology <- list.files(pattern="*.csv", path = "docker-data", full.names = TRUE) |> 
  purrr::map(~readr::read_csv(., col_types = "cccllcccc")) |> 
  purrr::list_rbind() |> 
  select(package, name, Rversion, priority, type, exported, class, S4generic, args) |> 
  arrange(package, name, as.package_version(Rversion)) |> 
  tibble::remove_rownames()
  
cat("Dimensions:", dim(rcheology), "\n")
cat("First rows:\n")
print(head(rcheology))
cat("Versions:\n")
print(table(rcheology$Rversion))

url <- paste0("http://cran.r-project.org/src/base/R-", 0:4)
Rversions <- lapply(url, function (x) XML::readHTMLTable(x, stringsAsFactors=FALSE)[[1]])
Rversions <- do.call(rbind, Rversions)
Rversions <- Rversions[grep("R-(.*)(\\.tar\\.gz|\\.tgz)", Rversions$Name), c(-1, -5)]
Rversions$Rversion <- gsub("R-(.*)\\.(tar\\.gz|tgz)", "\\1", Rversions$Name)
Rversions$date <- as.Date(Rversions[["Last modified"]])
Rversions <- Rversions[, c("Rversion", "date")]

print(Rversions)
usethis::use_data(Rversions, overwrite = TRUE)
usethis::use_data(rcheology, overwrite = TRUE)
