*stata itsa single group script

*disabling the option more  
set more off

*creating directory 
* you will probably have to change that drectory
cd ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1

*importing sugarcane harvested areas data from 1974 to 2018 in stata
import delimited ~/sciebo/PhD.BastosdeCastro/ScientificProduction/Paper1/data_package_paper1/data/ibge/pam_data_1974_2017/sugarcane_harvested_areas_RJ_1974_2017.csv ,  clear

*Renamming variable 
*rename reacolhidahectares harvestedareainhectares
rename sugarcane_harvested_area harvestedareainhectares

*changing label as well
label variable harvestedareainhectares "harvestedareainhectares"

*in case stata recognize numeric values as strings do: 
*destring harvestedareainhectares , replace force

*setting panel time series data for  multiple group analysis 
tsset cod year

*running multiple intervention itsa for a single group 
itsa harvestedareainhectares , single treatid(33) trperiod(1977 1986 1990 1995 2006) lag(0)posttrend replace figure

*testing autoccorelation 
actest , lags(3)
