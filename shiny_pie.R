
# install.packages("shiny")
# install.packages("ggplot2")
library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Purpose Breakdown Pie Chart"),
  
  numericInput("visualise", "Visualise results:", value = 25, min = 0),
  numericInput("communicate", "Communicate with stakeholders:", value = 25, min = 0),
  numericInput("compare", "Compare scenarios:", value = 25, min = 0),
  numericInput("other", "Other:", value = 25, min = 0),
  
  plotOutput("pieChart")
)

server <- function(input, output) {
  output$pieChart <- renderPlot({
    # Create a data frame from input values
    data <- data.frame(
      Purpose = c("Visualise results", "Communicate", "Compare scenarios", "Other"),
      Value = c(input$visualise, input$communicate, input$compare, input$other)
    )
    
    # Remove entries with 0 to avoid empty pie slices
    data <- data[data$Value > 0, ]
    
    # Compute proportions for the pie chart
    data$Fraction <- data$Value / sum(data$Value)
    data$Label <- paste0(data$Purpose, " (", round(data$Fraction * 100), "%)")
    
    ggplot(data, aes(x = "", y = Value, fill = Purpose)) +
      geom_col(width = 1, color = "white") +
      coord_polar(theta = "y") +
      theme_void() +
      labs(title = "Distribution of Purpose") +
      theme(legend.title = element_blank()) +
      scale_fill_brewer(palette = "Set3")
  })
}

shinyApp(ui = ui, server = server)