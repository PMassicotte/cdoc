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

ggplot(cdom_doc, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~study_id, nrow = 3, scales = "free_y")
