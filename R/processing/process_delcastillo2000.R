# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Del Castillo, C. E., Gilbes, F., Coble, P. G., and Müller-Karger,
# F. E. (2000). On the dispersal of riverine colored dissolved organic matter
# over the West Florida Shelf. Limnol. Oceanogr. 45, 1425–1432.
# doi:10.4319/lo.2000.45.6.1425.
#
# DATE: Wed Mar 23 09:59:23 2016
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

source("R/salinity2ecosystem.R")

delcastillo2000 <- read_excel("dataset/raw/literature/delcastillo2000/delcastillo2000.xlsx", "Data") %>%
  mutate(station = iconv(station, "latin1", "ASCII", sub = " ")) %>%
  mutate(a375 = ifelse(grepl("?‡$", a375), NA, a375)) %>%
  mutate(a412 = ifelse(grepl("?‡$", a412), NA, a412)) %>%
  mutate(a440 = ifelse(grepl("?‡$", a440), NA, a440)) %>%
  mutate(doc = parse_number(doc)) %>%
  mutate(pp = parse_number(pp)) %>%
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  gather(wavelength, absorption, starts_with("a")) %>%
  mutate(absorption = parse_number(absorption)) %>%
  mutate(wavelength = parse_number(wavelength)) %>%
  filter(absorption < 2) %>%
  mutate(study_id = "delcastillo2000") %>%
  mutate(unique_id = paste("delcastillo2000", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(delcastillo2000, "dataset/clean/literature/delcastillo2000.feather")
