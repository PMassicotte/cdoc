#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_datasets.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets containing CDOM and DOC data from
#               Colin, Eero and Philippe.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

colin <- list.files("dataset/clean/stedmon/", "*.rds", full.names = TRUE) %>% 
  lapply(., readRDS) %>% 
  bind_rows()

asmala2014 <- readRDS("dataset/clean/asmala2014/asmala2014.rds")

massicotte2011 <- readRDS("dataset/clean/massicotte2011/massicotte2011.rds")

cdom_doc <- bind_rows(colin, massicotte2011, asmala2014)

saveRDS(cdom_doc, file = "dataset/clean/complete_dataset.rds")