#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# DeVilbiss, S. E., Zhou, Z., Klump, J. V., & Guo, L. (2016). Spatiotemporal
# variations in the abundance and composition of bulk and chromophoric dissolved
# organic matter in seasonally hypoxia-influenced Green Bay, Lake Michigan, USA.
# Science of The Total Environment, 565, 742–757.
# http://doi.org/10.1016/j.scitotenv.2016.05.015
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

files <-
  list.files("dataset/raw/literature/devilbiss2016/",
             "*.csv",
             full.names = TRUE)

names1 <- c(
  "station_id",
  "date",
  "latitude",
  "longitude",
  "temperature",
  "conductivity",
  "do",
  "chla",
  "depth"
)

names2 <- c(
  "station_id",
  "date",
  "doc",
  "a254",
  "suva254",
  "s275_295"
)

df <- lapply(files, read_csv, na = c("", "NA", "– ", "–"))

names(df[[1]]) <- names1
names(df[[2]]) <- names1
names(df[[3]]) <- names2
names(df[[4]]) <- names2


# Stations ----------------------------------------------------------------

stations <- bind_rows(df[1:2]) %>%
  fill(date) %>%
  mutate(date = as.Date(paste("01-", date, sep = ""), format = "%d-%b %Y")) %>%
  separate(
    latitude,
    into = c("degree", "minute", "second"),
    sep = c(2, 5)
  ) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(second = parse_number(second)) %>% 
  mutate(latitude = degree + (minute / 60) + (second / 3600)) %>% 
  select(-(degree:second)) %>% 
  separate(
    longitude,
    into = c("degree", "minute", "second"),
    sep = c(2, 5)
  ) %>% 
  mutate(degree = parse_number(degree)) %>% 
  mutate(minute = parse_number(minute)) %>% 
  mutate(second = parse_number(second)) %>% 
  mutate(longitude = degree + (minute / 60) + (second / 3600)) %>% 
  select(-(degree:second))

# DOC values --------------------------------------------------------------

doc <- bind_rows(df[3:4]) %>%
  fill(date) %>%
  mutate(date = as.Date(paste("01-", date, sep = ""), format = "%d-%b %Y")) %>% 
  rename(absorption = a254) %>% 
  mutate(wavelength = 254)

# Merge and save ----------------------------------------------------------

devilbiss2016 <- left_join(doc, stations, by = c("station_id", "date")) %>% 
  mutate(ecosystem = "lake") %>% 
  mutate(study_id = "devilbiss2016") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(devilbiss2016, "dataset/clean/devilbiss2016.feather")

# devilbiss2016 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
