#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Pocess raw data from:
# 
# Gaines Banks, A. M. (2016). Bioavailability of Dissolved Organic Matter in the
# North Inlet Estuary. South Carolina Honors College.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

# Salinity ----------------------------------------------------------------

salinity <- read_csv("dataset/raw/literature/banks2016/tabula-Bioavailability of Dissolved Organic Matter in the North Inlet Es-0.csv") %>% 
  select(
    date,
    station,
    salinity = Salinity
  ) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30"))

# DOC ---------------------------------------------------------------------

doc <- read_csv("dataset/raw/literature/banks2016/tabula-Bioavailability of Dissolved Organic Matter in the North Inlet Es-1.csv") %>% 
  select(
    date,
    station,
    doc = DOC
  ) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  filter(doc < 800) # clear outlier


# CDOM --------------------------------------------------------------------

cdom <- read_csv("dataset/raw/literature/banks2016/tabula-Bioavailability of Dissolved Organic Matter in the North Inlet Es-2.csv") %>% 
  gather(wavelength, absorption, a250, a350) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30"))


# Merge -------------------------------------------------------------------

banks2016 <- inner_join(salinity, doc, by = c("date", "station")) %>% 
  inner_join(cdom, by = c("date", "station")) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(study_id = "banks2016") %>% 
  mutate(unique_id = paste(1:nrow(.), sep = "_")) %>% 
  mutate(longitude = -79.188292) %>% # Coords estimated by hand, not provided in the thesis
  mutate(latitude = 33.349687)

# Save --------------------------------------------------------------------

write_feather(banks2016, "dataset/clean/literature/banks2016.feather")

# Plot --------------------------------------------------------------------

# banks2016 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scale = "free")

# map <- rworldmap::getMap()
# plot(map)
# points(banks2016$longitude, banks2016$latitude, col = "red")
