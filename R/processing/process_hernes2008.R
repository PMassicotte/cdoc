#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_hernes2008.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Hernes et al. 2008
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hernes2008 <- read_excel("dataset/raw/literature/hernes2008/data.xlsx", na = "NA") %>% 
  
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  mutate(unique_id = paste("hernes2008",
                           as.numeric(interaction(study_id, sample_id, drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(hernes2008) == length(unique(hernes2008$unique_id)))

saveRDS(hernes2008, "dataset/clean/literature/hernes2008.rds")
