#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from: 
# 
# Shen, Y., Chapelle, F. H., Strom, E. W., & Benner, R. (2015). Origins and
# bioavailability of dissolved organic matter in groundwater. Biogeochemistry,
# 122(1), 61–78. http://doi.org/10.1007/s10533-014-0029-4
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

shen2014 <- read_excel("dataset/raw/literature/shen2014/shen2014.xlsx") %>% 
  setNames(tolower(names(.))) %>% 
  gather(wavelength, absorption, a254, a280, a350) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  rename(longitude = long) %>% 
  rename(latitude = lat) %>% 
  rename(s275_295 = `s275–295`) %>%  
  rename(s350_400 = `s350–400`) %>% 
  mutate(study_id = "shen2014") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(shen2014, "dataset/clean/literature/shen2014.feather")

# shen2014 %>% 
#   ggplot(aes(x = doc, y = absortpion)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free", ncol = 1) +
#   geom_smooth(method = "lm")
