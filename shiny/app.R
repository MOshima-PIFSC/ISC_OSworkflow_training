
# Nicholas Ducharme-Barth
# 2025/01/06
# launch Shiny app

# Copyright (c) 2025 Nicholas Ducharme-Barth

#_____________________________________________________________________________________________________________________________
# load packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(data.table)
library(markdown)
library(magrittr)
library(ggplot2)
library(viridis)

#_____________________________________________________________________________________________________________________________
# source ui/server
  source("./ui.R")
  source("./server.R")

#_____________________________________________________________________________________________________________________________
# Run the app
  app = shinyApp(ui=ui,server=server)
  runApp(app, port = 8888)
