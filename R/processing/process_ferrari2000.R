#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_ferrari2000.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Ferrari et al. 2000.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

ferrari2000 <- read_csv("dataset/raw/literature/ferrari2000/data.csv") %>% 
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  gather(range, S, matches("S\\d+")) %>% 
  mutate(date = as.Date(paste(year, month, "01", sep = "-"), format = "%Y-%B-%d")) %>% 
  select(-year, -month) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(unique_id = paste("ferrari2000",
                           as.numeric(interaction(study_id, 
                                                  sample_id, 
                                                  depth,
                                                  drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(ferrari2000) == length(unique(ferrari2000$unique_id)))

saveRDS(ferrari2000, "dataset/clean/literature/ferrari2000.rds")