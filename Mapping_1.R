library(shiny)
library(ggmap)
library(maptools)
library(maps)

mapWorld <- map_data("world")

ui <- fluidPage(
    titlePanel("Mapping Assignment Problem1"),
    sidebarLayout(
        sidebarPanel(
    selectInput("Projectionid", "Projections", c("cylindrical", "mercator", "sinusoidal", "gnomonic"))
    ),
    mainPanel(plotOutput("maps")
              )
)
)

server <- function(input, output, session) {
    output$maps <- renderPlot({
        mp1<- ggplot(mapWorld, aes(x=long, y=lat, group=group))+
            geom_polygon(fill="white", color="black") +
            coord_map(xlim=c(-180,180), ylim=c(-60, 90))
        mp2 <- mp1 + coord_map(input$Projectionid,xlim=c(-180,180), ylim=c(-60, 90))
        mp2
    })
}

shinyApp(ui, server)