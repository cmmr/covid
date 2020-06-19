Overview.Panel <- tabPanel(
  title = " Overview", 
  icon  = icon("images"),
  value = "tab_overview",
  
  fluidRow(
    
    column(8, leafletOutput("overview_map", height = 400)),
    
    column(4,
      fluidRow(column(12, highchartOutput("overview_cumulative", height = "400px")))
    )
  ),
  
  fluidRow(
      box(width=12,
          highchartOutput("overview_risks", height = "200px") ))

)