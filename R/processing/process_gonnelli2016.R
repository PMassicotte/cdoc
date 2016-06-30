# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Gonnelli, M, Y Galletti, E Marchetti, L Mercadante, S Retelletti Brogi, 
# A Ribotti, R Sorgente, S Vestri, and C Santinelli. 2016. “Dissolved Organic 
# Matter Dynamics in Surface Waters Affected by Oil Spill Pollution: Results 
# from the Serious Game Exercise.” Deep Sea Research Part II: Topical Studies 
# in Oceanography, June. Elsevier. doi:10.1016/j.dsr2.2016.05.027.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

gonnelli2016 <- read_csv("dataset/raw/literature/gonnelli2016/gonnelli2016.csv",
                         skip = 2) %>% 
  select(station = Station,
         cruise = Cruise,
         doc = `DOC [µM]`,
         a254 = `a254 [m-1]`,
         a280 = `a280 [m-1]`,
         a325 = `a325 [m-1]`,
         a355 = `a355 [m-1]`,
         a443 = `a443 [m-1]`) %>% 
  mutate(date = if_else(cruise == "SG1A", as.Date("2014-05-17"), as.Date("2014-05-21"))) %>% 
  gather(wavelength, absorption, a254:a443) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  filter(doc > 1 & doc < 80) %>% # clear outliers
  mutate(longitude = 10.2) %>% # By eye based on Fig. 1 
  mutate(latitude = 43) %>% 
  mutate(study_id = "gonnelli2016") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "ocean") # Salinity > 35

write_feather(gonnelli2016, "dataset/clean/literature/gonnelli2016.feather")

# gonnelli2016 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free") +
#   geom_smooth(method = "lm")