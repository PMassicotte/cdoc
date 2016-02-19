#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_lonborg2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Lonborg et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

lonborg2010 <- read_csv("dataset/raw/literature/lonborg2010/data.csv") %>% 
  gather(wavelength, acdom, matches("a\\d+"))

lonborg2010$wavelength <- as.numeric(unlist(str_extract_all(lonborg2010$wavelength, "\\d+")))

lonborg2010$sample_id <- paste(lonborg2010$study_id, 1:nrow(lonborg2010), sep = "_")

saveRDS(lonborg2010, "dataset/clean/literature/lonborg2010.rds")