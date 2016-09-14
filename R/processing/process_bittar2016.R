#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Bittar, T. B., Berger, S. A., Birsa, L. M., Walters, T. L., Thompson, M. E.,
# Spencer, R. G. M., … Brandes, J. A. (2016). Seasonal dynamics of dissolved,
# particulate and microbial components of a tidal saltmarsh-dominated estuary
# under contrasting levels of freshwater discharge. Estuarine, Coastal and Shelf
# Science. http://doi.org/10.1016/j.ecss.2016.08.046
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

# We select random coords because they are not provided in the paper...
set.seed(1234) 

# Read coordinates --------------------------------------------------------

# https://www.quora.com/Google-Earth-How-do-you-read-the-raw-data-in-a-KMZ-file

coords <- getKMLcoordinates(
  "dataset/raw/literature/bittar2016/doc.kml", 
  ignoreAltitude = TRUE
  ) %>% 
  do.call(rbind, .) %>% 
  data.frame() %>% 
  setNames(c("longitude", "latitude"))

# Read data ---------------------------------------------------------------

bittar2016 <- read_excel("dataset/raw/literature/bittar2016/mmc2.xlsx", 
                         sheet = 2,
                         skip = 3)

bittar2016 <- bittar2016[, !duplicated(names(bittar2016))] %>% 
  select(
    date = Date,
    salinity = `Salinity `,
    temprature = `Water temperature (oC)`,
    doc = `[DOC] (µM-C L-1)`,
    a254 = `CDOM a254 (m-1)`,
    a350 = `CDOM a350 (m-1)`
  ) %>%
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  cbind(., coords[sample(1:nrow(coords), nrow(.), replace = TRUE), ]) %>% 
  gather(wavelength, absorption, a254, a350) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  drop_na(doc, absorption, salinity) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity)) %>% 
  mutate(study_id = "bittar2016") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(bittar2016, "dataset/clean/literature/bittar2016.feather")

# bittar2016 %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free")
