
library(rcheology)
all_versions <- sort(as.package_version(unique(rcheology$Rversion)))


make_doc_anchors <- function (name, package, versions) {
  # rdocumentation.org doesn't have 3.2.0
  rdoc_versions <- ifelse(versions == '3.2.0', '3.2.1', as.character(versions))
  v3.1.1 <- as.package_version('3.1.1')
  url <- utils::URLencode(sprintf("https://www.rdocumentation.org/packages/%s/versions/%s/topics/%s", 
        package, rdoc_versions, name))
  versions <- as.character(versions)
  anchors <- ifelse(versions >= v3.1.1, 
        paste0("<a href='", url, "'  target='_blank'>", versions, "</a>"), 
        versions)
        
  anchors
}

make_range <- function (name, package, versions) {
  my_doc_anchors <- function (versions) make_doc_anchors(name, package, versions)

  lv <- length(all_versions)
  versions <- sort(as.package_version(unique(versions)))
  there <- all_versions %in% versions
  stop_start <- c(as.numeric(there[1]), diff(there))
  starts <- which(stop_start == 1)
  stops  <- which(stop_start == -1) - 1
  if (stop_start[lv] == 0 && there[lv]) stops <- c(stops, lv) 
  start_v <- all_versions[starts]
  stop_v  <- all_versions[stops]
  stop_v <- ifelse(start_v == stop_v, "", paste0("-", my_doc_anchors(stop_v)))
  ranges <- paste0(my_doc_anchors(start_v), stop_v, sep = "", collapse = "; ")
  
  ranges
}


n_all_versions <- length(unique(rcheology$Rversion))

rch_summary <- rcheology %>% 
      group_by(name, package) %>% 
      mutate(
        ever_changed = length(Rversion) < n_all_versions, 
        n_versions   = length(Rversion),
        args         = sub("^function ", "", args)
      ) %>% 
      group_by(name, package, args) %>% 
      summarize(
        versions     = paste0(
          make_range(name[1], package[1], Rversion), 
          "<!--", paste(Rversion, collapse = " ") ,"-->"
        ),
        `Ever changed?` = ever_changed[1],
        `Args changed?` = length(Rversion) < n_versions[1],
      )

save(rcheology, rch_summary, file = file.path("app", "rcheology-app-data.RData"))
