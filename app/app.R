library(shiny)
library(bslib)
library(DT)
library(dplyr)

load("rcheology-app-data.RData")

version_choice_labels <- ifelse(
  app_versions$status == "released" & ! is.na(app_versions$date),
  paste0(app_versions$label, "  ·  ", format(app_versions$date, "%d %b %Y")),
  app_versions$label
)
version_choices <- setNames(app_versions$key, version_choice_labels)

latest_id <- max(app_versions$version_id)
latest_major <- as.integer(sub("\\..*", "", app_versions$Rversion[latest_id]))
baseline_candidates <- app_versions |>
  filter(
    status == "released",
    as.integer(sub("\\..*", "", Rversion)) == latest_major - 1
  )

default_baseline <- if (nrow(baseline_candidates) > 0) {
  tail(baseline_candidates$key, 1)
} else {
  app_versions$key[max(1, round(nrow(app_versions) * 0.7))]
}
default_target <- app_versions$key[latest_id]
default_function_name <- if ("kmeans" %in% function_catalog$name) {
  "kmeans"
} else {
  function_catalog$name[1]
}

function_choices <- rch_history |>
  filter(! hidden) |>
  mutate(current = vapply(
    version_ids,
    function(ids) latest_id %in% ids,
    logical(1)
  )) |>
  summarise(.by = c(package, name),
    current = any(current),
    last_id = max(last_id)
  ) |>
  transmute(
    value = paste0(package, "::", name),
    label = value,
    name,
    name_length = nchar(name),
    package,
    current,
    last_id
  ) |>
  arrange(nchar(name), name, desc(current), desc(last_id), package)

visible_function_names <- function_choices |>
  distinct(name) |>
  pull(name)

default_function <- function_choices |>
  filter(name == default_function_name) |>
  slice_head(n = 1) |>
  pull(value)

function_options <- lapply(seq_len(nrow(function_choices)), function(i) {
  as.list(function_choices[i, ])
})

history_at_version <- function(history, version_id) {
  history[vapply(history$version_ids, function(x) version_id %in% x, logical(1)), ]
}

split_arguments <- function(args) {
  if (length(args) == 0 || is.na(args)) return(character())

  text <- sub("^\\(", "", sub("\\)$", "", args))
  if (! nzchar(trimws(text))) return(character())

  characters <- strsplit(text, "", fixed = TRUE)[[1]]
  pieces <- character()
  start <- 1L
  depth <- 0L
  quote <- ""
  escaped <- FALSE

  for (i in seq_along(characters)) {
    character <- characters[i]

    if (nzchar(quote)) {
      if (escaped) {
        escaped <- FALSE
      } else if (character == "\\") {
        escaped <- TRUE
      } else if (character == quote) {
        quote <- ""
      }
    } else if (character %in% c("'", "\"", "`")) {
      quote <- character
    } else if (character %in% c("(", "[", "{")) {
      depth <- depth + 1L
    } else if (character %in% c(")", "]", "}")) {
      depth <- depth - 1L
    } else if (character == "," && depth == 0L) {
      pieces <- c(pieces, paste0(characters[start:(i - 1L)], collapse = ""))
      start <- i + 1L
    }
  }

  pieces <- c(pieces, paste0(characters[start:length(characters)], collapse = ""))
  trimws(pieces)
}

signature_html <- function(row, other_args = NA_character_, difference_class = NULL) {
  if (is.na(row$args)) {
    return(HTML(htmltools::htmlEscape(
      paste0(row$package, "::", row$name, "  (arguments not recorded)")
    )))
  }

  arguments <- split_arguments(row$args)
  other_arguments <- split_arguments(other_args)
  argument_names <- trimws(sub("=.*$", "", arguments))
  other_argument_names <- trimws(sub("=.*$", "", other_arguments))

  changed <- vapply(seq_along(arguments), function(j) {
    match_index <- which(other_argument_names == argument_names[j])
    length(match_index) == 0 ||
      ! identical(arguments[j], other_arguments[match_index[1]])
  }, logical(1))

  argument_html <- vapply(seq_along(arguments), function(j) {
    argument <- htmltools::htmlEscape(arguments[j])
    if (! is.null(difference_class) && changed[j]) {
      title <- if (difference_class == "argument-removed") {
        "Removed or changed argument"
      } else {
        "Added or changed argument"
      }
      paste0(
        '<span class="', difference_class, '" title="', title, '">',
        argument,
        "</span>"
      )
    } else {
      argument
    }
  }, character(1))

  HTML(paste0(
    htmltools::htmlEscape(paste0(row$package, "::", row$name, "(")),
    paste(argument_html, collapse = ", "),
    ")"
  ))
}

