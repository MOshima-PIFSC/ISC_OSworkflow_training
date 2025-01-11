#' Function to run retrospective analysis, likelihood profiling, and jitter. 
#' 
#' @param root_dir root directory 
#' @param species species to run analyses for
#' @param file_dir name of subdirectory running tests in
#' @param do_retro TRUE run retrospective, FALSE doesn't
#' @param retro_years vector of years to peel back start with 0 and go to negative number of years
#' @param do_profile TRUE to run likelihood profile
#' @param profile string of the parameter to change (can be vector of strings if changing multiple)
#' @param profile.vec vector of 2 containing the spread of the profile range and the units of change over that spread (i.e., a vector of c(2,0.1) would indicate you would like a range of +/- 1 and a step of 0.1 for a total of 20 profiles)
#' @param do_jitter TRUE to run jitter analysis
#' @param Njitter number of jitters to run
#' @param jitterFraction increment of change for each jitter run
#' @param run_parallel TRUE to run diagnostics in parallel for jitter, profiles, and retrospectives
#' @param exe default is "ss", the name of the executable you want to use (do not include .exe in the name)
#' @param do_ASPM TRUE to run ASPM analysis




Run_Diags <- function(model.info,
                      root_dir = NA,
                     file_dir = "base",
                     r_code= "r-code",
                      do_retro = TRUE,
                      retro_years = 0:-5,
                      do_profile = TRUE,
                      profile_name = "SR_LN(R0)",
                      profile.vec = c(2, 0.1),
                      do_jitter = TRUE,
                      Njitter = 100,
                      jitterFraction = 0.1,
                     do_ASPM = TRUE,
                     run_parallel=TRUE,
                     exe= "ss"
                      ){
  if(!require(ggplot2)){install.packages("ggplot2")}
  library(ggplot2)
  if(!require(reshape2)){install.packages("reshape2")}
  library(reshape2)
  if(!require(parallelly)){install.packages("parallelly")}
  library(parallelly)
  if(!require(future)){install.packages("future")}
     library(future)
    if(do_retro == TRUE){
      message("Running retrospectives")
## this function uses a parallel retrospective function in development for R4ss. The code has been tested and pushed to the main branch of r4ss but hasn't been integrated yet. For now, a local version of the code is used. When the parallel process form retrospectives, jitter, and profiling are in the updated r4ss package, I will update this to use that function instead.
    if(run_parallel){
    source(file.path(root_dir,r_code,"SS Runs","parallel_retro.R"))
      source(file.path(root_dir,r_code,"SS Runs","parallel_SS_parlines.R"))
    ncores <- parallelly::availableCores() - 1
    future::plan(future::multisession, workers = ncores)
    retro(
    dir = file.path(root_dir,file_dir),
    oldsubdir="",
    newsubdir = "Retrospectives",
    years = retro_years,
    exe=exe
    )
    future::plan(future::sequential)
     }
    else {
       retro(dir=file.path(root_dir, file_dir), 
                  oldsubdir="", newsubdir="Retrospectives", years=retro_years, exe = exe)
    }
    
          # Read output
        #  retroModels <- SSgetoutput(dirvec=file.path(root_dir,file_dir,"Retrospectives", paste("retro",retro_years,sep="")), verbose=FALSE)
          
          # save as Rdata file for ss3diags
          #save(retroModels,file=file.path(dirname.Retrospective,paste0("Retro_",Run,".rdata")))
          
        #retroSummary<-SSsummarize(retroModels)  
       # MohnsRho<-SShcbias(retroSummary)
        message("Retrospectives Complete")  
        } 
    
    

  
    if(do_profile == TRUE){
      ## Create directory and copy inputs
      message(paste0("Doing profiles on ",profile_name,"." ))
      dir.profile <- file.path(root_dir, file_dir, paste0(profile_name, "_profile"))
      
       copy_SS_inputs(dir.old = file.path(root_dir, file_dir),
                     dir.new = dir.profile,
                     create.dir = TRUE,
                     overwrite = TRUE,
                     recursive = TRUE,
                     use_ss_new = TRUE,
                     copy_exe = TRUE,
                     copy_par = FALSE,
                     dir.exe = file.path(root_dir, file_dir),
                     verbose = TRUE)
      
      # Make changes to starter file
      starter <-  SS_readstarter(file.path(dir.profile, "starter.ss"))
      starter[["ctlfile"]] <- "control_modified.ss"
      starter[["init_values_src"]]<-0
      # make sure the prior likelihood is calculated
      # for non-estimated quantities
      starter[["prior_like"]] <- 1
       SS_writestarter(starter, dir = dir.profile, overwrite = TRUE)
      
      # make your new control file
      file.copy(file.path(dir.profile,model.info$ctl.file.name),
                file.path(dir.profile, "control_modified.ss"))
                
      
      # vector of values to profile over
      MLEmodel <- SS_output(file.path(root_dir,file_dir), verbose = FALSE, printstats = FALSE)
      profile.MLE<-MLEmodel$parameters %>%
        filter(Label==profile_name) %>%
        pull(Value)
     # Nprofile <- profile.vec[1]
      profile.min<-profile.MLE-(profile.vec[1]/2)*(profile.vec[2])
      profile.max<-profile.MLE+(profile.vec[1]/2)*(profile.vec[2])
      if (run_parallel == TRUE){
        source(file.path(root_dir,r_code,"SS Runs","parallel_profile.R"))
        source(file.path(root_dir,r_code,"SS Runs","parallel_SS_parlines.R"))
        ncores <- parallelly::availableCores() - 1
        future::plan(future::multisession, workers = ncores)
        prof.table <- profile(
          dir = dir.profile,
          exe = exe,
          oldctlfile = model.info$ctl.file.name,
          newctlfile = "control_modified.ss",
          string = profile_name, 
          profilevec = seq(profile.min,profile.max,profile.vec[2])
        )
        future::plan(future::sequential)
      } else {
      ## Do Profiling
      profile <- profile(
        dir = dir.profile, 
        exe = exe,
        oldctlfile = model.info$ctl.file.name,
        newctlfile = "control_modified.ss",
        string = profile_name,
        profilevec = seq(profile.min,profile.max,profile.vec[2])
      )
      }
      #  profilemodels<-SSgetoutput(dir=file.path(dir.profile),keyvec=1:(profile.vec[1]+1), verbose=FALSE)
       # profilemodels[["MLE"]] <- MLEmodel
       # profilesummary <- SSsummarize(profilemodels)
      message("Profiles complete")
    }
  
 
   if(do_jitter == TRUE){
     message(paste0("Running jitter for ",Njitter, " models."))
     dir.jitter <- file.path(root_dir, file_dir, "jitter")
      copy_SS_inputs(dir.old = file.path(root_dir, file_dir),
                          dir.new = dir.jitter,
                          create.dir = TRUE,
                          overwrite = TRUE,
                          recursive = TRUE,
                          use_ss_new = TRUE,
                          copy_exe = TRUE,
                          copy_par = TRUE,
                          dir.exe = file.path(root_dir, file_dir),
                          verbose = TRUE)
     
     if (run_parallel==TRUE) {
       source(file.path(root_dir,r_code,"SS Runs","parallel_jitter.R"))
       source(file.path(root_dir,r_code,"SS Runs","parallel_SS_parlines.R"))
       ncores <- parallelly::availableCores() - 1
       future::plan(future::multisession, workers = ncores)
       jit.likes <- jitter(
                   dir = dir.jitter, 
                   Njitter = Njitter,
                   jitter_fraction = jitterFraction, 
                   init_value_src = 1,
                   exe=exe
                   )
        future::plan(future::sequential)
     } else {
     # Step 7. Run jitter using this function (default is nohess)
     jit.likes <-  jitter(dir=dir.jitter, 
                                     exe = exe,
                               Njitter=Njitter, 
                               jitter_fraction = jitterFraction, 
                               init_values_src = 1)
     
     }
     message("Jitters complete")
     #jittermodels <- SSgetoutput(dirvec = dir.jitter, keyvec = 1:numjitter, getcovar = FALSE)
    # jittersummary <- SSsummarize(jittermodels)
   }
  
  if(do_ASPM==TRUE){
    ASPM.dir<-file.path(root_dir,file_dir,"ASPM")
     copy_SS_inputs(dir.old = file.path(root_dir, file_dir),
                         dir.new = ASPM.dir,
                         create.dir = TRUE,
                         overwrite = TRUE,
                         recursive = TRUE,
                         use_ss_new = TRUE,
                         copy_exe = TRUE,
                         copy_par = FALSE,
                         dir.exe = file.path(root_dir, file_dir),
                         verbose = TRUE)
    ##set rec devs in ss.par to 0
    # par <- SS_readpar_3.30(
    #   parfile = file.path(ASPM.dir, "ss3.par"),
    #   datsource = file.path(ASPM.dir, model.info$data.file.name),
    #   ctlsource = file.path(ASPM.dir, model.info$ctl.file.name),
    #   verbose = FALSE
    # )
    
    # par$recdev1[, "recdev"] <- 0
    # par$recdev_early[,"recdev"]<-0
    # SS_writepar_3.30(
    #   parlist = par,
    #   outfile = file.path(ASPM.dir, "ss3.par"),
    #   overwrite = T, verbose = FALSE
    # )
    ## set starter file to read par
    starter <- SS_readstarter(file = file.path(ASPM.dir, "starter.ss"), verbose = FALSE)
    starter$init_values_src <- 0
    SS_writestarter(starter,
                    dir = ASPM.dir,
                    overwrite = TRUE,
                    verbose = FALSE
    )
    ## turn off the likelihood for size, length, and age composition data, and intial F estimation
    control <- SS_readctl_3.30(
      file = file.path(ASPM.dir, model.info$ctl.file.name),
      datlist = file.path(ASPM.dir, model.info$data.file.name),
      verbose = FALSE
    )
    control$size_selex_parms[, "PHASE"] <- control$size_selex_parms[, "PHASE"] * -1
    control$size_selex_parms_tv[,"PHASE"]<-control$size_selex_parms_tv[,"PHASE"] * -1
    control$recdev_early_phase <- -4
    control$recdev_phase <- -2
    control$do_recdev <- 0
    
    new_lambdas <- data.frame(
      like_comp = c(rep(4,model.info$Nfleets), 10), ##assumes one initial F fleet
      fleet = c(1:31,1),
      phase = rep(1, sum(model.info$Nfleets,1)),
      value = rep(0, sum(model.info$Nfleets,1)),
      sizefreq_method = rep(1, sum(model.info$Nfleets,1))
    )
    control$lambdas <- new_lambdas
    control$N_lambdas <- nrow(new_lambdas)
    SS_writectl_3.30(control,
                     outfile = file.path(ASPM.dir, model.info$ctl.file.name),
                     overwrite = TRUE, verbose = FALSE
    )
     run(dir = ASPM.dir, exe = exe, skipfinished = FALSE, verbose = FALSE)
    
  }
}


