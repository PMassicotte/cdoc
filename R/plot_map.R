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
  select(longitude, latitude, study_id, sample_id, salinity) %>% 
  distinct()

doc_cdom <- readRDS("dataset/clean/cdom_dataset.rds") %>% 
  filter(!is.na(longitude)) %>% 
  select(longitude, latitude, study_id, sample_id, salinity) %>% 
  distinct()

world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = 'COWCODE')

ggplot(world.points, aes(long, lat, group = group)) + 
  geom_polygon() +
  geom_point(data = literature, aes(x = longitude, 
                                    y = latitude, 
                                    group = NULL,
                                    color = study_id), 
             alpha = 1, size = 0.25) +
  geom_point(data = doc_cdom, aes(x = longitude, 
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

df <- bind_rows(literature, doc_cdom)

df <- data.frame(df)
coordinates(df) <- c("longitude", "latitude")
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")

plotKML::kml(df, 
             file = "dataset/datasets.kml", 
             size = 1,
             colour = df$study_id,
             shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
             points_names = paste(df$study_id, df$sample_id, sep = "_"))

