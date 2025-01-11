#  --------------------------------------------------------------------------------------------------------------
#   ISC Billfish WG - INITIAL SS STARTER FILE CREATION
#	Use example model files (from https://github.com/nmfs-stock-synthesis/user-examples) as templates 
#   for starter file
#	Megumi Oshima megumi.oshima@noaa.gov, modified by Michelle Sculley michelle.sculley@noaa.gov
#  
#  --------------------------------------------------------------------------------------------------------------
## Starter file
#  --------------------------------------------------------------------------------------------------------------
Build_Starter <- function(scenario = "base",
                          template_dir = file.path(base.dir, "Template_Files"), 
                          out_dir = current.dir,
                          model.info = model.info,
                          init_values=0,
                          parmtrace = 0,
                          last_est_phs = 10,
                          N_bootstraps = 1){
  ## STEP 1. Read in template starter file
  START <- r4ss::SS_readstarter(file = file.path(template_dir, "starter.ss"))
  
  
  ## STEP 2. Make any changes necessary
  #  --------------------------------------------------------------------------------------------------------------
  ## most likely changes are listed below: 
  START$datfile <- model.info$data.file.name
  START$ctlfile <- model.info$ctl.file.name
  START$init_values_src <- init_values #switch 1 if want to use parameter values from par.ss
  START$parmtrace <- parmtrace #can switch to 1 to turn on, helpful for debugging model
  START$last_estimation_phase <- last_est_phs #turn to 0 if you don't want estimation
  START$N_bootstraps   <- N_bootstraps ## set how many bootstrap files you want
  START$maxyr_sdreport <- -2
  START$minyr_sdreport <- -1
  START$F_report_units <- 4
  START$F_age_range   <- model.info$F_age_range
  START$seed <- model.info$seed
  START$F_report_basis <- model.info$F_report_basis
  START$min_age_summary_bio <- model.info$Min_age_biomass
  
  
  ## STEP 3. Save updated starter file
  #  --------------------------------------------------------------------------------------------------------------
  r4ss::SS_writestarter(START, dir = out_dir, overwrite = TRUE)
  
}

