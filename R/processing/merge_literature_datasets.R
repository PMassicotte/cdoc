#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets cleaned by files starting with "process_*.R"
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

files <- list.files("dataset/clean/literature/", pattern = "^[^_]+$", full.names = TRUE)

dataset <- lapply(files, readRDS)

#---------------------------------------------------------------------
# For now, just select common variables.
#---------------------------------------------------------------------

#mynames <- Reduce(intersect,  lapply(dataset, names)) 

data_all <- bind_rows(dataset) %>% 
  filter(!is.na(doc) & !is.na(acdom))

saveRDS(data_all, "dataset/clean/literature_datasets.rds")

#---------------------------------------------------------------------
# Graph with all data.
#---------------------------------------------------------------------

ggplot(data_all, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(wavelength ~ study_id, scales = "free")

ggsave("graphs/literature_datasets.pdf", width = 10, height = 10)
