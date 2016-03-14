#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_river_delta_russia.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process data from:
# 
# DOC:
# 
# Dubinenkov, Ivan; Kraberg, Alexandra C; Bussmann, Ingeborg; Kattner, Gerhard; 
# Koch, Boris P (2015): Physical oceanography and dissolved organic matter in 
# the coastal Laptev Sea in 2013. Alfred Wegener Institute, Helmholtz Center 
# for Polar and Marine Research, Bremerhaven, doi:10.1594/PANGAEA.842221
# 
# WEB: http://doi.pangaea.de/10.1594/PANGAEA.842221
# 
# CDOM:
# 
# Gonçalves-Araujo, R., Stedmon, C. A., Heim, B., Dubinenkov, I., Kraberg, 
# A., Moiseev, D., et al. (2015). From Fresh to Marine Waters: Characterization 
# and Fate of Dissolved Organic Matter in the Lena River Delta Region, Siberia. 
# Front. Mar. Sci. 2, 108. doi:10.3389/fmars.2015.00108.
# 
# WEB: http://doi.pangaea.de/10.1594/PANGAEA.844928
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

doc <- read_delim("dataset/raw/literature/russia_delta_rivers/LenaDelta2013_phys_oce_DOC_TDN.tab", delim = "\t", skip = 44)

names(doc) <- make.names(names(doc))

doc <- select(doc,
              event = Event,
              id = SampleID,
              date = Date.Time,
              latitude = Latitude,
              longitude = Longitude,
              depth = Depth.water..m.,
              temperature = Temp...C.,
              salinity = Sal,
              pH,
              doc = DOC..µmol.l.)

cdom <- read_delim("dataset/raw/literature/russia_delta_rivers/Goncalves-Araujo-etal_2015.tab", delim = "\t", skip = 50)

names(cdom) <- make.names(names(cdom))

cdom <- select(cdom,
               event = Event,
               date = Date.Time,
               latitude = Latitude,
               longitude = Longitude,
               depth = Depth.water..m.,
               acdom350 = ac350..1.m.,
               acdom443 = ac443..1.m.)

river_delta_russia <- inner_join(doc, cdom, by = c("event", "date", "latitude", "longitude", "depth")) 

river_delta_russia <- gather(river_delta_russia, wavelength, acdom, starts_with("acdom")) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(date = as.Date(date)) %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(study_id = "russian_delta") %>% 
  mutate(sample_id = paste("russian_delta", 1:nrow(.), sep = "_")) %>% 
  mutate(ecotype = ifelse(salinity <= 25, "coastal", "ocean"))

saveRDS(river_delta_russia, file = "dataset/clean/literature/russian_delta.rds")

ggplot(river_delta_russia, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(~wavelength, scales = "free")
