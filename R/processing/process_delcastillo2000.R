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

delcastillo2000 <- read_excel("dataset/raw/literature/delcastillo2000/delcastillo2000.xlsx", "Data") %>% 
  mutate(station = iconv(station, "latin1", "ASCII", sub = " ")) %>% 
  mutate(a375 = ifelse(grepl("?‡$", a375), NA, a375)) %>% 
  mutate(a412 = ifelse(grepl("?‡$", a412), NA, a412)) %>% 
  mutate(a440 = ifelse(grepl("?‡$", a440), NA, a440)) %>% 
  mutate(doc = extract_numeric(doc)) %>% 
  mutate(pp = extract_numeric(pp)) %>% 
  gather(wavelength, absorption, starts_with("a")) %>% 
  mutate(absorption = extract_numeric(absorption)) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  filter(absorption < 2) %>% 
  mutate(study_id = "delcastillo2000") %>% 
  mutate(unique_id = paste("delcastillo2000", 1:nrow(.), sep = "_")) %>% 
  mutate(ecotype = "ocean")
  

ggplot(delcastillo2000, aes(x = doc, y = absorption)) +
  geom_point() +
  facet_wrap(~wavelength)

saveRDS(delcastillo2000, file = "dataset/clean/literature/delcastillo2000.rds")