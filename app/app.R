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

kw_opts <- list(
      debug  = list(
        global  = "", 
        columns = c("debug", "base", rep("", ncol_rchs - 2))
      ),
      `order (exact)`  = list(
        global  = "",
        columns = c("^order$", "", rep("", ncol_rchs - 2))
      ),
      `parallel package` = list(
        global  = "",
        columns = c("", "parallel", rep("", ncol_rchs - 2))
      ),
      `debugonce (R 3.2.5)` = list(
        global  = "",
        columns = c("debugonce", rep("", ncol_rchs - 4), "3.2.5", "", "")
      )
)
keywords <- names(kw_opts)

frc <- function (...) fluidRow(column(10, ..., offset = 1))
ui <- fluidPage(
  titlePanel("Base R Functions from 2.0.0 onwards"),
  frc(
    "Created using the ", a(href = "https://github.com/hughjonesd/rcheology", "rcheology"), " package."), 
  frc(code("Ever changed?"), " is true if a function was introduced or removed."),
  frc(code("Args changed?"), " is true if a function's arguments changed."),
  frc("Regexes work in filters."),
  frc(HTML("Links go to <a href='https://rdocumentation.org'>rdocumentation.org</a> and may not always work.")),
  frc(" Try: ", lapply(keywords, function (kw) list(HTML("&nbsp;"), actionLink(kw, kw)))),
  frc(HTML("<br/>")),
  frc(dataTableOutput("rcheology_DT"))
)

server <- function(input, output) {
  summary_dt <- DT::datatable(
        rch_summary, 
        rownames = FALSE,
        filter   = "top",
        escape   = setdiff(names(rch_summary), "versions"),
        options  = list(
          dom        = 'ltipr', # no global search box
          pageLength = 10,
          search     = list(regex = TRUE, caseInsensitive = FALSE),
          order      = c(0, "asc")
        ))
  summary_dt <- DT::formatStyle(summary_dt, c("name", "args"), `font-family` = "courier, monospace")
  
  output$rcheology_DT <- DT::renderDataTable(summary_dt)
  dt_proxy <- DT::dataTableProxy("rcheology_DT")
   
   lapply(keywords, function (kw) {
     observeEvent(input[[kw]], {
       DT::updateSearch(
              dt_proxy, 
              keywords = kw_opts[[kw]]
            )
     })
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

