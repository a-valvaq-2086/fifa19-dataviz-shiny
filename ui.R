# The user interface logic

players <- readRDS("data/processed_players.rds")
nums <- sapply(players, is.numeric)
vars_continuous <- names(players)[nums]

# UI application with tabs
shinyUI(
  navbarPage("Shiny Visualización Avanzada",
             tabPanel("Descripción del trabajo",
                      mainPanel(
                        h1("Ejercicio Visualización Avanzada", align = "center"),
                        h2("Alejandro Valladares Vaquero", align = "center"),
                        p("This app is an evaluated coursework for the", em("Master en Big Data - UNED")),
                        p("The dataset is the FIFA 19 complete dataset that can be obtained from Kaggle:\n
                          https://www.kaggle.com/karangadiya/fifa19"),
                        p("The database contains over 18,000 players from all around the globe. With more than
                          80 features"),
                        p("The data has been lightly processed to account for categorical variables, transform
                          some features such as height, weight, wage and release clause"),
                        p(""),
                        p(""),
                        h2("¿Qué espero que incluyáis aquí?", align = "center"),
                        h3("Como mínimo"),
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
                        h5("2. La URL o dirección de shinyapps.io a la que se ha subido"),
                        h5("IMPORTANTE: Si usáis vuestros datos deben estar incluidos o accesibles en internet")
                        )),
             
             tabPanel("Scatterplot of Overall value",
                      sidebarPanel(
                        
                        selectInput('x', 'Elige variable para eje X', 
                                    choices = c("Age", "International Reputation"),
                                    selected = "Age"),
                        
                        selectInput('y', 'Elige variable para eje Y',
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
                        
                        selectizeInput('spider_plot', "Search for both players", 
                                       choices = players$Name, multiple = TRUE, 
                                       options = list(maxItems = 2), selected = NULL)
                      ),
                      
                      mainPanel(
                        plotOutput('spider_plot',
                                   height=500)
                      )
             ),
             
             tabPanel("World Map",
                      sidebarPanel(
                      
                        radioButtons('map_color', "Select the variable to color the map",
                                     choices = c("Overall", "Numberof players", "Value (millions EUR)"),
                                     selected = "Overall")
                      ),
                      
                      mainPanel(
                        leafletOutput('world_map',
                                   height=1000)
                      )
             )
  )
)
