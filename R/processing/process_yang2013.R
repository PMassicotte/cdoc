#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Yang, L., Hong, H., Chen, C.-T. A., Guo, W., & Huang, T.-H. (2013).
# Chromophoric dissolved organic matter in the estuaries of populated and
# mountainous Taiwan. Marine Chemistry, 157, 12–23.
# http://doi.org/10.1016/j.marchem.2013.07.002 
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

yang2013 <- read_excel("dataset/raw/literature/yang2013/yang2013.xlsx") %>% 
  setNames(tolower(names(.))) %>% 
  setNames(make.names(names(.))) %>% 
  mutate(date = as.Date(paste(date, "/01", sep = ""))) %>% 
  select(
    site:latitude,
    a350:doc,
    s275_295 = s275.295,
    sr,
    a412
  ) %>% 
  gather(wavelength, absorption, a350, a412) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(study_id = "yang2013") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "estuary")

write_feather(yang2013, "dataset/clean/yang2013.feather")

# yang2013 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free") +
#   geom_smooth(method = "lm")