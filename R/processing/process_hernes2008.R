#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_hernes2008.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Hernes et al. 2008
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hernes2008 <- read_excel("dataset/raw/literature/hernes2008/data.xlsx", na = "NA") %>% 
  
  mutate(date = as.Date(date, origin = "1899-12-30"))

saveRDS(hernes2008, "dataset/clean/literature/hernes2008.rds")
