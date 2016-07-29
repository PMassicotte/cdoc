#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
#AUTHOR:       Philippe Massicotte
#
#DESCRIPTION:  Process raw data from:
#
#Hur, J., Nguyen, H. V.-M., & Lee, B.-M. (2014). Influence of upstream land use
#on dissolved organic matter and trihalomethane formation potential in
#watersheds for two different seasons. Environmental Science and Pollution
#Research, 21(12), 7489–7500. http://doi.org/10.1007/s11356-014-2667-4 
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hur2014 <- read_csv("dataset/raw/literature/hur2014/hur2014.csv") %>% 
  setNames(tolower(names(.))) %>% 
  mutate(absorbance = suva254 * doc) %>% 
  mutate(wavelength = 254) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(date = as.Date(paste(date, "/01", sep = ""), format = "%Y/%m/%d")) %>% 
  mutate(absorption  = absorbance * 2.303) %>% 
  select(-absorbance) %>% 
  mutate(study_id = "hur2014") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(hur2014, "dataset/clean/literature/hur2014.feather")

# hur2014 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   geom_smooth(method = "lm")
