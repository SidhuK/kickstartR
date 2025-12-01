# UI Definition for {{PROJECT_NAME}}
# Created: {{DATE}}

ui <- fluidPage(
  # Application title
  titlePanel("{{PROJECT_NAME}}"),

  # Custom CSS
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css")
  ),

  sidebarLayout(
    sidebarPanel(
      # Input controls go here
      h4("Controls"),
      sliderInput("n",
                  "Number of observations:",
                  min = 10,
                  max = 500,
                  value = 100)
    ),

    mainPanel(
      # Output displays go here
      h4("Output"),
      plotOutput("plot"),
      verbatimTextOutput("summary")
    )
  )
)
