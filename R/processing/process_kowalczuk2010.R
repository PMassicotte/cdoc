#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Kowalczuk, P., Cooper, W. J., Durako, M. J., Kahn, A. E., Gonsior, M., &
# Young, H. (2010). Characterization of dissolved organic matter fluorescence in
# the South Atlantic Bight with use of PARAFAC model: Relationships between
# fluorescence and its components, absorption coefficients and organic carbon
# concentrations. Marine Chemistry, 118(1–2), 22–36.
# http://doi.org/10.1016/j.marchem.2009.10.002
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

kowalczuk2010 <-
  read_excel("dataset/raw/literature/kowalczuk2010/Cormp_CDOM_absorption_fluo_6comp.xls") %>%
  select(
    station_name = `Station name`,
    date = Date,
    latitude = Latitude,
    longitude = Longitude,
    depth = `Depth (m.)`,
    `350nm`:`684nm`,
    salinity = `Salinity (PSU)`,
    temperature = `Temperature (Deg. C)`,
    doc = `DOC micromol/l`
  ) %>%
  mutate(date = as.Date(date)) %>%
  gather(wavelength, absorption, `350nm`:`684nm`) %>%
  mutate(wavelength = parse_number(wavelength)) %>%
  drop_na(doc, absorption, longitude, latitude, salinity) %>%
  mutate(ecosystem = salinity2ecosystem(salinity)) %>%
  # Outliers, they were also removed from their paper
  filter(station_name != "CFP1" & date != "2003-05-27") %>% 
  filter(station_name != "CFP5" & date != "2004-10-11") %>% 
  mutate(study_id = "kowalczuk2010") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(kowalczuk2010, "dataset/clean/literature/kowalczuk2010.feather")

# map <- rworldmap::getMap()
# plot(map)
# points(kowalczuk2010$longitude, kowalczuk2010$latitude, col = "red")
# 
# kowalczuk2010 %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~ wavelength, scales = "free")

# kowalczuk2010 %>%
#   filter(wavelength == 350) %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap( ~ wavelength, scales = "free") +
#   geom_text_repel(aes(label = paste(station_name, date)))
