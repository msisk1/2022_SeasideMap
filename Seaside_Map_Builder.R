if (FALSE){
  install.packages(sf)
  install.packages(tidyverse)
  install.packages(leaflet)
  install.packages(googlesheets4)
  install.packages(htmlwidgets)  
}


library(sf)
library(tidyverse)
library(leaflet)
library(googlesheets4)
library(htmlwidgets)


base.url <- "https://seaside-test.library.nd.edu/"

seaside.data <- read_sheet("https://docs.google.com/spreadsheets/d/1IHBm2UDZNQ91ilOquYVVOd2Ol7rs61uMKkkkpCKrnwc/edit#gid=333803365",
                           col_types = "ccccccccccccccddcccccccccc")

1



seaside.data <- seaside.data %>%
  mutate(popup = paste0("<b>", Structure_Name_1, "</b><br><hr>",
                        if_else(condition = is.na(Address),true = "", 
                                false = paste0("<b>Address: </b>", Address,"<br>")),
                        if_else(condition = is.na(Architect_1),true = "", 
                                false = paste0("<b>Architect: </b>", Architect_1,"<br>")),
                        "<a href=",base.url,SeasideTwo_ID," target=\"_parent\">More Info</a>"
                        )
         )


seaside.data<-seaside.data %>%
  filter(!is.na(lat)& !is.na(long))%>%
  st_as_sf(coords = c("long","lat")) %>% 
  st_set_crs(value = 4326) 


factpal <- colorFactor(palette = c("blue","green","yellow","orange") , levels = unique(seaside.data$`Building Type`))


seaside.map <- leaflet()%>%
  # addTiles(group = "OSM") %>%
  addProviderTiles(provider = providers$Esri.WorldTopoMap, group = "Streets")%>%
  addProviderTiles(provider = providers$Esri.WorldImagery, group = "Imagery")%>%
  # addProviderTiles(provider = providers$Stamen.TonerLite, group = "Toner Lite")%>%
  
  addCircleMarkers(data = seaside.data, color = NA, fillColor = ~factpal(`Building Type`), popup = ~popup, fillOpacity = 1, radius = 5)%>%
  addLayersControl(baseGroups = c("Streets", "Imagery"),
                   options = layersControlOptions(collapsed = FALSE))%>%
  addLegend(pal = factpal, values =unique(seaside.data$`Building Type`), position = "bottomleft")
seaside.map


saveWidget(seaside.map, file="Seaside-v2_3.html")


# st_write(seaside.data, "seasidePoints.geojson")
