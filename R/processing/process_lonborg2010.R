#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_lonborg2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Lonborg et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

lonborg2010 <- read_csv("dataset/raw/literature/lonborg2010/data_lonborg2010.csv") %>% 
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(date = as.Date(paste(year, month, date, sep = "-"))) %>% 
  select(-year, -month) %>% 
  mutate(sample_id = paste("lonborg2010", 1:nrow(.), sep = "_"))

saveRDS(lonborg2010, "dataset/clean/literature/lonborg2010.rds")
