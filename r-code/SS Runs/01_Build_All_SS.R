## Wrapper function for building SS files and running the models
#' This function takes several arguments, for a specific species, and builds the 4 SS3 input files, and saves the files into the subdirectory of that species-scenario.
#' Note, you will need to set up Google Drive authentication with the `googlesheets4` package which will allow you to directly pull parameter input files from Google Drive into R session. If you do not wish to use Google Drive, please download and unzip the data folder from the Territorial bottomfish Google Drive folder into a 'Data' folder on your local computer and then set `readGoogle = FALSE`.
#' @param species the species ID code to use (4 letter scientific name code, e.g. APRU)
#' @param scenario a string to identify which scenario model is being developed under, needs to match name of sheet in CTL_inputs.xlsx file
#' @param startyr start year of the model
#' @param species_folder TRUE if you want species specific model run folders, FALSE is only running models for a single species (reduces nesting)
#' @param endyr end year of the model
#' @param fleets                     an integer or vector of integers of fleet id numbers, default is 1
#' @param M_option which option being used for natural mortality and Nages (found in CTL_parameters.xlsx$OPTION), default is "Option1"
#' @param GROWTH_option see M_option (growth curve parameters: Lamin, Lamax, k, CV young & CV old)
#' @param LW_option see M_option (length-weight relationship)
#' @param MAT_option see M_option (maturity and fecundity: L50, L95,a,b,cohort growth, frac female)
#' @param SR_option see M_option (stock-recruitment, except R0)
#' @param Q_option see M_option (catchability)
#' @param EST_option see M_option (model estimated parameters: R0, Q, selectivity)
#' @param initF turn initial F estimation on (default is FALSE)
#' @param lambdas dataframe of lambda values, default is NULL 
#' @param includeCPUE default is true, if excluding CPUE, set to FALSE
#' @param superyear default is FALSE, to use super periods for length comp data set to TRUE
#' @param superyear_blocks a list of vectors, each vector contains the start and end year of a super period block 
#' (ie list(c(2004,2006))), if there are 2 super periods then length(superyear_blocks) = 2
#' @param init_values use ss.par file to run ss model (1), or no (0) (starter.ss input)
#' @param parmtrace can switch to 1 to turn on, helpful for debugging model (starter.ss input)
#' @param last_est_phs last phase for estimation (starter.ss input)
#' @param seed value to set seed for run
#' @param F_report_basis the denominator used to report out F std. Default is 2 (FMSY). See user manual for all options.
#' @param benchmarks default set to 1, see forecast file for options (forecast.ss input)
#' @param MSY default set to 2, see forecast file for options (forecast.ss input)
#' @param SPR.target value to set target SPR at (forecast.ss input)
#' @param Btarget value to set B-ratio target at (forecast.ss input)
#' @param Bmark_years years for forecasting settings, see forecast file for options (forecast.ss input)
#' @param Bmark_relF_Basis how forecast catches are calculated and removed default = 1, use FSPR (forecast.ss input)
#' @param Fcast_years years for forecast settings, see forecast file for options (forecast.ss input)
#' @param ControlRule apply reductions to catch or F based on a control rule, see forecast file for options (forecast.ss input)
#' @param root_dir path to root directory
#' @param file_dir name of subdirectory to save files to, default is same as scenario
#' @param template_dir path to template SS files
#' @param out_dir first part of path to directory for saving files to, do not include species name or scenario
#' @param write_files default TRUE, create new input files for ss models. Once the model files are written, can be set to FALSE to increase speed when running diagnostics.
#' @param runmodels default TRUE, runs ss model. If model has been run, can set to FALSE when running diagnostics to increase speed.
#' @param est_args extra arguments that can be added to ss call (i.e. "-nohess")
#' @param do_retro TRUE to run retrospective (see r4ss::retro() for specific details of how retrospectives are run)
#' @param retro_years years for retrospective peels, relative to end year, ie 0:-3 is 3 year peels
#' @param do_profile TRUE to run likelihood profiling (see r4ss::profile() for specific details of how likelihood profiles are run)
#' @param profile string vector of parameter to profile, can be a vector of strings if changing multiple (ie "SR_LN(R0)")
#' @param profile.vec first value is the number of models you want to run, second is the step of the parameter value you would like to use (i.e. if profiling over R0=8, a value of (20,0.1) would mean you want 20 models run from 7-9 by 0.1)
#' @param do_jitter TRUE to run jitter analysis (see r4ss::jitter() for specific details of how jitter analyses are run)
#' @param Njitter number of jitters to run
#' @param jitterFraction increment of change for each jitter run
#' @param printreport default TRUE, produces summary diagnostics report
#' @param r4ssplots default is FALSE, will produce full r4ss output plots
#' @param readGoogle default is TRUE, pulls in ctl parameter and input files from Google Drive. If false, will use them from Data folder on local computer
#' @param run_parallel default is TRUE, Jitter, Retrospectives, and Profiles will all be run in parallel, if FALSE, will run sequentially
#' @param N_bootstraps default is 1 (no bootstraps) is the number of bootstrap files that will be produced after running the model.
#' @param exe default is "ss", the name of the executable you want to use (do not include .exe in the name)
#' @param r_code is where your R scripts are located in the base directory description

