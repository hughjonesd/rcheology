
library(rcheology)
library(dplyr)
all_versions <- sort(as.package_version(unique(rcheology$Rversion)))


make_doc_anchors <- function (name, package, versions) {
  # rdocumentation.org doesn't have 3.2.0
  rdoc_versions <- ifelse(versions == '3.2.0', '3.2.1', as.character(versions))
  url <- utils::URLencode(sprintf("https://hughjonesd.github.io/r-help/%s/%s/%s.html",
                                  rdoc_versions, package, name))
  # url <- utils::URLencode(sprintf("https://www.rdocumentation.org/packages/%s/versions/%s/topics/%s", 
  #       package, rdoc_versions, name))
  versions <- as.character(versions)
  anchors <- paste0("<a href='", url, "' target='_blank'>", versions, "</a>")
        
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
  
  all_versions <- paste(versions, collapse = " ")
  range_string <- paste0(ranges,"<!--",  all_versions ,"-->")
  
  range_string
}


n_all_versions <- length(unique(rcheology$Rversion))

rch_summary <- rcheology %>% 
      mutate(
        # for DT search box to display as an option:
        package = as.factor(package),
        type = as.factor(type),
        class = as.factor(class),
        priority = as.factor(priority),
      ) %>%
      group_by(name, package, args, type, class, exported) %>% 
      summarize(
        hidden          = hidden[1],
        versions        = make_range(name[1], package[1], Rversion), 
      )

Rversions <- as.package_version(unique(rcheology$Rversion))

save(Rversions, rch_summary, file = file.path("app", "rcheology-app-data.RData"))
