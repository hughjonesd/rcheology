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

load("rcheology-app-data.RData")

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
      `debugonce@3.4.0` = list(
        global = "",
        columns = c("debugonce", rep("", ncol_rchs - 2), "3.4.0")
      )
)
keywords <- names(kw_opts)

ui <- fluidPage(
  titlePanel("Base R Functions from 3.0.1 to 3.4.3"),
  sidebarLayout(
    sidebarPanel(
      "Created using the ", a(href = "https://github.com/hughjonesd/rcheology", "rcheology"), 
      " package.", " Try: ", lapply(keywords, function (kw) actionLink(kw, kw))
    ),
      
    mainPanel(
      dataTableOutput("rcheology_DT")
    )
  )
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

