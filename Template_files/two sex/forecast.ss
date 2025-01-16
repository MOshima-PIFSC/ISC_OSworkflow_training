#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#C  generic forecast file
# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy; 3=add F_Blimit; 
2 # Do_MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr); 5=calc F(MEY) with MSY_unit options
# if Do_MSY=5, enter MSY_Units; then list fleet_ID, cost/F, price/mt, include_in_Fmey_scaling; # -fleet_ID to fill; -9999 to terminate
0.3 # SPR target (e.g. 0.40)
0.191 # Biomass target (e.g. 0.40)
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF, beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
 2021 2021 2021 2021 2021 2021 1975 2021 1975 2021
#  2021 2021 2021 2021 2021 2021 1975 2021 1975 2021
# value <0 convert to endyr-value; except -999 converts to start_yr; must be >=start_yr and <=endyr
1 #Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
#
2 # Forecast: -1=none; 0=simple_1yr; 1=F(SPR); 2=F(MSY) 3=F(Btgt) or F0.1; 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
# where none and simple require no input after this line; simple sets forecast F same as end year F
1 # N forecast years 
1 # Fmult (only used for Do_Forecast==5) such that apical_F(f)=Fmult*relF(f)
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_mean recruits, end_recruits  (enter actual year, or values of 0 or -integer to be rel. endyr)
 0 0 0 0 0 0
#  0 0 0 0 0 0
0 # Forecast selectivity (0=fcast selex is mean from year range; 1=fcast selectivity from annual time-vary parms)
0 # Control rule method (0: none; 1: ramp does catch=f(SSB), buffer on F; 2: ramp does F=f(SSB), buffer on F; 3: ramp does catch=f(SSB), buffer on catch; 4: ramp does F=f(SSB), buffer on catch) 
# values for top, bottom and buffer exist, but not used when Policy=0
0.001 # Control rule inflection for constant F (as frac of Bzero, e.g. 0.40); must be > control rule cutoff, or set to -1 to use Bmsy/SSB_unf 
0.0001 # Control rule cutoff for no F (as frac of Bzero, e.g. 0.10) 
1 # Buffer:  enter Control rule target as fraction of Flimit (e.g. 0.75), negative value invokes list of [year, scalar] with filling from year to YrMax 
2 #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
1 #_First forecast loop with stochastic recruitment
0 #_Forecast recruitment:  0= spawn_recr; 1=value*spawn_recr_fxn; 2=value*VirginRecr; 3=recent mean from yr range above (need to set phase to -1 in control to get constant recruitment in MCMC)
1 # value is ignored 
0 #_Forecast loop control #5 (reserved for future bells&whistles) 
2022  #FirstYear for caps and allocations (should be after years with fixed inputs) 
0 # stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)
0 # Do West Coast gfish rebuilder output: 0=no; 1=yes 
2021 # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
2021 # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
1 # fleet relative F:  1=use first-last alloc year; 2=read seas, fleet, alloc list below
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum); NOTE: same units for all fleets
# Conditional input if relative F choice = 2
# enter list of:  season,  fleet, relF; if used, terminate with season=-9999
# 1 1 0.0967104
# 1 2 0.00664817
# 1 3 0.0245864
# 1 4 0.0500476
# 1 7 0.0113969
# 1 9 0.00337685
# 1 12 0.0116159
# 1 14 0.0169648
# 1 15 0.000311896
# 1 16 0.00151149
# 1 18 0.00887887
# 1 19 0.0533869
# 2 1 0.0696601
# 2 2 0.00665663
# 2 3 0.0164619
# 2 4 0.0496123
# 2 7 0.0113594
# 2 9 0.0133715
# 2 12 0.0117095
# 2 14 0.0171015
# 2 15 0.000312292
# 2 16 0.00151342
# 2 18 0.00636625
# 2 19 0.0558379
# 3 1 0.0525958
# 3 2 0.00662604
# 3 4 0.0473108
# 3 7 0.0112607
# 3 9 0.00599455
# 3 12 0.0117531
# 3 14 0.0171652
# 3 15 0.000310857
# 3 16 0.00150646
# 3 18 0.000549166
# 3 19 0.0251173
# 4 1 0.141147
# 4 2 0.00661319
# 4 3 0.00298043
# 4 4 0.0481759
# 4 7 0.0111892
# 4 9 0.00564175
# 4 12 0.011851
# 4 14 0.0173082
# 4 15 0.000310255
# 4 16 0.00150354
# 4 18 0.000760313
# 4 19 0.0269301
# -9999 0 0  # terminator for list of relF
# enter list of: fleet number, max annual catch for fleets with a max; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
1 0
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
#_if N allocation groups >0, list year, allocation fraction for each group 
# list sequentially because read values fill to end of N forecast
# terminate with -9999 in year field 
# no allocation groups
#
2 # basis for input Fcast catch: -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input apical_F; NOTE: bio vs num based on fleet's catchunits
#enter list of Fcast catches or Fa; terminate with line having year=-9999
#_Yr Seas Fleet Catch(or_F)
-9999 1 1 0 
#
999 # verify end of input 
