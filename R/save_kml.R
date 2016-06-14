f <- function(df, study_id) {
  
  coordinates(df) <- c("longitude", "latitude")
  proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
  
  file <- paste0("dataset/kml/", study_id, ".kml")
  
  plotKML::kml(df, 
               file = file, 
               size = 1,
               colour = "red",
               shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
               points_names = paste0(study_id, df$unique_id, sep = "_"))
  
  
}


# Literature --------------------------------------------------------------

cdom_literature <- read_feather("dataset/clean/literature_datasets.feather") %>%
  select(study_id, unique_id, longitude, latitude) %>% 
  group_by(study_id) %>% 
  nest() 

map2(cdom_literature$data, cdom_literature$study_id, f)


# Complete profils --------------------------------------------------------

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(wavelength == 350) %>% 
  filter(!is.na(longitude)) %>% 
  select(study_id, unique_id, longitude, latitude) %>% 
  group_by(study_id) %>% 
  nest() 

map2(cdom_complete$data, cdom_complete$study_id, f)

