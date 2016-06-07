# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Retamal, Leira, Warwick F. Vincent, Christine Martineau, and Christopher 
# L. Osburn. 2007. “Comparison of the Optical Properties of Dissolved Organic
# Matter in Two River-Influenced Coastal Regions of the Canadian Arctic.” 
# Estuarine, Coastal and Shelf Science 72 (1–2): 261–72. 
# doi:10.1016/j.ecss.2006.10.022.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

retamal2007 <- read_excel("dataset/raw/literature/retamal2007/retamal2007.xlsx") %>% 
  select(station = Station,
         date = Date,
         longitude = Long,
         latitude = Lat,
         salinity = Salinity,
         doc = DOC,
         absorption = a320) %>% 
  mutate(wavelength = 320) %>% 
  mutate(doc = doc / 12 * 1000) %>%
  mutate(date = as.Date(date, "%d-%m-%Y")) %>% 
  mutate(unique_id = paste("retamal2007", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "retamal2007")

write_feather(retamal2007, "dataset/clean/literature/retamal2007.feather")

# retamal2007 %>% 
#   ggplot(aes(x = doc, y = absorption)) + 
#   geom_point()

