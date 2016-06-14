#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_bco.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process CDOM and DOC data from:
#
# Osburn et al. 2007: http://data.bco-dmo.org/jg/serv/BCO/NACP_Coastal/GulfMexico/CDOM.html1?Location_ID%20eq%20Atchafalaya
#
# Chen et al. 2000: http://data.bco-dmo.org/jg/serv/BCO/NACP_Coastal/GulfMexico/CDOM.html1?Location_ID%20eq%20Mississippi_Plume
#
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

bco <- data.table::fread("dataset/raw/complete_profiles/osburn2010/CDOM.csv", na.strings =  "NaN") %>% 
  as_data_frame() %>% 
  select(location_id = Location_ID,
         station_name = Sta_name,
         study_id = PI_name,
         date,
         latitude = lat,
         longitude = lon,
         time,
         depth,
         temperature = temp,
         salinity = sal,
         do = DO,
         doc = DOC,
         wavelength = Wavelength,
         absorption = a_lambda) %>%
  mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
  mutate(unique_id = paste(study_id,
                           as.numeric(interaction(location_id,
                                                  station_name,
                                                  study_id,
                                                  date,
                                                  time,
                                                  drop = TRUE)),
                           sep = "_")) %>%
  mutate(study_id = paste(tolower(study_id), format(date, "%Y"), sep = ""))

write_feather(bco, "dataset/clean/complete_profiles/bco.feather")
