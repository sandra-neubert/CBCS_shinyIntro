# install.packages("shinydashboard")
# install.packages("ggplot2")
library(shiny)
library(shinydashboard)
library(ggplot2)

ui <- dashboardPage(
  dashboardHeader(title = "Purpose Breakdown"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inputs", tabName = "inputs", icon = icon("sliders-h")),
      
      numericInput("visualise", "Visualise results:", value = 25, min = 0),
      numericInput("communicate", "Communicate with stakeholders:", value = 25, min = 0),
      numericInput("compare", "Compare scenarios:", value = 25, min = 0),
      numericInput("other", "Other:", value = 25, min = 0)
    )
  ),
  
  dashboardBody(
    fluidRow(
      box(
        title = "Pie Chart of Purpose", 
        status = "primary", 
        solidHeader = TRUE,
        width = 12,
        plotOutput("pieChart", height = "400px")
      )
    )
  )
)

server <- function(input, output) {
  output$pieChart <- renderPlot({
    data <- data.frame(
      Purpose = c("Visualise results", "Communicate", "Compare scenarios", "Other"),
      Value = c(input$visualise, input$communicate, input$compare, input$other)
    )
    
    # Remove zero entries
    data <- data[data$Value > 0, ]
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

shinyApp(ui, server)