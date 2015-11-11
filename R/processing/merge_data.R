#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets cleaned by files starting with "process_*.R"
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

files <- list.files("dataset/clean/", pattern = "^[^_]+$", full.names = TRUE)

dataset <- lapply(files, readRDS)

#---------------------------------------------------------------------
# For now, just select common variables.
#---------------------------------------------------------------------

mynames <- Reduce(intersect,  lapply(dataset, names)) 

data_all <- lapply(dataset, function(x){x[, mynames]}) %>% 
  bind_rows()


saveRDS(data_all, "dataset/clean/data_all.rds")


#---------------------------------------------------------------------
# Graph with all data.
#---------------------------------------------------------------------

ggplot(data_all, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_grid(wavelength ~ study_id, scales = "free")

ggsave("graphs/data_all.pdf", width = 10, height = 15)
