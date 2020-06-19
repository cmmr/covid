
#########################################################
# Half Donut Charts showing % Yes/No/Not Sure
#########################################################

observeEvent(limited_data(), {
  
  df <- req(limited_data()) %>%
    filter(result == 'Positive')
  
  
  # Traveled Recently
  output[['symrisk_traveled']] <- renderHighchart({
    
    table(df[['has_traveled']]) %>%
      data.frame() %>%
      hchart("pie", plotBorderWidth = 0, innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
        hc_add_theme(thm)
  })
  
  
  # Close Contact
  output[['symrisk_close_contact']] <- renderHighchart({
    
    table(df[['has_close_contact']]) %>%
      data.frame() %>%
      hchart("pie", innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
  })
  
  
  # Pre-Existing Conditions
  output[['symrisk_preexisting_conditions']] <- renderHighchart({
    
    table(df[['has_preexisting_conditions']]) %>%
      data.frame() %>%
      hchart("pie", innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
  })
  
  
  # Any Symptoms
  output[['symrisk_any_symptoms']] <- renderHighchart({
    
    table(df[['has_any_symptoms']]) %>%
      data.frame() %>%
      hchart("pie", innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
  })
  
  
  # Further Symptoms
  output[['symrisk_any_further_symptoms']] <- renderHighchart({
    
    table(df[['has_any_further_symptoms']]) %>%
      data.frame() %>%
      hchart("pie", innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
  })
  
  
  # Throat Symptoms
  output[['symrisk_symptoms_throat']] <- renderHighchart({
    
    table(df[['has_symptoms_throat']]) %>%
      data.frame() %>%
      hchart("pie", innerSize = "50%", hcaes(x = Var1, y = Freq)) %>%
      hc_tooltip(pointFormat = '<b>{point.y}</b> ({point.percentage:.1f}%)') %>%
      hc_plotOptions(pie = list(
        startAngle = -90, endAngle = 90,
        dataLabels = list(distance = 10, style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
  })
  
  
  
  
})
