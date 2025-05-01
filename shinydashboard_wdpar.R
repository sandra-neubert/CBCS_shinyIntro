# CBCS Coding Club: Introduction to R Shiny
# Sandra Neubert
# 02/05/2025

library(shiny)
library(shinydashboard)
library(wdpar)
library(leaflet)
library(dplyr)

# Load the protected areas data

# Define countries
country_dat <- c("New Zealand", "Fiji")

## download data for each country
mult_data <- lapply(country_dat, wdpa_fetch, wait = TRUE)

Category = c("Ia", "Ib", "II", "III", "IV", "V", "VI")

## merge datasets
mult_data <- st_as_sf(as_tibble(bind_rows(mult_data))) %>%
  dplyr::filter(.data$IUCN_CAT %in% Category)  # filter category


# UI 
ui <- dashboardPage(
  dashboardHeader(title = "Protected Areas"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      radioButtons("type", "Select PA Type:",
                   choices = c("Marine", "Terrestrial"),
                   selected = "Marine")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(
                box(title = "Protected Areas Map", width = 12,
                    leafletOutput("map", height = 500))
              )
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  # Reactive function to filter data based on country and PA type
  filtered_data <- reactive({
    country_data <- mult_data
    
    if (input$type == "Marine") {
      country_data <- country_data %>% dplyr::filter(.data$MARINE == 2)
    } else {
      country_data <- country_data %>% dplyr::filter(.data$MARINE == 0)
    }
    
    return(country_data)
  })
  
  # Render the map
  output$map <- renderLeaflet({
    data <- filtered_data() %>%
      rename(geometry = SHAPE) %>%
      mutate(IUCN_CAT = as.factor(IUCN_CAT)) %>%
      st_as_sf() %>%
      dplyr::filter(sf::st_is(., c("POLYGON", "MULTIPOLYGON")))
    
    pal <- colorFactor("YlOrRd", domain = data$IUCN_CAT)
    
    leaflet(data) %>%
      addTiles() %>%
      addPolygons(
        layerId = ~WDPAID,  # Important: store ID for clicking
        fillColor = ~pal(IUCN_CAT),
        fillOpacity = 0.7,
        color = "white", weight = 1,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "blue",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend("bottomright", pal = pal, values = data$IUCN_CAT,
                title = "IUCN Category",
                opacity = 1)
  })
  
  # React to map clicks and show popup
  observeEvent(input$map_shape_click, {
    click <- input$map_shape_click
    if (!is.null(click)) {
      data <- filtered_data() %>%
        rename(geometry = SHAPE) %>%
        mutate(IUCN_CAT = as.factor(IUCN_CAT)) %>%
        st_as_sf() %>%
        dplyr::filter(sf::st_is(., c("POLYGON", "MULTIPOLYGON")))
      
      click_point <- st_sfc(st_point(c(click$lng, click$lat)), crs = st_crs(data))
      
      idx <- which(st_intersects(click_point, data, sparse = FALSE))
      
      if (length(idx) > 0) {
        clicked_poly <- data[idx[1], ]
        
        # Build popup text
        popup_content <- paste0(
          "<strong>Name: </strong>", clicked_poly$NAME, "<br>",
          "<strong>Year: </strong>", clicked_poly$STATUS_YR
        )
        
        leafletProxy("map") %>%
          addPopups(
            lng = click$lng,
            lat = click$lat,
            popup = popup_content,
            layerId = "popup"
          )
        
      }
    }
  })
}

# Run the app
shinyApp(ui, server)