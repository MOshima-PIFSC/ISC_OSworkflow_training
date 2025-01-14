#V3.30.23.00;_safe;_compile_date:_Nov  4 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_Start_time: Mon Dec  2 14:04:04 2024
#_echo_input_data
#C data file for simple example
#V3.30.23.00;_safe;_compile_date:_Nov  4 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
1971 #_StartYr
2001 #_EndYr
1 #_Nseas
 12 #_months/season
2 #_Nsubseasons (even number, minimum is 2)
1 #_spawn_month
2 #_Nsexes: 1, 2, -1  (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)
40 #_Nages=accumulator age, first age is always age 0
1 #_Nareas
3 #_Nfleets (including surveys)
#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=predator(M2) 
#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)
#_fleet_area:  area the fleet/survey operates in 
#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)
#_catch_mult: 0=no; 1=yes
#_rows are fleets
#_fleet_type fishery_timing area catch_units need_catch_mult fleetname
 1 -1 1 1 0 FISHERY  # 1
 3 1 1 2 0 SURVEY1  # 2
 3 1 1 2 0 SURVEY2  # 3
#Bycatch_fleet_input_goes_next
#a:  fleet index
#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)
#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years
#d:  F or first year of range
#e:  last year of range
#f:  not used
# a   b   c   d   e   f 
#_Catch data: year, seas, fleet, catch, catch_se
#_catch_se:  standard error of log(catch)
#_NOTE:  catch data is ignored for survey fleets
-999 1 1 0 0.01
1971 1 1 0 0.2
1972 1 1 168.234 0.2
1973 1 1 1027.69 0.2
1974 1 1 1238.9 0.2
1975 1 1 2346.55 0.2
1976 1 1 3090.62 0.2
1977 1 1 5280.69 0.2
1978 1 1 5294.63 0.2
1979 1 1 5696.77 0.2
1980 1 1 6549.98 0.2
1981 1 1 11124.5 0.2
1982 1 1 10829.7 0.2
1983 1 1 9141.23 0.2
1984 1 1 10176.9 0.2
1985 1 1 12899.9 0.2
1986 1 1 10157.2 0.2
1987 1 1 5955.09 0.2
1988 1 1 6216.55 0.2
1989 1 1 9293.98 0.2
1990 1 1 7257.9 0.2
1991 1 1 4322.24 0.2
1992 1 1 3137.72 0.2
1993 1 1 4715.74 0.2
1994 1 1 3853.94 0.2
1995 1 1 4711.64 0.2
1996 1 1 4041.5 0.2
1997 1 1 3258.78 0.2
1998 1 1 2510.05 0.2
1999 1 1 1892.36 0.2
2000 1 1 2085.93 0.2
2001 1 1 3504.75 0.2
-9999 0 0 0 0
#
#_CPUE_and_surveyabundance_and_index_observations
#_units: 0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=exp(recdev); 36=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)
#_errtype:  -1=normal; 0=lognormal; 1=lognormal with bias correction; >1=df for T-dist
#_SD_report: 0=not; 1=include survey expected value with se
#_note that link functions are specified in Q_setup section of control file
#_dataunits = 36 and 35 should use Q_type 5 to provide offset parameter
#_fleet units errtype SD_report
1 1 0 0 # FISHERY
2 1 0 1 # SURVEY1
3 0 0 0 # SURVEY2
#_year month fleet obs stderr
1977 7 2 220339 0.3 #_ SURVEY1
1980 7 2 130788 0.3 #_ SURVEY1
1983 7 2 76162.5 0.3 #_ SURVEY1
1986 7 2 136587 0.3 #_ SURVEY1
1989 7 2 50024.4 0.3 #_ SURVEY1
1992 7 2 42777.8 0.3 #_ SURVEY1
1995 7 2 36247.7 0.3 #_ SURVEY1
1998 7 2 29376.5 0.3 #_ SURVEY1
2001 7 2 30832 0.3 #_ SURVEY1
1990 7 3 9.38429 0.7 #_ SURVEY2
1991 7 3 3.40078 0.7 #_ SURVEY2
1992 7 3 2.52159 0.7 #_ SURVEY2
1993 7 3 2.99565 0.7 #_ SURVEY2
1994 7 3 1.49053 0.7 #_ SURVEY2
1995 7 3 2.37793 0.7 #_ SURVEY2
1996 7 3 3.59249 0.7 #_ SURVEY2
1997 7 3 2.50434 0.7 #_ SURVEY2
1998 7 3 3.15164 0.7 #_ SURVEY2
1999 7 3 9.84062 0.7 #_ SURVEY2
2000 7 3 6.0189 0.7 #_ SURVEY2
2001 7 3 2.00594 0.7 #_ SURVEY2
-9999 1 1 1 1 # terminator for survey observations 
#
0 #_N_fleets_with_discard
#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)
#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV
# note: only enter units and errtype for fleets with discard 
# note: discard data is the total for an entire season, so input of month here must be to a month in that season
#_fleet units errtype
# -9999 0 0 0.0 0.0 # terminator for discard data 
#
0 #_use meanbodysize_data (0/1)
#_COND_0 #_DF_for_meanbodysize_T-distribution_like
# note:  type=1 for mean length; type=2 for mean body weight 
#_year month fleet part type obs stderr
#  -9999 0 0 0 0 0 0 # terminator for mean body size data 
#
# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage
2 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector
2 # binwidth for population size comp 
10 # minimum size in the population (lower edge of first bin and size at age 0.00) 
94 # maximum size in the population (lower edge of last bin) 
1 # use length composition data (0/1/2) where 2 invokes new comp_control format
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined sex below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_Using old format for composition controls
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
0 1e-07 0 0 0 0 1 #_fleet:1_FISHERY
0 1e-07 0 0 0 0 1 #_fleet:2_SURVEY1
0 1e-07 0 0 0 0 1 #_fleet:3_SURVEY2
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sex*length distribution
# partition codes:  (0=combined; 1=discard; 2=retained
25 #_N_LengthBins; then enter lower edge of each length bin
 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 68 72 76 80 90
