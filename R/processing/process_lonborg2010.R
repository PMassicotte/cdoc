#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_lonborg2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Lonborg et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

lonborg2010 <- read_csv("dataset/raw/literature/lonborg2010/data_lonborg2010.csv") %>%
  mutate(date = as.Date(date, format = "%d-%b-%Y")) %>%
  mutate(study_id = "lonborg2010") %>% 
  mutate(sample_id = paste("lonborg2010", 1:nrow(.), sep = "_")) %>% 
  mutate(longitude = -longitude)

saveRDS(lonborg2010, "dataset/clean/literature/lonborg2010.rds")
