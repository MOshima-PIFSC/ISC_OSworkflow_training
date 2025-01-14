
# Nicholas Ducharme-Barth
# 2025/01/06
# launch Shiny app

# Copyright (c) 2025 Nicholas Ducharme-Barth

#_____________________________________________________________________________________________________________________________
# define paths
	proj_dir = this.path::this.proj()
  setwd(paste0(proj_dir,"/shiny"))
  
#_____________________________________________________________________________________________________________________________
# Run the app
  source(paste0(proj_dir,"/shiny/app.R"))

