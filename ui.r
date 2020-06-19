
source(local = TRUE, "pages/Overview.ui.r")
source(local = TRUE, "pages/GeoMap.ui.r")
source(local = TRUE, "pages/Testing.ui.r")
source(local = TRUE, "pages/SymRisks.ui.r")

navbarPage(
    id = "navmenu",
    title       = div(style = "position: relative; top: -5px;", tags$a(img(src="CMMR.png", height=40), href= "https://www.bcm.edu/research/labs-and-centers/research-centers/alkek-center-for-metagenomics-and-microbiome-research")),
    windowTitle = "Covid Dashboard",
    theme       = shinythemes::shinytheme("slate"),
    collapsible = TRUE,
    selected    = "tab_overview",
    
    Overview.Panel,
    GeoMap.Panel,
    Testing.Panel,
    SymRisks.Panel,
    
    header = wellPanel(textOutput('HeaderText.UI')),
    
    footer = wellPanel(
        fluidRow(
            column(4, radioButtons(
                inputId = "rollup", 
                label   = "Summarize By", 
                inline  = TRUE,
                choices = c("Zip Code", "City", "County") )),
            
            column(2, selectInput(
                inputId = "region", 
                label = "Loading...", 
                choices = "Loading..." )),
            
            column(2, NULL),
                
            column(4, dateRangeInput(
                    inputId = "dateRange", 
                    label = "Date Range", 
                    format = "MM d",
                    start = min(DATA[['Date']]), 
                    min   = min(DATA[['Date']]), 
                    end   = max(DATA[['Date']]), 
                    max   = max(DATA[['Date']]) ))
        )
    )
)
