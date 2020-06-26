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



# Use a comma as the thousands separator in highcharts
hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)


