*Stata itsa multi-group after Synth script 2006

*Disabling the option more  
set more off

*Creating directory 
cd ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/output_stata

*Importing output from Synth in stata
import delimited ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/output_data_prep/synth_to_itsa2006.csv , clear

*Setting panel time series data for  multiple group analysis 
tsset code year

*Running itsa after Synth pre-processing
itsa value , treat(1) contid(2) trperiod(2006) lag(0)posttrend replace figure

*Testing autoccorelation newey
actest value , lag(6)

