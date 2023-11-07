
library(rcheology)
library(readr)
library(dplyr)

lost <- changed <- list()
for (rv in rcheology::Rversions$Rversion) {
  r_new <- try(read_csv(sprintf("docker-data/pkg_data-R-%s.csv", rv), 
                        show_col_types = FALSE))
  
  if (inherits(r_new, "try-error") || nrow(r_new) == 0) {
    lost[[rv]] <- 'NO DATA'
    next
  }
  r_old <- rcheology |> filter(Rversion == rv)
  if (nrow(r_old) == 0) {
    lost[[rv]] <- 'NO OLD'
    next
  }
  
  lost[[rv]] <- anti_join(r_old, r_new, by = c("package", "name"))
  both <- inner_join(r_old, r_new, by = c("package", "name"), suffix = c(".old", ".new"))
  changed[[rv]] <- both |> 
    filter(
      type.old != type.new | class.old != class.new
    )
  if (nrow(lost[[rv]]) == 0) lost[[rv]] <- "OK"
}

invisible(lapply(rcheology::Rversions$Rversion, 
       \(x) {
         cat(x, "\t")
         l <- lost[[x]]
         if (is.character(l)) {cat(l, "\n"); return()}
         cat(nrow(l), unique(l$package), "\n", sep = "\t")
       }))

invisible(lapply(rcheology::Rversions$Rversion, 
          \(x) {
            cat(x, "\t")
            ch <- changed[[x]] 
            cat(nrow(ch), "\n")
          }))

chall <- purrr::list_rbind(changed, names_to = "Rversion") |> as_tibble()
