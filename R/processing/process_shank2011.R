# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Shank, G. C., and Evans, A. (2011). Distribution and photoreactivity of
# chromophoric dissolved organic matter in northern Gulf of Mexico shelf waters.
# Cont. Shelf Res. 31, 1128–1139. doi:10.1016/j.csr.2011.04.009.
#
# DATE: Wed Mar 23 09:28:10 2016
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

stations <- read_excel("dataset/raw/literature/shank2011/shank2011.xlsx", "Tab1")
names(stations) <- tolower(names(stations))

table2 <- read_excel("dataset/raw/literature/shank2011/shank2011.xlsx", "Tab2")
table3 <- read_excel("dataset/raw/literature/shank2011/shank2011.xlsx", "Tab3")
table4 <- read_excel("dataset/raw/literature/shank2011/shank2011.xlsx", "Tab4")

shank2011 <- bind_rows(table2, table3, table4)

names(shank2011) <- tolower(names(shank2011))
names(shank2011) <- gsub("-", "_", names(shank2011))

shank2011 <- left_join(shank2011, stations, by = "site") %>%
  select(-`a305:doc`) %>%
  mutate(date = as.Date(date, origin = "1899-12-30")) %>%
  mutate(doc = doc / 12 * 1000) %>%
  rename(absorption = a305) %>%
  mutate(wavelength = 305) %>%
  mutate(study_id = "shank2011") %>%
  mutate(unique_id = paste("shank2011", 1:nrow(.), sep = "_"))

write_feather(shank2011, "dataset/clean/literature/shank2011.feather")
