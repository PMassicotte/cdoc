#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets cleaned by files starting with "process_*.R"
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

files <- list.files("dataset/clean/literature/", full.names = TRUE)

dataset <- lapply(files, read_feather)

# ********************************************************************
# For now, just select common variables.
# ********************************************************************

# mynames <- Reduce(intersect,  lapply(dataset, names))

data_all <- bind_rows(dataset) %>%
  filter(!is.na(doc) & !is.na(absorption) & doc > 0 & absorption > 0.01)

write_feather(data_all, "dataset/clean/literature_datasets.feather")
