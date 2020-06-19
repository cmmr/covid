GeoMap.Panel <- tabPanel(
  title = " Map", 
  icon  = icon("globe-americas"),
  value = "tab_map",
    
  leafletOutput("geomap_map")
)