#'---
#' author: Pedro Castro
#' title:  Paper LUP Review  - adjusting synth output table 
#' date: 27. November 2019 ( updated on 23.07.2020)
#'---

#' Required libraries
library(readxl)
library(dplyr)
library(tidyverse)

#' Synth 1990 output table adjustment
synth <- read.csv("output_stata/synth1990.csv", encoding = "UTF-8")
synth2<- synth%>%dplyr::select(-X_W_Weight, -X_Co_Number)%>%dplyr::select(X_Y_synthetic, X_time)%>%mutate(treatment="synthetic", code=2)
synth3<- synth%>%dplyr::select(-X_W_Weight, -X_Co_Number)%>%dplyr::select(X_Y_treated, X_time)%>%mutate(treatment="control", code=1)
names(synth2) <- c("value", "year", "treatment", "code" )
names(synth3) <- c("value", "year", "treatment", "code" )
synth_out<- bind_rows(synth2,synth3)
write.csv(synth_out, file ="output_data_prep/synth_to_itsa1990.csv", row.names = FALSE)

#' Synth 2006 output table adjustment 
synth <- read.csv("output_stata/synth2006.csv", encoding = "UTF-8")
synth2<- synth%>%dplyr::select(-X_W_Weight, -X_Co_Number)%>%dplyr::select(X_Y_synthetic, X_time)%>%mutate(treatment="synthetic", code=2)
synth3<- synth%>%dplyr::select(-X_W_Weight, -X_Co_Number)%>%dplyr::select(X_Y_treated, X_time)%>%mutate(treatment="control", code=1)
names(synth2) <- c("value", "year", "treatment", "code" )
names(synth3) <- c("value", "year", "treatment", "code" )
synth_out<- bind_rows(synth2,synth3)
write.csv(synth_out, file ="output_data_prep/synth_to_itsa2006.csv", row.names = FALSE)
