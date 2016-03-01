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
                  sample_id = event, 
                  date = date.time,
                  latitude,
                  longitude,
                  id,
                  depth = depth.water..m.,
                  doc = doc..mg.l.,
                  s250_600 = slope,
                  suva254 = suva..l.mg.m.,
                  acdom = absorp..arbitrary.units.)

kellerman2015 <- mutate(kellerman2015,
                  doc = doc / 12 * 1000,
                  acdom = acdom * 100,
                  wavelength = 254,
                  study_id = "kellerman2015") %>% 
  filter(!is.na(doc) & !is.na(acdom))

saveRDS(kellerman2015, file = "dataset/clean/literature/kellerman2015.rds")