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
  select(event = Event,
         date = `Date/Time`,
         latitude = Latitude,
         longitude = Longitude,
         elevation = `Elevation [m]`,
         depth = `Depth water [m]`,
         doc = `DOC [mg/l]`,
         absorption = `ac350 [1/m]`,
         suva254 = `SUVA norm DOC [m**2/g]`) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(doc = doc / 12 * 1000,
         wavelength = 350,
         study_id = "amon2012",
         date = as.Date(date),
         sample_id = paste("amon2012", 1:nrow(.), sep = "_"),
         ecotype = "ocean")

saveRDS(amon2012, "dataset/clean/literature/amon2012")

ggplot(amon2012, aes(x = doc, y = absorption)) +
  geom_point()
