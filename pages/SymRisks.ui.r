SymRisks.Panel <- tabPanel(
  title = " Symptoms & Risk Factors", 
  icon  = icon("thermometer-half"),
  value = "tab_symrisks",
  
  fluidRow(
    
    box(width=4, title="Traveled Recently",
        details[['has_traveled']],
        highchartOutput("symrisk_traveled", height = "200px") ),
    
    box(width=4, title="Close Contact",
        details[['has_close_contact']],
        highchartOutput("symrisk_close_contact", height = "200px") ),
    
    box(width=4, title="Pre-Existing Conditions",
        details[['has_preexisting_conditions']],
        highchartOutput("symrisk_preexisting_conditions", height = "200px") )),
  
  
  fluidRow(
    
    box(width=4, title="Any Symptoms",
        details[['has_any_symptoms']],
        highchartOutput("symrisk_any_symptoms", height = "200px") ),
    
    box(width=4, title="Further Symptoms",
        details[['has_any_further_symptoms']],
        highchartOutput("symrisk_any_further_symptoms", height = "200px") ),
    
    box(width=4, title="Throat Symptoms",
        details[['has_symptoms_throat']],
        highchartOutput("symrisk_symptoms_throat", height = "200px") ))

)