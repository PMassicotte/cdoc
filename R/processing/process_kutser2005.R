#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_kutser2005.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Kutser, T., Pierson, D. C., Tranvik, L., Reinart, A., Sobek, S., and
# Kallio, K. (2005). Using Satellite Remote Sensing to Estimate the
# Colored Dissolved Organic Matter Absorption Coefficient in Lakes.
# Ecosystems 8, 709–720. doi:10.1007/s10021-003-0148-6.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

kutser2005 <- read_csv("dataset/raw/literature/kutser2005/data_kutser2005.csv", 
                       skip = 2,
                       col_names = c("sample_id", 
                                     "date", 
                                     "latitude", 
                                     "longitude",
                                     "chla",
                                     "chla_pheo",
                                     "tss",
                                     "spim",
                                     "spom",
                                     "acdom_temp", 
                                     "acdom",
                                     "doc")) %>%
  
  mutate(date = as.Date(date, format = "%d-%b-%y")) %>%
  select(-acdom_temp) %>%
  mutate(doc = doc / 12 * 1000) %>%
  mutate(wavelength = 420) %>% 
  mutate(study_id = "kutser2005") %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  filter(latitude != 0)

saveRDS(kutser2005, "dataset/clean/literature/helms2008.rds")
