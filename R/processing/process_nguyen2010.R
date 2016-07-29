#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
#AUTHOR:       Philippe Massicotte
#
#DESCRIPTION:  Process raw data from:
#
#Nguyen, H. V.-M., Hur, J., & Shin, H.-S. (2010). Changes in Spectroscopic and
#Molecular Weight Characteristics of Dissolved Organic Matter in a River During
#a Storm Event. Water, Air, & Soil Pollution, 212(1–4), 395–406.
#http://doi.org/10.1007/s11270-010-0353-9 
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

nguyen2010 <- read_excel("dataset/raw/literature/nguyen2010/nguyen2010.xlsx") %>% 
  setNames(make.names(names(.))) %>% 
  setNames(tolower(names(.))) %>% 
  select(
    site:latitude,
    doc = doc.,
    s275_295 = s275.295,
    suva254
  ) %>% 
  mutate(date = as.Date("2008-07-25")) %>% 
  mutate(absorbance = suva254 * doc) %>% 
  mutate(absorption = absorbance * 2.303) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(wavelength = 254) %>% 
  select(-absorbance) %>% 
  mutate(study_id = "nguyen2010") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(nguyen2010, "dataset/clean/literature/nguyen2010.feather")

# nguyen2010 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
