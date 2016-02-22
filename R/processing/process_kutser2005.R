#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_kutser2005.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Helms et al. 2008
# 
# Kutser, T., Pierson, D. C., Tranvik, L., Reinart, A., Sobek, S., and 
# Kallio, K. (2005). Using Satellite Remote Sensing to Estimate the 
# Colored Dissolved Organic Matter Absorption Coefficient in Lakes. 
# Ecosystems 8, 709–720. doi:10.1007/s10021-003-0148-6.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

kutser2008 <- read_csv("dataset/raw/literature/kutser2005/data_kutser2005.csv") %>% 
  mutate(date = as.Date(paste(year, month, "01", sep = "-"))) %>% 
  select(-year, -month) %>%
  mutate(doc = doc / 12 * 1000, doc_unit = "umol") %>% 
  mutate(unique_id = paste("kutser2008",
                           as.numeric(interaction(study_id, sample_id, drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(kutser2008) == length(unique(kutser2008$unique_id)))

saveRDS(kutser2008, "dataset/clean/literature/helms2008.rds")

ggplot(kutser2008, aes(x = doc, y = acdom)) +
  geom_point() 