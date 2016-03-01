#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_tehrani2013.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Tehrani, N., D’Sa, E., Osburn, C., Bianchi, T., and Schaeffer, B. (2013).
# Chromophoric Dissolved Organic Matter and Dissolved Organic Carbon from
# Sea-Viewing Wide Field-of-View Sensor (SeaWiFS), Moderate Resolution Imaging
# Spectroradiometer (MODIS) and MERIS Sensors: Case Study for the Northern Gulf
# of Mexico. Remote Sens. 5, 1439–1464. doi:10.3390/rs5031439.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

tehrani2013 <- read_csv("dataset/raw/literature/tehrani2013/data_tehrani2013.csv") %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-"))) %>%
  select(-year, -month) %>%
  mutate(sample_id = paste("tehrani2013", 1:nrow(.), sep = "_"))

saveRDS(tehrani2013, "dataset/clean/literature/tehrani2013.rds")
