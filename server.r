
function (input, output, session) {
  
  
  source(local = TRUE, "pages/Overview.svr.r")
  source(local = TRUE, "pages/GeoMap.svr.r")
  source(local = TRUE, "pages/Testing.svr.r")
  source(local = TRUE, "pages/SymRisks.svr.r")
  
  
  #########################################################
  # Plug in dates and numbers into the header text
  #########################################################
  
  output[['HeaderText.UI']] <- renderText({
    dateRange <- strftime(range(DATA[['collection_datetime']]), "%B %d")
    nTests <- nrow(DATA)
    nCases <- sum(DATA[['result']] == 'Positive')
    sprintf(
      "Baylor College of Medicine has tested for %i individuals between %s 
      and %s for COVID-19. Of these, %i tests were positive for the SARS-CoV-2
      virus. As more tests are completed, this page will be updated with our
      progress and observed trends with demographic data.",
      nTests, dateRange[[1]], dateRange[[2]], nCases)
  })
  
  
  #########################################################
  # Subsetted dataset for this particular session.
  #########################################################
  
  limited_data <- reactive({
    
    dateRange <- req(input[['dateRange']])
    rollup    <- req(input[['rollup']])
    region    <- req(input[['region']])
    
    df <- DATA
    
    
    #----------------------------------------------------
    # Limit to just the selected region
    #----------------------------------------------------
    
    if (region %in% df[[rollup]])
      df <- filter(df, df[[rollup]] == region)
    
    
    #----------------------------------------------------
    # Exclude dates outside of given range
    #----------------------------------------------------
    
    req(all(sapply(dateRange, is, "Date")))
    req(identical(length(dateRange), 2L))
    
    df <- filter(df, Date >= dateRange[[1]], Date <= dateRange[[2]])
    
    
    #----------------------------------------------------
    # Tell user when they've selected zero data points
    #----------------------------------------------------
    
    if (nrow(df) == 0) {
      
      msg <- "There are no test results in the date range / %s you have selected. Reseting date range now."
      msg <- sprintf(msg, rollup)
      
      showModal(modalDialog(title = "No Data to Display", size  = "s", msg))
      
      updateDateRangeInput(session = session, inputId = 'dateRange', start = min(DATA[['Date']]), end = max(DATA[['Date']]))
      
      return (NULL)
    }
    
    return (df)
  })
  
  
  #########################################################
  # Present choices for 'Region' in the selectInput
  #########################################################
  observeEvent(input[['rollup']], {
    
    rollup <- req(input[['rollup']])
    
    choices <- sort(unique(DATA[[rollup]]))
    choices <- intersect(choices, names(GIS[[rollup]]))
    
    updateSelectInput(
      session = session, 
      inputId = 'region', 
      label   = input[['rollup']], 
      choices = c("(All)", choices) )
  })
  
  
  #########################################################
  # Useful shortcut for development
  #########################################################
  
  onSessionEnded(function (x) {
    if (interactive())
      stopApp()
  })
  
}
