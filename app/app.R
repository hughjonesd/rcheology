#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

load("rcheology.RData")

ui <- fluidPage(
  titlePanel("Base R Functions from 3.0.1 to 3.4.3"),
  sidebarLayout(
    sidebarPanel("Created using the ", a(href="https://github.com/hughjonesd/rcheology", "rcheology"), " package."),
    mainPanel(
      dataTableOutput("rcheology")
    )
  )
)

server <- function(input, output) {
   output$rcheology <- renderDataTable(rcheology, 
        options = list(
          pageLength = 20,
          order      = c(0, "asc")
        ))
}

# Run the application 
shinyApp(ui = ui, server = server)

