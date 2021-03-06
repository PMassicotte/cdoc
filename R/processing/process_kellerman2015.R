#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_kellerman2105.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process literature data from Kellerman et al. 2015.
#               http://doi.pangaea.de/10.1594/PANGAEA.844883
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

kellerman2015 <- read_delim("dataset/raw/literature/killerman2015/Swedish_lakes_PARAFAC.tab",
                      delim = "\t",
                      skip = 160)

names(kellerman2015) <- make.names(tolower(names(kellerman2015)))

kellerman2015 <- select(kellerman2015,
                  event = event,
                  date = date.time,
                  latitude,
                  longitude,
                  id,
                  depth = depth.water..m.,
                  doc = doc..mg.l.,
                  s250_600 = slope,
                  suva254 = suva..l.mg.m.,
                  absorption = absorp..arbitrary.units.)

kellerman2015 <- mutate(kellerman2015,
                  doc = doc / 12 * 1000,
                  absorption = absorption * 100,
                  wavelength = 254,
                  study_id = "kellerman2015",
                  id = as.character(id)) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("kellerman2015", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "lake")

write_feather(kellerman2015, "dataset/clean/literature/kellerman2015.feather")
