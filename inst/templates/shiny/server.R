# Server Logic for {{PROJECT_NAME}}
# Created: {{DATE}}

server <- function(input, output, session) {

  # Reactive data
  data <- reactive({
    rnorm(input$n)
  })

  # Render plot
  output$plot <- renderPlot({
    hist(data(),
         main = "Histogram of Random Data",
         xlab = "Value",
         col = "#3498db",
         border = "white")
  })

  # Render summary
  output$summary <- renderPrint({
    summary(data())
  })
}
