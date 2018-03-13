#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

REBUILD <- TRUE

make_range <- function (versions) {
  lv <- length(all_versions)
  versions <- sort(as.package_version(unique(versions)))
  there <- all_versions %in% versions
  stop_start <- c(as.numeric(there[1]), diff(there))
  starts <- which(stop_start == 1)
  stops  <- which(stop_start == -1) - 1
  if (stop_start[lv] == 0 && there[lv]) stops <- c(stops, lv) 
  start_v <- all_versions[starts]
  stop_v  <- all_versions[stops]
  stop_v <- ifelse(start_v == stop_v, "", paste0("-", stop_v))
  ranges <- paste0(start_v, stop_v, sep = "", collapse = "; ")
  
  ranges
}

if (REBUILD) {
  library(rcheology)
  rch_summary <- rcheology %>% 
        group_by(name, package, args) %>% 
        summarize(versions = make_range(Rversion))
  save(rcheology, rch_summary, file = "rcheology-app-data.RData")
}
load("rcheology-app-data.RData")

all_versions <- sort(as.package_version(unique(rcheology$Rversion)))


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
   output$rcheology <- renderDataTable(rch_summary, 
        options = list(
          pageLength = 20,
          order      = c(0, "asc")
        ))
}

# Run the application 
shinyApp(ui = ui, server = server)

