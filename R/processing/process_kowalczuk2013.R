#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Kowalczuk, P., Tilstone, G. H., Zabłocka, M., Röttgers, R., & Thomas, R.
# (2013). Composition of dissolved organic matter along an Atlantic Meridional
# Transect from fluorescence spectroscopy and Parallel Factor Analysis. Marine
# Chemistry, 157, 170–184. http://doi.org/10.1016/j.marchem.2013.10.004
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

kowalczuk2013 <- read_excel("dataset/raw/literature/kowalczuk2013/AMT20_aCDOM_EEM_DOC_17Dec.xls")

kowalczuk2013 <-
  kowalczuk2013[!duplicated(names(kowalczuk2013))] %>%
  select(date = Date,
         station = Station,
         latitude = `Latitude `,
         longitude = `Longitude `,
         depth = Depth,
         salinity = `PSALCC01 [Dmnless]`,
         doc = `DOC [micromol/l]`,
         contains("aCDOM(")) %>%
  gather(wavelength, absorption, contains("acdom(")) %>%
  mutate(date = as.Date(date)) %>%
  mutate(wavelength = parse_number(wavelength)) %>%
  drop_na(doc, absorption) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  filter(wavelength <= 500) %>% 
  mutate(study_id = "kowalczuk2013") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(kowalczuk2013, "dataset/clean/literature/kowalczuk2013.feather")
  
# kowalczuk2013 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free")
# 
# kowalczuk2013 %>% 
#   ggplot(aes(x = wavelength, y = absorption, group = station)) +
#   geom_line() +
#   facet_wrap(~depth)

# map <- rworldmap::getMap()
# plot(map)
# points(kowalczuk2013$longitude, kowalczuk2013$latitude, col = "red")
