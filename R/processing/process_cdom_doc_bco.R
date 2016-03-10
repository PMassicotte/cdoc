#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_bco.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process CDOM and DOC data from:
#
# Osburn et al. 2009: http://data.bco-dmo.org/jg/serv/BCO/NACP_Coastal/GulfMexico/CDOM.html1?Location_ID%20eq%20Atchafalaya
#
# Chen et al. 2011: http://data.bco-dmo.org/jg/serv/BCO/NACP_Coastal/GulfMexico/CDOM.html1?Location_ID%20eq%20Mississippi_Plume
#
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

osburn <- readMat("dataset/raw/complete_profiles/osburn2010/CDOM.mat") %>%
  data.table::as.data.table() %>%
  as_data_frame() %>%
  mutate(DO = extract_numeric(DO))

osburn[osburn == "NaN"] <- NA

# chen <- readMat("dataset/raw/complete_profiles/chen2011/CDOM.mat") %>%
#   data.table::as.data.table() %>%
#   as_data_frame() %>%
#   mutate(depth = extract_numeric(depth),
#          temp = extract_numeric(temp),
#          DO = extract_numeric(DO))

# chen[chen == "NaN"] <- NA

bco <- select(osburn,
              location_id = Location.ID,
              station_name = Sta.name,
              study_id = PI.name,
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
              absorption = a.lambda) %>%
  mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
  mutate(unique_id = paste(study_id,
                           as.numeric(interaction(location_id,
                                                  station_name,
                                                  study_id,
                                                  date,
                                                  depth,
                                                  time,
                                                  drop = TRUE)),
                           sep = "_")) %>% 
  mutate(study_id = paste(tolower(study_id), format(date, "%Y"), sep = ""))


#Some weird CDOM sample, remove them
tmp <- group_by(bco, unique_id) %>%
  nest() %>%
  mutate(r2 = map(data, ~ cdom_fit_exponential(absorbance = .$absorption,
                                               wl = .$wavelength,
                                               startwl = 250,
                                               endwl = 750)$r2))
r2 <- unnest(tmp, r2)

r2thres <- 0.9
ggplot(tmp$data[which(r2$r2 <= r2thres)] %>% bind_rows(),
       aes(x = wavelength, y = absorption, group = station_name)) +
  geom_line()

`%ni%` = Negate(`%in%`)

bco <- filter(bco, unique_id %ni% tmp$unique_id[which(r2$r2 <= r2thres)])

saveRDS(bco, file = "dataset/clean/complete_profiles/bco.rds")

ggplot(bco, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_grid(~study_id, scales = "free")

ggsave("graphs/datasets/bco.pdf")
