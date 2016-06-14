# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# http://www.thepolarisproject.org/data/
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

polaris2012 <- read_excel("dataset/raw/literature/polaris2012/polaris2012.xlsx") %>% 
  select(sample = Sample,
         date = Date,
         type = Type,
         channel_rank = `Channel Rank`,
         stream_size = `Str Size`,
         latitude = Latitude,
         longitude = Longitude,
         secchi = Secchi,
         depth = Depth,
         temperature = `W Temp`,
         ph = pH,
         doc = DOC,
         suva254 = SUVA254,
         a350:a440,
         a254 = A254) %>% 
  mutate(date = as.Date(date)) %>% 
  mutate(doc = doc / 12 * 1000) %>%
  filter(a254 < 150 & doc < 4000) %>% # clear outliers
  gather(wavelength, absorption, a350:a254) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>%
  fill(longitude, latitude) %>% 
  mutate(unique_id = paste("polaris2012", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "polaris2012") %>% 
  mutate(ecosystem = tolower(type)) %>% 
  mutate(ecosystem = ifelse(ecosystem == "stream" | 
                              is.na(ecosystem) | 
                              ecosystem == "other", "river", ecosystem))

write_feather(polaris2012, "dataset/clean/literature/polaris2012.feather")

# polaris2012 %>% 
#   ggplot(aes(x = doc, y = absorption)) + 
#   geom_point(aes(color = type)) + 
#   facet_wrap(~wavelength, scales = "free")
