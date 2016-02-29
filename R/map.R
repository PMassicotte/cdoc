library(cshapes)
library(gpclib)
library(maptools)
library(rgeos)

rm(list = ls())

literature <- readRDS("dataset/clean/literature_datasets.rds") %>% 
  filter(!is.na(longitude))

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
