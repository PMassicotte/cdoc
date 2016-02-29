#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_amon2012.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from :
# 
# http://doi.pangaea.de/10.1594/PANGAEA.789137?format=html#download
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

amon2012 <- read_delim("dataset/raw/literature/amon2012/ARK-XXII_2_fluorescence_DOC.tab", 
                       delim = "\t",
                       skip = 164) %>% 
  select(sample_id = Event,
         date = `Date/Time`,
         latitude = Latitude,
         longitude = Longitude,
         elevation = `Elevation [m]`,
         depth = `Depth water [m]`,
         doc = `DOC [mg/l]`,
         acdom = `ac350 [1/m]`,
         suva = `SUVA norm DOC [m**2/g]`) %>% 
  mutate(doc = doc / 12 * 1000,
         wavelength = 350,
         study_id = "amon2012") %>% 
  filter(!is.na(acdom) & !is.na(doc)) %>%
  mutate(unique_id = paste("amon2012",
                           as.numeric(interaction(study_id, 
                                                  sample_id, 
                                                  depth,
                                                  drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(amon2012) == length(unique(amon2012$unique_id)))

saveRDS(amon2012, "dataset/clean/literature/amon2012")