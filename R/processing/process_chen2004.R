#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Chen, R. F., Bissett, P., Coble, P., Conmy, R., Gardner, G. B., Moran, M. A.,
# … Zepp, R. G. (2004). Chromophoric dissolved organic matter (CDOM) source
# characterization in the Louisiana Bight. Marine Chemistry, 89(1–4), 257–272.
# http://doi.org/10.1016/j.marchem.2004.03.017
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

chen2004 <- read_csv("dataset/raw/literature/chen2004/tabula-1-s2.0-S0304420304000921-main.csv") %>% 
  setNames(tolower(names(.))) %>% 
  mutate(longitude = -longitude) %>% 
  mutate(wavelength = 337) %>% 
  mutate(absorption = a337 * 2.303) %>% # absorbance to absorption
  select(-a337) %>% 
  mutate(study_id = "chen2004") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(date = seq(as.Date("2000-06-21"), # random dates based on the paper
                    as.Date("2000-06-28"), 
                    length.out = nrow(.)))

write_feather(chen2004, "dataset/clean/literature/chen2004.feather")


# chen2004 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   geom_smooth(method = "lm")
# 
# map <- rworldmap::getMap()
# plot(map)
# points(chen2004$longitude, chen2004$latitude, col = "red")
