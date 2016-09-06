#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Spencer, R. G. M., Ahad, J. M. E., Baker, A., Cowie, G. L., Ganeshram, R.,
# Upstill-Goddard, R. C., & Uher, G. (2007). The estuarine mixing behaviour of
# peatland derived dissolved organic carbon and its relationship to chromophoric
# dissolved organic matter in two North Sea estuaries (U.K.). Estuarine, Coastal
# and Shelf Science, 74(1–2), 131–144. http://doi.org/10.1016/j.ecss.2007.03.032
# 
# Spencer, R. G. M., Baker, A., Ahad, J. M. E., Cowie, G. L., Ganeshram, R.,
# Upstill-Goddard, R. C., & Uher, G. (2007). Discriminatory classification of
# natural and anthropogenic waters in two U.K. estuaries. Science of The Total
# Environment, 373(1), 305–323. http://doi.org/10.1016/j.scitotenv.2006.10.052
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

spencer2007_1 <- read_excel("dataset/raw/literature/spencer2007/CDOM_DOC_GUher_July2016.xlsx",
                          sheet = "TyneTweed_GANE")

spencer2007_1 <- spencer2007_1[, !duplicated(names(spencer2007_1))] %>% 
  select(
    no = `No.`,
    transect_date = `Transect/Date`,
    site = Site,
    location_name = `Location Name`,
    salinity = Salinity,
    distance_n_sea = `km from N Sea`,
    doc = DOC,
    absorption = a350,
    position = pos
  ) %>% 
  na.omit() %>% 
  separate(transect_date, into = c("transect", "date"), sep = " ") %>% 
  mutate(date = as.Date(paste(date, "01", sep = "-"), format = "%b-%y-%d")) %>% 
  separate(position, into = c("latitude", "longitude"), sep = ",") %>% 
  mutate(longitude = parse_number(longitude)) %>% 
  mutate(latitude = parse_number(latitude))

spencer2007_2 <- read_excel("dataset/raw/literature/spencer2007/CDOM_DOC_GUher_July2016.xlsx",
                            sheet = "Tyne_NotGANE") %>% 
  select(
    no = `No. `,
    date = Date,
    station = Station,
    salinity = Salinity,
    doc = DOC,
    absorption = a350,
    position = pos
  ) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  fill(position) %>% # complete missing coordinates
  separate(position, into = c("latitude", "longitude"), sep = ",") %>% 
  mutate(longitude = parse_number(longitude)) %>% 
  mutate(latitude = parse_number(latitude)) %>% 
  na.omit()

spencer2007 <- bind_rows(spencer2007_1, spencer2007_2) %>% 
  mutate(site = as.character(site)) %>% 
  mutate(wavelength = 350) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(study_id = "spencer2007") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))
  
write_feather(spencer2007, "dataset/clean/literature/spencer2007.feather")

# spencer2007 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~ecosystem, scales = "free") +
#   geom_smooth(method = "lm")

# p1 <- spencer2007_1 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = transect)) +
#   facet_wrap(~transect, scales = "free") +
#   geom_smooth(method = "lm", size = 0.5)
# 
# p2 <- spencer2007_2 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   geom_smooth(method = "lm")
# 
# ggsave("/home/persican/Desktop/TyneTweed_GANE.pdf", p1, width = 7)
# ggsave("/home/persican/Desktop/Tyne_NotGANE.pdf", p2)
# 
# map <- rworldmap::getMap()
# plot(map)
# points(spencer2007_1$longitude, spencer2007_1$latitude, col = "red")
# points(spencer2007_2$longitude, spencer2007_2$latitude, col = "blue")
