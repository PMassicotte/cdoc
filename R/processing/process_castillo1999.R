#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_castillo1999.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Castillo et al. 1999
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

castillo1999 <- read_csv("dataset/raw/literature/castillo1999/data.csv") %>% 
  mutate(unique_id = paste("castillo1999",
                           as.numeric(interaction(study_id, sample_id, drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(castillo1999) == length(unique(castillo1999$unique_id)))

saveRDS(castillo1999, "dataset/clean/literature/castillo1999.rds")

