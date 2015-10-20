#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_massicotte2011.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Massicotte et al. 2011.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

station <- read_csv("dataset/raw/massicotte2011/data/station.csv") %>% 
  select(Date, StationID, Longitude_Decimal, Latitude_Decimal)

ysi <- read_csv("dataset/raw/massicotte2011/data/ysi.csv") %>% 
  select(StationID, Temp_S, Temp_D, Sal_S, Sal_D)

doc <- read_csv("dataset/raw/massicotte2011/data/doc.csv") %>% 
  select(StationID, ACDOM340_S, ACDOM340_D, ACDOM440_S, ACDOM440_D, DOC_S, DOC_D)

data <- left_join(station, ysi) %>% 
  
  left_join(doc) %>% 
  
  arrange(StationID) %>%  
  
  select(sample_id = StationID,
         date = Date,
         longitude = Longitude_Decimal,
         latitude = Latitude_Decimal,
         doc_s = DOC_S,
         doc_d = DOC_D,
         acdom_340_s = ACDOM340_S,
         acdom_340_d = ACDOM340_D,
         acdom_440_s = ACDOM440_S,
         acdom_440_d = ACDOM440_D,
         salinity_s = Sal_S,
         salinity_d = Sal_D,
         temperature_s = Temp_S,
         temperature_d = Temp_D)


dfs <- select(data, 
              sample_id = sample_id,
              date = date, 
              longitude = longitude,
              latitude = latitude,
              doc = doc_s,
              acdom340 = acdom_340_s,
              acdom440 = acdom_440_s,
              salinity = salinity_s,
              temperature = temperature_s)

dfd <- select(data, 
              sample_id = sample_id,
              date = date, 
              longitude = longitude,
              latitude = latitude,
              doc = doc_d,
              acdom340 = acdom_340_d,
              acdom440 = acdom_440_d,
              salinity = salinity_d,
              temperature = temperature_d)

data <- bind_rows(dfs, dfd)

data <- gather(data, wavelength, acdom, 
               -date, -sample_id, -longitude, -latitude, -doc, -salinity, -temperature)  

data$wavelength <- as.numeric(unlist(str_extract_all(data$wavelength, "\\d+")))

names(data)

massicotte2011 <- mutate(data,
               study_id = "massicotte2011",
               doc_unit = "µmol/l",
               filter_size = 0.2,
               season = "summer",
               doc = doc / 12 * 1000) %>%
  filter(doc <= 1000)

saveRDS(massicotte2011, "dataset/clean/massicotte2011.rds")

