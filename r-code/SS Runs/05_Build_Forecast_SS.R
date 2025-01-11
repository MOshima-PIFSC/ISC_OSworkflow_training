#  --------------------------------------------------------------------------------------------------------------
#   AMERICAN SAMOA BOTTOMFISH - INITIAL SS FORECAST FILE CREATION
#	Use example model files (from https://github.com/nmfs-stock-synthesis/user-examples) as templates 
#   for forecast file
#	Megumi Oshima megumi.oshima@noaa.gov
#  
#  --------------------------------------------------------------------------------------------------------------
## Forecast file
#  --------------------------------------------------------------------------------------------------------------
Build_Forecast <- function(scenario = "base",
                           template_dir = file.path(base.dir, "Template_Files"),
                           out_dir = current.dir,
                           benchmarks = 1,
                           MSY = 2,
                           endyr = endyear,
                           SPR.target = 0.4,
                           Btarget = 0.4,
                           Bmark_years = c(-1,-1,-1,-1,-1,-1,-999,-1,-999,-1),
                           Bmark_relF_Basis = 1,
                           Forecast = 0,
                           Nforeyrs = 1, 
                           Fcast_years = c(0,0,0,0,0,0),
                           ControlRule = 0,
                           Fixed_forecatch = 1){
  ## STEP 1. Read in template forecast file
  FORE <- r4ss::SS_readforecast(file = file.path(template_dir, "forecast.ss"))
  
  ## STEP 2. Make any necessary changes
  #  --------------------------------------------------------------------------------------------------------------
  ## most common inputs to change:
  FORE$benchmarks                         <- benchmarks #calculate F_spr
  FORE$MSY                                <- MSY #calculate F(MSY)
  FORE$SPRtarget                          <- SPR.target
  FORE$Btarget                            <- Btarget
  FORE$fcast_rec_option                   <- 0 #SR curve
  
  FORE$Bmark_years                        <- Bmark_years 
  FORE$Bmark_relF_Basis                   <- Bmark_relF_Basis #use year range
  FORE$Forecast                           <- Forecast #F(SPR)
  FORE$Nforecastyrs                       <- Nforeyrs
  
  #beg_selex, end_selex, beg_relF, end_relF, beg_mean recruits, end_recruits
  FORE$Fcast_years                        <- Fcast_years
  FORE$ControlRuleMethod                  <- ControlRule
  if(Nforeyrs > 1){
    FORE$FirstYear_for_caps_and_allocations <- endyr + Nforeyrs + 1
  }else{
    FORE$FirstYear_for_caps_and_allocations <- endyr + 2
  }
  
  FORE$basis_for_fcast_catch_tuning       <- 2
  FORE$InputBasis                         <- 2
 
  
  
  ## STEP 3. Save updated file
  #  --------------------------------------------------------------------------------------------------------------
  r4ss::SS_writeforecast(FORE, dir = out_dir,
                         writeAll = TRUE, overwrite = TRUE)
  
}
