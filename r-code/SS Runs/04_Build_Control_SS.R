#  --------------------------------------------------------------------------------------------------------------
#   AMERICAN SAMOA BOTTOMFISH - INITIAL SS CONTROL FILE CREATION
#	Use example model files (from https://github.com/nmfs-stock-synthesis/user-examples) as templates 
#   for adding in American Samoa model parameter information
#	Megumi Oshima megumi.oshima@noaa.gov
#  
#  --------------------------------------------------------------------------------------------------------------
#CTL file 
#  --------------------------------------------------------------------------------------------------------------
Build_Control <- function(species,
                          scenario = "base",
                          Nfleets = Nfleets,
                          Nsexes = Nsexes,
                          CompError = CompError,
                          ctl.inputs = ctl.inputs,
                          ctl.params = ctl.params,
                          includeCPUE = TRUE,
                          Q.options = Q.options,
                          M_option = "Option1",
                          GROWTH_option = "Option1",
                          LW_option = "Option1",
                          MAT_option = "Option1",
                          SR_option = "Option1",
                          EST_option = "Option1",
                          SEL_option = "Option1",
                          size_selex_types = size_selex_types,
                          age_selex_types = age_selex_types,
                          initF = FALSE,
                          lambdas = FALSE,
                          file_dir = "base",
                          template_dir = file.path(root_dir, "SS3 models", "Template_files"),
                          out_dir = out_dir,
                          model.info=model.info){
  
  CTL        <- r4ss::SS_readctl_3.30(file = file.path(template_dir, model.info$templatefiles["control"]), 
                                      datlist = file.path(template_dir, model.info$templatefiles["data"]))  

  
ctl.sps    <- ctl.inputs %>% 
    select(c(Parameter, contains(species))) %>% 
    pivot_wider(names_from = Parameter, 
                values_from = paste0(species))
  
  
  #  --------------------------------------------------------------------------------------------------------------
  ## STEP 2. Update input values
  
   CTL$EmpiricalWAA       <- ctl.sps$EprircalWAA #if want to use wtatage.ss file change to 1
   CTL$N_GP               <- ctl.sps$N_GP
   CTL$N_platoon          <- ctl.sps$N_platoon #number of platoons within growth pattern
   if(CTL$N_platoon>1){
    CTL$sd_ratio          <- ctl.sps$Platoon_SDratio # Platoon within/between standard deviation ratio.
    CTL$submorphdist      <- c(-1, rep(0,CTL$N_platoon-1)) # Distribution of variability among platoons. -1 followed by zero follows normal distribution.
   }
   CTL$recr_dist_method   <- ctl.sps$recr_dist_method #main effects for GP, area, settle timing
   CTL$recr_dist_read     <- ctl.sps$recr_dist_read
   CTL$recr_dist_pattern #dataframe with column names: GPattern, month, area, age. Just need to adjust month if assuming settlement doesn't happen in January. If settlement happens after age 0 need to adjust that too.
   CTL$N_Block_Designs    <- ctl.sps$N_Block_Designs #setting to zero for base model, can add blocks if needed for parameter values
   
   if(CTL$N_Block_Designs>=1) {
     for (i in 1:CTL$N_Block_Designs) {
                     CTL$blocks_per_pattern[i] <- ctl.sps[paste0("blocks_per_pattern_",i)] 
                     CTL$Block_Design[[i]]  <- if(ctl.sps$Block_Design == -1000){
     NULL
   }else{
    BlockYears<-c(ctl.sps[paste0("Block",i,"_Design_Start_",1)], ctl.sps[paste0("Block",i,"_Design_Finish_",1)])
     if(CTL$blocks_per_pattern[[i]]>1){ for (j in 2:CTL$blocks_per_pattern[[i]]){
    BlockYears<-c(BlockYears,ctl.sps[paste0("Block",i,"_Design_Start_",j)], ctl.sps[paste0("Block",i,"_Design_Finish_",j)])
     }
    }
    BlockYears 
   }
     }
   }                            
   
   CTL$time_vary_auto_generation <- c(ctl.sps$time_vary_auto_generation_1,
                                      ctl.sps$time_vary_auto_generation_2,
                                      ctl.sps$time_vary_auto_generation_3,
                                      ctl.sps$time_vary_auto_generation_4,
                                      ctl.sps$time_vary_auto_generation_5)
   # 
    CTL$natM_type         <- ctl.sps$natM_type #give one param value
    if(CTL$natM_type==3){
     for (i in 1:(CTL$Nages+1)){
        if(CTL$Nsexes==1){
      
          CTL$natM[1,i]<-ctl.sps[paste0("Age_",i-1,"_F")]
          #CTL$natM[2,i]<-"#"
      
      } else {
        CTL$natM[1,i]<-ctl.sps[paste0("Age_",i-1,"_F")]
        CTL$natM[2,i]<-ctl.sps[paste0("Age_",i-1,"_M")]
        }
      }
    }
   # 
    CTL$GrowthModel       <- ctl.sps$GrowthModel #von Bert with L1&L2
    CTL$Growth_Age_for_L1 <- ctl.sps$Growth_Age_for_L1
    CTL$Growth_Age_for_L2 <- ctl.sps$Growth_Age_for_L2 #can set to 999 to use as Linf
    CTL$Exp_Decay         <- ctl.sps$Exp_Decay
    
    CTL$SD_add_to_LAA <- ctl.sps$SD_add_to_LAA
    CTL$CV_Growth_Pattern <- ctl.sps$CV_Growth_Pattern # 0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
    
    CTL$maturity_option           <- ctl.sps$maturity_option #length logistic
    CTL$First_Mature_Age          <- ctl.sps$First_Mature_Age
    CTL$fecundity_option          <- ctl.sps$fecundity_option #(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
    CTL$hermaphroditism_option    <- ctl.sps$hermaphroditism_option
    if(CTL$hermaphroditism_option != 0){
      CTL$Herm_season <- ctl.sps$hermaphroditism_season
      CTL$Herm_MalesInSSB <- ctl.sps$hermaphroditism_malesinssb
      
    }
    CTL$parameter_offset_approach <- ctl.sps$parameter_off_approach #no offset
   # 
   ## Growth Parameters
 # 
 # 
   MG <- ctl.params[which(ctl.params$category == "GROWTH" & ctl.params$OPTION == GROWTH_option),]
   LW <- ctl.params[which(ctl.params$category == "LW" & ctl.params$OPTION == LW_option),]
   MAT <- ctl.params[which(ctl.params$category == "MAT" & ctl.params$OPTION == MAT_option),]
   
   if(CTL$natM_type!=3) {
    M <- ctl.params %>% filter(str_detect(category, "M") & OPTION == M_option & str_detect(X1, "NatM"))
   MG_parms <- bind_rows(M, MG, LW, MAT) %>% 
    select(-c(category, OPTION)) %>%
    mutate(sex = ifelse(str_detect(X1, "Fem"), 1, 2),
           sex = ifelse(str_detect(X1, "Herm"), 3, sex),
           sex = ifelse(str_detect(X1, "FracFemale|CohortGrowDev"), 4, sex)) %>% 
    column_to_rownames("X1") %>% 
    arrange(sex) %>% 
    select(-sex)
   } else {
     MG_parms <- bind_rows(MG, LW, MAT) %>% 
       select(-c(category, OPTION)) %>%
       mutate(sex = ifelse(str_detect(X1, "Fem"), 1, 2),
              sex = ifelse(str_detect(X1, "Herm"), 3, sex),
              sex = ifelse(str_detect(X1, "FracFemale|CohortGrowDev"), 4, sex)) %>% 
       column_to_rownames("X1") %>% 
       arrange(sex) %>% 
       select(-sex)
   }
  
  if(CTL$hermaphroditism_option == 0){
    MG_parms <- MG_parms %>% filter(str_detect(rownames(.), "Herm", negate = TRUE))
  }
  
  if(Nsexes != 2){
    MG_parms <- MG_parms %>% filter(str_detect(rownames(.), "Male", negate = TRUE))
  }
    CTL$MG_parms <- MG_parms
  
   CTL$MGparm_seas_effects <- unlist(select(ctl.sps, contains("Mgparm_seas")))
   ## Spawner-Recruitment
   CTL$SR_function         <- ctl.sps$SR_function #beverton holt
   CTL$Use_steep_init_equi <- ctl.sps$Use_steep_init_equi # 1= use in initial equ recruitment calculation
   # Table of parameters with column names: LO, HI, INIT, PRIOR, PR_SD, PR_type, PHASE, env_var&link, dev_link, dev_minyr, dev_maxyr, dev_PH, Block, Block_Fxn
   CTL$SR_parms <- ctl.params %>%
     filter(str_detect(category, "SR")) %>%
     filter(str_detect(OPTION, SR_option)) %>%
     select(-c(category, OPTION)) %>%
     column_to_rownames("X1")
   R0 <- ctl.params[which(ctl.params$X1 == "SR_LN(R0)" & ctl.params$OPTION == EST_option),]
   
   CTL$SR_parms <- R0 %>% select(-c(category, OPTION)) %>%
     column_to_rownames("X1") %>% 
     bind_rows(CTL$SR_parms)
   
   CTL$do_recdev <- ctl.sps$do_recdev
   if(CTL$do_recdev == 1){
  
     CTL$MainRdevYrFirst            <- ctl.sps$MainRdevYrFirst
     CTL$MainRdevYrLast             <- ctl.sps$MainRdevYrLast
     CTL$recdev_phase               <- ctl.sps$recdev_phase
     CTL$recdev_adv                 <- ctl.sps$recdev_adv
     CTL$recdev_early_start         <- ctl.sps$recdev_early_start
     CTL$recdev_early_phase         <- ctl.sps$recdev_early_phase
     CTL$Fcast_recr_phase           <- ctl.sps$Fcast_recr_phase
     CTL$lambda4Fcast_recr_like     <- ctl.sps$lambda4Fcast_recr_like
     CTL$last_early_yr_nobias_adj   <- ctl.sps$last_early_yr_nobias_adj
     CTL$first_yr_fullbias_adj      <- ctl.sps$first_yr_fullbias_adj
     CTL$last_yr_fullbias_adj       <- ctl.sps$last_yr_fullbias_adju
     CTL$first_recent_yr_nobias_adj <- ctl.sps$first_recent_yr_nobias_adj
     CTL$max_bias_adj               <- ctl.sps$max_bias_adj
     CTL$period_of_cycles_in_recr   <- ctl.sps$period_of_cycles_in_recr
     CTL$min_rec_dev                <- ctl.sps$min_rec_dev
     CTL$max_rec_dev                <- ctl.sps$max_rec_dev
     CTL$N_Read_recdevs             <- ctl.sps$N_Read_recdevs
  
   }
  
   ## Fishing Mortality
   CTL$F_ballpark      <- ctl.sps$F_ballpark
   CTL$F_ballpark_year <- ctl.sps$F_ballpark_year #negative year disables this
   CTL$F_Method        <- ctl.sps$F_Method
   if(CTL$F_Method == 2){
     CTL$F_setup <- c(ctl.sps$initialF_Fmethod2, ctl.sps$phase_Fmethod2, ctl.sps$Fdetail)
     
   }
   if(CTL$F_Method == 3){
     CTL$F_iter          <- ctl.sps$F_iter #recommended between 3 and 5
   }
   CTL$maxF            <- ctl.sps$maxF
   
   if(initF == T){
     CTL$init_F <- ctl.params %>% filter(str_detect(X1, "initial_F")) %>% 
       rename("LABEL" = "X1") %>% 
       select(c(LO, HI, INIT, PRIOR, PR_SD, PR_type, PHASE, LABEL)) %>% 
       data.table::as.data.table()
   } else {
     CTL$init_F=NULL
   }
  
   
   ## Catchability
   if(includeCPUE == TRUE){
     # Table with nrow = nfleets and column names: fleet, link, link_info, extra_se, biasadj, and float
     CTL$Q_options <- as.data.frame(Q.options)
     
     CTL$Q_parms <- ctl.params %>%
       filter(str_detect(category, "EST")) %>%
       filter(str_detect(X1, "Q")) %>% 
      # filter(str_detect(OPTION, EST_option)) %>%
       select(-c(category, OPTION)) %>%
       slice_head(n = Nfleets*2) %>% 
       column_to_rownames("X1")
     
   }else{
     CTL$Q_options <- NULL
     CTL$Q_parms <- NULL
   }
  
   # Table of parameters with column names: LO, HI, INIT, PRIOR, PR_SD, PR_type, PHASE, env_var&link, dev_link, dev_minyr, dev_maxyr, dev_PH, Block, Block_Fxn
   
  
   ## Selectivity
   size.parms <- ctl.params %>% 
     filter(str_detect(category, "SEL")) %>% 
     filter(str_detect(X1, fixed("size", ignore_case = TRUE))) %>% 
     nrow()
   
   if(size.parms > 0){
  
     CTL$size_selex_types <- size_selex_types
  
     CTL$size_selex_parms <- ctl.params %>%
       filter(str_detect(category, "SEL")) %>% 
       filter(str_detect(X1, fixed("SizeSel", ignore_case = TRUE))) %>%
       filter(!str_detect(X1, fixed("TV", ignore_case = TRUE))) %>%
       filter(str_detect(OPTION, SEL_option)) %>%
       #slice_head(n = 2) %>% 
       select(-c(category, OPTION, "X1")) %>% 
       as.data.frame()
     # if(Nfleets > 1){
     #   
     #   nn <- (Nfleets * 2) - nrow(CTL$size_selex_parms)
     #   
     #   selex_params_extra <- data.frame(
     #     "LO" = rep(-1, nn),
     #     "HI" = rep(-1, nn),
     #     "INIT" = rep(-1, nn),
     #     "PRIOR" = rep(-1, nn),
     #     "PR_SD" = rep(99, nn),
     #     "PR_type" = rep(0, nn),
     #     "PHASE" = rep(-99, nn),
     #     "env_var" = rep(0, nn),
     #     "use_dev" = rep(0, nn), 
     #     "dev_mnyr" = rep(0, nn),	
     #     "dev_mxyr" = rep(0, nn),
     #     "dev_PH" = rep(0, nn),
     #     "Block"	= rep(0, nn),
     #     "Blk_Fxn" = rep(0, nn)
     #   )
     #   colnames(selex_params_extra) <- colnames(CTL$size_selex_parms)
     #   
     #   CTL$size_selex_parms <- rbind(CTL$size_selex_parms, selex_params_extra)
     #   
     # }
  
   }else{
  
     CTL$size_selex_types <- size_selex_types
     CTL$size_selex_parms <- NULL
  
   }
   
   if (CTL$time_vary_auto_generation[5]==1){
          CTL$size_selex_parms_tv <- ctl.params %>%
         filter(str_detect(category, "EST")) %>% 
         filter(str_detect(X1, fixed("SizeSel", ignore_case = TRUE))) %>%
         filter(str_detect(X1, fixed("TV", ignore_case = TRUE))) %>%
         select(-c(category, OPTION, "X1","env_var&link","dev_link","dev_minyr","dev_maxyr","dev_PH","Block","Block_Fxn")) %>% 
         as.data.frame()
   }
  
   age.parms <- ctl.params %>%filter(str_detect(category, "EST")) %>% 
     filter(str_detect(X1, fixed("age", ignore_case = TRUE))) %>% nrow()
   if(age.parms > 0){
  
     CTL$age_selex_types <- age_selex_types
     CTL$age_selex_parms <- ctl.params %>%
       filter(str_detect(category, "EST")) %>% 
       filter(str_detect(X1, fixed("age", ignore_case = TRUE))) %>%
      # filter(str_detect(OPTION, EST_option)) %>%
       select(-c(category, OPTION, "X1")) %>% 
       as.data.frame()
  
   }else{
  
     CTL$age_selex_types <- age_selex_types
     CTL$age_selex_parms <- NULL
  
   }
  
   # Dirichlet length comp error distribution needs the Theta parameter from the Par sheet
   if(CompError==1){
     
     CTL$dirichlet_parms <- ctl.params %>%
       filter(str_detect(category, "EST")) %>%
       filter(str_detect(X1, "Dirichlet")) %>% 
       filter(str_detect(OPTION, EST_option)) %>%
       select(-c(category, OPTION)) %>%
       slice_head(n = Nfleets*2) %>% 
       column_to_rownames("X1")
   }
   
   
   CTL$Use_2D_AR1_selectivity <- 0 #no 2D_AR1 offset
  
   ## Tagging data
   CTL$TG_custom              <- 0
  
   ## Input variance adjustment
   CTL$DoVar_adjust           <- ctl.sps$DoVar_adjust
   #if 1, need a table with column names: Factor, Fleet, and Value
   if(CTL$DoVar_adjust == 1){
     
     CTL$Variance_adjustment_list <- ctl.sps %>% 
       select(contains("var_adj_")) %>% 
       pivot_longer(cols = everything(), names_to = "var", values_to = "Value") %>% 
       separate(col = var, into = c("var", "adj", "factor", "fleet"), sep = "_") %>% 
       select(-c(var, adj)) %>% 
       as.data.frame() %>%
       na.omit()
     
   }
  
   CTL$maxlambdaphase         <- ctl.sps$maxlambdaphase #max phase of estimation
   #CTL$sd_offset              <- ctl.sps$sd_offset #must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
  
   ## Likelihoods
   # Table with column names: like_comp, fleet, phase, value, and sizefreq_method
   # Only needed if values are different from 1
   if(lambdas == TRUE){
     CTL$lambdas <- ctl.sps %>% 
       select(contains("lambda_")) %>% 
       pivot_longer(cols = everything(), names_to = "name", values_to = "value") %>% 
       separate(name, into = c("lambda", "name", "fleet"), sep = "_") %>% 
       select(-lambda) %>% 
       filter(!is.na(value)) %>% 
       mutate(fleet = ifelse(is.na(fleet), 1, fleet)) %>% 
       pivot_wider(names_from = "name", values_from = "value", names_repair = "minimal") %>% 
       select(-1) %>% 
       as.data.frame()
     
     CTL$N_lambdas <- nrow(CTL$lambdas)
   }else{
     CTL$lambdas <- NULL
     CTL$N_lambdas <- 0
   }
  
   CTL$more_stddev_reporting  <- ctl.sps$more_stddev_reporting
   
 #  --------------------------------------------------------------------------------------------------------------
 ## STEP 3. Save updated control file
  
  r4ss::SS_writectl_3.30(CTL, outfile = file.path(out_dir, model.info$ctl.file.name), overwrite = TRUE)
  
}
  

