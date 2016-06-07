# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Format raw data from:
# 
# Sickman, James O., Carol L. DiGiorgio, M. Lee Davisson, Delores M. Lucero, 
# and Brian Bergamaschi. 2010. “Identifying Sources of Dissolved Organic 
# Carbon in Agriculturally Dominated Rivers Using Radiocarbon Age Dating: 
# Sacramento–San Joaquin River Basin, California.” Biogeochemistry 99 (1–3): 
# 79–96. doi:10.1007/s10533-009-9391-z.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

sickman2010 <- read_excel("dataset/raw/literature/sickman2010/Sickman2010.xlsx") %>% 
  select(site = Site,
         date = Date,
         type = Type, 
         longitude = Long,
         latitude = Lat,
         doc = `DOC\r\n mg L-1`,
         suva254 = `SUVA\r\n (liter (mg meter)-1)`) %>% 
  mutate(absorption = ((suva254 / 100) * doc) * 2.303 / 0.01) %>% 
  mutate(doc = doc / 12 * 1000) %>%
  mutate(site = trimws(site)) %>% 
  mutate(date = as.Date(date)) %>% 
  mutate(unique_id = paste("sickman2010", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "sickman2010")

write_feather(sickman2010, "dataset/clean/literature/sickman2010.feather")

sickman2010 %>% 
  ggplot(aes(x = doc, y = absorption, color = site)) + 
  geom_point() +
  facet_wrap(~type, scales = "free")
