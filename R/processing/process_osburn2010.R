#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2010 <- read_csv("dataset/raw/literature/osburn2010/data.csv") %>%
  gather(wavelength, acdom, matches("a\\d+")) %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-"))) %>%
  select(-year, -month) %>%
  mutate(wavelength = extract_numeric(wavelength),
         sample_id = paste("osburn2010", 1:nrow(.), sep = "_"))

saveRDS(osburn2010, "dataset/clean/literature/osburn2010.rds")
