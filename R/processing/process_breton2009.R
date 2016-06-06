# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Breton, Julie, Catherine Vallières, and Isabelle Laurion. 2009. 
# “Limnological Properties of Permafrost Thaw Ponds in Northeastern Canada.” 
# Canadian Journal of Fisheries and Aquatic Sciences 66 (10): 1635–48. 
# doi:10.1139/F09-108.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

breton2009 <- read_excel("dataset/raw/literature/breton2009/Breton2009.xlsx", na = "na") %>% 
  select(type, name, year, longitude = Long, latitude = Lat, doc = DOC,
         absorption = a320) %>%
  mutate(wavelength = 320) %>% 
  mutate(doc = doc / 12 * 1000) %>%
  mutate(unique_id = paste("breton2009", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "breton2009")
  
write_feather(breton2009, "dataset/clean/breton2009.feather")

# breton2009 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()

