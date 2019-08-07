# LOADING REQUIRED PACKAGES
library(tidyverse)
library(magrittr)
library(gsubfn)
library(rgdal)
library(leaflet)
library(fmsb)
library(data.table)
setwd("D:/Mis Documentos/Master Big Data/4-5 Visualizacion avanzada/fifa19_dataviz/")

# CONSTANTS
FEET_TO_METERS = 3.84
INCHES_TO_CM = 2.54

# ====================== PLAYERS DATA PRE-PROCESSING ====================================================

# Data ingestion.
# The data-set contains more than 18,000 players of the FIFA19 database, with more than 80 features.
# In order to simplify the dataset I have skip some columns that the game uses for its internal mechanics
# (e.g. skill points dependeing on the player positions, and additional information that is not needed for
# the intended analysis, like Loaned From, or if the players models have photorealistic face or not).
players <- read_csv("data/data.csv", 
                    na = character(),
                    col_types = cols(
                      Club = col_character(),
                      Special = col_skip(),
                      `Preferred Foot` = col_factor(levels = NULL),
                      `Body Type` = col_skip(),
                      `Real Face` = col_skip(),
                      `Loaned From` = col_skip(),
                      LS = col_skip(),
                      ST = col_skip(),
                      RS = col_skip(),
                      LW = col_skip(),
                      LF = col_skip(),
                      CF = col_skip(),
                      RF = col_skip(),
                      RW = col_skip(),
                      LAM = col_skip(),
                      CAM = col_skip(),
                      RAM = col_skip(),
                      LM = col_skip(),
                      LCM = col_skip(),
                      CM = col_skip(),
                      RCM = col_skip(),
                      RM = col_skip(),
                      LWB = col_skip(),
                      LDM = col_skip(),
                      CDM = col_skip(),
                      RDM = col_skip(),
                      RWB = col_skip(),
                      LB = col_skip(),
                      LCB = col_skip(),
                      CB = col_skip(),
                      RCB = col_skip(),
                      RB = col_skip()
                    )
)

# Tras cargas los datos estrictamente necesarios (hay muchos campos, que tienen parámetros que el juego utiliza, pero no son
# útiles para nuestro análisis, como las bonificaciones que recibe un jugador en función de jugar en sus posiciones favoritas)

# Vamos a tener que realizar un pequeño preproceso en los campos de peso, salario y clausala de rescisión (para convertirlos a valores numéricos)
# Convertidos la cadena vacia "" a "Sin equipo".
players$Club <- players$Club %>%
  str_replace_all("^$", "Free agent")

players$`Preferred Foot` <- players$`Preferred Foot` %>% 
  replace_na("Right")
players$`Weak Foot` <- players$`Weak Foot` %>% 
  replace_na(1)
players$`International Reputation` <- players$`International Reputation` %>% 
  replace_na(1)

# Convert dates into only years
players$Joined <- players$Joined %>% 
  str_replace_all("^.*([0-9]{4}$)", "\\1")
unique(players$Joined)

players$`Contract Valid Until` <- 
  players$`Contract Valid Until` %>% 
  str_replace_all("^.*([0-9]{4}$)", "\\1")

# Preprocess heigth column
players <- players %>% 
  separate(Height, c("Height_ft", "Height_in"), sep = "'")
players <- players %>% 
  mutate("Height (cm)" = round(as.numeric(Height_ft) * FEET_TO_METERS + as.numeric(Height_in) * INCHES_TO_CM))
# Preprocess weight column
players <- rename(players, "Weight_lbs" = Weight)
players$Weight_lbs <- 
  players$Weight_lbs %>% 
  str_replace_all("lbs", "")
players$`Weight (kg)` <- round(as.numeric(players$Weight_lbs))


# Preprocessing of the Wage, Value and Release Clause columns
players$`Release Clause` <- 
  players$`Release Clause` %>%
  str_replace_all(c("€"="", "^$" = "0"))
players$`Release Clause (M€)` <- as.numeric(gsubfn('([a-zA-Z])', list(M='e+0', K='e-3'), players$`Release Clause`))

players$Value <- 
  players$Value %>% 
  str_replace_all(c("€" = "", "^$" = "0"))
