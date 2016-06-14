# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Osburn, C. L., Wigdahl, C. R., Fritz, S. C., and Saros, J. E. (2011).
# Dissolved organic matter composition and photoreactivity in prairie lakes of
# the U.S. Great Plains. Limnol. Oceanogr. 56, 2371–2390.
# doi:10.4319/lo.2011.56.6.2371.
#
# DATE: Wed Mar 23 09:40:04 2016
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2011 <- read_excel("dataset/raw/literature/osburn2011/osburn2011.xlsx", "Data", na = "nd") %>%
  select(lake = Lake,
         state = State,
         latitude = Latitude,
         longitude = Longitude,
         doc = DOC,
         absorption = `a350 (m21)`,
         s300_650 = `S300–650 (mm21)`,
         s275_295 = `S275–295 (mm21)`,
         sr = SR) %>%
  mutate(doc = extract_numeric(doc)) %>%
  mutate(doc = doc / 12 * 1000) %>%
  mutate(s300_650 = s300_650 / 1000) %>%
  mutate(s275_295 = s275_295 / 1000) %>%
  mutate(wavelength = 350) %>%
  mutate(study_id = "osburn2011") %>%
  mutate(unique_id = paste("osburn2011", 1:nrow(.), sep = "_")) %>%
  filter(doc < 8000) %>%  # clear outlier
  mutate(ecosystem = "lake")

write_feather(osburn2011, "dataset/clean/literature/osburn2011.feather")
