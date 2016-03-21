# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_brezonik.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Brezonik, P. L., Olmanson, L. G., Finlay, J. C., and Bauer, M. E. (2015). 
# Factors affecting the measurement of CDOM by remote sensing of optically 
# complex inland waters. Remote Sens. Environ. 157, 199–215. 
# doi:10.1016/j.rse.2014.04.033.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

brezonik2015 <- read_csv("dataset/raw/literature/brezonik2015/brezonik2015.csv", na = "–")

brezonik2015 <- select(brezonik2015,
                       site_id = `Site ID and Name`,
                       date = Date,
                       latitude = Latitude,
                       longitude = Longitude,
                       a440 = `a440 m−1`,
                       s400_460 = `S400–460`,
                       s460_650 = `S460–650`,
                       s400_650 = `S400–650`,
                       suva254 = `SUVA 254 nm`,
                       secchi = `SD, m`,
                       doc = `DOC mg/L`,
                       tss = `TSS mg/L`,
                       chla = `Chl a μg/L`)

brezonik2015 <- mutate(brezonik2015,
                       a254 = suva254 * doc * 2.303,
                       doc = doc / 12 * 1000,
                       date = as.Date(paste(date, "-2013", sep = ""), 
                                      format = "%d-%b-%Y"))

brezonik2015 <- gather(brezonik2015, wavelength, absorption, starts_with("a")) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  mutate(sample_id = paste("brezonik2015", 1:nrow(.), sep = "_")) %>% 
  mutate(study_id = "brezonik2015") %>% 
  mutate(ecotype = "lake")

saveRDS(brezonik2015, file = "dataset/clean/literature/brezonik2015.rds")

# ggplot(brezonik2015, aes(x = doc, y = absorption)) +
#   geom_point() +
#   facet_wrap(~wavelength, scales = "free")