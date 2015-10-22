#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         explore_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Priliminary script to explore data.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

data_all <- readRDS("data/clean/data_all.rds")

ggplot(data_all, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_grid(study_id ~ wavelength, scales = "free")