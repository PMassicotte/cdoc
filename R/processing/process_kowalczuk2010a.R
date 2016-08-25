#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Kowalczuk, P., Zabłocka, M., Sagan, S., & Kuliński, K. (2010). Fluorescence
# measured in situ as a proxy of CDOM absorption and DOC concentration in the
# Baltic Sea. Oceanologia, 52(3), 431–471. http://doi.org/10.5697/oc.52-3.431
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

kowalczuk2010a <- read_excel("dataset/raw/literature/kowalczuk2010a/aCDOM_DOC_1993_2014_non_linear_all_data.xls") %>% 
  select(
    station_name = `Station name`,
    date = Date,
    latitude = Lat.,
    longitude = Long.,
    depth = `Depth (m)`,
    `acdom(350)`:`acdom(670)`,
    doc = `DOC mg/l`,
    salinity = `Salinity (PSU)`
  ) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(date = as.Date(date)) %>% 
  gather(wavelength, absorption, `acdom(350)`:`acdom(670)`) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  drop_na(doc, absorption, salinity) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(study_id = "kowalczuk2010a") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(kowalczuk2010a, "dataset/clean/literature/kowalczuk2010a.feather")

# map <- rworldmap::getMap()
# plot(map)
# points(kowalczuk2010a$longitude, kowalczuk2010a$latitude, col = "red")
# 
# kowalczuk2010a %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(ecosystem ~ wavelength, scales = "free")

