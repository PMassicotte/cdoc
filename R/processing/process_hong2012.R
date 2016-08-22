#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Hong, H., Yang, L., Guo, W., Wang, F., & Yu, X. (2012). Characterization of
# dissolved organic matter under contrasting hydrologic regimes in a subtropical
# watershed using PARAFAC model. Biogeochemistry, 109(1–3), 163–174.
# http://doi.org/10.1007/s10533-011-9617-8
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

hong2012 <- read_excel("dataset/raw/literature/hong2012/hong2012.xlsx") %>% 
  select(latitude:doc) %>% 
  rename(absorption = acdom) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  mutate(study_id = "hong2012") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(hong2012, "dataset/clean/literature/hong2012.feather")

# hong2012 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()