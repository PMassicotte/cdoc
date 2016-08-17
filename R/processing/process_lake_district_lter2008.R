# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# https://lter.limnology.wisc.edu/data/filter/31115
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

doc <- read_csv("dataset/raw/literature/lter-lake-district2008/TBL_Chem_Lab_Analyses.csv") %>% 
  filter(Analysis == "DOC") %>% 
  select(abbrev, doc = Value) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(study_id = "lter2008") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "lake")

station <- read_csv("dataset/raw/literature/lter-lake-district2008/TBL_Plot.csv") %>% 
  select(
    abbrev = PlotAbbrev,
    date = Date,
    longitude = x,
    latitude = y
    ) %>% 
  mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
  fill(longitude, latitude) %>% 
  na.omit()

station <- SpatialPointsDataFrame(station[, c("longitude", "latitude")], data = station, 
                                  proj4string = CRS("+proj=utm +zone=16N +ellps=WGS84 +datum=WGS84"))
station <- spTransform(station, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))  
station <- as.data.frame(station) %>% as_data_frame() %>% 
  select(abbrev, date, longitude = longitude.1, latitude = latitude.1)

cdom <- read_csv("dataset/raw/literature/lter-lake-district2008/TBL_Chem_Absorbance.csv") %>% 
  select(abbrev = sample, a254:a440) %>% 
  gather(wavelength, absorption, a254:a440) %>% 
  mutate(wavelength = parse_number(wavelength))

lter2008 <- inner_join(doc, station, by = "abbrev") %>% 
  inner_join(cdom, by = "abbrev")

write_feather(lter2008, "dataset/clean/literature/lter2008.feather")

# lter2008 %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free")
