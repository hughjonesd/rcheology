library(dplyr)

load("data/rcheology.rda")
load("data/Rversions.rda")

status_levels <- c("released", "r-patched", "r-next", "r-devel")

app_versions <- rcheology |>
  distinct(Rversion, status) |>
  mutate(
    version_number = as.package_version(Rversion),
    status_order = match(status, status_levels)
  ) |>
  arrange(version_number, status_order) |>
  mutate(
    version_id = row_number(),
    key = paste(Rversion, status, sep = "|"),
    label = if_else(
      status == "released",
      paste("R", Rversion),
      paste("R", Rversion, "·", status)
    )
  ) |>
  left_join(Rversions, by = "Rversion") |>
  select(version_id, key, Rversion, status, label, date)

rcheology <- rcheology |>
  mutate(
    key = paste(Rversion, status, sep = "|"),
    version_id = match(key, app_versions$key),
    callable = ! is.na(args) |
      type %in% c("closure", "builtin", "special") |
      class == "function" |
      grepl("Generic", class)
  ) |>
  filter(callable)

rch_history <- rcheology |>
  group_by(
    name, package, args, priority, type, class, S4generic, exported, hidden
  ) |>
  summarize(
    version_ids = list(sort(unique(version_id))),
    .groups = "drop"
  ) |>
  mutate(
    first_id = vapply(version_ids, min, integer(1)),
    last_id = vapply(version_ids, max, integer(1))
  )

state_counts <- rch_history |>
  count(name, name = "states")

function_catalog <- rcheology |>
  group_by(name) |>
  summarize(
    packages = paste(sort(unique(package)), collapse = ", "),
    version_ids = list(sort(unique(version_id))),
    .groups = "drop"
  ) |>
  mutate(
    first_id = vapply(version_ids, min, integer(1)),
    last_id = vapply(version_ids, max, integer(1)),
    current = last_id == max(app_versions$version_id)
  ) |>
  left_join(state_counts, by = "name") |>
  arrange(name)

save(
  app_versions,
  function_catalog,
  rch_history,
  file = file.path("app", "rcheology-app-data.RData"),
  compress = "xz",
  version = 2
)
