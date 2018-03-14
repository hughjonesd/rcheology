
library(rcheology)
all_versions <- sort(as.package_version(unique(rcheology$Rversion)))

make_range <- function (versions) {
  lv <- length(all_versions)
  versions <- sort(as.package_version(unique(versions)))
  there <- all_versions %in% versions
  stop_start <- c(as.numeric(there[1]), diff(there))
  starts <- which(stop_start == 1)
  stops  <- which(stop_start == -1) - 1
  if (stop_start[lv] == 0 && there[lv]) stops <- c(stops, lv) 
  start_v <- all_versions[starts]
  stop_v  <- all_versions[stops]
  stop_v <- ifelse(start_v == stop_v, "", paste0("-", stop_v))
  ranges <- paste0(start_v, stop_v, sep = "", collapse = "; ")
  
  ranges
}

rch_summary <- rcheology %>% 
      group_by(name, package, args) %>% 
      summarize(
        versions = paste0(make_range(Rversion), "<!--", paste(Rversion, collapse = " ") ,"-->")
      )

save(rcheology, rch_summary, file = file.path("app", "rcheology-app-data.RData"))
