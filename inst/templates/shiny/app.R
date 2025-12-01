# {{PROJECT_NAME}} - Shiny Application
# Created: {{DATE}}
# Author: {{AUTHOR}}

library(shiny)

source("R/ui.R")
source("R/server.R")

shinyApp(ui = ui, server = server)
