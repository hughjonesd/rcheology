#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(dplyr)

load("rcheology-app-data.RData")



ncol_rchs <- ncol(rch_summary)


frc <- function (...) fluidRow(column(10, ..., offset = 1))
ui <- fluidPage(
  titlePanel(paste("Base R Functions from R",  min(Rversions) ,"onwards")),
  frc(
    "Created using the ", a(href = "https://github.com/hughjonesd/rcheology", "rcheology"), " package."), 
  frc("Regexes work in filters. You can search for all versions in ", code("Versions"), "."),
  frc(HTML("Documentation links go to <a href='https://github.com/hughjonesd/r-help'>hughjonesd/r-help</a> on github. Please report broken links there.")),
  frc("This is on the shinyapps free plan; if it runs out of credit, visit ", 
    a(href = "https://github.com/hughjonesd/rcheology", "github.com/hughjonesd/rcheology"), 
    " to download the data and a copy of this app."),
  frc(HTML("<br/>")),
  frc(dataTableOutput("rcheology_DT"))
)


rch_summary <- select(rch_summary,
                      name, package, versions, args, type, class, exported, 
                      hidden)

search_col_opts <- rep(list(NULL), ncol(rch_summary))
hidden_col <- which(names(rch_summary) == "hidden")
exported_col <- which(names(rch_summary) == "exported")
search_col_opts[[hidden_col]] <- list(search = "false")
search_col_opts[[exported_col]] <- list(search = "true")

server <- function(input, output) {
  summary_dt <- DT::datatable(
        rch_summary, 
        rownames = FALSE,
        class    = "compact",
        filter   = "top",
        escape   = setdiff(names(rch_summary), "versions"),
        options  = list(
          dom        = 'ltipr', # no global search box
          pageLength = 10,
          search     = list(regex = TRUE, caseInsensitive = FALSE),
          searchCols = search_col_opts,
          order      = c(0, "asc")
        ))
  summary_dt <- DT::formatStyle(summary_dt, c("name", "args"), 
                                `font-family` = "courier, monospace")
  summary_dt <- DT::formatStyle(summary_dt, c("args"), 
                                `font-size` = "8pt")
  output$rcheology_DT <- DT::renderDataTable(summary_dt)
  dt_proxy <- DT::dataTableProxy("rcheology_DT")
}

# Run the application 
shinyApp(ui = ui, server = server)

