#'---
#' author: Pedro Castro
#' title:  Paper LUP Review  - SIDRA data join
#' date: 05. December 2019
#'---

library("dplyr")
library("tidyverse")
#' 1 - Joining anp data for add uf codes an acronyms - data will replace the previous generated anp data (which has no uf codes)
acronyms2 <- read.csv("data/link_tables/UFs_acronyms_ids_description_utf8.csv", sep=";", encoding="UTF-8")
anp<- read.csv("output_data_prep/UF_anp_oil_prod_mar_1941-2019.csv")
join_anp <-left_join(acronyms2, anp, by= c("Name"= "uf"))%>%dplyr::select(-Acronym)
colnames(join_anp) <- c("cod", "uf", "year", "oil_production_m3")
#' checking consistency
unique(anp$uf)
unique(join_anp$uf)
a<- filter(join_anp, !is.na(join_anp$oil_production_m3))
unique(a$uf)
filter(join_anp, join_anp$cod==33)
write.csv(join_anp, file="output_data_prep/UF_anp_oil_prod_mar_1941-2019.csv", row.names = FALSE, fileEncoding = "UTF-8")

#'  2 - binding tables with the same dimension
pam_ppm_list <- list.files("output_data_prep", full.names=TRUE, pattern="1974-2018")
df <- read.csv(pam_ppm_list[1], encoding="UTF-8")
df<- df%>%dplyr::select(-"sugarcane_amount_produced_ton")
for (i in seq_along(pam_ppm_list)){
  fl <- read.csv(pam_ppm_list[i], encoding="UTF-8")
  var <- strsplit(sub('\\.csv$', '', basename(pam_ppm_list[i])),"_")[[1]][2]
  var_nam <-paste(strsplit(var,"-")[[1]][c(1,2,3)], collapse ="_")
  fl <- fl%>%dplyr::select(-"cod",-"uf",-"year")
  colnames(fl)<-var_nam
  df<- cbind(df, fl)
}

#' joining one by one
#' mswep data
prec_mswep<- read.csv("output_data_prep/UF_prec_mswep_1979_2017_long.csv", encoding="UTF-8")
prec_mswep <- prec_mswep%>%dplyr::select(-"uf")
pam_ppm_df <- df
join_mswep <- left_join(pam_ppm_df, prec_mswep, by= c("cod"= "cod", "year"= "year"))
#' anp data
anp_cod<- read.csv("output_data_prep/UF_anp_oil_prod_mar_1941-2019.csv", encoding="UTF-8")
anp_cod <- anp_cod%>%dplyr::select(-"uf")
join_anp_df <- left_join(join_mswep, anp_cod, by= c("cod"= "cod", "year"= "year"))
#' ceagro data
#' ceagro employed peple in Rural areas
ceagro_employed<- read.csv("output_data_prep/UF_ceagro-employed-people-farms-1975_2017.csv", encoding="UTF-8")
ceagro_employed <- ceagro_employed%>%dplyr::select(-"uf")
join_ceagro_employed <- left_join(join_anp_df, ceagro_employed, by= c("cod"= "cod", "year"= "years"))
#' ceagro pasture areas 
ceagro_pasture<- read.csv("output_data_prep/UF_ceagro-landuse-farms-pasture-area-1975_2017.csv", encoding="UTF-8")
ceagro_pasture <- ceagro_pasture%>%dplyr::select(-"uf")
join_ceagro_pasture <- left_join(join_ceagro_employed, ceagro_pasture, by= c("cod"= "cod", "year"= "year"))
#' ceagro trucks
ceagro_trucks<- read.csv("output_data_prep/UF_ceagro-trucks-in-farms-1975_2017.csv", encoding="UTF-8")
ceagro_trucks <- ceagro_trucks%>%dplyr::select(-"uf")
join_ceagro_trucks <- left_join(join_ceagro_pasture, ceagro_trucks, by= c("cod"= "cod", "year"= "years"))
dim(join_ceagro_trucks)
names(join_ceagro_trucks)[c(9,14)] <- c("yield_sugarcane", "trucks_farms")
write.csv(join_ceagro_trucks,file="output_data_prep/UF_multiple_data_tosynth.csv", row.names = FALSE, fileEncoding = "UTF-8")




















