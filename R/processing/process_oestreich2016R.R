# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Oestreich, W. K., N. K. Ganju, J. W. Pohlman, and S. E. Suttles. 2016. 
# “Colored Dissolved Organic Matter in Shallow Estuaries: Relationships 
# between Carbon Sources and Light Attenuation.” Biogeosciences 13 (2): 583–95. 
# doi:10.5194/bg-13-583-2016.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

oestreich2016 <- read_csv("dataset/raw/literature/oestreich2016/oestreich2016.csv") %>% 
  mutate(wavelength = 340) %>% 
  rename(absorption = a340) %>% 
  mutate(study_id = "oestreich2016") %>% 
  mutate(unique_id = paste("oestreich2016", 1:nrow(.), sep = "_"))

write_feather(oestreich2016, "dataset/clean/literature/oestreich2016.feather")
  
# oestreich2016 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
