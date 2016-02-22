#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2011.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2011.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2011 <- read_excel("dataset/raw/literature/osburn2011/data.xlsx", na = "NA") %>% 
  gather(wavelength, acdom, matches("a\\d+"))

osburn2011$sample_id <- as.character(osburn2011$sample_id)

osburn2011 <- mutate(osburn2011,
                     unique_id = paste("osburn2011",
                                       as.numeric(interaction(study_id, 
                                                              sample_id, 
                                                              cruise, depth,
                                                              drop = TRUE)),
                                       sep = "_"))

stopifnot(nrow(osburn2011) == length(unique(osburn2011$unique_id)))

saveRDS(osburn2011, "dataset/clean/literature/osburn2011.rds")
