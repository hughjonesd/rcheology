
library(dplyr)
load("data/rcheology.rda")

all_versions <- rcheology |>
  filter(status == "released") |>
  pull(Rversion) |>
  unique() |>
  as.package_version() |>
  sort()


make_doc_anchors <- function (name, package, versions, suffixes = "") {
  versions <- as.character(versions)
  r_help_versions <- sub("(1\\.[0-4])\\.0", "\\1", versions)
  r_help_versions <- sub("(0\\.\\d+)\\.0", "\\1", r_help_versions)
  
  url <- utils::URLencode(sprintf("https://hughjonesd.github.io/r-help/%s/%s/%s.html",
                                  r_help_versions, package, name))
  
  anchors <- paste0(
    "<a href='", url, "' target='_blank'>", versions, suffixes, "</a>"
  )
        
  anchors
}

# Makes ranges which may have gaps, e.g. 0.60-0.61; 1.0-1.2.0 
make_range <- function (name, package, versions, statuses) {
  released_versions <- versions[statuses == "released"] |>
    unique() |>
    as.package_version() |>
    sort()

  lv <- length(all_versions)
  ranges <- character()
  if (length(released_versions) > 0) {
    there <- all_versions %in% released_versions
    stop_start <- c(as.numeric(there[1]), diff(there))
    starts <- which(stop_start == 1)
    stops <- which(stop_start == -1) - 1
    if (stop_start[lv] == 0 && there[lv]) stops <- c(stops, lv)

    start_v <- all_versions[starts]
    stop_v <- all_versions[stops]
    stop_v <- ifelse(
      start_v == stop_v,
      "",
      paste0("-", make_doc_anchors(name, package, stop_v))
    )
    ranges <- paste0(
      make_doc_anchors(name, package, start_v),
      stop_v,
      collapse = "; "
    )
  }

  snapshot_versions <- versions[statuses != "released"]
  snapshot_statuses <- statuses[statuses != "released"]
  keep <- ! duplicated(paste(snapshot_versions, snapshot_statuses))
  snapshot_versions <- as.package_version(snapshot_versions[keep])
  snapshot_statuses <- snapshot_statuses[keep]
  snapshot_order <- order(
    snapshot_versions,
    match(snapshot_statuses, c("r-patched", "r-devel"))
  )
  snapshot_versions <- snapshot_versions[snapshot_order]
  snapshot_statuses <- snapshot_statuses[snapshot_order]
  snapshot_suffixes <- ifelse(
    snapshot_statuses == "r-patched",
    " patched",
    " Devel"
  )
  snapshot_anchors <- make_doc_anchors(
    name,
    package,
    snapshot_versions,
    snapshot_suffixes
  )

  search_versions <- c(
    as.character(released_versions),
    paste0(snapshot_versions, snapshot_suffixes)
  )
  range_string <- paste0(
    paste(c(ranges, snapshot_anchors), collapse = "; "),
    "<!--", paste(search_versions, collapse = " "), "-->"
  )
  
  range_string
}


n_all_versions <- length(unique(rcheology$Rversion))

rch_summary <- rcheology |> 
      mutate(
        # for DT search box to display as an option:
        package = as.factor(package),
        type = as.factor(type),
        class = as.factor(class),
        priority = as.factor(priority),
      ) |>
      group_by(name, args, package, priority, type, class, exported) |> 
      summarize(
        hidden          = hidden[1],
        versions        = make_range(name[1], package[1], Rversion, status),
      )

Rversions <- as.package_version(unique(rcheology$Rversion))

save(Rversions, rch_summary, file = file.path("app", "rcheology-app-data.RData"))
