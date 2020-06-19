Testing.Panel <- tabPanel(
  title = " Testing Effort", 
  icon  = icon("chart-line"),
  value = "tab_testing",
    
    # shinydashboard::valueBoxOutput("nCases", width = 2),
    # shinydashboard::valueBoxOutput("nTests", width = 3),
  
  fluidRow(
    column(6, highchartOutput("testing_daywise")), 
    column(6, highchartOutput("testing_cumulative")) )
  
  #dygraphOutput("testing")
)