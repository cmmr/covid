

observeEvent(limited_data(), {
  
  df <- req(limited_data())
  
  # Line chart of cumulative cases and tests over time
  output[['overview_cumulative']] <- renderHighchart({
    
    dates <- seq(min(df[['Date']]), max(df[['Date']]), by = 1)
    data  <- data.frame(
      'Date'   = c(dates, dates),
      'Metric' = c(rep('Positive', length(dates)), rep('Not detected', length(dates))),
      'Value' = c(
        sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Positive")}),
        sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Not detected")})
      )
    )
    
    hchart(data, "line", hcaes(x = Date, y = Value, group = Metric)) %>%
      hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>%
      hc_legend(title = list(text = "SARS-CoV-2 Test Result", style = list(color = "white")), reversed=TRUE) %>%
      #hc_title(text = "Cumulative Tests Over Time") %>%
      hc_xAxis(title = list(text = "")) %>%
      hc_yAxis(title = list(text = "Cumulative Total (log scale)"), type = "logarithmic") %>%
      hc_add_theme(thm)
    
  })
  
  
  # Traveled Recently
  output[['overview_risks']] <- renderHighchart({
    
    risks <- df %>%
      group_by(`result`) %>%
      summarise(.groups='drop',
        'Close Contact with Covid' = sum(`has_close_contact`          == "Yes", na.rm = TRUE) / n(),
        'Pre-Existing Conditions'  = sum(`has_preexisting_conditions` == "Yes", na.rm = TRUE) / n(),
        'Traveled to Covid Area'   = sum(`has_traveled`               == "Yes", na.rm = TRUE) / n(),
        'Throat Symptoms'          = sum(`has_symptoms_throat`        == "Yes", na.rm = TRUE) / n(),
        'Respiratory Symptoms'     = sum(`has_any_symptoms`           == "Yes", na.rm = TRUE) / n(),
        'Diarrhea or Nausea'       = sum(`has_any_further_symptoms`   == "Yes", na.rm = TRUE) / n() ) %>%
      pivot_longer(cols = 2:7) %>%
      transmute(
        `Result`      = ifelse(`result` == 'Positive', 'Positive for SARS-CoV-2', 'Negative for SARS-CoV-2'),
        `Risk Factor` = `name`, 
        `Pct`         = round(`value` * 100, 1))
    
    risks %>%
      hchart("column", plotBorderWidth = 0, hcaes(x = `Risk Factor`, y = Pct, group=Result)) %>%
      #hc_legend(align = "right", verticalAlign = "top", layout="vertical", floating = TRUE) %>%
      hc_legend(enabled = FALSE) %>%
      hc_xAxis(title = list(text = "")) %>%
      hc_yAxis(title = list(text = ""), labels = list(format = "{value}%")) %>%
      hc_tooltip(pointFormat = '<b>{point.y:.1f}%</b> of those who tested <b>{series.name}</b> had <b>{point.name}</b><br/>') %>%
      hc_plotOptions(column = list(
        dataLabels = list(enabled = TRUE, format = "{point.y:.1f}%", style = list(color = "white"))) ) %>%
      hc_add_theme(thm)
    
  })
  
})