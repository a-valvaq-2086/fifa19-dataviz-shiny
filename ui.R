# UI application with tabs
shinyUI(
  navbarPage("Shiny App for FIFA19 DB Visualization",
             tabPanel("App Description",
                      mainPanel(
                        h1("\"Visualización Avanzada\" Coursework", align = "center"),
                        h2("Alejandro Valladares Vaquero", align = "center"),
                        p("This is a Shinny App for the final coursework of the module ", em("Advanced Visualization "),
                          "of the ", strong("Masters Desgree in Big Data - UNED")),
                        p("The data set is the complete DB of the", strong("FIFA19"), " game, which can be downloaded from:"),
                        a(href="https://www.kaggle.com/karangadiya/fifa19", "https://www.kaggle.com/karangadiya/fifa19"),
                        p(""),
                        p("The database comprises over ", strong("18,000 players"), " from all around the globe. Each player has more than
                          80 features."),
                        p("To simplify the dataset I have drop some columns that are not relevant for
                          the visualization (e.g. some features that the game uses for its internal game mechanics)."),
                        p(""),
                        p(""),
                        h2("Summary of the visualization app", align = "center"),
                        h3(""),
                        p("I divided the app in three tabs:"),
                        p(""),
                        p(strong("1)"), " The first one, represents an overall database ", strong("scatter plot"), " , where you can compare different features, and see if you
                        can get any insight of any relationship."),
                        p(""),
                        p(strong("2)"), " The second one is a ", strong("radar plot"), " comparison typical of this kind of games, where you can
                          can search for two players and compare them visually"),
                        p(""),
                        p(strong("3)"), " Is a Leaflet ", strong("interactive"), " choropleth world map coloured by ", strong("Average Overall"), " and ", strong("Number of Players"), " per country"))),
             
             tabPanel("Feature Explorer (Scatter Plot)",
                      sidebarPanel(
                        
                        selectInput('x', 'Choose the x-axis variable', 
                                    choices = c("Age",
                                                "International Reputation"),
                                    selected = "Age"),
                        
                        selectInput('y', 'Choose the y-axis variable',
                                    choices = c("Overall", "Potential"),
                                    selected = "Overall")
                        # selectInput('color', 'Color', c('None', 'Tipo')),
                        
                        # checkboxInput('lm', 'Línea de Regresión'),
                        # checkboxInput('smooth', 'Suavizado LOESS'),
                        
                        # selectInput('facet_row', 'Elige variable para facetas por filas', c(None='.', categoricas))
                      ),
                      
                      mainPanel(
                        plotOutput('plot',
                                   height=500)
                      )
             ),
             
             tabPanel("Player Comparison",
                      sidebarPanel(
                        
                        selectizeInput('spider_plot_input1', "Search for players to compare:", 
                                       choices = spider_chart_data$Name, multiple = TRUE,
                                       options = list(maxItems = 2),
                                       selected = "")
                      ),
                      
                      mainPanel(
                        plotOutput('spider_plot',
                                   height=500)
                      )
             ),
             
             tabPanel("World Map",
                      sidebarPanel(
                      
                        radioButtons('map_color', "Select the variable to color the map",
                                     choices = c("Average Overall", "Number of players"),
                                     selected = "Average Overall")
                      ),
                      
                      mainPanel(
                        leafletOutput('world_map',
                                      height=500)
                      )
             )
  )
)
