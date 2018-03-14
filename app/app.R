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


rch_summary <- rch_summary %>% 
      rename(`Ever changed?` = "ever_changed", `Args changed?` = "args_changed") %>% 
      select(- type, - class, - generic) %>% 
      mutate(args = sub("^function ", "", args))
ncol_rchs <- ncol(rch_summary)

kw_opts <- list(
      debug  = list(
        global = "", 
        columns = c("debug", "base", rep("", ncol_rchs - 2))
      ),
      order  = list(
        global = "",
        columns = c("order", "base", rep("", ncol_rchs - 2))
      ),
      hasName = list(
        global = "hasName", 
        columns = rep("", ncol_rchs)
      ),
      `debugonce@3.2.5` = list(
        global = "",
        columns = c("debugonce", rep("", ncol_rchs - 4), "3.2.5", "", "")
      )
)
keywords <- names(kw_opts)

frc <- function (...) fluidRow(column(10, ..., offset = 1))
ui <- fluidPage(
  titlePanel("Base R Functions from 3.0.1 to 3.4.3"),
  frc(
    "Created using the ", a(href = "https://github.com/hughjonesd/rcheology", "rcheology"), " package."), 
  frc(" Try: ", lapply(keywords, function (kw) actionLink(kw, kw))),
  frc(code("Ever changed?"), " is true if a function was introduced or removed."),
  frc(code("Args changed?"), " is true if a function's arguments changed."),
  frc(HTML("<br/>")),
  frc(dataTableOutput("rcheology_DT"))
)

server <- function(input, output) {
   output$rcheology_DT <- DT::renderDataTable(
        rch_summary, 
        rownames = FALSE,
        filter   = "top",
        escape   = setdiff(names(rch_summary), "versions"),
        options  = list(
          pageLength = 10,
          search     = list(regex = TRUE, caseInsensitive = FALSE),
          order      = c(0, "asc")
        ))
   
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

