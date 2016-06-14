# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Zhang, Yun Lin, Bo Qiang Qin, Wei Min Chen, and Guang Wei Zhu. 2005. 
# “A Preliminary Study of Chromophoric Dissolved Organic Matter (CDOM) in Lake 
# Taihu, a Shallow Subtropical Lake in China.” Acta Hydrochimica et 
# Hydrobiologica 33 (4): 315–23. doi:10.1002/aheh.200400585.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

zhang2005 <- read_csv("dataset/raw/literature/zhang2005/zhang2005.csv") %>% 
  gather(wavelength, absorption, starts_with("a")) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(study_id = "zhang2005") %>% 
  mutate(unique_id = paste("zhang2005", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "lake")

write_feather(zhang2005, "dataset/clean/literature/zhang2005.feather")

# zhang2005 %>% 
#   ggplot(aes(x = doc, y = absorption)) + 
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free") +
#   geom_smooth(method = "lm")
