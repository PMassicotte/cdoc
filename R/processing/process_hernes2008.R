#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_hernes2008.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Hernes, P. J., Spencer, R. G. M., Dyda, R. Y., Pellerin, B. A.,
# Bachand, P. A. M., and Bergamaschi, B. A. (2008). The role of hydrologic
# regimes on dissolved organic carbon composition in an agricultural watershed.
# Geochim. Cosmochim. Acta 72, 5266–5277. doi:10.1016/j.gca.2008.07.031.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hernes2008 <- read_excel("dataset/raw/literature/hernes2008/data.xlsx", na = "NA") %>%
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  mutate(longitude = -121.767570) %>% # based on Fig. 1 
  mutate(latitude = 38.602899) %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(study_id = "hernes2008") %>% 
  mutate(sample_id = paste("hernes2008", 1:nrow(.), sep = "_"))

saveRDS(hernes2008, "dataset/clean/literature/hernes2008.rds")
