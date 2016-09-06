#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Oceans and Atmosphere Aquatic Remote Sensing team. (2016). CSIRO Oceans and
# Atmosphere, Aquatic Remote Sensing team. Australia. Retrieved from
# http://www.csiro.au/en/Research/OandA
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

# Stations ----------------------------------------------------------------

stations <- read_excel("dataset/raw/literature/csiro/CSIRO_DBlondeau_CDOM_DOC_Tropical.xlsx",
                       sheet = "SamplingSummary") %>% 
  drop_na(StationID_all)

stations <- stations[, !duplicated(names(stations))] %>% 
  select(
    station = `StationID_all`,
    latitude = Lat,
    longitude = Lon,
    date = Date_UTC,
    salinity = Salinity
  ) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  separate(station, into = c("cruise", "station"), sep = 4) %>% 
  mutate(station = as.numeric(station)) %>% 
  mutate(cruise = tolower(cruise)) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  drop_na(salinity) # Remove stations that are missing salinity

# CDOM wet season 2012 ----------------------------------------------------

cdom_wet <- read_excel("dataset/raw/literature/csiro/CSIRO_DBlondeau_CDOM_DOC_Tropical.xlsx", 
                       sheet = "CDOM_WetSeason2012", skip = 7)

cdom_wet <- cdom_wet[, -1]

names(cdom_wet)[1] <- "wavelength"

cdom_wet <- cdom_wet %>% 
  gather(station, absorption, -wavelength) %>% 
  mutate(station = parse_number(station)) %>% 
  mutate(cruise = "vdgw")

cdom_wet %>% 
  ggplot(aes(x = wavelength, y = absorption, group = station)) +
  geom_line()

# CDOM dry season 2013 ----------------------------------------------------

cdom_dry <- read_excel("dataset/raw/literature/csiro/CSIRO_DBlondeau_CDOM_DOC_Tropical.xlsx", 
                       sheet = "CDOM_DrySeason2013", skip = 9, na = "-999")

cdom_dry <- cdom_dry[, -1]

names(cdom_dry)[1] <- "wavelength"

cdom_dry <- cdom_dry %>% 
  gather(station, absorption, -wavelength) %>% 
  mutate(station = parse_number(station)) %>% 
  na.omit() %>% 
  mutate(cruise = "vdgd")

# Interpolate aCDOM at 350 ------------------------------------------------

# ***************************************************************************
# CDOM data is "only" between 349.60 800.16. Let's interpolate at 350 nm.
# ***************************************************************************

wl <- 350

cdom <- bind_rows(cdom_dry, cdom_wet) %>% 
  group_by(cruise, station) %>% 
  nest() %>% 
  mutate(absorption = map(data, ~splinefun(.$wavelength, .$absorption)(wl))) %>% 
  unnest(absorption) %>% 
  select(-data) %>% 
  mutate(wavelength = wl)

# DOC ---------------------------------------------------------------------

doc_wet <- read_excel("dataset/raw/literature/csiro/CSIRO_DBlondeau_CDOM_DOC_Tropical.xlsx",
                      sheet = "DOC_Wet2012", 
                      skip = 6, 
                      col_names = FALSE) %>% 
  select(
    station = X0,
    doc = X2
  ) %>% 
  separate(station, into = c("cruise", "station"), 4) %>% 
  filter(grepl("NERP", cruise)) %>% 
  mutate(cruise = "vdgw") %>%
  mutate(station = as.numeric(station)) %>% 
  mutate(doc = doc / 12 * 1000)


doc_dry <- read_excel("dataset/raw/literature/csiro/CSIRO_DBlondeau_CDOM_DOC_Tropical.xlsx",
                      sheet = "DOC_POC_Dry2013", 
                      skip = 10, 
                      col_names = FALSE) %>% 
  select(
    cruise = X0,
    station = X1,
    doc = X3
  ) %>% 
  filter(grepl("VDGD", cruise)) %>% 
  mutate(cruise = "vdgd") %>%
  mutate(station = as.numeric(station)) %>% 
  mutate(doc = doc / 12 * 1000)

doc <- bind_rows(doc_wet, doc_dry)

# Merge everything --------------------------------------------------------

csiro <- inner_join(stations, cdom, by = c("cruise", "station")) %>% 
  inner_join(doc, by = c("cruise", "station")) %>% 
  mutate(study_id = "csiro") %>%
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(station = as.character(station))

# anti_join(stations, doc)

# Save --------------------------------------------------------------------

write_feather(csiro, "dataset/clean/literature/csiro.feather")


# Plot --------------------------------------------------------------------

# csiro %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~ecosystem, scales = "free")
# 
# map <- rworldmap::getMap()
# plot(map)
# points(stations$longitude, stations$latitude, col = "red")
