# CBCS Coding Club: Introduction to R Shiny
# Sandra Neubert
# 02/05/2025

#install.packages("shiny")
library(shiny)

# General structure of a shiny app:
# ui <- ...
# 
# server <- ...
# 
# shinyApp(ui = ui, server = server)


# define the user interface object with the appearance of the app
ui <- fluidPage(
  numericInput(inputId = "n", label = "Sample size", value = 25),
  plotOutput(outputId = "hist")
  # titlePanel("Example of sidebar layout"),
  # 
  # sidebarLayout(
  #   sidebarPanel(
  #     numericInput(
  #       inputId = "n", label = "Sample size",
  #       value = 25
  #     )
  #   ),
  #   
  #   mainPanel(
  #     plotOutput(outputId = "hist")
  #   )
  # )
)

# define the server function with instructions to build the
# objects displayed in the ui
server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$n))
  })
}

# call shinyApp() which returns the Shiny app object
shinyApp(ui = ui, server = server)

