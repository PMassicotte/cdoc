# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_loken2016.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Luke Loken, Gaston Small, Jacques Finlay, Robert Sterner, Elizabeth Runde,
# Sandra Brovold, and Emily Stanley. 2016. Saint Louis River Estuary Water
# Chemistry, Wisconsin, Minnesota, USA 2012 - 2013. U.S. LTER Network.
# https://pasta.lternet.edu/package/metadata/eml/knb-lter-ntl/322/1.
#
# https://search.dataone.org/#view/https://pasta.lternet.edu/package/metadata/eml/knb-lter-ntl/322/1
# 
#  Luke Loken, Gaston Small, Jacques Finlay, Robert Sterner, Elizabeth Runde, 
#  Sandra Brovold, and Emily Stanley. 2016. 
#  Saint Louis River Estuary Water Chemistry, Wisconsin, Minnesota, 
#  USA 2012 - 2013. U.S. LTER Network. 
#  https://pasta.lternet.edu/package/metadata/eml/knb-lter-ntl/322/1. 
# 
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

stations <- read_csv("dataset/raw/literature/loken2016/https---pasta.lternet.edu-package-data-eml-knb-lter-ntl-322-1-5a5465526b7a4c0ac70403b8b4677bb6") %>%
  select(station = Station,
         site_description = SiteDescription,
         latitude = lat_decimal,
         longitude = long_decimal) %>%
  distinct(station, .keep_all = TRUE) # duplicated station ID, good job guys...

loken2016 <- read_csv("dataset/raw/literature/loken2016/https---pasta.lternet.edu-package-data-eml-knb-lter-ntl-322-1-36971421d2cb8308296ded83d0c67e9c") %>%
  select(date = sampledate,
         station = Station,
         temperature = wtemp,
         ph,
         doc,
         abs254,
         suva254 = SUVA) %>%
  # mutate(station = parse_number(station)) %>%
  mutate(doc = doc / 12 * 1000) %>%
  mutate(absorption = abs254 * 2.303 / 0.01) %>%
  select(-abs254) %>%
  mutate(wavelength = 254) %>%
  inner_join(stations, by = "station") %>%
  mutate(station = as.character(station)) %>%
  mutate(study_id = "loken2016") %>%
  mutate(unique_id = paste("loken2016", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(loken2016, "dataset/clean/literature/loken2016.feather")
