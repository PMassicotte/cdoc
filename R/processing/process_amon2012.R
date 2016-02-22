#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_amon2012.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Amon et al. 2012
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

amon2012 <- read_csv("dataset/raw/literature/amon2012/data.csv") %>% 
  mutate(date = as.character(date)) %>% 
  mutate(date = as.Date(date, format = "%d-%m-%y")) %>%
  mutate(unique_id = paste("amon2012",
                           as.numeric(interaction(study_id, 
                                                  sample_id, 
                                                  depth,
                                                  drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(amon2012) == length(unique(amon2012$unique_id)))

saveRDS(amon2012, "dataset/clean/literature/amon2012")