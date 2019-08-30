# Server logic to create the three tabs
shinyServer(function(input, output, session) {
  
  # 1) Scatter Plot
  output$plot <- renderPlot({
    
    data_x <- switch (input$x,
      "Age" = players$Age,
      "International Reputation" = players$`International Reputation`)
    
    data_y <- switch (input$y,
      "Overall" = players$Overall,
      "Potential" = players$Potential)
    
    p <- ggplot(players, 
                aes_string(x=data_x, y=data_y)) + geom_point() +
      ggtitle("Database Explorer") + xlab(input$x) + ylab(input$y)
    
    
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

  observe({
    updateSelectizeInput(session, inputId = "spider_plot_input1", 
                         choices = tail(spider_chart_data$Name,-2), server = TRUE)  
  })
  
  
  output$spider_plot <- renderPlot({

    data_spider <- req(input$spider_plot_input1)
    
    player1 <- as_tibble(filter(spider_chart_data, Name == data_spider[1])[1,])
    player2 <- as_tibble(filter(spider_chart_data, Name == data_spider[2])[1,])
    
    if (length(data_spider) == 0) {
      s <- plot(1, type="n", axes=F, xlab="", ylab="")
    }
    if (length(data_spider) == 1) {
      s <- radarchart(rbind(rep(100,7), rep(0,7), player1[2:8]), axistype=1 ,
                      #custom polygon
                      pcol=spider_colors_border[1] , pfcol=spider_colors_in[1], plwd=2,
                      pdensity=c(5), pangle = c(45),
                      #custom the grid
                      cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(40,100,10), cglwd=0.8,
                      #custom labels
                      vlcex=0.8
      )
      # Add a legend
      legend(x=1.0,y=1.2, legend = c(player1[1]), bty = "n",
             pch=20 , col=spider_colors_in , text.col = "black", cex=1.2, pt.cex=3)
    }
    else {
    s <- radarchart(rbind(rep(100,7), rep(0,7), player1[2:8], player2[2:8]), axistype=1 ,
                  #custom polygon
                  pcol=spider_colors_border , pfcol=spider_colors_in , plwd=2 , plty=1,
                  pdensity=c(5, 20), pangle = c(45,-45),
                  #custom the grid
                  cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(40,100,10), cglwd=0.8,
                  #custom labels
                  vlcex=0.8
      )
      # Add a legend
      legend(x=1.0,y=1.2, legend = c(player1[1], player2[1]), bty = "n",
             pch=20 , col=spider_colors_in , text.col = "black", cex=1.2, pt.cex=3)
    }

    s
  }) #End of the spider plot
  
  
  # 3 - world map interactive cloropleth
  output$world_map <- renderLeaflet({
    
    color_by <- switch (input$map_color,
      "Average Overall" = world_data@data$avg,
      "Number of players" = world_data@data$count
    )
    
    my_palette <- colorNumeric("OrRd", domain = color_by, na.color = "transparent")
    
    labels <- sprintf(
      "<strong>%s</strong><br/> Avg. Overall = %g<br/>  Num. Players: %g",
      world_data@data$NAME, world_data@data$avg, world_data@data$count) %>% 
      lapply(htmltools::HTML)
    
    m <- leaflet(world_data) %>% 
      addTiles() %>% 
      addPolygons(
        fillColor = ~my_palette(color_by),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")) %>% 
      addLegend(pal = my_palette, values = color_by, opacity = 0.7, title = input$map_color,
                position = "bottomleft")
    
    m
    
  })  # End of the world map
})