signature_panel <- function(rows, other_rows, version_id, label, difference_class) {
  version <- app_versions[version_id, ]

  if (nrow(rows) == 0) {
    return(div(
      class = "signature-panel signature-panel-empty",
      h2(class = "version-heading", paste0(label, ": ", version$label)),
      div(class = "empty-mark", "Not available"),
      p("This name was not recorded as a callable object in this version.")
    ))
  }

  div(
    class = "signature-panel",
    h2(class = "version-heading", paste0(label, ": ", version$label)),
    lapply(seq_len(nrow(rows)), function(i) {
      row <- rows[i, ]
      help_version <- app_versions$Rversion[version_id]
      help_version <- sub("(1\\.[0-4])\\.0", "\\1", help_version)
      help_version <- sub("(0\\.\\d+)\\.0", "\\1", help_version)
      help_url <- sprintf(
        "https://hughjonesd.github.io/r-help/%s/%s/%s.html",
        help_version,
        row$package,
        utils::URLencode(row$name, reserved = TRUE)
      )
      other_index <- which(other_rows$package == row$package)
      if (length(other_index) == 0 && nrow(rows) == 1 && nrow(other_rows) == 1) {
        other_index <- 1L
      }

      other_args <- if (length(other_index) > 0) {
        other_rows$args[other_index[1]]
      } else {
        NA_character_
      }
      signature <- signature_html(row, other_args, difference_class)

      div(
        class = "implementation",
        div(
          class = "implementation-meta",
          span(class = "package-badge", paste0("package: ", row$package)),
          span(
            class = if (isTRUE(row$exported)) "visibility-badge" else
              "visibility-badge visibility-internal",
            if (isTRUE(row$exported)) "exported" else "internal"
          )
        ),
        pre(class = "signature-code", code(signature)),
        a(
          class = "documentation-link",
          href = help_url,
          target = "_blank",
          rel = "noopener noreferrer",
          "Open documentation ", span("↗", `aria-hidden` = "true")
        )
      )
    })
  )
}

catalog_table <- function_catalog |>
  filter(name %in% visible_function_names) |>
  transmute(
    Function = name,
    Packages = packages,
    `First seen` = app_versions$label[first_id],
    `Last seen` = app_versions$label[last_id],
    Status = if_else(current, "Current", "Historical"),
    `Recorded states` = states
  )

app_css <- "
:root {
  --ink: #17312d;
  --ink-soft: #4f635f;
  --paper: #f5f1e8;
  --paper-deep: #eae3d6;
  --card: #fffdfa;
  --line: #dcd4c5;
  --teal: #0c7469;
  --teal-dark: #07554e;
  --teal-pale: #d9eee9;
  --copper: #bd6848;
  --copper-pale: #fae6dc;
  --gold: #d3a341;
  --shadow: 0 18px 50px rgba(38, 55, 50, 0.09);
  --mono: 'SFMono-Regular', Consolas, 'Liberation Mono', monospace;
}

html { scroll-behavior: smooth; }
body {
  margin: 0;
  color: var(--ink);
  background: var(--paper);
  font-family: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 16px;
  line-height: 1.55;
}
.container-fluid { padding: 0; }
a { color: var(--teal-dark); }
a:hover { color: var(--teal); }

.site-header {
  position: relative;
  z-index: 2;
  background: #123c37;
  color: white;
  border-bottom: 1px solid rgba(255,255,255,.12);
}
.site-header-inner {
  max-width: 1180px;
  margin: 0 auto;
  min-height: 74px;
  padding: 0 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}
