#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2010 <- read_csv("dataset/raw/literature/osburn2010/data.csv") %>% 
  
  gather(wavelength, acdom, matches("a\\d+"))

osburn2010$wavelength <- as.numeric(unlist(str_extract_all(osburn2010$wavelength, "\\d+")))

osburn2010$sample_id <- paste(osburn2010$study_id, 1:nrow(osburn2010), sep = "_")

saveRDS(osburn2010, "dataset/clean/literature/osburn2010.rds")