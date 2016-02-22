#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2010.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2010.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2010 <- read_csv("dataset/raw/literature/osburn2010/data.csv") %>% 
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  mutate(date = as.Date(paste(year, month, "01", sep = "-"))) %>% 
  select(-year, -month) %>% 
  mutate(wavelength = extract_numeric(wavelength))

osburn2010$wavelength <- as.numeric(unlist(str_extract_all(osburn2010$wavelength, "\\d+")))

osburn2010$sample_id <- paste(osburn2010$study_id, 1:nrow(osburn2010), sep = "_")

osburn2010 <-  mutate(osburn2010,
                      unique_id = paste("osburn2010",
                           as.numeric(interaction(study_id, 
                                                  ecosystem,
                                                  depth,
                                                  date,
                                                  drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(osburn2010) == length(unique(osburn2010$unique_id)))

saveRDS(osburn2010, "dataset/clean/literature/osburn2010.rds")