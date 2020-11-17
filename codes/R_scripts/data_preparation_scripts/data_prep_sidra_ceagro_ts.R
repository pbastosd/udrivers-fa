#'---
#' author: Pedro Castro
#' title:  Script for CEAGRO data preparation and Time-series integration
#' date: 04. December 2019 (updated on 23.07.2020)
#'---

#' The Script contains two functions for adjusting CEAGRO data and to bult an up to date time-series for SYNTH analysis 
#' The funcions are sidra_prep_wide_to_long and ceagro_2017_adj

#' The function sidra_prep_wide_to_long was developed for the case the sidra tables were download in wide format
#' For tables download in long format use the script data_prep_sidra
#' The function was used to prepare the time-series CEAGRO data until 2006 exported in wide format
#' New released data from the CEAGRO 2017 was prepared using the script Ceagro_2017_data_prep
#' The results from the function sidra_prep_wide_to_long will be combined with the output of the function ceagro_2017_adj
#' The table resulting of this combination will be in long format, as all other tables
#' The long format tables will be combined to created the input table for the SYNTH analsysis in Stata 13

#' Function sidra_prep_wide_to_long returns a long format dataframe 
#' The dataframe returned by the function has to be combined (rbind) with the output of the ceagro_2017_adj dataframe 
sidra_prep_wide_to_long <- function(xls_sidra_path, var_name=var_name, skipped=3){
  require("readxl")
  require("dplyr")
  require("tidyverse")
  sidra_xls<-read_excel(xls_sidra_path, skip = skipped)
  sidra_xls<- sidra_xls[1:dim(sidra_xls)[1]-1,]
  sidra_xls[3:ncol(sidra_xls)] <- sapply(sidra_xls[3:ncol(sidra_xls)], as.numeric)
  colnames(sidra_xls)[1:2]<- c("cod", "uf")
  cod_ufs <- unique(sidra_xls$cod)
  ceagro_uf_long <-NULL
  var_name <- paste0(strsplit(sub('\\.xlsx$', '', basename(xls_sidra_path)), "-")[[1]][2],"_", strsplit(sub('\\.xlsx$', '', basename(xls_sidra_path)), "-")[[1]][3])
  for (i in seq_along(cod_ufs)){
    sidra_uf <- sidra_xls%>%
      filter(cod==unique(sidra_xls$cod)[i])%>%
      dplyr::select(-"cod", -"uf")%>%
      pivot_longer(everything(), names_to="years", 
                   values_to =var_name)
    sidra_uf$uf <-unique(sidra_xls$uf)[i]
    sidra_uf$cod <-unique(sidra_xls$cod)[i]
    ceagro_uf_long <- rbind(ceagro_uf_long, sidra_uf)
  }
  sidra_uf_long <-  dplyr::select(ceagro_uf_long, "cod", "uf", everything())
  return(sidra_uf_long)
}
ceagro_labor_1975_2006 <- sidra_prep_wide_to_long("data/ibge/ceagro_data/UF_ceagro-employed-people-farms-1975-2006.xlsx")
ceagro_trucks_1975_2006 <- sidra_prep_wide_to_long("data/ibge/ceagro_data/UF_ceagro-trucks-in-farms-1975-2006.xlsx")

#' Function ceagro_2017_adj reads xlsx file from CEAGRO 2017 extracted from IBGE SIDRA platform 
#' The output of the function is a long format table
#' The function is designed for tables with a with  three columns: cod;  UF_names; one measured variable
#' The output is designed to allow the integration of CEAGRO time series until 2006 with CEAGRO 2017 
ceagro_2017_adj <- function(ceagro_xls, skipped= 7){
  # ceagro_xls is a full path of the sidra ceagro 2017 data
  ceagro_2017 <-  readxl::read_excel(ceagro_xls, skip = skipped)
  ceagro_2017 <- ceagro_2017[1:dim(ceagro_2017)[1]-1,]
  ceagro_2017$year <- 2017
  var_nam <- paste0(strsplit(sub('\\.xlsx$', '', basename(ceagro_xls)), "-")[[1]][2],"_", strsplit(sub('\\.xlsx$', '', basename(ceagro_xls)), "-")[[1]][3])    
  colnames(ceagro_2017) <- c("cod", "uf",var_nam, "years" )
  ceagro_2017<- dplyr::select(ceagro_2017, "cod", "uf", "years", everything())
  return(ceagro_2017)
}
ceagro_labor_2017<- ceagro_2017_adj("data/ibge/ceagro_data/UF_ceagro-employed-people-farms-2017.xlsx", skipped  = 6)
ceagro_trucks_2017 <- ceagro_2017_adj("data/ibge/ceagro_data/UF_ceagro-trucks-in-farms-2017.xlsx")
ceagro_pasture_2017 <- ceagro_2017_adj("data/ibge/ceagro_data/UF_ceagro-landuse-farms-pasture-area-2017.xlsx")

#' Building updated time series for CEAGRO from 1974 to 2017
output_dir <- "output_data_prep"
if(!file.exists(output_dir)){dir.create(output_dir)}
#' Labor variable
ceagro_labor_1975_2017 <- rbind(ceagro_labor_1975_2006, ceagro_labor_2017)# binding the new rows with the 2017 data
ceagro_labor_1975_2017 <- ceagro_labor_1975_2017[order(ceagro_labor_1975_2017$cod),]# reordering files per code
write.csv(ceagro_labor_1975_2017, file=paste0(output_dir,"/",strsplit(sub('\\.xlsx$', '', basename("data/ibge/ceagro_data/UF_ceagro-employed-people-farms-2017.xlsx")), "2017")[[1]][1], "1975_2017.csv"),# need to adjust
          row.names = FALSE, fileEncoding = "UTF-8")
#' Pasture land use variable
colnames(ceagro_pasture_2017)<-colnames(ceagro_pasture)
ceagro_landuse_1975_2017 <- rbind(ceagro_pasture, ceagro_pasture_2017)
ceagro_landuse_1975_2017 <- ceagro_landuse_1975_2017[order(ceagro_landuse_1975_2017$cod),]
write.csv(ceagro_landuse_1975_2017, file=paste0(output_dir,"/",strsplit(sub('\\.xlsx$', '', basename("data/ibge/ceagro_data/UF_ceagro-landuse-farms-pasture-area-2017.xlsx")), "2017")[[1]][1], "1975_2017.csv"),# need to adjust
          row.names = FALSE, fileEncoding = "UTF-8")
#' trucks variable
colnames(ceagro_trucks_2017)<-colnames(ceagro_trucks_1975_2006)
ceagro_trucks_1975_2017 <- rbind(ceagro_trucks_1975_2006, ceagro_trucks_2017)
ceagro_trucks_1975_2017 <- ceagro_trucks_1975_2017[order(ceagro_trucks_1975_2017$cod),]
write.csv(ceagro_trucks_1975_2017, file=paste0(output_dir,"/",strsplit(sub('\\.xlsx$', '', basename("data/ibge/ceagro_data/UF_ceagro-trucks-in-farms-2017.xlsx")), "2017")[[1]][1], "1975_2017.csv"),# need to adjust
          row.names = FALSE, fileEncoding = "UTF-8")