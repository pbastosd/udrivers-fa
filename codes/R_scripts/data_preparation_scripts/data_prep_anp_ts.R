#'---
#' author: Pedro Castro
#' title:  Paper LUP Review  - ANP OIL time serie building
#' date: 29. November 2019 (updated on 21.07.2020)
#'---

#' Script builds time series of oil production in the sea from 1941 to 2019 per federal State 
#' The data used in this script was provided by ANP
#' Time-series provied by ANP are slip in different periods, e.g.: from 1941 to 1979; from 1980 to 1988, etc.
#' The script filter the information provided by ANP selecing only the amount of oil produced in the sea 
#' The script exports he time serie with annual oil production (in the sea) aggregated per Federal state  
#' The resulting table was considered as a candicate covariable for the SYNTH analysis
#' in the end, it was not incorporated in the paper analysis

output_dir <- "output_data_prep"
  if(!file.exists(output_dir)){dir.create(output_dir)}

#' 1- building big table with anp oil data 
library("dplyr")
library("tidyverse")
anp_tables_dir <- "data/anp/Oil-production"
anp_tables_mar <- list.files(anp_tables_dir, pattern = "producao-mar-", full.names = TRUE)
anp_prod_mar <- NULL
names_df <- names(read.csv(anp_tables_mar[1], sep=",", encoding= "UTF-8", header = TRUE))
for( i in seq_along(anp_tables_mar)){
  anp_table <- read.csv(anp_tables_mar[i], sep=",", encoding= "UTF-8", header = TRUE)
  names(anp_table) <- names_df
  anp_oil <- dplyr::select(anp_table, X.U.FEFF.Ano,Estado, Bacia,Campo, Poço, Produção.de.Óleo..m³.)
  names(anp_oil) <- c("year","uf", "Basin", "Field", "Oil_well", "Oil_production_m3")
  anp_prod_mar <- rbind(anp_prod_mar, anp_oil)
}
anp_prod_mar$Oil_production_m3 <- as.numeric(gsub("\\,", ".",anp_prod_mar$Oil_production_m3))
anp_prod_mar<- dplyr::select(anp_prod_mar, "uf", "year", everything())

#' 2-building time-series grouped by UF
ufs <- unique(anp_prod_mar$uf)
anp_prod_mar_uf_total <- NULL
for (i in seq_along(ufs)){
  anp_prod_mar_uf <- anp_prod_mar%>%
    filter(uf==unique(anp_prod_mar$uf)[i])%>%
    group_by(year)%>%
    summarise(Oil_production_m3 = sum(Oil_production_m3, na.rm = TRUE))
  anp_prod_mar_uf$uf <-unique(anp_prod_mar$uf)[i]
  anp_prod_mar_uf_total <- rbind(anp_prod_mar_uf_total, anp_prod_mar_uf)
}

#' correcting unformated states in a very tailored solution and exporting the final time series aggregated per state
bad <- c("Cear\xe1", "Esp\xedrito Santo","S\xe3o Paulo", "N\xe3o Informado")
to_rep <- c("Ceará","Espírito Santo","São Paulo" , "Não Informado")
anp_prod_mar_uf_total_sel <- anp_prod_mar_uf_total[1:359,]# could not find a better solution 
colnames(anp_prod_mar_uf_total_sel) <- c("year", "oil_production_m3","uf")
anp_prod_mar_uf_total_sel<- dplyr::select(anp_prod_mar_uf_total_sel, "uf", "year", everything())%>%filter(uf!= "Não Informado")
write.csv(anp_prod_mar_uf_total_sel, file=paste0(output_dir,"/UF_anp_oil_prod_mar_1941-2019.csv"), row.names = FALSE)







