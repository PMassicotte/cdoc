#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         plot_map.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Plot a map with location of sampling sites.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

literature <- readRDS("dataset/clean/literature_datasets.rds") %>% 
  filter(!is.na(longitude)) %>% 
  select(longitude, latitude, study_id, unique_id, ecotype)

doc_cdom <- readRDS("dataset/clean/cdom_dataset.rds") %>% 
  filter(!is.na(longitude)) %>% 
  distinct(unique_id) %>% 
  select(longitude, latitude, study_id, unique_id, ecotype) 


df <- bind_rows(literature, doc_cdom)

world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = 'COWCODE')

ggplot(world.points, aes(long, lat, group = group)) + 
  geom_polygon() +
  geom_point(data = df, aes(x = longitude, 
                                    y = latitude, 
                                    group = NULL,
                                    color = study_id), 
             alpha = 1, size = 0.25) +
  xlab("Longitude") +
  ylab("Latitude") +
  guides(colour = guide_legend(override.aes = list(size = 2))) +
  theme(legend.position = "top")

ggsave("graphs/map.pdf", width = 15, height = 10)

#---------------------------------------------------------------------
# Write a kml file.
#---------------------------------------------------------------------

df <- data.frame(df) %>% 
  arrange(ecotype, study_id, unique_id)

coordinates(df) <- c("longitude", "latitude")
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")

plotKML::kml(df, 
             file = "dataset/datasets.kml", 
             size = 1,
             colour = df$ecotype,
             shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
             points_names = paste(df$ecotype, df$study_id, df$unique_id, sep = "_"))

# ---------------------------------------------------------------------
# Find stations that at the same coord have more than two ecotypes.
# ---------------------------------------------------------------------
as_data_frame(data.frame(df)) %>% 
  group_by(longitude, latitude, study_id) %>% 
  summarise(n_ecotype = n_distinct(ecotype)) %>% 
  filter(n_ecotype > 1) %>% 
  arrange(study_id)