.brand {
  display: inline-flex;
  align-items: center;
  gap: 11px;
  color: white;
  text-decoration: none;
  font-size: .91rem;
  font-weight: 800;
  letter-spacing: .14em;
}
.brand-mark {
  width: 36px;
  height: 36px;
  display: grid;
  place-items: center;
  border: 1px solid rgba(255,255,255,.55);
  border-radius: 50%;
  font-family: Georgia, serif;
  font-size: 1.3rem;
  letter-spacing: 0;
}
.header-links { display: flex; gap: 24px; }
.header-links a {
  color: rgba(255,255,255,.82);
  font-size: .9rem;
  font-weight: 650;
  text-decoration: none;
}
.header-links a:hover { color: white; }

.hero {
  position: relative;
  overflow: hidden;
  color: white;
  background: #123c37;
  padding: 72px 28px 126px;
}
.hero::after {
  content: '';
  position: absolute;
  width: 460px;
  height: 460px;
  right: -120px;
  top: -180px;
  border: 1px solid rgba(255,255,255,.12);
  border-radius: 50%;
  box-shadow: 0 0 0 72px rgba(255,255,255,.025), 0 0 0 144px rgba(255,255,255,.018);
}
.hero-inner {
  position: relative;
  z-index: 1;
  max-width: 1124px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: minmax(0, 1.6fr) minmax(260px, .7fr);
  gap: 70px;
  align-items: end;
}
.hero h1 {
  max-width: 760px;
  margin: 0;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(2.85rem, 6vw, 5.6rem);
  font-weight: 400;
  line-height: .98;
  letter-spacing: -.045em;
}
.hero-copy {
  max-width: 680px;
  margin: 24px 0 0;
  color: rgba(255,255,255,.76);
  font-size: 1.08rem;
}
.coverage-card {
  padding: 0 0 5px 28px;
  border-left: 1px solid rgba(255,255,255,.22);
}
.coverage-number {
  display: block;
  font-family: Georgia, serif;
  font-size: 2.4rem;
  line-height: 1;
}
.coverage-label {
  display: block;
  margin: 5px 0 20px;
  color: rgba(255,255,255,.64);
  font-size: .84rem;
}

