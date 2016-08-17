#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2016.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Osburn, C. L., Boyd, T. J., Montgomery, M. T., Bianchi, T. S., Coffin, R. B.,
# and Paerl, H. W. (2016). Optical Proxies for Terrestrial Dissolved Organic
# Matter in Estuaries and Coastal Waters. Front. Mar. Sci. 2.
# doi:10.3389/fmars.2015.00127.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

source("R/salinity2ecosystem.R")

osburn2016 <- read_excel("dataset/raw/literature/osburn2016/osburn2016.xlsx") %>%
  select(estuary = Estuary,
         season = Season,
         latitude = Lat,
         longitude = Lon,
         salinity = Salinity,
         a254,
         a350,
         doc = DOC) %>%
  gather(wavelength, absorption, a254, a350) %>%
  mutate(wavelength = parse_number(wavelength)) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(study_id = "osburn2016") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>%
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(osburn2016, "dataset/clean/literature/osburn2016.feather")
