# Server logic to create the three tabs
shinyServer(function(input, output) {
  
  # 1) Scatter Plot
  output$plot <- renderPlot({
    
    data_x <- switch (input$x,
      "Age" = players$Age,
      "International Reputation" = players$`International Reputation`)
    
    data_y <- switch (input$y,
      "Overall" = players$Overall,
      "Potential" = players$Potential)
    
    p <- ggplot(players, 
                aes_string(x=data_x, y=data_y)) + geom_point() 
    
    
    # if (input$color != 'None')
    #   p <- p + aes_string(color=input$color)
    # 
    # facets <- paste(input$facet_row, "~ .")
    # if (facets != '. ~ .')
    #   p <- p + facet_grid(facets)
    # 
    # if (input$lm)
    #   p <- p + geom_smooth(method='lm',formula=y~x, na.rm = T)
    # if (input$smooth)
    #   p <- p + geom_smooth(method='loess',formula=y~x, na.rm = T)
    
    print(p)
  }) # End of the Scatter Plot
  
  
  # 2 - Spider plot comparison
  output$spider_plot <- renderPlot({
    
  }) #End of the spider plot
  
  
  # 3 - world map interactive cloropleth
  output$world_map <- renderLeaflet({
    
    map_data <- switch (input$map_color,
      "Average Overall" = nationality_overall$avg,
      "Average Value (M €)" = nationality_overall$avg_value
    )
    
    m <- leaflet(data =) %>% 
      addTiles() %>% 
      setView(lat=10, lng=0 , zoom=2) %>% 
      addPolygons(
        fillColor = mypalette(),
        stroke=TRUE,
        fillOpacity = 0.9,
        color = "white",
        label = paste(
          "Country", nationality_overall$Nationality, "<br>",
          "Average Overall", nationality_overall$avg, "<br>",
          "Number of players", nationality_overall$count) %>% 
          lapply(htmltools::HTML)) %>% 
      addLegend(pal = mypalette, 
                values = y, 
                opacity = 0.9, 
                title = x, 
                position = "bottomleft")
    
    m
  }) # End of the world map
  
})