players$`Value (M€)` <- as.numeric(gsubfn('([a-zA-Z])', list(M='e+0', K='e-3'), players$Value))

players$Wage <- 
  players$Wage %>% 
  str_replace_all(c("€" = "", "^$" = "0"))
players$`Wage (K€)` <-  as.numeric(gsub('([a-zA-Z])', 'e+0', players$Wage))

# Saving the players data.
saveRDS(players,file="data/processed_players.rds")

#==================== End Players Preprocessing  ===============================================================


# 2) Data pre-processing for the spider graph
spider_chart <- select(players, Name, Finishing, Dribbling, Acceleration, BallControl, Agility, LongPassing, SprintSpeed)
spider_chart <- rbind(rep(100,8), rep(0,8), spider_chart)

# Color vector
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9))
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4))

radarchart( spider_chart[c(1,2,4,17000),2:8]  , axistype=1 , 
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)
# Add a legend
legend(x=1.6, legend = c(spider_chart[4,1], spider_chart[17000,1]), bty = "n", pch=20 , col=colors_in , text.col = "black", cex=1.2, pt.cex=3)


# 3) Data preoprocessing for the map:
# download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip" , destfile="data/world_shape_file.zip")
# system("unzip DATA/world_shape_file.zip")
# world_spdf <- readOGR(
#   dsn= paste0(getwd(),"/data/world_shape_file/"), 
#   layer="TM_WORLD_BORDERS_SIMPL-0.3",
#   verbose=FALSE
# )
world_spdf <- readOGR("data/world_shape_file/TM_WORLD_BORDERS_SIMPL-0.3.shp")

# Summarise Overall average by Country of Origin
nationality_overall <- players %>% group_by(Nationality) %>% 
  summarise(avg = mean(Overall), avg_value = round(mean(`Value (M€)`), 1), count = n()) %>% 
  arrange(desc(avg))

# Now we standarize the names of the Fifa19 database and the world map shape
nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Bosnia.*", "Bosnia and Herzegovina")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Central African Re.*", "Central African Republic")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("China P.*", "China")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("DR Cong.*", "Democratic Republic of the Congo")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("FYR Mace.*", "The former Yugoslav Republic of Macedonia")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Guinea Biss.*", "Guinea-Bissau")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Iran.*", "Iran (Islamic Republic of)")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Rep.*Ireland.*", "Ireland")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Korea DPR.*", "Korea, Democratic People's Republic of")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Korea Republic", "Korea, Republic of")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Libya", "Libyan Arab Jamahiriya")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Moldova", "Republic of Moldova")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all(".*& Príncipe", "Sao Tome and Principe")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all(".*Sudan", "Sudan")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all(".*Kitts Nevis", "Saint Kitts and Nevis")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Syria", "Syrian Arab Republic")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Tanzania", "United Republic of Tanzania")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Trinidad & Tobago", "Trinidad and Tobago")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Antigua & Barbuda", "Antigua and Barbuda")

nationality_overall$Nationality <- 
  nationality_overall$Nationality %>% 
  str_replace_all("Ivory Coast", "Cote d'Ivoire")

saveRDS(nationality_overall, file="data/processed_nationality.rds")

# Now we merge our data with the spatial data.
world_data <- sp::merge(world_spdf, nationality_overall, by.x = "NAME", by.y = "Nationality", duplicateGeoms = TRUE)


mybins <- c(0, 40, 50, 60, 70, 75, 80, 85, 90, 95, 100)
pal <- colorNumeric("Blues", domain = world_data@data$count, na.color = "transparent")

labels <- sprintf(
  "<strong>%s</strong><br/> Avg. Overall = %g<br/>  Num. Players: %g",
  world_data@data$NAME, world_data@data$avg, world_data@data$count) %>% 
  lapply(htmltools::HTML)

m <- leaflet(world_data) %>% 
  addTiles() %>% 
  addPolygons(
    fillColor = ~pal(count),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto")) %>% 
   addLegend(pal = pal, values = world_data$count, opacity = 0.7, title = "Avg Overall",
             position = "bottomleft")
  
m
