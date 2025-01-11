#  --------------------------------------------------------------------------------------------------------------
#   AMERICAN SAMOA BOTTOMFISH - INITIAL SS FILE CREATION
#	Use example model files (from https://github.com/nmfs-stock-synthesis/user-examples) as templates 
#   for adding in American Samoa data
#	Megumi Oshima megumi.oshima@noaa.gov
#  
#  --------------------------------------------------------------------------------------------------------------
## DAT file
#  --------------------------------------------------------------------------------------------------------------
Build_Data <- function(catch = NULL, 
                       initF = F, 
                       CPUEinfo = NULL, 
                       cpue = NULL, 
                     Narea = 1, 
                     CompError = NULL,
                     Nages = 15,
                     lencomp = NULL, 
                     startyr = 1967, 
                     endyr = 2021, 
                      bin.list = NULL, 
                     fleets = 1, 
                     fleetinfo = NULL, 
                     lbin_method = 2, 
                     superyear = FALSE, 
                      superyear_blocks = NULL, 
                     file_dir = "base",
                      template_dir = file.path(root_dir, "SS3 models", "TEMPLATE_FILES"), 
                      out_dir = file.path(root_dir, "SS3 models"),
                     model.info=model.info){
  
  nfleet <- length(model.info$fleets)
  
  ## STEP 2. Read in SS dat file
  DAT <- r4ss::SS_readdat_3.30(file = file.path(template_dir, model.info$templatefiles$data))
  
  ## STEP 3. Get data in correct format and subset
  if(is.null(catch)){ stop("Timeseries of catch is missing")
} 
  DAT$catch <- as.data.frame(catch)
  if (model.info$Species=="SWO"|model.info$Species=="BUM"|model.info$Species=="MLS"){
    DAT$N_lbins     <- length(select(lencomp, starts_with("X")))/2
    lencomp$Yr<-as.integer(lencomp$Yr)
    names(lencomp)[c(1:6)]<-c("Yr","Seas","FltSvy","Gender","Part","Nsamp")
    names(lencomp)<-gsub("X","f",names(lencomp))
    names(lencomp)[grep(".1$",names(lencomp))]<-gsub("f","m",names(lencomp)[grep(".1$",names(lencomp))])
    names(lencomp)<-gsub(".1$","",names(lencomp))
    
    lencomp.sp=lencomp[which(complete.cases(lencomp)==TRUE),]
  }
  ## STEP 4. Change inputs for dat file
  
  DAT$Comments        <- paste("#C data file for", model.info$Species, sep = " ")
  DAT$styr            <- startyr
  DAT$endyr           <- endyr
  DAT$nseas           <- model.info$nseas
  DAT$Nages           <- Nages
  DAT$months_per_seas <- rep(12/model.info$nseas,model.info$nseas)
  DAT$Nsubseasons     <- 2 #minimum number is 2
  DAT$spawn_month     <- model.info$spawn_month
  DAT$Nsexes          <- model.info$Nsexes #1 ignore fraction female in ctl file, 2 use frac female in ctl file, -1 one sex and multiply spawning biomass by frac female
  DAT$Ngenders        <- NULL
  DAT$N_areas         <- Narea #if want to explore fleets as areas, change this 
  DAT$Nfleets         <- nfleet  #include fishing fleets and surveys
  ## specify the fleet types, timing, area, units, any catch multiplier and fleet name in fleetinfo
  DAT$fleetinfo <- fleetinfo

  ## Add CPUE info, column names: Fleet, Units, Errtype, SD_Report
  DAT$CPUEinfo <- as.data.frame(cpueinfo)
  
#  if(exists("cpue")){

    ## ADD CPUE data, column names: year, seas, index, obs, se_log
    DAT$CPUE <- as.data.frame(cpue)

  # }else{
  #   message("No CPUE to input")
  #   DAT$CPUE <- NULL
  # }
  # 
  if(exists("discards.sp")){
    DAT$N_discard_fleets <- unique(discards.sp$fleet)
    DAT$discard <- discards.sp
  }else{
    message("No discards to input")
    ## Any discard fleets?
    DAT$N_discard_fleets <- 0
    DAT$discard <- NULL
    
  }
  
  ## Composition data
  
  if(exists("lencomp.sp")){
    
    ## Length Composition 
    if(CompError==0){
    if(DAT$Nsexes==1){
      DAT$len_info    <- data.frame(mintailcomp = rep(-0.005, DAT$Nfleets),
                               addtocomp      = rep(0.001, DAT$Nfleets),
                               combine_M_F    = rep(1, DAT$Nfleets),
                               CompressBins   = rep(0, DAT$Nfleets),
                               CompError      = rep(0, DAT$Nfleets),
                               ParmSelect     = rep(0, DAT$Nfleets),
                               minsamplesize  = rep(1, DAT$Nfleets))
    } else {
      DAT$len_info    <- data.frame(mintailcomp = rep(-0.005, DAT$Nfleets),
                                    addtocomp      = rep(0.001, DAT$Nfleets),
                                    combine_M_F    = rep(0, DAT$Nfleets),
                                    CompressBins   = rep(0, DAT$Nfleets),
                                    CompError      = rep(0, DAT$Nfleets),
                                    ParmSelect     = rep(0, DAT$Nfleets),
                                    minsamplesize  = rep(1, DAT$Nfleets))
    } 
    
      } else if (CompError==1){
        if (DAT$Nsexes==1){
    DAT$len_info    <- data.frame(mintailcomp = rep(-0.005, DAT$Nfleets),
                               addtocomp      = rep(0.001, DAT$Nfleets),
                               combine_M_F    = rep(1, DAT$Nfleets),
                               CompressBins   = rep(0, DAT$Nfleets),
                               CompError      = rep(1, DAT$Nfleets),
                               ParmSelect     = rep(1, DAT$Nfleets),
                               minsamplesize  = rep(1, DAT$Nfleets))  
        } else {
          DAT$len_info    <- data.frame(mintailcomp = rep(-0.005, DAT$Nfleets),
                                        addtocomp      = rep(0.001, DAT$Nfleets),
                                        combine_M_F    = rep(0, DAT$Nfleets),
                                        CompressBins   = rep(0, DAT$Nfleets),
                                        CompError      = rep(1, DAT$Nfleets),
                                        ParmSelect     = rep(1, DAT$Nfleets),
                                        minsamplesize  = rep(1, DAT$Nfleets))  
    }
      }
   
  
    DAT$lbin_vector<-seq(BIN.LIST$min,BIN.LIST$max,BIN.LIST$BINWIDTH)
    
    ## Add length composition data, column names: Yr, Seas, FltSVy, Gender, Part, Nsamp, length_bin_values...
    DAT$lencomp     <- as.data.frame(lencomp.sp)
    DAT$N_lbins <- length(DAT$lbin_vector)
    
  } else{
    
    message("No length composition to input")
    DAT$use_lencomp <- 0
    DAT$lencomp <- NULL
  }
  
  ## Age Composition
  if(exists("age.comp.sp")){
    
    DAT$N_agebins              <- length(agebin_vector)
    DAT$agebin_vector          <- agebin_vector
    DAT$N_ageerror_definitions <- 1
    DAT$ageerror               <- ageerror # vectors for each definition of mean age and sd associated with the mean age for each age
    ## Dataframe with column names: mintailcomp, addtocomp, combine_M_F, CompressBins, CompError, ParmSelect, minsamplesize
    DAT$age_info
    DAT$Lbin_method            <- model.info$lbin_method #Lbin_method_for_Age_Data, 1 = poplenbins, 2 = datalenbins, 3 = lengths
    DAT$agecomp                <- age.comp
    
  }else{
    
    message("No age composition to input")
    DAT$N_agebins              <- 0
    DAT$agecomp <- NULL
    
  }
  
  ## Mean size-at-age 
  if(exists("size.comp.sp")){
    
    DAT$use_MeanSize_at_Age_obs  <- 1
    DAT$MeanSize_at_Age_obs    <- mean.size.at.age # dataframe with column names: Yr, Seas, FltSvy, Gender, Part, AgeErr, Ignore, age_bins..
    
  }else{
    
    message("No size composition to input")
    DAT$use_MeanSize_at_Age_obs <- 0
    DAT$MeanSize_at_Age_obs <- NULL
    
  }
  
  
  DAT$use_meanbodywt           <- 0
  ## Population length bins
  ## method options include 
  ##      1: use data bins, no other input necessary
  ##      2: generate from bin width, min, and max, specify those values 
  ##      3: read values for length bins, specify number of length bins then lower edges of each bin
  DAT$lbin_method <- lbin_method 
  if(DAT$lbin_method == 2){
    
    DAT$binwidth     <- BIN.LIST$BINWIDTH
    DAT$minimum_size <- BIN.LIST$min #lower size of first bin
    DAT$maximum_size <- BIN.LIST$max #lower size of largest bin 
    
    
  }
  if(DAT$lbin_method == 3){
    
    DAT$N_lbinspop      <- length(pop.length.bins)
    DAT$lbin_vector_pop <- pop.length.bins #seq(start_bin, end_bin, by = 2)
    
  }
  
  
  ## Environmental variables 
  DAT$N_environ_variables    <- 0
  ## Generalized size comp data
  DAT$N_sizefreq_methods     <- 0
  ## Tagging data
  DAT$do_tags                <- 0 
  ## Morph composition data
  DAT$morphcomp_data         <- 0
  ## Selectivity empirical data (future feature)
  DAT$use_selectivity_priors <- 0
  
  ## STEP 5. Save new dat file
  r4ss::SS_writedat_3.30(DAT, outfile = file.path(out_dir,model.info$data.file.name), 
                         overwrite = TRUE, verbose = FALSE)
  
}

