#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_mladenov2011.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Mladenov, N., Sommaruga, R., Morales-Baquero, R., Laurion, I., Camarero, L., 
# Diéguez, M. C., et al. (2011). Dust inputs and bacteria influence dissolved 
# organic matter in clear alpine lakes. Nat. Commun. 2, 405. 
# doi:10.1038/ncomms1411.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


# doc ---------------------------------------------------------------------

mladenov_doc <- read_excel("dataset/raw/literature/mladenov2011/mladenov2011.xlsx", sheet = "Tab3", na = "-")

mladenov_doc <- mladenov_doc[, 1:16]

mladenov_doc <- select(mladenov_doc,
                       site = Site,
                       lake_name = Lakename,
                       latitude = Lat,
                       longitude = Long,
                       date = Date,
                       doc = DOC,
                       depth = Ds) %>% 
  fill(site) %>% 
  separate(latitude, into = c("lat_deg", "lat_min"), sep = "°") %>% 
  separate(lat_min, into = c("lat_min", "lat_sec"), sep = "'", fill = "left", extra = "drop") %>% 
  separate(longitude, into = c("long_deg", "long_min"), sep = "°") %>% 
  separate(long_min, into = c("long_min", "long_sec"), sep = "'", fill = "left", extra = "drop") %>% 
  mutate(lat_deg = extract_numeric(lat_deg)) %>% 
  mutate(lat_min = extract_numeric(lat_min)) %>% 
  mutate(lat_sec = extract_numeric(lat_sec), lat_sec = ifelse(is.na(lat_sec), 0, lat_sec)) %>% 
  mutate(long_deg = extract_numeric(long_deg)) %>% 
  mutate(long_min = extract_numeric(long_min)) %>% 
  mutate(long_sec = extract_numeric(long_sec), long_sec = ifelse(is.na(long_sec), 0, long_sec)) %>% 
  mutate(longitude = abs(long_deg) + (long_min / 60) + (long_sec / 3600)) %>%
  mutate(longitude = ifelse(long_deg < 0, -longitude, longitude)) %>% 
  mutate(latitude = lat_deg + (lat_min / 60) + (lat_sec / 3600)) %>% 
  select(-(lat_deg:long_sec)) %>% 
  mutate(doc = doc * 1000) %>% # nm to um
  mutate(site = iconv(site, "latin1", "ASCII", sub = "")) %>%
  mutate(lake_name = iconv(lake_name, "latin1", "ASCII", sub = "")) %>% 
  mutate(unfiltred = ifelse(grepl("?u$", lake_name), TRUE, FALSE)) %>% 
  mutate(lake_name = str_replace(lake_name, "[*]+", "")) %>% 
  mutate(lake_name = gsub("?u$", "", lake_name)) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30"))

# cdom --------------------------------------------------------------------

mladenov_cdom <- read_excel("dataset/raw/literature/mladenov2011/mladenov2011.xlsx", sheet = "Tab4", na = "-")

mladenov_cdom <- mladenov_cdom[, 1:13]

mladenov_cdom <- select(mladenov_cdom,
                       site = Site,
                       lake_name = Lakename,
                       depth = Depth, 
                       a250:a320,
                       suva254 = SUVA254,
                       s275_295 = `S275-295`,
                       s350_400 = `S350-400`,
                       sr = SR) %>% 
  fill(site) %>% 
  mutate(site = iconv(site, "latin1", "ASCII", sub = "")) %>% 
  mutate(lake_name = iconv(lake_name, "latin1", "ASCII", sub = "")) %>% 
  mutate(unfiltred = ifelse(grepl("?u$", lake_name), TRUE, FALSE)) %>% 
  mutate(qc_passed = ifelse(grepl("?x$", lake_name), FALSE, TRUE)) %>% 
  mutate(lake_name = gsub("?u$", "", lake_name)) %>% 
  mutate(lake_name = gsub("?x$", "", lake_name))


# merge -------------------------------------------------------------------

mladenov <- inner_join(mladenov_doc, 
                       mladenov_cdom, 
                       by = c("site", "lake_name", "depth")) %>%
  gather(wavelength, acdom, a250:a320) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>% 
  filter(unfiltred.x == FALSE | unfiltred.y == FALSE) %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>%
  filter(doc > 0 & acdom > 0) %>% 
  filter(qc_passed == TRUE) %>% 
  select(-starts_with("unfiltred")) %>% 
  mutate(study_id = "mladenov2011") %>% 
  mutate(sample_id = paste("mladenov2011", 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "lake")

ggplot(mladenov, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(~wavelength, scale = "free")


saveRDS(mladenov, file = "dataset/clean/literature/mladenov2011.rds")

anti_join(mladenov_doc, 
          mladenov_cdom, 
          by = c("site", "lake_name", "depth"))
