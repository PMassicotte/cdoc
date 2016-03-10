#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_bouillon2014.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Bouillon, S., Yambélé, A., Gillikin, D. P., Teodoru, C., Darchambeau, F., 
# Lambert, T., et al. (2014). Contrasting biogeochemical characteristics of 
# the Oubangui River and tributaries (Congo River basin). Sci. Rep. 4, 5402. 
# doi:10.1038/srep05402.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

bouillon2014 <- read_excel("dataset/raw/literature/bouillon2014/bouillon2014.xlsx") %>% 
  select(date = Date, 
         site = Site,
         latitude = Lat,
         longitude = Long,
         temperature = T,
         pH,
         doc = DOC,
         acdom = `a350(m-1)`) %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(sample_id = paste("bouillon2014", 1:nrow(.), sep = "_")) %>% 
  mutate(date = as.Date(date, format = "%d/%m/%Y")) %>% 
  mutate(study_id = "bouillon2014") %>% 
  mutate(wavelength = 350) %>% 
  mutate(doc = doc / 12 * 1000)

saveRDS(bouillon2014, file = "dataset/clean/literature/bouillon2016.rds")
