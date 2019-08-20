# UI application with tabs
shinyUI(
  navbarPage("Shiny Visualización Avanzada",
             tabPanel("Descripción del trabajo",
                      mainPanel(
                        h1("Ejercicio Visualización Avanzada", align = "center"),
                        h2("Alejandro Valladares Vaquero", align = "center"),
                        p("This app is an evaluated coursework for the module ", em("Visualización avanzada "),
                          em("Master en Big Data - UNED")),
                        p("The dataset is the FIFA 19 complete dataset that can be obtained from Kaggle:\n
                          https://www.kaggle.com/karangadiya/fifa19"),
                        p("The database contains over 18,000 players from all around the globe. With more than
                          80 features each one. To simplify the dataset I have drop some columns that are not relevant for
                          the visualization (e.g. some features that the game uses for its internal game mechanics)"),
                        p(""),
                        p(""),
                        h2("Summary of the visualization app", align = "center"),
                        h3(""),
                        p("The Shiny app is divided in three tabs. One is a player comparison, where you
                          can search two players from the complete DB, and compare its characteristics with
                          a spider plot"),
                        p("Secondly, you can find several plots, where you can see more info of the players skill set
                          some statistical representations of the data set and visualize the data"),
                        p("In the last tab you can find a World Map where you can plot different mean quantities,
                          such as Overal skill, Wages, Age depending on the League where the players Club, or their country
                          of origin"),
                        h3("Deseable pero no imprescindible"),
                        p("Algún gráfico adicional en pestaña Trabajo adicional"),
                        h2("¿Qué componentes se deben entregar?"),
                        h5("1. El código R (ui.R / server.R) -por separado o en un .zip"),
                        h5("2. La URL o dirección de shinyapps.io a la que se ha subido")
                        )),
             
             tabPanel("Scatterplot of Overall value",
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
                        
                        selectizeInput('spider_plot_input1', "Search players", 
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
