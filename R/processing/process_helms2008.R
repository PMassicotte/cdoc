#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_helms2008.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Helms et al. 2008
#
# Helms, J. R., Stubbins, A., Ritchie, J. D., Minor, E. C., Kieber, D. J.,
# and Mopper, K. (2008). Absorption spectral slopes and slope ratios as
# indicators of molecular weight, source, and photobleaching of chromophoric
# dissolved organic matter. Limnol. Oceanogr. 53, 955–969.
# doi:10.4319/lo.2008.53.3.0955.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

helms2008 <- read_csv("dataset/raw/literature/helms2008/data_helms2008.csv") %>%
  gather(wavelength, absorption, contains("acdom")) %>%
  mutate(wavelength = parse_number(wavelength)) %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-"))) %>%
  select(-year, -month)

locations <- read_csv("dataset/raw/literature/helms2008/helms2008_locations.csv") %>%
  rename(sample_name = id, latitude = Lat., longitude = Long.) %>%
  select(-Note) %>%
  mutate(longitude = parse_number(longitude)) %>% 
  mutate(latitude = parse_number(latitude)) %>% 
  mutate(longitude = -longitude)

helms2008 <- left_join(helms2008, locations) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("helms2008", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(helms2008, "dataset/clean/literature/helms2008.feather")
