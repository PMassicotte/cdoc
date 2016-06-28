# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge complete and literature datasets into a single 
#               dataframe.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

target_wl <- 350

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(wavelength == target_wl) %>% 
  mutate(source = "complete")

cdom_literature <- read_feather("dataset/clean/literature_datasets_estimated_absorption.feather") %>%
  filter(r2 > 0.98) %>% 
  select(-absorption) %>% 
  dplyr::rename(absorption = predicted_absorption) %>% 
  filter(absorption > 0.01) %>% 
  mutate(source = "literature")

df <- bind_rows(cdom_complete, cdom_literature)

write_feather(df, "dataset/clean/complete_data_350nm.feather")