#_year month fleet sex part Nsamp datavector(female-male)
 1971 7 1 3 0 75 0 0 0 0 0 0 0 0 0 2 3 1 1 0 1 5 2 1 2 11 6 1 4 0 0 0 0 0 0 0 0 0 0 2 0 0 3 0 0 1 3 2 3 6 8 4 1 2 0 0
 1972 7 1 3 0 75 0 0 0 0 0 0 0 0 0 1 0 1 1 1 2 3 3 2 3 4 4 3 1 2 0 0 0 0 0 0 0 0 0 1 0 0 1 1 0 2 4 0 6 2 7 5 10 5 0 0
 1973 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 0 0 3 3 3 1 3 3 5 8 5 8 5 0 0 0 0 0 0 0 0 0 0 0 0 0 2 0 1 0 2 3 2 1 7 3 3 2 2 0
 1974 7 1 3 0 75 0 0 0 0 0 0 0 0 0 2 0 1 1 1 0 1 1 4 0 8 5 7 7 0 0 0 0 0 0 0 0 0 1 1 0 1 0 2 2 2 0 2 4 1 9 2 3 3 4 0
 1975 7 1 3 0 75 0 0 0 0 0 0 0 2 1 0 0 2 1 0 1 3 4 2 4 10 9 5 4 0 0 0 0 0 0 0 0 0 0 0 1 1 0 2 1 2 2 4 0 5 3 3 2 1 0 0
 1976 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 3 4 6 9 5 2 5 0 0 0 0 0 0 0 0 1 1 1 0 0 1 2 2 2 2 4 6 2 4 6 2 2 0 0
 1977 7 1 3 0 75 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 1 0 3 2 4 3 11 3 3 0 0 0 0 0 0 1 1 0 1 2 1 2 0 5 3 2 0 1 4 10 3 2 4 0 0
 1978 7 1 3 0 75 0 0 0 0 0 0 1 0 1 1 1 0 0 0 1 2 1 1 3 4 4 5 2 4 0 0 0 0 0 0 0 0 2 1 0 1 0 3 1 0 3 6 4 2 12 4 4 1 0 0
 1979 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 3 1 0 3 1 1 2 2 3 7 4 2 6 1 0 0 0 0 0 0 0 0 0 0 0 2 1 1 3 3 0 0 2 2 10 9 4 0 2 0
 1980 7 1 3 0 75 0 0 0 0 0 0 0 2 0 0 2 1 3 3 3 2 3 5 4 1 7 3 4 0 0 0 0 0 0 0 0 0 0 2 0 3 1 0 1 2 1 5 1 2 7 2 3 2 0 0
 1981 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 0 3 1 1 2 1 3 3 3 6 6 2 6 0 0 0 0 0 0 0 0 1 0 0 2 0 0 2 1 1 2 1 3 4 4 11 3 3 0 0
 1982 7 1 3 0 75 0 0 0 0 0 0 0 0 1 0 2 1 1 3 3 6 1 4 5 8 6 4 0 0 0 0 0 0 0 0 0 0 0 0 1 2 2 2 3 3 0 2 1 1 4 4 1 4 0 0
 1983 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 4 1 3 2 2 2 3 2 1 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 4 0 1 0 3 2 2 2 4 4 6 1 2 3 0 0
 1984 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 1 1 0 3 1 5 3 4 3 7 5 7 2 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 4 1 2 4 4 1 5 3 2 5 0 0
 1985 7 1 3 0 75 0 0 0 0 0 0 0 0 0 0 1 2 1 3 3 3 4 3 1 12 6 2 5 0 0 0 0 0 0 0 0 0 2 2 0 2 2 0 1 2 2 2 1 2 1 8 2 0 0 0
 1986 7 1 3 0 75 0 0 0 0 1 1 0 0 0 0 1 0 2 3 2 3 4 4 2 8 5 0 2 0 0 0 0 0 0 0 0 1 0 1 0 1 1 2 1 2 4 1 3 5 7 3 2 3 0 0
 1987 7 1 3 0 75 0 0 0 0 0 0 1 0 0 3 2 1 1 6 1 3 3 2 4 6 3 6 0 0 0 0 0 0 0 0 0 0 3 0 1 0 2 3 4 3 3 3 0 2 2 2 2 3 0 0
 1988 7 1 3 0 75 0 0 0 0 0 0 0 0 4 1 1 2 1 2 0 3 3 2 1 3 6 4 3 0 0 0 0 0 0 0 1 0 1 3 1 4 0 1 3 4 5 2 2 3 2 3 4 0 0 0
 1989 7 1 3 0 75 0 0 0 0 0 0 0 1 1 0 2 2 3 3 1 5 2 0 2 9 2 2 1 0 0 0 0 0 0 0 0 4 1 1 2 2 0 0 2 6 2 4 3 2 5 4 1 0 0 0
 1990 7 1 3 0 75 0 0 0 0 0 0 0 3 0 2 2 3 1 1 3 4 2 4 0 1 1 3 1 0 0 0 0 0 0 0 2 1 3 1 2 3 2 5 3 3 4 3 0 1 6 0 4 1 0 0
 1991 7 1 3 0 75 0 0 0 0 0 0 0 5 2 0 2 1 3 5 1 4 6 0 1 2 0 3 0 0 0 0 0 0 0 0 0 0 0 1 3 2 3 3 1 1 4 3 3 4 6 1 5 0 0 0
 1992 7 1 3 0 75 0 0 0 0 2 0 2 2 0 1 1 1 3 3 4 4 0 0 2 7 5 3 0 0 0 0 0 0 0 0 0 0 3 0 2 3 4 3 0 2 3 4 2 1 1 5 2 0 0 0
 1993 7 1 3 0 75 0 0 0 0 0 0 0 1 1 0 2 1 3 2 5 4 2 2 0 6 1 6 0 0 0 0 0 0 0 0 0 0 2 1 3 2 1 3 0 4 5 2 4 4 4 3 0 1 0 0
 1994 7 1 3 0 75 0 0 0 0 0 0 0 0 0 4 2 1 2 3 6 6 5 1 0 6 3 2 2 0 0 0 0 0 0 0 0 0 1 0 3 0 1 2 3 4 3 2 3 1 3 2 2 2 0 0
 1995 7 1 3 0 75 0 0 0 1 0 1 0 0 0 0 1 1 4 1 3 2 5 4 2 3 9 0 0 0 0 0 0 0 0 2 0 0 0 1 3 0 0 3 4 2 3 4 4 1 5 2 4 0 0 0
 1996 7 1 3 0 75 0 0 0 0 0 0 1 0 0 1 1 1 1 4 6 2 5 2 3 4 2 4 0 0 0 0 0 0 0 0 0 0 0 0 2 1 0 1 3 6 3 3 7 3 5 1 1 2 0 0
 1997 7 1 3 0 75 0 0 0 1 0 0 0 0 1 0 0 1 3 1 2 2 2 8 2 6 3 0 0 0 0 0 0 0 0 0 2 1 1 1 1 4 2 2 2 3 3 2 4 1 3 8 3 0 0 0
 1998 7 1 3 0 75 0 0 0 0 2 1 0 2 0 0 1 0 1 2 1 3 3 4 2 5 3 3 0 0 0 0 0 0 0 2 0 0 0 3 1 3 4 2 2 2 2 2 2 1 6 6 2 2 0 0
 1999 7 1 3 0 75 0 0 0 0 1 0 3 3 2 3 0 1 1 1 6 4 2 2 2 3 4 4 0 0 0 0 0 0 0 0 0 2 2 0 1 3 0 0 1 1 2 4 2 1 6 4 4 0 0 0
 2000 7 1 3 0 75 0 0 0 0 0 3 1 1 1 2 0 1 1 3 8 0 3 1 1 1 7 0 0 0 0 0 0 0 0 0 1 0 2 0 3 5 2 3 4 3 2 3 3 1 4 2 2 1 0 0
 2001 7 1 3 0 75 0 0 0 0 3 1 0 3 5 1 1 2 0 3 1 3 9 2 3 8 1 2 0 0 0 0 0 0 0 0 2 1 1 0 1 4 3 0 1 2 2 3 1 0 2 3 1 0 0 0
 1977 7 2 3 0 100 0 0 0 0 3 1 1 1 1 6 1 3 4 3 1 5 5 2 2 4 4 4 0 0 0 0 0 0 0 0 0 2 2 3 3 1 3 2 1 3 4 4 2 4 3 8 2 2 0 0
 1980 7 2 3 0 100 0 0 0 0 0 3 2 2 4 1 2 3 5 2 3 0 5 2 4 5 1 4 4 0 0 0 0 0 0 1 4 2 0 3 3 1 2 2 4 5 2 1 2 2 4 3 4 3 0 0
 1983 7 2 3 0 100 0 0 0 0 0 0 3 4 3 4 1 2 1 4 2 4 1 4 4 5 7 3 0 0 0 0 0 0 0 2 1 4 1 1 2 1 4 1 6 2 4 4 2 0 3 10 0 0 0 0
 1986 7 2 3 0 100 0 0 0 0 1 2 1 1 2 0 2 3 0 3 3 2 4 2 3 3 4 0 1 0 0 0 0 0 1 2 4 3 1 2 3 4 4 3 2 4 4 2 3 4 4 6 7 0 0 0
 1989 7 2 3 0 100 0 0 0 0 0 8 2 5 3 7 4 5 1 3 3 2 3 2 1 1 1 3 0 0 0 0 0 0 1 1 2 5 1 2 2 2 2 4 4 3 3 3 1 3 7 0 0 0 0 0
 1992 7 2 3 0 100 0 0 0 0 0 2 3 2 4 3 7 0 0 1 6 4 1 3 1 1 6 0 0 0 0 0 0 0 0 0 2 0 5 1 4 5 4 5 4 5 2 6 4 3 4 0 2 0 0 0
 1995 7 2 3 0 100 0 0 0 0 0 2 1 2 2 0 2 5 4 6 5 3 6 2 3 5 4 2 0 0 0 0 0 0 0 0 0 3 0 5 1 0 5 4 1 5 3 3 2 2 3 5 4 0 0 0
 1998 7 2 3 0 100 0 0 0 3 3 3 2 3 1 2 5 1 1 2 2 1 1 5 2 5 3 3 0 0 0 0 0 0 0 8 0 3 1 3 4 5 2 3 1 3 4 3 2 4 4 1 1 0 0 0
 2001 7 2 3 0 100 0 0 0 0 0 1 0 1 5 3 9 5 3 5 4 2 2 4 3 3 2 0 0 0 0 0 0 0 0 4 4 1 0 3 5 4 6 3 3 2 2 1 0 5 1 4 0 0 0 0
-9999 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
#
0 #_N_age_bins
# 0 #_N_ageerror_definitions
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined sex below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
# 0 0 0 0 0 0 0 #_fleet:1_FISHERY
# 0 0 0 0 0 0 0 #_fleet:2_SURVEY1
# 0 0 0 0 0 0 0 #_fleet:3_SURVEY2
# 0 #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sex*length distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_year month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)
# -9999  0 0 0 0 0 0 0 0
#
0 #_Use_MeanSize-at-Age_obs (0/1)
#
0 #_N_environ_variables
# -2 in year will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)
#_year variable value
#
# Sizefreq data. Defined by method because a fleet can use multiple methods
0 # N sizefreq methods to read (or -1 for expanded options)
# 
0 # do tags (0/1/2); where 2 allows entry of TG_min_recap
#
0 #    morphcomp data(0/1) 
#  Nobs, Nmorphs, mincomp
#_year, seas, type, partition, Nsamp, datavector_by_Nmorphs
#
0  #  Do dataread for selectivity priors(0/1)
#_year, seas, fleet, age/size, bin, selex_prior, prior_sd
# feature not yet implemented
#
999

