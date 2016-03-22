# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_doc_lter.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Paul Hanson, Stephen Carpenter, Luke Winslow, and Jeffrey Cardille. 2014. 
# Fluxes project at North Temperate Lakes LTER: Random lake survey 2004. GLEON 
# Data Repository. gleon.1.9.
# 
# https://search.dataone.org/#view/gleon.1.9
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


# lter2004 ----------------------------------------------------------------

rm(list = ls())

# *************************************************************************
# The CDOM data has been measured in 1 and 10 cm cuvette. From graphs, it
# was obvious that the 10 cm spectra are problematic and thus have been 
# discarded.
# *************************************************************************

# read_csv("dataset/raw/complete_profiles/lter/2004/cgries.10.1.csv") %>% 
#   ggplot(aes(x = wavelength, y = absorption, group = lakeid)) +
#   geom_line(size = 0.05, alpha = 0.5) +
#   facet_wrap(~cuvette, scales = "free", ncol = 1) +
#   ggtitle("CDOM spectra measured in 1 and 10 cm cuvette")

hanson2014_cdom <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.10.1.csv") %>% 
  rename(wbic = lakeid) %>% 
  filter(cuvette == 1) %>% # only select 1 cm cuvette
  mutate(absorption = absorption * 2.303 / (cuvette / 100)) %>% 
  select(-cuvette)

hanson2014_doc <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.9.1.csv", na = "-999") %>% 
  filter(!is.na(doc)) %>% 
  mutate(doc = doc / 12 * 1000)

hanson2014_stations <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.5.1.csv") %>% 
  filter(!is.na(sampledate)) %>% 
  select(wbic, depth, longitude, latitude, date = sampledate)

lter2004 <- inner_join(hanson2014_doc, hanson2014_stations) %>% 
  inner_join(hanson2014_cdom) %>% 
  mutate(unique_id = paste("lter_2004",
                           as.numeric(interaction(date, wbic, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(study_id = "lter_2004") %>% 
  mutate(sample_id = unique_id)

saveRDS(lter2004, file = "dataset/clean/complete_profiles/lter2004.rds")


# ggplot(lter2004, aes(x = wavelength, y = absorption, group = unique_id)) +
#   geom_line(size = 0.1)

# lter 2001-2004 ----------------------------------------------------------

# *************************************************************************
# Data from: https://lter.limnology.wisc.edu/datacatalog/search
# Select "Organic Matter" from the list and hit "Search".
# *************************************************************************

rm(list = ls())

biocomplexity_stations <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__lakes.csv") %>% 
  select(lakeid,
         lakename,
         lake_number,
         wbic,
         county,
         longitude,
         latitude)

biocomplexity_cdom <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__color.csv") %>% 
  rename(date = sampledate) %>% 
  #https://lter.limnology.wisc.edu/variable/absorbance-bioc35
  mutate(absorption = value * 2.303 / 0.01) %>% 
  group_by(lakeid, date, wavelength, cell_size_cm) %>% 
  summarise(absorption = mean(absorption)) %>% 
  ungroup()

biocomplexity_doc <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__chemical_limnology.csv") %>% 
  select(lakeid, lakename, date = sampledate, rep, depth, doc) %>% 
  filter(!is.na(doc)) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  group_by(lakeid, date, depth) %>% 
  summarise(doc = mean(doc)) %>% 
  ungroup()

lter2001_2004 <- inner_join(biocomplexity_doc, biocomplexity_stations) %>% 
  inner_join(., biocomplexity_cdom) %>% 
  mutate(unique_id = paste("lter_2001_2004",
                           as.numeric(interaction(date, lakeid, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(sample_id = unique_id) %>% 
  mutate(study_id = "lter_2001_2004")

saveRDS(lter2001_2004, file = "dataset/clean/complete_profiles/lter2001_2004.rds")


# lter 1998-2000 ----------------------------------------------------------

# *************************************************************************
# While we there, process the data at fixed wavelength.
# 
# https://lter.limnology.wisc.edu/data/filter/5653
# *************************************************************************

rm(list = ls())

lter_1998_2000 <- read_csv("dataset/raw/literature/lter/landscape_position_project__chemical_limnology.csv") %>% 
  gather(wavelength, absorbance, starts_with("color")) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(absorption = absorbance * 2.303 / 0.01) %>%
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  select(-absorbance) %>% 
  mutate(study_id = "lter_1998_2000") %>% 
  mutate(sample_id = paste("lter_1998_2000", 1:nrow(.), sep = "_"))

saveRDS(lter_1998_2000, file = "dataset/clean/literature/lter_1998_2000.rds")
