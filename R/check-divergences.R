
library(rcheology)
library(readr)
library(dplyr)

lost <- list()
for (rv in rcheology::Rversions$Rversion) {
  r_new <- try(read_csv(sprintf("docker-data/pkg_data-R-%s.csv", rv)))
  if (inherits(r_new, "try-error")) {
    lost[[rv]] <- 'NO FILE'
    next
  }
  r_old <- rcheology |> filter(Rversion == rv)
  lost[[rv]] <- anti_join(r_old, r_new, by = c("package", "name"))
}

invisible(lapply(rcheology::Rversions$Rversion, 
       \(x) {
         l <- lost[[x]]
         if (is.character(l) && l == "NO FILE") {cat(x, " NO FILE\n"); return()}
         if (nrow(l) < 1) {cat(x, " OK\n"); return()}
         cat(l$Rversion[[1]], nrow(l), unique(l$package), "\n", sep = "\t")
       }))
