
library(dplyr)
library(purrr)
library(readr)

rcheology <- list.files(pattern="*.csv", path = "docker-data", full.names = TRUE) |> 
  purrr::map(~readr::read_csv(., col_types = "cccllccc")) |> 
  purrr::list_rbind() |> 
  select(package, name, Rversion, type, exported, class, generic, args) |> 
  arrange(package, name, as.package_version(Rversion)) |> 
  tibble::remove_rownames()
  
cat("Dimensions:", dim(rcheology), "\n")
cat("First rows:\n")
print(head(rcheology))
cat("Versions:\n")
print(table(rcheology$Rversion))

url <- paste0("http://cran.r-project.org/src/base/R-", 0:4)
versions <- lapply(url, function (x) XML::readHTMLTable(x, stringsAsFactors=FALSE)[[1]])
versions <- do.call(rbind, versions)
versions <- versions[grep("R-(.*)(\\.tar\\.gz|\\.tgz)", versions$Name), c(-1, -5)]
versions$Rversion <- gsub("R-(.*)\\.(tar\\.gz|tgz)", "\\1", versions$Name)
versions$date <- as.Date(versions[["Last modified"]])
versions <- versions[, c("Rversion", "date")]

usethis::use_data(Rversions, overwrite = TRUE)
usethis::use_data(rcheology, overwrite = TRUE)
