#V3.30.23.1;_safe;_compile_date:_Dec  5 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#C starter comment here
data.ss
control.ss
0 # 0=use init values in control file; 1=use ss.par
0 # run display detail (0 = minimal; 1=one line per iter; 2=each logL)
1 # detailed output (0=minimal for data-limited, 1=high (w/ wtatage.ss_new), 2=brief, 3=custom) 
#COND: custom report options: -100 to start with minimal; -101 to start with all; -number to remove, +number to add, -999 to end
0 # write 1st iteration details to echoinput.sso file (0,1) 
0 # write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)
0 # write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)
1 # Include prior_like for non-estimated parameters (0,1) 
1 # Use Soft Boundaries to aid convergence (0,1) (recommended)
#
1 # Number of datafiles to produce:  0 turns off all *.ss_new; 1st is data_echo.ss_new, 2nd is data_expval.ss, 3rd and higher are data_boot_**N.ss,
10 # Turn off estimation for parameters entering after this phase
#
0 # MCeval burn interval
1 # MCeval thin interval
0 # jitter initial parm value by this fraction
1969 # min year for sdreport outputs (-1 for styr); #_1969
2011 # max year for sdreport outputs (-1 for endyr+1; -2 for endyr+Nforecastyrs); #_2011
0 # N individual STD years 
#COND: vector of year values if N>0

0.0001 # final convergence criteria (e.g. 1.0e-04) 
0 # retrospective year relative to end year (e.g. -4)
1 # min age for calc of summary biomass
2 # Depletion basis:  denom is: 0=skip; 1=X*SPBvirgin; 2=X*SPBmsy; 3=X*SPB_styr; 4=X*SPB_endyr; 5=X*dyn_Bzero;  values>=11 invoke N multiyr with 10s & 100s digit; append .1 to invoke log(ratio); e.g. 122.1 produces log(12 year trailing average of B/Bmsy)
1 # Fraction (X) for Depletion denominator (e.g. 0.4)
4 # SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR
3 # F_std_reporting_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Apical_F's); 4=mean F for range of ages (numbers weighted); 5=unweighted mean F for range of ages
#COND 10 15 #_min and max age over which mean F will be calculated with F_reporting=4 or 5
0 # F_std_scaling: 0=no scaling; 1=F/Fspr; 2=F/Fmsy; 3=F/Fbtgt; where F means annual F_std, Fmsy means F_std@msy; values >=11 invoke N multiyr using 10s and 100s digit; append .1 to invoke log(ratio)
0 # MCMC output detail: integer part (0=default; 1=adds obj func components; 2= +write_report_for_each_mceval); and decimal part (added to SR_LN(R0) on first call to mcmc)
0 # ALK tolerance ***disabled in code
-1 # random number seed for bootstrap data (-1 to use long(time) as seed): # 1736195242
3.30 # check value for end of file and for version control