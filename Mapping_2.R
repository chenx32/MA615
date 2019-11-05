library(leaflet)
library(maps)
library(htmlwidgets)

# The data to map.
library <- read.csv("~/Desktop/MA615/Assignments/Mapping/Mapping_2/Public_Libraries.csv")
# State boundaries from the maps package. The fill option must be TRUE.
bounds <- map('state', c('Massachusetts'), fill=TRUE, plot=FALSE)

# A custom icon.
icons <- awesomeIcons(
  icon = 'disc',
  iconColor = 'black',
  library = 'ion', # Options are 'glyphicon', 'fa', 'ion'.
  markerColor = 'blue',
  squareMarker = TRUE
)
# Create the Leaflet map widget and add some map layers.
# We use the pipe operator %>% to streamline the adding of
# layers to the leaflet object. The pipe operator comes from 
# the magrittr package via the dplyr package.
map <- leaflet(data = library) %>%
  # setView(-72.14600, 43.82977, zoom = 8) %>% 
  addProviderTiles("CartoDB.Positron", group = "Map") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite")%>% 
  addProviderTiles("Esri.WorldShadedRelief", group = "Relief")%>%
  addMarkers(~X, ~Y, label = ~BRANCH, group = "Libraries") %>% 
  # addAwesomeMarkers(~lon_dd, ~lat_dd, label = ~locality, group = "Sites", icon=icons) %>%
  addPolygons(data=bounds, group="States", weight=2, fillOpacity = 0) %>%
  addScaleBar(position = "bottomleft") %>%
  addLayersControl(
    baseGroups = c("Map", "Satellite", "Relief"),
    overlayGroups = c("Libraries", "States"),
    options = layersControlOptions(collapsed = FALSE)
  )
invisible(print(map))

# Save the interactive map to an HTML page.
saveWidget(map, file="sitesmap2.html", selfcontained=TRUE)
# Uncomment the following line to save the interactive map to a static image file.
# mapshot(map, file="sitesmap2.png")




