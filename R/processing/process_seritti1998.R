#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Seritti, A., Russo, D., Nannicini, L., & Del Vecchio, R. (1998). DOC,
# absorption and fluorescence properties of estuarine and coastal waters of the
# Northern Tyrrhenian Sea. Chemical Speciation and Bioavailability, 10(3),
# 95–106. http://doi.org/10.3184/095422998782775790
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

seritti1998_1 <- read_excel("dataset/raw/literature/seritti1998/seritti1998.xlsx", sheet = 1) %>% 
  select(
    station = Station,
    longitude,
    latitude,
    salinity = Salinity,
    doc = DOC,
    a280,
    a355
  ) %>% 
  mutate(station = as.character(station)) %>% 
  separate(longitude, into = c("degree", "minute"), sep = "° ") %>%
  mutate(minute = gsub(",", ".", minute)) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(longitude = degree + (minute / 60)) %>% 
  select(-degree, -minute) %>% 
  separate(latitude, into = c("degree", "minute"), sep = "° ") %>%
  mutate(minute = gsub(",", ".", minute)) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(latitude = degree + (minute / 60)) %>% 
  select(-degree, -minute)

seritti1998_2 <- read_excel("dataset/raw/literature/seritti1998/seritti1998.xlsx", sheet = 2) %>% 
  select(
    station = Station,
    longitude,
    latitude,
    salinity = Salinity,
    doc = DOC,
    a280,
    a355
  ) %>% 
  separate(longitude, into = c("degree", "minute"), sep = "° ") %>%
  mutate(minute = gsub(",", ".", minute)) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(longitude = degree + (minute / 60)) %>% 
  select(-degree, -minute) %>% 
  separate(latitude, into = c("degree", "minute"), sep = "° ") %>%
  mutate(minute = gsub(",", ".", minute)) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(latitude = degree + (minute / 60)) %>% 
  select(-degree, -minute) 

# Merge and format --------------------------------------------------------

seritti1998 <- bind_rows(seritti1998_1, seritti1998_2) %>% 
  gather(wavelength, absorption, a280, a355) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(study_id = "seritti1998") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(date = as.Date("1997-09-01")) # Fixed date from the paper

# Save --------------------------------------------------------------------

write_feather(seritti1998, "dataset/clean/literature/seritti1998.feather")

# Plot --------------------------------------------------------------------

# map <- rworldmap::getMap()
# plot(map)
# points(seritti1998$longitude, seritti1998$latitude, col = "red")
# 
# seritti1998 %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = ecosystem)) +
#   facet_wrap(~wavelength, scales = "free") +
#   geom_smooth(method = "lm")
