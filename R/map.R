#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         map.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Plot a map with location of sampling sites.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

library(cshapes)
library(gpclib)
library(maptools)
library(rgeos)
library(rgdal)

rm(list = ls())

literature <- readRDS("dataset/clean/literature_datasets.rds") %>% 
  filter(!is.na(longitude)) %>% 
  select(longitude, latitude, study_id, sample_id) %>% 
  distinct()

world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = 'COWCODE')

ggplot(world.points, aes(long, lat, group = group)) + 
  geom_polygon() +
  geom_point(data = literature, aes(x = longitude, 
                                    y = latitude, 
                                    group = NULL,
                                    color = study_id), 
             alpha = I(0.5), size = 1) +
  theme_bw() +
  xlab("Longitude") +
  ylab("Latitude") 

ggsave("graphs/map.pdf", width = 10, height = 5)

#---------------------------------------------------------------------
# Write a kml file.
#---------------------------------------------------------------------

literature <- data.frame(literature)
coordinates(literature) <- c("longitude", "latitude")
proj4string(literature) <- CRS("+proj=longlat +datum=WGS84")
#writeOGR(literature["study_id"], "dataset/literature.kml", layer="study_id", driver="KML") 

plotKML::kml(literature, 
             file = "dataset/datasets.kml", 
             size = 1,
             colour = literature$study_id,
             shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png",
             points_names = literature$sample_id)

plotKML::plotKML(literature)
