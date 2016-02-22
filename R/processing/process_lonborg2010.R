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
  mutate(unique_id = paste("lonborg2010",
                           as.numeric(interaction(study_id, sample_id, drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(lonborg2010) == length(unique(lonborg2010$unique_id)))

saveRDS(lonborg2010, "dataset/clean/literature/lonborg2010.rds")
