*Synth for comparative studies analysis 2006

*Disabling the option more  
set more off, permanently 

*creating directory 

cd ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/output_stata

*Importing adjusted tables with covariates in long format
import delimited ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/output_data_prep/UF_multiple_data_tosynth.csv, clear

*In case stata recognize numeric values as strings do: 
destring amount_produced_sugarcane -trucks_farms, replace force

*Setting panel time series data for  multiple group analysis 
tsset cod year

*Checking states and the respective codes 
tabstat cod, by(uf)

*Renamming variable due to a problem with names in stata
rename employed_people labor
rename pasture_hectares pasture_ha
rename trucks_farms trucks
rename livestock_bovines_amount bovines

*Selecting states that does not have NA values
keep if cod != 50 & cod != 53 & cod!= 14 & cod !=17 & cod !=35 & cod !=32

*BEFORE RUNNING SNYTH:
*In case the program does not run the function and returns a message saying it misses a synthopt.plugin do: 
*net from "http://www.mit.edu/~jhainm/Synth";
*net install synth, all replace force

*Running synth 2006 output
*For 2006 the use of control states counit(22 23 24 25 26)worked best
synth harvested_area_sugarcane prec_mswep(1979(1)2017) labor trucks pasture_ha harvested_area_pineapples bovines, trunit(33) trperiod(2006) nested allopt counit(22 23 24 25 26) unitnames(uf) fig  keep(synth2006) replace
*other predictors and their specifications
*pasture_ha(1985&1995&2006&2017) labor(1985&1995&2006&2017) trucks(1985&1995&2006&2017)

*Reading synth 2006 output
use C:/Users/pedroibc/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/output_stata/synth2006.dta, clear

*Exporting synth 2006 output as csv
export delimited synth2006, replace 
