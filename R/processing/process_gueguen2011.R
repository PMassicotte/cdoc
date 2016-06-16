# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Guéguen, C et al. (2011): (Table 1) Salinity, dissolved organic carbon and 
# absorption characteristics of surface river waters around Hudson Bay. 
# doi:10.1594/PANGAEA.810341
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

gueguen2011 <- read_delim("dataset/raw/literature/gueguen2011/Gueguen-etal_2011.tab",
                          delim = "\t", skip = 30) %>% 
  select(event = Event,
         latitude = Latitude,
         longitude = Longitude,
         area = Area,
         date = `Date/Time`,
         station = Station,
         salinity = Sal,
         doc = `DOC [µmol/l]`,
         absorption = `ac355 [1/m]`) %>% 
  mutate(doc = extract_numeric(doc)) %>% 
  mutate(wavelength = 355) %>% 
  mutate(study_id = "gueguen2011") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(gueguen2011, "dataset/clean/literature/gueguen2011.feather")

# gueguen2011 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()