.app-main {
  position: relative;
  z-index: 1;
  max-width: 1180px;
  margin: -72px auto 0;
  padding: 0 28px 80px;
}
.control-card {
  padding: 30px;
  background: var(--card);
  border: 1px solid rgba(255,255,255,.8);
  border-radius: 20px;
  box-shadow: var(--shadow);
}
.control-grid {
  display: grid;
  grid-template-columns: minmax(290px, 1.55fr) minmax(190px, .72fr) 42px minmax(190px, .72fr);
  gap: 18px;
  align-items: end;
}
.form-group { margin-bottom: 0; }
.form-label, .control-label {
  margin-bottom: 8px;
  color: var(--ink);
  font-size: .79rem;
  font-weight: 800;
  letter-spacing: .04em;
  text-transform: uppercase;
}
.form-control, .selectize-input {
  min-height: 48px;
  border: 1px solid #cfc7b8 !important;
  border-radius: 10px !important;
  background: #fff !important;
  box-shadow: none !important;
}
.selectize-input { padding: 13px 12px !important; }
.selectize-input.focus, .form-control:focus {
  border-color: var(--teal) !important;
  box-shadow: 0 0 0 3px rgba(12,116,105,.12) !important;
}
.swap-button {
  width: 42px;
  height: 48px;
  padding: 0;
  color: var(--teal-dark);
  background: var(--teal-pale);
  border: 0;
  border-radius: 10px;
  font-size: 1.15rem;
  font-weight: 800;
}
.swap-button:hover, .swap-button:focus { background: #c5e5df; color: var(--teal-dark); }
.quick-examples {
  margin-top: 15px;
  color: var(--ink-soft);
  font-size: .87rem;
}
.quick-examples .action-button {
  margin-left: 6px;
  padding: 0;
  color: var(--teal-dark);
  background: transparent;
  border: 0;
  border-bottom: 1px solid rgba(12,116,105,.35);
  border-radius: 0;
  font-family: var(--mono);
  font-size: .84rem;
}

.comparison-shell { margin-top: 30px; }

.signature-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
  margin-top: 20px;
}
.signature-panel {
  min-width: 0;
  padding: 24px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
}
.signature-panel-empty { background: rgba(255,255,255,.45); }
.version-heading { margin: 2px 0 19px; font-family: Georgia, serif; font-size: 1.65rem; }
.implementation + .implementation { margin-top: 20px; padding-top: 20px; border-top: 1px solid var(--line); }
.implementation-meta { display: flex; gap: 7px; margin-bottom: 10px; }
.package-badge, .visibility-badge {
  padding: 3px 8px;
  color: var(--teal-dark);
  background: var(--teal-pale);
  border-radius: 999px;
  font-family: var(--mono);
  font-size: .7rem;
  font-weight: 750;
}
.visibility-badge { color: #665022; background: #f3e7c9; font-family: inherit; }
.visibility-internal { color: #655f58; background: #ebe7e0; }
.signature-code {
  max-height: 260px;
  margin: 0 0 12px;
  padding: 15px;
  overflow: auto;
  white-space: normal;
  overflow-wrap: anywhere;
  color: #183c37;
  background: #f0eee7;
  border: 0;
  border-radius: 10px;
  font-family: var(--mono);
  font-size: .83rem;
  line-height: 1.55;
}
.argument-removed, .argument-added {
  padding: 1px 2px;
  border-radius: 3px;
}
.argument-removed {
  color: #8b1f1f;
  background: #f8dddd;
  text-decoration: line-through;
}
.argument-added { color: #155c36; background: #dcefe4; }
.documentation-link { font-size: .8rem; font-weight: 750; text-decoration: none; }
.empty-mark { margin: 35px 0 5px; color: #716d66; font-family: Georgia, serif; font-size: 1.3rem; }
.signature-panel-empty p { color: var(--ink-soft); font-size: .88rem; }

.section { margin-top: 78px; }
.section-heading {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 30px;
  margin-bottom: 22px;
}
.section-heading h2 {
  margin: 2px 0 0;
  font-family: Georgia, serif;
  font-size: clamp(2rem, 4vw, 3rem);
  font-weight: 400;
  letter-spacing: -.025em;
}
.section-heading p { max-width: 460px; margin: 0; color: var(--ink-soft); font-size: .91rem; }
.timeline { position: relative; }
.timeline::before {
  content: '';
  position: absolute;
  top: 18px;
  bottom: 18px;
  left: 11px;
  width: 1px;
  background: #c8beac;
}
.timeline-row {
  position: relative;
  display: grid;
  grid-template-columns: 22px minmax(180px, .55fr) minmax(0, 1.45fr);
  gap: 20px;
  padding: 0 0 24px;
}
.timeline-dot {
  position: relative;
  z-index: 1;
  width: 11px;
  height: 11px;
  margin-top: 15px;
  background: var(--paper);
  border: 3px solid var(--teal);
  border-radius: 50%;
  box-sizing: content-box;
}
.timeline-range { padding-top: 8px; color: var(--ink-soft); font-size: .78rem; font-weight: 750; }
.timeline-card {
  min-width: 0;
  padding: 17px 20px;
  background: rgba(255,253,250,.72);
  border: 1px solid var(--line);
  border-radius: 12px;
}
.timeline-card code {
  display: block;
  color: var(--ink);
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  font-size: .79rem;
  line-height: 1.5;
}
.timeline-meta { margin-top: 9px; color: var(--ink-soft); font-size: .74rem; }

.catalog-card {
  padding: 18px 20px 20px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  box-shadow: 0 8px 30px rgba(38,55,50,.05);
}
.catalog-card .dataTables_filter { margin-bottom: 14px; }
.catalog-card .dataTables_filter input { min-width: 260px; margin-left: 8px; }
.catalog-card table.dataTable { border-collapse: collapse !important; }
.catalog-card table.dataTable thead th {
  color: var(--ink-soft);
  border-bottom: 1px solid var(--line) !important;
  font-size: .7rem;
  letter-spacing: .06em;
  text-transform: uppercase;
}
.catalog-card table.dataTable tbody td { padding: 11px 10px; border-color: #eee8dd; font-size: .82rem; }
.catalog-card table.dataTable tbody td:first-child { color: var(--teal-dark); font-family: var(--mono); font-weight: 700; }
.catalog-card table.dataTable tbody tr.selected > * { color: var(--ink) !important; background: var(--teal-pale) !important; box-shadow: none !important; }
.dataTables_info, .dataTables_paginate { margin-top: 14px; color: var(--ink-soft) !important; font-size: .78rem; }

.site-footer {
  color: rgba(255,255,255,.72);
  background: #123c37;
  padding: 38px 28px;
  font-size: .82rem;
}
.footer-inner { max-width: 1124px; margin: 0 auto; display: flex; justify-content: space-between; gap: 25px; }
.site-footer a { color: white; }

@media (max-width: 880px) {
  .hero-inner { grid-template-columns: 1fr; gap: 38px; }
  .coverage-card { display: flex; gap: 28px; padding: 22px 0 0; border-left: 0; border-top: 1px solid rgba(255,255,255,.22); }
  .coverage-label { margin-bottom: 0; }
  .control-grid { grid-template-columns: 1fr 1fr; }
  .function-control { grid-column: 1 / -1; }
  .swap-button { display: none; }
  .signature-grid { grid-template-columns: 1fr; }
}
@media (max-width: 620px) {
  .site-header-inner, .hero, .app-main { padding-left: 18px; padding-right: 18px; }
  .header-links a:first-child { display: none; }
  .hero { padding-top: 50px; }
  .hero h1 { font-size: 2.8rem; }
  .coverage-card { flex-wrap: wrap; }
  .control-card { padding: 20px; }
  .control-grid { grid-template-columns: 1fr; }
  .section { margin-top: 58px; }
  .section-heading { display: block; }
  .section-heading p { margin-top: 10px; }
  .timeline-row { grid-template-columns: 22px 1fr; gap: 13px; }
  .timeline-range { grid-column: 2; padding-top: 8px; }
  .timeline-card { grid-column: 2; }
  .catalog-card { overflow-x: auto; }
  .footer-inner { display: block; }
}
"

simple_css <- "
body {
  color: #202624;
  background: #f6f7f6;
  font-size: 15px;
  line-height: 1.45;
}
.site-header {
  color: #202624;
  background: #ffffff;
  border-bottom: 1px solid #dfe3e1;
}
.site-header-inner {
  max-width: 1100px;
  min-height: 64px;
  padding: 10px 24px;
}
.brand {
  color: #202624;
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: 0;
}
.brand:hover { color: #202624; }
.header-links { gap: 18px; }
.header-links a { color: #4c5a56; font-size: .86rem; }
.header-links a:hover { color: #0c7469; }
.app-main {
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px 24px 54px;
}
.intro { margin: 0 0 18px; }
.intro h1 {
  margin: 0 0 3px;
  font-family: inherit;
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -.02em;
}
.intro p { margin: 0; color: #56635f; }
.control-card {
  padding: 20px;
  background: #ffffff;
  border: 1px solid #dfe3e1;
  border-radius: 8px;
  box-shadow: none;
}
.control-grid {
  grid-template-columns: minmax(250px, 1.35fr) minmax(180px, .75fr) 40px minmax(180px, .75fr);
  gap: 14px;
  align-items: start;
}
.form-label, .control-label {
  margin-bottom: 6px;
  color: #37423f;
  font-size: .74rem;
  letter-spacing: .025em;
}
.form-control, .selectize-input {
  min-height: 42px;
  border-color: #cbd2cf !important;
  border-radius: 5px !important;
}
.selectize-input { padding: 10px 11px !important; }
.search-package { color: #7a8581; }
.selectize-control.plugin-remove_button .item .remove {
  padding: 0 7px;
  color: #5d6965;
  border-left-color: #dfe3e1;
}
.search-help {
  margin: 7px 0 0;
  color: #68736f;
  font-size: .79rem;
}
.search-help code { color: #3c4945; }
.swap-button {
  width: 40px;
  height: 42px;
  margin-top: 26px;
  color: #315f58;
  background: #edf4f2;
  border-radius: 5px;
}
.comparison-shell { margin-top: 16px; }
.signature-grid { gap: 12px; margin-top: 12px; }
.signature-panel {
  padding: 16px;
  background: #ffffff;
  border-color: #dfe3e1;
  border-radius: 6px;
}
.version-heading {
  margin: 1px 0 12px;
  font-family: inherit;
  font-size: 1.15rem;
  font-weight: 650;
}
.signature-code {
  max-height: 180px;
  padding: 12px;
  background: #f4f6f5;
  border-radius: 4px;
}
.history-disclosure {
  margin-top: 14px;
  background: #ffffff;
  border: 1px solid #dfe3e1;
  border-radius: 6px;
}
.history-disclosure summary {
  padding: 13px 16px;
  cursor: pointer;
  color: #24302c;
  font-weight: 650;
}
.history-content { padding: 2px 16px 14px; }
.history-help { margin: 0 0 15px; color: #68736f; font-size: .82rem; }
.timeline-row { grid-template-columns: 18px minmax(150px, .5fr) minmax(0, 1.5fr); gap: 14px; padding-bottom: 14px; }
.timeline::before { left: 5.5px; }
.timeline-dot { width: 8px; height: 8px; margin-top: 13px; border-width: 2px; }
.timeline-card { padding: 12px 14px; border-radius: 5px; }
.catalog-section { margin-top: 26px; }
.catalog-heading { margin-bottom: 12px; }
.catalog-heading h2 { margin: 0; font-size: 1.35rem; }
.catalog-heading p { margin: 3px 0 0; color: #68736f; font-size: .84rem; }
.catalog-card {
  padding: 12px 14px 14px;
  border-color: #dfe3e1;
  border-radius: 6px;
  box-shadow: none;
}
.catalog-card table.dataTable tbody td { padding: 8px 9px; }
.site-footer { padding: 20px 24px; color: #59635f; background: #eef0ef; }
.site-footer a { color: #315f58; }
.footer-inner { max-width: 1052px; }
@media (max-width: 880px) {
  .control-grid { grid-template-columns: 1fr 1fr; }
  .function-control { grid-column: 1 / -1; }
}
@media (max-width: 620px) {
  .site-header-inner, .app-main { padding-left: 16px; padding-right: 16px; }
  .control-grid { grid-template-columns: 1fr; }
  .signature-grid { grid-template-columns: 1fr; }
  .timeline-row { grid-template-columns: 18px 1fr; }
}
"

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bg = "#f5f1e8",
    fg = "#17312d",
    primary = "#0c7469"
  ),
  tags$head(
    tags$title("rcheology · Compare R function history"),
    tags$meta(
      name = "description",
      content = "Compare base and recommended R function interfaces across R versions."
    ),
    tags$style(HTML(paste(app_css, simple_css))),
    tags$script(HTML(
      "Shiny.addCustomMessageHandler('scroll-to-compare', function(_) {
         document.getElementById('compare').scrollIntoView({behavior: 'smooth'});
       });"
    ))
  ),
  div(
    id = "top",
    class = "site-header",
    div(
      class = "site-header-inner",
      a(
        class = "brand",
        href = "#top",
        "rcheology"
      ),
      div(
        class = "header-links",
        a(
          href = "https://github.com/hughjonesd/rcheology",
          target = "_blank",
          rel = "noopener noreferrer",
          "GitHub ↗"
        )
      )
    )
  ),
  tags$main(
    id = "compare",
    class = "app-main",
    div(
      class = "intro",
      h1("Compare R functions"),
      p(
        "Compare a function's recorded arguments and availability between two R versions. ",
        "Function implementations are not compared. For more control, download the ",
        a(
          href = "https://github.com/hughjonesd/rcheology",
          target = "_blank",
          rel = "noopener noreferrer",
          "rcheology package."
        )
      )
    ),
    div(
      class = "control-card",
      div(
        class = "control-grid",
        div(
          class = "function-control",
          selectizeInput(
            "function_name",
            "Function",
            choices = NULL,
            options = list(
              placeholder = "Search for a function",
              options = function_options,
              items = list(default_function),
              maxOptions = 3000,
              plugins = list("remove_button"),
              onFocus = I("function() { if (this.items.length) this.clear(); }"),
              valueField = "value",
              labelField = "label",
              searchField = c("name", "label"),
              sortField = list(
                list(field = "name_length", direction = "asc"),
                list(field = "name", direction = "asc"),
                list(field = "current", direction = "desc"),
                list(field = "last_id", direction = "desc"),
                list(field = "package", direction = "asc"),
                list(field = "$score", direction = "desc")
              ),
              render = I(
                "{
                   option: function(item, escape) {
                     return '<div><span class=\"search-package\">' +
                       escape(item.package) + '::</span>' + escape(item.name) + '</div>';
                   },
                   item: function(item, escape) {
                     return '<div><span class=\"search-package\">' +
                       escape(item.package) + '::</span>' + escape(item.name) + '</div>';
                   }
                 }"
              ),
              score = I(
                "function(search) {
                   var query = String(search).toLowerCase().trim();
                   var qualified = query.indexOf('::') !== -1;
                   return function(item) {
                     var text = String(qualified ? item.label : item.name).toLowerCase();
                     if (text === query) return 2;
                     return text.indexOf(query) === -1 ? 0 : 1;
                   };
                 }"
              )
            )
          ),
          p(
            class = "search-help",
            HTML(
              paste(
                "Type a function name, for example <code>lm</code>.",
                "Version lists show where the selected package and function were recorded."
              )
            )
          )
        ),
        selectInput(
          "baseline_version",
          "Baseline R",
          choices = rev(version_choices),
          selected = default_baseline
        ),
        actionButton(
          "swap_versions",
          label = "⇄",
          class = "swap-button",
          title = "Swap versions",
          `aria-label` = "Swap versions"
        ),
        selectInput(
          "target_version",
          "Compare with",
          choices = rev(version_choices),
          selected = default_target
        )
      )
    ),
    uiOutput("comparison_panels"),
    uiOutput("history_section"),
    tags$section(
      id = "catalog",
      class = "catalog-section",
      div(
        class = "catalog-heading",
        h2("Functions"),
        p("Search the catalog or select a row to load that function into the comparison above.")
      ),
      div(class = "catalog-card", DTOutput("function_catalog"))
    )
  ),
  tags$footer(
    class = "site-footer",
    div(
      class = "footer-inner",
      span(
        "Data and source: ",
        a(href = "https://github.com/hughjonesd/rcheology", "rcheology dataset"),
        "."
      ),
      span("Documentation: ", a(href = "https://github.com/hughjonesd/r-help", "r-help"), ".")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$swap_versions, {
    baseline <- input$baseline_version
    updateSelectInput(session, "baseline_version", selected = input$target_version)
    updateSelectInput(session, "target_version", selected = baseline)
  })

  selected_history <- reactive({
    req(input$function_name, nzchar(input$function_name))
    qualified <- grepl("^[^:]+::.+$", input$function_name)
    function_name <- if (qualified) {
      sub("^[^:]+::", "", input$function_name)
    } else {
      input$function_name
    }
    history <- filter(rch_history, name == function_name)

    if (qualified) {
      selected_package <- sub("::.*$", "", input$function_name)
      history <- filter(history, .data$package == .env$selected_package)
    }

    history
  })

  observeEvent(input$function_name, {
    history <- selected_history()
    version_ids <- sort(unique(unlist(history$version_ids)))
    choices <- rev(version_choices[version_ids])

    baseline <- isolate(input$baseline_version)
    if (length(baseline) != 1 || ! baseline %in% app_versions$key[version_ids]) {
      baseline <- app_versions$key[min(version_ids)]
    }

    target <- isolate(input$target_version)
    if (length(target) != 1 || ! target %in% app_versions$key[version_ids]) {
      target <- app_versions$key[max(version_ids)]
    }

    updateSelectInput(
      session,
      "baseline_version",
      choices = choices,
      selected = baseline
    )
    updateSelectInput(
      session,
      "target_version",
      choices = choices,
      selected = target
    )
  })

  output$comparison_panels <- renderUI({
    history <- selected_history()
    baseline_id <- match(input$baseline_version, app_versions$key)
    target_id <- match(input$target_version, app_versions$key)
    req(! is.na(baseline_id), ! is.na(target_id))

    baseline_rows <- history_at_version(history, baseline_id)
    target_rows <- history_at_version(history, target_id)
    div(
      class = "comparison-shell",
      div(
        class = "signature-grid",
        signature_panel(
          baseline_rows,
          target_rows,
          baseline_id,
          "Baseline",
          "argument-removed"
        ),
        signature_panel(
          target_rows,
          baseline_rows,
          target_id,
          "Comparison",
          "argument-added"
        )
      )
    )
  })

  output$history_section <- renderUI({
    history <- selected_history() |>
      arrange(desc(last_id), desc(first_id), package)

    tags$details(
      class = "history-disclosure",
      tags$summary("Interface history"),
      div(
        class = "history-content",
        p(
          class = "history-help",
          paste(
            "Distinct recorded signatures and metadata states across R versions.",
            "Arguments added or changed since the previous state are highlighted in green."
          )
        ),
        div(
          class = "timeline",
          lapply(seq_len(nrow(history)), function(i) {
            row <- history[i, ]
            version_ids <- sort(unique(row$version_ids[[1]]))
            version_groups <- cumsum(c(TRUE, diff(version_ids) != 1))
            version_span <- vapply(split(version_ids, version_groups), function(ids) {
              first <- app_versions$label[ids[1]]
              last <- app_versions$label[ids[length(ids)]]
              if (first == last) first else paste(first, last, sep = " – ")
            }, character(1)) |>
              paste(collapse = "; ")
            previous_rows <- history[history$last_id < row$first_id, ]
            if (nrow(previous_rows) > 0) {
              same_package <- which(previous_rows$package == row$package)
              if (length(same_package) > 0) {
                previous_rows <- previous_rows[same_package, ]
              }
              previous_row <- previous_rows[which.max(previous_rows$last_id), ]
              previous_args <- previous_row$args
              signature <- signature_html(row, previous_args, "argument-added")
            } else {
              signature <- signature_html(row)
            }
            metadata <- c(
              row$type,
              row$class,
              if (isTRUE(row$exported)) "exported" else "internal"
            )
            metadata <- metadata[! is.na(metadata) & metadata != ""]

            div(
              class = "timeline-row",
              div(class = "timeline-dot", `aria-hidden` = "true"),
              div(class = "timeline-range", version_span),
              div(
                class = "timeline-card",
                code(signature),
                div(class = "timeline-meta", paste(metadata, collapse = " · "))
              )
            )
          })
        )
      )
    )
  })

  output$function_catalog <- renderDT({
    datatable(
      catalog_table,
      rownames = FALSE,
      selection = "single",
      class = "stripe hover",
      options = list(
        dom = "ftp",
        pageLength = 15,
        order = list(list(0, "asc")),
        language = list(
          search = "Find a function",
          searchPlaceholder = "name or package…"
        ),
        columnDefs = list(
          list(className = "dt-left", targets = c(0, 1)),
          list(className = "dt-center", targets = c(2, 3, 4, 5))
        )
      )
    )
  }, server = FALSE)

  observeEvent(input$function_catalog_rows_selected, {
    row <- input$function_catalog_rows_selected
    req(length(row) == 1)
    selected_name <- catalog_table$Function[row]
    selected_value <- function_choices |>
      filter(name == selected_name) |>
      slice_head(n = 1) |>
      pull(value)
    updateSelectizeInput(
      session,
      "function_name",
      selected = selected_value
    )
    session$sendCustomMessage("scroll-to-compare", list())
  })
}

shinyApp(ui = ui, server = server)
