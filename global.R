# Loading the server
library(shiny)
library(rsconnect)
library(tidyverse)
library(broom)
library(magrittr)
library(fmsb)
library(rgdal)
library(leaflet)
library(fmsb)
library(htmltools)

# Load the scatter plot data
players <- readRDS("data/processed_players.rds")

# Data and color vectors for spider chart
spider_chart_data <- readRDS("data/spider_chart_data.rds")
spider_colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9))
spider_colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4))

# Loading data for the choropleth
world_data <- readRDS("data/world_map_fifa_colored.rds")