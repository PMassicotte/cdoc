#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_everglades.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# http://sofia.usgs.gov/exchange/aiken/aikenchem.html
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

#---------------------------------------------------------------------
# Surface water
#---------------------------------------------------------------------

everglades1 <- read_excel("dataset/raw/literature/everglades/DOC-data-SOFIA-5-02.xls",
                   skip = 2,
                   col_names = rep(c("site_id", "date", "doc", "suva254"), 2),
                   sheet = 1) %>%
  bind_rows(.[, 1:4], .[, 5:8]) %>%
  filter(complete.cases(.)) %>%
  mutate(suva254 = extract_numeric(suva254) * 100,
         acdom = extract_numeric(doc) * suva254 * 2.303, # convert suva to acdom
         doc = extract_numeric(doc) / 12 * 1000,
         wavelength = 254,
         date = as.Date(extract_numeric(date), origin = "1899-12-30"),
         depth = 0,
         study_id = "everglades_sw") %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(sample_id = paste("everglades_sw", 1:nrow(.), sep = "_"))

#---------------------------------------------------------------------
# Pore water
#---------------------------------------------------------------------

everglades2 <- read_excel("dataset/raw/literature/everglades/DOC-data-SOFIA-5-02.xls",
                         skip = 2,
                         col_names = rep(c("site_id", "date", "depth", "doc", "suva254"), 2),
                         sheet = 2) %>%
  bind_rows(.[, 1:5], .[, 6:10]) %>%
  fill(site_id, date) %>%
  filter(complete.cases(.) & site_id != "Site ID") %>%
  mutate(suva254 = extract_numeric(suva254) * 100,
         acdom = extract_numeric(doc) * suva254 * 2.303, # convert suva to acdom
         doc = extract_numeric(doc) / 12 * 1000,
         wavelength = 254,
         depth = extract_numeric(depth),
         date = as.Date(extract_numeric(date), origin = "1899-12-30"),
         study_id = "everglades_pw") %>% 
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(sample_id = paste("everglades_pw", 1:nrow(.), sep = "_"))

everglades <- bind_rows(everglades1, everglades2)

# table5d -----------------------------------------------------------------

table5d <- read_csv("dataset/raw/literature/everglades/table5d.csv")
table5d <- table5d[, 1:4]
names(table5d) <- c("lab_id", "site_id", "doc", "suva254")

table5d <- mutate(table5d,
                  acdom = doc / suva254,
                  doc = doc / 12 * 1000,
                  wavelength = 254,
                  study_id = "table5d") %>%
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(sample_id = paste("table5d", 1:nrow(.), sep = "_"))
  

everglades <- bind_rows(everglades, table5d) %>%
  filter(!is.na(doc) & !is.na(acdom)) %>% 
  mutate(longitude = -80.388200) %>% # based on code below I selected a central point
  mutate(latitude =  26.306640)

saveRDS(everglades, file = "dataset/clean/literature/everglades.rds")

# library(rvest)
# 
# url <- "http://sofia.usgs.gov/exchange/aiken/siteschem.html"
# 
# df <- read_html(url) %>% 
#   html_nodes("table") %>% 
#   html_table(fill = TRUE)
# 
# df <- df[[12]]
# 
# longitude <- as.character(df$`Longitude (DDMMSS)`)
# latitude <- as.character(df$`Latitude (DDMMSS)`)
# 
# longitude <- as.numeric(substr(longitude, 1, 2)) + 
#   as.numeric(substr(longitude, 3, 4)) / 60 +
#   as.numeric(substr(longitude, 5, 6)) / 3600
# 
# longitude <- -longitude
# 
# latitude <- as.numeric(substr(latitude, 1, 2)) + 
#   as.numeric(substr(latitude, 3, 4)) / 60 +
#   as.numeric(substr(latitude, 5, 6)) / 3600
# 
# 
# df <- data.frame(site = df$`Site ID`, longitude = longitude, latitude = latitude) %>% 
#   distinct()
# 
# coordinates(df) <- c("longitude", "latitude")
# proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
# 
# plotKML::kml(df, 
#              file = "tmp/everglades.kml", 
#              size = 1,
#              colour = df$study_id,
#              shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
#              points_names = df$site)
