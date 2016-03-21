# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_doc_lter2004.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Paul Hanson, Stephen Carpenter, Luke Winslow, and Jeffrey Cardille. 2014. 
# Fluxes project at North Temperate Lakes LTER: Random lake survey 2004. GLEON 
# Data Repository. gleon.1.9.
# 
# https://search.dataone.org/#view/gleon.1.9
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hanson2014_cdom <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.10.1.csv") %>% 
  rename(wbic = lakeid)

hanson2014_cdom <- mutate(hanson2014_cdom,
                          absorption = absorption * 2.303 / (cuvette / 100))

hanson2014_doc <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.9.1.csv") 

hanson2014_stations <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.5.1.csv") %>% 
  filter(!is.na(sampledate))

hanson2014 <- inner_join(hanson2014_doc, hanson2014_stations) %>% 
  inner_join(hanson2014_cdom) %>% 
  mutate(unique_id = paste("lter2004",
                           as.numeric(interaction(groupid, wbic, drop = TRUE)),
                           sep = "_"))

saveRDS(hanson2014, file = "dataset/clean/complete_profiles/lter2004.rds")

ggplot(hanson2014, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line()


