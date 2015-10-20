#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2010 <- read_csv("data/raw/osburn2010/data.csv") %>% 
  
  gather(wavelength, acdom, matches("a\\d+"))

osburn2010$wavelength <- as.numeric(unlist(str_extract_all(osburn2010$wavelength, "\\d+")))

saveRDS(osburn2010, "data/clean/osburn2010.rds")