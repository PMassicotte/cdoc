#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Shank, G. C., Nelson, K., & Montagna, P. A. (2009). Importance of CDOM
# Distribution and Photoreactivity in a Shallow Texas Estuary. Estuaries and
# Coasts, 32(4), 661–677. http://doi.org/10.1007/s12237-009-9159-7
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

shank2009 <-
  read_excel("dataset/raw/literature/shank2009/shank2009.xlsx", na = "na") %>%
  setNames(tolower(names(.))) %>%
  mutate(date = as.Date(date)) %>%
  mutate(doc = doc / 12 * 1000) %>%
  rename(absorption = `cdom a305`) %>%
  rename(s290_320 = `s290–320`) %>%
  rename(longitude = long) %>%
  rename(latitude = lat) %>%
  mutate(wavelength = 305) %>%
  mutate(ecosystem = salinity2ecosystem(salinity)) %>%
  mutate(study_id = "shank2009") %>%
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(shank2009, "dataset/clean/literature/shank2009.feather")

# shank2009 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   geom_smooth(method = "lm")

