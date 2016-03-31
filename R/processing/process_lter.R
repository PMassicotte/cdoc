# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_lter.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Paul Hanson, Stephen Carpenter, Luke Winslow, and Jeffrey Cardille. 2014.
# Fluxes project at North Temperate Lakes LTER: Random lake survey 2004. GLEON
# Data Repository. gleon.1.9.
#
# https://lter.limnology.wisc.edu/dataset/north-temperate-lakes-lter-color-trout-lake-area-1989-current
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


# lter 1998-2000 ----------------------------------------------------------

# *************************************************************************
# While we there, process the data at fixed wavelength.
#
# https://lter.limnology.wisc.edu/data/filter/5653
# *************************************************************************

rm(list = ls())

lter5653 <- read_csv("dataset/raw/literature/lter/landscape_position_project__chemical_limnology.csv") %>%
  select(lake, date = sampledate, depth, rep, doc, color253, color280, color440) %>%
  gather(wavelength, absorbance, starts_with("color")) %>%
  mutate(doc = doc / 12 * 1000) %>%
  filter(!is.na(doc) & !is.na(absorbance)) %>%
  mutate(absorption = absorbance * 2.303 / 0.1) %>%
  mutate(depth = extract_numeric(depth)) %>%
  mutate(depth = ifelse(is.na(depth), Inf, depth)) %>%
  mutate(wavelength = extract_numeric(wavelength)) %>%
  select(-absorbance) %>%
  group_by(lake, date, depth, wavelength) %>%
  summarise(doc = mean(doc), absorption = mean(absorption)) %>%
  ungroup() %>%
  mutate(study_id = "lter5653") %>%
  mutate(unique_id = paste("lter5653", 1:nrow(.), sep = "_"))

station5653 <- read_excel("dataset/raw/literature/lter/stations.xlsx", "Sheet1")
lter5653 <- left_join(lter5653, station5653, by = "lake") %>%
  rename(lake_name = lake)


# lter 1981-2015 ----------------------------------------------------------

# *************************************************************************
# Data source:
#
# DOC: https://lter.limnology.wisc.edu/data/filter/5689
# CDOM: https://lter.limnology.wisc.edu/dataset/north-temperate-lakes-lter-color-trout-lake-area-1989-current
#
# The raw CDOM spectra are kinda messy, some measured on different range,
# some measured using different cuvette sizes. Hence, we decided to only
# absorption value measured in 1 cm cuvette at 254, 300, 350 and 400 nm.
# *************************************************************************

lter_cdom <- read_csv("dataset/raw/literature/lter/north_temperate_lakes_lter__color.csv") %>%
  mutate(absorption = value * 2.303 / (cuvette / 100)) %>%
  mutate(lakeid = toupper(lakeid)) %>%
  filter(is.na(color_flag)) %>%
  filter(cuvette == 1) %>%
  filter(wavelength %in% c(254, 300, 350, 400)) %>%
  select(-year4, -month, -color_flag, -cuvette, -value, date = sampledate)

lter_doc <- read_csv("dataset/raw/literature/lter/chemical_limnology_of_north_temperate_lakes_lter_primary_study_lakes__nutrients_ph_and_carbon.csv") %>%
  filter(!is.na(doc), depth == 0) %>% # cdom are surface samples, so only keep surface DOC
  mutate(doc = doc / 12 * 1000) %>%
  select(lakeid, date = sampledate, depth, doc, ph) %>%
  group_by(lakeid, date, depth) %>%
  summarise_each(funs(mean(., na.rm = TRUE))) %>%
  ungroup()

lter5689 <- inner_join(lter_doc, lter_cdom) %>%
  mutate(study_id = "lter5689") %>%
  mutate(unique_id = paste("lter5689", 1:nrow(.), sep = "_"))

station5689 <- read_excel("dataset/raw/literature/lter/stations.xlsx", "Sheet2") %>%
  select(lake_name = `lake name`, lakeid, longitude = Longitude, latitude = Latitude)

lter5689 <- left_join(lter5689, station5689, by = "lakeid")

lter <- bind_rows(lter5653, lter5689) %>%
  select(lake_name, date, depth, wavelength, doc, absorption, study_id,
         unique_id, lakeid, latitude, longitude)

saveRDS(lter, file = "dataset/clean/literature/lter.rds")
