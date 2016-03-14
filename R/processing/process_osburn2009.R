#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2009.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2009
#
# Osburn, C. L., Retamal, L., and Vincent, W. F. (2009).
# Photoreactivity of chromophoric dissolved organic matter transported by
# the Mackenzie River to the Beaufort Sea. Mar. Chem. 115, 10–20.
# doi:10.1016/j.marchem.2009.05.003.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2009 <- read_csv("dataset/raw/literature/osburn2009/data_osburn2009.csv") %>% 
  mutate(longitude = -longitude) %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(study_id = "castillo1999") %>% 
  mutate(sample_id = paste("castillo1999", 1:nrow(.), sep = "_")) %>% 
  mutate(ecotype = ifelse(salinity <= 0.1, "river", ifelse(salinity > 0.1 & salinity <= 25, "coastal", "ocean")))

saveRDS(osburn2009, "dataset/clean/literature/osburn2009.rds")
