# LOADING REQUIRED PACKAGES ====================================================
library(tidyverse)
library(magrittr)
library(gsubfn)
library(rgdal)
library(leaflet)
library(fmsb)
library(data.table)

# CONSTANTS ====================================================================
FEET_TO_METERS = 3.84
INCHES_TO_CM = 2.54

# 1 - Players pre-processing ===================================================

# The dataset contains more than 18,000 players, with more than 80 features for 
# each one. To simplify the dataset I have drop some that columns are not relevant for
# the visualization (e.g. some features that the game uses for its internal game mechanics)

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

# Dealing with empty colunms in Club, Preferred Foor and International Rep. features
players$Club <- players$Club %>%
  str_replace_all("^$", "Free agent")

players$`Preferred Foot` <- players$`Preferred Foot` %>% 
  replace_na("Right")
players$`Weak Foot` <- players$`Weak Foot` %>% 
  replace_na(1)
players$`International Reputation` <- players$`International Reputation` %>% 
  replace_na(1)

# Converting dates from --MM YYYY-- into years only ----------------------------
players$Joined <- players$Joined %>% 
  str_replace_all("^.*([0-9]{4}$)", "\\1")
unique(players$Joined)

players$`Contract Valid Until` <- 
  players$`Contract Valid Until` %>% 
  str_replace_all("^.*([0-9]{4}$)", "\\1")

# Converting height (ft. inches to cm) -----------------------------------------
players <- players %>% 
  separate(Height, c("Height_ft", "Height_in"), sep = "'")

players <- players %>% 
  mutate("Height (cm)" = round(as.numeric(Height_ft) * FEET_TO_METERS + 
                                 as.numeric(Height_in) * INCHES_TO_CM))

# Preprocess weight column (from lbs to kg) ------------------------------------
players <- rename(players, "Weight_lbs" = Weight)

players$Weight_lbs <- players$Weight_lbs %>% 
  str_replace_all("lbs", "")

players$`Weight (kg)` <- round(as.numeric(players$Weight_lbs))

# Preprocessing Wage, Value and Release Clause columns -------------------------
# from €xxxx.xxM or €xxx.xxK to just XXX in millions of €

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

saveRDS(players,file="data/processed_players.rds") # saving as serialized file

# End of players Preprocessing  ================================================


# 2 - Data pre-processing for the spider graph =================================

spider_chart_data <- select(players, Name, Finishing, Dribbling, Acceleration,
                            BallControl, Agility, LongPassing, SprintSpeed)

# first two rows must be the max. and min. values
spider_chart_data <- rbind(rep(100,8), rep(0,8), spider_chart_data) 

# saveRDS(spider_chart_data, file="data/spider_chart_data.rds")

# Color vectors for the spider chart
spider_colors_border=c(rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9))
spider_colors_in=c(rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4))

radarchart( spider_chart_data[c(1,2,4,17000),2:8]  , axistype=1 , 
            #custom polygon
            pcol=spider_colors_border , pfcol=spider_colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)
# Add a legend
legend(x=1.6, legend = c(spider_chart_data[4,1], spider_chart_data[17000,1]), bty = "n",
       pch=20 , col=spider_colors_in , text.col = "black", cex=1.2, pt.cex=3)


# 3 - Data preoprocessing for the map ==========================================
# download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip", 
#              destfile="data/world_shape_file.zip")
# system("unzip DATA/world_shape_file.zip")

world_spdf <- readOGR("data/world_shape_file/TM_WORLD_BORDERS_SIMPL-0.3.shp")

# Summarise the variables and aggregate by Nationality -------------------------
nationality_overall <- players %>% group_by(Nationality) %>% 
  summarise(avg = round(mean(Overall),0), avg_value = round(mean(`Value (M€)`), 1), count = n()) %>% 
  arrange(desc(avg))

# Now we make equal the names of the Fifa19 database and the world map shape ---
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

# Now we merge our aggregated Fifa19 data with the spatial polygons dataframe --
world_data <- sp::merge(world_spdf, nationality_overall, by.x = "NAME",
                        by.y = "Nationality", duplicateGeoms = TRUE)
saveRDS(world_data, file = "data/world_map_fifa_colored.rds")

# Define the color of the choropleth
# mybins <- c(0, 40, 50, 60, 70, 75, 80, 85, 90, 95, 100)
pal <- colorNumeric("Greens", domain = world_data@data$count, na.color = "transparent")

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
