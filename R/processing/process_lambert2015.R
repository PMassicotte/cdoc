# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process the raw data from:
# 
# Lambert, Thibault, François Darchambeau, Steven Bouillon, Bassirou Alhou, 
# Jean-Daniel Mbega, Cristian R. Teodoru, Frank C. Nyoni, Philippe Massicotte, 
# and Alberto V. Borges. 2015. “Landscape Control on the Spatial and Temporal 
# Variability of Chromophoric Dissolved Organic Matter and Dissolved Organic 
# Carbon in Large African Rivers.” Ecosystems 18 (7): 1224–39. 
# doi:10.1007/s10021-015-9894-5.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

lambert2015 <- read_csv("dataset/raw/literature/lambert2015/lambert2015.csv", 
                        col_types = "ccddddddddd") %>% 
  mutate(date = as.Date(date, "%m/%d/%y")) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(study_id = "lambert2015") %>% 
  mutate(unique_id = paste("lambert2015", 1:nrow(.), sep = "_")) %>% 
  mutate(wavelength = 350) %>% 
  rename(absorption = a350)

write_feather(lambert2015, "dataset/clean/literature/lambert2015.feather")

# lambert2015 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~basin, scales = "free")
