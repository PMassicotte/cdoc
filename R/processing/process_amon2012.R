#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_amon2012.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Amon et al. 2012
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

amon2012 <- read_csv("dataset/raw/amon2012/data.csv") %>% 
  mutate(date = as.POSIXct(paste(date, time))) %>% 
  select(-time)

saveRDS(amon2012, "dataset/clean/amon2012")