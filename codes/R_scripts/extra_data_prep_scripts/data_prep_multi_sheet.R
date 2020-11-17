#'---
#' author: Pedro Castro
#' title:  Script for executing SIDRA xlsx tables adjustment for tables with multiple sheets
#' date: 03. December 2019 (last update 21.07.2020)
#'---

#' Script includes a funtion an a loop over the sheets to automatize the adjustment
#' It provides additional funtionality for batch donwload of multiple sheets PAM SIDRA xlsx tables
#' Not necessarly used in the analsys of the paper, but a helpfull funtion for other crop case analysis

#' 1-Loading PAM datasets with multiple sheets 
xls_dir <-"data/ibge/updated_pam_data_1974_2018"
list_xls <- list.files(xls_dir, pattern="different-crops", full.names = TRUE)

#' 2-Modification of the function data_prep_sidra having as input instead of a path a loaded xls file
#' Function have to be used in combination with step three for batch download of sidra tables to an specific format
output_many_tables <- paste0(getwd(), "/data_prep_mod_output")
if(!file.exists(output_many_tables)){dir.create(output_many_tables)}
data_prep_mod<- function(sidra_xlsx, var_name){
  require("readxl")
  require("dplyr")
  sidra_xlsx <- sidra_xlsx[1:dim(sidra_xlsx)[1]-1,]
  print("Defining column names")
  colnames(sidra_xlsx) <- c("cod", "uf", "year", colnames(sidra_xlsx)[4])
  print("Converting variable and year columns to numeric. The missing values will become NA")
  sidra_xlsx[, which(colnames(sidra_xlsx) == colnames(sidra_xlsx)[4])] <- as.numeric(unlist(sidra_xlsx[, which(colnames(sidra_xlsx) == colnames(sidra_xlsx)[4])]))
  sidra_xlsx$year <- as.numeric(sidra_xlsx$year)
  print("Getting the state names and state codes")
  ufs_names <- as.vector(na.omit(unique(sidra_xlsx$uf)))
  ufs_cod <- as.vector(na.omit(unique(sidra_xlsx$cod)))
  print("Adjusting states' code and names columns")
  df<- NULL
  df2 <- NULL
  for (i in seq_along(ufs_cod)){
    a <- as.data.frame(rep(ufs_cod[i], count(unique(sidra_xlsx[,3]))))
    colnames(a) <- ufs_names[i]
    b <- as.data.frame(rep(ufs_names[i], count(unique(sidra_xlsx[,3]))))
    colnames(b) <- ufs_cod[i]
    df[i] <- a 
    df2[i] <- b
  }
  sidra_xlsx$cod <- unlist((df))
  sidra_xlsx$uf<- unlist((df2))
  print("Saving the new file in the working directory")
  write.csv(sidra_xlsx, file=paste0(output_many_tables, "/",var_name, "_1974_2018.csv"), 
            row.names = FALSE, fileEncoding = "UTF-8")
  return(sidra_xlsx)
}

#' 3-Running a loop to execute the function in all the different sheets existing in each excel file
library("readxl")
for (i in seq_along(list_xls)){
  xls <- list_xls[i]
  sheets<- excel_sheets(list_xls[i])
  for (k in seq_along(sheets)){
    print(sheets[k])
    test <- readxl::read_excel(list_xls[i], sheet=sheets[k], skip = 3)
    var <-strsplit(sub('\\.xlsx$', '', basename(list_xls[i])), "-")[[1]][1]
    prod<- strsplit(sheets[k], " ")[[1]][1]
    var_nam<- paste0(var, "_", prod)
    data_prep_mod(test,var_nam)
  }
}
