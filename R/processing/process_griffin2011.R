# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from: Griffin, Claire G., Karen E. Frey, 
# John Rogan, and Robert M. Holmes. 2011. “Spatial and Interannual Variability 
# of Dissolved Organic Matter in the Kolyma River, East Siberia, Observed Using 
# Satellite Imagery.” Journal of Geophysical Research 116 (G3): G03018. 
# doi:10.1029/2010JG001634.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

griffin2011 <- read_excel("dataset/raw/literature/griffin2011/griffin2011.xlsx") %>% 
  select(station = Station,
         date = Date,
         longitude = Long,
         latitude = Lat,
         doc = DOC,
         absorption = a400) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(wavelength = 400) %>% 
  mutate(date = as.Date(date, "%d/%m/%Y")) %>%
  mutate(unique_id = paste("griffin2011", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "griffin2011")

write_feather(griffin2011, "dataset/clean/literature/griffin2011.feather")

griffin2011 %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point()
