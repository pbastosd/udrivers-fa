#'---
#' author: Pedro Castro
#' title:  Paper LUP Review  - Building precipitation dataset with mswep data 
#' date: 02. December 2019
#'---

#' Script extracts mswep precipitation monthly datasets and aggreagates the average annual precipitation per Federal State
#' The output is an csv table with a time-series with average precipitation per federal state from 1979 to 2017
#' libraries 
library(raster)
library(rgdal)
library(dplyr)

#' loading mswep datasets
mswep_dir <- "data/mswep2.2/mswep2.2_monthly"
mswep <- list.files(mswep_dir, full.names = TRUE)

#' clipping mswep  data for Brazil using rgdal
ibge_sa <- readOGR("data/vectors", "LIM_Pais_A")# south america boundaries
ibge_br <- subset(ibge_sa, NOME=="Brasil")# subsetting brazil
clip_ras_mod <- function(ras, shp){
  require(rgdal)
  bound <- spTransform(shp, CRSobj=crs(ras))
  ras_crop <- crop(ras, extent(bound), snap="out")# crop by extent, not by mask
  bound_ras <- rasterize(bound, ras_crop)# convert polygon to raster using previous cropped raster as reference
  ras_shp <- mask(ras_crop, bound_ras)
  return(ras_shp)
}

output_mswep <- paste0(mswep_dir, "/mswep2.2_br")
if(!file.exists(output_mswep)){dir.create(output_mswep)}
#' extracting mswep data for Brazil UF
for(i in seq_along(mswep)){
  mswep_ras <- raster(mswep[i])
  mswep_clip <- clip_ras_mod(mswep_ras, ibge_br)
  writeRaster(mswep_clip, filename= paste0(output_mswep,"/", sub('\\.tif$', '', basename(mswep[i])), "_br.tif"))
  print(paste(mswep[i], " is complete"))
}

list_mswep_br<- list.files(output_mswep, pattern = ".tif$", full.names = TRUE)
list_years <- NULL
for (i in seq_along(list_mswep_br)){
  year <-substr(strsplit(basename(list_mswep_br[i]), "_")[[1]][3],1,4)
  list_years[i]<-year
}

list_years <- unique(list_years)

output_mswep_br_annual <- paste0(output_mswep, "/mswep2.2_br_annual")
if(!file.exists(output_mswep_br_annual)){dir.create(output_mswep_br_annual)}
for ( i in seq_along(list_years)){
  mswep_br_year <- grep(list_years[i],list_mswep_br)
  mswep_br_year_stack <- stack(list_mswep_br[mswep_br_year])
  mswep_annual <- sum(mswep_br_year_stack)
  print("mswep 2.2 annual data aggregation for Brazil is complete")
  writeRaster(mswep_annual, filename= paste0(output_mswep_br_annual,"/", "mswep2.2_", list_years[i], "_br.tif"))
  print(paste("Results are saved in ", output_mswep_br_annual))
}

#'building time series per federal state to serve as input to synth 
prec_uf_1979_2017 <- NULL
ibge_specs <- read.csv("data/link_tables/UFs_acronyms_ids_description.csv", sep=";", header = TRUE)
ibge_uf_br <- readOGR("data/vectors", "BRUFE250GC_SIR")
list.annual <- list.files(output_mswep_br_annual, pattern = ".tif$", full.names = TRUE)
output_mswep_uf_annual <- paste0(output_mswep_br_annual, "/mswep2.2_uf_annual")
if(!file.exists(output_mswep_uf_annual)){dir.create(output_mswep_uf_annual)}
for (i in seq_along(list.annual)){
  mean_uf_year<- extract(raster(list.annual[i]), ibge_uf_br, fun=mean, na.rm=TRUE)
  colnames(mean_uf_year)<-list_years[i]
  prec_uf_1979_2017[[i]] <- mean_uf_year
}

#' table adjustments for synth 
prec_uf_1979_2017_2<-as.data.frame(prec_uf_1979_2017)
prec_uf_1979_2017_2$cod<-ibge_uf_br$CD_GEOCUF
colnames(prec_uf_1979_2017_2)<- c(seq(1979, 2017,1), "cod")
ibge_specs$Geocode <- as.factor(ibge_specs$Geocode)
prec_uf_1979_2017_join <- left_join(ibge_specs, prec_uf_1979_2017_2, by= c("Geocode"= "cod"))#RJ changed position because of the join
infos<- prec_uf_1979_2017_join[,1:3]
ufs <- unique(infos$Geocode)
prec_mswep_uf <- NULL
for (i in seq_along(ufs)){
  prec_uf <- prec_uf_1979_2017_join%>%
    filter(Name==unique(prec_uf_1979_2017_join$Name)[i])%>%
    dplyr::select(-"Acronym", -"Name", -"Geocode")%>%
    pivot_longer(everything(), names_to="years", values_to ="prec_mswep")
    prec_uf$Name <-unique(prec_uf_1979_2017_join$Name)[i]
    prec_uf$cod <-unique(prec_uf_1979_2017_join$Geocode)[i]
    prec_mswep_uf <- rbind(prec_mswep_uf, prec_uf)
}
colnames(prec_mswep_uf) <- c("year", "prec_mswep","uf", "cod")
prec_mswep_uf$year <- as.numeric(prec_mswep_uf$year)
prec_mswep_uf<- dplyr::select(prec_mswep_uf, "cod", "uf", "year", everything())
write.csv(prec_mswep_uf, file=paste0(output_dir,"/UF_prec_mswep_1979_2017_long.csv"), row.names = FALSE, fileEncoding = "UTF-8")

