
observeEvent(limited_data(), {
  
  df <- req(limited_data())
  
  
  #########################################################
  # One Stacked Bar per day
  #########################################################
  
  output[['testing_daywise']] <- renderHighchart({
    
    dates <- seq(min(df[['Date']]), max(df[['Date']]), by = 1)
    data  <- data.frame(
      'Date'   = c(dates, dates),
      'Metric' = c(rep('Positive Cases', length(dates)), rep('Not detected', length(dates))),
      'Value' = c(
        sapply(dates, function (d) { sum(df[['Date']] == d & df[['result']] == "Positive")}),
        sapply(dates, function (d) { sum(df[['Date']] == d & df[['result']] == "Not detected")})
      )
    )
    
    hchart(data, "column", stacking = "normal", hcaes(x = Date, y = Value, group = Metric)) %>%
      hc_title(text = "Testing Effort Per Day") %>%
      hc_yAxis(title = list(text = "Totals (log scale)"), type = "logarithmic") %>%
      hc_add_theme(thm)
    
  })
  
  
  
  #########################################################
  # Line chart of cumulative cases and tests over time
  #########################################################
  
  output[['testing_cumulative']] <- renderHighchart({
    
    dates <- seq(min(df[['Date']]), max(df[['Date']]), by = 1)
    data  <- data.frame(
      'Date'   = c(dates, dates),
      'Metric' = c(rep('Positive Cases', length(dates)), rep('Not detected', length(dates))),
      'Value' = c(
        sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Positive")}),
        sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Not detected")})
      )
    )
    
    hchart(data, "line", hcaes(x = Date, y = Value, group = Metric)) %>%
      hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>%
      hc_title(text = "Cumulative Tests Over Time") %>%
      hc_yAxis(title = list(text = "Totals (log scale)"), type = "logarithmic") %>%
      hc_add_theme(thm)
    
  })
  
})




  #------------------------------------------------------
  # Update valueboxes
  #------------------------------------------------------
# output[['nCases']] <- shinydashboard::renderValueBox({
#   shinydashboard::valueBox(sum(df[['result']] == "Positive"), "Positive", icon('diagnoses')) })
# output[['nTests']] <- shinydashboard::renderValueBox({
#   shinydashboard::valueBox(nrow(df), "Tested", icon('stethoscope')) })



# output$testing <- renderDygraph({
#   
#   df <- req(limited_data())
#   
#   dates <- seq(min(df[['Date']]), max(df[['Date']]), by = 1)
#   data  <- xts::xts(
#     order.by = dates,
#     x = matrix(
#       ncol=2,
#       dimnames = list(dates, c('Positive', 'Negative')),
#       data = c(
#         sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Positive")}),
#         sapply(dates, function (d) { sum(df[['Date']] <= d & df[['result']] == "Not detected")})
#       )
#     )
#   )
#   
#   #------------------------------------------------------
#   # Update valueboxes
#   #------------------------------------------------------
#   
#   output[['nCases']] <- shinydashboard::renderValueBox({
#     shinydashboard::valueBox(sum(df[['result']] == "Positive"), "Positive", icon('diagnoses')) })
#   output[['nTests']] <- shinydashboard::renderValueBox({
#     shinydashboard::valueBox(nrow(df), "Tested", icon('stethoscope')) })
#   
#   dygraph(data, main = "Cumulative Total", ylab = "Number of People Tested") %>%
#     dySeries("Negative") %>%
#     dySeries("Positive") %>%
#     dyOptions(stackedGraph = TRUE, logscale = TRUE) %>%
#     dyRangeSelector(height = 40) %>%
#     dyLegend(show = "follow")
#   
# })
