library(shiny)
library(bslib)
library(DT)
library(dplyr)

load("rcheology-app-data.RData")

version_choice_labels <- ifelse(
  is.na(app_versions$date),
  app_versions$label,
  paste0(app_versions$label, "  ·  ", format(app_versions$date, "%d %b %Y"))
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
default_function <- if ("kmeans" %in% function_catalog$name) {
  "kmeans"
} else {
  function_catalog$name[1]
}

qualified_function_names <- rch_history |>
  distinct(package, name) |>
  transmute(name = paste0(package, "::", name)) |>
  arrange(name) |>
  pull(name)

function_choice_values <- c(function_catalog$name, qualified_function_names)
function_choices <- setNames(function_choice_values, function_choice_values)

history_at_version <- function(history, version_id) {
  history[vapply(history$version_ids, function(x) version_id %in% x, logical(1)), ]
}

state_signature <- function(rows) {
  if (nrow(rows) == 0) return(character())

  rows |>
    transmute(
      package,
      args = if_else(is.na(args), "", args),
      type = if_else(is.na(type), "", type),
      class = if_else(is.na(class), "", class),
      exported,
      hidden
    ) |>
    arrange(package, args, type, class, exported, hidden) |>
    apply(1, paste, collapse = "|")
}

signature_panel <- function(rows, version_id, eyebrow) {
  version <- app_versions[version_id, ]

  if (nrow(rows) == 0) {
    return(div(
      class = "signature-panel signature-panel-empty",
      div(class = "panel-eyebrow", eyebrow),
      div(class = "version-heading", version$label),
      div(class = "empty-mark", "Not available"),
      p("This name was not recorded as a callable object in this version.")
    ))
  }

  div(
    class = "signature-panel",
    div(class = "panel-eyebrow", eyebrow),
    div(class = "version-heading", version$label),
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
      signature <- if (is.na(row$args)) {
        paste0(row$package, "::", row$name, "  (arguments not recorded)")
      } else {
        paste0(row$package, "::", row$name, row$args)
      }

      div(
        class = "implementation",
        div(
          class = "implementation-meta",
          span(class = "package-badge", row$package),
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
.kicker {
  margin-bottom: 18px;
  color: #8dd2c7;
  font-size: .78rem;
  font-weight: 800;
  letter-spacing: .16em;
  text-transform: uppercase;
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

.result-shell { margin-top: 30px; }
.answer-banner {
  display: flex;
  align-items: flex-start;
  gap: 17px;
  padding: 24px 26px;
  background: var(--teal-pale);
  border: 1px solid #bbdcd5;
  border-radius: 16px;
}
.answer-banner.status-change { background: var(--copper-pale); border-color: #edc4b3; }
.answer-banner.status-introduced { background: #e8efdc; border-color: #cfdcb8; }
.answer-banner.status-removed, .answer-banner.status-unavailable { background: #eeeae3; border-color: #d7d0c5; }
.answer-icon {
  flex: 0 0 auto;
  width: 40px;
  height: 40px;
  display: grid;
  place-items: center;
  color: white;
  background: var(--teal);
  border-radius: 50%;
  font-size: 1.12rem;
  font-weight: 850;
}
.status-change .answer-icon { background: var(--copper); }
.status-introduced .answer-icon { background: #66813d; }
.status-removed .answer-icon, .status-unavailable .answer-icon { background: #716d66; }
.answer-kicker {
  color: var(--ink-soft);
  font-size: .74rem;
  font-weight: 800;
  letter-spacing: .1em;
  text-transform: uppercase;
}
.answer-banner h2 { margin: 2px 0 4px; font-size: 1.55rem; letter-spacing: -.02em; }
.answer-banner p { margin: 0; color: var(--ink-soft); }
.change-notes { margin-top: 8px !important; font-size: .9rem; font-weight: 650; }
.scope-note { margin: 11px 4px 0; color: var(--ink-soft); font-size: .8rem; }

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
.panel-eyebrow {
  color: var(--ink-soft);
  font-size: .71rem;
  font-weight: 800;
  letter-spacing: .11em;
  text-transform: uppercase;
}
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
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  color: #183c37;
  background: #f0eee7;
  border: 0;
  border-radius: 10px;
  font-family: var(--mono);
  font-size: .83rem;
  line-height: 1.55;
}
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
.section-kicker {
  color: var(--copper);
  font-size: .74rem;
  font-weight: 850;
  letter-spacing: .12em;
  text-transform: uppercase;
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
  color: #315f58;
  background: #edf4f2;
  border-radius: 5px;
}
.result-shell { margin-top: 16px; }
.answer-banner {
  display: block;
  padding: 15px 18px;
  background: #ffffff;
  border: 1px solid #dfe3e1;
  border-left: 4px solid #0c7469;
  border-radius: 6px;
}
.answer-banner.status-change { background: #ffffff; border-color: #dfe3e1; border-left-color: #bd6848; }
.answer-banner.status-introduced { background: #ffffff; border-color: #dfe3e1; border-left-color: #66813d; }
.answer-banner.status-removed, .answer-banner.status-unavailable {
  background: #ffffff;
  border-color: #dfe3e1;
  border-left-color: #716d66;
}
.answer-kicker { font-size: .7rem; letter-spacing: .05em; }
.answer-banner h2 { margin: 2px 0; font-size: 1.25rem; }
.answer-banner p { color: #56635f; }
.change-notes { margin-top: 5px !important; font-size: .84rem; }
.signature-grid { gap: 12px; margin-top: 12px; }
.signature-panel {
  padding: 16px;
  background: #ffffff;
  border-color: #dfe3e1;
  border-radius: 6px;
}
.panel-eyebrow { font-size: .68rem; letter-spacing: .06em; }
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
.timeline::before { left: 8px; }
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
      p("Check whether a function's recorded interface differs between two R versions.")
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
              maxOptions = 400,
              plugins = list("remove_button"),
              onFocus = I("function() { if (this.items.length) this.clear(); }"),
              score = I(
                "function(search) {
                   var query = search.toLowerCase().trim();
                   return function(item) {
                     var text = String(item.text || item.label || item.value || '').toLowerCase();
                     if (text.indexOf('::') !== -1 && query.indexOf('::') === -1) return 0;
                     if (text === query) return 100;
                     var position = text.indexOf(query);
                     if (position === -1) return 0;
                     return (position === 0 ? 2 : 1) + query.length / text.length;
                   };
                 }"
              )
            )
          ),
          p(
            class = "search-help",
            "For a specific package, use ", code("stats::lm"), "."
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
    uiOutput("comparison_result"),
    tags$section(
      id = "catalog",
      class = "catalog-section",
      div(
        class = "catalog-heading",
        h2("Functions"),
        p("Search the catalog or select a row to load that function into the comparison above.")
      ),
      div(class = "catalog-card", DTOutput("function_catalog"))
    ),
    uiOutput("history_section")
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
  updateSelectizeInput(
    session,
    "function_name",
    choices = function_choices,
    selected = default_function,
    server = TRUE
  )

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

  output$comparison_result <- renderUI({
    history <- selected_history()
    baseline_id <- match(input$baseline_version, app_versions$key)
    target_id <- match(input$target_version, app_versions$key)
    req(! is.na(baseline_id), ! is.na(target_id))

    baseline_rows <- history_at_version(history, baseline_id)
    target_rows <- history_at_version(history, target_id)
    baseline_signature <- state_signature(baseline_rows)
    target_signature <- state_signature(target_rows)

    if (nrow(baseline_rows) == 0 && nrow(target_rows) == 0) {
      status_class <- "status-unavailable"
      status_title <- "Not present in either version"
      status_text <- paste(
        "This function was not recorded in either selected version.",
        "This tool compares recorded interfaces and availability, not implementations."
      )
    } else if (nrow(baseline_rows) == 0) {
      status_class <- "status-introduced"
      status_title <- "Available in the comparison version"
      status_text <- paste(
        "This function was not recorded at the baseline, but is present in the comparison version.",
        "Function implementations are not compared."
      )
    } else if (nrow(target_rows) == 0) {
      status_class <- "status-removed"
      status_title <- "No longer available"
      status_text <- paste(
        "This function was recorded at the baseline, but not in the comparison version.",
        "Function implementations are not compared."
      )
    } else if (identical(baseline_signature, target_signature)) {
      status_class <- "status-steady"
      status_title <- "No recorded interface change"
      status_text <- paste(
        "The recorded signature, package, type, class, and visibility are the same in both versions.",
        "Function implementations are not compared."
      )
    } else {
      status_class <- "status-change"
      status_title <- "Recorded interface changed"
      status_text <- paste(
        "At least one recorded interface detail differs between the selected versions.",
        "Function implementations are not compared."
      )
    }

    change_notes <- character()
    if (nrow(baseline_rows) > 0 && nrow(target_rows) > 0) {
      if (! setequal(baseline_rows$package, target_rows$package)) {
        change_notes <- c(change_notes, "package membership")
      }
      if (! setequal(baseline_rows$args, target_rows$args)) {
        change_notes <- c(change_notes, "arguments")
      }
      if (! setequal(baseline_rows$exported, target_rows$exported) ||
          ! setequal(baseline_rows$hidden, target_rows$hidden)) {
        change_notes <- c(change_notes, "visibility")
      }
      if (! setequal(baseline_rows$type, target_rows$type) ||
          ! setequal(baseline_rows$class, target_rows$class)) {
        change_notes <- c(change_notes, "type or class")
      }
    }

    div(
      class = "result-shell",
      div(
        class = paste("answer-banner", status_class),
        div(
          div(class = "answer-kicker", paste("Result for", input$function_name)),
          h2(status_title),
          p(status_text),
          if (length(change_notes) > 0) {
            p(class = "change-notes", paste("Differences:", paste(change_notes, collapse = ", ")))
          }
        )
      ),
      div(
        class = "signature-grid",
        signature_panel(baseline_rows, baseline_id, "Baseline"),
        signature_panel(target_rows, target_id, "Comparison")
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
          "Distinct recorded signatures and metadata states across R versions."
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
            signature <- if (is.na(row$args)) {
              paste0(row$package, "::", row$name, "  (arguments not recorded)")
            } else {
              paste0(row$package, "::", row$name, row$args)
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
    updateSelectizeInput(
      session,
      "function_name",
      choices = function_choices,
      selected = catalog_table$Function[row],
      server = TRUE
    )
    session$sendCustomMessage("scroll-to-compare", list())
  })
}

shinyApp(ui = ui, server = server)
