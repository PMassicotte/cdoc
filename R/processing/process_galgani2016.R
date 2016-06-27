# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
# AUTHOR:       Philippe Massicotte
# 
# DESCRIPTION:  Process raw data from:
# 
# Galgani, Luisa, and Anja Engel. 2016. “Changes in Optical Characteristics of
# Surface Microlayers Hint to Photochemically and Microbially Mediated DOM
# Turnover in the Upwelling Region off the Coast of Peru.” Biogeosciences 13
# (8): 2453–73. doi:10.5194/bg-13-2453-2016. 
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

station <- read_excel("dataset/raw/literature/galgani2016/galgani2016.xlsx", sheet = "station")

station <- station[3:nrow(station) , !duplicated(colnames(station))] %>% 
  select(
    station = `Station nr. `,
    date = `Date `,
    latitude = `Lat, S `,
    longitude = `Long, W `
    ) %>% 
  mutate(station = trimws(station)) %>% 
  separate(latitude, into = c("lat_deg", "lat_min", "lat_sec")) %>% 
  separate(longitude, into = c("long_deg", "long_min", "long_sec")) %>% 
  mutate(latitude = extract_numeric(lat_deg) + 
           (extract_numeric(lat_min) / 60) + 
           (extract_numeric(lat_sec) / 3600)) %>% 
  mutate(longitude = extract_numeric(long_deg) + 
           (extract_numeric(long_min) / 60) + 
           (extract_numeric(long_sec) / 3600)) %>% 
  select(-starts_with(c("lat_"))) %>% 
  select(-starts_with(c("long_"))) %>% 
  mutate(date = as.Date(date, "%d-%m-%y")) %>% 
  mutate(longitude = -longitude) %>% 
  mutate(latitude = -latitude)

doc <- read_excel("dataset/raw/literature/galgani2016/galgani2016.xlsx", "data") %>% 
  select(station = Station,
         sample = Sample,
         absorption = `a(325)[m`,
         s_275_295 = `S(275-295)[nm`,
         doc = `DOC[mg L`,
         suva254 = `SUVA254 [mg C L`
         ) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(wavelength = 325) %>% 
  mutate(station = trimws(station))

galgani2016 <- full_join(station, doc, by = "station") %>% 
  fill(date, latitude, longitude) %>% 
  mutate(study_id = "galgani2016") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "ocean")

write_feather(galgani2016, "dataset/clean/literature/galgani2016.feather")

# galgani2016 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = sample))

