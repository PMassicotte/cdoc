#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_ferrari2000.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Ferrari et al. 2000.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

ferrari2000 <- read_csv("dataset/raw/ferrari2000/data.csv") %>% 
  
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  
  gather(range, S, matches("S\\d+"))

ferrari2000$wavelength <- as.numeric(unlist(str_extract_all(ferrari2000$wavelength, "\\d+")))

saveRDS(ferrari2000, "dataset/clean/ferrari2000.rds")