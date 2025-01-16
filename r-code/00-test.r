
# Nicholas Ducharme-Barth
# 2025/01/06
# R code to modify a baseline stock synthesis model
# change steepness and run alternative versions of the model

# Copyright (c) 2025 Nicholas Ducharme-Barth

# load packages
    library(r4ss)

# define paths
	proj_dir = this.path::this.proj()
	dir_model = paste0(proj_dir,"/stock-synthesis-models/")
    dir_base_stock_synthesis = paste0(dir_model,"base-model/")

# read control file
    tmp_ctl = SS_readctl(file=paste0(dir_base_stock_synthesis,"control.ss"),
                         datlist = paste0(dir_base_stock_synthesis,"data.ss"))

# modify
    tmp_ctl$SR_parms["SR_BH_steep","INIT"] = 0.7

# write out file using r4ss functions
    tmp_dir = paste0(dir_model,"test-new-version/")
    dir.create(tmp_dir,recursive=TRUE)
    SS_writectl(tmp_ctl,outfile=paste0(tmp_dir,"control.ss"),overwrite=TRUE)

# copy over executable
    dir_exec = paste0(proj_dir,"/executables/stock-synthesis/3.30.22.1/")
    ss3_exec = "ss3_linux"
    file.copy(from=paste0(dir_exec,ss3_exec),to=tmp_dir)
    file.copy(from=paste0(dir_base_stock_synthesis,c("starter.ss","data.ss","forecast.ss")),to=paste0(tmp_dir,c("starter.ss","data.ss","forecast.ss")))

    
# run the model
    run(dir=tmp_dir,exe=ss3_exec,show_in_console=TRUE,skipfinished=FALSE)

#_____________________________________________________________________________________________________________________________
# analyze in a for loop
    # steepness_vec = c(0.5,0.6,0.7)
    # for(i in seq_along(steepness_vec)){
    #     # make new directory
    #         tmp_dir = paste0(dir_model,"steepness-",steepness_vec[i],"/")
    #         dir.create(tmp_dir,recursive=TRUE)
        
    #     # modify control file
    #     # read in baseline stock synthesis files using r4ss functions
    #         tmp_ctl = SS_readctl(file=paste0(dir_base_stock_synthesis,"control.ss_new"),datlist = paste0(dir_base_stock_synthesis,"data_echo.ss_new"))
    #         tmp_ctl$SR_parms["SR_BH_steep","INIT"] = steepness_vec[i]
        
    #     # write out file using r4ss functions
    #         SS_writectl(tmp_ctl,outfile=paste0(tmp_dir,"control.ss"),overwrite=TRUE)
    #     # copy remaining input files and executable
    #         file.copy(from=paste0(dir_base_stock_synthesis,c("starter.ss_new","data_echo.ss_new","forecast.ss_new")),to=paste0(tmp_dir,c("starter.ss","data.ss","forecast.ss")))
    #         file.copy(from=paste0(dir_exec,ss3_exec),to=tmp_dir)

    #     # run the model
    #         run(dir=tmp_dir,exe=ss3_exec,show_in_console=TRUE,skipfinished=FALSE)

    #     # clean-up workspace
    #     rm(list=c("tmp_dir","tmp_ctl"))
    # }
