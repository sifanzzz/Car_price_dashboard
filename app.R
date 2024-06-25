library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)


car_data <- read.csv("data/preprocessed/preprocessed_car_data.csv") 

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Australia Car Price", titleWidth = 300),
  dashboardSidebar(
    selectInput("brand", "Brand", choices = c("", unique(car_data$Brand)), multiple = TRUE),
    selectInput("usedOrNew", "New or Used", choices = c("", unique(car_data$UsedOrNew))),
    selectInput("transmission", "Transmission", choices = c("", unique(car_data$Transmission))),
    selectInput("driveType", "Drive Type", choices = c("", unique(car_data$DriveType))),
    selectInput("fuelType", "Fuel Type", choices = c("", unique(car_data$FuelType))),
    selectInput("bodyType", "Body Type", choices = c("", unique(car_data$BodyType))),
    selectInput("doors", "Doors", choices = c("", unique(car_data$Doors))),
    selectInput("seats", "Seats", choices = c("", unique(car_data$Seats))),
    selectInput("engineCyl", "Engine Cylinder Number", choices = c("", unique(car_data$Engine_cylinder_number))),
    selectInput("ExteriorColour", "Exterior Colour", choices = c("", unique(car_data$ExteriorColour)))
  ),
  dashboardBody(
    # Each plot in its own fluidRow for vertical layout
    fluidRow(
      box(plotlyOutput("pricePlot", height = 400), width = 12)  
    ),
    fluidRow(
      box(plotlyOutput("average_price_plot", height = 400), width = 12)  
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Reactive expression to filter data based on inputs
  filteredData <- reactive({
    car_data %>%
      filter(
        (Brand %in% input$brand) | (input$brand[1] == ""),
        (UsedOrNew %in% input$usedOrNew) | (input$usedOrNew[1] == ""),
        (Transmission %in% input$transmission) | (input$transmission[1] == ""),
        (DriveType %in% input$driveType) | (input$driveType[1] == ""),
        (FuelType %in% input$fuelType) | (input$fuelType[1] == ""),
        (BodyType %in% input$bodyType) | (input$bodyType[1] == ""),
        (Doors %in% input$doors) | (input$doors[1] == ""),
        (Seats %in% input$seats) | (input$seats[1] == ""),
        (Engine_cylinder_number %in% input$engineCyl) | (input$engineCyl[1] == ""),
        (ExteriorColour %in% input$ExteriorColour) | (input$ExteriorColour[1] == "")
      )
  })

  
  # Output for Price Plot
  output$pricePlot <- renderPlotly({
    if (nrow(filteredData()) == 0) {
      return(ggplot() + 
               theme_void() + 
               ggtitle("No data available for selected filters"))
    } else {
      p <- ggplot(filteredData(), aes(x = factor(Year), y = Price, fill = Brand)) +
        geom_bar(stat = "identity", position = "dodge") +
        scale_y_continuous(labels = scales::comma) +
        scale_x_discrete() +  
        theme_minimal() +
        theme(panel.background = element_rect(fill = "white"), 
              legend.position = "top",  
              legend.direction = "horizontal",
              plot.title = element_text(size = 16, face = "bold"),  
              axis.title = element_text(size = 12),  
              axis.text = element_text(size = 10),    
              axis.title.x = element_text(size = 12),
              axis.title.y = element_text(size = 12) ) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(title = "Price Over Years for Selected Brands", x = "Year", y = "Price")
      ggplotly(p, tooltip = c("x", "y", "fill")) 
    }
  })
  
  
  # Output for Color vs Price Plot using a bar chart
  output$average_price_plot <- renderPlotly({
    if (nrow(filteredData()) == 0) {
      return(ggplot() + 
               theme_void() + 
               ggtitle("No data available for selected filters"))
    } else {
    q <- ggplot(filteredData(), aes(x = ExteriorColour)) + 
      stat_summary(geom = "bar", fun = "mean", aes(y = Price)) +
      theme_minimal() +
      theme(panel.background = element_rect(fill = "white"), 
              legend.position = "top", 
              legend.direction = "horizontal",
              plot.title = element_text(size = 16, face = "bold"),  
              axis.title = element_text(size = 12),  
              axis.text = element_text(size = 10),    
              axis.title.x = element_text(size = 12),
              axis.title.y = element_text(size = 12),
              plot.background = element_rect(color = "transparent")
            ) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(title = "Average Price by Car Colour", x = "Exterior Colour", y = "Average Price") +
        guides(fill = FALSE)
    ggplotly(q, tooltip = c("x", "y", "fill")) %>%
      layout(width =1300,
             legend = list(x = 1.1, y = 0.5, orientation = "v"),
             margin = list(l = 50, r = 200, b = 50, t = 50, pad = 4))
    
    }
  })
}

# Run the application 
shinyApp(ui, server)
