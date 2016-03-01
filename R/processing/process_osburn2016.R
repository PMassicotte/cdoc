#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2016.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Osburn, C. L., Boyd, T. J., Montgomery, M. T., Bianchi, T. S., Coffin, R. B., 
# and Paerl, H. W. (2016). Optical Proxies for Terrestrial Dissolved Organic 
# Matter in Estuaries and Coastal Waters. Front. Mar. Sci. 2. 
# doi:10.3389/fmars.2015.00127.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

osburn2016 <- read_excel("dataset/raw/literature/osburn2016/osburn2016.xlsx") %>% 
  select(estuary = Estuary,
         season = Season,
         latitude = Lat,
         longitude = Lon,
         salinity = Salinity,
         a254,
         a350,
         doc = DOC) %>% 
  gather(wavelength, acdom, a254, a350) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(sample_id = paste("osburn2016", 1:nrow(.), sep = "_")) %>% 
  mutate(study_id = "osburn2016")


saveRDS(osburn2016, file = "dataset/clean/literature/osburn2016.rds")

ggplot(osburn2016, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(~wavelength, scales = "free")
