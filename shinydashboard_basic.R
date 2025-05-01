#install.packages("shinydashboard")
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody()
)

## UI, server and App can also be split into ui.R, server.R and app.R files

server <- function(input, output) { }

shinyApp(ui, server)


