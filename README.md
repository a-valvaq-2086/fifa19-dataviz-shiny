# fifa19-dataviz-shiny
Data vizualitation app in RShiny App for the FIFA19 database

The app can be run from shinyapps.io, click on the following link:

https://avalladares-vaquero.shinyapps.io/FIFA19-Database-Visualization/

App description.

This R Shiny app contains the visualization of the FIFA19 videogame complete database. You can find a brief summary in the following lines:

The data set is the complete DB of the FIFA19 game, which can be downloaded from:
https://www.kaggle.com/karangadiya/fifa19

The database comprises over 18,000 players from all around the globe. Each player has more than 80 features.

To simplify the dataset I have drop some columns that are not relevant for the visualization (e.g. some features that the game uses for its internal game mechanics).

I divided the app in three tabs:

1) The first one, represents an overall database scatter plot , where you can compare different features, and see if you can get any insight of any relationship.

-NB: how the value and wages increase exponentially with the Overall quality

-It is clearly noticeable that some of the best players (the so-called 'franchise players') are overvalued with respect other outstanding players

-Is interesting to compare physical characteristics like weight, or height with performance attributes

2) The second one is a radar plot comparison typical of this kind of games, where you can can search for two players and compare them visually

3) Is a Leaflet interactive choropleth world map coloured by Average Overall and Number of Players per country 
