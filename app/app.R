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
    tags$style(HTML(app_css)),
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
        span(class = "brand-mark", "R"),
        span("RCHEOLOGY")
      ),
      div(
        class = "header-links",
        a(href = "#catalog", "Browse functions"),
        a(
          href = "https://github.com/hughjonesd/rcheology",
          target = "_blank",
          rel = "noopener noreferrer",
          "GitHub ↗"
        )
      )
    )
  ),
  div(
    class = "hero",
    div(
      class = "hero-inner",
      div(
        div(class = "kicker", "A field guide to R's past"),
        h1("Did this R function change?"),
        p(
          class = "hero-copy",
          "Compare a function's recorded interface across releases—from early R to today's development snapshots."
        )
      ),
      div(
        class = "coverage-card",
        div(
          span(class = "coverage-number", format(nrow(app_versions), big.mark = ",")),
          span(class = "coverage-label", "R versions indexed")
        ),
        div(
          span(class = "coverage-number", format(nrow(function_catalog), big.mark = ",")),
          span(class = "coverage-label", "callable names")
        )
      )
    )
  ),
  tags$main(
    id = "compare",
    class = "app-main",
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
              placeholder = "Type a function name, e.g. kmeans",
              maxOptions = 80
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
      ),
      div(
        class = "quick-examples",
        "Try",
        actionButton("example_kmeans", "kmeans"),
        actionButton("example_read_csv", "read.csv"),
        actionButton("example_sample", "sample")
      )
    ),
    uiOutput("comparison_result"),
    tags$section(
      class = "section",
      div(
        class = "section-heading",
        div(
          div(class = "section-kicker", "Stratigraphy"),
          h2("Recorded interface history")
        ),
        p("Each layer represents a distinct signature or metadata state. Version spans may contain gaps when a state later reappeared.")
      ),
      uiOutput("function_history")
    ),
    tags$section(
      id = "catalog",
      class = "section",
      div(
        class = "section-heading",
        div(
          div(class = "section-kicker", "The full dig"),
          h2("Browse all functions")
        ),
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
        "Built from the ",
        a(href = "https://github.com/hughjonesd/rcheology", "rcheology dataset"),
        "."
      ),
      span("Documentation snapshots are hosted by ", a(href = "https://github.com/hughjonesd/r-help", "r-help"), ".")
    )
  )
)

server <- function(input, output, session) {
  function_choices <- setNames(
    function_catalog$name,
    paste0(function_catalog$name, "  ·  ", function_catalog$packages)
  )

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

  observeEvent(input$example_kmeans, {
    updateSelectizeInput(
      session, "function_name",
      choices = function_choices, selected = "kmeans", server = TRUE
    )
  })

  observeEvent(input$example_read_csv, {
    updateSelectizeInput(
      session, "function_name",
      choices = function_choices, selected = "read.csv", server = TRUE
    )
  })

  observeEvent(input$example_sample, {
    updateSelectizeInput(
      session, "function_name",
      choices = function_choices, selected = "sample", server = TRUE
    )
  })

  selected_history <- reactive({
    req(input$function_name)
    filter(rch_history, name == input$function_name)
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
      status_icon <- "·"
      status_title <- "Not present in either version"
      status_text <- "Choose versions within this function's recorded lifespan."
    } else if (nrow(baseline_rows) == 0) {
      status_class <- "status-introduced"
      status_icon <- "+"
      status_title <- "Available in the comparison version"
      status_text <- "This callable was not recorded at the baseline, but it is present in the comparison version."
    } else if (nrow(target_rows) == 0) {
      status_class <- "status-removed"
      status_icon <- "−"
      status_title <- "No longer available"
      status_text <- "This callable was recorded at the baseline, but not in the comparison version."
    } else if (identical(baseline_signature, target_signature)) {
      status_class <- "status-steady"
      status_icon <- "="
      status_title <- "No recorded interface change"
      status_text <- "The signature, package, type, class, and visibility match in both versions."
    } else {
      status_class <- "status-change"
      status_icon <- "Δ"
      status_title <- "Recorded interface changed"
      status_text <- "At least one recorded part of this callable differs between the selected versions."
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
        div(class = "answer-icon", status_icon),
        div(
          div(class = "answer-kicker", paste("Result for", input$function_name)),
          h2(status_title),
          p(status_text),
          if (length(change_notes) > 0) {
            p(class = "change-notes", paste("Differences:", paste(change_notes, collapse = ", ")))
          }
        )
      ),
      p(
        class = "scope-note",
        "Scope: this compares recorded interfaces and availability. A function body may have changed even when its interface did not."
      ),
      div(
        class = "signature-grid",
        signature_panel(baseline_rows, baseline_id, "Baseline"),
        signature_panel(target_rows, target_id, "Comparison")
      )
    )
  })

  output$function_history <- renderUI({
    history <- selected_history() |>
      arrange(desc(last_id), desc(first_id), package)

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
