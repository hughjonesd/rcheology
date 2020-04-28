
# thanks to Brandon Bertelsen on
# https://stackoverflow.com/questions/13567453/how-to-scrape-the-web-for-the-list-of-r-release-dates

scrape_version_dates <- function () {
  url <- paste0("http://cran.r-project.org/src/base/R-", 0:4)
  versions <- lapply(url, function (x) XML::readHTMLTable(x, stringsAsFactors=FALSE)[[1]])
  versions <- do.call(rbind, versions)
  versions <- versions[grep("R-(.*)(\\.tar\\.gz|\\.tgz)", versions$Name), c(-1, -5)]
  versions$Rversion <- gsub("R-(.*)\\.(tar\\.gz|tgz)", "\\1", versions$Name)
  versions$date <- as.Date(versions[["Last modified"]])
  
  versions[, c("Rversion", "date")]
}

Rversions <- scrape_version_dates()
Rversions <- Rversions[! grepl("recommended", Rversions$Rversion), ]
usethis::use_data(Rversions, overwrite = TRUE)