cpueinfo <- as.data.frame(matrix(data = c(1:model.info$Nfleets), nrow = model.info$Nfleets, ncol = 4))
colnames(cpueinfo) <- c("Fleet", "Units", "Errtype", "SD_Report")
cpueinfo$Fleet <- as.character(c(1:model.info$Nfleets))
cpueinfo$Units <- 1
cpueinfo$Errtype <- 0 #lognormal
cpueinfo$SD_Report <- 0

if(any(!is.na(model.info$catch.num))){
cpueinfo[c(model.info$catch.num),"Units"]=0 #changes these to numbers
}
if(any(!is.na(model.info$fleetinfo.special))) {
cpueinfo[c(model.info$fleetinfo.special$fleet),"Units"]=model.info$fleetinfo.special$unit
}

# Length Bins

BIN.LIST <- list("BINWIDTH"=model.info$binwidth,
                 "min" = model.info$bin.min,
                 "max" = model.info$bin.max)


Build_All_SS <- function(model.info=model.info,
                         species_folder=FALSE,
                         scenario = "base",
                         M_option = "Option1",
                         GROWTH_option = "Option1",
                         LW_option = "Option1",
                         MAT_option = "Option1",
                         SR_option = "Option1",
                         EST_option = "Option1",
                         SEL_option = "Option1",
                         initF = FALSE,
                         includeCPUE = TRUE,
                         superyear = FALSE,
                         superyear_blocks = NULL,
                         N_samp = 40,
                         init_values = 0, 
                         parmtrace = 0,
                         last_est_phs = 10,
                         benchmarks = 1,
                         MSY = 2,
                         SPR.target = 0.4,
                         Btarget = 0.4,
                         Bmark_years = c(0,0,0,0,0,0,0,0,0,0),
                         Bmark_relF_Basis = 1,
                         Forecast = 2,
                         Fcast_years = c(0,0,0,0,-999,0),
                         Fixed_forecatch=1,
                         ControlRule = 0,
                         file_dir = scenario,
                         write_files = TRUE,
                         runmodels = TRUE,
                         ext_args = "-nohess",
                         do_retro = TRUE,
                         retro_years = 0:-5,
                         do_profile = TRUE,
                         profile_name = "SR_LN(R0)",
                         profile.vec = seq(8, 0.1),
                         do_jitter = TRUE,
                         Njitter = 200,
                         jitterFraction = 0.1,
                         do_ASPM = TRUE,
                         printreport = TRUE,
                         r4ssplots = TRUE,
                         readGoogle = TRUE,
                         run_parallel=TRUE,
                         N_bootstraps = 1,
                         exe="ss",
                         r_code = "Rscripts",
                         run_folder = "SS3 Runs"
                         ){
  
  
  

  # cpue info table
  cpueinfo <- as.data.frame(matrix(data = c(1:model.info$Nfleets), nrow = model.info$Nfleets, ncol = 4))
  colnames(cpueinfo) <- c("Fleet", "Units", "Errtype", "SD_Report")
  cpueinfo$Fleet <- as.character(c(1:model.info$Nfleets))
  cpueinfo$Units <- 1
  cpueinfo$Errtype <- 0 #lognormal
  cpueinfo$SD_Report <- 0
if (any(!is.na(model.info$catch.num))) {
  cpueinfo[c(model.info$catch.num), "Units"] <- 0 # changes these to numbers
}
if (any(!is.na(model.info$fleetinfo.special))) {
  cpueinfo[c(model.info$fleetinfo.special$fleet), "Units"] <- model.info$fleetinfo.special$unit
}
  
  # Length Bins
  
  BIN.LIST <- list("BINWIDTH"=model.info$binwidth,
                   "min" = model.info$bin.min,
                   "max" = model.info$bin.max)
  
  startyr=model.info$startyear
  endyr=model.info$endyear
  species=model.info$Species
  scenario=model.info$scenario
  lambdas=model.info$lambdas
  seed=model.info$seed
  F_report_basis=model.info$F_report_basis
  Nforeyrs=model.info$N_foreyrs
 
  root_dir=model.info$base.dir
  if(model.info$Nsexes==1){
    template_dir=file.path(model.info$template_dir,"one sex")
  } else {
    template_dir=file.path(model.info$template_dir,"two sex")
    }
 
 if(species_folder==TRUE){
   file_dir = paste(species,run_folder, model.info$scenario, sep="/") 
   out_dir=paste(root_dir,species,file_dir,model.info$scenario,sep="/")
 } else {
  file_dir = paste(run_folder,model.info$scenario,sep="/")
  out_dir=paste(root_dir,run_folder,model.info$scenario,sep="/")
 }
  if(write_files){
    
  ## Step 1. Read in all data components ###-------------------------------------------
  
  # Catch data
  catch <- data.table::data.table(  read.csv(file.path(root_dir, "Data", "Catch", model.info$catch.file))  )
  names(catch)<-c("year","seas","fleet","catch","catch_se")
  #catch <- catch %>% mutate(MT = ifelse(MT == 0, 0.001, MT))

  # CPUE data
  cpue<-data.table::data.table(  read.csv(file.path(root_dir, "Data", "CPUE", model.info$CPUE.file),header=T)  )[,1:5]
  names(cpue)<-c("year","seas","index","obs","se_log")  
  
  
    # Length comp data
  lencomp <- read.csv(file.path(base.dir, "Data", "Length", model.info$length.file),header=T)  

   # Control and data file inputs
  if(readGoogle == T){
      ctl.params <- read_sheet("1_I8tIzXB7pSlWc4Yr1mC4zXe0JYmQGr_lmmZdAGWy4Q", 
                           sheet=model.info$Species)
      ctl.inputs <- read_sheet("1j_WdVNls0xusIV2DDVnQXJnyLI8ybKlFnrKmG1_G7A8", sheet=model.info$scenario)
  
  }else{
    ctl.inputs <- readxl::read_excel(file.path(root_dir, "Data", "CTL_inputs.xlsx"), sheet=scenario)
    ctl.params <- readxl::read_excel(file.path(root_dir, "Data", "CTL_parameters.xlsx"), 
                       sheet=species)
  }

  
  ## Step 2. Source scripts with each function ###-------------------------------------
  ### Call the functions to build the SS3 files ####
  source(file.path(root_dir, r_code, "SS Runs", "02_Build_Starter_SS.R"))
  source(file.path(root_dir, r_code, "SS Runs", "03_Build_Data_SS.R"))
  source(file.path(root_dir, r_code, "SS Runs", "04_Build_Control_SS.R"))
  source(file.path(root_dir, r_code, "SS Runs", "05_Build_Forecast_SS.R"))
 
  ## Step 3. Create other inputs ###---------------------------------------------------
  ### Create subdirectory
  if(!dir.exists(file.path(root_dir, file_dir))){
    dir.create(file.path(root_dir, file_dir), showWarnings = T, recursive=TRUE)
  }
  
  ## Create text file with notes from CTL_params sheet for reference
   sink(file.path(root_dir, file_dir,"model_options.txt"))
   
   cat(paste0("M: ", M_option, ", ", ctl.params$Notes[which(ctl.params$category == "MG" & 
                                                              ctl.params$OPTION == M_option &
                                                              ctl.params$X1 == "NatM_p_1_Fem_GP_1")] ,"\n"))
   
   cat(paste0("Growth: ", M_option, ", ", ctl.params$Notes[which(ctl.params$category == "MG" & 
                                                                   ctl.params$OPTION == M_option &
                                                                   ctl.params$X1 == "L_at_Amin_Fem_GP_2")] ,"\n"))
   
   cat(paste0("Stock-Recruit: ", SR_option, ", ", ctl.params$Notes[which(ctl.params$category == "SR" & 
                                                                   ctl.params$OPTION == SR_option &
                                                                   ctl.params$X1 == "SR_LN(R0)")] ,"\n"))
   
   sink()
  
  ## Remove notes column 
  ctl.params <- select(ctl.params, -Notes)
  
  Nfleets <- length(model.info$fleets)
  
   Nages <- ctl.inputs %>%
     select(Parameter, paste0(model.info$Species)) %>% 
     filter(str_detect(Parameter, "Nages")) %>%
        pull() 
  
  Narea <- ctl.inputs %>% 
    select(Parameter, paste0(model.info$Species)) %>% 
    filter(str_detect(Parameter, "N_areas")) %>% 
    pull()
  
  Nsexes <- ctl.inputs %>% 
    select(Parameter, paste0(model.info$Species)) %>% 
    filter(str_detect(Parameter, "Nsexes")) %>% 
    pull()
  
  CompError <- ctl.inputs %>% 
    select(Parameter, paste0(model.info$Species)) %>% 
    filter(str_detect(Parameter, "CompError")) %>% 
    pull()
  
  # Determine min-max age when reporting F (starter file option)
  FminAge <- if(Nages>=15){5} else {1}
  FmaxAge <- Nages-2
  
  
 # Selectivity types
  size_selex_types <- ctl.inputs %>% 
    select(Parameter, contains(paste0(model.info$Species))) %>% 
    filter(str_detect(Parameter, "size_selex")) %>% 
    mutate(Fleet = str_extract(Parameter, "[0-9]*$") %>% 
             as.numeric(),
           Fleet = str_replace_na(Fleet, replacement = "1"),
           Parameter = str_remove_all(Parameter, "_[0-9]*$")
           ) %>% 
    filter(Fleet %in% c(1:model.info$Nfleets)) %>% 
    pivot_wider(names_from = Parameter, values_from = paste0(model.info$Species)) %>% 
    mutate(Male = 0) %>% 
    select(size_selex_pattern, size_selex_discard, Male, size_selex_special) %>% 
    setNames(c("Pattern", "Discard", "Male", "Special")) %>% 
    as.data.frame() 
  
  age_selex_types <- ctl.inputs %>% 
    select(Parameter, contains(paste0(model.info$Species))) %>% 
    filter(str_detect(Parameter, "age_selex")) %>% 
    pivot_wider(names_from = Parameter, values_from = paste0(model.info$Species)) %>% 
   setNames(c("Pattern", "Discard", "Male", "Special")) %>% 
    as.data.frame() %>% 
    slice(rep(1:n(), each = model.info$Nfleets)) #assume same selectivity pattern for both areas
    
  # Catchability options
  if(includeCPUE){
    Q.options <- ctl.inputs %>% 
      select(Parameter, contains(paste0(model.info$Species))) %>% 
      filter(str_detect(Parameter, "Q.opt")) %>% 
      mutate(Fleet = str_extract(Parameter, "[0-9]*$") %>% 
               as.numeric(),
             Parameter = str_remove_all(Parameter, "_[0-9]*$")) %>% 
      filter(Fleet %in% c(1:model.info$Nfleets)) %>% 
      pivot_wider(names_from = Parameter, values_from = paste0(model.info$Species)) %>% 
      setNames(c("fleet", "link", "link_info", "extra_se", "biasadj", "float")) %>%
      na.omit()
    Q.options$fleet<-c((model.info$Nfleets-model.info$Nsurvey+1):model.info$Nfleets)
    if(model.info$Nfleets > 1){
      Q.options <- Q.options %>% 
        filter(fleet > 1)
    }
  }else{
    Q.options <- NULL
  }

  # Fleet and CPUE info
  
  need_catch_mult <- ctl.inputs %>% 
    select(Parameter, paste0(model.info$Species)) %>% 
    filter(str_detect(Parameter, "catch_mult")) %>% 
    mutate(Fleet = str_extract(Parameter, "[0-9]*$") %>% 
             as.numeric()) %>% 
    filter(Fleet %in% c(1:model.info$Nfleets)) %>% 
    pull(paste0(model.info$Species))
  

   fleetname <- model.info$fleets
  
   fleetinfo <- data.frame(
     "type" = c(rep(1,model.info$Nfleets-model.info$Nsurvey),rep(3, model.info$Nsurvey)), 
     "surveytiming" = c(rep(-1, (model.info$Nfleets-model.info$Nsurvey)),rep(1,model.info$Nsurvey)), 
     "area" = rep(1, model.info$Nfleets),
    "units" = rep(1, model.info$Nfleets),
     "need_catch_mult" = ifelse(!is.na(need_catch_mult),need_catch_mult,0),
     "fleetname" = fleetname
   )
   if(any(!is.na(model.info$catch.num))){
   fleetinfo[c(model.info$catch.num),"units"]=2 ##change catch units to numbers for these fleets
   }
  
   
  ## Step 4. Create SS3 input files
  Build_Starter(scenario = scenario,
                template_dir = template_dir, 
                out_dir = out_dir,
                model.info = model.info,
                init_values = init_values,
                parmtrace = parmtrace,
                last_est_phs = last_est_phs,
                N_bootstraps=N_bootstraps)
  
  ## write a new forecast file
  Build_Forecast(scenario = scenario,
                 template_dir = template_dir,
                 out_dir = out_dir,
                 benchmarks = benchmarks,
                 MSY = MSY,
                 endyr = endyr,
                 SPR.target = SPR.target,
                 Btarget = Btarget,
                 Bmark_years = Bmark_years, #c(-1,-1,-1,-1,-1,-1,-999,-1,-999,-1), ## <0 = endyear, -999 = startyear
                 Bmark_relF_Basis = Bmark_relF_Basis,
                 Forecast = Forecast,
                 Nforeyrs = Nforeyrs, 
                 Fcast_years = Fcast_years,#c(0,0,0,0,0,0),
                 ControlRule = ControlRule,
                 Fixed_forecatch = Fixed_forecatch)
  
  
  Build_Control(species=species, 
                scenario = scenario,
                Nfleets = model.info$Nfleets,
                Nsexes = model.info$Nsexes,
                CompError = CompError,
                ctl.inputs = ctl.inputs,
                ctl.params = ctl.params,
                includeCPUE = includeCPUE,
                Q.options = Q.options,
                M_option = M_option,
                GROWTH_option = GROWTH_option,
                LW_option = LW_option,
                MAT_option = MAT_option,
                SR_option = SR_option,
                EST_option = EST_option,
                SEL_option = SEL_option,
                size_selex_types = size_selex_types,
                age_selex_types = age_selex_types,
                initF = initF,
                lambdas = lambdas,
                file_dir = scenario,
                template_dir = template_dir,
                out_dir = out_dir,
                model.info=model.info)
  
  
  
   Build_Data(catch = catch, 
              initF = initF, 
              CPUEinfo = cpueinfo, 
              cpue = cpue, 
              Narea = Narea, 
              Nages = Nages,
              CompError = CompError, 
              lencomp = lencomp, 
              startyr = startyr, 
              endyr = endyr, 
              bin.list = BIN.LIST, 
              fleets = fleets, 
              fleetinfo = fleetinfo, 
              lbin_method = model.info$lbin_method, 
              file_dir = scenario,
              template_dir = template_dir, 
              out_dir = out_dir,
              model.info=model.info)
   
 
 } 
   model_dir <- out_dir
   
   if(runmodels){
  #   ### Run Stock Synthesis ####
     file.copy(file.path(root_dir,"bin", paste0(exe,".exe")), 
               model_dir)
     r4ss::run(dir = model_dir, 
                   exe = exe, extras = ext_args,  skipfinished = FALSE, show_in_console = TRUE)
   }

  # 
   
     report <- r4ss::SS_output(model_dir, 
                               verbose = FALSE, printstats = FALSE)
    if(r4ssplots){ 
      r4ss::SS_plots(report, dir = model_dir)
     r4ss::SS_plots(report, dir = model_dir, pdf=TRUE, png=FALSE)
     
   }
  # 
  source(file.path(root_dir, r_code, "SS Runs", "06_Run_Diags.R")) 
  # 
  Run_Diags(model.info,
            root_dir = root_dir,
            file_dir = file_dir,
            r_code = r_code,
            do_retro = do_retro,
            retro_years = retro_years,
            do_profile = do_profile,
            profile_name = profile_name,
            profile.vec = profile.vec,
            do_jitter = do_jitter,
            Njitter = Njitter,
            jitterFraction = jitterFraction,
            do_ASPM = do_ASPM,
            run_parallel=run_parallel,
            exe=exe
              )
   
   if(printreport){
     ### Create Summary Report ####
     if(!require(tinytex)) {tinytex::install_tinytex()
                            library(tinytex)}
           profile.MLE<-report$parameters %>%
              filter(Label==profile_name) %>%
              pull(Value)
            profile.min<-profile.MLE-(profile.vec[1]/2)*(profile.vec[2])
            profile.max<-profile.MLE+(profile.vec[1]/2)*(profile.vec[2])  
      profile_vec <- seq(profile.min,profile.max,profile.vec[2])
     
     file.copy(from = file.path(root_dir,r_code, "model_diags_report.qmd"), 
                 to = file.path(out_dir, 
                                paste0(species, "_", model.info$scenario, "_model_diags_report.qmd")), 
                 overwrite = TRUE)
      
      
   
     quarto::quarto_render(input = file.path(root_dir, file_dir,
                                             paste0(species, "_", model.info$scenario, 
                                                    "_model_diags_report.qmd")),
                           output_format = c("pdf","html"),
                           execute_params = list(
                             species = paste0(species),
                             scenario = scenario,
                             profile = profile_name,
                             profile_vec = profile_vec,
                             Njitter = Njitter
                           ),
                           execute_dir = file.path(root_dir, file_dir))
     
     file.rename(from = file.path(root_dir, file_dir,
                                  paste0(species, "_", scenario, 
                                         "_model_diags_report.pdf")),
                 to = file.path(root_dir, file_dir,
                                paste0("0_", species, "_", scenario, 
                                       "_model_diags_report.pdf")))
         
   
   }
   
  
} 
