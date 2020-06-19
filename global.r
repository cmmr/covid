# In this script include packages, functions, datasets and anyting that will be 
# used both by UI and server

############################.
## Packages ----
############################.

library(aws.s3) # s3readRDS
library(dashboardthemes)
library(highcharter)
library(leaflet)
library(mapproj)
library(maptools) # unionSpatialPolygons
library(rgdal) # readOGR
library(rgeos)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(sp)
library(tidyverse)
library(tigris)




# Themes:
# https://rstudio.github.io/shinythemes/
# http://jkunst.com/highcharter/themes.html


thm <- hc_theme_merge(
  hc_theme_flatdark(),
  hc_theme(
    chart = list(
      backgroundColor = "transparent"
    )
  )
)



# Use a comma as the thousands separator in highcharts
hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)


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
  
  if (interactive())
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

details <- list(
  sex                        = "Sex",
  age                        = "Current age",
  zipcode                    = "Zip Code",
  has_traveled               = "Has the participant/patient recently traveled to an area with a known local spread of COVID-19?",
  has_close_contact          = "Has the participant/patient come into close contact (within 6 feet) with someone who has a laboratory confirmed COVID-19 diagnosis in the past 14 days?",
  has_any_symptoms           = "Does the participant/patient have symptoms that include a fever (greater than 100.4 F), cough, shortness of breath, fatigue and/or difficulty breathing?",
  has_any_further_symptoms   = "Has the participant/patient experienced any gastrointestinal symptoms such as diarrhea and nausea prior to developing fever and lower respiratory tract signs and symptoms?",
  has_symptoms_throat        = "Does the participant/patient have symptoms that include a sore throat, headache, cough with sputum production and/or blood-stained mucus?",
  has_preexisting_conditions = "Does the participant/patient have any pre-existing conditions such as heart disease, diabetes, chronic respiratory disease, hypertension, and cancer?",
  research_specimen_id       = "Research Specimen ID",
  result                     = "Result",
  collection_datetime        = "Collection Date & Time"
)


# Get all the zip codes in tested counties
zipdetails   <- read_csv("zipcodes.csv", col_types = "ccc")
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

remove(list = setdiff(ls(), c("DATA", "GIS", "POPULATION", "details", "thm")))
