# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# https://lter.limnology.wisc.edu/data/filter/32494
# 
# Fluxes project at North Temperate Lakes LTER: Random lake survey 2004
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

doc <- read_csv("dataset/raw/complete_profiles/lter-random-lake-2004/random_lake_survey_measured_parameters.csv", na = "-999") %>% 
  select(wbic, doc) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(study_id = "lter2004") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

cdom <- read_csv("dataset/raw/complete_profiles/lter-random-lake-2004/random_lake_survey_raw_absorption.csv") %>% 
  mutate(absorption = (absorption * 2.303) / (cuvette / 100)) %>% 
  filter(wavelength %in% 250:600) %>% 
  filter(cuvette == 1) %>%  # I do not trust 10 cm cuvette in lakes
  group_by(lakeid) %>% 
  filter(absorption[wavelength = 250] > 0) %>%  # Remove absorption at 250 < 0
  ungroup()

station <- read_csv("dataset/raw/complete_profiles/lter-random-lake-2004/random_lake_survey_lakes.csv") %>% 
  select(-area)

lter2004 <- inner_join(doc, cdom, by = c("wbic" = "lakeid")) %>% 
  inner_join(station, by = "wbic") %>% 
  mutate(ecosystem = "lake")

write_feather(lter2004, "dataset/clean/complete_profiles/lter2004.feather")

# lter2004 %>% 
#   filter(wavelength == 254) %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = factor(cuvette)))
# 
cdom %>%
  filter(wavelength %in% 250:600) %>%
  ggplot(aes(
    x = wavelength,
    y = absorption,
    group = interaction(lakeid, groupid)
  )) +
  geom_line() +
  facet_wrap( ~ cuvette)
