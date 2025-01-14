### Set up the SS model to run
### Notes about the template input files: you need separate control 
### and data files for single sex models and two-sex models. Otherwise 
### the starter and forecast files can be the same.


## 1. Input needed information
library(r4ss)
## library(ss3diags)  ## don't load ss3diags until it is updated to by compatible with r4ss v1.51.0
library(readxl)
library(quarto)
library(googlesheets4)
library(tidyr)
library(dplyr)
library(tibble)
library(stringr)
library(this.path)
## base working directory where all files are stored

base.dir<-"C:/Users/Michelle.Sculley/Documents/OpenScienceTraining/ISC_OSworkflow_training"
base.dir <- getwd()

fleetnames<-c("FISHERY",
              "SURVEY1",
              "SURVEY2")




model.info<-list(
  "Species"="EXM",
  "base.dir"=base.dir,
  "scenario"="base",
  "startyear"=1971,
  "endyear"=2001,
  "nyr"=5,  ## indicates how many years you want to average the dynamic B0 over if applicable
  "nboot"= 1, ## number of bootstrap files to create, set to 1 to create none
  "seed"=123, ##set seed value
  "data.file.name"="data.dat",
  "ctl.file.name"="control.ctl",
  "templatefiles"=list("data"="data.dat",
                       "control"="control.ctl"),
  "template_dir" = file.path(base.dir, "Template_files"),
  "N_foreyrs"=1,
  "init_values" = 0, #read from par = 1, read from ctl file = 0
  "F_age_range"=c(1,25),
  "F_report_basis" = 0, #0=raw_annual_F; 1=F/Fspr; 2=F/Fmsy; 3=F/Fbtgt; where F means annual_F; values >=11 invoke N multiyr (up to 9!) with 10's digit; >100 invokes log(ratio)
  "Min_age_biomass"=1,
  "Nfleets"=3,
  "Nsurvey"=2,
  "Nsexes" = 2,
  "fleets"=fleetnames,
  "catch.file"="InputCatch_Base.csv",
  "length.file"="InputLength_Base.csv",
  "CPUE.file"="InputCPUE_Base.csv",
  "binwidth"=2,
  "bin.min"=10,
  "bin.max"=94,
  "fleetinfo.special"= c(NA), #fleet number, special survey type (otherthan  1 - catch or 3 - CPUE/Survey )
  "catch.num"=c(2,3),  ##fleets in which catch is in numbers,
  "nseas"=1,
  "spawn_month"=1,
  "mon_per_seas" = 12,
  "lbin_method"=2,
  "n_sizebins" = 25,
  "size_bins"=c(26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 68, 72, 76, 80, 90),
  "lambdas"=TRUE,
  "fore_maxcatch_flt" = data.frame("fleet"=1, "max_catch"=0))  #for setting forecast values, one line for each catch fleet


## Run models
source(file.path(base.dir,"r-code","SS Runs","01_Build_All_SS.R"))
Build_All_SS(model.info=model.info,
             species_folder=FALSE,
             M_option = "Base",
             GROWTH_option = "Base",
             LW_option = "Fat_Fish",
             MAT_option = "Base",
             SR_option = "Base",
             EST_option = "Base",
             SEL_option = "Base",
             initF = FALSE,
             includeCPUE = TRUE,
             superyear = FALSE,
             superyear_blocks = NULL,
             N_samp = 40,  ##what does this do
             init_values = 0,  ## use initial values from ctr file 
             parmtrace = 0,
             last_est_phs = 10,
             benchmarks = 1,
             MSY = 2,
             SPR.target = 0.4,
             Btarget = 0.4,
             Bmark_years = c(0,0,0,0,0,0,-999,0,-999,0),
             Bmark_relF_Basis = 1,
             Forecast = 2,
             Fcast_years = c(0,0,0,0,0,0),
             Fixed_forecatch=1,
             ControlRule = 0,
             write_files = TRUE,
             runmodels = TRUE,
             ext_args = "",  ## -nohess to run without hessian
             do_retro = FALSE,
             retro_years = 0:-5,
             do_profile = FALSE,
             profile_name = "SR_LN(R0)",
             profile.vec = c(4, 0.1),  #[1] the number of models to run; [2] the increment you want to chang the parameter
             do_jitter = FALSE,
             Njitter = 10,
             jitterFraction = 0.1,
             do_ASPM = FALSE,
             printreport = FALSE,
             r4ssplots = FALSE,
             readGoogle = FALSE,
             run_parallel=FALSE,
             exe="ss3_win",
             r_code = "r-code", ## folder where your R scripts are stored
             run_folder = "stock-synthesis-models" ## folder you want your run models to be stored (default is SS3 runs)
)
