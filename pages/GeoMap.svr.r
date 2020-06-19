#########################################################
# Map of greater houston area colored by covid prevalence
#########################################################


#------------------------------------------------------
# React to user events in the sidebar controls
#------------------------------------------------------
mapdata <- reactive({
  
  df     <- req(limited_data())
  rollup <- req(input$rollup)
  
  
  #----------------------------------------------------
  # Read the current rollup selection from the website
  #----------------------------------------------------
  
  req(rollup %in% c("Zip Code", "City", "County"))
  
  
  #----------------------------------------------------
  # Merged polygons based on city or county limits
  #----------------------------------------------------
  sp <- GIS[[rollup]]
  
  
  #----------------------------------------------------
  # Summarize per geographical region
  #----------------------------------------------------
  
  df[['Region']] <- df[[rollup]]
  df <- df %>%
    filter(!is.na(Region)) %>%
    group_by(Region) %>%
    summarise(
      n_tested   = n(),
      positive   = sum(result == 'Positive', na.rm = TRUE),
      pct_pos    = positive * 100 / n_tested,
      population = sum(POPULATION[unique(zipcode)], na.rm = TRUE),
      pct_pop    = positive * 10000 / population
    ) %>%
    ungroup()
  df <- data.frame(df, row.names = df[['Region']])
  
  
  #----------------------------------------------------
  # Ignore regions without any test result data
  #----------------------------------------------------
  
  sp <- sp[intersect(rownames(df), names(sp))]
  df <- df[names(sp),,F]
  
  
  #----------------------------------------------------
  # Create the pop-up labels
  #----------------------------------------------------
  
  labels <- c(
    "<strong>%s</strong><br/>",
    "%s %s tested (out of %s)<br/>",
    "%s positive for SARS-CoV-2<br/>",
    "%.1f cases per 10,000 people<br/>" ) %>%
    paste(collapse="") %>%
    sprintf(
      names(sp),
      formatC(df[['n_tested']], format="d", big.mark=","),
      ifelse(df[['n_tested']] == 1, "person", "people"),
      formatC(df[['population']], format="d", big.mark=","),
      formatC(df[['positive']], format="d", big.mark=","),
      df[['pct_pop']] ) %>%
    lapply(htmltools::HTML)
  
  
  #----------------------------------------------------
  # Assign colors to each geographic region
  #----------------------------------------------------
  
  vals <- df[['pct_pop']]
  colors <- colorBin(palette = "Reds", domain = vals)(vals)
  
  
  return (list(sp=sp, colors=colors, labels=labels))
  
})





output$geomap_map <- renderLeaflet({
  
  #------------------------------------------------------
  # Update the map
  #------------------------------------------------------
  
  observeEvent(mapdata(), {
    
    md <- req(mapdata())
    
    leafletProxy("geomap_map", data = md[['sp']]) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = md[['colors']],
        weight = .5,
        color = "grey",
        highlight = highlightOptions(
          weight = 3,
          color = "#666",
          bringToFront = TRUE ),
        label = md[['labels']],
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto" ))
  })
  
  
  #------------------------------------------------------
  # The initial map that is drawn without covid data
  #------------------------------------------------------
  
  leaflet() %>% 
    addProviderTiles(providers$CartoDB.Positron) %>% 
    setView(lat = 29.7604, lng = -95.3698, zoom = 9)
  
})



output$overview_map <- renderLeaflet({
  
  #------------------------------------------------------
  # Update the map
  #------------------------------------------------------
  
  observeEvent(mapdata(), {
    
    md <- req(mapdata())
    
    leafletProxy("overview_map", data = md[['sp']]) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = md[['colors']],
        weight = .5,
        color = "grey",
        highlight = highlightOptions(
          weight = 3,
          color = "#666",
          bringToFront = TRUE ),
        label = md[['labels']],
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto" ))
  })
  
  
  #------------------------------------------------------
  # The initial map that is drawn without covid data
  #------------------------------------------------------
  
  leaflet() %>% 
    addProviderTiles(providers$CartoDB.Positron) %>% 
    setView(lat = 29.7604, lng = -95.3698, zoom = 9)
  
})
