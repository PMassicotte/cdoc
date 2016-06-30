#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_forsstrom2015.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Forsström, L., Rautio, M., Cusson, M., Sorvari, S., Albert, R.,
# Kumagai, M., et al. (2015). Dissolved organic matter concentration,
# optical parameters and attenuation of solar radiation in high- latitude
# lakes across three vegetation zones. Écoscience 6860.
# doi:10.1080/11956860.2015.1047137.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

forsstrom2015 <- read_csv("dataset/raw/literature/forsstrom2015/forsstrom2015.csv", na = "nd") %>%
  select(lake_code = `Lake (code)`,
         doc = DOC,
         a440,
         a320) %>%
  mutate(lake_code = iconv(lake_code, from = "latin1", to = "UTF-8")) %>%
  na.omit() %>%
  mutate(doc = doc / 12 * 1000) %>%
  mutate(date = as.Date("2004-08-22")) %>% # average
  gather(wavelength, absorption, a320, a440) %>%
  mutate(wavelength = extract_numeric(wavelength)) %>%
  mutate(longitude = 21) %>% # based on Fig. 1
  mutate(latitude = 69) %>%
  mutate(study_id = "forsstrom2015") %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("forsstrom2015", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "lake")

write_feather(forsstrom2015, "dataset/clean/literature/forsstrom2015.feather")
