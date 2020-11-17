#'---
#' author: Pedro Castro
#' title:  Function SIDRA xlsx sigle sheet  adjustment
#' date: 22. October 2019 (updated on 21.07.2020)
#'---

#'Description: The functions performs an adjustment of the downloaded SIDRA xlxs table and exports the adjusted table in csv format. 
#'It works for cases where there is only one sheet per xlsx file
#'For tables dowmnloaded in wide format please refer to the function sidra_prep_wide_to_long_function

data_prep_sidra<- function(sidra_xlsx_path, skipped_rows=3, var_name, filename=file_name, output_dir=paste0(getwd(),"/output_data_prep")){
  #the function requires the complete path of a sidra IBGE PAM or PPM xlsx table
  #function also works for CEAGRO data in long format
  #skipped_rows vary according with the data set
  #headers should be skipped and the table should start by the row were the column names cod appear
  #var_name is a string
  #the data can be acessed via https://sidra.ibge.gov.br/pesquisa/pam/tabelas
  #the table must be dowwloaded containing annual data from 1974 to 2018 per Federal state
  #the table must contiain the uf codes, name of the states, the years, and the variable of interest
  #the table must be in long format
  require("readxl")
  require("dplyr")
  print("Creating output dir")
  if(!file.exists(output_dir)){dir.create(output_dir)}
  print("Reading table")
  sidra_xlsx <- readxl::read_excel(sidra_xlsx_path, skip=skipped_rows)
  print("Removing footnote")
  sidra_xlsx <- sidra_xlsx[1:dim(sidra_xlsx)[1]-1,]
  print("Defining column names")
  colnames(sidra_xlsx) <- c("cod", "uf", "year", var_name)
  print("Converting variable and year columns to numeric. The missing values will become NA")
  sidra_xlsx[, which(colnames(sidra_xlsx) == var_name)] <- as.numeric(unlist(sidra_xlsx[, which(colnames(sidra_xlsx) == var_name)]))
  sidra_xlsx$year <- as.numeric(sidra_xlsx$year)
  print("Getting the state names and state codes")
  ufs_names <- as.vector(na.omit(unique(sidra_xlsx$uf)))
  ufs_cod <- as.vector(na.omit(unique(sidra_xlsx$cod)))
  print("Adjusting states' code and names columns")
  df<- NULL
  df2 <- NULL
  for (i in seq_along(ufs_cod)){# or any sequence representing the number territorial units
    a <- as.data.frame(rep(ufs_cod[i], count(unique(sidra_xlsx[,3]))))# repeat for the time serie number
    colnames(a) <- ufs_names[i]# set column names based on the state names por position
    b <- as.data.frame(rep(ufs_names[i], count(unique(sidra_xlsx[,3]))))# same repetition
    colnames(b) <- ufs_cod[i]# set column names based on the state codes por position
    df[i] <- a #store as a list with 27 (number of territotial units) levels
    df2[i] <- b #store as a list with 27 (number of territotial units) levels
  }
  sidra_xlsx$cod <- unlist((df))# unlist for getting the sequence of repreated values per number of years
  sidra_xlsx$uf <- unlist((df2))
  print(paste("Saving the new file in", output_dir))
  file_name <-  sub('\\.xlsx$', '',basename(sidra_xlsx_path))
  write.csv(sidra_xlsx, file=paste0(output_dir,"/", filename, ".csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
  return(sidra_xlsx)
}

yield_sugarcane<- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_yield-sugarcane-1974-2018.xlsx", var_name="sugarcane_yield_kg_ha")
amount_prod_sugarcane<- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_amount-produced-sugarcane-1974-2018.xlsx", var_name="sugarcane_amount_produced_ton")
harv_sugarcane<- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_harvested-area-sugarcane-1974-2018.xlsx", var_name="sugarcane_harvested_areas")
harv_total <- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_harvested-area-total-1974-2018.xlsx", var_name="total_harvested_areas")
amount_bovines <- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_livestock-bovines-amount-1974-2018.xlsx", var_name="bovines_amount")
ceagro_pasture <- data_prep_sidra("data/ibge/ceagro_data/UF_ceagro-landuse-farms-pasture-area-1975-2006.xlsx", var_name="pasture_hectares")
harv_pineapple <- data_prep_sidra("data/ibge/updated_pam_data_1974_2018/UF_harvested-area-different-crops-1974-2018.xlsx", filename= "UF_harvested-area-pineapples_1974-2018", var_name="pineapples_harvested_areas")# for multiple sheets, it will consider only the first, i.e. pineapples
