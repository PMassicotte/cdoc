#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_tanana.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# http://pubs.usgs.gov/of/2007/1390/section4.html (tables 4 and 5)
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
tanana2005 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table05.xls", skip = 3)
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
  mutate(suva254 = extract_numeric(suva254),
         doc = extract_numeric(doc),
         absorption = suva254 * doc * 2.303,
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
  mutate(deg = extract_numeric(deg),
         min = extract_numeric(min),
         sec = extract_numeric(sec),
         latitude = deg + (min / 60) + (sec / 3600) ) %>%
  select(latitude, map_no)

# ********************************************************************
# Merge everything.
# ********************************************************************
locations <- separate(locations, longitude, into = c("deg", "min", "sec"), sep = " ") %>%
  mutate(deg = extract_numeric(deg),
         min = extract_numeric(min),
         sec = extract_numeric(sec),
         longitude = deg + (min / 60) + (sec / 3600) ) %>%
  select(longitude, map_no) %>%
  left_join(latitude) %>%
  mutate(map_no = trimws(map_no)) %>%
  mutate(longitude = -longitude)

tanana <- left_join(tanana, locations, by = "map_no")

saveRDS(tanana, file = "dataset/clean/literature/tanana.rds")
