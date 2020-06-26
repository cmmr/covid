
function (input, output, session) {
  
  
  
  # Data on covid test results, including zip code
  if (interactive() && file.exists("results.rds")) {
    
    md <- readRDS("results.rds")
    
  } else {
    
    source("aws_credentials.r") # Defines AWS_KEY and AWS_SECRET
    
    md <- aws.s3::s3readRDS(
      object = "projects/covid/test_results.rds",
      bucket = "jplab",
      region = "us-east-1",
      key    = AWS_KEY,
      secret = AWS_SECRET,
    ) %>%
      as_tibble() %>%
      filter(!is.na(`zipcode`)) %>%
      filter(`result` %in% c("Not detected", "Positive"))
    
    if (0 && interactive())
      saveRDS(md, "results.rds")
  }
  
  
  # Expected format of data:
  #----------------------------------------------------------------------------------------------------
  # > glimpse(md)
  # Rows: 6,507
  # Columns: 12
  # $ sex                        <dbl> 2, 2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1...
  # $ age                        <dbl> 68.00, 48.00, 37.00, 48.00, 45.00, 78.00, 12.00, 27.00, 80.00...
  # $ zipcode                    <dbl> 77073, 77082, 77536, 77090, 77346, 77034, 77406, 77449, 77504...
  # $ has_traveled               <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2...
  # $ has_close_contact          <dbl> 3, 3, 2, 2, 1, 1, 1, 1, 1, 1, 3, 3, 2, 2, 2, 2, 1, 1, 1, 2, 3...
  # $ has_any_symptoms           <dbl> 2, 2, 1, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1, 2, 2, 2, 1, 2, 1, 1, 1...
  # $ has_any_further_symptoms   <dbl> NA, NA, 2, NA, 1, 2, NA, NA, 2, 1, NA, NA, 1, NA, NA, NA, 1, ...
  # $ has_symptoms_throat        <dbl> 2, 2, 2, 2, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2, 1, 2, 1, 1, 1, 1, 1...
  # $ has_preexisting_conditions <dbl> 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1...
  # $ collection_datetime        <dttm> 2020-05-07 10:28:00, 2020-05-21 14:42:00, 2020-06-12 13:35:0...
  # $ research_specimen_id       <chr> "HI6FHHF9", "DWBB8NVI", "AF676CAZ", "51QMT2YO", "ZJDSGGSA", "...
  # $ result                     <chr> "Not detected", "Not detected", "Not detected", "Not detected...
  #----------------------------------------------------------------------------------------------------
  
  
  
  # Population per zip code (2016)
  # Source: https://data.world/lukewhyte/us-population-by-zip-code-2010-2016
  POPULATION <- readRDS("data/population.rds")
  
  
  
  # Recode numbers into human readable values
  md[['zipcode']]    <- as.character(md[['zipcode']])
  md[['sex']]        <- factor(md[['sex']], levels=1:3, labels=c("Male","Female","Other"))
  for (i in grep("has_", names(md)))
    md[[i]] <- factor(md[[i]], levels=1:3, labels=c("Yes","No","Not Sure"))
  remove("i")
  
  
  # Get all the zip codes in tested counties
  zipdetails   <- read_csv("data/zipcodes.csv", col_types = "ccc")
  zip2city     <- setNames(zipdetails$City,   zipdetails$Zip)
  zip2county   <- setNames(zipdetails$County, zipdetails$Zip)
  tested_zips  <- unique(md[['zipcode']])
  include_zips <- with(zipdetails, which(
    Zip    %in% tested_zips | 
      City   %in% unique(zip2city[tested_zips]) | 
      County %in% unique(zip2county[tested_zips])))
  include_zips <- zipdetails[['Zip']][include_zips]
  
  
  # SpatialPolygonsDataFrame for above zip codes
  if (!all(file.exists(paste0("data/gis-", c("zip", "city", "county"), ".rds")))) {
    
    # Download a Zip Code Tabulation Area (ZCTA) shapefile
    zip_prefixes <- include_zips %>% substr(1,3) %>% unique()
    gis <- tigris::zctas(cb = TRUE, starts_with = zip_prefixes)
    
    # Merge polygons based on city or county limits
    gisZip    <- unionSpatialPolygons(gis, as.character(gis$ZCTA5CE10))
    gisCity   <- unionSpatialPolygons(gis, zip2city[as.character(gis$ZCTA5CE10)])
    gisCounty <- unionSpatialPolygons(gis, zip2county[as.character(gis$ZCTA5CE10)])
    
    saveRDS(gisZip,    "data/gis-zip.rds")
    saveRDS(gisCity,   "data/gis-city.rds")
    saveRDS(gisCounty, "data/gis-county.rds")
    
  }
  
  GIS <- list(
    'Zip Code' = readRDS("data/gis-zip.rds"),
    'City'     = readRDS("data/gis-city.rds"),
    'County'   = readRDS("data/gis-county.rds")
  )
  
  
  
  md[['Zip Code']]   <- md[['zipcode']]
  md[['City']]       <- zip2city[md[['zipcode']]]
  md[['County']]     <- zip2county[md[['zipcode']]]
  md[['Date']]       <- as.Date(md[['collection_datetime']])
  
  DATA <- md
  
  
  
  
  source(local = TRUE, "pages/Overview.svr.r")
  source(local = TRUE, "pages/GeoMap.svr.r")
  source(local = TRUE, "pages/Testing.svr.r")
  source(local = TRUE, "pages/SymRisks.svr.r")
  
  
  
  #########################################################
  # Render the date range selector, using min/max dates
  #########################################################
  
  output[['dateRange.UI']] <- renderUI({
    dateRangeInput(
      inputId = "dateRange", 
      label = "Date Range", 
      format = "MM d",
      start = min(DATA[['Date']]), 
      min   = min(DATA[['Date']]), 
      end   = max(DATA[['Date']]), 
      max   = max(DATA[['Date']]) )
  })
  
  
  
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
