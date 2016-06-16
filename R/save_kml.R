f <- function(df, study_id) {
  
  coordinates(df) <- c("longitude", "latitude")
  proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
  
  file <- paste0("dataset/kml/", study_id, ".kml")
  
  plotKML::kml(df, 
               file = file, 
               size = 1,
               colour = color,
               shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
               points_names = paste0(study_id, df$unique_id, df$ecosystem, 
                                     sep = "_"))
  
}


unlink("dataset/kml/", recursive = TRUE)
dir.create("dataset/kml")


# Read data ---------------------------------------------------------------

cdom_literature <- read_feather("dataset/clean/literature_datasets.feather") %>%
  select(study_id, unique_id, longitude, latitude, ecosystem) 

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(wavelength == 350) %>%
  select(study_id, unique_id, longitude, latitude, ecosystem) 

df <- bind_rows(cdom_literature, cdom_complete) %>% 
  mutate(color = palette()[factor(ecosystem)]) %>% 
  group_by(study_id) %>% 
  nest()

map2(df$data, df$study_id, f)

