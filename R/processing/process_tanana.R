#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_tanana.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# http://pubs.usgs.gov/of/2007/1390/section4.html (tables 4 and 5)
# 
# Hello Philippe,
# The suggested citation for this report is:
# Moran, E.H., 2007, Water quality in the Tanana River basin, Alaska, water 
# years 2004–06: U.S. Geological Survey Open-File Report 2007–1390, 6 p.
# 
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# ********************************************************************
# Year 2004.
# ********************************************************************
tanana2004 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table04.xls", skip = 4, na = "N/A")
tanana2004 <- tanana2004[, c(2, 3, 10, 11)]
names(tanana2004) <- c("map_no", "date", "suva254", "doc")
tanana2004$date <- as.Date(tanana2004$date)

# ********************************************************************
# Year 2005.
# ********************************************************************
tanana2005 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table05.xls", skip = 2)
tanana2005 <- tanana2005[, c(2, 3, 10, 11)]
names(tanana2005) <- c("map_no", "date", "suva254", "doc")
tanana2005$date <- as.Date(tanana2005$date)

# ********************************************************************
# Year 2006.
# ********************************************************************
tanana2006 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table06.xls", skip = 3)
tanana2006 <- tanana2006[, c(2, 3, 10, 11)]
names(tanana2006) <- c("map_no", "date", "suva254", "doc")
tanana2006$date <- as.Date(tanana2006$date, origin = "1899-12-30")

tanana <- rbind(tanana2004, tanana2005, tanana2006) %>%
  mutate(suva254 = parse_number(suva254),
         doc = parse_number(doc),
         absorption = ((suva254 * doc) * 2.303),
         doc = doc / 12 * 1000,
         wavelength = 254,
         study_id = "tanana") %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("tanana", 1:nrow(.), sep = "_"))

# ********************************************************************
# Get sampling locations coordinates.
# ********************************************************************
locations <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table01.xls", skip = 2) %>%
  select(latitude = `Latitude (NAD83)`,
         longitude = `Longitude (NAD83)`,
         map_no = `EMAP site identification No.`,
         stream_name = `Stream name`)

latitude <- separate(locations, latitude, into = c("deg", "min", "sec"), sep = " ") %>%
  mutate(deg = parse_number(deg),
         min = parse_number(min),
         sec = parse_number(sec),
         latitude = deg + (min / 60) + (sec / 3600) ) %>%
  select(latitude, map_no)

# ********************************************************************
# Merge everything.
# ********************************************************************
locations <- separate(locations, longitude, into = c("deg", "min", "sec"), sep = " ") %>%
  mutate(deg = parse_number(deg),
         min = parse_number(min),
         sec = parse_number(sec),
         longitude = deg + (min / 60) + (sec / 3600) ) %>%
  select(longitude, map_no) %>%
  left_join(latitude) %>%
  mutate(map_no = trimws(map_no)) %>%
  mutate(longitude = -longitude)

tanana <- left_join(tanana, locations, by = "map_no") %>% 
  mutate(ecosystem = "river")

write_feather(tanana, "dataset/clean/literature/tanana.feather")
