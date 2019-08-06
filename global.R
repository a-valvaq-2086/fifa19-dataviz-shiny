# Loading the server
library(shiny)
library(rsconnect)
library(data.table)
library(tidyverse)
library(broom)
library(magrittr)
library(fmsb)
library(rgdal)
library(leaflet)
library(fmsb)
library(htmltools)

# Load the data set
players <- readRDS("data/processed_players.rds")
world_spdf <- readOGR("data/world_shape_file/TM_WORLD_BORDERS_SIMPL-0.3.shp")
nationality_overall <- readRDS("data/processed_nationality.rds")


# Color vectors for spider chart
colors_border=c(rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9))
colors_in=c(rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4))

# Color vectors for the map colors
map_overall <-  colorNumeric(palette = "Greens", na.color = "transparent")
map_value <- colorNumeric(palette = "Blues", na.color = "transparent")