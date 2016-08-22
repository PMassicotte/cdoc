#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Guo, X.-J., Li, Q., Jiang, J.-Y., & Dai, B.-L. (2014). Investigating Spectral
# Characteristics and Spatial Variability of Dissolved Organic Matter Leached
# from Wetland in Semi-Arid Region to Differentiate Its Sources and Fate. CLEAN
# - Soil, Air, Water, 42(8), 1076–1082. http://doi.org/10.1002/clen.201300412
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

guo2014 <- read_excel("dataset/raw/literature/guo2014/guo2014.xlsx") %>% 
  select(
    site = Site,
    station = Station,
    longitude = Longitude,
    latitude = Latitude,
    doc = `DOC `,
    suva280 = SUVA280
  ) %>% 
  mutate(absorption = 2.303 * ((suva280 * doc))) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(wavelength = 280) %>% 
  mutate(ecosystem = "lake") %>% 
  mutate(study_id = "guo2014") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(guo2014, "dataset/clean/literature/guo2014.feather")

# guo2014 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
