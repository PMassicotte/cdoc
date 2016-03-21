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

rm(list = ls())

hanson2014_cdom <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.10.1.csv") %>% 
  rename(wbic = lakeid)

hanson2014_cdom <- mutate(hanson2014_cdom,
                          absorption = absorption * 2.303 / (cuvette / 100))

hanson2014_doc <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.9.1.csv", na = "-999") %>% 
  filter(!is.na(doc))

hanson2014_stations <- read_csv("dataset/raw/complete_profiles/lter/2004/cgries.5.1.csv") %>% 
  filter(!is.na(sampledate))

hanson2014 <- inner_join(hanson2014_doc, hanson2014_stations) %>% 
  inner_join(hanson2014_cdom) %>% 
  mutate(unique_id = paste("lter2004",
                           as.numeric(interaction(groupid, wbic, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(study_id = "lter2004") %>% 
  mutate(sample_id = unique_id)

saveRDS(hanson2014, file = "dataset/clean/complete_profiles/lter2004.rds")

ggplot(hanson2014, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1)

filter(hanson2014, wavelength == 254) %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point() 

# lter 2001-2004 ----------------------------------------------------------

rm(list = ls())

biocomplexity_stations <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__lakes.csv") 

biocomplexity_cdom <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__color.csv") %>% 
  mutate(absorption = value * 2.303 / (cell_size_cm / 100)) %>% 
  group_by(lakeid, sampledate, wavelength) %>% 
  summarise(absorption = mean(absorption), n = n()) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  ungroup()

biocomplexity_doc <- read_csv("dataset/raw/complete_profiles/lter/2001-2004/biocomplexity__coordinated_field_studies__chemical_limnology.csv") %>% 
  select(lakeid, lakename, sampledate, rep, depth, doc) %>% 
  filter(!is.na(doc)) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  group_by(lakeid, sampledate, depth) %>% 
  summarise(doc = mean(doc)) %>% 
  ungroup()

lter2001_2004 <- inner_join(biocomplexity_doc, biocomplexity_stations) %>% 
  inner_join(., biocomplexity_cdom) %>% 
  mutate(unique_id = paste("lter2001_2004",
                           as.numeric(interaction(sampledate, lakeid, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(sample_id = unique_id) %>% 
  mutate(study_id = "lter2001_2004")

saveRDS(lter2001_2004, file = "dataset/clean/complete_profiles/lter2001_2004.rds")
