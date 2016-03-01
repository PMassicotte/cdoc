#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2011.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2011.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2011 <- read_excel("dataset/raw/literature/osburn2011/data.xlsx", na = "NA") %>%
  gather(wavelength, acdom, matches("a\\d+")) %>%
  mutate(sample_id = as.character(sample_id))

saveRDS(osburn2011, "dataset/clean/literature/osburn2011.rds")
