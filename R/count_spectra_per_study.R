#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         count_spectra_per_study.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Count the number of different CDOM spectra in each study.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds")


res <- group_by(cdom_doc, study_id) %>% 
  summarise(n = n_distinct(unique_id))

res


